function [test_value,p_value] = perform_utility_dm_test(util_m1,util_m2)

%% perform_cw_dm_test.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This function performs a Diebold-Mariano test on the difference in realized utility from two competing models. 
%
%   Input variables:
%   ---------------------------------------------------------
%   util_m1         = P x N matrix of realized utilities from model 1
%   util_m2         = P x N matrix of realized utilities from model 2    
%
%
%   Output variables:
%   ---------------------------------------------------------
%   test_value      = value of the Diebold-Mariono test   
%   p-value         = p-value for rejecting the null of equal realized utility
%
%   Dependencies:
%   ---------------------------------------------------------
%   linear_reg.m 
%
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

% Error checking in input
if (nargin < 2)
    error('perform_cw_dm_test.m: Not enough input parameters');
end

if (nargin > 2)
    error('perform_cw_dm_test.m: Too many input parameters');
end

if (size(util_m1,1) ~= size(util_m2,1))
    error('perform_cw_dm_test.m: util_m1 and util_m2 not of equal length');
end

if (size(util_m1,2) ~= size(util_m2,2))
    error('perform_cw_dm_test.m: util_m1 and util_m2 not of equal cross-sectional size');
end

%-----------------------------------------------------------------------------------------------------------------------
%% TESTING FOR DIFFERENCE IN REALIZED UTILITIES
%-----------------------------------------------------------------------------------------------------------------------

% Computing difference in realized utility
utillity_difference     = util_m1 - util_m2;

% Run regression to get beta and standard error
[beta_util,std_util]    = linear_reg(utillity_difference,ones(size(utillity_difference,1),1),0,'OLS',3);

% Compute test value
test_value              = beta_util./std_util;

% Compute p-value
p_value                 = 1 - normcdf(test_value,0,1);      

end

%-----------------------------------------------------------------------------------------------------------------------
%% END OF FUNCTION
%-----------------------------------------------------------------------------------------------------------------------