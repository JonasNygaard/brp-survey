%% main_brp.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This scripts contain the main code for the paper "Expected Business Conditions and Bond Risk Premia". 
%
%   The script imports data from the Data/Output/ folder, which have been prepared using the data making scripts stored
%   in the Data/ folder. The Data/ folder contains a Markdown file with further notes on the data. Using these data, 
%   this script compute all results presented in the paper following the procedures described in more detail in the 
%   paper. All results are stored in LaTeX tables and encapsulated post script (eps) figures in the TeX/ folder and 
%   used directly as input to the main TeX file for the paper. The script calls all auxiliary functions and scripts 
%   from the root directory when needed along the way. 
%    
%   -------------------------------
%   Last modified: December, 2015
%   -------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

clear; clc; tStart = tic; close all; format shortg; c = clock;
disp('-------------------------------------------------------------------------------------');
disp('Main script for the paper "Expected Business Conditions and Bond Risk Premia"'        );
fprintf('Code initiated at %.0f:%.0f on %.0f / %0.f - %0.f \n',c(4:5),c(3),c(2),c(1)        );
disp('-------------------------------------------------------------------------------------');

%-----------------------------------------------------------------------------------------------------------------------
%% LOADING AND PREPARING DATA
%-----------------------------------------------------------------------------------------------------------------------
%{
    Data are constructed in the Data/ folder using the Matlab files stored therein. Here we load the processed data 
    from mat files and set it up for our empirical analysis and sample period. We refer to the markdown file located 
    in the Data/ folder explaining the data and its construction in more detail.
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Loading data and setting input values');

% Loading preprocessed data 
load('data/matfiles/BondData.mat');
load('data/matfiles/MacroFactors.mat');
load('data/matfiles/SurveyData.mat');
load('data/matfiles/FRED.mat');
load('data/matfiles/JLN.mat');
run('name_lists.m');

% Setting input values
vol_window          = 80;                   % Hardwiring length of rolling volatility window
risk_aversion       = 10;                   % Hardwiring the risk aversion parameter
transaction_costs   = 50;                   % Hardwiring assumed transaction costs in basis points
line_color          = colorBrewer(1:4);     % Setting better line colors based on colorbrewer.org

% Creating datenum vector
datenum_indx        = datenum({'01-Jan-1968';'02-Jan-2015'});
datevec_indx        = datevec(datenum_indx(1):1:datenum_indx(2));
datevec_indx        = datevec_indx(datevec_indx(2:end,2) ~= datevec_indx(1:end-1,2),1:3);
datevec_indx        = datevec_indx(11:3:end,:);
datenum_indx        = datenum(datevec_indx);
 
%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING SUMMARY STATISTICS FOR MACROECONOMIC EXPECTATIONS VARIABLES
%-----------------------------------------------------------------------------------------------------------------------
%{
    In this part of the script, we compute descriptive statistics for the survey-based expectations for our set of 
    macroeconomic fundamentals. We further plot the data in various ways for better interpretation and understanding.
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Computing summary statistics for macroeconomic expectations variables');

% Computing summary statistics
mSurvey_mean  = mean(mSurvey);
mSurvey_std   = std(mSurvey);
mSurvey_skew  = skewness(mSurvey);
mSurvey_kurt  = kurtosis(mSurvey);
mSurvey_max   = max(mSurvey);
mSurvey_min   = min(mSurvey);
mSurvey_corr  = tril(corr(mSurvey));

% Writing descriptive statistics to LaTex table
fid = fopen('TeX/Tables/e_sumstat_survey_variables.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s & %s \\\\\\midrule\n','',survey_list{:,:});
fprintf(fid,'%s & %s \\\\\\cmidrule{2-7}\n','','\multicolumn{6}{c}{Panel A: One quarter ahead}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Mean',mSurvey_mean(1:6));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Std',mSurvey_std(1:6));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Skewness',mSurvey_skew(1:6));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Kurtosis',mSurvey_kurt(1:6));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',load_list{1},loadings(1:6,1));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',load_list{2},loadings(1:6,2));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\\cmidrule{2-7}\n',load_list{3},loadings(1:6,3));
fprintf(fid,'%s & %s \\\\\\cmidrule{2-7}\n','','\multicolumn{6}{c}{Panel B: Two quarter ahead}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Mean',mSurvey_mean(7:12));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Std',mSurvey_std(7:12));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Skewness',mSurvey_skew(7:12));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Kurtosis',mSurvey_kurt(7:12));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',load_list{1},loadings(7:12,1));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',load_list{2},loadings(7:12,2));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\\cmidrule{2-7}\n',load_list{3},loadings(7:12,3));
fprintf(fid,'%s & %s \\\\\\cmidrule{2-7}\n','','\multicolumn{6}{c}{Panel C: Three quarter ahead}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Mean',mSurvey_mean(13:18));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Std',mSurvey_std(13:18));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Skewness',mSurvey_skew(13:18));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Kurtosis',mSurvey_kurt(13:18));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',load_list{1},loadings(13:18,1));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',load_list{2},loadings(13:18,2));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\\cmidrule{2-7}\n',load_list{3},loadings(13:18,3));
fprintf(fid,'%s & %s \\\\\\cmidrule{2-7}\n','','\multicolumn{6}{c}{Panel D: Four quarter ahead}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Mean',mSurvey_mean(19:24));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Std',mSurvey_std(19:24));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Skewness',mSurvey_skew(19:24));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Kurtosis',mSurvey_kurt(19:24));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',load_list{1},loadings(19:24,1));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',load_list{2},loadings(19:24,2));
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',load_list{3},loadings(19:24,3));
fprintf(fid, '\n');
fclose(fid);

% Plotting the term structure of survey expectations
figure;
for iFig = 1:numel(survey_list)

    subplot(numel(survey_list),1,iFig);
    p1 = plot(datenum_indx(1:end-4,1),mSurvey(1:end-4,iFig:numel(survey_list):end));
    p1(1).LineStyle = '-';  p1(1).Color = line_color(1,:);  p1(1).LineWidth = 1.2;
    p1(2).LineStyle = ':';  p1(2).Color = line_color(2,:);  p1(2).LineWidth = 1.4;
    p1(3).LineStyle = '--'; p1(3).Color = line_color(3,:);  p1(3).LineWidth = 1.2;
    p1(4).LineStyle = '-.'; p1(4).Color = line_color(4,:);  p1(4).LineWidth = 1.2;
    datetick('x','yyyy');
    if iFig == 2
        leg = legend(horizon_list{:,:});
        set(leg,'Orientation','Vertical','FontSize',8,'Box','off','Location','NorthEast');
    end
    axis('tight');
    set(gcf, 'PaperUnits','Centimeters','PaperSize',[19 25],'PaperPosition',[0.5 0.5 18 24]);
    title(survey_name_list{iFig},'FontSize',8);
    box on

end
print(gcf,'-depsc','TeX/Figures/e_survey_expectations.eps');

% Plotting loadings from principal component estimation
figure;
for iFig = 1:numel(pc_list)

    subplot(3,1,iFig);
    b1 = bar([
        loadings(1:numel(survey_list):end,iFig)
        loadings(2:numel(survey_list):end,iFig)
        loadings(3:numel(survey_list):end,iFig)
        loadings(4:numel(survey_list):end,iFig)
        loadings(5:numel(survey_list):end,iFig)
        loadings(6:numel(survey_list):end,iFig)
    ]);
    b1.EdgeColor = line_color(1,:); 
    b1.FaceColor = line_color(1,:);
    axis([1 size(loadings,1) -0.5 0.5]);
    set(gca,'XTick',2:4:size(loadings,1),'XTickLabel',survey_short_list);
    set(gcf, 'PaperUnits', 'Centimeters','PaperSize',[21 11],'PaperPosition',[0.5 0.5 20 10]);
    title(pc_name_list{iFig},'FontSize',8);
    box on

end
print(gcf,'-depsc','TeX/Figures/e_pca_loadings.eps');

% Plotting the principal components
figure;
for iFig = 1:3

    subplot(3,1,iFig);
    hold on
    pc_max = max(pc_survey(:,iFig));
    pc_min = min(pc_survey(:,iFig));

    b1 = bar(datenum_indx(1:end-4,1),nber(1:end,1).*(pc_max-0.05));
    b1.EdgeColor = 'None';
    b1.FaceColor = [0.8 0.8 0.8];
    b1.BarWidth = 1.2;
    b1.ShowBaseLine = 'off';

    b2 = bar(datenum_indx(1:end-4,1),nber(1:end,1).*(pc_min+0.05));
    b2.EdgeColor = 'None';
    b2.FaceColor = [0.8 0.8 0.8];
    b2.BarWidth = 1.2;
    b2.ShowBaseLine = 'off';

    p1 = plot(datenum_indx(1:end-4,1),pc_survey(:,iFig));
    p1.LineStyle = '-';
    p1.LineWidth = 1.2;
    p1.Color = [0.05 0.05 0.05];
    hold off

    datetick('x','yyyy');
    axis([min(datenum_indx(1:end-4,1)) max(datenum_indx(1:end-4,1)) pc_min pc_max]);
    set(gcf, 'PaperUnits', 'Centimeters','PaperSize',[21 13],'PaperPosition',[0.5 0.5 20 12]);
    title(pc_name_list{iFig},'FontSize',8)
    box on

end
print(gcf,'-depsc','TeX/Figures/e_principal_components.eps');

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING SUMMARY STATISTICS FOR BOND EXCESS RETURNS AND FORECASTING FACTORS
%-----------------------------------------------------------------------------------------------------------------------
%{
    In this part of the script, we compute descriptive statistics for bond risk premia and the forecasting factors. We
    also consider autocorrelations coefficients to see the time-series dependence of bond excess returns and the 
    forecasting factors. 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Computing summary statistics for bond excess returns and forecasting factors');

% Computing standard descriptive statistics
mSummary_Data   = [rxFB CP LN ME];
mSummary_mean   = mean(mSummary_Data);
mSummary_std    = std(mSummary_Data);
mSummary_skew   = skewness(mSummary_Data);
mSummary_kurt   = kurtosis(mSummary_Data);
mSummary_sr     = mSummary_mean./mSummary_std;
mSummary_corr   = tril(corr(mSummary_Data));

% Preallocations for loop
mSummary_ar1    = zeros(1,size(mSummary_Data,2));
mSummary_ar4    = zeros(1,size(mSummary_Data,2));

% Computing first- and fourth-order autocorrelation coefficients
for iData = 1:size(mSummary_Data,2);

    rho1    = linear_reg(mSummary_Data(2:end,iData),mSummary_Data(1:end-1,iData),1,'Skip');
    rho4    = linear_reg(mSummary_Data(5:end,iData),mSummary_Data(1:end-4,iData),1,'Skip');
    mSummary_ar1(1,iData) = rho1(2,1);
    mSummary_ar4(1,iData) = rho4(2,1);

end

% Writing results to LaTeX table
fid = fopen('TeX/Tables/e_sumstat_brp_factor.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s & %s & %s \\\\\\midrule\n','',rx_list{:,:},factor_list{1:3});
fprintf(fid,'%s & %s \\\\\\cmidrule{2-8}\n','','\multicolumn{7}{c}{Panel A: Descriptive statistics}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Mean',mSummary_mean);
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Std',mSummary_std);
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Skewness',mSummary_skew);
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','Kurtosis',mSummary_kurt);
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','AC(1)',mSummary_ar1);
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f\\\\\n','AC(4)',mSummary_ar4);
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %s & %s & %s \\\\\\cmidrule{2-8}\n','SR',mSummary_sr(1:4),'-','-','-');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-8}\n','','\multicolumn{7}{c}{Panel B: Correlation matrix}');
fprintf(fid,'%s & %.2f & %s & %s & %s & %s & %s & %s \\\\\n',rx_list{1},mSummary_corr(1,1),'','','','','','');
fprintf(fid,'%s & %.2f & %.2f & %s & %s & %s & %s & %s \\\\\n',rx_list{2},mSummary_corr(2,1:2),'','','','','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %s & %s & %s & %s \\\\\n',rx_list{3},mSummary_corr(3,1:3),'','','','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %s & %s & %s \\\\\n',rx_list{4},mSummary_corr(4,1:4),'','','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %s & %s \\\\\n',factor_list{1},mSummary_corr(5,1:5),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %s \\\\\n',factor_list{2},mSummary_corr(6,1:6),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',factor_list{3},mSummary_corr(7,1:7));
fprintf(fid, '\n');
fclose(fid);

%-----------------------------------------------------------------------------------------------------------------------
%% EXAMINING THE INFORMATION CONTENT IN HORIZON SPECIFIC PRINCIPAL COMPONENTS
%-----------------------------------------------------------------------------------------------------------------------
%{
    We start by investigating the informational content in survey-expectations for the four different forecast horizons
    embedded in the data from the Survey of Professional Forecasters (SPF). We construct horizon specific principal 
    components and single-factors constructed as a linear combination of the principal components. 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Examining the informational content in horizon specific survey-expectations');

% Running regressions of bond risk premia on horizon specific principal components
[b_pc_1q,~,tb_pc_1q,~,adr2_pc_1q]   = linear_reg(rxFB,pc_survey_1q,1,'HH',4);
[b_pc_2q,~,tb_pc_2q,~,adr2_pc_2q]   = linear_reg(rxFB,pc_survey_2q,1,'HH',4);
[b_pc_3q,~,tb_pc_3q,~,adr2_pc_3q]   = linear_reg(rxFB,pc_survey_3q,1,'HH',4);
[b_pc_4q,~,tb_pc_4q,~,adr2_pc_4q]   = linear_reg(rxFB,pc_survey_4q,1,'HH',4);

% Running regressions of bond risk premia on horizon specific ME factors
[b_me_1q,~,tb_me_1q,~,adr2_me_1q]   = linear_reg(rxFB,ME_1q,1,'HH',4);
[b_me_2q,~,tb_me_2q,~,adr2_me_2q]   = linear_reg(rxFB,ME_2q,1,'HH',4);
[b_me_3q,~,tb_me_3q,~,adr2_me_3q]   = linear_reg(rxFB,ME_3q,1,'HH',4);
[b_me_4q,~,tb_me_4q,~,adr2_me_4q]   = linear_reg(rxFB,ME_4q,1,'HH',4);

% Writing results to LaTeX table
fid = fopen('TeX/Tables/e_horizon_specific_pcs.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s & %s \\\\\\midrule\n','',pc_list{:,:},'adj R$^{2}\left(\%\right)$','ME$_{t}$','adj R$^{2}\left(\%\right)$');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-7}\n','','\multicolumn{6}{c}{Panel A: Two-year bond}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{1},b_pc_1q(2:end,1),adr2_pc_1q(1).*100,b_me_1q(2,1),adr2_me_1q(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_1q(2:end,1),'',tb_me_1q(2,1),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{2},b_pc_2q(2:end,1),adr2_pc_2q(1).*100,b_me_2q(2,1),adr2_me_2q(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_2q(2:end,1),'',tb_me_2q(2,1),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{3},b_pc_3q(2:end,1),adr2_pc_3q(1).*100,b_me_3q(2,1),adr2_me_3q(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_3q(2:end,1),'',tb_me_3q(2,1),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{4},b_pc_4q(2:end,1),adr2_pc_4q(1).*100,b_me_4q(2,1),adr2_me_4q(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\\cmidrule{2-7}\n','',tb_pc_4q(2:end,1),'',tb_me_4q(2,1),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-7}\n','','\multicolumn{6}{c}{Panel B: Three-year bond}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{1},b_pc_1q(2:end,2),adr2_pc_1q(2).*100,b_me_1q(2,2),adr2_me_1q(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_1q(2:end,2),'',tb_me_1q(2,2),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{2},b_pc_2q(2:end,2),adr2_pc_2q(2).*100,b_me_2q(2,2),adr2_me_2q(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_2q(2:end,2),'',tb_me_2q(2,2),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{3},b_pc_3q(2:end,2),adr2_pc_3q(2).*100,b_me_3q(2,2),adr2_me_3q(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_3q(2:end,2),'',tb_me_3q(2,2),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{4},b_pc_4q(2:end,2),adr2_pc_4q(2).*100,b_me_4q(2,2),adr2_me_4q(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\\cmidrule{2-7}\n','',tb_pc_4q(2:end,2),'',tb_me_4q(2,2),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-7}\n','','\multicolumn{6}{c}{Panel C: Four-year bond}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{1},b_pc_1q(2:end,3),adr2_pc_1q(3).*100,b_me_1q(2,3),adr2_me_1q(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_1q(2:end,3),'',tb_me_1q(2,3),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{2},b_pc_2q(2:end,3),adr2_pc_2q(3).*100,b_me_2q(2,3),adr2_me_2q(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_2q(2:end,3),'',tb_me_2q(2,3),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{3},b_pc_3q(2:end,3),adr2_pc_3q(3).*100,b_me_3q(2,3),adr2_me_3q(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_3q(2:end,3),'',tb_me_3q(2,3),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{4},b_pc_4q(2:end,3),adr2_pc_4q(3).*100,b_me_4q(2,3),adr2_me_4q(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\\cmidrule{2-7}\n','',tb_pc_4q(2:end,3),'',tb_me_4q(2,3),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-7}\n','','\multicolumn{6}{c}{Panel D: Five-year bond}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{1},b_pc_1q(2:end,4),adr2_pc_1q(4).*100,b_me_1q(2,4),adr2_me_1q(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_1q(2:end,4),'',tb_me_1q(2,4),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{2},b_pc_2q(2:end,4),adr2_pc_2q(4).*100,b_me_2q(2,4),adr2_me_2q(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_2q(2:end,4),'',tb_me_2q(2,4),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{3},b_pc_3q(2:end,4),adr2_pc_3q(4).*100,b_me_3q(2,4),adr2_me_3q(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_3q(2:end,4),'',tb_me_3q(2,4),'');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',horizon_list{4},b_pc_4q(2:end,4),adr2_pc_4q(4).*100,b_me_4q(2,4),adr2_me_4q(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_pc_4q(2:end,4),'',tb_me_4q(2,4),'');
fprintf(fid, '\n');
fclose(fid);

%-----------------------------------------------------------------------------------------------------------------------
%% ESTIMATING THE FULL SAMPLE MACROECONOMIC EXPECTATIONS (ME) FACTOR
%-----------------------------------------------------------------------------------------------------------------------
%{
    We now turn to a major part of the paper, namely the estimation of our proxy for expected business conditions, which
    we label ME for macroeconomic expectations. The factor is estimated analogously to the factors from Cochrane and 
    Piazzesi (2005) and Ludvigson and Ng (2009). 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Estimating the full sample Macroeconomic Expectations (ME) factor');

% Estimating the ME factor
[b_me,~,tb_me,~,adr2_me]    = linear_reg(rxFB,ME,1,'HH',4);
[b_pc,~,tb_pc,~,adr2_pc]    = linear_reg(rxFB,pc_survey,1,'HH',4);
[b_pc1,~,tb_pc1,~,adr2_pc1] = linear_reg(rxFB,pc_survey(:,1),1,'HH',4);
[b_pc2,~,tb_pc2,~,adr2_pc2] = linear_reg(rxFB,pc_survey(:,2),1,'HH',4);
[b_pc3,~,tb_pc3,~,adr2_pc3] = linear_reg(rxFB,pc_survey(:,3),1,'HH',4);

% Writing results to LaTeX table
fid = fopen('TeX/Tables/e_me_estimation.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s \\\\\\midrule\n','',pc_list{:,:},factor_list{3},'adj R$^{2}\left(\%\right)$');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel A: Two-year bond}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %s & %.2f \\\\\n','(a)',b_pc(2:4,1),'',adr2_pc(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_pc(2:4,1),'','');
fprintf(fid,'%s & %s & %s & %s & %.2f & %.2f \\\\\n','(b)','','','',b_me(2,1),adr2_me(1).*100);
fprintf(fid,'%s & %s & %s & %s & (%.2f) & %s \\\\\\cmidrule{2-6}\n','','','','',tb_me(2,1),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel B: Three-year bond}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %s & %.2f \\\\\n','(a)',b_pc(2:4,2),'',adr2_pc(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_pc(2:4,2),'','');
fprintf(fid,'%s & %s & %s & %s & %.2f & %.2f \\\\\n','(b)','','','',b_me(2,2),adr2_me(2).*100);
fprintf(fid,'%s & %s & %s & %s & (%.2f) & %s \\\\\\cmidrule{2-6}\n','','','','',tb_me(2,2),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel C: Four-year bond}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %s & %.2f \\\\\n','(a)',b_pc(2:4,3),'',adr2_pc(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_pc(2:4,3),'','');
fprintf(fid,'%s & %s & %s & %s & %.2f & %.2f \\\\\n','(b)','','','',b_me(2,3),adr2_me(3).*100);
fprintf(fid,'%s & %s & %s & %s & (%.2f) & %s \\\\\\cmidrule{2-6}\n','','','','',tb_me(2,3),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel D: Five-year bond}');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %s & %.2f \\\\\n','(a)',b_pc(2:4,4),'',adr2_pc(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_pc(2:4,4),'','');
fprintf(fid,'%s & %s & %s & %s & %.2f & %.2f \\\\\n','(b)','','','',b_me(2,4),adr2_me(4).*100);
fprintf(fid,'%s & %s & %s & %s & (%.2f) & %s \\\\\n','','','','',tb_me(2,4),'');
fprintf(fid, '\n');
fclose(fid);

% Writing long version of results to LaTeX table
fid = fopen('TeX/Tables/e_me_estimation_long.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s \\\\\\midrule\n','',pc_list{:,:},factor_list{3},'adj R$^{2}\left(\%\right)$');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel A: Two-year bond}');
fprintf(fid,'%s & %.2f & %s & %s & %s & %.2f \\\\\n','(a)',b_pc1(2,1),'','','',adr2_pc1(1).*100);
fprintf(fid,'%s & (%.2f) & %s & %s & %s & %s \\\\\n','',tb_pc1(2,1),'','','','');
fprintf(fid,'%s & %s & %.2f & %s & %s & %.2f \\\\\n','(b)','',b_pc2(2,1),'','',adr2_pc2(1).*100);
fprintf(fid,'%s & %s & (%.2f) & %s & %s & %s \\\\\n','','',tb_pc2(2,1),'','','');
fprintf(fid,'%s & %s & %s & %.2f & %s & %.2f \\\\\n','(c)','','',b_pc3(2,1),'',adr2_pc3(1).*100);
fprintf(fid,'%s & %s & %s & (%.2f) & %s & %s \\\\\n','','','',tb_pc3(2,1),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %s & %.2f \\\\\n','(d)',b_pc(2:4,1),'',adr2_pc(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_pc(2:4,1),'','');
fprintf(fid,'%s & %s & %s & %s & %.2f & %.2f \\\\\n','(e)','','','',b_me(2,1),adr2_me(1).*100);
fprintf(fid,'%s & %s & %s & %s & (%.2f) & %s \\\\\\cmidrule{2-6}\n','','','','',tb_me(2,1),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel B: Three-year bond}');
fprintf(fid,'%s & %.2f & %s & %s & %s & %.2f \\\\\n','(a)',b_pc1(2,2),'','','',adr2_pc1(2).*100);
fprintf(fid,'%s & (%.2f) & %s & %s & %s & %s \\\\\n','',tb_pc1(2,2),'','','','');
fprintf(fid,'%s & %s & %.2f & %s & %s & %.2f \\\\\n','(b)','',b_pc2(2,2),'','',adr2_pc2(2).*100);
fprintf(fid,'%s & %s & (%.2f) & %s & %s & %s \\\\\n','','',tb_pc2(2,2),'','','');
fprintf(fid,'%s & %s & %s & %.2f & %s & %.2f \\\\\n','(c)','','',b_pc3(2,2),'',adr2_pc3(2).*100);
fprintf(fid,'%s & %s & %s & (%.2f) & %s & %s \\\\\n','','','',tb_pc3(2,2),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %s & %.2f \\\\\n','(d)',b_pc(2:4,2),'',adr2_pc(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_pc(2:4,2),'','');
fprintf(fid,'%s & %s & %s & %s & %.2f & %.2f \\\\\n','(e)','','','',b_me(2,2),adr2_me(2).*100);
fprintf(fid,'%s & %s & %s & %s & (%.2f) & %s \\\\\\cmidrule{2-6}\n','','','','',tb_me(2,2),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel C: Four-year bond}');
fprintf(fid,'%s & %.2f & %s & %s & %s & %.2f \\\\\n','(a)',b_pc1(2,3),'','','',adr2_pc1(3).*100);
fprintf(fid,'%s & (%.2f) & %s & %s & %s & %s \\\\\n','',tb_pc1(2,3),'','','','');
fprintf(fid,'%s & %s & %.2f & %s & %s & %.2f \\\\\n','(b)','',b_pc2(2,3),'','',adr2_pc2(3).*100);
fprintf(fid,'%s & %s & (%.2f) & %s & %s & %s \\\\\n','','',tb_pc2(2,3),'','','');
fprintf(fid,'%s & %s & %s & %.2f & %s & %.2f \\\\\n','(c)','','',b_pc3(2,3),'',adr2_pc3(3).*100);
fprintf(fid,'%s & %s & %s & (%.2f) & %s & %s \\\\\n','','','',tb_pc3(2,3),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %s & %.2f \\\\\n','(d)',b_pc(2:4,3),'',adr2_pc(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_pc(2:4,3),'','');
fprintf(fid,'%s & %s & %s & %s & %.2f & %.2f \\\\\n','(e)','','','',b_me(2,3),adr2_me(3).*100);
fprintf(fid,'%s & %s & %s & %s & (%.2f) & %s \\\\\\cmidrule{2-6}\n','','','','',tb_me(2,3),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel D: Five-year bond}');
fprintf(fid,'%s & %.2f & %s & %s & %s & %.2f \\\\\n','(a)',b_pc1(2,4),'','','',adr2_pc1(4).*100);
fprintf(fid,'%s & (%.2f) & %s & %s & %s & %s \\\\\n','',tb_pc1(2,4),'','','','');
fprintf(fid,'%s & %s & %.2f & %s & %s & %.2f \\\\\n','(b)','',b_pc2(2,4),'','',adr2_pc2(4).*100);
fprintf(fid,'%s & %s & (%.2f) & %s & %s & %s \\\\\n','','',tb_pc2(2,4),'','','');
fprintf(fid,'%s & %s & %s & %.2f & %s & %.2f \\\\\n','(c)','','',b_pc3(2,4),'',adr2_pc3(4).*100);
fprintf(fid,'%s & %s & %s & (%.2f) & %s & %s \\\\\n','','','',tb_pc3(2,4),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %s & %.2f \\\\\n','(d)',b_pc(2:4,4),'',adr2_pc(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_pc(2:4,4),'','');
fprintf(fid,'%s & %s & %s & %s & %.2f & %.2f \\\\\n','(e)','','','',b_me(2,4),adr2_me(4).*100);
fprintf(fid,'%s & %s & %s & %s & (%.2f) & %s \\\\\n','','','','',tb_me(2,4),'');
fprintf(fid, '\n');
fclose(fid);

% Plotting the Macroeconomic Expectations (ME) factor against the CFNAI
figure;
hold on
b1 = bar(datenum_indx(1:end-4,1),nber(1:end,1).*2.99);
b1.EdgeColor = 'none';
b1.FaceColor = [0.8 0.8 0.8];
b1.BarWidth = 1.2;
b1.ShowBaseLine = 'off';
set(get(get(b1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
b2 = bar(datenum_indx(1:end-4,1),nber(1:end,1).*-3.99);
b2.EdgeColor = 'none';
b2.FaceColor = [0.8 0.8 0.8];
b2.BarWidth = 1.2;
b2.ShowBaseLine = 'off';
set(get(get(b2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
p1 = plot(datenum_indx(1:end-4,1),standard(ME));
p1.LineStyle = '-';
p1.LineWidth = 1.2;
p1.Color = [0.05 0.05 0.05];
p2 = plot(datenum_indx(1:end-4,1),standard(cfnai(1:end-4,1)));
p2.LineStyle = '-';
p2.LineWidth = 1;
p2.Color = line_color(2,:);
hold off
datetick('x','yyyy');
axis([-inf inf -4.005 3.005]);
set(gcf, 'PaperUnits', 'Centimeters','PaperSize',[21 8],'PaperPosition',[0.5 0.5 20 7]);
leg = legend('ME$_{t}$','CFNAI$_{t}$');
set(leg,'Position',[0.56 0.2 0.1 0.03],'Box','off','Interpreter','latex');
box on
print(gcf,'-depsc','TeX/Figures/e_me_cfnai.eps');

% Plotting the Macroeconomic Expectations (ME) factor against the smooth CFNAI
figure;
hold on
b1 = bar(datenum_indx(1:end-4,1),nber(1:end,1).*2.99);
b1.EdgeColor = 'none';
b1.FaceColor = [0.8 0.8 0.8];
b1.BarWidth = 1.2;
b1.ShowBaseLine = 'off';
set(get(get(b1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
b2 = bar(datenum_indx(1:end-4,1),nber(1:end,1).*-3.99);
b2.EdgeColor = 'none';
b2.FaceColor = [0.8 0.8 0.8];
b2.BarWidth = 1.2;
b2.ShowBaseLine = 'off';
set(get(get(b2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
p1 = plot(datenum_indx(1:end-4,1),standard(ME));
p1.LineStyle = '-';
p1.LineWidth = 1.2;
p1.Color = [0.05 0.05 0.05];
p2 = plot(datenum_indx(1:end-4,1),standard(filter((1/3)*ones(3,1),1,cfnai(1:end-4,1))));
p2.LineStyle = '-';
p2.LineWidth = 1;
p2.Color = line_color(2,:);
hold off
datetick('x','yyyy');
axis([-inf inf -4.005 3.005]);
set(gcf, 'PaperUnits', 'Centimeters','PaperSize',[21 8],'PaperPosition',[0.5 0.5 20 7]);
leg = legend('ME$_{t}$','CFNAI$_{t}$');
set(leg,'Position',[0.56 0.2 0.1 0.03],'Box','off','Interpreter','latex');
box on
print(gcf,'-depsc','TeX/Figures/e_me_cfnai_smooth.eps');

%-----------------------------------------------------------------------------------------------------------------------
%% TESTING IF THE MACROEXPECTATIONS FACTOR IS UNSPANNED BY THE TERM STRUCUTRE
%-----------------------------------------------------------------------------------------------------------------------

disp('Testing if the Macroeconomic expectations (ME) factor is unspanned by the term structure');

% Collecting data and running linear projections
mSpanning_data              = [pc_survey ME];
[b_pc3,~,tb_pc3,~,adr2_pc3] = linear_reg(mSpanning_data,pc_yields(1:end-4,1:3),1,'HH',4);
[b_pc5,~,tb_pc5,~,adr2_pc5] = linear_reg(mSpanning_data,pc_yields(1:end-4,1:5),1,'HH',4);

% Creating LaTeX table
fid = fopen('TeX/Tables/e_spanning_restriction.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s & %s & %s \\\\\\midrule\n','','Variable',factor_list{4:8},'adj R$^{2}\left(\%\right)$');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f & %s & %s & %.2f \\\\\n','(a)',pc_list{1},b_pc3(2:4,1),'','',adr2_pc3(1).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & (%.2f) & %s & %s & %s \\\\\n','','',tb_pc3(2:4,1),'','','');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','(b)','',b_pc5(2:6,1),adr2_pc5(1).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & (%.2f) & (%.2f) & (%.2f) & %s \\\\\\cmidrule{2-8}\n','','',tb_pc5(2:6,1),'');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f & %s & %s & %.2f \\\\\n','(a)',pc_list{2},b_pc3(2:4,2),'','',adr2_pc3(2).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & (%.2f) & %s & %s & %s \\\\\n','','',tb_pc3(2:4,2),'','','');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','(b)','',b_pc5(2:6,2),adr2_pc5(2).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & (%.2f) & (%.2f) & (%.2f) & %s \\\\\\cmidrule{2-8}\n','','',tb_pc5(2:6,2),'');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f & %s & %s & %.2f \\\\\n','(a)',pc_list{3},b_pc3(2:4,3),'','',adr2_pc3(3).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & (%.2f) & %s & %s & %s \\\\\n','','',tb_pc3(2:4,3),'','','');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','(b)','',b_pc5(2:6,3),adr2_pc5(3).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & (%.2f) & (%.2f) & (%.2f) & %s \\\\\\cmidrule{2-8}\n','','',tb_pc5(2:6,3),'');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f & %s & %s & %.2f \\\\\n','(a)',factor_list{3},b_pc3(2:4,4),'','',adr2_pc3(4).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & (%.2f) & %s & %s & %s \\\\\n','','',tb_pc3(2:4,4),'','','');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n','(b)','',b_pc5(2:6,4),adr2_pc5(4).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & (%.2f) & (%.2f) & (%.2f) & %s \\\\\n','','',tb_pc5(2:6,4),'');
fprintf(fid, '\n');
fclose(fid);

%-----------------------------------------------------------------------------------------------------------------------
%% ESTIMATING FORECASTING MODELS IN-SAMPLE
%-----------------------------------------------------------------------------------------------------------------------

disp('Estimating forecasting models in-sample');

% Estimating forecasting models in-sample
[b_cp,~,tb_cp,~,adr2_cp]                = linear_reg(rxFB,CP,1,'HH',4);
[b_ln,~,tb_ln,~,adr2_ln]                = linear_reg(rxFB,LN,1,'HH',4);
[b_cpme,~,tb_cpme,~,adr2_cpme]          = linear_reg(rxFB,[CP ME],1,'HH',4);
[b_lnme,~,tb_lnme,~,adr2_lnme]          = linear_reg(rxFB,[LN ME],1,'HH',4);
[b_cpln,~,tb_cpln,~,adr2_cpln]          = linear_reg(rxFB,[CP LN],1,'HH',4);
[b_cplnme,~,tb_cplnme,~,adr2_cplnme]    = linear_reg(rxFB,[CP LN ME],1,'HH',4);

% Writing results to LaTeX table
fid = fopen('TeX/Tables/e_insample_results.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s \\\\\\midrule\n','',factor_list{1:3},'adj R$^{2}\left(\%\right)$');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-5}\n','','\multicolumn{4}{c}{Panel A: Two-year bond}');
fprintf(fid,'%s & %.2f & %s & %s & %.2f \\\\\n','(a)',b_cp(2,1),'','',adr2_cp(1).*100);
fprintf(fid,'%s & (%.2f) & %s & %s & %s \\\\\n','',tb_cp(2,1),'','','');
fprintf(fid,'%s & %.2f & %s & %.2f & %.2f \\\\\n','(b)',b_cpme(2,1),'',b_cpme(3,1),adr2_cpme(1).*100);
fprintf(fid,'%s & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_cpme(2,1),'',tb_cpme(3,1),'');
fprintf(fid,'%s & %s & %.2f & %s & %.2f \\\\\n','(c)','',b_ln(2,1),'',adr2_ln(1).*100);
fprintf(fid,'%s & %s & (%.2f) & %s & %s \\\\\n','','',tb_ln(2,1),'','');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f \\\\\n','(d)','',b_lnme(2:3,1),adr2_lnme(1).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & %s \\\\\n','','',tb_lnme(2:3,1),'');
fprintf(fid,'%s & %.2f & %.2f & %s & %.2f \\\\\n','(e)',b_cpln(2:3,1),'',adr2_cpln(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_cpln(2:3,1),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f \\\\\n','(f)',b_cplnme(2:4,1),adr2_cplnme(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s \\\\\\cmidrule{2-5}\n','',tb_cplnme(2:4,1),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-5}\n','','\multicolumn{4}{c}{Panel B: Three-year bond}');
fprintf(fid,'%s & %.2f & %s & %s & %.2f \\\\\n','(a)',b_cp(2,2),'','',adr2_cp(2).*100);
fprintf(fid,'%s & (%.2f) & %s & %s & %s \\\\\n','',tb_cp(2,2),'','','');
fprintf(fid,'%s & %.2f & %s & %.2f & %.2f \\\\\n','(b)',b_cpme(2,2),'',b_cpme(3,2),adr2_cpme(2).*100);
fprintf(fid,'%s & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_cpme(2,2),'',tb_cpme(3,2),'');
fprintf(fid,'%s & %s & %.2f & %s & %.2f \\\\\n','(c)','',b_ln(2,2),'',adr2_ln(2).*100);
fprintf(fid,'%s & %s & (%.2f) & %s & %s \\\\\n','','',tb_ln(2,2),'','');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f \\\\\n','(d)','',b_lnme(2:3,2),adr2_lnme(2).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & %s \\\\\n','','',tb_lnme(2:3,2),'');
fprintf(fid,'%s & %.2f & %.2f & %s & %.2f \\\\\n','(e)',b_cpln(2:3,2),'',adr2_cpln(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_cpln(2:3,2),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f \\\\\n','(f)',b_cplnme(2:4,2),adr2_cplnme(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s \\\\\\cmidrule{2-5}\n','',tb_cplnme(2:4,2),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-5}\n','','\multicolumn{4}{c}{Panel C: Four-year bond}');
fprintf(fid,'%s & %.2f & %s & %s & %.2f \\\\\n','(a)',b_cp(2,3),'','',adr2_cp(3).*100);
fprintf(fid,'%s & (%.2f) & %s & %s & %s \\\\\n','',tb_cp(2,3),'','','');
fprintf(fid,'%s & %.2f & %s & %.2f & %.2f \\\\\n','(b)',b_cpme(2,3),'',b_cpme(3,3),adr2_cpme(3).*100);
fprintf(fid,'%s & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_cpme(2,3),'',tb_cpme(3,3),'');
fprintf(fid,'%s & %s & %.2f & %s & %.2f \\\\\n','(c)','',b_ln(2,3),'',adr2_ln(3).*100);
fprintf(fid,'%s & %s & (%.2f) & %s & %s \\\\\n','','',tb_ln(2,3),'','');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f \\\\\n','(d)','',b_lnme(2:3,3),adr2_lnme(3).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & %s \\\\\n','','',tb_lnme(2:3,3),'');
fprintf(fid,'%s & %.2f & %.2f & %s & %.2f \\\\\n','(e)',b_cpln(2:3,3),'',adr2_cpln(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_cpln(2:3,3),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f \\\\\n','(f)',b_cplnme(2:4,3),adr2_cplnme(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s \\\\\\cmidrule{2-5}\n','',tb_cplnme(2:4,3),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-5}\n','','\multicolumn{4}{c}{Panel D: Five-year bond}');
fprintf(fid,'%s & %.2f & %s & %s & %.2f \\\\\n','(a)',b_cp(2,4),'','',adr2_cp(4).*100);
fprintf(fid,'%s & (%.2f) & %s & %s & %s \\\\\n','',tb_cp(2,4),'','','');
fprintf(fid,'%s & %.2f & %s & %.2f & %.2f \\\\\n','(b)',b_cpme(2,4),'',b_cpme(3,4),adr2_cpme(4).*100);
fprintf(fid,'%s & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_cpme(2,4),'',tb_cpme(3,4),'');
fprintf(fid,'%s & %s & %.2f & %s & %.2f \\\\\n','(c)','',b_ln(2,4),'',adr2_ln(4).*100);
fprintf(fid,'%s & %s & (%.2f) & %s & %s \\\\\n','','',tb_ln(2,4),'','');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f \\\\\n','(d)','',b_lnme(2:3,4),adr2_lnme(4).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & %s \\\\\n','','',tb_lnme(2:3,4),'');
fprintf(fid,'%s & %.2f & %.2f & %s & %.2f \\\\\n','(e)',b_cpln(2:3,4),'',adr2_cpln(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_cpln(2:3,4),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f \\\\\n','(f)',b_cplnme(2:4,4),adr2_cplnme(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s \\\\\n','',tb_cplnme(2:4,4),'');
fprintf(fid,'\n');
fclose(fid);

%-----------------------------------------------------------------------------------------------------------------------
%% ESTIMATING FORECASTING MODELS OUT-OF-SAMPLE
%-----------------------------------------------------------------------------------------------------------------------
%{
    This out-of-sample exercise is based on recursive model estimation using an expanding window scheme. The initial 
    in-sample estimation period is set from 1968Q4 to 1989Q4 (84 observations) and the out-of-sample evaluation periods 
    goes from 1990Q1 to 2013Q4 (93 observations). 
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Estimating forecasting models out-of-sample');

% Setting dimension of the forecasting problem
[~,nBonds]      = size(rxFB);
init_window     = 80;
nFrcst          = 100;

% Preallocations for forecast matrices
actual          = NaN(nFrcst,nBonds);
frcst_eh        = NaN(nFrcst,nBonds);
frcst_cp        = NaN(nFrcst,nBonds);
frcst_ln        = NaN(nFrcst,nBonds);
frcst_me        = NaN(nFrcst,nBonds);
frcst_cpln      = NaN(nFrcst,nBonds);
frcst_cpme      = NaN(nFrcst,nBonds);
frcst_lnme      = NaN(nFrcst,nBonds);
frcst_cplnme    = NaN(nFrcst,nBonds);
frcst_comp1     = NaN(nFrcst,nBonds);
frcst_comp2     = NaN(nFrcst,nBonds);
frcst_comp3     = NaN(nFrcst,nBonds);

% Setting up text-based progress bar
pbar = progressbar(nFrcst,...
    'barlength', 20, ...
    'updatestep', 10, ...
    'startmsg', 'Making forecasts... ',...
    'endmsg', ' Done!', ...
    'showbar', true, ...
    'showremtime', false, ...
    'showactualnum', false, ...
    'showfinaltime', false, ...
    'barsymbol', '#' ...
);


% Generating out-of-sample forecasts
for iFrcst = 1:nFrcst

    % Setting starting point
    begf = 1;

    % Printing text-based progress bar
    pbar(iFrcst);

    % Adapting returns and predictors to the initialization period
    rx_t = rxFB(1:init_window+iFrcst,:)./100;
    rxbar_t = rxbarFB(1:init_window+iFrcst,:)./100;
    ftfb_t = ftFB(1:init_window+iFrcst+1,:)./100;
    actual(iFrcst,:) = rxFB(init_window+iFrcst+1,:)./100;

    % Estimating time t predictors
    cp_t = cCP{1,iFrcst};
    ln_t = cLN{1,iFrcst};
    me_t = cME{1,iFrcst};

    % EH Forecasts
    frcst_eh(iFrcst,:) = mean(rx_t);

    % CP Forecasts
    bcp = linear_reg(rx_t,cp_t(1:end-1,1),1,'Skip',1);
    frcst_cp(iFrcst,:) = [1 cp_t(end)]*bcp;

    % LN Forecast 
    bln = linear_reg(rx_t,ln_t(1:end-1,1),1,'Skip',1);
    frcst_ln(iFrcst,:) = [1 ln_t(end)]*bln;

    % % ME Forecasts
    bme = linear_reg(rx_t,me_t(1:end-1,1),1,'Skip',1);
    frcst_me(iFrcst,:) = [1 me_t(end)]*bme;

    % CP + LN Forecasts
    bcpln = linear_reg(rx_t,[cp_t(1:end-1,1) ln_t(1:end-1,1)],1,'Skip',1);
    frcst_cpln(iFrcst,:) = [1 cp_t(end) ln_t(end)]*bcpln;

    % CP + ME Forecasts
    bcpme = linear_reg(rx_t,[cp_t(1:end-1,1) me_t(1:end-1,1)],1,'Skip',1);
    frcst_cpme(iFrcst,:) = [1 cp_t(end) me_t(end)]*bcpme;

    % LN + ME Forecasts
    blnme = linear_reg(rx_t,[ln_t(1:end-1,1) me_t(1:end-1,1)],1,'Skip',1);
    frcst_lnme(iFrcst,:) = [1 ln_t(end) me_t(end)]*blnme;

    % CP + LN + ME Forecasts
    bcplnme = linear_reg(rx_t,[cp_t(1:end-1,1) ln_t(1:end-1,1) me_t(1:end-1,1)],1,'Skip',1);
    frcst_cplnme(iFrcst,:) = [1 cp_t(end) ln_t(end) me_t(end)]*bcplnme;

    % Equal-weighted forecast combination of various models
    frcst_comp1(iFrcst,:) = (frcst_cp(iFrcst,:) + frcst_ln(iFrcst,:) + frcst_cpln(iFrcst,:))./3; 
    frcst_comp2(iFrcst,:) = (frcst_comp1(iFrcst,:).*3 + frcst_me(iFrcst,:))./4;
    frcst_comp3(iFrcst,:) = (frcst_comp2(iFrcst,:).*4+frcst_lnme(iFrcst,:)+frcst_cpme(iFrcst,:)+frcst_cplnme(iFrcst,:))./7;

end

%-----------------------------------------------------------------------------------------------------------------------
%% EVALUATING FORECASTS STATISTICALLY
%-----------------------------------------------------------------------------------------------------------------------

disp('Evaluating forecasts statistically');

% Collecting forecasts
mFrcst = [
    frcst_eh ...
    frcst_cp ...
    frcst_ln ...
    frcst_cpln ...
    frcst_me ...
    frcst_cpme ...
    frcst_lnme ...
    frcst_cplnme ...
    frcst_comp1 ...
    frcst_comp3 ...
    frcst_comp2 ...
];

% Computing forecast errors and MSPE measures
mEps    = repmat(actual,1,11) - mFrcst;
mMSPE   = mean(mEps.^2);

% Computing cumulative difference in squared forecast errors
mCSFE   = cumsum(mEps.^2);
mDCSFE  = repmat(mCSFE(:,1:4),1,size(mCSFE,2)/4-1) - mCSFE(:,5:end);

% Computing out-of-sample R-squared and Clark-West p-values against expectations hypothesis benchmark
[~,mCW,mR2oos]  = perform_cw_dm_test(repmat(actual,1,10),repmat(frcst_eh,1,10),mFrcst(:,5:end),'CW');
mCW             = reshape(mCW,[4,10]);
mR2oos          = reshape(mR2oos,[4,10]);

% Computing out-of-sample R-squared and Clark-West p-values against models without the ME factor
[~,mCW_mc,mR2oos_mc]    = perform_cw_dm_test(repmat(actual,1,3),mFrcst(:,5:16),mFrcst(:,21:32),'CW');
mCW_mc                  = reshape(mCW_mc,[4,3]);
mR2oos_mc               = reshape(mR2oos_mc,[4,3]);

% Plotting the differences in cumulative squared prediction errors
figure;
for iFig = 1:7

    subplot(4,2,iFig);
    hold on

    b1 = bar(datenum_indx(86:end,1),nber(82:end,1).*0.058);
    b1.EdgeColor = 'none';
    b1.FaceColor = [0.8 0.8 0.8];
    b1.BarWidth = 1.2;
    b1.ShowBaseLine = 'off';
    set(get(get(b1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    b2 = bar(datenum_indx(86:end,1),nber(82:end,1).*-0.058);
    b2.EdgeColor = 'none';
    b2.FaceColor = [0.8 0.8 0.8];
    b2.BarWidth = 1.2;
    b2.ShowBaseLine = 'off';
    set(get(get(b2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    p1 = plot(datenum_indx(86:end,1),mDCSFE(:,1+(iFig-1)*4));
    p1.LineStyle = '-'; p1.LineWidth = 1.6;
    p1.Color = line_color(1,:);

    p2 = plot(datenum_indx(86:end,1),mDCSFE(:,2+(iFig-1)*4));
    p2.LineStyle = ':'; p2.LineWidth = 1.8;
    p2.Color = line_color(2,:);

    p3 = plot(datenum_indx(86:end,1),mDCSFE(:,3+(iFig-1)*4));
    p3.LineStyle = '--'; p3.LineWidth = 1.6;
    p3.Color = line_color(3,:);

    p4 = plot(datenum_indx(86:end,1),mDCSFE(:,4+(iFig-1)*4));
    p4.LineStyle = '-.'; p4.LineWidth = 1.6;
    p4.Color = line_color(4,:);

    hold off
    if iFig == 1
        leg = legend('2-year','3-year','4-year','5-year');
        set(leg,'Orientation','vertical','FontSize',6,'Box','off','Location','SouthWest');
    end

    datetick('x','yyyy');
    axis([min(datenum_indx(86:end,1))-150 max(datenum_indx(86:end,1))+50 -0.05 0.05]);
    set(gca,'YTIck',-0.04:0.02:0.04);
    set(gcf, 'PaperUnits', 'Centimeters','PaperSize',[19 21],'PaperPosition',[0.5 0.5 18 20]);
    title(model_list{iFig},'FontSize',8)
    box on

end
print(gcf,'-depsc','TeX/Figures/e_dcsfe.eps');

%-----------------------------------------------------------------------------------------------------------------------
%% EVALUATING FORECASTS ECONOMICALLY
%-----------------------------------------------------------------------------------------------------------------------

disp('Evaluating forecasts economically');

% Estimate volatility using a simple rolling estimator
frcst_vol = recursive_vol(rxFB./100,'rol',12,80);
frcst_vol = frcst_vol(end-99:end,:).^2;

% Setting the risk-free rate to be one-year bond yield
risk_free   = yFB(init_window+2:end-4,1);

% Performing asset allocation
[avg_utility,sharpe_ratio,gisw_model,risky_weights,portfolio_ret,avg_turnover] = ...
    perform_asset_allocation(repmat(actual,1,11),risk_free,mFrcst,repmat(frcst_vol,1,11),risk_aversion,...
    'Weights',[0 1.5]);

[avg_utility_tc,sharpe_ratio_tc,gisw_model_tc,risky_weights_tc,portfolio_ret_tc,avg_turnover_tc] = ...
    perform_asset_allocation(repmat(actual,1,11),risk_free,mFrcst,repmat(frcst_vol,1,11),risk_aversion,...
    'Weights',[0 1.5],transaction_costs);

% Computing time-series of realized utility
realized_utility    = portfolio_ret-0.5.*risk_aversion.*(portfolio_ret-repmat(mean(portfolio_ret),nFrcst,1)).^2;
realized_utility_tc = portfolio_ret_tc-0.5.*risk_aversion.*(portfolio_ret_tc-repmat(mean(portfolio_ret_tc),nFrcst,1)).^2;

% Computing annualized utility gains relative to EH benchmark
utility_gains       = 400.*(avg_utility(:,5:end) - repmat(avg_utility(:,1:4),1,10));
utility_gains_tc    = 400.*(avg_utility_tc(:,5:end) - repmat(avg_utility_tc(:,1:4),1,10));
utility_gains       = reshape(utility_gains,[4,10]);
utility_gains_tc    = reshape(utility_gains_tc,[4,10]);

% Compute annualized GISW measures against EH benchmark
gisw                = 400.*(gisw_model(:,5:end) - repmat(gisw_model(:,1:4),1,10));
gisw_tc             = 400.*(gisw_model_tc(:,5:end) - repmat(gisw_model_tc(:,1:4),1,10));
gisw                = reshape(gisw,[4,10]);
gisw_tc             = reshape(gisw_tc,[4,10]);

% Computing Diebold-Mariano p-values against EH utility benchmark
[~,mDM]             = perform_utility_dm_test(realized_utility(:,5:end),repmat(realized_utility(:,1:4),1,10));
mDM                 = reshape(mDM,[4,10]);

% Computing annualized utility gains against models without the ME factor
utility_gains_mc    = 400.*(avg_utility(21:32) - avg_utility(5:16));
utility_gains_mc_tc = 400.*(avg_utility_tc(21:32) - avg_utility_tc(5:16));
utility_gains_mc    = reshape(utility_gains_mc,[4,3]);
utility_gains_mc_tc = reshape(utility_gains_mc_tc,[4,3]);

% Compute annualized GISW measures against models without the ME factor
gisw_mc             = 400.*(gisw_model(:,21:32) - repmat(gisw_model(:,5:16),1,1));
gisw_mc_tc          = 400.*(gisw_model_tc(:,21:32) - repmat(gisw_model_tc(:,5:16),1,1));
gisw_mc             = reshape(gisw_mc,[4,3]);
gisw_mc_tc          = reshape(gisw_mc_tc,[4,3]);

% Computing Diebold-Mariano p-values against models without the ME factor
[~,mDM_mc]          =  perform_utility_dm_test(realized_utility(:,21:32),repmat(realized_utility(:,5:16),1,1));
mDM_mc              = reshape(mDM_mc,[4,3]);

% Computing differences in cumulative realized utility relative to the EH benchmark
mDCRU               = 400.*(cumsum(realized_utility(:,5:end))-repmat(cumsum(realized_utility(:,1:4)),1,10))./nFrcst;
mDCRU_tc            = 400.*(cumsum(realized_utility_tc(:,5:end))-repmat(cumsum(realized_utility_tc(:,1:4)),1,10))./nFrcst;

% Writing results to LaTeX table
fid = fopen('TeX/Tables/e_out_of_sample_results.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s & %s & %s \\\\\\midrule\n','n',model_list{:,:});
fprintf(fid,'%s & %s \\\\\\cmidrule{2-8}\n','','\multicolumn{7}{c}{Panel A: R$^{2}_{\text{oos}}$}');
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',2,mR2oos(1,1:7));
fprintf(fid,'%s & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] \\\\\n','',mCW(1,1:7));
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',3,mR2oos(2,1:7));
fprintf(fid,'%s & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] \\\\\n','',mCW(2,1:7));
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',4,mR2oos(3,1:7));
fprintf(fid,'%s & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] \\\\\n','',mCW(3,1:7));
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',5,mR2oos(4,1:7));
fprintf(fid,'%s & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] \\\\\\cmidrule{2-8}\n','',mCW(4,1:7));
fprintf(fid,'%s & %s \\\\\\cmidrule{2-8}\n','','\multicolumn{7}{c}{Panel B: $\Delta\left(\%\right)$}');
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',2,utility_gains(1,1:7));
fprintf(fid,'%s & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] \\\\\n','',mDM(1,1:7));
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',3,utility_gains(2,1:7));
fprintf(fid,'%s & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] \\\\\n','',mDM(2,1:7));
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',4,utility_gains(3,1:7));
fprintf(fid,'%s & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] \\\\\n','',mDM(3,1:7));
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',5,utility_gains(4,1:7));
fprintf(fid,'%s & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] & [%.2f] \\\\\\cmidrule{2-8}\n','',mDM(4,1:7));
fprintf(fid,'%s & %s \\\\\\cmidrule{2-8}\n','','\multicolumn{7}{c}{Panel C: $\Theta\left(\%\right)$}');
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',2,gisw(1,1:7));
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',3,gisw(2,1:7));
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',4,gisw(3,1:7));
fprintf(fid,'%.0f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n',5,gisw(4,1:7));
fprintf(fid,'\n');
fclose(fid);

% Writing results to LaTeX table
strvar = {'R$^{2}_{\text{oos}}$','p-val','$\Delta$(\%)','p-val','$\Theta$(\%)'};
fid = fopen('TeX/Tables/e_out_of_sample_model_comparison.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s \\\\\\midrule\n','',strvar{:,:});
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel A: Two-year bond}');
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f  \\\\\n','CP+ME vs. CP',...
    mR2oos_mc(1,1),mCW_mc(1,1),utility_gains_mc(1,1),mDM_mc(1,1),gisw_mc(1,1));
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n','LN+ME vs. LN',...
    mR2oos_mc(1,2),mCW_mc(1,2),utility_gains_mc(1,2),mDM_mc(1,2),gisw_mc(1,2));
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\\cmidrule{2-6}\n','CP+LN+ME vs. CP+LN',...
    mR2oos_mc(1,3),mCW_mc(1,3),utility_gains_mc(1,3),mDM_mc(1,3),gisw_mc(1,3));
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel B: Three-year bond}');
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n','CP+ME vs. CP',...
    mR2oos_mc(2,1),mCW_mc(2,1),utility_gains_mc(2,1),mDM_mc(2,1),gisw_mc(2,1));
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n','LN+ME vs. LN',...
    mR2oos_mc(2,2),mCW_mc(2,2),utility_gains_mc(2,2),mDM_mc(2,2),gisw_mc(2,2));
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\\cmidrule{2-6}\n','CP+LN+ME vs. CP+LN',...
    mR2oos_mc(2,3),mCW_mc(2,3),utility_gains_mc(2,3),mDM_mc(2,3),gisw_mc(2,3));
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel C: Four-year bond}');
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n','CP+ME vs. CP',...
    mR2oos_mc(3,1),mCW_mc(3,1),utility_gains_mc(3,1),mDM_mc(3,1),gisw_mc(3,1));
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n','LN+ME vs. LN',...
    mR2oos_mc(3,2),mCW_mc(3,2),utility_gains_mc(3,2),mDM_mc(3,2),gisw_mc(3,2));
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\\cmidrule{2-6}\n','CP+LN+ME vs. CP+LN',...
    mR2oos_mc(3,3),mCW_mc(3,3),utility_gains_mc(3,3),mDM_mc(3,3),gisw_mc(3,3));
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel D: Five-year bond}');
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n','CP+ME vs. CP',...
    mR2oos_mc(4,1),mCW_mc(4,1),utility_gains_mc(4,1),mDM_mc(4,1),gisw_mc(4,1));
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n','LN+ME vs. LN',...
    mR2oos_mc(4,2),mCW_mc(4,2),utility_gains_mc(4,2),mDM_mc(4,2),gisw_mc(4,2));
fprintf(fid,'%s & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n','CP+LN+ME vs. CP+LN',...
    mR2oos_mc(4,3),mCW_mc(4,3),utility_gains_mc(4,3),mDM_mc(4,3),gisw_mc(4,3));
fprintf(fid,'\n');
fclose(fid);

% Plotting the differences in cumulative realized utilities
figure;
for iFig = 1:7

    subplot(4,2,iFig);
    hold on

    b1 = bar(datenum_indx(86:end,1),nber(82:end,1).*4.95);
    b1.EdgeColor = 'none';
    b1.FaceColor = [0.8 0.8 0.8];
    b1.BarWidth = 1.2;
    b1.ShowBaseLine = 'off';
    set(get(get(b1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    b2 = bar(datenum_indx(86:end,1),nber(82:end,1).*-2.95);
    b2.EdgeColor = 'none';
    b2.FaceColor = [0.8 0.8 0.8];
    b2.BarWidth = 1.2;
    b2.ShowBaseLine = 'off';
    set(get(get(b2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    p1 = plot(datenum_indx(86:end,1),mDCRU(:,1+(iFig-1)*4));
    p1.LineStyle = '-'; p1.LineWidth = 1.6;
    p1.Color = line_color(1,:);

    p2 = plot(datenum_indx(86:end,1),mDCRU(:,2+(iFig-1)*4));
    p2.LineStyle = ':'; p2.LineWidth = 1.8;
    p2.Color = line_color(2,:);

    p3 = plot(datenum_indx(86:end,1),mDCRU(:,3+(iFig-1)*4));
    p3.LineStyle = '--'; p3.LineWidth = 1.6;
    p3.Color = line_color(3,:);

    p4 = plot(datenum_indx(86:end,1),mDCRU(:,4+(iFig-1)*4));
    p4.LineStyle = '-.'; p4.LineWidth = 1.6;
    p4.Color = line_color(4,:);

    hold off
    if iFig == 1
        leg = legend('2-year','3-year','4-year','5-year');
        set(leg,'Orientation','vertical','FontSize',6,'Box','off','Location','NorthWest');
    end
    datetick('x','yyyy');
    axis([min(datenum_indx(86:end,1))-150 max(datenum_indx(86:end,1))+50 -3 5]);
    set(gca,'YTIck',-2:2:4);
    set(gcf, 'PaperUnits', 'Centimeters','PaperSize',[19 21],'PaperPosition',[0.5 0.5 18 20]);
    title(model_list{iFig},'FontSize',8)
    box on

end
print(gcf,'-depsc','TeX/Figures/e_dcutil.eps');

% Writing results to LaTeX table
fid = fopen('TeX/Tables/e_forecast_combination.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s \\\\\\midrule\n','n',strvar{:,:});
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel A: Forecast combination using CP$_{t}$ and LN$_{t}$ models}');
fprintf(fid,'%.0f & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n',2,mR2oos(1,8),mCW(1,8),utility_gains(1,8),mDM(1,8),gisw(1,8));
fprintf(fid,'%.0f & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n',3,mR2oos(2,8),mCW(2,8),utility_gains(2,8),mDM(2,8),gisw(2,8));
fprintf(fid,'%.0f & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n',4,mR2oos(3,8),mCW(3,8),utility_gains(3,8),mDM(3,8),gisw(3,8));
fprintf(fid,'%.0f & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\\cmidrule{2-6}\n',5,mR2oos(4,8),mCW(4,8),utility_gains(4,8),mDM(4,8),gisw(4,8));
fprintf(fid,'%s & %s \\\\\\cmidrule{2-6}\n','','\multicolumn{5}{c}{Panel B: Forecast combination using all models}');
fprintf(fid,'%.0f & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n',2,mR2oos(1,9),mCW(1,9),utility_gains(1,9),mDM(1,9),gisw(1,9));
fprintf(fid,'%.0f & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n',3,mR2oos(2,9),mCW(2,9),utility_gains(2,9),mDM(2,9),gisw(2,9));
fprintf(fid,'%.0f & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n',4,mR2oos(3,9),mCW(3,9),utility_gains(3,9),mDM(3,9),gisw(3,9));
fprintf(fid,'%.0f & %.2f & [%.2f] & %.2f & [%.2f] & %.2f \\\\\n',5,mR2oos(4,9),mCW(4,9),utility_gains(4,9),mDM(4,9),gisw(4,9));
fprintf(fid,'\n');
fclose(fid);

%-----------------------------------------------------------------------------------------------------------------------
%% LINKS TO THE REAL ECONOMY
%-----------------------------------------------------------------------------------------------------------------------

disp('Computing correlations to assess links to the real economy');

% Smoothing out the CFNAI
cfnai = filter((1/3)*ones(3,1),1,cfnai);

% Computing correlation coefficients for differences in cumulative squared predictor errors and CFNAI
[corr_dcsfe,pval_corr_dcsfe]        = corr(mDCSFE,cfnai(init_window+2:end-4,1));
corr_dcsfe                          = reshape(corr_dcsfe,[4,10]);
pval_corr_dcsfe                     = reshape(pval_corr_dcsfe,[4,10]);

% Computing correlation coefficients for differences in cumulative realized utility and CFNAI
[corr_dcutil,pval_corr_dcutil]      = corr(mDCRU,cfnai(init_window+2:end-4,1));
corr_dcutil                         = reshape(corr_dcutil,[4,10]);
pval_corr_dcutil                    = reshape(pval_corr_dcutil,[4,10]);

% Computing correlation coefficients for model-implied forecasts and CFNAI
[corr_frcst,pval_corr_frcst]        = corr(mFrcst(:,5:end),cfnai(init_window+2:end-4,1));
corr_frcst                          = reshape(corr_frcst,[4,10]);
pval_corr_frcst                     = reshape(pval_corr_frcst,[4,10]);

% Computing correlation coefficients for model-implied forecasts and CFNAI
[corr_frcst_u,pval_corr_frcst_u]    = corr(mFrcst(:,5:end),macro_uncertainty(init_window+1:end-5,1));
corr_frcst_u                        = reshape(corr_frcst_u,[4,10]);
pval_corr_frcst_u                   = reshape(pval_corr_frcst_u,[4,10]);

% Setting up strings for table creation
model_list_extend = [model_list; {'FC1'}; {'FC2'}];
panel_a = '\multicolumn{4}{c}{Panel A: $\rho\left(\text{DCSPE}_{t},\text{CFNAI}_{t}\right)$}';
panel_b = '\multicolumn{4}{c}{Panel B: $\rho\left(\text{DCRU}_{t},\text{CFNAI}_{t}\right)$}';
panel_c = '\multicolumn{4}{c}{Panel C: $\rho\left(\mathbb{E}_{t}rx_{t+4}^{\left(n\right)},\text{CFNAI}_{t}\right)$}';
panel_d = '\multicolumn{4}{c}{Panel D: $\rho\left(\mathbb{E}_{t}rx_{t+4}^{\left(n\right)},\mathbb{U}_{t}^{\text{Macro}}\right)$}';
n_years  = {'2-year','3-year','4-year','5-year'};

% Writing correlations to LaTeX table
fid = fopen('TeX/Tables/e_links_to_the_real_economy.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s & %s & %s & %s & %s & %s \\\\\\midrule\n','',n_years{:,:},'',n_years{:,:});
fprintf(fid,'%s & %s & %s & %s  \\\\\\cmidrule{2-5}\\cmidrule{7-10}\n','',panel_a,'',panel_b);
for iModel = 1:9
    if iModel == 9
        fprintf(fid,...
        '%s & %.2f & %.2f & %.2f & %.2f & %s & %.2f & %.2f & %.2f & %.2f \\\\\\cmidrule{2-5}\\cmidrule{7-10}\n',...
        model_list_extend{iModel},corr_dcsfe(:,iModel),'',corr_dcutil(:,iModel));
    else
        fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %s & %.2f & %.2f & %.2f & %.2f \\\\\n',...
        model_list_extend{iModel},corr_dcsfe(:,iModel),'',corr_dcutil(:,iModel));
    end
end
fprintf(fid,'%s & %s & %s & %s  \\\\\\cmidrule{2-5}\\cmidrule{7-10}\n','',panel_c,'',panel_d);
for iModel = 1:9
    fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f & %s & %.2f & %.2f & %.2f & %.2f \\\\\n',...
        model_list_extend{iModel},corr_frcst(:,iModel),'',corr_frcst_u(:,iModel));
end
fprintf(fid, '\n');
fclose(fid);

%-----------------------------------------------------------------------------------------------------------------------
%% ESTIMATING FORECASTING MODELS IN-SAMPLE FOR GSW BOND DATA
%-----------------------------------------------------------------------------------------------------------------------
%{
    To verify that our results are not only applicable to annual excess holding period bond returns, we run in-sample
    regression of quarterly excess holding period bond returns on one-quarter ahead survey expectations and the same 
    set of benchmark predictors as above.     
%}
%-----------------------------------------------------------------------------------------------------------------------

disp('Estimating forecasting models in-sample for GSW bond data');

% Estimating forecasting models in-sample
[b_me,~,tb_me,adr2_me]                  = linear_reg(rxGSW,ME_gsw,1,'NW',6);
[b_cp,~,tb_cp,~,adr2_cp]                = linear_reg(rxGSW,CP_gsw,1,'NW',6);
[b_ln,~,tb_ln,~,adr2_ln]                = linear_reg(rxGSW,LN_gsw,1,'NW',1);
[b_cpme,~,tb_cpme,~,adr2_cpme]          = linear_reg(rxGSW,[CP_gsw ME_gsw],1,'NW',6);
[b_lnme,~,tb_lnme,~,adr2_lnme]          = linear_reg(rxGSW,[LN_gsw ME_gsw],1,'NW',6);
[b_cpln,~,tb_cpln,~,adr2_cpln]          = linear_reg(rxGSW,[CP_gsw LN_gsw],1,'NW',6);
[b_cplnme,~,tb_cplnme,~,adr2_cplnme]    = linear_reg(rxGSW,[CP_gsw LN_gsw ME_gsw],1,'NW',6);

% Writing results to LaTeX table
fid = fopen('TeX/Tables/e_insample_results_gsw_bonds.tex','w');
fprintf(fid,'%s & %s & %s & %s & %s \\\\\\midrule\n','',factor_list_gsw{1:3},'adj R$^{2}\left(\%\right)$');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-5}\n','','\multicolumn{4}{c}{Panel A: Two-year bond}');
fprintf(fid,'%s & %s & %s & %.2f & %.2f \\\\\n','(a)','','',b_me(2,1),adr2_me(1).*100);
fprintf(fid,'%s & %s & %s & (%.2f) & %s \\\\\n','','','',tb_me(2,1),'');
fprintf(fid,'%s & %.2f & %s & %.2f & %.2f \\\\\n','(b)',b_cpme(2,1),'',b_cpme(3,1),adr2_cpme(1).*100);
fprintf(fid,'%s & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_cpme(2,1),'',tb_cpme(3,1),'');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f \\\\\n','(c)','',b_lnme(2:3,1),adr2_lnme(1).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & %s \\\\\n','','',tb_lnme(2:3,1),'');
fprintf(fid,'%s & %.2f & %.2f & %s & %.2f \\\\\n','(d)',b_cpln(2:3,1),'',adr2_cpln(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_cpln(2:3,1),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f \\\\\n','(e)',b_cplnme(2:4,1),adr2_cplnme(1).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s \\\\\\cmidrule{2-5}\n','',tb_cplnme(2:4,1),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-5}\n','','\multicolumn{4}{c}{Panel B: Three-year bond}');
fprintf(fid,'%s & %s & %s & %.2f & %.2f \\\\\n','(a)','','',b_me(2,2),adr2_me(2).*100);
fprintf(fid,'%s & %s & %s & (%.2f) & %s \\\\\n','','','',tb_me(2,2),'');
fprintf(fid,'%s & %.2f & %s & %.2f & %.2f \\\\\n','(b)',b_cpme(2,2),'',b_cpme(3,2),adr2_cpme(2).*100);
fprintf(fid,'%s & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_cpme(2,2),'',tb_cpme(3,2),'');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f \\\\\n','(c)','',b_lnme(2:3,2),adr2_lnme(2).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & %s \\\\\n','','',tb_lnme(2:3,2),'');
fprintf(fid,'%s & %.2f & %.2f & %s & %.2f \\\\\n','(d)',b_cpln(2:3,2),'',adr2_cpln(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_cpln(2:3,2),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f \\\\\n','(e)',b_cplnme(2:4,2),adr2_cplnme(2).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s \\\\\\cmidrule{2-5}\n','',tb_cplnme(2:4,2),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-5}\n','','\multicolumn{4}{c}{Panel C: Four-year bond}');
fprintf(fid,'%s & %s & %s & %.2f & %.2f \\\\\n','(a)','','',b_me(2,3),adr2_me(3).*100);
fprintf(fid,'%s & %s & %s & (%.2f) & %s \\\\\n','','','',tb_me(2,3),'');
fprintf(fid,'%s & %.2f & %s & %.2f & %.2f \\\\\n','(b)',b_cpme(2,3),'',b_cpme(3,3),adr2_cpme(3).*100);
fprintf(fid,'%s & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_cpme(2,3),'',tb_cpme(3,3),'');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f \\\\\n','(c)','',b_lnme(2:3,3),adr2_lnme(3).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & %s \\\\\n','','',tb_lnme(2:3,3),'');
fprintf(fid,'%s & %.2f & %.2f & %s & %.2f \\\\\n','(d)',b_cpln(2:3,3),'',adr2_cpln(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_cpln(2:3,3),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f \\\\\n','(e)',b_cplnme(2:4,3),adr2_cplnme(3).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s \\\\\\cmidrule{2-5}\n','',tb_cplnme(2:4,3),'');
fprintf(fid,'%s & %s \\\\\\cmidrule{2-5}\n','','\multicolumn{4}{c}{Panel D: Five-year bond}');
fprintf(fid,'%s & %s & %s & %.2f & %.2f \\\\\n','(a)','','',b_me(2,4),adr2_me(4).*100);
fprintf(fid,'%s & %s & %s & (%.2f) & %s \\\\\n','','','',tb_me(2,4),'');
fprintf(fid,'%s & %.2f & %s & %.2f & %.2f \\\\\n','(b)',b_cpme(2,4),'',b_cpme(3,4),adr2_cpme(4).*100);
fprintf(fid,'%s & (%.2f) & %s & (%.2f) & %s \\\\\n','',tb_cpme(2,4),'',tb_cpme(3,4),'');
fprintf(fid,'%s & %s & %.2f & %.2f & %.2f \\\\\n','(c)','',b_lnme(2:3,4),adr2_lnme(4).*100);
fprintf(fid,'%s & %s & (%.2f) & (%.2f) & %s \\\\\n','','',tb_lnme(2:3,4),'');
fprintf(fid,'%s & %.2f & %.2f & %s & %.2f \\\\\n','(d)',b_cpln(2:3,4),'',adr2_cpln(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & %s & %s \\\\\n','',tb_cpln(2:3,4),'','');
fprintf(fid,'%s & %.2f & %.2f & %.2f & %.2f \\\\\n','(e)',b_cplnme(2:4,4),adr2_cplnme(4).*100);
fprintf(fid,'%s & (%.2f) & (%.2f) & (%.2f) & %s \\\\\n','',tb_cplnme(2:4,4),'');
fprintf(fid,'\n');
fclose(fid);

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING CODE RUN TIME
%-----------------------------------------------------------------------------------------------------------------------

tEnd = toc(tStart);
fprintf('Runtime: %d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));
disp('Routine Completed');

%-----------------------------------------------------------------------------------------------------------------------
% END OF SCRIPT
%-----------------------------------------------------------------------------------------------------------------------