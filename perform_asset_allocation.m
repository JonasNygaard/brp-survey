function [utility,Sharpe,mppm,wrisk,pf_return,turnover] = ...
    perform_asset_allocation(actual,risk_free,forecast,vol_forecast,risk_aversion,bound_type,bounds,tc_bp)

%% perform_asset_allocation.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This functions performs asset allocation under the assumption of a the investor having mean-variance preferences. 
%   Under this framework, the function then computes average utility gains, Sharpe ratios for the resulting portfolio
%   returns, a manipulation-proof performance measure, and turnover for the portfolio strategy. The function assumes 
%   that the mean-variance investor allocates capital between a risky security and a risk-free security. 
%
%   Input variables:
%   ---------------------------------------------------------
%   actual          = P-vector of actual excess returns
%   risk_free       = P-vector of one-period risk free rate of return
%   forecast        = P-vector of excess return forecasts
%   vol_forecast    = P-vector of volatility forecasts
%   risk_aversion   = Relative risk aversion parameter for the investor
%   bound_type      = Specify whether bounds are put on weights or returns
%   bounds          = [Upper Lower] bounds for the portfolio formation weights
%   tc_bp           = Transaction costs in basis points (default is zero)
%
%   Output variables:
%   ---------------------------------------------------------
%   utility         = Average realized utility from investment strategy
%   Sharpe          = Sharpe ratio from the investment strategy
%   mppm            = Manipulation-proof performance measure
%   wrisk           = Matrix (vector) of risky asset weights
%   pf_return       = Matrix (vector) of portfolio returns
%   turnover        = Average portfolio turnover in percent
%
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

% Error checking input parameters
if (nargin < 7)
   error ('PerformAssetAllocation.m: Not enough input arguments');
end

if (nargin > 8)
    error('PerformAssetAllocation.m: Too many input arguments');
end

if (size(actual,1) ~= size(forecast,1))
   error('PerformAssetAllocation.m: Length of input variables is not the same');
end

if (size(risk_free,1) ~= size(vol_forecast,1))
   error('PerformAssetAllocation.m: Length of input variables is not the same');
end

if (size(actual,1) ~= size(vol_forecast,1))
   error('PerformAssetAllocation.m: Length of input variables is not the same');
end

if (size(actual,2) ~= size(forecast,2))
    error('PerformAssetAllocation.m: Length of input variables is not the same');
end

if (size(forecast,2) ~= size(vol_forecast,2))
    error('PerformAssetAllocation.m: Length of input variables is not the same');
end

if (~strcmp(bound_type,'Returns') && ~strcmp(bound_type,'Weights'))
    error('PerformAssetAllocation.m: Wrong specification for bounds');
end

%-----------------------------------------------------------------------------------------------------------------------
%% PRELIMINARIES
%-----------------------------------------------------------------------------------------------------------------------

% Set transaction costs to zero by default
if nargin < 8
    tc_bp = 0;
end

% Setting portfolio restrictions
lower_bound = bounds(1);
upper_bound = bounds(2);

% Preallocations and scaling transaction costs
tc          = tc_bp/10000;
[nObs,nAss] = size(actual);
turnover    = nan(nObs-1,nAss);
pf_return   = nan(nObs,nAss);

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING WEIGHT TO THE RISKY ASSET
%-----------------------------------------------------------------------------------------------------------------------

% Computing risky asset weights
wrisk = (forecast./vol_forecast)./risk_aversion;

% Keeping portfolio weights within user specified bounds
if strcmp(bound_type,'Weights')

    wrisk(wrisk < lower_bound) = lower_bound; 
    wrisk(wrisk > upper_bound) = upper_bound;

end

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING AVERAGE UTILITY AND SHARPE RATIOS
%-----------------------------------------------------------------------------------------------------------------------

% Extend risk-free rate series to number of assets
risk_free  = repmat(risk_free,1,nAss);

% Computing portfolio returns and turnover
for tIndx = 1:nObs

    if tIndx < nObs

        % Computing evolution of wealth
        wealth_total_end_t  = 1 + risk_free(tIndx,:) + wrisk(tIndx,:).*actual(tIndx,:);
        wealth_risky_end_t  = wrisk(tIndx,:).*(1+risk_free(tIndx,:)+actual(tIndx,:));
        target_risky_end_t  = wrisk(tIndx+1,:).*wealth_total_end_t;

        % Computing portfolio turnover
        turnover(tIndx,:)   = abs(target_risky_end_t - wealth_risky_end_t)./wealth_total_end_t;

        % Computing portfolio return less transaction costs (if any)
        pf_return(tIndx,:)  = (1+risk_free(tIndx,:) + wrisk(tIndx,:).*actual(tIndx,:)).*(1-tc.*turnover(tIndx,:)) - 1;

    else
        
        % Computing portfolio return less transaction costs (if any)
        pf_return(tIndx,:)  = risk_free(tIndx,:) + wrisk(tIndx,:).*actual(tIndx,:);

    end

end

% Keeping returns within user specified bounds
if strcmp(bound_type,'Returns')

    pf_return(pf_return < lower_bound) = lower_bound; 
    pf_return(pf_return > upper_bound) = upper_bound;

end

% Computing average utilities, Sharpe ratios, and manipulation-proof performance measures
utility         = mean(pf_return) - 0.5*risk_aversion*var(pf_return);
pf_excess_ret   = pf_return - risk_free;
Sharpe          = mean(pf_excess_ret)./std(pf_excess_ret);
mppm            = (1/(1-risk_aversion)).*log(mean((exp(pf_return)./exp(risk_free)).^(1-risk_aversion)));

end

%-----------------------------------------------------------------------------------------------------------------------
% END OF FUNCTION
%-----------------------------------------------------------------------------------------------------------------------