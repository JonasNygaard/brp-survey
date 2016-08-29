function x = standard(y)

%% standard.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This function transforms the input variable x into a variable with mean zero and variance one. y can either be a 
%   vector time series or a matrix of time series. In the case of matrix, it transform each column with its own mean 
%   and variance. 
%
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

% Number of observations
T   = size(y,1);

% Creating vector of means
my  = repmat(mean(y),T,1);

% Creating vector of standard deviations
sy  = repmat(std(y),T,1);

% Standardizing
x   = (y-my)./sy;

end

%-----------------------------------------------------------------------------------------------------------------------
% END OF FUNCTION
%-----------------------------------------------------------------------------------------------------------------------