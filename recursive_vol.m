function volatility = recursive_vol(returns,vol_estimator,initialization_window,rolling_window_length)

%% recursive_vol.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This function computes out-of-sample return volatility of input returns based on a user-specified estimation method. 
%
%   Input:
%   ---------------------------------------------------------------------------------
%   returns                 = T x N matrix of (portfolio) returns
%   vol_estimator           = 'rec' for recursive, 'rol' for rolling window, 'ewa' for exponentially-weighted average
%   initialization_window   = Length of initialization period to compute volatility
%   window_lenght:          = Length of rolling window
%
%   Output
%   ---------------------------------------------------------------------------------
%   volatility              = T x N matrix of rolling volatilities
%
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

% Error checking
if (isempty(returns) == 1)
    error('recursive_vol.m: Matrix of (portfolio) returns is empty');
end

if (~ismember(vol_estimator,[{'rec'},{'rol'},{'ewa'}]))
    error('recursive_vol.m: Wrong volatility estimation method specified');
end

if (nargin < 2)
    error('recursive_vol.: Not enough input parameters');
end

if (nargin > 4)
    error('recursive_vol.m: Too many input parameters');
end

% Setting defaults
if (nargin < 3)
    initialization_window = 12;
end

if (nargin < 4) && strcmp(vol_estimator,'rol')
    error('recursive_vol.m: Length of rolling window unspecified');
elseif (nargin < 4) && ~strcmp(vol_estimator,'rol')
    rolling_window_length = inf;
end

%-----------------------------------------------------------------------------------------------------------------------
%% SETTING PRELIMINARIES
%-----------------------------------------------------------------------------------------------------------------------

% Setting dimension of data
[nObs,nAssets]  = size(returns);

% Preallocate for loop
volatility      = NaN(nObs,nAssets);

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING ROLLING VOLALITY
%-----------------------------------------------------------------------------------------------------------------------

if strcmp(vol_estimator,'rol')

    for iObs = 1:nObs

        if iObs < rolling_window_length

            volatility(iObs,:) = nanstd(returns(1:iObs,:),[],1);

        else

            volatility(iObs,:) = nanstd(returns(iObs-rolling_window_length+1:iObs,:));

        end

    end

end

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING RECURSIVE VOLALITY
%-----------------------------------------------------------------------------------------------------------------------

if strcmp(vol_estimator,'rec')

    for iObs = 1:nObs

        volatility(iObs,:) = nanstd(returns(1:iObs,:),[],1);

    end

end

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING ROLLING VOLALITY
%-----------------------------------------------------------------------------------------------------------------------

if strcmp(vol_estimator,'ewa')

    % Setting weight parameter and preallocation
    lambda          = 0.96;
    lambda_weights  = NaN(nObs,1);

    % Constructing exponentially declining weights
    for iObs = 1:nObs

        lambda_weights(iObs,:) = lambda^(iObs-1);

    end

    % Constructing exponential moving average volatility measure
    for iObs = 1:nObs

        % Pick out weights corresponding to the window
        weights_t = lambda_weights(1:iObs);
        weights_t = flip(weights_t);

        % Exponentially weighted moving average
        ewma_t(iObs,:) = ((1-lambda)./(1-lambda^(iObs))).*nan_sum(repmat(weights_t,1,nAssets).*(returns(1:iObs,:)));

        % Compute the exponentially weighted moving average volatility
        volatility(iObs,:) = nan_sum(repmat(weights_t,1,nAssets).*(returns(1:iObs,:)-repmat(ewma_t(iObs,:),iObs,1)).^2);
        volatility(iObs,:) = sqrt(((1-lambda)./(1-lambda^(iObs))).*volatility(iObs,:));

    end

end

%-----------------------------------------------------------------------------------------------------------------------
%% FIXING THE INITIALIZATION PERIOD
%-----------------------------------------------------------------------------------------------------------------------

for iAsset = 1:nAssets

    volatility(volatility(:,iAsset) == 0,iAsset) = NaN;
    nan_indx = isnan(volatility(:,iAsset));

    if sum(nan_indx) ~= nObs

        last_nan_indx = find(isnan(volatility(:,iAsset)),1,'last');

        if ~isempty(last_nan_indx) && (last_nan_indx == 1)

            volatility(1:initialization_window,iAsset) = NaN;

        elseif (last_nan_indx > 1) && (last_nan_indx < nObs)

            volatility(last_nan_indx:last_nan_indx+initialization_window-1,iAsset) = NaN;

        end

    end

end

end

%-----------------------------------------------------------------------------------------------------------------------
%% END OF FUNCTION
%-----------------------------------------------------------------------------------------------------------------------