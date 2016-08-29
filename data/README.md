## Data and file descriptions
The `data/` folder contains the following folders and files:

* matfiles/
* makeBondData.m
* makeMacroFactors.m
* makeSurveyData.m
* rawToMatfiles.m

The `matfiles/` folder contains matfiles with both raw and processed data used as input to the empirical analyses conducted in the paper. The matfiles are either constructing in the `rawToMatfiles.m` script, which simply reads in raw data, or in the series of `make...` scripts located within this folder as well. 

The `makeBondData.m` script generates bond risk premia and yield curve related predictors following the outline in the paper. We consider bond risk premia using both the Fama and Bliss bonds and the Gürkaynak, Sack, and Wright bonds. The `makeMacroFactors.m` script generates the macro factor proposed in Ludvigson and Ng (2009) using ALFRED macroeconomic data, which enables us to construct the information set in the out-of-sample analysis according to the vintage of data actually available at the time of the forecast. Lastly, the `makeSurveyData.m` script computes one- through four-quarter ahead growth expectations for the survey-based expectations for the future level of a set of macroeconomic fundamentals surveyed by the Survey of Professional Forecasters (SPF). 

For further details on the data construction, we refer to the detailed discussions contained the paper. 