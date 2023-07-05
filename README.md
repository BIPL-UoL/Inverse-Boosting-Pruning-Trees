# Inverse-Boosting-Pruning-Trees algorithm for earthquake prediction 

The Inverse boosting pruning trees code should be compiled with scikit-learn 0.18.X   


""" 

@authors: Pan Xiong, Lei Tong, Kun Zhang, Xuhui Shen, Roberto Battiston, Dimitar Ouzounov, Roberto Iuppa, Danny Crookes, Cheng Long and Huiyu Zhou

@Email: lt228@leicester.ac.uk, xiong.pan@gmail.com (Software Developers)

""" 

This method is built upon [sklearn_tree_post_prune](https://github.com/shenwanxiang/sklearn-post-prune-tree/tree/master) and scikit-learn 0.18.X.

Usage 
======= 

Step 0: Configure the Python Environment
  ```
  conda create -n py36 python=3.6.8
  ```
Step 1: Install Required Dependencies
  ```
  source activate py36
  pip install -r requirements.txt
  ```
Step 2: Download the source code of [scikit-learn 0.18.0](https://github.com/scikit-learn/scikit-learn/tree/0.18.X) and extract it. 

Step 3: Build Cython Extensions
  ```
  cd ./sklearn_tree_post_prune/src/
  cython _tree_prune.pyx
  python setup.py build
  ```
Step 4: Copy the following files to the directory scikit-learn-0.18.X/sklearn/tree/
  ```
  cp ./sklearn_tree_post_prune/src/build/lib_Completement with the system version/tree/_tree_prune.cpython-36m-darwin.so to scikit-learn-0.18.X/sklearn/tree/
  cp ./tree_prune.py to scikit-learn-0.18.X/sklearn/tree/
  ```

Step 5: Copy the following files to the directory scikit-learn-0.18.X/sklearn/ensemble/ and add 'from . import boost\_utils' to ensemble/\_\_init__.py file:
  ```
  cp ./boost\_modify.py to scikit-learn-0.18.X/sklearn/ensemble/
  cp ./boost\_utils.py to scikit-learn-0.18.X/sklearn/ensemble/
  ```
 
Step 6: Change the directory to the root folder of scikit-learn-0.18.X and execute the following command:
 ```
  cd ./scikit-learn-0.18.X/
  pip install -e .
  ```

Step 7: Install R packages that depends on 

 

	pkgs <- c("plotROC", "cvAUC", "pROC", "ROCR" ,"readxl","MLmetrics","mccr") 

	for (pkg in pkgs) { 
  	if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg) } 
	} 

 

Testing 
======= 

 

Open an IPython shell:: 

 

	>>> from sklearn import datasets
	>>> from sklearn.tree import tree_prune 
	>>> from sklearn.ensemble import boost_modify 
	>>> from sklearn.model_selection import train_test_split
	
	>>> iris = datasets.load_iris()
	>>> X = iris.data
	>>> y = iris.target
	>>> X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.30, random_state=42)
	
	>>> IBPT = boost_modify.AdaBoostClassifier(n_estimators=100,
							base_estimator=tree_prune.DecisionTreeClassifier(),algorithm='SAMME') 
	>>> IBPT.fit(X_train,y_train,v_Folds=5) 
	>>> IBPT.score(X_test,y_test)

 
 

Undertaking earthquake prediction performance  
======= 

Run the testing example by "python test.py" to have the prediction results file. 

Run the code by "Rscript caculate_metrics.R" to have the earthquake prediction metrics and curves. 

## Acknowledgement
Many thanks to the authors of [sklearn_tree_post_prune](https://github.com/shenwanxiang/sklearn-post-prune-tree/tree/master). 

 
