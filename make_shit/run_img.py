import requests
import sys
import os

def execute_ebaz_runner(img_path: str):
    img_bytes = []
    with open(img_path, 'r') as f:
        for line in list(f)[1:]:
            if (comment_start := line.find('#')) != -1:
                    line = line[:comment_start]
            for entry in line.strip().split():
                if '*' in entry:
                    amt, val = entry.split('*')
                else:
                    amt, val = '1', entry
                amt = int(amt)
                val = int(val, 16)
                img_bytes += bytes([val]*amt)
    resp = requests.post('http://ebaz.local/run', json={'image': img_bytes})
    resp.raise_for_status()
    j = resp.json()
    print(j['registers'])
    print((j['memory'][0xB000:0xB010]))

if __name__ == '__main__':
     execute_ebaz_runner(sys.argv[1])