/****************************************************************************
| Program name : 06_Create censoring variable and outcome
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/

/************************* Prepare censoring variables & outcomes **************************************************/

data comp_eff.event_1;
	set comp_eff.outcome_v12;
	
	* participate_end_date = minimum of (censor_date, death_date);
	participate_end_date = censor_date;
	if participate_end_date = "." then participate_end_date = study_end_date;
	format participate_end_date mmddyy10.;
	
	years_to_death = (participate_end_date - index_date)/365;
	
	* outcome_date_w_censor = minimum of (censor_date, death_date, outcome_date);
	outcome_date_w_censor = min(outcome_date, participate_end_date);
	format outcome_date_w_censor mmddyy10.;
	
	years_to_end = (outcome_date_w_censor - index_date)/365;

	* indicator of initiation drug class;
	doac_flag = 0;
	if init_drug_class = "DOAC" then doac_flag = 1;
	
	/************************************ Censor flag and outcomes ***************************************************************/
	* censor flag for competing risks model;
	if outcome_date_w_censor = outcome_date then censor_flag = 1; * event coded =1;
	else if outcome_date_w_censor = death_date_v1 then censor_flag = 2;
	else censor_flag = 0;

	* censor flag for cox regression model for time to death;
	if participate_end_date = death_date_v1 then censor_flag_2 = 1; * event coded =1;
	else censor_flag_2 = 0;
	
	* outcome variables;
	time_to_stroke_embolism = outcome_date_w_censor - index_date;
	time_to_death = participate_end_date - index_date;

run;

data comp_eff.event_2;
	set comp_eff.event_1;

	keep patient_id index_date outcome_date death_date study_end_date death_date_v1 init_date init_drug_class switch_date switch_drug_class
		 discontinuation_date disenrollment_A_B_date disenrollment_D_date hospice_from_dt hospice_after
		 censor_date censor_type participate_end_date years_to_end doac_flag censor_flag
		 outcome_date_w_censor censor_flag_2 time_to_stroke_embolism time_to_death;
run;

proc freq data = comp_eff.event_2;
	table censor_flag*init_drug_class censor_flag_2*init_drug_class;
run;
