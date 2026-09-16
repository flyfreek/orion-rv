"""Small independent, sequential RV32I oracle for the core's test environment.

No RTL imports. Byte-addressed little-endian memory; aligned accesses only.
Compare separate in-order register-write/read/store streams because the DUT
stores in MEM and writes registers in WB, not at one common retire stage.
This is differential side-effect checking, not a cycle-accurate pipeline model.
"""
import argparse
import json
from pathlib import Path

MASK = 0xffffffff
RAM = 0x10000000
RAM_SIZE = 16384


def signed(value, bits=32):
    value &= (1 << bits) - 1
    return value - (1 << bits) if value & (1 << (bits - 1)) else value


class Model:
    def __init__(self, words):
        if not 0 < len(words) <= 256:
            raise ValueError('Image must contain 1..256 words')
        self.rom = bytearray(1024)
        for i in range(256):
            self.rom[i*4:i*4+4] = (words[i] if i < len(words) else 0x13).to_bytes(4, 'little')
        self.ram = bytearray(RAM_SIZE)
        self.regs = [0] * 32
        self.pc = 0
        self.events = {'W': [], 'R': [], 'S': []}
        self.steps = 0

    def region(self, addr, size):
        if 0 <= addr and addr + size <= len(self.rom):
            return self.rom, addr
        if RAM <= addr and addr + size <= RAM + RAM_SIZE:
            return self.ram, addr - RAM
        raise ValueError(f'Unmapped access {addr:08x} size={size}')

    def read(self, addr, size):
        if addr % size:
            raise ValueError(f'Misaligned access {addr:08x} size={size}')
        mem, offset = self.region(addr, size)
        return int.from_bytes(mem[offset:offset+size], 'little')

    def write(self, addr, size, value):
        if addr % size:
            raise ValueError(f'Misaligned store {addr:08x} size={size}')
        mem, offset = self.region(addr, size)
        if mem is self.rom:
            raise ValueError('Self-modifying code not supported by this oracle')
        mem[offset:offset+size] = (value & ((1 << (size*8))-1)).to_bytes(size, 'little')

    def run(self, limit=20000):
        for self.steps in range(1, limit+1):
            pc = self.pc
            inst = self.read(pc, 4)
            op, rd, f3, rs1, rs2, f7 = inst & 127, (inst >> 7) & 31, (inst >> 12) & 7, (inst >> 15) & 31, (inst >> 20) & 31, inst >> 25
            a, b = self.regs[rs1], self.regs[rs2]
            imm = signed(inst >> 20, 12)
            next_pc, result = (pc+4) & MASK, None
            if inst == 0x6f and self.regs[26] == 1:
                if self.regs[27] != 1:
                    raise ValueError(f'Program self-check failed, x3={self.regs[3]}')
                return self
            if op == 0x37:
                result = inst & 0xfffff000
            elif op == 0x17:
                result = pc + (inst & 0xfffff000)
            elif op == 0x6f:
                off = signed(((inst >> 31) << 20) | (((inst >> 12) & 255) << 12) | (((inst >> 20) & 1) << 11) | (((inst >> 21) & 1023) << 1), 21)
                result, next_pc = pc+4, (pc+off) & MASK
            elif op == 0x67 and f3 == 0:
                result, next_pc = pc+4, ((a+imm) & MASK) & ~1
            elif op == 0x63:
                off = signed(((inst >> 31) << 12) | (((inst >> 7) & 1) << 11) | (((inst >> 25) & 63) << 5) | (((inst >> 8) & 15) << 1), 13)
                conds = {0: a == b, 1: a != b, 4: signed(a) < signed(b), 5: signed(a) >= signed(b), 6: a < b, 7: a >= b}
                if f3 not in conds:
                    raise ValueError('Illegal branch')
                if conds[f3]:
                    next_pc = (pc+off) & MASK
            elif op == 3:
                sizes = {0: 1, 1: 2, 2: 4, 4: 1, 5: 2}
                if f3 not in sizes:
                    raise ValueError('Illegal load')
                addr = (a+imm) & MASK
                value = self.read(addr, sizes[f3])
                self.events['R'].append((addr, self.read(addr & ~3, 4)))
                result = signed(value, sizes[f3]*8) if f3 < 4 else value
            elif op == 0x23:
                if f3 not in (0, 1, 2):
                    raise ValueError('Illegal store')
                off = signed(((inst >> 25) << 5) | ((inst >> 7) & 31), 12)
                addr = (a+off) & MASK
                self.write(addr, 1 << f3, b)
                # Match the DUT full-word RMW bus, derived from byte stores.
                self.events['S'].append((addr, self.read(addr & ~3, 4)))
            elif op in (0x13, 0x33):
                rhs = (imm & MASK) if op == 0x13 else b
                shift = rhs & 31
                if op == 0x33 and f7 not in (0, 0x20):
                    raise ValueError('Unsupported R-type/M-extension instruction')
                if op == 0x33 and f7 == 0x20 and f3 not in (0, 5):
                    raise ValueError('Illegal R-type instruction')
                if f3 == 0:
                    result = a-rhs if op == 0x33 and f7 == 0x20 else a+rhs
                elif f3 == 1:
                    if f7 != 0:
                        raise ValueError('Illegal SLL encoding')
                    result = a << shift
                elif f3 == 2:
                    result = int(signed(a) < signed(rhs))
                elif f3 == 3:
                    result = int(a < rhs)
                elif f3 == 4:
                    result = a ^ rhs
                elif f3 == 5:
                    if f7 not in (0, 0x20):
                        raise ValueError('Illegal right shift')
                    result = signed(a) >> shift if f7 == 0x20 else a >> shift
                elif f3 == 6:
                    result = a | rhs
                elif f3 == 7:
                    result = a & rhs
            else:
                raise ValueError(f'Unsupported instruction {inst:08x} at PC {pc:08x}')
            if result is not None and rd:
                self.regs[rd] = result & MASK
                self.events['W'].append((rd, result & MASK))
            self.pc = next_pc
        raise ValueError(f'Reference step limit {limit} exceeded')


def compare(model, trace):
    actual = {'W': [], 'R': [], 'S': []}
    regs, memory = {}, {}
    completed = False
    for line in trace.splitlines():
        fields = line.split()
        if not fields:
            continue
        kind = fields[0]
        if kind in actual:
            actual[kind].append(tuple(int(v, 16) for v in fields[1:]))
        elif kind == 'F':
            index, value = (int(v, 16) for v in fields[1:])
            if index in regs:
                raise ValueError('Duplicate final register')
            regs[index] = value
        elif kind == 'D':
            index, value = (int(v, 16) for v in fields[1:])
            if index in memory:
                raise ValueError('Duplicate final RAM word')
            memory[index] = value
        elif kind == 'END':
            completed = True
        else:
            raise ValueError(f'Unknown trace record: {line}')
    if not completed:
        raise ValueError('Incomplete DUT trace (no END)')
    for kind, expected in model.events.items():
        if actual[kind] != expected:
            for i in range(max(len(expected), len(actual[kind]))):
                want = expected[i] if i < len(expected) else None
                got = actual[kind][i] if i < len(actual[kind]) else None
                if want != got:
                    raise ValueError(f'{kind} event {i}: expected={want}, actual={got}; lengths={len(expected)}/{len(actual[kind])}')
    if regs != dict(enumerate(model.regs)):
        raise ValueError('Final register file differs from reference')
    expected_memory = {i: model.read(RAM+i*4, 4) for i in range(RAM_SIZE//4)}
    if memory != expected_memory:
        raise ValueError('Final RAM differs from reference')
    return {'steps': model.steps, 'register_writes': len(model.events['W']),
            'loads': len(model.events['R']), 'stores': len(model.events['S']),
            'final_registers_checked': 32, 'final_ram_words_checked': RAM_SIZE//4}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--program', required=True)
    parser.add_argument('--trace', required=True)
    parser.add_argument('--report', required=True)
    args = parser.parse_args()
    try:
        words = [int(v, 16) for v in Path(args.program).read_text().split()]
        result = compare(Model(words).run(), Path(args.trace).read_text())
        result['status'] = 'REF_PASS'
        code = 0
    except (ValueError, OSError) as exc:
        result = {'status': 'REF_FAIL', 'reason': str(exc)}
        code = 1
    Path(args.report).write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result))
    return code


if __name__ == '__main__':
    raise SystemExit(main())
