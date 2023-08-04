/****************************************************************************
| Program name : 13_Covariates - Dummy variables & quartile category
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/

/** quartile category for education and per capita income **************************************/
proc rank data=comp_eff.covariate_07 out=comp_eff.covariate_08 groups=4;                               
	var per_capita_income;                                                          
	ranks rank_income;                                                      
run;   

proc rank data=comp_eff.covariate_08 out=comp_eff.covariate_08 groups=4;                               
	var edu;                                                          
	ranks rank_edu;                                                      
run; 

data comp_eff.covariate_09;
	set comp_eff.covariate_08;
	rank_edu_char = put(rank_edu,8.);
	rank_income_char = put(rank_income,8.);
	if rank_edu_char = "       ." then rank_edu_char = "Missing";
	if rank_income_char = "       ." then rank_income_char = "Missing";

	sex = input(m_sex, 8.);
	drop m_sex;
run;




/** Dummy varibles for multiple category variables *************************************************/

%let VarList = Racem Regionm Cancer_type stage grade tumor_size init_yr rank_edu_char rank_income_char; /* name of categorical variables */

data AddFakeY / view=AddFakeY;	set comp_eff.covariate_09;	_Y = 0;	run;

proc glmselect data=AddFakeY NOPRINT outdesign(addinputvars)=comp_eff.covariate_10(drop=_Y);
   class      &VarList;   /* list the categorical variables here */
   model _Y = &VarList /  noint selection=none;
run;


proc freq data=comp_eff.covariate_10;
	table rank_edu_char*doac_flag rank_income_char*doac_flag/missing;
run;
