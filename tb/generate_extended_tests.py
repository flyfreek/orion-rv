"""Emit an apply_patch patch for reproducible Memory/X0/Reference test images.
Run from repository root; stdout contains new-file patches (not direct writes).
"""
import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.as_posix()


class Program:
    def __init__(self, number):
        self.code, self.labels = [], {}
        self.addi(26, 0, 0); self.addi(27, 0, 0); self.addi(3, 0, number)
        self.li(10, 0x10000000)

    def emit(self, text, value):
        self.code.append((text, value))

    def label(self, name):
        self.labels[name] = len(self.code)*4

    def i(self, op, rd, f3, rs, imm, text):
        self.emit(text, ((imm & 4095) << 20) | (rs << 15) | (f3 << 12) | (rd << 7) | op)

    def addi(self, d, a, n):
        self.i(0x13, d, 0, a, n, f'addi x{d},x{a},{n}')

    def li(self, d, value):
        value &= 0xffffffff
        s = value if value < 0x80000000 else value-0x100000000
        if -2048 <= s <= 2047:
            self.addi(d, 0, s)
        else:
            hi = ((value+0x800) >> 12) & 0xfffff
            lo = value & 4095
            if lo >= 2048: lo -= 4096
            self.emit(f'lui x{d},0x{hi:x}', (hi << 12) | (d << 7) | 0x37)
            self.addi(d, d, lo)

    def gap(self):
        self.addi(0, 0, 0); self.addi(0, 0, 0)

    def reg(self, op, d, a, b):
        f3, f7 = {'add':(0,0),'sub':(0,32),'sll':(1,0),'slt':(2,0),'sltu':(3,0),
                  'xor':(4,0),'srl':(5,0),'sra':(5,32),'or':(6,0),'and':(7,0)}[op]
        self.emit(f'{op} x{d},x{a},x{b}', (f7<<25)|(b<<20)|(a<<15)|(f3<<12)|(d<<7)|0x33)

    def load(self, op, d, a, off=0):
        self.i(3,d,{'lb':0,'lh':1,'lw':2,'lbu':4,'lhu':5}[op],a,off,f'{op} x{d},{off}(x{a})')

    def store(self, op, s, a, off=0):
        f3 = {'sb':0,'sh':1,'sw':2}[op]
        self.emit(f'{op} x{s},{off}(x{a})', (((off>>5)&127)<<25)|(s<<20)|(a<<15)|(f3<<12)|((off&31)<<7)|0x23)

    def branch(self, op, a, b, label):
        pc = len(self.code)*4
        f3 = {'beq':0,'bne':1,'blt':4,'bge':5,'bltu':6,'bgeu':7}[op]
        def encode():
            off = self.labels[label]-pc
            return (((off>>12)&1)<<31)|(((off>>5)&63)<<25)|(b<<20)|(a<<15)|(f3<<12)|(((off>>1)&15)<<8)|(((off>>11)&1)<<7)|0x63
        self.emit(f'{op} x{a},x{b},{label}', encode)

    def jal(self, d, label):
        pc = len(self.code)*4
        def encode():
            off = self.labels[label]-pc
            return (((off>>20)&1)<<31)|(((off>>1)&1023)<<21)|(((off>>11)&1)<<20)|(((off>>12)&255)<<12)|(d<<7)|0x6f
        self.emit(f'jal x{d},{label}', encode)

    def addr(self, d, label):
        self.emit(f'addi x{d},x0,{label}+1', lambda: ((self.labels[label]+1)<<20)|(d<<7)|0x13)

    def check(self, d, value):
        self.gap(); self.li(28,value); self.gap(); self.branch('bne',d,28,'fail')

    def finish(self):
        self.addi(27,0,1); self.addi(26,0,1); self.label('done'); self.jal(0,'done')
        self.label('fail'); self.addi(27,0,0); self.addi(26,0,1); self.label('failed'); self.jal(0,'failed')
        words = [(value() if callable(value) else value) & 0xffffffff for _,value in self.code]
        assert len(words) <= 256, len(words)
        listing = ['# RV32I listing; use the paired .data image.']
        for i,(text,_) in enumerate(self.code):
            listing.extend(n+':' for n,a in self.labels.items() if a==i*4)
            listing.append(f'    {text} # {i*4:04x}: {words[i]:08x}')
        return '\n'.join(f'{w:08x}' for w in words), '\n'.join(listing)


files = {}
manifests = {}
def save(folder,name,p,**meta):
    data, listing = p.finish()
    for ext,body in [('data',data),('S',listing)]:
        files[f'test_instruction/{folder}/inst_{name}.{ext}'] = body
    manifests.setdefault(folder,[]).append(dict(name=name,**meta))


folder = 'Memory_Example'
p=Program(1)
for value in (0x807fff00,0xff00807f):
    p.li(2,value); p.store('sw',2,10)
    for off in range(4):
        byte=(value>>(off*8))&255
        p.load('lb',5,10,off); p.check(5,byte if byte<128 else byte-256)
        p.load('lbu',5,10,off); p.check(5,byte)
save(folder,'load_bytes',p)
p=Program(2)
for value in (0x80007fff,0xffff0000):
    p.li(2,value); p.store('sw',2,10)
    for off in (0,2):
        half=(value>>(off*8))&65535
        p.load('lh',5,10,off); p.check(5,half if half<32768 else half-65536)
        p.load('lhu',5,10,off); p.check(5,half)
save(folder,'load_halves',p)
p=Program(3)
for i,value in enumerate((0,0xffffffff,0x80000000,0x7fffffff)):
    p.li(2,value); p.store('sw',2,10,i*4); p.load('lw',5,10,i*4); p.check(5,value)
p.addi(11,10,16);p.load('lw',5,11,-4);p.check(5,0x7fffffff)
save(folder,'words',p)
p=Program(4)
for off in range(4):
    p.li(2,0xa1b2c3d4);p.store('sw',2,10)
    p.li(4,0x12345680);p.store('sb',4,10,off)
    p.load('lw',5,10);p.check(5,(0xa1b2c3d4 & ~(255<<(off*8))) | (0x80<<(off*8)))
save(folder,'store_bytes',p)
p=Program(5)
for off in (0,2):
    p.li(2,0xa1b2c3d4);p.store('sw',2,10)
    p.li(4,0xdead89ab);p.store('sh',4,10,off)
    p.load('lw',5,10);p.check(5,(0xa1b2c3d4 & ~(65535<<(off*8))) | (0x89ab<<(off*8)))
save(folder,'store_halves',p)
p=Program(6)
p.li(2,0x11223344);p.store('sw',2,10);p.store('sw',2,10,4)
p.li(2,0xaa);p.li(4,0xbb);p.li(5,0x8001);p.gap()
p.store('sb',2,10,0);p.store('sb',4,10,1);p.store('sh',5,10,2)
p.load('lw',6,10);p.check(6,0x8001bbaa)
p.load('lw',6,10,4);p.check(6,0x11223344)
save(folder,'store_mixed',p)
p=Program(7)
p.li(11,0x10003ffc);p.li(2,0x12345678);p.store('sw',2,11)
p.li(2,0xff);p.store('sb',2,11,3);p.load('lw',5,11);p.check(5,0xff345678)
p.li(2,0x8000);p.store('sh',2,11,2);p.load('lh',5,11,2);p.check(5,0xffff8000)
p.load('lw',5,0);p.check(5,0x00000d13)
p.load('lbu',5,0);p.check(5,0x13)
save(folder,'bounds_rom',p)

folder='X0_Example'
p=Program(1)
p.addi(0,0,123);p.reg('add',5,0,0);p.check(5,0)
p.li(2,0xffffffff)
for op in ('add','sub','sll','slt','sltu','xor','srl','sra','or','and'):
    p.reg(op,0,2,2);p.reg('add',5,0,0);p.check(5,0)
p.check(0,0)
save(folder,'alu_discard',p,loads=0)
p=Program(2)
p.li(2,0x80ff8001);p.store('sw',2,10)
for op in ('lb','lbu','lh','lhu','lw'):
    p.load(op,0,10);p.reg('add',5,0,0);p.check(5,0)
save(folder,'load_discard',p,loads=5)
p=Program(3)
p.jal(0,'first');p.addi(5,0,99);p.label('first')
p.addr(7,'second');p.i(0x67,0,0,7,0,'jalr x0,0(x7)');p.addi(0,0,111)
p.label('second');p.check(0,0)
save(folder,'jump_discard',p,loads=0)
p=Program(4)
p.li(2,0xfeedbeef);p.store('sw',2,10);p.addi(0,0,123);p.store('sw',0,10)
p.load('lw',5,10);p.check(5,0);p.branch('bne',0,0,'fail')
p.load('lw',5,0);p.check(5,0xd13);p.check(0,0)
save(folder,'read_store_branch',p,loads=0)

folder='Reference_Example'
p=Program(1)
p.li(1,0x80000000);p.li(2,0x7fffffff);p.li(4,0xffffffff);p.li(7,31)
for op,a,b,want in [('slt',1,2,1),('sltu',1,2,0),('sra',1,7,0xffffffff),
                    ('srl',1,7,1),('add',2,4,0x7ffffffe),('sub',1,4,0x80000001)]:
    p.reg(op,5,a,b);p.check(5,want)
p.branch('bge',1,2,'fail');p.branch('bltu',1,2,'fail')
save(folder,'alu_edges',p)
for seed in (1,7,42,2026):
    rng=random.Random(seed);p=Program(seed)
    regs=list(range(1,10))+list(range(11,18))
    for d in regs:p.li(d,rng.getrandbits(32))
    for i in range(80):
        kind=rng.randrange(7);d,a,b=(rng.choice(regs) for _ in range(3))
        if kind==0:p.reg(rng.choice(('add','sub','sll','slt','sltu','xor','srl','sra','or','and')),d,a,b)
        elif kind==1:p.addi(d,a,rng.randrange(-2048,2048))
        elif kind==2:
            op=rng.choice(('lb','lbu','lh','lhu','lw'));size={'lb':1,'lbu':1,'lh':2,'lhu':2,'lw':4}[op]
            p.load(op,d,10,(rng.randrange(64)//size)*size)
        elif kind==3:
            op=rng.choice(('sb','sh','sw'));size={'sb':1,'sh':2,'sw':4}[op]
            p.store(op,a,10,(rng.randrange(64)//size)*size)
        elif kind==4:
            p.branch(rng.choice(('beq','bne','blt','bge','bltu','bgeu')),a,b,f'skip{i}')
            p.addi(d,d,1);p.label(f'skip{i}')
        elif kind==5:
            p.jal(d,f'skip{i}');p.addi(d,0,999);p.label(f'skip{i}')
        else:
            p.addr(a,f'skip{i}');p.i(0x67,d,0,a,0,f'jalr x{d},0(x{a})')
            p.addi(d,0,999);p.label(f'skip{i}')
    save(folder,f'mixed_seed_{seed}',p,seed=seed)

for folder,rows in manifests.items():
    files[f'test_instruction/{folder}/tests.json']=json.dumps(rows,indent=2)
print('*** Begin Patch')
for path,content in files.items():
    print(f'*** Add File: {ROOT}/{path}')
    print('\n'.join('+'+line for line in content.splitlines()))
print('*** End Patch')
