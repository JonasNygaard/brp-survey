%% makeMacroFactors.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This script constructs the Ludvigson and Ng (2009): "Macro Factors in Bond Risk Premia" (LN) factor using a large
%   panel of macroeconomic data. The panel is slightly smaller than their original data set due to required all used 
%   variables to have vintage data available for the out-of-sample period. The panel is constructed using data from the 
%   ALFRED database available from the Federal Reserve Bank of St. Louis. The vintage panel for each macroeconomic 
%   fundamental has been constructed by cleaning the raw data such that only one vintage is available for each month, 
%   where the latest vintage in a given month is always chosen. For months without any vintages, we simply use the 
%   vintage from the previous month. This procedure ensures that we do not introduce any look-ahead bias in the data. 
%
%   The data spans the period from 1968:Q4 to 2014:Q4 to match the survey data. All data is aggregated to a quarterly 
%   frequency by sampling from the second month of each quarter. 
%
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

clear; clc; tStart = tic; close all; format shortg; c = clock; addpath('../')
disp('-------------------------------------------------------------------------------------');
disp('Running the makeMacroFactors.m script.'                                               );
fprintf('Code initiated at %.0f:%.0f on %.0f / %0.f - %0.f \n',c(4:5),c(3),c(2),c(1)        );
disp('-------------------------------------------------------------------------------------');

%-----------------------------------------------------------------------------------------------------------------------
%% LOADING DATA FROM MATFILES AND PRELIMINARY PROCESSING
%-----------------------------------------------------------------------------------------------------------------------

disp('Loading and preparing ALFRED data');

% Loading real-time data vintages
load('matfiles/BondData.mat');
load('matfiles/ALFRED.mat');

% Getting number of variables in ALFRED
nVar            = size(ALFRED,2);
cALFRED         = cell(1,nVar);
cALFRED_full    = cell(1,nVar);
ALFRED_monthly  = cell(1,nVar);

% Getting and augmenting ALFRED data with date vector
for iVar = 1:nVar

    dates                   = datevec(x2mdate(ALFRED{1,iVar}(:,1),0));      % Converting excel dating to Matlab dating
    cALFRED{1,iVar}         = [dates(:,1:3) ALFRED{1,iVar}(:,2:end)];       % Adding dates to data
    cALFRED_full{1,iVar}    = [dates(:,1:3) ALFRED{1,iVar}(:,end)];         % Setting up matrix of revised data
    ALFRED_monthly{1,iVar}  = [dates(:,1:2) ALFRED{1,iVar}(:,2:end)];

end

%-----------------------------------------------------------------------------------------------------------------------
%% TRANSFORMING THE MONTHLY PANEL TO A QUARTERLY FREQUENCY
%-----------------------------------------------------------------------------------------------------------------------
%{
    We transform the monthly panel to a quarterly panel by sampling from the second month of each quarter to match 
    macroeconomic fundamentals with the timing of the SPF responses, see Bansal and  Shaliastovich (2013). 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Transforming the monthly panel to a quarterly frequency');

% Transforming the monthly panel to a quarterly frequency
for iVar = 1:nVar

    cALFRED{1,iVar}         =  cALFRED{1,iVar}(2:3:end-10,[1:3 14:3:end]);
    cALFRED_full{1,iVar}    =  cALFRED_full{1,iVar}(2:3:end-10,[1:3 end]);

end

%-----------------------------------------------------------------------------------------------------------------------
%% ESTIMATING THE FULL SAMPLE LN FACTOR
%-----------------------------------------------------------------------------------------------------------------------
%{
    We generally follow the procedure outlines in Ludvigson and Ng (2009) quite closely in our construction of our 
    variant of the latent-macro-based single factor. In particular, we transform all variables in the panel to be 
    covariance stationary using a set of transformation codes that follows those in the FRED-MD database (see McCracken
    and Ng (2015)) when applicable. We then estimate the factors using the factor model of Stock and Watson (2002) and 
    determine the optimal number of factors using the Bai and Ng (2002) panel information criterion. 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Estimating the full sample LN factor');

% Preallocation
cDates_full = cell(1,nVar);

% Picking out observations to match the full sample period
for iVar = 1:nVar

    cDates_full{1,iVar}     = cALFRED_full{1,iVar}(end-185:end,1:3);
    cALFRED_full{1,iVar}    = cALFRED_full{1,iVar}(end-185:end,end);

end

% Verifying that observations are observed at same dates
for iVar = 1:nVar

    if ~isequal(cDates_full{1,1},cDates_full{1,iVar})

        fprintf('Error in variable no.: %.0f\n',iVar);
        error('Mismatch in dates');

    end

end

% Preallocations for full sample factor estimation
mPanel_full = cell2mat(cALFRED_full);
mTransform  = NaN(size(mPanel_full));

% Transforming variables according to transformation codes
for iVar = 1:nVar

    tmp = transx(mPanel_full(:,iVar),tcode(iVar));
    mTransform(:,iVar) = tmp;

end

% Estimating the latent common factors
mTransform      = mTransform(6:end,:);
mFactors_full   = pc_T(mTransform,8,'Full');

% Estimating the full sample LN factor
xln_full        = [mFactors_full(:,1) mFactors_full(:,5).^2  mFactors_full(:,1).^3];
ln_parm         = linear_reg(rxbarFB,xln_full,1,'HH',4);
LN              = [ones(size(xln_full,1),1) xln_full]*ln_parm;

%-----------------------------------------------------------------------------------------------------------------------
%% ESTIMATING LATENT COMMON FACTORS RECURSIVELY USING AN EXPANDING WINDOW OF OBSERVATIONS
%-----------------------------------------------------------------------------------------------------------------------

disp('Estimating latent common factors recursively using an expanding window of observations');

% Setting up preliminaries
tIndx           = 84;
nVin            = size(cALFRED{1,1},2)-4;
cDates_loop     = cell(1,nVar);
cALFRED_loop    = cell(1,nVar);
cFactors        = cell(1,nVin);
cLN             = cell(1,nVin);

for iVin = 1:nVin

    tIndx = tIndx + 1;
    tcode_loop  = tcode;

    % Picking out observations to match the full sample period
    for iVar = 1:nVar

        cDates_loop{1,iVar}     = cALFRED{1,iVar}(~isnan(cALFRED{1,iVar}(:,3+iVin)),1:3);
        cALFRED_loop{1,iVar}    = cALFRED{1,iVar}(~isnan(cALFRED{1,iVar}(:,3+iVin)),[1:3 3+iVin]);

    end

    % Eliminating variables with insufficient observations for factor estimation
    for iVar = 1:nVar

        if ismember(iVin,1:17) && iVar == 6

            cALFRED_loop{1,iVar}    = [];
            tcode_loop(iVar)        = [];

        elseif iVin == 100 && iVar == 55

            cALFRED_loop{1,iVar}    = [];
            tcode_loop(iVar)        = [];

        else

            cDates_loop{1,iVar} = cALFRED_loop{1,iVar}(end-3-tIndx+1:end-3,1:3);
            cALFRED_loop{1,iVar} = cALFRED_loop{1,iVar}(end-3-tIndx+1:end-3,4);

        end

    end

    % Preallocations
    mPanel_loop = cell2mat(cALFRED_loop(1,:));
    mTransform  = NaN(size(mPanel_loop));

    % Transforming variables according to transformation codes
    for iVar = 1:size(mPanel_loop,2)

        tmp = transx(mPanel_loop(:,iVar),tcode(iVar));
        mTransform(:,iVar) = tmp;

    end

    % Estimating the latent common factors
    mTransform          = mTransform(4:end,:);
    cFactors{1,iVin}    = pc_T(mTransform,8,'Full');

    % Estimating the LN factor while keeping the composition of variables fixes
    xln_loop    = [cFactors{1,iVin}(:,1) cFactors{1,iVin}(:,5).^2 cFactors{1,iVin}(:,1).^3];
    alpha_loop  = linear_reg(rxbarFB(1:tIndx-4,1),xln_loop(1:end-1,:),1,'Skip',4);
    cLN{1,iVin} = [ones(size(xln_loop,1),1) xln_loop] * alpha_loop;

end

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING THE ROLLING OUT-OF-SAMPLE LUDVIGSON-NG (LN) MACRO FACTOR
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating the rolling out-of-sample (real-time) Ludvigson-Ng (LN) macro factor');

% Setting up preliminaries and preallocations
tIndx       = 81;
rol_window  = 80;
cLN_rol     = cell(1,nVin);

% Looping over vintages
for iVin = 1:nVin

    tIndx       = tIndx + 1;
    xln_loop    = [cFactors{1,iVin}(:,1) cFactors{1,iVin}(:,5).^2 cFactors{1,iVin}(:,1).^3];
    xln_loop    = xln_loop(tIndx-rol_window:tIndx,:);

    % Estimating the ME factor out-of-sample
    alpha_loop      = linear_reg(rxbarFB(tIndx-rol_window:tIndx-1,:),xln_loop(1:end-1,:),1,'Skip',4);
    cLN_rol{1,iVin} = [ones(rol_window+1,1) xln_loop]*alpha_loop;

end

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING THE FULL SAMPLE LN FACTOR FOR GSW BOND DATA
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating the full sample LN factor for the GSW bond data');

% Estimating the full sample LN factor using GSW bond data
xln_full    = [mFactors_full(:,1) mFactors_full(:,5).^2  mFactors_full(:,1).^3];
ln_parm     = linear_reg(rxbarGSW,xln_full,1,'HH',4);
LN_gsw      = [ones(size(xln_full,1),1) xln_full]*ln_parm;

%-----------------------------------------------------------------------------------------------------------------------
%% SAVING RELEVANT VARIABLES
%-----------------------------------------------------------------------------------------------------------------------

save('matfiles/MacroFactors.mat','LN','cLN','cLN_rol','LN_gsw','cFactors');
save('matfiles/ALFRED_monthly.mat','ALFRED_monthly');

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING CODE RUN TIME
%-----------------------------------------------------------------------------------------------------------------------

tEnd = toc(tStart); rmpath('../')
fprintf('Runtime: %d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));
disp('Routine Completed');

%-----------------------------------------------------------------------------------------------------------------------
% END OF SCRIPT
%-----------------------------------------------------------------------------------------------------------------------