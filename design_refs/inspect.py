import re, sys

path = sys.argv[1]
t = open(path, encoding='utf-8').read()

# gradients
for gid, body in re.findall(r'<linearGradient id="([^"]+)"[^>]*>(.*?)</linearGradient>', t, re.S):
    stops = re.findall(r'offset="([^"]+)" stop-color="([^"]+)"', body)
    print('GRAD', gid, ' '.join(f'{o}:{c}' for o, c in stops))

# group structure
for m in re.finditer(r'<g id="([^"]+)"', t):
    print('GROUP', m.group(1))

# texts with position+size
for m in re.finditer(
        r'<text[^>]*x="([\d.]+)" y="([\d.]+)"[^>]*font-size="([\d.]+)"[^>]*font-weight="([^"]+)"[^>]*fill="([^"]+)"[^>]*>([^<]*)</text>',
        t):
    x, y, sz, w, fill, txt = m.groups()
    print(f'TEXT  y={y:>7} x={x:>7} sz={sz:>5} w={w} fill={fill}  {txt[:60]}')

# key rects (backgrounds, cards, buttons) - rounded ones
for m in re.finditer(
        r'<rect[^>]*id="([^"]+)"[^>]*x="([\d.-]+)"[^>]*y="([\d.-]+)"[^>]*width="([\d.]+)"[^>]*height="([\d.]+)"[^>]*rx="([\d.]+)"[^>]*fill="([^"]+)"',
        t):
    rid, x, y, w, h, rx, fill = m.groups()
    print(f'RECT  {rid:<34} y={y:>7} x={x:>7} {w}x{h} r={rx} fill={fill}')
