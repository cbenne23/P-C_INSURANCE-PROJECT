/*=================================================================================================================================*/
/* IMPORTING RAW DATA INTO SAS*/
/*==================================================================================================================================*/
        data WORK.DS_MiniProject    ;
       %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
       infile '\\Client\F$\GEICO_DATA_SCIENCE_PROJECT\DS_MiniProject\DS_MiniProject_ANON.csv'
   delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
          informat DATE_FOR mmddyy10. ;
         informat RTD_ST_CD $6. ;
         informat CustomerSegment best12. ;
         informat Tenure best32. ;
          informat Age best32. ;
          informat MART_STATUS $5. ;
          informat GENDER $1. ;
         informat CHANNEL1_6M best32. ;
         informat CHANNEL2_6M best32. ;
          informat CHANNEL3_6M best32. ;
          informat CHANNEL4_6M best32. ;
          informat CHANNEL5_6M best32. ;
         informat METHOD1_6M best32. ;
          informat RECENT_PAYMENT best32. ;
          informat PAYMENTS_6M best32. ;
         informat CHANNEL1_3M best32. ;
         informat CHANNEL2_3M best32. ;
          informat CHANNEL3_3M best32. ;
          informat CHANNEL4_3M best32. ;
          informat CHANNEL5_3M best32. ;
         informat METHOD1_3M best32. ;
          informat PAYMENTS_3M best32. ;
          informat NOT_DI_3M best32. ;
          informat NOT_DI_6M best32. ;
          informat EVENT1_30_FLAG best32. ;
          informat EVENT2_90_SUM best32. ;
         informat LOGINS best32. ;
         informat POLICYPURCHASECHANNEL best32. ;
          informat Call_Flag best32. ;
         format DATE_FOR mmddyy10. ;
          format RTD_ST_CD $6. ;
          format CustomerSegment best12. ;
          format Tenure best12. ;
          format Age best12. ;
          format MART_STATUS $5. ;
         format GENDER $1. ;
         format CHANNEL1_6M best12. ;
          format CHANNEL2_6M best12. ;
          format CHANNEL3_6M best12. ;
         format CHANNEL4_6M best12. ;
          format CHANNEL5_6M best12. ;
          format METHOD1_6M best12. ;
          format RECENT_PAYMENT best12. ;
          format PAYMENTS_6M best12. ;
         format CHANNEL1_3M best12. ;
         format CHANNEL2_3M best12. ;
         format CHANNEL3_3M best12. ;
         format CHANNEL4_3M best12. ;
          format CHANNEL5_3M best12. ;
         format METHOD1_3M best12. ;
          format PAYMENTS_3M best12. ;
          format NOT_DI_3M best12. ;
          format NOT_DI_6M best12. ;
         format EVENT1_30_FLAG best12. ;
          format EVENT2_90_SUM best12. ;
          format LOGINS best12. ;
          format POLICYPURCHASECHANNEL best12. ;
          format Call_Flag best12. ;
       input
                   DATE_FOR
                   RTD_ST_CD $
                   CustomerSegment
                   Tenure
                  Age
                  MART_STATUS $
                   GENDER $
                  CHANNEL1_6M
                  CHANNEL2_6M
                   CHANNEL3_6M
                   CHANNEL4_6M
                  CHANNEL5_6M
                  METHOD1_6M
                   RECENT_PAYMENT
                   PAYMENTS_6M
                  CHANNEL1_3M
                  CHANNEL2_3M
                 CHANNEL3_3M
                 CHANNEL4_3M
                   CHANNEL5_3M
                   METHOD1_3M
                   PAYMENTS_3M
                   NOT_DI_3M
                  NOT_DI_6M
                  EVENT1_30_FLAG
                  EVENT2_90_SUM
                  LOGINS
                  POLICYPURCHASECHANNEL
                 Call_Flag
     ;
      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
      run;


/*=================================================================================================================================================================================*/
* DISCRIPTIVE STATISTICS
*==================================================================================================================================================================================*;
title ' Descriptive Statistics of Variables';
	  proc univariate data= DS_Miniproject;
	  Var   Age  Tenure  CHANNEL1_6M CHANNEL2_6M CHANNEL3_6M CHANNEL4_6M  CHANNEL5_6M METHOD1_6M PAYMENTS_6M CHANNEL1_3M  CHANNEL2_3M CHANNEL3_3M CHANNEL4_3M CHANNEL5_3M METHOD1_3M PAYMENTS_3M  LOGINS EVENT1_30_FLAG EVENT2_90_SUM  ;
	  run;


 



/*===================================================================================================================================================================================================*/
********TRANSFORMING VARIABLES TO PREPARE FOR ESTIMATION OF LOGISTIC MODELS;
/*========================================================================================================================================================================*/
data New_Data; set DS_MiniProject;

if   RTD_ST_CD  not in ('ST_S7', 'ST_S9', 'ST_S0', 'ST_S14' 'ST_S4' 'ST_S42') then RTD_ST_CD ='OTHER';
run;

/*****TRANSFORMATION CONTINUED****/

/* To assign serial numbers to observations in a data set in SAS, create a variable using _N_, a system variable, which contains observation numbers from 1 through n. */


data Data_Obs; set New_Data;

Id=_N_;

 drop EVENT1_30_FLAG DATE_FOR;/* The EVENT2_90_SUM and DATE_FOR variables are removed from the dataset as it contains only zeros***/
run;

/* Data Transformations to create Macro Variables, clean up the datafile and create Dummy Variables*/
data TransF; set Data_Obs;

	  if MART_STATUS in ('MS_S0' 'MS_S1' 'MS_S2' 'MS_S3' 'MS_S4') then do;
	  MS_S1_D =(MART_STATUS EQ  'MS_S1');
      MS_S2_D =(MART_STATUS EQ  'MS_S2');
	  MS_S3_D =(MART_STATUS EQ  'MS_S3');
	  MS_S4_D =(MART_STATUS EQ  'MS_S4');
	  end;

	  if GENDER in ('F' 'M') then do;
	  GEND_M = (GENDER EQ 'M');
	  end;


	  if CustomerSegment in ('1' '2' '3') then do;
	  CSeg2_D =(CustomerSegment EQ  '2');
      CSeg3_D =(CustomerSegment  EQ  '3');
	  end;
* Creating Dummy Variables for Rated State Policy;
	    if RTD_ST_CD in ('ST_S0' 'ST_S4' 'ST_S7' 'ST_S9' 'ST_S14' 'ST_S42' 'OTHER') then do;
	  RTD_S0_D =(RTD_ST_CD EQ  'ST_S0');
      RTD_S4_D =(RTD_ST_CD EQ  'ST_S4');
	  RTD_S7_D =(RTD_ST_CD EQ  'ST_S7');
	  RTD_S9_D =(RTD_ST_CD EQ  'ST_S9');
	  RTD_S14_D =(RTD_ST_CD EQ  'ST_S14');
      RTD_S42_D =(RTD_ST_CD EQ  'ST_S42');
	  
	  end;

  		
	 %let RatedStatePol_D = RTD_S0_D RTD_S4_D RTD_S7_D RTD_S9_D RTD_S14_D RTD_S42_D;
	 %let Mart_STA = MS_S1_D MS_S2_D MS_S3_D MS_S4_D;
	 %let Cus_seg = CSeg2_D CSeg3_D;

	  %let Channel_6M =  CHANNEL1_6M CHANNEL2_6M  CHANNEL3_6M CHANNEL4_6M CHANNEL5_6M;
      %let Channel_3M =  CHANNEL1_3M CHANNEL2_3M  CHANNEL3_3M  CHANNEL4_3M  CHANNEL5_3M;
	  %let Enroll_AP =  NOT_DI_3M  NOT_DI_6M;

	 
run;

/* Creating Training and Testing Random Samples without Imputation*/
 proc surveyselect data=TransF samprate=0.70 seed=49201 out=Sample1 outall 
           method=srs noprint;
        run;

data Train Test; set Sample1;
if Selected = 1 then output Train;
else output Test;
drop Selected;
run; 

*========================================================================================================;
/********Removing Missing Cases from Test dataset***********************/
*========================================================================================================;
data Test; set Test;

If CustomerSegment ne .;
if CHANNEL4_6M ne .;
run;

/*=========================================================================================================================================================================================*/
* ***************************ESTIMATION OF THE DELETED MISSING CASES MODEL***********************************************;
/*========================================================================================================================================================================================*/
/* Estimating Logistic Regression Model with Deleted cases and investigating Influential observations*/


proc logistic data = Train plots (MAXPOINTS=NONE)=(roc oddsratio);
model Call_Flag (event='1') = RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL/ctable  pprob=0 to 1 by .1;
output out=results p=pred l=cl95l u=cl95u h=leverage difchisq=dchi;
title2 'Logistic Regression';
run;

****** PLOT RESIDUALS ******;
proc plot data=results;
plot (leverage dchi)*pred;
title3 'Residual Plots';
run;


******Leverage by Index ******;
proc plot data=results;
plot leverage*Id;
title3 'Index Plot';
run;
/******* 95% PREDICTION LIMITS *****;
proc print data=results;
var RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL pred cl95l cl95u;
title3 '95% Prediction Intervals';
run;
*/

/* Estimation based on extracted candidate predictors */
******SCORING TEST CASES: DELETED CASES W/O INTERACTIONS ******;
proc logistic  data = Train;
model Call_Flag( event='1')= RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL/ctable  pprob=0 to 1 by .1;
score data=Test out=out_score1 fitstat  outroc=roc_val1 roceps=0.1;
title1 'Predict Call  Status (Yes or No) ';
title2 'Logistic Regression Scoring the Test dataset with deleted cases and no interactions';
*title1 'Predict Call  Status (Yes or No) ';
run;



* Try a 0.1 cutoff value;
data OutScore1;
set out_score1;
if P_1 > 0.1 then class1=1;
else class1=0;
run;

title 'Summary of the classification results on the validation data set with deleted cased at 10 percent cutoff';
proc freq data = OutScore1;
tables F_Call_Flag*I_Call_Flag Call_Flag*class1 / nopercent nocol;
run;
* Try a 0.3 cutoff value;
data OutScore1;
set out_score1;
if P_1 > 0.3 then class3=1;
else class3=0;
run;

title 'Summary of the classification results on the validation data set with deleted cased';
proc freq data = OutScore1;
tables F_Call_Flag*I_Call_Flag Call_Flag*class3 / nopercent nocol;
run;


* Try a 0.40 cutoff value;
data OutScore1;
set out_score1;
if P_1 > 0.4 then class4=1;
else class4=0;
run;

title 'Summary of the classification results on the validation data set with deleted cased at 40 percent cutoff';
proc freq data = OutScore1;
tables F_Call_Flag*I_Call_Flag Call_Flag*class4 / nopercent nocol;
run;
/*=========================================================================================================================================================================================*/
* ***************************ESTIMATION OF THE DELETED MISSING CASES MODEL WITH THE REMOVAL OF INFLUENTIAL OBSERVATIONS***********************************************;
/*========================================================================================================================================================================================*/

* Removing Extreme Observations;
data RemoveOutliers1; set Transf;

if Id in ( 57684, 62941, 95977,16912,16911, 130086,130085,130084,130083,130082) then delete;
if Id in ( 14179,44296,44297,44298,130081,130080) then delete;
if Id in ( 15900,6971,3898,19593,3444, 130007,130044,130042,130029, 130041) then delete;
if Id in ( 21459,14077,38414,64089,153,126925,127856,123995,127981,129138) then delete;
if Id in ( 74687,78991,89203,100565,103845) then delete;
if Id in ( 110520,23995) then delete;
if Id in ( 62837,68138,124470,6992,6993) then delete;
if Id in ( 79947,30438,30439,30440,30441) then delete;
if Id in ( 40721,23995,44296,44297,44298) then delete;
if Id in ( 78033,103827,110706,110930,117342) then delete;
run;



/* Estimating Logistic Regression Model with Deleted cases and investigating Influential observations*/
/* Creating Training and Testing Random Samples without Imputation*/
 proc surveyselect data=RemoveOutliers1 samprate=0.70 seed=49201 out=Sample4 outall 
           method=srs noprint;
        run;

data Train4 Test4; set Sample4;
if Selected = 1 then output Train4;
else output Test4;
drop Selected;
run; 

*========================================================================================================;
/********Removing Missing Cases from Test dataset***********************/
*========================================================================================================;
data Test4; set Test4;

If CustomerSegment ne .;
if CHANNEL4_6M ne .;
run;



* Esimating Logistic Regression after deleting observations with missing values and removing influential observations;
proc logistic data = Train4 plots (MAXPOINTS=NONE)=(roc oddsratio);
model Call_Flag (event='1') = RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL/ctable  pprob=0 to 1 by .1;
output out=results4 p=pred4 l=cl95l4 u=cl95u4 h=leverage4 difchisq=dchi4;
title2 'Logistic Regression';
run;

****** PLOT RESIDUALS ******;
proc plot data=results4;
plot (leverage4 dchi4)*pred4;
title3 'Residual Plots';
run;


******Leverage by Index ******;
proc plot data=results4;
plot leverage4*Id;
title3 'Index Plot';
run;
/******* 95% PREDICTION LIMITS *****;
proc print data=results;
var RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL pred cl95l cl95u;
title3 '95% Prediction Intervals';
run;
*/

/* Estimation based on extracted candidate predictors with Influential observations deleted */
******SCORING TEST CASES: DELETED OBSERVATIONS WITH MISSING VALUES AND INLUENTIAL CASES W/O INTERACTIONS ******;

proc logistic data=Train4;
model Call_Flag( event='1')= RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL/ctable  pprob=0 to 1 by .1;
score data=Test4 out=out_score3 fitstat  outroc=roc_val3 roceps=0.1;
title1 'Predict Call  Status (Yes or No)';
title2 'Logistic Regression Scoring the Test dataset with missing observations and fluential cases deleted and no interactions';
run;




* Try a 0.1 cutoff value;
data OutScore3;
set out_score3;
if P_1 > 0.1 then class1=1;
else class1=0;
run;

title 'Summary of the classification results on the validation data set with deleted influential cases and observation with missing values at 10 percent cutoff';
proc freq data = OutScore3;
tables F_Call_Flag*I_Call_Flag Call_Flag*class1 / nopercent nocol;
run;
* Try a 0.3 cutoff value;
data OutScore3;
set out_score3;
if P_1 > 0.3 then class3=1;
else class3=0;
run;

title 'Summary of the classification results on the validation data set with deleted  influential cases and observations with missing values at 30% cutoff';
proc freq data = OutScore3;
tables F_Call_Flag*I_Call_Flag Call_Flag*class3 / nopercent nocol;
run;


* Try a 0.40 cutoff value;
data OutScore3;
set out_score3;
if P_1 > 0.4 then class4=1;
else class4=0;
run;

title 'Summary of the classification results on the validation data set with observations with missing values and influential cases deleted - 40 percent cutoff';
proc freq data = OutScore3;
tables F_Call_Flag*I_Call_Flag Call_Flag*class4 / nopercent nocol;
run;

/*===================================================================================================================================================================================*/
*************************ESTIMATION OF THE STOCHASTIC IMPUTATION MODEL;
/*====================================================================================================================================================================================*/
/* Imputation for Missingness*/

title'Applying Multiple Imputation';
proc mi data=Transf noprint out=imputed;
run;


/* Transforming the Imputed dataset to round imputated values*/

data imputed_mod; set imputed;

if _Imputation_ = 1;
	CustomerSegment = round(CustomerSegment);
	
	CHANNEL1_6M =round(CHANNEL1_6M);
 CHANNEL2_6M =round(CHANNEL2_6M);
CHANNEL3_6M=round(CHANNEL3_6M);
CHANNEL4_6M=round(CHANNEL4_6M);
CHANNEL5_6M=round(CHANNEL5_6M);
	 
METHOD1_6M=round(METHOD1_6M);
 RECENT_PAYMENT=round(RECENT_PAYMENT);
  PAYMENTS_6M=round(PAYMENTS_6M);

  drop  _Imputation_;

run;

/* Creating Training and Testing Random Samples With Stochastic Imputation dataset*/
 proc surveyselect data=imputed_mod samprate=0.70 seed=49201 out=Sample2 outall 
           method=srs noprint;
        run;

data Train2 Test2; set Sample2;
if Selected = 1 then output Train2;
else output Test2;
drop Selected ;
run;

/* Estimating Logistic Regression Model with Stochastic Imputation and investigating Influential observations*/

proc logistic data = Train2 plots (MAXPOINTS=NONE)=(roc oddsratio);
model Call_Flag (event='1') = RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL/ctable  pprob=0 to 1 by .1;
output out=results2 p=pred2 l=cl95l2 u=cl95u2 h=leverage2 difchisq=dchi2;
title2 'Logistic Regression';
run;

****** PLOT RESIDUALS ******;
proc plot data=results2;
plot (leverage2 dchi2)*pred2;
title3 'Residual Plots';
run;


******Leverage by Index ******;
proc plot data=results2;
plot leverage2*Id;
title3 'Index Plot';
run;
/******* 95% PREDICTION LIMITS *****;
proc print data=results;
var RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL pred cl95l cl95u;
title3 '95% Prediction Intervals';
run;
*/

/* Estimation based on extracted candidate predictors */
******SCORING TEST CASES: STOCHASTIC IMPUTATION W/O INTERACTIONS ******;
proc logistic  data = Train2;
model Call_Flag( event='1')= RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL/ctable  pprob=0 to 1 by .1;
score data=Test2 out=out_score2 fitstat  outroc=roc_val2 roceps=0.1;
title1 'Predict Call  Status (Yes or No) ';
title2 'Logistic Regression Scoring the Test dataset with Stochastic Imputation and no interactions';
*title1 'Predict Call  Status (Yes or No) ';
run;



* Try a 0.1 cutoff value;
data OutScore2;
set out_score2;
if P_1 > 0.1 then class1=1;
else class1=0;
run;

title 'Summary of the classification results on the validation data set with Stochastic Imputation at 10 percent cutoff';
proc freq data = OutScore2;
tables F_Call_Flag*I_Call_Flag Call_Flag*class1 / nopercent nocol;
run;
* Try a 0.3 cutoff value;
data OutScore2;
set out_score2;
if P_1 > 0.3 then class3=1;
else class3=0;
run;

title 'Summary of the classification results on the validation data set with Stochastic Imputation';
proc freq data = OutScore2;
tables F_Call_Flag*I_Call_Flag Call_Flag*class3 / nopercent nocol;
run;


* Try a 0.40 cutoff value;
data OutScore2;
set out_score2;
if P_1 > 0.4 then class4=1;
else class4=0;
run;

title 'Summary of the classification results on the validation data set with Stochastic Imputation at 40 percent cutoff';
proc freq data = OutScore2;
tables F_Call_Flag*I_Call_Flag Call_Flag*class4 / nopercent nocol;
run;


/*=========================================================================================================================================================================================*/
* ***************************ESTIMATION THE STOCHASTIC IMPUTATION MODEL WITH THE REMOVAL OF INFLUENTIAL OBSERVATIONS***********************************************;
/*========================================================================================================================================================================================*/
/* Estimating Logistic Regression Model with Deleted cases and investigating Influential observations*/

* Removing Extreme Observations;
data RemoveOutliers; set Imputed_mod;

if Id in ( 57684, 62941, 95977,16912,16911, 130086,130085,130084,130083,130082) then delete;
if Id in ( 14179,44296,44297,44298,130081,130080) then delete;
if Id in ( 15900,6971,3898,19593,3444, 130007,130044,130042,130029, 130041) then delete;
if Id in ( 21459,14077,38414,64089,153,126925,127856,123995,127981,129138) then delete;
if Id in ( 74687,78991,89203,100565,103845) then delete;
if Id in ( 110520,23995) then delete;
if Id in ( 62837,68138,124470,6992,6993) then delete;
if Id in ( 79947,30438,30439,30440,30441) then delete;
if Id in ( 40721,23995,44296,44297,44298) then delete;
if Id in ( 78033,103827,110706,110930,117342) then delete;
run;



/* Creating Training and Testing Random Samples With Stochastic Imputation dataset*/
 proc surveyselect data=RemoveOutliers samprate=0.70 seed=49201 out=Sample3 outall 
           method=srs noprint;
        run;

data Train3 Test3; set Sample3;
if Selected = 1 then output Train3;
else output Test3;
drop Selected ;
run;
* Esimating Logistic Regression after removing influential observations;
proc logistic data = Train3 plots (MAXPOINTS=NONE)=(roc oddsratio);
model Call_Flag (event='1') = RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL/ctable  pprob=0 to 1 by .1;
output out=results3 p=pred3 l=cl95l3 u=cl95u3 h=leverage3 difchisq=dchi3;
title2 'Logistic Regression';
run;

****** PLOT RESIDUALS ******;
proc plot data=results3;
plot (leverage3 dchi3)*pred3;
title3 'Residual Plots';
run;


******Leverage by Index ******;
proc plot data=results3;
plot leverage3*Id;
title3 'Index Plot';
run;
/******* 95% PREDICTION LIMITS *****;
proc print data=results;
var RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL pred cl95l cl95u;
title3 '95% Prediction Intervals';
run;
*/

/* Estimation based on extracted candidate predictors with Influential observations deleted */
******SCORING TEST CASES: DELETED INFERENTIAL CASES W/O INTERACTIONS ******;
proc logistic  data = Train3 plots;
*class class aquifer;
model Call_Flag( event='1')= RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL/ctable  pprob=0 to 1 by .1;
score data=Test3 out=out_score2 fitstat  outroc=roc_val2 roceps=0.1;
title1 'Predict Call  Status (Yes or No) ';
title2 'Logistic Regression Scoring the Test dataset with deleted influential cases and no interactions';
*title1 'Predict Call  Status (Yes or No) ';
run;



* Try a 0.1 cutoff value;
data OutScore2;
set out_score2;
if P_1 > 0.1 then class1=1;
else class1=0;
run;

title 'Summary of the classification results on the validation data set with deleted influential cases at 10 percent cutoff';
proc freq data = OutScore2;
tables F_Call_Flag*I_Call_Flag Call_Flag*class1 / nopercent nocol;
run;
* Try a 0.3 cutoff value;
data OutScore2;
set out_score2;
if P_1 > 0.3 then class3=1;
else class3=0;
run;

title 'Summary of the classification results on the validation data set with deleted  influential cases at 30% cutoff';
proc freq data = OutScore2;
tables F_Call_Flag*I_Call_Flag Call_Flag*class3 / nopercent nocol;
run;


* Try a 0.40 cutoff value;
data OutScore2;
set out_score2;
if P_1 > 0.4 then class4=1;
else class4=0;
run;

title 'Summary of the classification results on the validation data set with deleted influential cases at 40 percent cutoff';
proc freq data = OutScore2;
tables F_Call_Flag*I_Call_Flag Call_Flag*class4 / nopercent nocol;
run;
/* Estimation based on extracted candidate predictors */
****** DELETED CASES WITH INTERACTIONS ******;

proc logistic  data = Train plots(only)=(roc oddsratio);
*class class aquifer;
model Call_Flag( event='1')= RTD_S7_D | CHANNEL1_6M | CHANNEL2_6M | CHANNEL3_6M | CHANNEL4_6M | CHANNEL2_3M | CHANNEL3_3M | CHANNEL5_3M |  NOT_DI_3M | Tenure | Age | RECENT_PAYMENT | PAYMENTS_6M | EVENT2_90_SUM | POLICYPURCHASECHANNEL/ctable  pprob=.3 to .7 by .1;
oddsratio RTD_S7_D;
oddsratio  CHANNEL1_6M;
oddsratio  CHANNEL2_6M;
oddsratio  CHANNEL3_6M;
oddsratio  CHANNEL4_6M;
oddsratio  CHANNEL2_3M;
oddsratio  CHANNEL3_3M;
oddsratio  CHANNEL5_3M;
oddsratio  NOT_DI_3M;
oddsratio Tenure;
oddsratio  Age;
oddsratio  RECENT_PAYMENT;
oddsratio  PAYMENTS_6M;
oddsratio  EVENT2_90_SUM;
oddsratio  POLICYPURCHASECHANNEL;
score data=Test out=out_score2 fitstat  outroc=roc_val2 roceps=0.1;
title1 'Predict Call  Status (Yes or No) ';
title2 'Logistic Regression Scoring the Test dataset with deleted cases and With Interactions';
title1 'Predict Call  Status (Yes or No) ';
run;

* Try a 0.3 cutoff value;

data OutScore;
set out_score;
if P_1 > 0.3 then class3=1;
else class3=0;
run;

title 'Summary of the classification results on the validation data set with deleted cased';
proc freq data = OutScore;
tables F_Call_Flag*I_Call_Flag Call_Flag*class3 / nopercent nocol;
run;
