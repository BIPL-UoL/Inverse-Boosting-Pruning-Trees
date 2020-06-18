# Inverse-Boosting-Pruning-Trees
The Inverse boosting pruning trees code should be compiled with scikit-learn 0.18.0  
(This code will be updated later and be compatible with new version of sklearn)


"""

@auther: LeiTong, Xiong Pan

@email: lt228@leicester.ac.uk, 

"""


Usage
=======


step1: Download the source code of scikit-learn 0.18.0

setp2: copy the files of _tree_prune.cpython-35m-x86_64-linux-gnu.so and tree_prune.py to scikit-learn-0.18.X/sklearn/tree

setp3: copy the files of boost_modify.py and boost_utils.py to scikit-learn-0.18.X/sklearn/ensemble, then add 'from . import boost_utils' in the ensemble/__init__.py file.

step4: cd the root folder of sckikt-learn and execute "pip install -e ."

step5: install R packages that H2O depends on

	pkgs <- c("plotROC", "cvAUC", "pROC", "ROCR" ,"readxl","MLmetrics","mccr")
	for (pkg in pkgs) {
	  if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg) }
	}


Testing
=======

Open an IPython shell ::

    >>> from sklearn.datasets import make_classification
    >>> from sklearn.tree import tree_prune
	>>> from sklearn.ensemble import boost_modify
    >>> X,y = make_classification
    >>> IBPT = boost_modify.AdaBoostClassifier(n_estimators=100,
                                       base_estimator=tree_prune.DecisionTreeClassifier(),algorithm='SAMME')
    >>> IBPT.fit(train_data,train_target,v_Folds=5)
    >>> predicted_results = IBPT.predict(your_testing_data)


Calculating earthquake prediction performance 
=======
Run the code testing example by "python testing.py" to get the prediction results file.

Run the code by "Rscript caculate_metrics.R" to get the earthquake prediction metrics and curves.
