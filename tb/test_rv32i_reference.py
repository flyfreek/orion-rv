"""Hand-encoded oracle tests and deliberate comparator mismatch tests."""
import unittest
from rv32i_reference import Model, compare, RAM, RAM_SIZE

FINISH = [0x00100d93, 0x00100d13, 0x0000006f]


def trace_of(model):
    lines = [f'{kind} {a:x} {b:x}' for kind,events in model.events.items() for a,b in events]
    lines += [f'F {i:x} {v:x}' for i,v in enumerate(model.regs)]
    lines += [f'D {i:x} {model.read(RAM+4*i,4):x}' for i in range(RAM_SIZE//4)]
    return '\n'.join(lines+['END'])


class ReferenceTests(unittest.TestCase):
    def test_signed_loads(self):
        m=Model([0x100000b7,0xf8000113,0x0020a023,0x00008283,0x0000c303,
                 0x00009383,0x0000d403]+FINISH).run()
        self.assertEqual(m.regs[5:9], [0xffffff80,0x80,0xffffff80,0xff80])

    def test_partial_store_preservation(self):
        m=Model([0x100000b7,0xfff00113,0x0020a023,0x01200113,
                 0x002080a3,0x00209123]+FINISH).run()
        self.assertEqual([v for _,v in m.events['S']], [0xffffffff,0xffff12ff,0x001212ff])

    def test_jalr_same_source_destination_and_low_bit(self):
        m=Model([0x00d00093,0x000080e7,0x06300113,0x00008113]+FINISH).run()
        self.assertEqual(m.regs[1:3], [8,8])

    def test_load_to_x0_still_reads(self):
        m=Model([0x100000b7,0x07b00013,0x0000a003]+FINISH).run()
        self.assertEqual(m.regs[0],0)
        self.assertEqual(m.events['R'],[(RAM,0)])

    def test_unknown_and_alignment_rejected(self):
        with self.assertRaises(ValueError): Model([0]).run()
        with self.assertRaises(ValueError): Model([0x100000b7,0x0010a283]+FINISH).run()
        with self.assertRaises(ValueError): Model([0x6f]).run(limit=3)

    def test_trace_and_injected_mismatches(self):
        m=Model([0x02900293]+FINISH).run()
        good=trace_of(m)
        self.assertEqual(compare(m,good)['final_registers_checked'],32)
        for bad in (good.replace('W 5 29','W 5 28'),good.replace('END',''),
                    good.replace('F 0 0','F 0 1'),good.replace('D 0 0','D 0 1'),
                    'S 10000000 1\n'+good):
            with self.assertRaises(ValueError): compare(m,bad)


if __name__ == '__main__': unittest.main()
