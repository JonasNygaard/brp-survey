function [parm,std_err,t_stat,r2,adj_r2,reg_se,F_test,bic] = linear_reg(y,x,constant,method,nlag)
 
%% linear_reg.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This function estimates a linear regression model using Ordinary Least Squares (OLS) with standard errors computed
%   according to a user-specified method and, if applicable, with a user-specified number of lags in the computation. 
%   The function currently supports the following set of standard errors: 
%
%       * OLS:              Usual OLS standard errors under the assumption of iid errors.
%       * White:            White (1980) heteroskedasticity consistent standard errors.
%       * Newey-West:       Newey and West (1987) heteroskedasticity and autocorrelation consistent standard errors.
%       * Hansen-Hodrick:   Hansen and Hodrick (1980) heteroskedasticity and autocorrelation consistent standard errors.
%       * Skip:             No standard errors computed, useful if used in Monte Carlo simulations
%
%   If the standard error computation method is left unspecified, then the function will return the usual OLS standard
%   errors per default. A constant is added to the model as a default, but can be turned off. The function supports 
%   single regressions as well as multiple regression for different dependent variable, but same dependent variables.
%
%   Function inputs:
%   --------------------------------------------------------------------------------------------------------------------
%   y           = A T x N matrix of dependent variables. If N > 1 the function runs N separate regressions. 
%   x           = A T x K matrix of explanatory variables common for all N regressions. 
%   constant    = Scalar indicating whether a constant is added to the model. 1 for yes (default), 0 otherwise.
%   method      = String input indicating choice of standard errors. The following abbreviations are used:
%                   - 'OLS'     standard OLS iid standard errors
%                   - 'W'       While (1980) standard errors
%                   - 'NW'      Newey & West (1987) standard errors
%                   - 'HH'      Hansen & Hodrick (1980) standard errors
%                   - 'Skip'    Standard error computation omitted
%   nlag        = Scalar indicating number of lags to use in the standard error computation
%
%   Function outputs:
%   --------------------------------------------------------------------------------------------------------------------
%   parm        = A K x N matrix of estimated model parameters
%   std_err     = A K x N matrix of standard errors
%   t_stat      = A K x N matrix of t-statistics for the null of individual parameters being equal to zero.
%   r2          = A N x 1 vector of r-squared values
%   adj_r2      = A N x 1 vector of adjusted r-squared values
%   reg_se      = A N x 1 vector of variances of the model residuals
%   F_test      = A N x 3 matrix of joint F-tests testing whether slope parameters are jointly equal to zero
%   bic         = A N x 1 vector of Schwartz-Bayesian Information criteria
%
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

% Error checking on input
if (nargin < 2)
    error('linear_reg.m: Not enough input parameters')
end

if (nargin > 5)
    error('linear_reg.m: Too many input parameters');
end

if (size(x,1) ~= size(y,1))
  error('linear_reg.m: Length of y and x is not the same'); 
end

if ~ismember(method,[{'OLS'},{'W'},{'NW'},{'HH'},{'Skip'}])
    error('linear_reg.m: Wrong specification for standard errors provided');
end

% Error check on lag number or set to zero if inconsequential
if (nargin < 5) && ismember(method,[{'NW'},{'HH'}])
    error('linear_reg.m: Lag length unspecified');
end

% Setting default parameters
if (nargin < 3)

    constant    = 1;
    method      = 'OLS';
    nlag        = 0;
    
end

%-----------------------------------------------------------------------------------------------------------------------
%% PRELIMINARIES
%-----------------------------------------------------------------------------------------------------------------------

% Adding constant to design matrix
if constant == 1

  x = [ones(size(x,1),1) x];

end

% Determining dimensions of y
[T,nVar]   = size(y);

% Setting preliminaries
K       = size(x,2);
Exx     = x'*x/T;
parm    = x\y;
errv    = y - x*parm;
reg_se  = sum(errv.^2)/T;

% Computing information criteria
bic     = log(reg_se) + K*log(T)/T;

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTE STANDARD ERRORS ACCORDING TO METHOD
%-----------------------------------------------------------------------------------------------------------------------

% Preallocations
std_err = NaN(K,nVar);
t_stat  = NaN(K,nVar);
F_test  = NaN(nVar,3);

% Computing standard errors based on method
if strcmp(method,'Skip');
    
   std_err  = NaN;
   t_stat   = NaN;
   r2       = NaN;
   adj_r2   = NaN;
   F_test   = NaN;

%-----------------------------------------------------------------------------------------------------------------------
%% OLS STANDARD ERRORS
%-----------------------------------------------------------------------------------------------------------------------

elseif strcmp(method,'OLS')

    errv    = y - x*parm;
    reg_se  = mean(errv.^2);
    vary    = mean((y - ones(T,1) * mean(y)).^2);
    r2      = (1 - reg_se./vary)';
    adj_r2  = (1 - (reg_se./vary) * (T-1)/(T-K))';

    % Computing OLS standard errors
    for iVar = 1:nVar

        % Compute residuals and covariance matrix
        err                 = errv(:,iVar);
        s2i                 = mean(err.^2);
        varb                = s2i.*(Exx\eye(K))/T;
        
        % F_test-test on coefficient being zero (except constant)
        chi2val             = parm(2:end,iVar)'*((varb(2:end,2:end))\parm(2:end,iVar));
        df                  = size(parm(2:end,1),1);
        pval                = 1 - cdf('chi2',chi2val,df);
        F_test(iVar,1:3)    = [chi2val df pval];

        % Making vector of standard errors
        seb                 = diag(varb);
        seb                 = sign(seb).*(abs(seb).^0.5);
        std_err(:,iVar)     = seb;
        t_stat(:,iVar)      = parm(:,iVar)./std_err(:,iVar);

    end

%-----------------------------------------------------------------------------------------------------------------------
%% WHITE (1980) STANDARD ERRORS
%-----------------------------------------------------------------------------------------------------------------------

elseif strcmp(method,'W')

    errv    = y - x*parm;
    reg_se  = mean(errv.^2);
    vary    = mean((y - ones(T,1) * mean(y)).^2);
    r2      = (1 - reg_se./vary)';
    adj_r2  = (1 - (reg_se./vary) * (T-1)/(T-K))';

    % Computing White standard errors
    for iVar = 1:nVar

        % Compute residuals and covariance matrix
        err                 = errv(:,iVar);
        inner               = (x.*(err*ones(1,K)))' * (x.*(err*ones(1,K))) / T;
        varb                = Exx\inner/Exx/T;

        % F_test-test on coefficient being zero (except constant)
        chi2val             = parm(2:end,iVar)'*((varb(2:end,2:end))\parm(2:end,iVar));
        df                  = size(parm(2:end,1),1);
        pval                = 1 - cdf('chi2',chi2val,df);
        F_test(iVar,1:3)    = [chi2val df pval];

        % Making vector of standard errors  
        seb                 = diag(varb);
        seb                 = sign(seb).*(abs(seb).^0.5);
        std_err(:,iVar)     = seb;
        t_stat(:,iVar)      = parm(:,iVar)./std_err(:,iVar);

    end

%-----------------------------------------------------------------------------------------------------------------------
%% NEWEY AND WEST (1987) STANDARD ERRORS
%-----------------------------------------------------------------------------------------------------------------------
     
elseif strcmp(method,'NW');
    
    ww      = 1;
    errv    = y - x*parm;
    reg_se  = mean(errv.^2);
    vary    = mean((y - ones(T,1) * mean(y)).^2);
    r2      = (1 - reg_se./vary)';
    adj_r2  = (1 - (reg_se./vary) * (T-1)/(T-K))';
    
    % Computing Newey-West standard errors
    for iVar = 1:nVar

        % Compute residuals and covariance matrix
        err                 = errv(:,iVar);
        inner               = (x.*(err*ones(1,K)))' * (x.*(err*ones(1,K))) / T;

        for j=1:nlag

            innadd          = (x(1:T-j,:).*(err(1:T-j)*ones(1,K)))'*(x(1+j:T,:).*(err(1+j:T)*ones(1,K)))/T;
            inner           = inner + (1-ww*j/(nlag+1))*(innadd+innadd');

        end
        varb = Exx\inner/Exx/T;

        % F_test-test on coefficient being zero (except constant)
        chi2val             = parm(2:end,iVar)'*((varb(2:end,2:end))\parm(2:end,iVar));
        df                  = size(parm(2:end,1),1);
        pval                = 1 - cdf('chi2',chi2val,df);
        F_test(iVar,1:3)    = [chi2val df pval];
        
        % Making vector of standard errors
        seb                 = diag(varb);
        seb                 = sign(seb).*(abs(seb).^0.5);
        std_err(:,iVar)     = seb;
        t_stat(:,iVar)      = parm(:,iVar)./std_err(:,iVar);

    end

%-----------------------------------------------------------------------------------------------------------------------
%% HANSEN AND HODRICK (1980) STANDARD ERRORS
%-----------------------------------------------------------------------------------------------------------------------
    
elseif strcmp(method,'HH');
    
    ww      = 0;
    errv    = y - x*parm;
    reg_se  = mean(errv.^2);
    vary    = mean((y - ones(T,1) * mean(y)).^2);
    r2      = (1 - reg_se./vary)';
    adj_r2  = (1 - (reg_se./vary) * (T-1)/(T-K))';
    
    % Computing Hansen-Hodrick standard errors
    for iVar = 1:nVar

        % Compute residuals and covariance matrix
        err                 = errv(:,iVar);
        inner               = (x.*(err*ones(1,K)))' * (x.*(err*ones(1,K))) / T;

        for j=1:nlag

            innadd          = (x(1:T-j,:).*(err(1:T-j)*ones(1,K)))'*(x(1+j:T,:).*(err(1+j:T)*ones(1,K)))/T;
            inner           = inner + (1-ww*j/(nlag+1))*(innadd+innadd');
                
        end
        varb = Exx\inner/Exx/T;

        % F_test-test on coefficient being zero (except constant)
        chi2val             = parm(2:end,iVar)'*((varb(2:end,2:end))\parm(2:end,iVar));
        df                  = size(parm(2:end,1),1);
        pval                = 1 - cdf('chi2',chi2val,df);
        F_test(iVar,1:3)    = [chi2val df pval];

        % Making vector of standard errors
        seb                 = diag(varb);
        seb                 = sign(seb).*(abs(seb).^0.5);
        std_err(:,iVar)     = seb;
        t_stat(:,iVar)      = parm(:,iVar)./std_err(:,iVar);

    end
        
end
end
    
%-----------------------------------------------------------------------------------------------------------------------
% END OF FUNCTION
%-----------------------------------------------------------------------------------------------------------------------