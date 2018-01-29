
        data WORK.DS_MiniProject    ;
       %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
       infile '\\Client\F$\GEICO_DATA_SCIENCE_PROJECT\DS_MiniProject\old\DS_MiniProject_ANON.csv'
   delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;
          informat DATE_FOR mmddyy10. ;
         informat RTD_ST_CD $5. ;
         informat CustomerSegment $5. ;
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
         informat POLICYPURCHCHANNEL best32. ;
          informat Call_Flag best32. ;
         format DATE_FOR mmddyy10. ;
          format RTD_ST_CD $5. ;
          format CustomerSegment $5. ;
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
          format POLICYPURCHCHANNEL best12. ;
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
                  POLICYPURCHCHANNEL
                 Call_Flag
     ;
      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
      run;

	  /*================================================================================================================================*/
*****CLEAN UP ;

data missing1; set DS_MiniProject ;
if CHANNEL1_6M eq .;
Id = _N_;
run;

******CONVERTING "NONE" to missing;

data convNone; set DS_MiniProject;

if CustomerSegment ="NONE" then CustomerSegment = .;

*CustomerSegment= int(CustomerSegment);
*Id = _N_;
run;
**********************CHECKING MISSING PATTERN*******************************;
data custStrg; set convNone;
CustSeg= int(CustomerSegment);
drop CustomerSegment;
drop  EVENT1_30_FLAG;
run;

ods select misspattern;

proc mi data=custStrg nimpute=0;
*class CustomerSegment;

run;
ods select all;



/*===================================================================================================================================================================================*/
*************************ESTIMATION OF THE STOCHASTIC IMPUTATION MODEL;
;

/* Data Transformations to create Macro Variables, clean up the datafile and create Dummy Variables*/
data newdata; set imputed;
if   RTD_ST_CD  not in ('ST_S7', 'ST_S9', 'ST_S0', 'ST_S14' 'ST_S4' 'ST_S42') then RTD_ST_CD ='OTHER';


	  if MART_STATUS in ('MS_S0' 'MS_S1' 'MS_S2' 'MS_S3' 'MS_S4') then do;
	  MS_S1_D =(MART_STATUS EQ  'MS_S1');
      MS_S2_D =(MART_STATUS EQ  'MS_S2');
	  MS_S3_D =(MART_STATUS EQ  'MS_S3');
	  MS_S4_D =(MART_STATUS EQ  'MS_S4');
	  end;

	  if GENDER in ('F' 'M') then do;
	  GEND_M = (GENDER EQ 'M');
	  end;


	  if CustSeg in ('1' '2' '3') then do;
	  CSeg2_D =(CustSeg EQ  '2');
      CSeg3_D =(CustSeg EQ  '3');
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

  		
	* %let RatedStatePol_D = RTD_S0_D RTD_S4_D RTD_S7_D RTD_S9_D RTD_S14_D RTD_S42_D;
	 *%let Mart_STA = MS_S1_D MS_S2_D MS_S3_D MS_S4_D;
	 *%let Cus_seg = CSeg2_D CSeg3_D;

	 * %let Channel_6M =  CHANNEL1_6M CHANNEL2_6M  CHANNEL3_6M CHANNEL4_6M CHANNEL5_6M;
     * %let Channel_3M =  CHANNEL1_3M CHANNEL2_3M  CHANNEL3_3M  CHANNEL4_3M  CHANNEL5_3M;
	  *%let Enroll_AP =  NOT_DI_3M  NOT_DI_6M;

	 
run;


/*====================================================================================================================================================================================*/
/* Imputation for Missingness*/

title'Applying Multiple Imputation';
proc mi data=CustStrg noprint out=imputed;
run;


data dataPol; set imputed;
if _Imputation_ = 1;
keep POLICYPURCHASECHANNEL;
run;

data PolMissing; set dataPol;
If POLICYPURCHASECHANNEL eq . ;
run; 


ods select none;
ods output parameterestimates=imputedEst covb=imputedcovb;
proc logistic data=NewData descending;
by  _Imputation_;
model Call_Flag = RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHCHANNEL / covb;
run;
ods select all;


proc mianalyze parms=imputedEst covb=Imputedcovb ;
modeleffects intercept RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHCHANNEL; 
run;
***************************MISSING CUSTOMERSEGMENT**********************;
data missingCusSeg; set convNone;

if  CustomerSegment = .;
run;

*********************ALL Missing***********************************************;
data AllMissing; set convNone;

if (CustomerSegment eq . or CHANNEL1_6M eq .);
*if CustomerSegment eq . ; /* don't do this
*if CHANNEL1_6M eq . ;*/
run;

*******************Only Missing Customer Segment;

data CusSegMiss; set AllMissing;

drop CHANNEL1_6M;

run;

**********************Only Missing CHANNEL1_6M;
data CHAN1Miss; set AllMissing;

drop CustomerSegment;
run;


title' Distribution of Call_flag for All Missing';
proc freq data = AllMissing;

tables  Call_Flag;
run;

title' Distribution of Call_flag for All Data';
proc freq data = Ds_miniproject;


tables  Call_Flag;
run;



proc freq data = CHAN1Miss;

tables CHANNEL1_6M * Call_Flag;
run;

**********************WITHOUT MISSING****************************************************************;
data AllCases; set convNone;

if CustomerSegment ne . and CHANNEL1_6M ne .;

run;

title' Distribution of Call_flag for AllCases';
proc freq data = AllCases;

tables Call_Flag;
run;



/*===================================================================================================================================================================================================*/
********TRANSFORMING VARIABLES TO PREPARE FOR ESTIMATION OF LOGISTIC MODELS;
/*========================================================================================================================================================================*/
/*data New_Data; set DS_MiniProject;

if   RTD_ST_CD  not in ('ST_S7', 'ST_S9', 'ST_S0', 'ST_S14' 'ST_S4' 'ST_S42') then RTD_ST_CD ='OTHER';
run;
*/
/*****TRANSFORMATION CONTINUED****/

/* To assign serial numbers to observations in a data set in SAS, create a variable using _N_, a system variable, which contains observation numbers from 1 through n. */


/*data Data_Obs; set New_Data;

Id=_N_;

 drop EVENT1_30_FLAG DATE_FOR;/* The EVENT2_90_SUM and DATE_FOR variables are removed from the dataset as it contains only zeros
run;
*/
/* Data Transformations to create Macro Variables, clean up the datafile and create Dummy Variables*/
data newData; set AllCases;

if   RTD_ST_CD  not in ('ST_S7', 'ST_S9', 'ST_S0', 'ST_S14' 'ST_S4' 'ST_S42') then RTD_ST_CD ='OTHER';

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

	   drop EVENT1_30_FLAG DATE_FOR;

	 
run;

/* Creating Training and Testing Random Samples without Imputation*/
 proc surveyselect data=newData samprate=0.70 seed=49201 out=Sample1 outall 
           method=srs noprint;
        run;

data Train Test; set Sample1;
if Selected = 1 then output Train;
else output Test;
drop Selected;
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
model Call_Flag( event='1')= RTD_S7_D  CHANNEL1_6M  CHANNEL2_6M  CHANNEL3_6M  CHANNEL4_6M  CHANNEL2_3M CHANNEL3_3M CHANNEL5_3M  NOT_DI_3M  Tenure Age  RECENT_PAYMENT  PAYMENTS_6M  EVENT2_90_SUM  POLICYPURCHASECHANNEL /ctable  pprob=0 to 1 by .1;
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

/*
	  title ' Frequency Distribution for Customer Segment';
	  proc freq data= DS_MiniProject;
	  table CustomerSegment;
	  run;


	  title ' Frequency Distribution for Target Variable';
	  proc freq data= DS_MiniProject;
	  table Call_Flag;
	  run;


	  title ' Frequency Distribution for Marital Status';
	  proc freq data= DS_MiniProject;
	  table  MART_STATUS;
	  run;


	   title ' Frequency Distribution for Age';
	  proc freq data= DS_MiniProject;
	  table   Age;
	  run;

	  data Trans; set DS_MiniProject;

	  Age =round(Age);
	  Tenure =round(Tenure);

	  run;


	     title ' Frequency Distribution for Rounded Age';
	  proc freq data= Trans;
	  table   Age;
	  run;

	     title ' Frequency Distribution for Rounded Tenure';
	  proc freq data= Trans;
	  table   Tenure;
	  run;


	  
	     title ' Frequency Distribution for  Gender';
	  proc freq data= Trans;
	  table   GENDER;
	  run;


	       title ' Frequency Distribution for  Rated State of Policy';
	  proc freq data= Trans;
	  table   RTD_ST_CD;
	  run;


	        title ' Frequency Distribution for  Recent Payment';
	  proc freq data= Trans;
	  table   RECENT_PAYMENT;
	  run;


	  title ' Frequency Distribution for Target Variable';
	  proc freq data= DS_MiniProject;
	  table Call_Flag;
	  run;

	  data miss_RP;  set Trans;

	  if RECENT_PAYMENT =.;

	  run;
Data Macro; set trans;

	  %let Channel_6M =  CHANNEL1_6M CHANNEL2_6M  CHANNEL3_6M CHANNEL4_6M CHANNEL5_6M;
      %let Channel_3m =  CHANNEL1_3M CHANNEL2_3M  CHANNEL3_3M  CHANNEL4_3M  CHANNEL5_3M;
	  %let Enroll_AP =  NOT_DI_3M  NOT_DI_6M;
	  
run;
       title ' Frequency Distribution for  CHANNEL1-5 6 Months';
	  proc freq data= Macro;
	  table   &Channel_6M;
	  run;


	   title ' Frequency Distribution for  CHANNEL1-5 3 Months';
	  proc freq data= Macro;
	  table   &Channel_3m;
	  run;


	    title ' Frequency Distribution for  METHOD1_6M( # of payments made with Method1)';
	  proc freq data= Macro;
	  table   METHOD1_6M;
	  run;


	  
	    title ' Frequency Distribution for  PAYMENTS_6M( # of total payments in last 6 months)';
	  proc freq data= Macro;
	  table   PAYMENTS_6M;
	  run;



	  
	    title ' Frequency Distribution for  METHOD1_3M( # of payments made with Method1)';
	  proc freq data= Macro;
	  table   METHOD1_3M;
	  run;


	  
	    title ' Frequency Distribution for  PAYMENTS_3M( # of total payments in last 3 months)';
	  proc freq data= Macro;
	  table   PAYMENTS_3M;
	  run;


	  title ' Frequency Distribution for  PAYMENTS_3M( # of total payments in last 3 months)';
	  proc freq data= Macro;
	  table   PAYMENTS_3M;
	  run;


	  title ' Frequency Distribution for NOT_DI_3M or NOT_DI_6M( Has the customer enrolled in autopay in the last 3 or 6 month)';
	  proc freq data= Macro;
	  table   &Enroll_AP;
	  run;

	  title ' Frequency Distribution for EVENT1_30_FLAG( Has customer received cancellation notice in the last 30 days?)';
	  proc freq data= Macro;
	  table   EVENT1_30_FLAG;
	  run;


	    title ' Frequency Distribution for EVENT2_90_SUM ( How Many cancellation notices have been sent in the last 90 days?)';
	  proc freq data= Macro;
	  table EVENT2_90_SUM  ;
	  run;


	      title ' Frequency Distribution for LOGINS ( How Many times logged into self-service online in the last 30 days?)';
	  proc freq data= Macro;
	  table LOGINS ;
	  run;


	      title ' Frequency Distribution for POLICYPURCHASECHANNEL ( How was this policy purchased?)';
	  proc freq data= Macro;
	  table POLICYPURCHASECHANNEL;
	  run;
*/
