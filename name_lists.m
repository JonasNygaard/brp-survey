%% MakeLists.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This scripts constructs name lists for use in the construction of figures and tables. 
%
%    --------------------------------
%    Last modified: December, 2015
%    --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

% Setting up list of survey variables
survey_list = {
    'gdp$_{t}^{\mathbb{E}}$'
    'inf$_{t}^{\mathbb{E}}$'
    'cprof$_{t}^{\mathbb{E}}$'
    'unemp$_{t}^{\mathbb{E}}$'
    'ip$_{t}^{\mathbb{E}}$'
    'hous$_{t}^{\mathbb{E}}$'
};

% Setting up list of survey variable names
survey_name_list = {
    'GDP'
    'Inflation'
    'Corporate Profitability'
    'Unemployment'
    'Industrial Production'
    'Housing'
};

% Setting up list of short survey variable names
survey_short_list = {
    'gdp'
    'inf'
    'cprof'
    'unemp'
    'ip'
    'hous'
};

% Setting up list of principal components
pc_list = {
    '$\mathcal{P}_{1,t}^{\mathbb{E}}$'
    '$\mathcal{P}_{2,t}^{\mathbb{E}}$'
    '$\mathcal{P}_{3,t}^{\mathbb{E}}$'
};

% Setting up list of principal component names
pc_name_list = {
    'First principal component'
    'Second principal component'
    'Third principal component'
};

% Setting up list of loading PC names
load_list = {
    'Load $\mathcal{P}_{1,t}^{\mathbb{E}}$'
    'Load $\mathcal{P}_{2,t}^{\mathbb{E}}$'
    'Load $\mathcal{P}_{3,t}^{\mathbb{E}}$'
};

% Setting up list of excess returns
rx_list = {
    '$rx^{\left(2\right)}_{t+4}$'
    '$rx^{\left(3\right)}_{t+4}$'
    '$rx^{\left(4\right)}_{t+4}$'
    '$rx^{\left(5\right)}_{t+4}$'   
};

% Setting up predictor list
factor_list = {
    'CP$_{t}$'
    'LN$_{t}$'
    'ME$_{t}$'
    'level$_{t}$'
    'slope$_{t}$'
    'curv$_{t}$'
    '$\mathcal{Y}_{4,t}$'
    '$\mathcal{Y}_{5,t}$'
};

% Setting up predictor list for GSW data
factor_list_gsw = {
    'CP$_{t}^{\text{GSW}}$'
    'LN$_{t}^{\text{GSW}}$'
    'ME$_{t}^{\text{GSW}}$'
};

% Setting up model list
model_list = {
    'CP'
    'LN'
    'CP+LN'
    'ME'
    'CP+ME'
    'LN+ME'
    'CP+LN+ME'
};

% Setting model comparison list
model_comp_list = {
    'CP+ME vs. CP'
    'LN+ME vs. LN'
    'CP+LN+ME vs. CP+LN'
};

% Setting up survey forecast horizon list
horizon_list = {
    'One-quarter ahead'
    'Two-quarters ahead'
    'Three-quarters ahead'
    'Four-quarters ahead'
};

%-----------------------------------------------------------------------------------------------------------------------
% END OF SCRIPT
%-----------------------------------------------------------------------------------------------------------------------