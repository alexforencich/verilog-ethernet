"""

Copyright (c) 2020 Matthias Seidel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"""

from multiprocessing import Pool
import subprocess
import glob
import tqdm
import os.path

class colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def run_test_sub(test_path):
    args = ["python3", test_path]
    res = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    with open(test_path.rsplit(".",1)[0]+".log", "wb") as log:
        log.write(res.stdout)
    
    return "{} -> {}{}{}".format(test_path, colors.GREEN if not res.returncode else colors.RED, "SUCCESS" if not res.returncode else "FAILED", colors.ENDC)


if __name__ == '__main__':
    test_list = glob.glob("./test_*.py")
    with Pool(4) as pool:
        bar = tqdm.tqdm(pool.imap_unordered(run_test_sub,test_list), total=len(test_list))
        for res in bar:
            bar.write(res)
