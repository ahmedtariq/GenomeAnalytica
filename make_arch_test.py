#!/usr/bin/env python
# coding: utf-8

# In[22]:


import numpy as np
import pandas as pd
from scipy.stats import mannwhitneyu, ttest_ind
from statsmodels.stats.multitest import multipletests

import sys
import argparse
import random
import os
from functools import reduce

pd.set_option('display.max_columns',None)
pd.set_option('display.max_colwidth', None)

random.seed = 0
np.random.seed = 0


# In[24]:


parser=argparse.ArgumentParser()

parser.add_argument('--stats', nargs='?',type=str, default='./data/output', help='Directory containning the nested csv stats for all species in form of (species,stats)')
parser.add_argument('--tax', nargs='?',type=str, default='./data/tax_mapping.csv', help='File csv contianing the full lineage of all species in stats')
parser.add_argument('--out_test', nargs='?',type=str, default='test_result.csv', help='File to write the test results')
parser.add_argument('--out_parsed', nargs='?',type=str, default='parsed_all.csv', help='File to write the test results')
parser.add_argument('--out_parsed_filtered', nargs='?',type=str, default='parsed_filtered.csv', help='File to write the test results')
parser.add_argument('--tax_rank', nargs='?',type=int, default=10, help='the rank of lineage to be used e.g: 10 to use the supphylum')
parser.add_argument('--rank_value', nargs='?',type=str, default="Vertebrata", help='value to test for in the tax rank e.g: Vertebrata to test Vert vs In-Vert in Subphylum')


# In[25]:


args=parser.parse_args()


# In[ ]:


data_dir = args.stats
tax_file = args.tax
out_file = args.out_test
out_parsed = args.out_parsed
out_filtered = args.out_parsed_filtered
taxa_rank = args.tax_rank
rank_value = args.rank_value



# In[3]:


def parse_df_from_tree_on(data_dir,on,use_dir_as_on= True):
    dict_df_sp = {}
    for sp in os.listdir(data_dir):
        sp_path = os.path.join(data_dir, sp)
        dict_df_sp[sp] = reduce(
            lambda df1, df2: pd.merge(df1, df2, on=on),
            [pd.read_csv(os.path.join(sp_path, st)) for st in os.listdir(sp_path)])
    df = reduce(
        lambda df1, df2: pd.merge(
            df1, df2, how='outer', left_index=True, right_index=True),
        [df.T for df in dict_df_sp.values()]).T.reset_index(drop=True).fillna(0)
    if use_dir_as_on:
        df[on] = dict_df_sp.keys()
    return df


# In[4]:


df = parse_df_from_tree_on(data_dir=data_dir,on="species",use_dir_as_on= True)

df.to_csv(out_parsed)
# In[7]:


df_map = pd.read_csv(tax_file,header=None,usecols=[i for i in range(0,11,1)])


# In[9]:


df_map = df_map.loc[:,[0,taxa_rank]]


# In[10]:


df = df.merge(df_map,left_on="species",right_on=0,how='left').drop(0,axis=1)


# In[13]:


df['Flag'] = (df.loc[:,taxa_rank].str.lower() == rank_value.lower())


# In[14]:


test_dict = {'feature' : [],'0_count' : [],'MannWhitney_p' : [], 'ttest_p' : []}
for fet in df.select_dtypes(['float','int']):
    test_dict['feature'].append(fet)
    test_dict['0_count'].append((df[fet] == 0).sum())
    test_dict['MannWhitney_p'].append(mannwhitneyu(df[fet],df['Flag'],alternative='two-sided')[1])
    test_dict['ttest_p'].append(ttest_ind(df[fet],df['Flag'])[1])


# In[15]:


df_test = pd.DataFrame(test_dict)


# In[16]:


df_test['MannWhitney_adj_p'] = multipletests(df_test['MannWhitney_p'],alpha=0.05,method='bonferroni')[1]
df_test['ttest_adj_p'] = multipletests(df_test['ttest_p'],alpha=0.05,method='bonferroni')[1]
df_test['MannWhitney_adj_reject'] = multipletests(df_test['MannWhitney_p'],alpha=0.05,method='bonferroni')[0]
df_test['ttest_adj_reject'] = multipletests(df_test['ttest_p'],alpha=0.05,method='bonferroni')[0]


# In[20]:


df_test.sort_values(by='ttest_adj_p').to_csv(out_file)

df.loc[:,df.columns.isin(df_test.loc[(df_test['MannWhitney_adj_reject'] | df_test['ttest_adj_reject']),'feature'])].to_csv(out_filtered)
