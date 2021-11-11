import os
from PIL import Image
import numpy as np

dir = './images'
out = 'mem.txt'

def convert():
    files = os.listdir(dir)
    files.sort(key = lambda a: int(a.split('.')[0]))
    mem = open(out, 'w')
    for f in files:
        print(f)
        img1 = Image.open(os.path.join(dir, f))
        img = img1.convert('L')
        arr = np.asarray(img)
        col = 0
        h, w = arr.shape
        while col < w:
            for row in range(h):
                d = 0
                for c in range(8):
                    d <<= 1
                    px = arr[row][col + c]
                    if px: d |= 1
                mem.write('%02x '%d)
            col += 8
            mem.write('\n')
        img.close()
        img1.close()
    mem.close()

if __name__ == '__main__':
    convert()