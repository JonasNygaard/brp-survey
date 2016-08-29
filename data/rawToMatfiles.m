%% rawToMatfiles.m
%-----------------------------------------------------------------------------------------------------------------------
%
%   This script loads all raw data files from the raw/ folder, sets transformation codes for the macroeconomic 
%   data panel, and performs minor data preparation tasks. The raw data is loaded in from excel and tab delimited text
%   files. The loaded raw data is then stored in category specific .mat files for faster loading time in the data 
%   making scripts contained in this folder. 
%
%   --------------------------------
%   Last modified: December, 2015
%   --------------------------------
%
%-----------------------------------------------------------------------------------------------------------------------

clear; clc; tStart = tic; close all; format shortg; c = clock;
disp('-------------------------------------------------------------------------------------');
disp('Running the rawToMatfiles.m script.'                                                  );
fprintf('Code initiated at %.0f:%.0f on %.0f / %0.f - %0.f \n',c(4:5),c(3),c(2),c(1)        );
disp('-------------------------------------------------------------------------------------');

%-----------------------------------------------------------------------------------------------------------------------
%% LOADING REAL-TIME MACROECONOMIC DATA FROM ALFRED
%-----------------------------------------------------------------------------------------------------------------------

disp('Loading real-time macroeconomic data from ALFRED');

% Loading real-time data vintages
tcode           = nan(67,1);
ALFRED         = cell(1,67);
ALFRED{1,1}    = xlsread('raw/ALFRED/AWHMAN_2','Data','a3:kz996');        tcode(1)    = 1;
ALFRED{1,2}    = xlsread('raw/ALFRED/AWHNONAG_2','Data','a3:kz612');      tcode(2)    = 2;
ALFRED{1,3}    = xlsread('raw/ALFRED/AWOTMAN_2','Data','a3:kz708');       tcode(3)    = 2;
ALFRED{1,4}    = xlsread('raw/ALFRED/CE16OV_2','Data','a3:kz810');        tcode(4)    = 5;
ALFRED{1,5}    = xlsread('raw/ALFRED/CLF16OV_2','Data','a3:kz810');       tcode(5)    = 5;
ALFRED{1,6}    = xlsread('raw/ALFRED/CPIAUCSL_2','Data','a3:kz815');      tcode(6)    = 6;
ALFRED{1,7}    = xlsread('raw/ALFRED/CURRDD_2','Data','a3:kz816');        tcode(7)    = 6;
ALFRED{1,8}    = xlsread('raw/ALFRED/CURRSL_2','Data','a3:kz815');        tcode(8)    = 5;
ALFRED{1,9}    = xlsread('raw/ALFRED/DEMDEPSL_2','Data','a3:kz816');      tcode(9)    = 6;
ALFRED{1,10}   = xlsread('raw/ALFRED/DMANEMP_2','Data','a3:kz912');       tcode(10)   = 5;
ALFRED{1,11}   = xlsread('raw/ALFRED/DSPI_2','Data','a3:kz671');          tcode(11)   = 5;
ALFRED{1,12}   = xlsread('raw/ALFRED/DSPIC96_2','Data','a3:kz671');       tcode(12)   = 5;
ALFRED{1,13}   = xlsread('raw/ALFRED/HOUST_2','Data','a3:kz672');         tcode(13)   = 4;
ALFRED{1,14}   = xlsread('raw/ALFRED/HOUST1F_2','Data','a3:kz672');       tcode(14)   = 4;
ALFRED{1,15}   = xlsread('raw/ALFRED/HOUST2F_2','Data','a3:kz617');       tcode(15)   = 4;
ALFRED{1,16}   = xlsread('raw/ALFRED/HOUSTMW_2','Data','a3:kz672');       tcode(16)   = 4;
ALFRED{1,17}   = xlsread('raw/ALFRED/HOUSTNE_2','Data','a3:kz672');       tcode(17)   = 4;
ALFRED{1,18}   = xlsread('raw/ALFRED/HOUSTS_2','Data','a3:kz672');        tcode(18)   = 4;
ALFRED{1,19}   = xlsread('raw/ALFRED/HOUSTW_2','Data','a3:kz672');        tcode(19)   = 4;
ALFRED{1,20}   = xlsread('raw/ALFRED/INDPRO_2','Data','a3:kz1152');       tcode(20)   = 5;
ALFRED{1,21}   = xlsread('raw/ALFRED/M1SL_2','Data','a3:kz672');          tcode(21)   = 6;
ALFRED{1,22}   = xlsread('raw/ALFRED/M2SL_2','Data','a3:kz672');          tcode(22)   = 6;
ALFRED{1,23}   = xlsread('raw/ALFRED/MANEMP_2','Data','a3:kz912');        tcode(23)   = 5;
ALFRED{1,24}   = xlsread('raw/ALFRED/NDMANEMP_2','Data','a3:kz912');      tcode(24)   = 5;
ALFRED{1,25}   = xlsread('raw/ALFRED/OCDSL_2','Data','a3:kz672');         tcode(25)   = 6;
ALFRED{1,26}   = xlsread('raw/ALFRED/PAYEMS_2','Data','a3:kz912');        tcode(26)   = 5;
ALFRED{1,27}   = xlsread('raw/ALFRED/PCE_2','Data','a3:kz671');           tcode(27)   = 5;
ALFRED{1,28}   = xlsread('raw/ALFRED/PCEDG_2','Data','a3:kz671');         tcode(28)   = 5;
ALFRED{1,29}   = xlsread('raw/ALFRED/PCEND_2','Data','a3:kz671');         tcode(29)   = 5;
ALFRED{1,30}   = xlsread('raw/ALFRED/PCES_2','Data','a3:kz671');          tcode(30)   = 5;
ALFRED{1,31}   = xlsread('raw/ALFRED/PFCGEF_2','Data','a3:kz813');        tcode(31)   = 6;
ALFRED{1,32}   = xlsread('raw/ALFRED/PI_2','Data','a3:kz827');            tcode(32)   = 5;
ALFRED{1,33}   = xlsread('raw/ALFRED/PPICPE_2','Data','a3:kz813');        tcode(33)   = 6;
ALFRED{1,34}   = xlsread('raw/ALFRED/PPICRM_2','Data','a3:kz813');        tcode(34)   = 6;
ALFRED{1,35}   = xlsread('raw/ALFRED/PPIFCF_2','Data','a3:kz813');        tcode(35)   = 6;
ALFRED{1,36}   = xlsread('raw/ALFRED/PPIFGS_2','Data','a3:kz813');        tcode(36)   = 6;
ALFRED{1,37}   = xlsread('raw/ALFRED/PPIIFF_2','Data','a3:kz576');        tcode(37)   = 6;
ALFRED{1,38}   = xlsread('raw/ALFRED/PPIITM_2','Data','a3:kz813');        tcode(38)   = 6;
ALFRED{1,39}   = xlsread('raw/ALFRED/SAVINGSL_2','Data','a3:kz672');      tcode(39)   = 6;
ALFRED{1,40}   = xlsread('raw/ALFRED/SRVPRD_2','Data','a3:kz912');        tcode(40)   = 5;
ALFRED{1,41}   = xlsread('raw/ALFRED/STDCBSL_2','Data','a3:kz672');       tcode(41)   = 6;
ALFRED{1,42}   = xlsread('raw/ALFRED/STDSL_2','Data','a3:kz672');         tcode(42)   = 6;
ALFRED{1,43}   = xlsread('raw/ALFRED/STDTI_2','Data','a3:kz672');         tcode(43)   = 6;
ALFRED{1,44}   = xlsread('raw/ALFRED/SVGCBSL_2','Data','a3:kz672');       tcode(44)   = 6;
ALFRED{1,45}   = xlsread('raw/ALFRED/SVGTI_2','Data','a3:kz672');         tcode(45)   = 6;
ALFRED{1,46}   = xlsread('raw/ALFRED/SVSTCBSL_2','Data','a3:kz672');      tcode(46)   = 6;
ALFRED{1,47}   = xlsread('raw/ALFRED/SVSTSL_2','Data','a3:kz672');        tcode(47)   = 6;
ALFRED{1,48}   = xlsread('raw/ALFRED/TCDSL_2','Data','a3:kz672');         tcode(48)   = 6;
ALFRED{1,49}   = xlsread('raw/ALFRED/UEMP5TO14_2','Data','a3:kz804');     tcode(49)   = 5;
ALFRED{1,50}   = xlsread('raw/ALFRED/UEMP15OV_2','Data','a3:kz804');      tcode(50)   = 5;
ALFRED{1,51}   = xlsread('raw/ALFRED/UEMP15T26_2','Data','a3:kz804');     tcode(51)   = 5;
ALFRED{1,52}   = xlsread('raw/ALFRED/UEMP27OV_2','Data','a3:kz804');      tcode(52)   = 5;
ALFRED{1,53}   = xlsread('raw/ALFRED/UEMPLT5_2','Data','a3:kz804');       tcode(53)   = 5;
ALFRED{1,54}   = xlsread('raw/ALFRED/UEMPMEAN_2','Data','a3:kz804');      tcode(54)   = 2;
ALFRED{1,55}   = xlsread('raw/ALFRED/UEMPMED_2','Data','a3:kz570');       tcode(55)   = 2;
ALFRED{1,56}   = xlsread('raw/ALFRED/UNEMPLOY_2','Data','a3:kz804');      tcode(56)   = 5;
ALFRED{1,57}   = xlsread('raw/ALFRED/UNRATE_2','Data','a3:kz804');        tcode(57)   = 2;
ALFRED{1,58}   = xlsread('raw/ALFRED/USCONS_2','Data','a3:kz912');        tcode(58)   = 5;
ALFRED{1,59}   = xlsread('raw/ALFRED/USFIRE_2','Data','a3:kz912');        tcode(59)   = 5;
ALFRED{1,60}   = xlsread('raw/ALFRED/USGOOD_2','Data','a3:kz912');        tcode(60)   = 5;
ALFRED{1,61}   = xlsread('raw/ALFRED/USGOVT_2','Data','a3:kz912');        tcode(61)   = 5;
ALFRED{1,62}   = xlsread('raw/ALFRED/USMINE_2','Data','a3:kz912');        tcode(62)   = 5;
ALFRED{1,63}   = xlsread('raw/ALFRED/USPRIV_2','Data','a3:kz912');        tcode(63)   = 5;
ALFRED{1,64}   = xlsread('raw/ALFRED/USSERV_2','Data','a3:kz912');        tcode(64)   = 5;
ALFRED{1,65}   = xlsread('raw/ALFRED/USTPU_2','Data','a3:kz912');         tcode(65)   = 5;
ALFRED{1,66}   = xlsread('raw/ALFRED/USTRADE_2','Data','a3:kz912');       tcode(66)   = 5;
ALFRED{1,67}   = xlsread('raw/ALFRED/USWTRADE_2','Data','a3:kz912');      tcode(67)   = 5;

%-----------------------------------------------------------------------------------------------------------------------
%% LOADING BOND DATA FROM FB AND GSW DATASETS
%-----------------------------------------------------------------------------------------------------------------------

disp('Loading bond data from FB and GSW datasets');

% Loading bond data
mFB         = dlmread('raw/FB/FBprices.txt','\t',1,0);
mGSW        = xlsread('raw/GSW/feds200628','Yields','b11:cw13375');
tbill       = xlsread('raw/FRED/TB3MS','TB3MS','b342:b984');

% Transform to log treasury bill
tbill       = log(1+tbill(3:3:end,1)./100);

% Preparing Gurkaynak-Sack-Wright (GSW) data.
mGSW        = flip(mGSW); % Flipping data such that time progresses down the rows
datemat     = datevec(x2mdate(mGSW(:,1),0));
mGSW        = [datemat(:,1:3) mGSW(:,2:end)]; 

%-----------------------------------------------------------------------------------------------------------------------
%% LOADING SURVEY DATA FROM SPF
%-----------------------------------------------------------------------------------------------------------------------

disp('Loading survey data from SPF');

% Loading survey data
mNGDP       = xlsread('raw/SPF/Individual/Individual_NGDP','NGDP','a2:k7517');
mRGDP       = xlsread('raw/SPF/Individual/Individual_RGDP','RGDP','a2:k7517');
mPGDP       = xlsread('raw/SPF/Individual/Individual_PGDP','PGDP','a2:k7517');
mCPROF      = xlsread('raw/SPF/Individual/Individual_CPROF','CPROF','a2:k7517');
mUNEMP      = xlsread('raw/SPF/Individual/Individual_UNEMP','UNEMP','a2:k7517');
mINDPROD    = xlsread('raw/SPF/Individual/Individual_INDPROD','INDPROD','a2:k7517');
mHOUSING    = xlsread('raw/SPF/Individual/Individual_HOUSING','HOUSING','a2:k7517');

%-----------------------------------------------------------------------------------------------------------------------
%% LOADING CFNAI INDEX AND NBER RECESSION DATA
%-----------------------------------------------------------------------------------------------------------------------

disp('Loading CFNAI index and NBER recession data');

% Loading CFNAI and NBER dates
cfnai 			= dlmread('raw/CFNAI/CFNAI.txt','',39,1);
cfnai 			= cfnai(1:3:end,1);
nber 			= xlsread('raw/FRED/USREC','USREC','b1439:b1979');
nber 			= nber(1:3:end,1);
nber(nber == 0) = NaN;

%-----------------------------------------------------------------------------------------------------------------------
%% LOADING MACROECONOMIC UNCERTAINTY SERIES FROM JURADO, LUDVIGSON, AND NG
%-----------------------------------------------------------------------------------------------------------------------

disp('Loading macroeconomic uncertainty data');

macro_uncertainty   = xlsread('raw/JLN/MacroUncertaintyToCirculate','Macro Uncertainty','b102:d655');
macro_uncertainty   = macro_uncertainty(1:3:end,:);

%-----------------------------------------------------------------------------------------------------------------------
%% STORING DATA IN CATEGORY SPECIFIC MAT FILES
%-----------------------------------------------------------------------------------------------------------------------

% Saving data to .mat files
save('matfiles/ALFRED.mat','ALFRED','tcode');
save('matfiles/FB.mat','mFB');
save('matfiles/GSW.mat','mGSW','tbill');
save('matfiles/SPF.mat','mNGDP','mRGDP','mPGDP','mCPROF','mUNEMP','mINDPROD','mHOUSING');
save('matfiles/FRED.mat','cfnai','nber');
save('matfiles/JLN.mat','macro_uncertainty');

%-----------------------------------------------------------------------------------------------------------------------
%% COMPUTING CODE RUN TIME
%-----------------------------------------------------------------------------------------------------------------------

tEnd = toc(tStart);
fprintf('Runtime: %d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));
disp('Routine Completed');

%-----------------------------------------------------------------------------------------------------------------------
% END OF SCRIPT
%-----------------------------------------------------------------------------------------------------------------------