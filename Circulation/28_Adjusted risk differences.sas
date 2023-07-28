/****************************************************************************
| Program name : 28_Adjusted risk differences
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/
data covariates;
	set comp_eff.propensity_score_trimmed;
	keep time_cancer_to_index doac_flag init_yr;
run;
           
* Death;
proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ risklimits;
	weight _ATEWgt_ / normalize;
	Baseline out=Pred_risk_death covariates=covariates survival=survival/nomean; 
run;

Data Pred_risk;
Set Pred_risk_death;
Event_risk=1-survival;
Run;

Proc Means data=Pred_risk nway;
Class doac_flag;
Var Event_risk;
Output out=pop_risk mean=pop_risk;
Run;
Proc Transpose data=pop_risk out=pop_risk prefix=doac_flag_;
Id doac_flag;
Var pop_risk;
Run;
Data pop_risk;
Set pop_risk;
Adjusted_RR=doac_flag_1/doac_flag_0;
Run;
Proc Print data=pop_risk;
Var Adjusted_RR;
Run;
