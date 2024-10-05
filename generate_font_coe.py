with open('term.psf.txt', 'r') as f:
    lines = f.read()

width = 10
height = 20

import re

pat = r'// Character (\d+)\s+Bitmap:([ \-\\#\n]+)'

chars = [None for _ in  range(256)]


matches = re.findall(pat, lines)
print(len(matches))
for match in matches:
    n = int(match[0])
    lines = match[1].splitlines()
    # print(len(lines))
    cline = []
    line: str
    for line in lines:
        line = line.strip(' \n\\\t')
        val = 0
        for i in range(width):
            val |= {'#':1,'-':0}[line[i]] << i
        cline.append(val)
    chars[n] = cline




fdata = '''memory_initialization_radix=2;
memory_initialization_vector=
'''

fname = 'bd_top_blk_mem_gen_1_0.coe'

for char in chars:
    for line in char + [0] * 12:
        fdata += f'{line:010b},\n'
    fdata += '\n'

fdata = fdata[::-1].replace(',', ';', 1)[::-1]

open(fname, 'w').write(fdata)
    