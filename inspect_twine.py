from pathlib import Path
text = Path('Self Care Adventure.html').read_text(encoding='utf-8')
lines = text.splitlines()
for i in (119, 120, 145, 146):
    if i < len(lines):
        print('LINE', i, ':', repr(lines[i]))

