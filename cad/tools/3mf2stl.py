import sys, zipfile, re, struct, os
src, out = sys.argv[1], sys.argv[2]
z = zipfile.ZipFile(src)
names = {}
cfg = z.read('Metadata/model_settings.config').decode()
for m in re.finditer(r'<object id="(\d+)">(.*?)</object>', cfg, re.S):
    n = re.search(r'key="name" value="([^"]*)"', m.group(2))
    names[m.group(1)] = n.group(1) if n else m.group(1)
main = z.read('3D/3dmodel.model').decode()
for f in z.namelist():
    if not f.startswith('3D/Objects/'): continue
    x = z.read(f).decode()
    for om in re.finditer(r'<object id="(\d+)"[^>]*>(.*?)</object>', x, re.S):
        body = om.group(2)
        vs = [tuple(map(float, v)) for v in re.findall(r'<vertex x="([^"]+)" y="([^"]+)" z="([^"]+)"', body)]
        ts = [tuple(map(int, t)) for t in re.findall(r'<triangle v1="(\d+)" v2="(\d+)" v3="(\d+)"', body)]
        if not ts: continue
        # find owning top-level object name via component reference
        oid = None
        for cm in re.finditer(r'<object id="(\d+)"[^>]*>(.*?)</object>', main, re.S):
            if f'p:path="/{f}" objectid="{om.group(1)}"' in cm.group(2) or (f'/{f}' in cm.group(2) and f'objectid="{om.group(1)}"' in cm.group(2)):
                oid = cm.group(1)
        nm = names.get(oid, os.path.basename(f)).replace(' ', '_').replace('.stl','')
        xs=[v[0] for v in vs]; ys=[v[1] for v in vs]; zs=[v[2] for v in vs]
        print(f"{nm}: tris={len(ts)} bbox x[{min(xs):.1f},{max(xs):.1f}] y[{min(ys):.1f},{max(ys):.1f}] z[{min(zs):.1f},{max(zs):.1f}] size {max(xs)-min(xs):.1f} x {max(ys)-min(ys):.1f} x {max(zs)-min(zs):.1f}")
        with open(os.path.join(out, nm + '.stl'), 'wb') as o:
            o.write(b'\0'*80 + struct.pack('<I', len(ts)))
            for a,b,c in ts:
                o.write(struct.pack('<12fH', 0,0,0, *vs[a], *vs[b], *vs[c], 0))
