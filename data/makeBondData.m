%% makeBondData.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This script constructs annual log excess holding period bond returns using the methodology in Cochrane and Piazzesi 
%   (2005): "Bond Risk Premia". The main part of the paper uses the Fama and Bliss (1987) bond data available from the 
%   Center for Research in Security Prices (CRSP). As a robustness check, we further construct quarterly excess holding
%   period returns using the Gurkaynak, Sack, and Wright bond data series. 
%
%   The data span a period starting in 1968:Q4 and ending in 2014:Q4, which is mainly determined by the availability of
%   survey forecasts from the Survey of Professional Forecasters. All data is aggregated to a quarterly frequency by 
%   sampling from the second month of each quarter. 
%ßß
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

clear; clc; tStart = tic; close all; format shortg; c = clock; addpath('../')
disp('-------------------------------------------------------------------------------------');
disp('Running the makeBondData.m script.'                                                   );
fprintf('Code initiated at %.0f:%.0f on %.0f / %0.f - %0.f \n',c(4:5),c(3),c(2),c(1)        );
disp('-------------------------------------------------------------------------------------');

%-----------------------------------------------------------------------------------------------------------------------
%% LOADING DATA FROM MATFILES
%-----------------------------------------------------------------------------------------------------------------------

disp('Reading in bond price data');

% Loading bond data
load('matfiles/FB.mat');
load('matfiles/GSW.mat');

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING EXCESS HOLDING PERIOD BOND RETURNS
%-----------------------------------------------------------------------------------------------------------------------
%{
    We compute annual holding period excess bond returns using the methodology from Cochrane and Piazzesi (2005) and 
    Ludvigson and Ng (2009). This entails following a simple trading strategy by buying an n-year bond today at time t
    and selling it as an n-1 year bond one-year hence. 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating excess holding period bond returns');

% Generating annual excess holding period bond returns
mFB     = mFB(198:3:end,:);                                                     % Adapting to quarterly sample
yFB     = -log(mFB(:,2:end)./100).*(ones(size(mFB,1),1)*[1/1 1/2 1/3 1/4 1/5]); % Log bond yield
pFB     = -(ones(size(mFB,1),1)*[1 2 3 4 5]).*yFB;                              % Log bond prices
fFB     = pFB(:,1:4) - pFB(:,2:5);                                              % Log one-year forward rates
fsFB    = fFB - repmat(yFB(:,1),1,4);                                           % Log forward-spot spreads
rFB     = pFB(5:end,1:4) - pFB(1:end-4,2:5);                                    % Annual holding period returns
rxFB    = (rFB - repmat(yFB(1:end-4,1),1,4)).*100;                              % Annual excess holding period returns
rxbarFB = mean(rxFB,2);                                                         % Mean excess returns across maturities

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING THE FULL SAMPLE TENT-SHAPED FORWARD-RATE FACTOR FROM COCHRANE & PIAZZESI (2005)
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating the full-sample Cochrane-Piazzesi (2005) forward rate factor');

% Estimating the CP factor in-sample
ftFB    = [yFB(1:end-4,1) fFB(1:end-4,:)].*100;
cp_parm = linear_reg(rxbarFB,ftFB,1,'HH',4);
CP      = [ones(size(ftFB,1),1) ftFB] * cp_parm;

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING THE RECURSIVE OUT-OF-SAMPLE COCHRANE-PIAZZESI (CP) FACTOR
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating the recursive out-of-sample (real-time) CP factor');

% Setting up preliminaries
tIndx       = 81;
nVin        = 100;
cCP         = cell(1,nVin);

% Looping over time periods
for iVin = 1:nVin

    % Setting up variables
    tIndx       = tIndx + 1;
    xcp_loop    = [yFB(1:tIndx,1) fFB(1:tIndx,:)].*100;

    % Estimating the CP factors out-of-sample
    lambda_loop = linear_reg(rxbarFB(1:tIndx-1,1),xcp_loop(1:end-1,:),1,'Skip',4);
    cCP{1,iVin} = [ones(size(xcp_loop,1),1) xcp_loop]*lambda_loop;

end

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING THE ROLLING OUT-OF-SAMPLE COCHRANE-PIAZZESI (CP) FACTOR
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating the rolling out-of-sample (real-time) CP factor');

% Setting up preliminaries
tIndx       = 81;
rol_window  = 80;
nVin        = 100;
cCP_rol     = cell(1,nVin);

% Looping over time periods
for iVin = 1:nVin

    % Setting up variables
    tIndx           = tIndx + 1;
    xcp_loop        = [yFB(tIndx-rol_window:tIndx,1) fFB(tIndx-rol_window:tIndx,:)].*100;

    % Estimating the CP factors out-of-sample
    lambda_loop     = linear_reg(rxbarFB(tIndx-rol_window:tIndx-1,1),xcp_loop(1:end-1,:),1,'Skip',4);
    cCP_rol{1,iVin} = [ones(rol_window+1,1) xcp_loop]*lambda_loop;

end

%-----------------------------------------------------------------------------------------------------------------------
% GENERATING LEVEL, SLOPE, AND CURVATURE FACTORS (LITTERMAN & SCHEINKMAN, 1991)
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating slope, level, and curvature factors');

% Computing the principal components of the yield covariance matrix
pc_yields   = pca_eig(yFB.*100,5,'No');

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING QUARTERLY HOLDING PERIOD RETURNS USING GSW BOND DATA
%-----------------------------------------------------------------------------------------------------------------------
%{
    As a robustness check on the main results, we also consider a set of results based on using bond risk premia over a
    shorter holding period. In particular, we consider quarterly bond risk premia, which is the highest frequency 
    permitted by the response frequency of the SPF survey forecasts. We re-construct the daily yield curve using the 
    parameter estimates from Gurkaynak, Sack, and Wright (2007) and convert to quarterly yields by sampling from the 
    last day of the second month of each quarter. We then quarterly bond risk premia by buying an n-year bond today and 
    selling it after one quarter as an n-1/4 year bond. 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating quarterly bond excess returns using GSW bond data');

% Setting up preliminaries
gswParm             = mGSW(:,97:end);                       % Picking out GSW parameter values
indx_tau2           = find(gswParm == -999.99);             % Locate missing values in the data set
gswParm(indx_tau2)  = 0;                                    % Set tau_2 equal to zero for first part of sample
yields_gsw          = NaN(size(gswParm,1),17);              % Computing yields using GSW parameters and models
iCol                = 0;                                    % Initialize index for looping procedure
maturities          = 1:1/4:5;                              % Setting quarterly maturities

% Computing log bond yields
for mat = 1:1/4:5

    % Indexing the columns
    iCol = iCol + 1;

    for tIndx = 1:size(gswParm,1)

        % Constructing the daily yield curve using the Nelson-Siegel (1987) and Svensson (1994) framework
        yields_gsw(tIndx,iCol)  = ...
            gswParm(tIndx,1) + ...
            gswParm(tIndx,2)*((1-exp(-mat/gswParm(tIndx,5)))/(mat/gswParm(tIndx,5))) + ...
            gswParm(tIndx,3)*((1-exp(-mat/gswParm(tIndx,5)))/(mat/gswParm(tIndx,5)) - exp(-mat/gswParm(tIndx,5))) + ...
            gswParm(tIndx,4)*((1-exp(-mat/gswParm(tIndx,6)))/(mat/gswParm(tIndx,6)) - exp(-mat/gswParm(tIndx,6)) ...
        );

    end

end

% Adapting daily yields to our quarterly frequency
yields_gsw  = [mGSW(:,1:3) yields_gsw];                                     % Adding date matrix to yield matrix
yields_gsw  = yields_gsw(yields_gsw(2:end,2) ~= yields_gsw(1:end-1,2),:);   % Picking out observations at month's end
yGSW        = [yields_gsw(90:3:end,1:3) yields_gsw(90:3:end,4:end)./100];   % and then second month of each quarter

% Generating quarterly excess holding period bond returns
pGSW        = -(ones(size(yGSW,1),1)*maturities).*yGSW(:,4:end);            % Log bond prices
fGSW        = pGSW(:,1:end-1) - pGSW(:,2:end);                              % Log quarterly forward rates
rGSW        = pGSW(2:end,1:end-1) - pGSW(1:end-1,2:end);                    % Quarterly holding period returns
rxGSW       = rGSW(:,4:4:end) - repmat(tbill(30:end-1,:)./4,1,4);           % Excess holding period returns
rxbarGSW    = mean(rxGSW,2);                                                % Mean excess returns across maturities

% Estimating the CP factor for GSW bond data
ftGSW       = [yGSW(1:end-4,1) fGSW(1:end-4,4:4:end)].*100;
cp_parm     = linear_reg(rxbarGSW(1:end-3,:),ftGSW,1,'HH',4);
CP_gsw      = [ones(size(ftGSW,1),1) ftGSW] * cp_parm;

% Adapting GSW bonds for the sample
rxbarGSW    = rxbarGSW(1:end-3,:);
rxGSW       = rxGSW(1:end-3,:);

%-----------------------------------------------------------------------------------------------------------------------
%% SAVING RELEVANT VARIABLES
%-----------------------------------------------------------------------------------------------------------------------

save('matfiles/BondData.mat','CP','ftFB','rxFB','rxbarFB','yFB','pc_yields','cCP','cCP_rol',...
    'ftGSW','CP_gsw','rxGSW','rxbarGSW');

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING CODE RUN TIME
%-----------------------------------------------------------------------------------------------------------------------

tEnd = toc(tStart); rmpath('../')
fprintf('Runtime: %d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));
disp('Routine Completed');

%-----------------------------------------------------------------------------------------------------------------------
% END OF SCRIPT
%-----------------------------------------------------------------------------------------------------------------------