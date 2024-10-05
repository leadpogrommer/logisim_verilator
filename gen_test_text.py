fdata = '''memory_initialization_radix=16;
memory_initialization_vector=
'''
fname = 'test_message.coe'

STYLE_RED_FG = 1 << 0
STYLE_BLU_FG = 1 << 1
STYLE_GRN_FG = 1 << 2
STYLE_RED_BG = 1 << 3
STYLE_BLU_BG = 1 << 4
STYLE_GRN_BG = 1 << 5
STYLE_DIM    = 1 << 6
STYLE_BLINK  = 1 << 7


colors = [
    '---',
    '--R',
    '-B-',
    '-BR',
    'G--',
    'G-R',
    'GB-',
    'GBR'
]

flags = [
    'normal',
    'dim',
    'blinking',
]

cbuf = []
current_style = 0

def print_str(s):
    global cbuf
    print(s,end='')
    for c in s:
        if c == '\n':
            to_pad = 80 - len(cbuf)%80
            cbuf += [(current_style << 8) | ord(' ')] * to_pad
            continue
        cbuf.append((ord(c) & 0xff) | (current_style << 8))



print_str('Hello, world\n')

for fb, flag in enumerate(flags):
    current_style = 0
    print_str(f'Style: {flag}\n')
    for fgb, fgname in enumerate(colors):
        for bgb, bgname in enumerate(colors):
            if fgb == bgb:
                continue
            current_style = (fb << 6) | (bgb << 3) | (fgb ^ 0b111)
            print_str(f'{fgname} on {bgname}')
            current_style = fb << 6
            print_str(',')
        cbuf = cbuf[:-1]
        print_str('\n')

print()
print(len(cbuf), 80*30)
with open(fname, 'w') as f:
    f.write(fdata + ', '.join(map(lambda a: hex(a)[2:], cbuf[:80*30])))