import json, re, base64, os

src = r'C:\Users\sudha\Downloads\TrachCare-UI-design.html'
out = r'C:\Users\sudha\trachcare\design_refs'
t = open(src, encoding='utf-8').read()
m = re.search(r'const S = (\[.*?\]);', t, re.S)
S = json.loads(m.group(1))
os.makedirs(out, exist_ok=True)
for s in S:
    path = os.path.join(out, s['slug'] + '.svg')
    with open(path, 'wb') as f:
        f.write(base64.b64decode(s['b64']))
print(len(S))
for s in S:
    print(s['slug'], '|', s['title'], '|', s['grp'])
