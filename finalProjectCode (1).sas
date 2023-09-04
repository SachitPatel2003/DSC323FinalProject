/*Sachit Patel Final Project
Seoul Bike Sharing*/
data bikeSharing;
TITLE "Bike Sharing Data";
/*Calling the file and setting it up properly*/
infile 'SeoulBikeSharing.csv' delimiter=',' MISSOVER FIRSTOBS=2;
input date $ rentalbc hour temperatureC humidityP windSpdMs visibility10m dptC 
solarRadiation rainfallMm snowfallCm Season $ Holiday $ functioningDay $;
/*Dummy Variables*/
/*Holiday 0 = no holiday, 1 = holiday*/
numHoliday = 0;
if Holiday = 'Holiday' then numHoliday = 1;
/*Functioning Day 0 = no, 1 = yes*/
numFunc = 1;
if functioningDay = "No" then numFunc = 0;
/*Seasons 0 = Winter, 1 = Spring, 2 = Summer, 3 = Autumn*/
numSeason = 0;
if Season = "Spring" then numSeason = 1;
else if Season = "Summer" then numSeason = 2;
else if Season = "Autumn" then numSeason = 3;
/*Interaction Terms*/
hour_numFunc = hour*numFunc;
hour_numHoliday = hour*numHoliday;
/*Transformations*/
lnrbc = log(rentalbc);
sqrtrbc = SQRT(rentalbc);
run;
proc print;
run;

/*EXPLORATORY ANALYSIS*/
/*Histograms*/
/*Histogram rbc*/
TITLE "Rental Bike Day Count";
PROC UNIVARIATE normal;
VAR rentalbc;
histogram / normal (mu = est sigma = est);
RUN;
/*Histogram ln*/
TITLE "Log Rental Bike Day Count";
PROC UNIVARIATE normal;
VAR lnrbc;
histogram / normal (mu = est sigma = est);
RUN;
/*Histogram sqrt*/
TITLE "Root Rental Bike Day Count";
PROC UNIVARIATE normal;
VAR sqrtrbc;
histogram / normal (mu = est sigma = est);
RUN;
/*Histogram sq*/
TITLE "Squared Rental Bike Day Count";
PROC UNIVARIATE normal;
VAR rbcsq;
histogram / normal (mu = est sigma = est);
RUN;
/*Histogram cu*/
TITLE "Cubed Rental Bike Day Count";
PROC UNIVARIATE normal;
VAR rbccu;
histogram / normal (mu = est sigma = est);
RUN;
/*Histogram rbi*/
TITLE "Reciprocal Rental Bike Day Count";
PROC UNIVARIATE normal;
VAR rbcrbi;
histogram / normal (mu = est sigma = est);
RUN;

/*Histogram of Predictors*/
TITLE "Predictor Histogram";
PROC UNIVARIATE normal;
VAR windSpdMs;
histogram / normal (mu = est sigma = est);
RUN;

/*Boxplots*/
/*Rainfall*/
TITLE "Boxplot";
PROC SORT;
BY rentalbc;
RUN;
*Create Boxplot;
PROC BOXPLOT;
*1st var = x variable, 2nd var = y variable;
PLOT rentalbc*rainfallMm;
RUN;

/*Correlation Table*/
PROC CORR;
TITLE "Bike Rental Correlation Values";
VAR rentalbc hour temperatureC humidityP windSpdMs visibility10m dptC 
solarRadiation rainfallMm snowfallCm numSeason numHoliday numFunc;
RUN;
/*Sqrt Correlation*/
PROC CORR;
TITLE "Sqrt Bike Rental Correlation Values";
VAR sqrtrbc hour temperatureC humidityP windSpdMs visibility10m dptC 
solarRadiation rainfallMm snowfallCm numSeason numHoliday numFunc;
RUN;
/*Ln Correlation*/
PROC CORR;
TITLE "Log Bike Rental Correlation Values";
VAR lnrbc hour temperatureC humidityP windSpdMs visibility10m dptC 
solarRadiation rainfallMm snowfallCm numSeason numHoliday numFunc;
RUN;
/*Correlation Table used for presentation*/
PROC CORR;
TITLE "Bike Rental Correlation Values";
VAR rentalbc hour temperatureC humidityP windSpdMs visibility10m 
rainfallMm snowfallCm numSeason numHoliday;
RUN;

/*Means Procedure*/
PROC MEANS mean std stderr clm min p25 p50 p75 max n;
RUN;

/*Matrix Plot*/
PROC SGSCATTER;
TITLE "Rental Bike Count Matrix";
Matrix rentalbc hour temperatureC humidityP windSpdMs visibility10m dptC 
solarRadiation rainfallMm snowfallCm numSeason numHoliday numFunc;
RUN;
/*Matrix Ln Plot*/
PROC SGSCATTER;
TITLE "Rental Bike Count Matrix";
Matrix lnrbc hour temperatureC humidityP windSpdMs visibility10m dptC 
solarRadiation rainfallMm snowfallCm numSeason numHoliday numFunc;
RUN;
/*Matrix Ln Plot version 2*/
PROC SGSCATTER;
TITLE "Log Rental Bike Count Matrix";
Matrix lnrbc hour temperatureC humidityP windSpdMs visibility10m  
solarRadiation rainfallMm snowfallCm numSeason numHoliday ;
RUN;

/*GPLOT EXPLORATION*/
proc gplot;
plot lnrbc*temperatureC;
run;

/*MODELING PHASE
TWO MODELS TO BE EXPERIMENTED WITH*/

/*FULL MODEL*/
PROC REG;
TITLE "FULL MODEL M1";
MODEL rentalbc = hour temperatureC humidityP windSpdMs visibility10m dptC 
solarRadiation rainfallMm snowfallCm numSeason numHoliday numFunc/vif;
RUN;

/*FIRST EDIT MODEL*/
PROC REG;
TITLE "FIRST EDIT MODEL M1";
MODEL rentalbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday numFunc/vif;
RUN;

/*FULL MODEL LNRBC*/
PROC REG;
TITLE "FULL MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m dptC 
solarRadiation rainfallMm snowfallCm numSeason numHoliday numFunc/vif;
RUN;

/*FIRST EDIT MODEL LNRBC*/
PROC REG;
TITLE "FIRST EDIT MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday/vif; 
RUN;

/*SECOND EDIT MODEL LNRBC*/
PROC REG;
TITLE "SECOND EDIT MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday hour_numFunc hour_numHoliday/vif; 
RUN;

/*OUTLIERS AND INFLUENTIAL POINTS*/
/*Addressing Outliers and Influential Points*/
PROC REG;
TITLE "FIRST EDIT MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday/r cli clm; 
RUN;
/*Outliers noted down, tracked*/
/*Deleting outliers with studentualized residuals > 3 or < -3*/
data bikeSharingNew;
set bikeSharing;
if _n_ in (2150,2151,2153,2154,2157,2159,2238,2253,2254,2255,2256,2259,2260,2261,2333,2501,
2502,2504,2596,2597,3006,3105,3222,3223,3258,3345,3426,3428,3429,3431,3432,3436,3437,3438,
3444,3446,3448,3750,3751,3754,3755,3766,3899,3901,3907,3909,3910,3911,3998,4013,4017,4028,4030,
4149,4151,4974,4975,4981,4983,5035,5096,5097,5098,5103,5105,5106,5107,5110,5111,5112,
5115,5118,5124,5132,5133,5301,5304,6317,6389,6493,6499,6502,6641,7060,7062,7063,7403,7404,7405,
7407,7408,7413,7414,7415,7416,7426,7427,7428,7909,7910,7950,8219,8220,8222,8225,8226,8228,8229,8231,
8232) then delete;
/*Influential Point Deletion*/
*if _n_ in (458,481,482,489,506,507,512,514,726,727,1267,1543,1566,1872,1879,1880,1901,1902,2024,2025,
2027,2150,2246,2247,2275,2488,3002,3007,3011,3012,3033,3083,3084,3232,3321,3412,3413,3424,3428,3588,3589,3590,3595,
3596,3597,3598,3599,3600,3601,3602,3603,3604,3605,3606,3607,3608,3609,3610,3625,3631,3712,3713,3714,3715,3897,3942,3984,
4075,4076,4077,4078,4080,4081,4082,4085,4086,4087,4088,4089,4090,4091,4092,4093,4094,4095,4096,4097,4099,4106) then delete;
if _n_ in (222, 228) then delete;
*add 1 to deleted obs;
/*0s deletion*/
if rentalbc = 0 then delete;
run;


/*Post outlier removal model*/
PROC REG DATA = bikeSharingNew;
TITLE "SECOND EDIT MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday; 
RUN;

/*Influential Points Research*/
PROC REG DATA = bikeSharingNew;
TITLE "SECOND EDIT MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday/influence; 
RUN;

/*LNRBC M2 MODEL Assumptions*/
PROC REG DATA = bikeSharingNew;
TITLE "SECOND EDIT MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday; 
plot student.*(hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday); /*Residuals*/
plot residual.*(hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday);
plot student.*predicted.;
plot residual.*predicted.;
plot npp.*student.; /*Normality Assumptions*/
RUN;

/*MODEL SELECTION ADJRSQ*/
PROC REG DATA = bikeSharingNew;
TITLE "MODEL SELECTION MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday/selection=adjrsq; 
RUN;

/*MODEL SELECTION STEPWISE*/
PROC REG DATA = bikeSharingNew;
TITLE "MODEL SELECTION MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday/selection=stepwise; 
RUN;

/*MODEL SELECTION BACKWARD*/
PROC REG DATA = bikeSharingNew;
TITLE "MODEL SELECTION MODEL M2";
MODEL lnrbc = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday/selection=backward; 
RUN;

/*FINAL MODEL M1 BY SELECTION METHODS*/
PROC REG DATA = bikeSharingNew plots(maxpoints=none);
TITLE "FINAL MODEL M1";
MODEL lnrbc = hour temperatureC humidityP visibility10m rainfallMm 
snowfallCm numSeason numHoliday hour_numFunc;
plot student.*predicted.;
plot student.*(hour temperatureC humidityP visibility10m rainfallMm 
snowfallCm numSeason numHoliday hour_numFunc);
plot npp.*student.;
RUN;

/*PROC GLMSELECT ATTEMPT*/
PROC GLMSELECT DATA = bikeSharingNew;
MODEL lnrbc= hour|temperatureC|humidityP|visibility10m|rainfallMm|snowfallCm|numSeason|numHoliday|hour_numFunc @2/selection=stepwise(stop=cv);
run;


/*Model Validation
Attempts, Before the Final Model*/
data bikeXV;
proc surveyselect data=bikeSharingNew
	OUT = bikeXV SEED=23
	SAMPRATE = 0.75 OUTALL;
	RUN;
*Model Split Process;
	data bikeXV;
	set bikeXV;
	if selected then new_y=lnrbc;
	run;
	proc print data=bikeXV;
	run;
*Training and Testing Split achieved, shown through selection values;
*Value 1 -> Training set. Value 0 -> Testing Set;
/*Validation Test Set, Stepwise*/
TITLE "Validation Test Set STEPWISE";
PROC REG DATA = bikeXV;
MODEL new_y = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday hour_numFunc hour_numHoliday/selection=stepwise;
run;

/*Validation Test Set, BACKWARD*/
TITLE "Validation Test Set Backward";
PROC REG DATA = bikeXV;
MODEL new_y = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday hour_numFunc hour_numHoliday/selection=backward;
run;

/*Validation Test Set, CP*/
TITLE "Validation Test Set CP";
PROC REG DATA = bikeXV;
MODEL new_y = hour temperatureC humidityP windSpdMs visibility10m 
solarRadiation rainfallMm snowfallCm numSeason numHoliday hour_numFunc hour_numHoliday/selection=cp;
run;

*Same model chosen by CP and Backward;
/*TRAINING SET SELECTED MODEL*/
TITLE "TRAINING SET SELECTED MODEL";
PROC REG DATA = bikeXV plots(maxpoints=none);
MODEL new_y = hour temperatureC humidityP visibility10m rainfallMm snowfallCm numSeason numHoliday hour_numHoliday;
output out=outm1(where=(new_y=.))p=yhat;
RUN;
*PREDICTED VALUES, TESTING SET;
proc print data=outm1;
run;

/*CROSS VALIDATION*/
TITLE "Net difference between observed and predicted values";
data outm1_sum;
set outm1;
d = lnrbc-yhat; *Observed-Predicted;
absd = abs(d);
run;
proc print data=outm1_sum;
run;

/*Compute Predicted Statisics: RMSE, Mean Absolute Error (MAE)*/
proc summary data=outm1_sum;
var d absd;
output out=outm1_stats std(d)=rmse mean(absd)=mae;
run;
proc print data=outm1_stats;
TITLE "Validation Statistics for Model";
run;
*computes correlation values of observed and predicted values in test set;
TITLE "Validation Correlation Values";
proc corr data=outm1;
var lnrbc yhat;
run;

/*FINAL MODEL*/
TITLE "FINAL MODEL";
PROC REG DATA = bikeSharingNew plots(maxpoints=none);
MODEL lnrbc = hour temperatureC humidityP visibility10m rainfallMm 
snowfallCm numSeason numHoliday hour_numHoliday;
RUN;

/*FINAL MODEL*/
TITLE "FINAL MODEL";
PROC REG DATA = bikeSharingNew plots(maxpoints=none);
MODEL lnrbc = hour temperatureC humidityP visibility10m rainfallMm 
snowfallCm numSeason numHoliday hour_numHoliday/p clm cli;
RUN;
*Confidence intervals created for the final model.;

/*FINAL MODEL RESIDUALS*/
TITLE "FINAL MODEL";
PROC REG DATA = bikeSharingNew plots(maxpoints=none);
MODEL lnrbc = hour temperatureC humidityP visibility10m rainfallMm snowfallCm numSeason numHoliday hour_numHoliday;
plot student.*predicted.;
plot student.*(hour temperatureC humidityP visibility10m rainfallMm snowfallCm numSeason numHoliday hour_numHoliday);
plot npp.*student.;
RUN;

/*COMPUTING PREDICTIONS*/
*Reference;
proc print data=bikeSharingNew;
run;
*;
data new;
input date $ rentalbc hour temperatureC humidityP windSpdMs visibility10m dptC 
solarRadiation rainfallMm snowfallCm Season $ Holiday $ functioningDay $ numHoliday numFunc numSeason hour_numFunc hour_numHoliday lnrbc;
datalines;
. . 9 23 60 . 2000 . . 0.4 0.0 . . . 0 1 1 9 0 . 
. . 12 25 20 . 2000 . . 0.0 0.0 . . . 0 0 1 0 0 .
;
data pred;
set new bikeSharingNew;
run;

PROC REG DATA=pred;
MODEL lnrbc = hour temperatureC humidityP visibility10m rainfallMm snowfallCm numSeason numHoliday hour_numHoliday;
output out=pred p=phat lower=lcl upper=ucl
run;
*printing predicted probabilities and confidence intervals;
proc print data=pred;
title2 'Predicted Probabilities and 95% Confidence Limits';
run;


