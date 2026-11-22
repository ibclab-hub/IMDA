# !/usr/bin/env python3.4
# argv[1,2,3,4]: newick tree, spc1, spc2
# target spc name: scientific name (with '_')
# output: just distance

import sys
sys.path.append('/mss/www/html/RACA-w/program/ete3')
sys.path.append('/mss/www/html/RACA-w/program')
import six
from ete3 import Tree



tree_file = sys.argv[1]
spc1 = sys.argv[2]
spc2 = sys.argv[3]


#save tree spc list
t = Tree(open(tree_file).read().rstrip(),quoted_node_names=True,format=1)
tree_list = []

for i in t.traverse('preorder'):
    if i.is_leaf():
        tree_list.append(i.name.lower())
if (spc1 in tree_list) and (spc2 in tree_list):
	print(round(t.get_distance(spc1,spc2),5))



