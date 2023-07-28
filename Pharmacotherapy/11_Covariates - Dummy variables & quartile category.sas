/****************************************************************************
| Program name : 13_Covariates - Dummy variables & quartile category
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/

/** quartile category for education and per capita income **************************************/
proc rank data=oac_can.cohort_v09 out=q1 groups=4;                               
	var per_capita_income;                                                          
	ranks rank_income;                                                      
run;   

proc rank data=q1 out=q2 groups=4;                               
	var edu;                                                          
	ranks rank_edu;                                                      
run; 

data oac_can.cohort_v10;
	set q2;
	rank_edu_char = put(rank_edu,8.);
	rank_income_char = put(rank_income,8.);
	if rank_edu_char = "       ." then rank_edu_char = "Missing";
	if rank_income_char = "       ." then rank_income_char = "Missing";
	drop rank_income rank_edu;
run;




/** Dummy varibles for multiple category variables *************************************************/ 
* #1;
%let VarList = age_grp Racem  Cancer_type stage grade tumor_size afib_year  rank_edu_char rank_income_char; /* name of categorical variables */

data AddFakeY / view=AddFakeY;	set oac_can.cohort_v10;	_Y = 0;	run;

proc glmselect data=AddFakeY NOPRINT outdesign(addinputvars)=f1(drop=_Y);
   class      &VarList;   /* list the categorical variables here */
   model _Y = &VarList /  noint selection=none;
run;


* #2;
data AddFakeY_2 / view=AddFakeY_2;	set f1;	_Y = 0;	run;

proc glmselect data=AddFakeY_2 NOPRINT outdesign(addinputvars)=f2(drop=_Y);
   class      regionm;   /* list the categorical variables here */
   model _Y = regionm /  noint selection=none;
run;


* #3;
data AddFakeY / view=AddFakeY;	set f2;	_Y = 0;	run;

proc glmselect data=AddFakeY NOPRINT outdesign(addinputvars)=oac_can.cohort_v11(drop=_Y);
   class      init_year;   /* list the categorical variables here */
   model _Y = init_year /  noint selection=none;
run;

