# -*- coding: utf-8 -*-

import pandas as pd
from glob import glob as gb 
import matplotlib.pyplot as plt
import seaborn as sns

# Read in conversion file
scans2rils = pd.read_excel('/home/nathan/Documents/GenSoc/Data/scaninfo.xlsx', index_col='Measurement number')
scans2rils.index = scans2rils.index -7

# Read in fles
files = { (f.rsplit('/',1)[-1]).rsplit('.',2)[0][4:] :
    pd.read_csv(f) for f in gb('/home/nathan/Documents/GenSoc/Data/phendata/*/*ISQ.csv') } 

plants = {}

for f in files: 
    if int(f) in scans2rils.index:
        plants[scans2rils.loc[int(f)]['Plant number'].replace(' ', '-')] = files[f]


for p, v in plants.items():
    v['Plant ID'] = p
    
    if 'ABR6' in p:
        v['type'] = 'ABR6'
    elif 'Bd21' in p:
        v['type'] = 'Bd21'
    else: 
        v['type'] = 'F8'

plants = pd.concat(plants.values())
plants = plants[plants['volume'] > 1]

plants = plants[plants['volume'] > plants['volume'].quantile(0.05)]
plants = plants[plants['width'] < plants['width'].quantile(0.95)]

plants = plants.sort_values(by=['type','Plant ID'])


sns.boxplot(data=plants, y='Plant ID', x='volume', hue='type')
plt.figure()
sns.boxplot(data=plants, y='Plant ID', x='width', hue='type')
plt.figure()
sns.boxplot(data=plants, y='Plant ID', x='length', hue='type')
plt.figure()
sns.boxplot(data=plants, y='Plant ID', x='surface_area', hue='type')