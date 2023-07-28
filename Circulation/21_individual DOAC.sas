/****************************************************************************
| Program name : 21_individual DOAC
| Date (update):
| Project name :
| Purpose      :
|
|
****************************************************************************/

%let class = sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
					  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
					  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
					  cancer_type_stomach_cancer cancer_type_uterus_cancer
/*					  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016*/
					  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
					  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
					  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
					  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
					  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm
/*					  rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing*/
					  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
					  CHF HT STT VD Dia AKF ALF bleed alcohol
					  anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
					  Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall
					  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi;

data comp_eff.event_12;
	set comp_eff.event_11;
	if init_drug = "APIXABAN" then APIXABAN=1; else APIXABAN=0;
	if init_drug = "DABIGATRAN ETEXILATE MESYLATE" then DABIGATRAN=1; else DABIGATRAN=0;
	if init_drug = "EDOXABAN TOSYLATE" then EDOXABAN=1; else EDOXABAN=0;
	if init_drug = "RIVAROXABAN" then RIVAROXABAN=1; else RIVAROXABAN=0;
	if init_drug = "WARFARIN SODIUM" then WARFARIN=1; else WARFARIN=0;
run;


proc freq data=comp_eff.event_12;
	table init_drug APIXABAN DABIGATRAN EDOXABAN RIVAROXABAN WARFARIN;
run;

/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/******************************************************** APIXABAN ********************************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/

data comp_eff.APIXABAN;
	set comp_eff.event_12_new;
	if WARFARIN=1 or APIXABAN=1;
run;
proc freq data=comp_eff.APIXABAN;
	table censor_flag*APIXABAN censor_flag_2*APIXABAN censor_flag_3*APIXABAN censor_flag_pneumonia_2*APIXABAN 
		  censor_flag_hipp_2*APIXABAN censor_flag_sepsis_2*APIXABAN;
run;

/************************* Events per 100 patient years ****************************/
proc sql; *Stroke;
	create table comp_eff.APIXABAN_personyr as
	select APIXABAN, sum(years_to_end) as sum
	from comp_eff.APIXABAN
	group by APIXABAN;
quit; 
proc sql; *Death;
	create table comp_eff.APIXABAN_personyr_2 as
	select APIXABAN, sum(years_to_death) as sum
	from comp_eff.APIXABAN
	group by APIXABAN;
quit; 
proc sql; *Bleed;
	create table comp_eff.APIXABAN_personyr_3 as
	select APIXABAN, sum(years_to_bleed) as sum
	from comp_eff.APIXABAN
	group by APIXABAN;
quit; 
proc sql; *Pneumonia;
	create table comp_eff.APIXABAN_personyr_4 as
	select APIXABAN, sum(years_to_pneumonia) as sum
	from comp_eff.APIXABAN
	group by APIXABAN;
quit; 
proc sql; *hipp;
	create table comp_eff.APIXABAN_personyr_5 as
	select APIXABAN, sum(years_to_hipp) as sum
	from comp_eff.APIXABAN
	group by APIXABAN;
quit; 
proc sql; *sepsis;
	create table comp_eff.APIXABAN_personyr_6 as
	select APIXABAN, sum(years_to_sepsis) as sum
	from comp_eff.APIXABAN
	group by APIXABAN;
quit; 

/***. Unadjusted Hazard ratio for all-cause death - cox regression model*/
proc phreg data=comp_eff.APIXABAN; *Stroke;
	class / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = APIXABAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.APIXABAN; *Death;
	class / param=ref ref=first; 
	model time_to_death*censor_flag_2(0) = APIXABAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.APIXABAN; *Bleed;
	class / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = APIXABAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.APIXABAN; *Pneumonia;
	class / param=ref ref=first; 
	model time_to_pneumonia*censor_flag_pneumonia_2(0) = APIXABAN / eventcode=1 risklimits;
run;
proc phreg data=comp_eff.APIXABAN; *hipp;
	class / param=ref ref=first; 
	model time_to_hipp*censor_flag_hipp_2(0) = APIXABAN / eventcode=1 risklimits;
run;
proc phreg data=comp_eff.APIXABAN; *sepsis;
	class / param=ref ref=first; 
	model time_to_sepsis*censor_flag_sepsis_2(0) = APIXABAN / eventcode=1 risklimits;
run;

/*** Adjusted HR's */
proc psmatch data=comp_eff.APIXABAN region=allobs;
		class APIXABAN &class;
		psmodel APIXABAN(treated='1')= &covaraites;
		assess lps var=(&covaraites)
						/ varinfo nlargestwgt=6 plots=(barchart boxplot(display=(lps )) wgtcloud) weight=atewgt(stabilize=yes);
output out(obs=all)=comp_eff.propensity_score_APIXABAN atewgt(stabilize=yes)=_ATEWgt_;
run;
proc univariate data=comp_eff.propensity_score_APIXABAN; class doac_flag; var _ATEWgt_; histogram; run; /*stabilized weights*/

/*Trimming at 1st and 99th percentile*/
data comp_eff.ps_APIXABAN_trimmed; 
set comp_eff.propensity_score_APIXABAN; 
if 0< _ATEWgt_ < 0.380489 then _ATEWgt_=0.380489; 
if _ATEWgt_ > 4.980546 then _ATEWgt_=4.980546; 
if _ATEWgt_=. then delete; 
run;
proc sgplot data=comp_eff.ps_APIXABAN_trimmed;       
  histogram _ATEWgt_ / group=doac_flag transparency=0.5;     
  density _ATEWgt_ / type=kernel group=doac_flag; 
run;

**2. Trimmed IPTW association;
proc phreg data=comp_eff.ps_APIXABAN_trimmed; *Stroke;
	class doac_flag / param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = APIXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_APIXABAN_trimmed; *Death;
	class doac_flag / param=ref ref=first;
	model time_to_death*censor_flag_2(0) = APIXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_APIXABAN_trimmed; *Bleed;
	class doac_flag / param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = APIXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_APIXABAN_trimmed; *Pneumonia;
	class doac_flag / param=ref ref=first;
	model time_to_pneumonia*censor_flag_pneumonia_2(0) = APIXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_APIXABAN_trimmed; *Hipp;
	class doac_flag / param=ref ref=first;
	model time_to_hipp*censor_flag_hipp_2(0) = APIXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_APIXABAN_trimmed; *Sepsis;
	class doac_flag / param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = APIXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;


**3. Fine stratification;
%include 'D:\SEER Medicare_Huijun\Manuscript 2_comparative effectiveness\SAS codes\macro\Weighted Table 1s.sas';
%include 'D:\SEER Medicare_Huijun\Manuscript 2_comparative effectiveness\SAS codes\macro\PSS weighted analysis.sas';
%fine_stratification (in_data= comp_eff.ps_APIXABAN_trimmed, exposure= APIXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag, survival_time= time_to_stroke_embolism);  *Stroke;
%fine_stratification (in_data= comp_eff.ps_APIXABAN_trimmed, exposure= APIXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_2, survival_time= time_to_death);  *Death;
%fine_stratification (in_data= comp_eff.ps_APIXABAN_trimmed, exposure= APIXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_3, survival_time= time_to_major_bleed);  *Bleed;
%fine_stratification (in_data= comp_eff.ps_APIXABAN_trimmed, exposure= APIXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_pneumonia_2, survival_time= time_to_pneumonia);  *Pneumonia;
%fine_stratification (in_data= comp_eff.ps_APIXABAN_trimmed, exposure= APIXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_hipp_2, survival_time= time_to_hipp);  *Hipp;
%fine_stratification (in_data= comp_eff.ps_APIXABAN_trimmed, exposure= APIXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_sepsis_2, survival_time= time_to_sepsis);  *Sepsis;








/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/******************************************************** DABIGATRAN ******************************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/

data comp_eff.DABIGATRAN;
	set comp_eff.event_12_new;
	if WARFARIN=1 or DABIGATRAN=1;
run;
proc freq data=comp_eff.DABIGATRAN;
	table censor_flag*DABIGATRAN censor_flag_2*DABIGATRAN censor_flag_3*DABIGATRAN 
		  censor_flag_pneumonia_2*DABIGATRAN censor_flag_hipp_2*DABIGATRAN censor_flag_sepsis_2*DABIGATRAN;
run;

/************************* Events per 100 patient years ****************************/
proc sql; *Stroke;
	create table comp_eff.DABIGATRAN_personyr as
	select DABIGATRAN, sum(years_to_end) as sum
	from comp_eff.DABIGATRAN
	group by DABIGATRAN;
quit; 
proc sql; *Death;
	create table comp_eff.DABIGATRAN_personyr_2 as
	select DABIGATRAN, sum(years_to_death) as sum
	from comp_eff.DABIGATRAN
	group by DABIGATRAN;
quit; 
proc sql; *Bleed;
	create table comp_eff.DABIGATRAN_personyr_3 as
	select DABIGATRAN, sum(years_to_bleed) as sum
	from comp_eff.DABIGATRAN
	group by DABIGATRAN;
quit; 
proc sql; *Pneumonia;
	create table comp_eff.DABIGATRAN_personyr_4 as
	select DABIGATRAN, sum(years_to_pneumonia) as sum
	from comp_eff.DABIGATRAN
	group by DABIGATRAN;
quit; 
proc sql; *hipp;
	create table comp_eff.DABIGATRAN_personyr_5 as
	select DABIGATRAN, sum(years_to_hipp) as sum
	from comp_eff.DABIGATRAN
	group by DABIGATRAN;
quit; 
proc sql; *sepsis;
	create table comp_eff.DABIGATRAN_personyr_6 as
	select DABIGATRAN, sum(years_to_sepsis) as sum
	from comp_eff.DABIGATRAN
	group by DABIGATRAN;
quit; 

/***. Unadjusted Hazard ratio  - cox regression model*/
proc phreg data=comp_eff.DABIGATRAN; *Stroke;
	class / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = DABIGATRAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.DABIGATRAN; *Death;
	class / param=ref ref=first; 
	model time_to_death*censor_flag_2(0) = DABIGATRAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.DABIGATRAN; *Bleed;
	class / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = DABIGATRAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.DABIGATRAN; *Pneumonia;
	class / param=ref ref=first; 
	model time_to_pneumonia*censor_flag_pneumonia_2(0) = DABIGATRAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.DABIGATRAN; *hipp;
	class / param=ref ref=first; 
	model time_to_hipp*censor_flag_hipp_2(0) = DABIGATRAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.DABIGATRAN; *sepsis;
	class / param=ref ref=first; 
	model time_to_sepsis*censor_flag_sepsis_2(0) = DABIGATRAN / eventcode=1 risklimits;
run;

/*** Adjusted HR's */
proc psmatch data=comp_eff.DABIGATRAN region=allobs;
		class DABIGATRAN &class;
		psmodel DABIGATRAN(treated='1')= &covaraites;
		assess lps var=(&covaraites)
						/ varinfo nlargestwgt=6 plots=(barchart boxplot(display=(lps )) wgtcloud) weight=atewgt(stabilize=yes);
output out(obs=all)=comp_eff.propensity_score_DABIGATRAN atewgt(stabilize=yes)=_ATEWgt_;
run;
proc univariate data=comp_eff.propensity_score_DABIGATRAN; class DABIGATRAN; var _ATEWgt_; histogram; run; /*stabilized weights*/

/*Trimming at 1st and 99th percentile*/
data comp_eff.ps_DABIGATRAN_trimmed; 
set comp_eff.propensity_score_DABIGATRAN; 
if 0< _ATEWgt_ < 0.247067 then _ATEWgt_=0.247067; 
if _ATEWgt_ > 3.860966 then _ATEWgt_=3.860966; 
if _ATEWgt_=. then delete; 
run;

**2. Trimmed IPTW association;
proc phreg data=comp_eff.ps_DABIGATRAN_trimmed; *Stroke;
	class DABIGATRAN / param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = DABIGATRAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_DABIGATRAN_trimmed; *Death;
	class DABIGATRAN / param=ref ref=first;
	model time_to_death*censor_flag_2(0) = DABIGATRAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_DABIGATRAN_trimmed; *Bleed;
	class DABIGATRAN / param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = DABIGATRAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_DABIGATRAN_trimmed; *Pneumonia;
	class DABIGATRAN / param=ref ref=first;
	model time_to_pneumonia*censor_flag_pneumonia_2(0) = DABIGATRAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_DABIGATRAN_trimmed; *hipp;
	class DABIGATRAN / param=ref ref=first;
	model time_to_hipp*censor_flag_hipp_2(0) = DABIGATRAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_DABIGATRAN_trimmed; *sepsis;
	class DABIGATRAN / param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = DABIGATRAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

**3. Fine stratification;
%fine_stratification (in_data= comp_eff.ps_DABIGATRAN_trimmed, exposure= DABIGATRAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag, survival_time= time_to_stroke_embolism);  *Stroke;
%fine_stratification (in_data= comp_eff.ps_DABIGATRAN_trimmed, exposure= DABIGATRAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_2, survival_time= time_to_death);  *Death;
%fine_stratification (in_data= comp_eff.ps_DABIGATRAN_trimmed, exposure= DABIGATRAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_3, survival_time= time_to_major_bleed);  *Bleed;
%fine_stratification (in_data= comp_eff.ps_DABIGATRAN_trimmed, exposure= DABIGATRAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_pneumonia_2, survival_time= time_to_pneumonia);  *Pneumonia;
%fine_stratification (in_data= comp_eff.ps_DABIGATRAN_trimmed, exposure= DABIGATRAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_hipp_2, survival_time= time_to_hipp);  *hipp;
%fine_stratification (in_data= comp_eff.ps_DABIGATRAN_trimmed, exposure= DABIGATRAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_sepsis_2, survival_time= time_to_sepsis);  *sepsis;




/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/******************************************************** RIVAROXABAN *****************************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/

data comp_eff.RIVAROXABAN;
	set comp_eff.event_12_new;
	if WARFARIN=1 or RIVAROXABAN=1;
run;
proc freq data=comp_eff.RIVAROXABAN;
	table censor_flag*RIVAROXABAN censor_flag_2*RIVAROXABAN censor_flag_3*RIVAROXABAN 
		  censor_flag_pneumonia_2*RIVAROXABAN censor_flag_hipp_2*RIVAROXABAN censor_flag_sepsis_2*RIVAROXABAN/nocol nopercent norow;
run;

/************************* Events per 100 patient years ****************************/
proc sql; *Stroke;
	create table comp_eff.RIVAROXABAN_personyr as
	select RIVAROXABAN, sum(years_to_end) as sum
	from comp_eff.RIVAROXABAN
	group by RIVAROXABAN;
quit; 
proc sql; *Death;
	create table comp_eff.RIVAROXABAN_personyr_2 as
	select RIVAROXABAN, sum(years_to_death) as sum
	from comp_eff.RIVAROXABAN
	group by RIVAROXABAN;
quit; 
proc sql; *Bleed;
	create table comp_eff.RIVAROXABAN_personyr_3 as
	select RIVAROXABAN, sum(years_to_bleed) as sum
	from comp_eff.RIVAROXABAN
	group by RIVAROXABAN;
quit; 
proc sql; *Pneumonia;
	create table comp_eff.RIVAROXABAN_personyr_4 as
	select RIVAROXABAN, sum(years_to_pneumonia) as sum
	from comp_eff.RIVAROXABAN
	group by RIVAROXABAN;
quit; 
proc sql; *hipp;
	create table comp_eff.RIVAROXABAN_personyr_5 as
	select RIVAROXABAN, sum(years_to_hipp) as sum
	from comp_eff.RIVAROXABAN
	group by RIVAROXABAN;
quit;
proc sql; *sepsis;
	create table comp_eff.RIVAROXABAN_personyr_6 as
	select RIVAROXABAN, sum(years_to_sepsis) as sum
	from comp_eff.RIVAROXABAN
	group by RIVAROXABAN;
quit;

/***. Unadjusted Hazard ratio for all-cause death - cox regression model*/
proc phreg data=comp_eff.RIVAROXABAN; *Stroke;
	class / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = RIVAROXABAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.RIVAROXABAN; *Death;
	class / param=ref ref=first; 
	model time_to_death*censor_flag_2(0) = RIVAROXABAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.RIVAROXABAN; *Bleed;
	class / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = RIVAROXABAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.RIVAROXABAN; *Pneumonia;
	class / param=ref ref=first; 
	model time_to_pneumonia*censor_flag_pneumonia_2(0) = RIVAROXABAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.RIVAROXABAN; *hipp;
	class / param=ref ref=first; 
	model time_to_hipp*censor_flag_hipp_2(0) = RIVAROXABAN / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.RIVAROXABAN; *sepsis;
	class / param=ref ref=first; 
	model time_to_sepsis*censor_flag_sepsis_2(0) = RIVAROXABAN / eventcode=1 risklimits;
run;

/*** Adjusted HR's */
proc psmatch data=comp_eff.RIVAROXABAN region=allobs;
		class RIVAROXABAN &class;
		psmodel RIVAROXABAN(treated='1')= &covaraites;
		assess lps var=(&covaraites)
						/ varinfo nlargestwgt=6 plots=(barchart boxplot(display=(lps )) wgtcloud) weight=atewgt(stabilize=yes);
output out(obs=all)=comp_eff.propensity_score_RIVAROXABAN atewgt(stabilize=yes)=_ATEWgt_;
run;
proc univariate data=comp_eff.propensity_score_RIVAROXABAN; class RIVAROXABAN; var _ATEWgt_; histogram; run; /*stabilized weights*/

/*Trimming at 1st and 99th percentile*/
data comp_eff.ps_RIVAROXABAN_trimmed; 
set comp_eff.propensity_score_RIVAROXABAN; 
if 0< _ATEWgt_ < 0.451142 then _ATEWgt_=0.451142; 
if _ATEWgt_ >3.918606 then _ATEWgt_=3.918606; 
if _ATEWgt_=. then delete; 
run;

**2. Trimmed IPTW association;
proc phreg data=comp_eff.ps_RIVAROXABAN_trimmed; *Stroke;
	class RIVAROXABAN / param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = RIVAROXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_RIVAROXABAN_trimmed; *Death;
	class RIVAROXABAN / param=ref ref=first;
	model time_to_death*censor_flag_2(0) = RIVAROXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_RIVAROXABAN_trimmed; *Bleed;
	class RIVAROXABAN / param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = RIVAROXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_RIVAROXABAN_trimmed; *Pneumonia;
	class RIVAROXABAN / param=ref ref=first;
	model time_to_pneumonia*censor_flag_pneumonia_2(0) = RIVAROXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_RIVAROXABAN_trimmed; *hipp;
	class RIVAROXABAN / param=ref ref=first;
	model time_to_hipp*censor_flag_hipp_2(0) = RIVAROXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.ps_RIVAROXABAN_trimmed; *sepsis;
	class RIVAROXABAN / param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = RIVAROXABAN / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

**3. Fine stratification;
%fine_stratification (in_data= comp_eff.ps_RIVAROXABAN_trimmed, exposure= RIVAROXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag, survival_time= time_to_stroke_embolism);  *Stroke;
%fine_stratification (in_data= comp_eff.ps_RIVAROXABAN_trimmed, exposure= RIVAROXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_2, survival_time= time_to_death);  *Death;
%fine_stratification (in_data= comp_eff.ps_RIVAROXABAN_trimmed, exposure= RIVAROXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_3, survival_time= time_to_major_bleed);  *Bleed;
%fine_stratification (in_data= comp_eff.ps_RIVAROXABAN_trimmed, exposure= RIVAROXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_pneumonia_2, survival_time= time_to_pneumonia);  *Pneumonia;
%fine_stratification (in_data= comp_eff.ps_RIVAROXABAN_trimmed, exposure= RIVAROXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_hipp_2, survival_time= time_to_hipp);  *hipp;
%fine_stratification (in_data= comp_eff.ps_RIVAROXABAN_trimmed, exposure= RIVAROXABAN, PS_provided= yes , ps_var= _PS_, 
					  ps_class_var_list= &class, 
					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,
					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_sepsis_2, survival_time= time_to_sepsis);  *sepsis;




/**************************************************************************************************************************************/
/**************************************************************************************************************************************/
/******************************************************** EDOXABAN ********************************************************************/
/**************************************************************************************************************************************/
/**************************************************************************************************************************************/

data comp_eff.EDOXABAN;
	set comp_eff.event_12;
	if WARFARIN=1 or EDOXABAN=1;
run;
proc freq data=comp_eff.EDOXABAN;
	table censor_flag*EDOXABAN censor_flag_2*EDOXABAN censor_flag_3*EDOXABAN 
		  censor_flag_pneumonia_2*EDOXABAN censor_flag_hipp_2*EDOXABAN censor_flag_sepsis_2*EDOXABAN/nocol nopercent norow;
run;

/************************* Events per 100 patient years ****************************/
proc sql; *Stroke;
	create table comp_eff.EDOXABAN_personyr as
	select EDOXABAN, sum(years_to_end) as sum
	from comp_eff.EDOXABAN
	group by EDOXABAN;
quit; 
proc sql; *Death;
	create table comp_eff.EDOXABAN_personyr_2 as
	select EDOXABAN, sum(years_to_death) as sum
	from comp_eff.EDOXABAN
	group by EDOXABAN;
quit; 
proc sql; *Bleed;
	create table comp_eff.EDOXABAN_personyr_3 as
	select EDOXABAN, sum(years_to_bleed) as sum
	from comp_eff.EDOXABAN
	group by EDOXABAN;
quit; 
proc sql; *Pneumonia;
	create table comp_eff.EDOXABAN_personyr_4 as
	select EDOXABAN, sum(years_to_pneumonia) as sum
	from comp_eff.EDOXABAN
	group by EDOXABAN;
quit; 
proc sql; *hipp;
	create table comp_eff.EDOXABAN_personyr_5 as
	select EDOXABAN, sum(years_to_hipp) as sum
	from comp_eff.EDOXABAN
	group by EDOXABAN;
quit; 
proc sql; *sepsis;
	create table comp_eff.EDOXABAN_personyr_6 as
	select EDOXABAN, sum(years_to_sepsis) as sum
	from comp_eff.EDOXABAN
	group by EDOXABAN;
quit; 

/***. Unadjusted Hazard ratio for all-cause death - cox regression model*/
proc phreg data=comp_eff.EDOXABAN; *Bleed;
	class / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = EDOXABAN / eventcode=1 risklimits;
run;
proc phreg data=comp_eff.EDOXABAN; *Death;
	class / param=ref ref=first; 
	model time_to_death*censor_flag_2(0) = EDOXABAN / eventcode=1 risklimits;
run;



