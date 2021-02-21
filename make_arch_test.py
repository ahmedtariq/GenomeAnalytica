#!/usr/bin/env python
# coding: utf-8

# In[22]:


import numpy as np
import pandas as pd
from scipy.stats import mannwhitneyu, ttest_ind
from statsmodels.stats.multitest import multipletests
import matplotlib.pyplot as plt
import seaborn as sns

import sys
import argparse
import random
import os
from functools import reduce

sns.set(rc={'figure.figsize':(25,20)})
plt.rcParams.update({'font.size': 22})
plt.rcParams['xtick.labelsize'] = 15
plt.rcParams['ytick.labelsize'] = 15
pd.set_option('display.max_columns',None)
pd.set_option('display.max_colwidth', None)

random.seed = 0
np.random.seed = 0

desc = """make_arch_test

This script takes the path for data created by make_arch_all, path for species lineage csv created by make_tax, rank value to test againist. 
Count the nulls (which is filled with 0 and returned as 0_count) in each feature, applies 2 sample 2 tailed ttest and Manwhetney, correct using benferroni and returns
parsed data architicture feature in 1 csv
test results containing (feature,0_count,MannWhitney_p,ttest_p,MannWhitney_adj_p,ttest_adj_p,MannWhitney_adj_reject,ttest_adj_reject)
filtered parsed data architicture features for only significant ones according to corrected p-value < 0.05
Box plot figure for adj_ttest significant features
"""
use = "./make_arch_test.py --stats input_stats_dir --tax tax_file --tax_rank number --rank_value rank_value [--out_test output_test_file] [--out_parsed output_parsed_file] [--out_parsed_filtered output_filtered_file]"

example = """example:

./make_arch_test.py --stats data/output/ --tax data/tax_mapping.csv --tax_value vertebrata
"""
# In[24]:


parser=argparse.ArgumentParser(description=desc,formatter_class=argparse.RawDescriptionHelpFormatter,usage=use,epilog=example)

parser.add_argument('--stats', nargs='?',type=str, help='Directory containning the nested csv stats for all species in form of (species,stats)')
parser.add_argument('--tax', nargs='?',type=str, help='File csv contianing the full lineage of all species in stats')
parser.add_argument('--out_test', nargs='?',type=str, default='test_result.csv', help='File to write the test results')
parser.add_argument('--out_parsed', nargs='?',type=str, default='parsed_all.csv', help='File to write parsed data')
parser.add_argument('--out_parsed_filtered', nargs='?',type=str, default='parsed_filtered.csv', help='File to write parsed data with filtered significant features')
parser.add_argument('--out_fig', nargs='?',type=str, default='Sig_Fet_boxplot.png', help='png File to write boxplot figure')
parser.add_argument('--tax_value', nargs='?',type=str, default="Vertebrata", help='value to test for in the tax rank e.g: Vertebrata to test Vert vs In-Vert in Subphylum')


# In[25]:


args=parser.parse_args()


# In[ ]:


data_dir = args.stats
tax_file = args.tax
out_file = args.out_test
out_parsed = args.out_parsed
out_filtered = args.out_parsed_filtered
rank_value = args.tax_value
out_fig = args.out_fig


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


df[["species"] + [i for i in df.columns if i!="species"]].to_csv(out_parsed,index=False)
# In[7]:


df_map = pd.read_csv(tax_file,header=None,usecols=[i for i in range(0,11,1)])


# In[9]:
df_map['Flag'] = (df_map.apply(lambda x: x.str.lower() if x.dtype=='object' else x) == rank_value.lower()).any(axis=1)
df_map = df_map.loc[:,[0,'Flag']]
df = df.merge(df_map,left_on="species",right_on=0,how='left').drop(0,axis=1)

# In[14]:


test_dict = {'feature' : [],'0_count' : [],"avg_"+rank_value.lower() : [],"avg_non_"+rank_value.lower() : [],'MannWhitney_p' : [], 'ttest_p' : []}
for fet in df.select_dtypes(['float','int']):
    test_dict['feature'].append(fet)
    test_dict['0_count'].append((df[fet] == 0).sum())
    test_dict["avg_"+rank_value.lower()].append(df.loc[df['Flag'] == True,fet].mean())
    test_dict["avg_non_"+rank_value.lower()].append(df.loc[df['Flag'] == False,fet].mean())
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


df_test.sort_values(by='ttest_adj_p').to_csv(out_file,index=False)

df.loc[:,df.columns.isin(df_test.loc[(df_test['MannWhitney_adj_reject'] | df_test['ttest_adj_reject']),'feature'])].to_csv(out_filtered,index=False)

def plot_sig(y_list ,df=df,df_test=df_test,x = 'Flag',output=out_fig):
    # Tot and Cols are known

    Tot = len(y_list)
    Cols = 4

    # Compute Rows required

    Rows = Tot // Cols 
    Rows += Tot % Cols

    # Create a Position index

    Position = range(1,Tot + 1)
    # Create main figure
    fig = plt.figure(1)
    
    for i,c in enumerate(y_list):
        ax1 = fig.add_subplot(Rows,Cols,Position[i])
        ax = sns.boxplot(data=df,x=x,y=c,ax=ax1)
        ax.set_xticklabels(['Non-' + rank_value,rank_value])
        ax.set_title("Adj_p_value = " + str(round(df_test.loc[df_test['feature'] == c,'ttest_adj_p'].item(),5)))
    fig.text(0.5, 0.04, 'Species', ha='center')
    fig.text(0.04, 0.5, 'Feature', va='center', rotation='vertical')
    fig.tight_layout()
    fig.savefig(output)

plot_sig(y_list = df_test[(df_test['ttest_adj_reject'] == True)]['feature'].to_list())
