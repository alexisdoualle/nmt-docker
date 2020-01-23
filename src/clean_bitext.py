import re
import sys
import linecache
​
def clean(source, target, cleanSource, cleanTarget):
    with open(source, 'r') as sr, open(target, 'r') as tg, open(cleanSource, 'w') as cleanSource, open(cleanTarget, 'w') as cleanTarget:
        i = 0
        keywords = ['President', 'agriculture']
        reg = ".*?" + ".*|.*?".join(keywords) + ".*"
        for lineS, lineT in zip(sr, tg):
            if i%100 == 0:
                print(str(i), end='\r')
            if re.match('.*?Statistics Finland.*', lineS):
                i += 1
                # print(lineS, lineT)
            else:
                cleanSource.write(lineS)
                cleanTarget.write(lineT)
        print(i)
​
def find(source):
    with open(source, 'r') as sr:
        i = 0
        keywords = ['President', 'agriculture', 'education', 'immigrant', 'Jesus', 'parliament', 'christ', 'gospel', 'bible', 'philistines', 'islam',
        'corinthians', 'Unesco', 'galatians']
        reg = ".*?" + ".*|.*?".join(keywords) + ".*"
        for line in sr:
            if i%100 == 0:
                print(str(i), end='\r')
            if re.match(reg, line, re.IGNORECASE):
                # print(line)
                i += 1
        print(i)
​
if __name__ == '__main__':
    # clean(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
    find(sys.argv[1])