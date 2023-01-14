#!/usr/bin/python
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
# Transform a unified diff from stdin to a colored
# side-by-side HTML page on stdout.
#
# Author: Olivier MATZ <zer0@droids-corp.org>
#
# Inspired by diff2html.rb from Dave Burt <dave (at) burt.id.au>
# (mainly for html theme)


import sys, re, htmlentitydefs

html_hdr="""<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
            <html><head>
		<meta name="generator" content="diff2html.rb" />
		<title>HTML Diff</title>
		<style>
			table { border:0px; border-collapse:collapse; width: 100%; font-size:0.75em; font-family: Lucida Console, monospace }
			td.line { color:#8080a0 }
			th { background: black; color: white }
			tr.unmodified td { background: #D0D0E0 }
			tr.hunk td { background: #A0A0A0 }
			tr.added td { background: #CCFFCC }
			tr.deleted td { background: #FFCCCC }
			tr.changed td { background: #FFFFA0 }
			span.changed2 { background: #E0C880 }
			span.ponct { color: #B08080 }
			tr.misc td {}
			tr.separator td {}
		</style>
		</head>
		<body>
		<table>
"""

html_footer="""
</table></body></html>
"""

DIFFON="\x01"
DIFFOFF="\x02"

buffer=[]
add_cpt, del_cpt = 0,0
line1, line2 = 0,0
hunk_off1, hunk_size1, hunk_off2, hunk_size2 = 0,0,0,0

# minimum line size, we add a zero-sized breakable space every
# LINESIZE characters
LINESIZE=20
TAB=8

def sane(x):
    r=""
    for i in x:
        j = ord(i)
        if i not in ['\t', '\n'] and ((j < 32) or (j >= 127)):
            r=r+"."
        else:
            r=r+i
    return r

def linediff(s, t):
    if len(s):
        s=str(reduce(lambda x,y:x+y, [ sane(c) for c in s ]))
    if len(t):
        t=str(reduce(lambda x,y:x+y, [ sane(c) for c in t ]))
    
    m,n = len(s), len(t)
    d=[[(0,0) for i in range(n+1)] for i in range(m+1)]
    x=[[(0,0) for i in range(n+1)] for i in range(m+1)]

    
    d[0][0] = (0, (0,0))
    for i in range(m+1)[1:]:
        d[i][0] = (i,(i-1,0))
    for j in range(n+1)[1:]:
        d[0][j] = (j,(0,j-1))

    for i in range(m+1)[1:]:
        for j in range(n+1)[1:]:
            if s[i-1] == t[j-1]:
                cost = 0
            else:
                cost = 1
            d[i][j] = min((d[i-1][j][0] + 1, (i-1,j)),
                          (d[i][j-1][0] + 1, (i,j-1)),
                          (d[i-1][j-1][0] + cost, (i-1,j-1)))
            
    l=[]
    coord = (m,n)
    while coord != (0,0):
        l.insert(0, coord)
        x,y = coord
        coord = d[x][y][1]

    l1 = []
    l2 = []

    for coord in l:
        cx,cy = coord
        child_val = d[cx][cy][0]
        
        father_coord = d[cx][cy][1]
        fx,fy = father_coord
        father_val = d[fx][fy][0]

        diff = (cx-fx, cy-fy)

        if diff == (0,1):
            l1.append("")
            l2.append(DIFFON + t[fy] + DIFFOFF)
        elif diff == (1,0):
            l1.append(DIFFON + s[fx] + DIFFOFF)
            l2.append("")
        elif child_val-father_val == 1:
            l1.append(DIFFON + s[fx] + DIFFOFF)
            l2.append(DIFFON + t[fy] + DIFFOFF)
        else:
            l1.append(s[fx])
            l2.append(t[fy])

    r1,r2 = (reduce(lambda x,y:x+y, l1), reduce(lambda x,y:x+y, l2))
    return r1,r2


def convert(s, linesize=0, ponct=0):
    i=0
    t=""
    l=[]
    for c in s:
        # used by diffs
        if c==DIFFON:
            t += '<spanclass="changed2">'
        elif c==DIFFOFF:
            t += "</span>"

        # special html chars
        elif htmlentitydefs.codepoint2name.has_key(ord(c)):
            t += "&%s;"%(htmlentitydefs.codepoint2name[ord(c)])
            i += 1

        # special highlighted chars
        elif c=="\t" and ponct==1:
            n = TAB-(i%TAB)
            if n==0:
                n=TAB
            t += ('<spanclass="ponct">&raquo;</span>'+'&nbsp;'*(n-1))
            i += n
        elif c=="\n" and ponct==1:
            t += '<spanclass="ponct">\</span>'
        else:
            t += c
            i += 1
        if linesize and i>linesize:
            i=0
            t += "&#8203;"

    if ponct==1:
        t = t.replace(' ', '<spanclass="ponct">&middot;</span>')
    t = t.replace("spanclass", "span class")
        
    return t


def add_comment(s):
    sys.stdout.write('<tr class="misc"><td colspan="4">%s</td></tr>\n'%convert(s))

def add_filename(f1, f2):
    sys.stdout.write("<tr><th colspan='2'>%s</th>"%convert(f1, linesize=LINESIZE))
    sys.stdout.write("<th colspan='2'>%s</th></tr>\n"%convert(f2, linesize=LINESIZE))

def add_hunk():
    global hunk_off1
    global hunk_size1
    global hunk_off2
    global hunk_size2
    sys.stdout.write('<tr class="hunk"><td colspan="2">Offset %d, %d lines modified</td>'%(hunk_off1, hunk_size1))
    sys.stdout.write('<td colspan="2">Offset %d, %d lines modified</td></tr>\n'%(hunk_off2, hunk_size2))

def add_line(s1, s2):
    global line1
    global line2

    if s1==None and s2==None:
        type="unmodified"
    elif s1==None:
        type="added"
    elif s2==None:
        type="deleted"
    elif s1==s2:
        type="unmodified"
    else:
        type="changed"
        s1,s2 = linediff(s1, s2)

    sys.stdout.write('<tr class="%s">'%type)
    if s1!=None and s1!="":
        sys.stdout.write('<td class="line">%d </td>'%line1)
        sys.stdout.write('<td>')
        sys.stdout.write(convert(s1, linesize=LINESIZE, ponct=1))
        sys.stdout.write('</td>')
    else:
        s1=""
        sys.stdout.write('<td colspan="2"> </td>')
    
    if s2!=None and s2!="":
        sys.stdout.write('<td class="line">%d </td>'%line2)
        sys.stdout.write('<td>')
        sys.stdout.write(convert(s2, linesize=LINESIZE, ponct=1))
        sys.stdout.write('</td>')
    else:
        s2=""
        sys.stdout.write('<td colspan="2"></td>')

    sys.stdout.write('</tr>\n')

    if s1!="":
        line1 += 1
    if s2!="":
        line2 += 1


def empty_buffer():
    global buffer
    global add_cpt
    global del_cpt

    if del_cpt == 0 or add_cpt == 0:
        for l in buffer:
            add_line(l[0], l[1])

    elif del_cpt != 0 and add_cpt != 0:
        l0, l1 = [], []
        for l in buffer:
            if l[0] != None:
                l0.append(l[0])
            if l[1] != None:
                l1.append(l[1])
        max = (len(l0) > len(l1)) and len(l0) or len(l1)
        for i in range(max):
            s0, s1 = "", ""
            if i<len(l0):
                s0 = l0[i]
            if i<len(l1):
                s1 = l1[i]
            add_line(s0, s1)
        
    add_cpt, del_cpt = 0,0
    buffer = []



sys.stdout.write(html_hdr)

while True:
    l=sys.stdin.readline()
    if l=="":
        break
    
    m=re.match('^--- ([^\s]*)', l)
    if m:
        empty_buffer()
        file1=m.groups()[0]
        l=sys.stdin.readline()
        m=re.match('^\+\+\+ ([^\s]*)', l)
        if m:
            file2=m.groups()[0]
        add_filename(file1, file2)
        hunk_off1, hunk_size1, hunk_off2, hunk_size2 = 0,0,0,0
        continue

    m=re.match("@@ -(\d+),?(\d*) \+(\d+),?(\d*)", l)
    if m:
        empty_buffer()
        hunk_data = map(lambda x:x=="" and 1 or int(x), m.groups())
        hunk_off1, hunk_size1, hunk_off2, hunk_size2 = hunk_data
        line1, line2 = hunk_off1, hunk_off2
        add_hunk()
        continue
        
    if hunk_size1 == 0 and hunk_size2 == 0:
        empty_buffer()
        add_comment(l)
        continue

    if re.match("^\+", l):
        add_cpt += 1
        hunk_size2 -= 1
        buffer.append((None, l[1:]))
        continue

    if re.match("^\-", l):
        del_cpt += 1
        hunk_size1 -= 1
        buffer.append((l[1:], None))
        continue

    if re.match("^\ ", l) and hunk_size1 and hunk_size2:
        empty_buffer()
        hunk_size1 -= 1
        hunk_size2 -= 1
        buffer.append((l[1:], l[1:]))
        continue

    empty_buffer()
    add_comment(l)


empty_buffer()
sys.stdout.write(html_footer)
