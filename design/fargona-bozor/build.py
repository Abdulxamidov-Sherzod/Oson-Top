import re
def inner(p): return re.search(r'<x-dc>(.*?)</x-dc>',open(p,encoding='utf-8').read(),re.S).group(1)
card=inner('ListingCard.dc.html'); tab=inner('TabBar.dc.html'); main=inner('Oson Top.dc.html')
def sc_if(t,tr):
    out=[];i=0
    while True:
        m=re.search(r'<sc-if value="\{\{\s*(\w+)\s*\}\}"[^>]*>',t[i:])
        if not m: out.append(t[i:]);break
        s=i+m.start();n=m.group(1);bs=i+m.end();e=t.find('</sc-if>',bs)
        out.append(t[i:s])
        if tr.get(n): out.append(t[bs:e])
        i=e+len('</sc-if>')
    return ''.join(out)
def rc(a):
    f=a.get('fav','').strip()=='{{ true }}'
    t=sc_if(card,{'fav':f,'notFav':not f})
    for k in ['title','price','place','time','ph']: t=t.replace('{{ %s }}'%k,a.get(k,''))
    return t
def rt(a):
    act=a.get('active','home'); t=tab
    for k,v in {'cHome':act=='home','cPost':act=='post','cProfile':act=='profile'}.items():
        t=t.replace('{{ %s }}'%k,'#16A45C' if v else '#9AA6A0')
    return t
def ex(m):
    a=dict(re.findall(r'(\w[\w-]*)="([^"]*)"',m.group(0)))
    w=a.get('hint-size','100%,100px').split(',')[0]
    return '<div style="width:%s;">%s</div>'%(w, rc(a) if a.get('name')=='ListingCard' else rt(a))
main=re.sub(r'<dc-import[^>]*>(\s*</dc-import>)?',ex,main)
main=sc_if(main,{'showEmptyStates':True,'hasNotif':True}).replace('{{ notifBadge }}','2')
main=re.sub(r'<helmet>(.*?)</helmet>',lambda m:m.group(1),main,flags=re.S).replace('<meta name="design_doc_mode" content="canvas">','')
assert '{{' not in main and 'dc-import' not in main and 'sc-if' not in main
open('preview.html','w',encoding='utf-8').write('<!doctype html><html><head><meta charset="utf-8"><title>Oson Top</title></head><body>'+main+'</body></html>')
open('/Users/sherzodbekkofficalgmail.com/Documents/Oson Top/design/oson-top-dizayn.html','w',encoding='utf-8').write('<title>Oson Top</title>\n'+main)
print('qayta yigildi — ekranlar:', main.count('data-screen-label'))
