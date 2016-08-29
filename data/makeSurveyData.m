%% makeSurveyData
%-----------------------------------------------------------------------------------------------------------------------
%
%   This script constructs the term structure of survey-based expectations to future changes in a set of macroeconomic
%   fundamentals. Data are obtained from the Survey of Professional Forecasters (SPF) available at the Federal Reserve
%   Bank of Philadelphia. 
%
%   The data span a period starting in 1968:Q4 and ending in 2014:Q4, which is mainly determined by the availability of
%   survey forecasts from the Survey of Professional Forecasters. All data is aggregated to a quarterly frequency by 
%   sampling from the second month of each quarter. 
%
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

clear; clc; tStart = tic; close all; format shortg; c = clock; addpath('../')
disp('-------------------------------------------------------------------------------------');
disp('Running the makeSurveyData.m script.'                                                 );
fprintf('Code initiated at %.0f:%.0f on %.0f / %0.f - %0.f \n',c(4:5),c(3),c(2),c(1)        );
disp('-------------------------------------------------------------------------------------');

%-----------------------------------------------------------------------------------------------------------------------
%% LOADING DATA FROM MATFILES AND PRELIMINARY PROCESSING
%-----------------------------------------------------------------------------------------------------------------------

disp('Loading data from Survey of Professional Forecasters (SPF)');

% Loading individual response data
load('matfiles/SPF.mat');
load('matfiles/BondData.mat');

% Creating datenum index for plotting
datenum_indx    = datenum({'01-Jan-1968';'02-Jan-2015'});
datevec_indx    = datevec(datenum_indx(1):1:datenum_indx(2));
datevec_indx    = datevec_indx(datevec_indx(2:end,2) ~= datevec_indx(1:end-1,2),1:3);
datevec_indx    = datevec_indx(11:3:end,:);
datenum_indx    = datenum(datevec_indx);

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING EXPECTED GROWTH RATES FROM NOWCAST AND FORECASTS FOR LEVELS FROM SPF
%-----------------------------------------------------------------------------------------------------------------------
%{
    We compute one- through four-quarter ahead log growth forecast using the individual forecaster's nowcast as the 
    base. We then aggregate individual log growth forecast into a median consensus forecast for each fundamental and 
    each forecast horizon. 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating expected growth rates from SPF data');

% Preallocations for loop procedure
cNGDP       = repmat({NaN(185,580)},1,4);
cRGDP       = repmat({NaN(185,580)},1,4);
cPGDP       = repmat({NaN(185,580)},1,4);
cCPROF      = repmat({NaN(185,580)},1,4);
cUNEMP      = repmat({NaN(185,580)},1,4);
cINDPROD    = repmat({NaN(185,580)},1,4);
cHOUSING    = repmat({NaN(185,580)},1,4);

% Looping over entries for forecasters and time periods
for iEntry = 1:size(mRGDP,1);

    % Computing one-quarter ahead forecasts
    cNGDP{1,1}(mNGDP(iEntry,3),mNGDP(iEntry,4))             = 100.*log(mNGDP(iEntry,8)./mNGDP(iEntry,7));
    cRGDP{1,1}(mRGDP(iEntry,3),mRGDP(iEntry,4))             = 100.*log(mRGDP(iEntry,8)./mRGDP(iEntry,7));
    cPGDP{1,1}(mPGDP(iEntry,3),mPGDP(iEntry,4))             = 100.*log(mPGDP(iEntry,8)./mPGDP(iEntry,7));
    cCPROF{1,1}(mCPROF(iEntry,3),mCPROF(iEntry,4))          = 100.*log(mCPROF(iEntry,8)./mCPROF(iEntry,7));
    cINDPROD{1,1}(mINDPROD(iEntry,3),mINDPROD(iEntry,4))    = 100.*log(mINDPROD(iEntry,8)./mINDPROD(iEntry,7));
    cHOUSING{1,1}(mHOUSING(iEntry,3),mHOUSING(iEntry,4))    = 100.*(mHOUSING(iEntry,8) - mHOUSING(iEntry,7));
    cUNEMP{1,1}(mUNEMP(iEntry,3),mUNEMP(iEntry,4))          = 100.*log(mUNEMP(iEntry,8)./mUNEMP(iEntry,7));

    % Computing two-quarter ahead forecasts
    cNGDP{1,2}(mNGDP(iEntry,3),mNGDP(iEntry,4))             = 100.* log(mNGDP(iEntry,9)./mNGDP(iEntry,7));
    cRGDP{1,2}(mRGDP(iEntry,3),mRGDP(iEntry,4))             = 100.* log(mRGDP(iEntry,9)./mRGDP(iEntry,7));
    cPGDP{1,2}(mPGDP(iEntry,3),mPGDP(iEntry,4))             = 100.* log(mPGDP(iEntry,9)./mPGDP(iEntry,7));
    cCPROF{1,2}(mCPROF(iEntry,3),mCPROF(iEntry,4))          = 100.* log(mCPROF(iEntry,9)./mCPROF(iEntry,7));
    cINDPROD{1,2}(mINDPROD(iEntry,3),mINDPROD(iEntry,4))    = 100.* log(mINDPROD(iEntry,9)./mINDPROD(iEntry,7));
    cHOUSING{1,2}(mHOUSING(iEntry,3),mHOUSING(iEntry,4))    = 100.*(mHOUSING(iEntry,9) - mHOUSING(iEntry,7));
    cUNEMP{1,2}(mUNEMP(iEntry,3),mUNEMP(iEntry,4))          = 100.* log(mUNEMP(iEntry,9)./mUNEMP(iEntry,7));

    % Computing three-quarter ahead forecasts
    cNGDP{1,3}(mNGDP(iEntry,3),mNGDP(iEntry,4))             = 100.*log(mNGDP(iEntry,10)./mNGDP(iEntry,7));
    cRGDP{1,3}(mRGDP(iEntry,3),mRGDP(iEntry,4))             = 100.*log(mRGDP(iEntry,10)./mRGDP(iEntry,7));
    cPGDP{1,3}(mPGDP(iEntry,3),mPGDP(iEntry,4))             = 100.*log(mPGDP(iEntry,10)./mPGDP(iEntry,7));
    cCPROF{1,3}(mCPROF(iEntry,3),mCPROF(iEntry,4))          = 100.*log(mCPROF(iEntry,10)./mCPROF(iEntry,7));
    cINDPROD{1,3}(mINDPROD(iEntry,3),mINDPROD(iEntry,4))    = 100.*log(mINDPROD(iEntry,10)./mINDPROD(iEntry,7));
    cHOUSING{1,3}(mHOUSING(iEntry,3),mHOUSING(iEntry,4))    = 100.*(mHOUSING(iEntry,10) - mHOUSING(iEntry,7));
    cUNEMP{1,3}(mUNEMP(iEntry,3),mUNEMP(iEntry,4))          = 100.*log(mUNEMP(iEntry,10)./mUNEMP(iEntry,7));

    % Computing four-quarter ahead forecasts
    cNGDP{1,4}(mNGDP(iEntry,3),mNGDP(iEntry,4))             = 100.*log(mNGDP(iEntry,11)./mNGDP(iEntry,7));
    cRGDP{1,4}(mRGDP(iEntry,3),mRGDP(iEntry,4))             = 100.*log(mRGDP(iEntry,11)./mRGDP(iEntry,7));
    cPGDP{1,4}(mPGDP(iEntry,3),mPGDP(iEntry,4))             = 100.*log(mPGDP(iEntry,11)./mPGDP(iEntry,7));
    cCPROF{1,4}(mCPROF(iEntry,3),mCPROF(iEntry,4))          = 100.*log(mCPROF(iEntry,11)./mCPROF(iEntry,7));
    cINDPROD{1,4}(mINDPROD(iEntry,3),mINDPROD(iEntry,4))    = 100.*log(mINDPROD(iEntry,11)./mINDPROD(iEntry,7));
    cHOUSING{1,4}(mHOUSING(iEntry,3),mHOUSING(iEntry,4))    = 100.*(mHOUSING(iEntry,11) - mHOUSING(iEntry,7));
    cUNEMP{1,4}(mUNEMP(iEntry,3),mUNEMP(iEntry,4))          = 100.*log(mUNEMP(iEntry,11)./mUNEMP(iEntry,7));

end

% Constructing time-series of number of participating forecasters 
countNGDP           = sum(~isnan(cNGDP{1,1}),2);
countRGDP           = sum(~isnan(cRGDP{1,1}),2);
countPGDP           = sum(~isnan(cPGDP{1,1}),2);
countCPROF          = sum(~isnan(cCPROF{1,1}),2);
countUNEMP          = sum(~isnan(cUNEMP{1,1}),2);
countINDPROD        = sum(~isnan(cINDPROD{1,1}),2);
countHOUSING        = sum(~isnan(cHOUSING{1,1}),2);

% Computing the overall average of participating forecasters
avg_countNGDP       = mean(countNGDP(countNGDP ~= 0,:));
avg_countRGDP       = mean(countRGDP(countRGDP ~= 0,:));
avg_countPGDP       = mean(countPGDP(countPGDP ~= 0,:));
avg_countCPROF      = mean(countCPROF(countCPROF ~= 0,:));
avg_countUNEMP      = mean(countUNEMP(countUNEMP ~= 0,:));
avg_countINDPROD    = mean(countINDPROD(countINDPROD ~= 0,:));
avg_countHOUSING    = mean(countHOUSING(countHOUSING ~= 0,:));

%-----------------------------------------------------------------------------------------------------------------------
%% PLOTTING FORECASTER PARTICIPATION
%-----------------------------------------------------------------------------------------------------------------------

disp('Plotting forecaster participation');

% Make index of participating forecasters
participating_forecasters   = ~isnan(cRGDP{1,1});
nForecasters                = size(participating_forecasters,2);
empty_columns_indx          = NaN(1,250);
j_indx                      = 0;

% Find empty columns
for iCol = 1:nForecasters

    if nansum(participating_forecasters(:,iCol)) == 0
        
        j_indx                          = j_indx + 1;
        empty_columns_indx(1,j_indx)    = iCol;

    end

end

% Remove forecasters with no entries
participating_forecasters(:,empty_columns_indx) = [];
line_color = color_brewer(1);

% Plot figure
figure;
spy(participating_forecasters,'.r');
xlabel('Forecaster ID');
ylabel('Time');
markerH = findall(gca,'color','r');
set(markerH,'MarkerFaceColor',line_color(1,:),'MarkerEdgeColor',line_color(1,:));
ax = gca;
ax.YTick = 4:18:185;
ax.YTickLabel = datevec_indx(4:18:end,1);
box on
set(gcf, 'PaperUnits', 'Centimeters','PaperSize',[19 15],'PaperPosition',[0.5 0.5 18 14]);
print(gcf,'-depsc','-painters','../TeX/Figures/e_participating_forecasters.eps');

%-----------------------------------------------------------------------------------------------------------------------
%% AGGREGATING INDIVIDUAL FORECASTS INTO A MEDIAN CONSENSUS FORECASTS
%-----------------------------------------------------------------------------------------------------------------------
%{
    Due to the entry and exist of forecasters during our sample period, we simply aggregate all individual growth 
    expectations into a single median consensus forecasts using all participating forecasters at time t. 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Aggregating individual forecasts to median consensus forecast');

% Preallocations for loop
medNGDP     = cell(1,4);
medRGDP     = cell(1,4);
medPGDP     = cell(1,4);
medCPROF    = cell(1,4);
medUNEMP    = cell(1,4);
medINDPROD  = cell(1,4);
medHOUSING  = cell(1,4);

% Computing median growth rates for one-quarter ahead forecasts
for iHorizon = 1:4

    medNGDP{1,iHorizon}     = nanmedian(cNGDP{1,iHorizon},2);
    medRGDP{1,iHorizon}     = nanmedian(cRGDP{1,iHorizon},2);
    medPGDP{1,iHorizon}     = nanmedian(cPGDP{1,iHorizon},2);
    medCPROF{1,iHorizon}    = nanmedian(cCPROF{1,iHorizon},2);
    medUNEMP{1,iHorizon}    = nanmedian(cUNEMP{1,iHorizon},2);
    medINDPROD{1,iHorizon}  = nanmedian(cINDPROD{1,iHorizon},2);
    medHOUSING{1,iHorizon}  = nanmedian(cHOUSING{1,iHorizon},2);

end

%-----------------------------------------------------------------------------------------------------------------------
%% IMPUTING MISSING DATA USING LINEAR INTERPOLATION
%-----------------------------------------------------------------------------------------------------------------------
%{
    There are a few missing observations in the data set from the SPF, mainly in the beginning of the sample period. 
    We deal with this in a simple manner using simple linear interpolation.
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Imputing missing values');

% Imputing missing values
int_type        = 'linear';
nobs            = size(medNGDP{1,4},1);
medNGDP{1,4}    = interp1(find(~isnan(medNGDP{1,4})),medNGDP{1,4}(~isnan(medNGDP{1,4}),1),1:nobs,int_type)';
medRGDP{1,4}    = interp1(find(~isnan(medRGDP{1,4})),medRGDP{1,4}(~isnan(medRGDP{1,4}),1),1:nobs,int_type)';
medPGDP{1,4}    = interp1(find(~isnan(medPGDP{1,4})),medPGDP{1,4}(~isnan(medPGDP{1,4}),1),1:nobs,int_type)';
medCPROF{1,4}   = interp1(find(~isnan(medCPROF{1,4})),medCPROF{1,4}(~isnan(medCPROF{1,4}),1),1:nobs,int_type)';
medUNEMP{1,4}   = interp1(find(~isnan(medUNEMP{1,4})),medUNEMP{1,4}(~isnan(medUNEMP{1,4}),1),1:nobs,int_type)';
medINDPROD{1,4} = interp1(find(~isnan(medINDPROD{1,4})),medINDPROD{1,4}(~isnan(medINDPROD{1,4}),1),1:nobs,int_type)';
medHOUSING{1,4} = interp1(find(~isnan(medHOUSING{1,4})),medHOUSING{1,4}(~isnan(medHOUSING{1,4}),1),1:nobs,int_type)';

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING THE FULL SAMPLE MACROECONOMIC EXPECTATIONS (ME) FACTOR
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating the full sample Macroeconomic Expectations (ME) factor');

% Collecting all variables for PC estimation
mSurvey = [
    medNGDP{1,1} medPGDP{1,1} medCPROF{1,1} medUNEMP{1,1} medINDPROD{1,1} medHOUSING{1,1} ...
    medNGDP{1,2} medPGDP{1,2} medCPROF{1,2} medUNEMP{1,2} medINDPROD{1,2} medHOUSING{1,2} ...
    medNGDP{1,3} medPGDP{1,3} medCPROF{1,3} medUNEMP{1,3} medINDPROD{1,3} medHOUSING{1,3} ...
    medNGDP{1,4} medPGDP{1,4} medCPROF{1,4} medUNEMP{1,4} medINDPROD{1,4} medHOUSING{1,4} ...
];

% Estimating principal components
[pc_survey,loadings,var_explained]          = pca_eig(mSurvey(1:end-4,:),3,'Yes');
[pc_survey_1q,loadings_1q,var_explained_1q] = pca_eig(mSurvey(1:end-4,1:6),3,'Yes');
[pc_survey_2q,loadings_2q,var_explained_2q] = pca_eig(mSurvey(1:end-4,7:12),3,'Yes');
[pc_survey_3q,loadings_3q,var_explained_3q] = pca_eig(mSurvey(1:end-4,13:18),3,'Yes');
[pc_survey_4q,loadings_4q,var_explained_4q] = pca_eig(mSurvey(1:end-4,19:24),3,'Yes');

% Estimating the Macroeconomic Expectations (ME) factor
alpha       = linear_reg(rxbarFB,pc_survey,1,'HH',4);
alpha_1q    = linear_reg(rxbarFB,pc_survey_1q,1,'HH',4);
alpha_2q    = linear_reg(rxbarFB,pc_survey_2q,1,'HH',4);
alpha_3q    = linear_reg(rxbarFB,pc_survey_3q,1,'HH',4);
alpha_4q    = linear_reg(rxbarFB,pc_survey_4q,1,'HH',4);

ME          = [ones(size(pc_survey,1),1) pc_survey] * alpha;
ME_1q       = [ones(size(pc_survey_1q,1),1) pc_survey_1q] * alpha_1q;
ME_2q       = [ones(size(pc_survey_2q,1),1) pc_survey_2q] * alpha_2q;
ME_3q       = [ones(size(pc_survey_3q,1),1) pc_survey_3q] * alpha_3q;
ME_4q       = [ones(size(pc_survey_4q,1),1) pc_survey_4q] * alpha_4q;


%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING THE RECURSIVE OUT-OF-SAMPLE MACROECONOMIC EXPECTATIONS (ME) FACTOR
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating the recursive out-of-sample (real-time) Macroeconomic Expectations (ME) factor');

% Setting up preliminaries and preallocations
tIndx       = 81;
nVin        = 100;
cME         = cell(1,nVin);

% Looping over vintages
for iVin = 1:nVin

    tIndx       = tIndx + 1;
    xme_loop    = pca_eig(mSurvey(1:tIndx,:),3,'Yes');

    % Estimating the ME factor out-of-sample
    alpha_loop  = linear_reg(rxbarFB(1:tIndx-1,1),xme_loop(1:end-1,:),1,'Skip',4);
    cME{1,iVin} = [ones(size(xme_loop,1),1) xme_loop]*alpha_loop;

end

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING THE ROLLING OUT-OF-SAMPLE MACROECONOMIC EXPECTATIONS (ME) FACTOR
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating the rolling out-of-sample (real-time) Macroeconomic Expectations (ME) factor');

% Setting up preliminaries and preallocations
tIndx       = 81;
rol_window  = 80;
cME_rol     = cell(1,nVin);

% Looping over vintages
for iVin = 1:nVin

    tIndx       = tIndx + 1;
    xme_loop    = pca_eig(mSurvey(tIndx-rol_window:tIndx,:),3,'Yes');

    % Estimating the ME factor out-of-sample
    alpha_loop  = linear_reg(rxbarFB(tIndx-rol_window:tIndx-1,:),xme_loop(1:end-1,:),1,'Skip',4);
    cME_rol{1,iVin} = [ones(rol_window+1,1) xme_loop]*alpha_loop;

end

%-----------------------------------------------------------------------------------------------------------------------
%% GENERATING THE FULL SAMPLE MACROECONOMIC EXPECTATIONS (ME) FACTOR FOR GSW BOND DATA
%-----------------------------------------------------------------------------------------------------------------------

disp('Generating the full sample Macroeconomic Expectations (ME) factor for the GSW bond data');

% Collecting all variables for PC estimation
mSurvey_gsw     = mSurvey(:,1:size(mSurvey,2)/4);

% Estimating principal components
pc_survey_gsw   = pca_eig(mSurvey_gsw(1:end-4,:),3,'Yes');

% Estimating the Macroeconomic Expectations (ME) factor
alpha_gsw           = linear_reg(rxbarGSW,pc_survey_gsw,1,'HH',4);
ME_gsw              = [ones(size(pc_survey_gsw,1),1) pc_survey_gsw]*alpha_gsw;
[b,sb,tb,r2,adr2]   = linear_reg(rxGSW,ME_gsw,1,'HH',4);

%-----------------------------------------------------------------------------------------------------------------------
%% SAVING RELEVANT VARIABLES
%-----------------------------------------------------------------------------------------------------------------------

save('matfiles/SurveyData.mat','mSurvey','pc_survey','loadings','ME','cME','cME_rol',...
    'ME_1q','ME_2q','ME_3q','ME_4q','pc_survey_1q','pc_survey_2q','pc_survey_3q','pc_survey_4q','ME_gsw');

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING CODE RUN TIME
%-----------------------------------------------------------------------------------------------------------------------

tEnd = toc(tStart); rmpath('../')
fprintf('Runtime: %d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));
disp('Routine Completed');

%-----------------------------------------------------------------------------------------------------------------------
% END OF SCRIPT
%-----------------------------------------------------------------------------------------------------------------------