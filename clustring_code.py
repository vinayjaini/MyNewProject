# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 15:45:00 2019

@author: GURU
"""

#load Pandas libary
import pandas as pd
import numpy as np
import random 
import sklearn
from sklearn.cluster import KMeans

# Read data from csv file
master = pd.read_csv("E:/cluster analysis/OLD_INV_LINES_201801-201803_masked.csv")
master = pd.DataFrame(master)

# data explore
master.shape #rows and column information 
master.head(n=5) #top rows details
master.info
master.dtypes
master.describe() #data summary details
master.apply(pd.Series.value_counts)
#master.mean()
#master.corr() ##correlation analysis

##missing data analysis
list(master)
master.isna().sum()
#deleted_on_date
dlt_cnt = pd.crosstab(index = master["DELETED_ON_DATE"], columns = "count")
master = master.drop('DELETED_ON_DATE',axis=1)
#v cm_chk_num
chk_cnt = pd.crosstab(index = master["V_CM_CHK_NUM"], columns = "count")
master["V_CM_CHK_NUM"] = master["V_CM_CHK_NUM"].fillna("0")
#v_orig_shwrm_flag
org_cnt = pd.crosstab(index = master["V_ORIG_SHWRM_FLAG"], columns = "count")
master["V_ORIG_SHWRM_FLAG"] = master["V_ORIG_SHWRM_FLAG"].fillna("0")
#v_org_writter_init
wrt_cnt = pd.crosstab(index = master["V_ORIG_WRITER_INIT"], columns = "count")
master["V_ORIG_WRITER_INIT"] = master["V_ORIG_WRITER_INIT"].fillna("0")
#v_wms_status
wms_cnt = pd.crosstab(index = master["V_WMS_STATUS"], columns = "count")
master["V_WMS_STATUS"] = master["V_WMS_STATUS"].fillna("S")
#v_trans_date
trsn_cnt = pd.crosstab(index = master["V_TRANS_DATE"], columns = "count")
master = master.drop('V_TRANS_DATE',axis=1)
#v_trans_entry_date
entry_cnt = pd.crosstab(index = master["V_TRANS_ENTRY_DATE"], columns = "count")
master = master.drop('V_TRANS_ENTRY_DATE',axis=1)


##one-hot encoding
#old_invoices_key
old_inv_cnt = pd.crosstab(index = master["OLD_INVOICES_KEY"], columns = "count")
master = master.drop('OLD_INVOICES_KEY',axis=1)
#invoice_acct
inv_cnt = pd.crosstab(index = master["INVOICE_ACCT"], columns = "count")
s = pd.Series(list(master['INVOICE_ACCT']))
order_dummy=pd.DataFrame(pd.get_dummies(s))
master = pd.concat([master,order_dummy],axis=1)
master = master.drop('INVOICE_ACCT',axis=1)

#invoice_id
id_cnt = pd.crosstab(index = master["INVOICE_ID"], columns = "count")
master = master.drop('INVOICE_ID',axis=1)
#order_code
ord_cnt = pd.crosstab(index = master["ORDER_CODE"], columns = "count")
s = pd.Series(list(master['ORDER_CODE']))
order_dummy=pd.DataFrame(pd.get_dummies(s))
master = pd.concat([master,order_dummy],axis=1)
master = master.drop('ORDER_CODE',axis=1)
#db_insert_ts
db_cnt = pd.crosstab(index = master["DB_INSERT_TS"], columns = "count")
master = master.drop('DB_INSERT_TS',axis=1)
#nonconforming_flag
confr_cnt = pd.crosstab(index = master["NONCONFORMING_FLAG"], columns = "count")
master = master.drop('NONCONFORMING_FLAG',axis=1)
#v cm_chk_num
chk_cnt = pd.crosstab(index = master["V_CM_CHK_NUM"], columns = "count")
master['repeated'] = np.where(master['V_CM_CHK_NUM']=='0', '0', '1')

##modelling
master.V_CM_CHK_NUM = pd.to_numeric(master.V_CM_CHK_NUM, errors='coerce')
master.V_ORIG_SHWRM_FLAG = pd.to_numeric(master.V_ORIG_SHWRM_FLAG, errors='coerce')
master.V_ORIG_WRITER_INIT = pd.to_numeric(master.V_ORIG_WRITER_INIT, errors='coerce')
master.V_WMS_STATUS = pd.to_numeric(master.V_WMS_STATUS, errors='coerce')
master.repeated = pd.to_numeric(master.repeated, errors='coerce')
master= master.fillna('0')

kmeans = KMeans(n_clusters=3).fit(master)
centroids = kmeans.cluster_centers_
print(centroids)





