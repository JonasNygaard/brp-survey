function [test_value,p_value,r2_oos] = perform_cw_dm_test(actual,forecast_m1,forecast_m2,test_type)

%% perform_cw_dm_test.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This function computes the Clark-West or the Diebold-Mariano test for equal predictive accuracy based on user input.
%
%   Input variables:
%   ---------------------------------------------------------
%   actual          = P x N matrix of actual excess returns
%   forecast_m1     = P x N matrix of forecast from model 1
%   forecast_m2     = P x N matrix of forecast from model 2    
%   test_type       = String indicator for DM or CW test
%
%   Output variables:
%   ---------------------------------------------------------
%   test_value      = value of the CW or DM test   
%   p-value         = p-value for rejecting the null of equal predictive accuracy
%   r2_oos          = Out-of-sample R-squared from Campbell & Thompson (2008)
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
if (nargin < 4)
    error('perform_cw_dm_test.m: Not enough input parameters');
end

if (nargin > 4)
    error('perform_cw_dm_test.m: Too many input parameters');
end

if (size(actual,1) ~= size(forecast_m1,1))
    error('perform_cw_dm_test.m: Actual and forecast_m1 not of equal length');
end

if (size(actual,1) ~= size(forecast_m2,1))
    error('perform_cw_dm_test.m: Actual and forecast_m2 not of equal length');
end

if (size(actual,2) ~= size(forecast_m1,2))
    error('perform_cw_dm_test.m: Actual and forecast_m1 not of equal cross-sectional size');
end

if (size(actual,2) ~= size(forecast_m2,2))
    error('perform_cw_dm_test.m: Actual and forecast_m2 not of equal cross-sectional size');
end

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING FORECAST ERRORS AND OUT-OF-SAMPLE R-SQUARED
%-----------------------------------------------------------------------------------------------------------------------

% Computing forecast errors
ferror1 = actual - forecast_m1;
ferror2 = actual - forecast_m2;

% Computing mean squared prediction errors
mspe1   = mean(ferror1.^2);
mspe2   = mean(ferror2.^2);

% Computing out-of-sample R2
r2_oos  = 100.*(1-mspe2./mspe1);

%-----------------------------------------------------------------------------------------------------------------------
%% PERFORM CLARK-WEST TEST
%-----------------------------------------------------------------------------------------------------------------------

if strcmp(test_type,'CW')

    f_hat           = ferror1.^2 - (ferror2.^2 - (forecast_m1-forecast_m2).^2); % Computing adjusted difference in MSE
    [beta_f,std_f]  = linear_reg(f_hat,ones(size(f_hat,1),1),0,'NW',3);         % Compute difference in adj. MSE
    test_value      = beta_f./std_f;                                            % Compute CW test value
    p_value         = 1 - normcdf(test_value,0,1);                              % Compute CW p-value

end

%-----------------------------------------------------------------------------------------------------------------------
%% PERFORM DIEBOLD-MARIANO TEST
%-----------------------------------------------------------------------------------------------------------------------

if strcmp(test_type,'DM')

    d_hat           = ferror1.^2 -ferror2.^2;                                   % Computing difference in MSE
    [beta_d,std_d]  = linear_reg(d_hat,ones(size(d_hat,1),1),0,'NW',3);         % Compute difference in MSE
    test_value      = beta_d./std_d;                                            % Compute DM test value
    p_value         = 1 - normcdf(test_value,0,1);                              % Compute DM p-value

end
end

%-----------------------------------------------------------------------------------------------------------------------
%% END OF FUNCTION
%-----------------------------------------------------------------------------------------------------------------------