import pandas as pd
import os
url_path = '/scratch/depdetect/lt228/Example/Data/EQS_7_TO_10'
'''dataset Reading'''
feature_NAME = ("SURFSKINTEMP","SURFAIRTEMP","TOTH2OVAP","TOTO3",
                "TOTCO","TOTCH4","OLR_ARIS","CLROLR_ARIS","OLR_NOAA","MODIS_LST")
for fold in [3]:
    
    train_path = url_path+'/FOLD%d/series_train_k_DBSTAR.csv'%fold
    
    test_path = url_path+'/FOLD%d/series_test_k_DBSTAR.csv'%fold
    train_df=pd.read_csv(train_path,header=0)
    test_df = pd.read_csv(test_path,header=0)

    train_data  = train_df.loc[:,feature_NAME]

    train_target = train_df.loc[:,'FLAG']
    test_data = test_df.loc[:,feature_NAME]
    test_target = test_df.loc[:,'FLAG']

    from sklearn.ensemble import boost_modify
    from sklearn.tree import tree_prune
    clf = tree_prune.DecisionTreeClassifier()
    clf.fit(train_data,train_target)
    tree_prune.get_n_leaves(clf)


from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_curve,auc
from sklearn.ensemble import AdaBoostClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import boost_modify
from sklearn.tree import tree_prune
import multiprocessing
def task_5fold(fold):
    train_path = url_path+'/FOLD%d/series_train_k_DBSTAR.csv'%fold
    
    test_path = url_path+'/FOLD%d/series_test_k_DBSTAR.csv'%fold
    new_path = url_path+'/FOLD%d/Inverse_series_test_k_DBSTAR_500.csv'%fold

    train_df=pd.read_csv(train_path,header=0)
    test_df = pd.read_csv(test_path,header=0)
    
    train_data  = train_df.loc[:,feature_NAME]

    train_target = train_df.loc[:,'FLAG']
    test_data = test_df.loc[:,feature_NAME]
    test_target = test_df.loc[:,'FLAG']
    '''Boost-pruning'''
    boost_pruning = boost_modify.AdaBoostClassifier(n_estimators=500,
                                       base_estimator=tree_prune.DecisionTreeClassifier(max_depth=17),algorithm='SAMME')
    boost_pruning.fit(train_data,train_target,v_Folds=5)
    
    test_df['LABEL_PREDICTION'] = boost_pruning.predict(test_data)
    test_df.to_csv(new_path)
    
    bp_prob  = boost_pruning.predict_proba(test_data)
    fpr, tpr, _ = roc_curve(test_target, bp_prob[:, 1],pos_label=1)
    roc_auc = auc(fpr, tpr)
    print('Fold %d AUC:%f'%(fold,roc_auc))
    return roc_auc

results=[]
for fold in [3]:
    result=task_5fold(fold)
    results.append(result)

for result in results:
    print(result)

