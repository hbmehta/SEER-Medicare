/****************************************************************************
| Program name : 25_Sensitivity analysis - Intention to treat
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/


data comp_eff.propensity_score_trimmed_itt;
	set comp_eff.propensity_score_trimmed_2;

	censor_date_itt=999999;
	array date{4} $ death_date_v1 disenrollment_A_B_date disenrollment_D_date hospice_from_dt;
	do i=1 to 4;
		if date{i} lt censor_date_itt and date{i} ne "." then censor_date_itt=date{i};
	end;

	if censor_date_itt=999999 then censor_date_itt = ".";

	format censor_date_itt mmddyy10.;
	
	*Define censoring type;
	if censor_date_itt = "." then censor_type_itt = "none						";
	else if censor_date_itt = death_date_v1 then censor_type_itt = "death			";
	else if censor_date_itt = disenrollment_A_B_date or censor_date_itt = disenrollment_D_date then censor_type_itt = "disenrollment			";
	else if censor_date_itt = hospice_from_dt then censor_type_itt = "Hospice_admission			";

run;
PROC FREQ DATA=comp_eff.propensity_score_trimmed_itt;
    TABLES censor_type_itt*init_drug_class /missing;
RUN;

data comp_eff.propensity_score_trimmed_itt_2;
	set comp_eff.propensity_score_trimmed_itt;
	
	* participate_end_date = minimum of (censor_date, death_date);
	participate_end_date_itt = censor_date_itt;
	if participate_end_date_itt = "." then participate_end_date_itt = study_end_date;
	format participate_end_date_itt mmddyy10.;
		
	* outcome_date_w_censor = minimum of (censor_date, death_date, outcome_date);
	outcome_date_w_censor_itt = min(outcome_date, participate_end_date_itt);
	format outcome_date_w_censor_itt mmddyy10.;

	* Bleeding outcome date;
	major_bleed_date_w_censor_itt = min(m_bleed_date, participate_end_date_itt);
	format major_bleed_date_w_censor_itt mmddyy10.;

	* Sepsis outcome date;
	sepsis_date_w_censor_itt = min(sepsis_date, participate_end_date_itt);
	format sepsis_date_w_censor_itt mmddyy10.;

		
	/************************************ Censor flag and outcomes ***************************************************************/
	* censor flag for competing risks model;
	if outcome_date_w_censor_itt = outcome_date then censor_flag_itt = 1; * event coded =1;
	else if outcome_date_w_censor_itt = death_date_v1 then censor_flag_itt = 2;
	else censor_flag_itt = 0;

	* censor flag for cox regression model for time to death;
	if participate_end_date_itt = death_date_v1 then censor_flag_itt_2 = 1; * event coded =1;
	else censor_flag_itt_2 = 0;

	
	* censor flag for competing risks model for time to bleeding;
	if major_bleed_date_w_censor_itt = m_bleed_date then censor_flag_itt_3 = 1; * event coded =1;
	else if major_bleed_date_w_censor_itt = death_date_v1 then censor_flag_itt_3 = 2;
	else censor_flag_itt_3 = 0;

	
	* censor flag for competing risks model for time to sepsis;
	if sepsis_date_w_censor_itt = sepsis_date then censor_flag_sepsis_itt_2 = 1; * event coded =1;
	else if sepsis_date_w_censor_itt = death_date_v1 then censor_flag_sepsis_itt_2 = 2;
	else censor_flag_sepsis_itt_2 = 0;
	
	* outcome variables;
	time_to_stroke_embolism_itt = outcome_date_w_censor_itt - index_date;
	time_to_death_itt = participate_end_date_itt - index_date;
	time_to_major_bleed_itt = major_bleed_date_w_censor_itt - index_date;
	time_to_sepsis_itt = sepsis_date_w_censor_itt - index_date;

run;





* Intention to treat models;
* stroke;
proc phreg data=comp_eff.propensity_score_trimmed_itt_2;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism_itt*censor_flag_itt(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* bleeding;
proc phreg data=comp_eff.propensity_score_trimmed_itt_2;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed_itt*censor_flag_itt_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* death;
proc phreg data=comp_eff.propensity_score_trimmed_itt_2;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death_itt*censor_flag_itt_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* sepsis;
proc phreg data=comp_eff.propensity_score_trimmed_itt_2;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_sepsis_itt*censor_flag_sepsis_itt_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;
