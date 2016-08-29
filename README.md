## Expected Business Conditions and Bond Risk Premia

* Author: Jonas Nygaard Eriksen
* Maintainer: Jonas Nygaard Eriksen (jeriksen@econ.au.dk)
* Paper status: Accepted for publication in Journal of Financial and Quantitative Analysis (JFQA)

### Abstract
> This paper studies the predictability of bond risk premia by means of expectations to future business conditions using survey forecasts from the Survey of Professional Forecasters. We show that expected business conditions consistently affect excess bond returns and that the inclusion of expected business conditions in standard predictive regressions improve forecast performance relative to models using information derived from the current term structure or macroeconomic variables. The results are confirmed in a real-time out-of-sample exercise, where the predictive accuracy of the models is evaluated both statistically and from the perspective of a mean-variance investor that trades in the bond market.

### Replication files
This repository contains the source files for replicating the empirical results presented in the paper *_Expected Business Conditions and Bond Risk Premia_*. Specifically, this repository contains all Matlab files used for generating the empirical results as well as the tables and figures appearing in the paper. 

### Generate figures and tables
To re-create the results, simply run `main_brp.m` in Matlab. It calls all dependencies and stores `tex` tables and `eps` figures in the `tex/figures` and `tex/tables` folders. The data is stored in `.mat` files in the `data/` folder, which contains further notes on the data. The code is run using Matlab R2016a for Mac. 

#### Compiling the LaTeX file
Open the `main_brp.tex` file in the `tex/` folder in our favorite editor and hit compile. The document is fairly plain vanilla, so hopefully there should be no trouble compiling. It loads figures and tables directly from the `tex/figures` and `tex/tables` folders, where the Matlab script `main_brp.m` stores the results. The LaTeX document is written and prepared in [Sublime Text 3](http://www.sublimetext.com/3) using the [LaTeX Tools](https://github.com/SublimeText/LaTeXTools) plug-in. 