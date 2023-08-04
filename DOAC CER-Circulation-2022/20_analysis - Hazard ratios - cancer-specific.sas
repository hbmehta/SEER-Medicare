proc sgplot data=comp_eff.propensity_score_trimmed;
  histogram _ps_ / group=doac_flag transparency=0.5;
  density _ps_ / type=kernel group=doac_flag;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_breast_cancer=1));
    class doac_flag / param=ref ref=first;
    model time_to_stroke_embolism*censor_flag(0) = doac_flag / eventcode=1 risklimits;
    weight _ATEWgt_ / normalize;
run;
/****************************************************************************
| Program name : 20_analysis - Hazard ratios - cancer-specific
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/

proc freq data=comp_eff.event_3;
	tables cancer_type*doac_flag*censor_flag;
run;

proc freq data=comp_eff.event_6;
	tables cancer_type*doac_flag*censor_flag_3;
run;

***************************************************************************************************************************************************************;
***************************************************************************************************************************************************************;
***************************************************************************************************************************************************************;
***************************************************************************************************************************************************************;

%let covaraites2 = time_cancer_to_index age number_prior_hospitalization number_prior_physician
				  sex maritalm dualflag chemo
				  racem_black racem_hispanic racem_white racem_other
				  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
/*				  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016*/
				  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
				  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
				  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
				  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
				  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm
/*				  rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing*/
				  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
				  CHF HT STT VD Dia AKF ALF bleed alcohol
				  anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
				  Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall
				  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi;

/********************************************************************************
     Derive PS and get Std Diff before and after weighting
********************************************************************************/
proc psmatch data=comp_eff.event_12_new region=allobs;
		class doac_flag sex maritalm dualflag chemo
			  racem_black racem_hispanic racem_white racem_other
			  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
/*			  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016*/
			  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
			  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
			  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
			  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
			  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm 
/*			  rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing*/
			  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
			  CHF HT STT VD Dia AKF ALF bleed alcohol
			  anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
			  Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall
			  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi;
		psmodel doac_flag(treated='1')= &covaraites2;
		assess lps var=(&covaraites)
						/ varinfo nlargestwgt=6 plots=(barchart boxplot(display=(lps )) wgtcloud) weight=atewgt(stabilize=yes);
output out(obs=all)=comp_eff.propensity_score_cs atewgt(stabilize=yes)=_ATEWgt_;
run;
proc univariate data=comp_eff.propensity_score_cs; class doac_flag; var _ATEWgt_; histogram; run; /*stabilized weights*/


/*Trimming at 1st and 99th percentile*/
data comp_eff.propensity_score_trimmed_cs; 
set comp_eff.propensity_score_cs; 
if 0< _ATEWgt_ < 0.605259 then _ATEWgt_= 0.605259; 
if _ATEWgt_ > 3.200993 then _ATEWgt_=3.200993; 
if _ATEWgt_=. then delete; 
run;
****************************** Primary outcome: Time to ischemic stroke or systemic embolism ******************************************************************;


/***. Unadjusted Hazard ratio for ischemic stroke or systematic embolism - competing risk model*/
proc phreg data=comp_eff.propensity_score_cs(where=(cancer_type_breast_cancer=1));
	class doac_flag / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag / eventcode=1 risklimits;
run;
proc phreg data=comp_eff.propensity_score_cs(where=(cancer_type_colorectal_cancer=1));
	class doac_flag / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag / eventcode=1 risklimits;
run;
proc phreg data=comp_eff.propensity_score_cs(where=(cancer_type_lung_cancer=1));
	class doac_flag / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag / eventcode=1 risklimits;
run;



**2. Trimmed IPTW association of ischemic stroke or systematic embolism;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_breast_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_colorectal_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_lung_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_prostate_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_bladder_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

proc freq data=comp_eff.propensity_score_trimmed_cs;
	table cancer_type_bladder_cancer*doac_flag*censor_flag;
run;

**3. Fine stratification;

%include 'D:\SEER Medicare_Huijun\Manuscript 2_comparative effectiveness\SAS codes\macro\Weighted Table 1s.sas';
%include 'D:\SEER Medicare_Huijun\Manuscript 2_comparative effectiveness\SAS codes\macro\PSS weighted analysis.sas';

%fine_stratification (in_data= comp_eff.propensity_score_trimmed_cs(where=(cancer_type_breast_cancer=1)), exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
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
					  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi, 

					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,

					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag, survival_time= time_to_stroke_embolism); 

%fine_stratification (in_data= comp_eff.propensity_score_trimmed_cs(where=(cancer_type_colorectal_cancer=1)), exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
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
					  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi, 

					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,

					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag, survival_time= time_to_stroke_embolism); 

%fine_stratification (in_data= comp_eff.propensity_score_trimmed_cs(where=(cancer_type_lung_cancer=1)), exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
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
					  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi, 

					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,

					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag, survival_time= time_to_stroke_embolism); 





**********************************************************************************************************************************************************************;
**********************************************************************************************************************************************************************;
********************************************************* Secondary outcome: Time to major bleeding  *****************************************************************;
/***. Unadjusted Hazard ratio for ischemic stroke or systematic embolism - competing risk model*/
proc phreg data=comp_eff.propensity_score_cs(where=(cancer_type_bladder_cancer=1));
	class doac_flag / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = doac_flag / eventcode=1 risklimits;
run;
proc phreg data=comp_eff.propensity_score_cs(where=(cancer_type_breast_cancer=1));
	class doac_flag / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = doac_flag / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_cs(where=(cancer_type_colorectal_cancer=1));
	class doac_flag / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = doac_flag / eventcode=1 risklimits;
run;
proc phreg data=comp_eff.propensity_score_cs(where=(cancer_type_lung_cancer=1));
	class doac_flag / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = doac_flag / eventcode=1 risklimits;
run;
proc phreg data=comp_eff.propensity_score_cs(where=(cancer_type_prostate_cancer=1));
	class doac_flag / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = doac_flag / eventcode=1 risklimits;
run;


**2. Trimmed IPTW association of ischemic stroke or systematic embolism;

proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_breast_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_colorectal_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_lung_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_prostate_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_bladder_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

**3. Fine stratification;
%fine_stratification (in_data= comp_eff.propensity_score_trimmed_cs(where=(cancer_type_bladder_cancer=1)), exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
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
					  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi, 

					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,

					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_3, survival_time= time_to_major_bleed); 

%fine_stratification (in_data= comp_eff.propensity_score_trimmed_cs(where=(cancer_type_breast_cancer=1)), exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
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
					  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi, 

					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,

					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_3, survival_time= time_to_major_bleed); 


%fine_stratification (in_data= comp_eff.propensity_score_trimmed_cs(where=(cancer_type_colorectal_cancer=1)), exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
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
					  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi, 

					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,

					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_3, survival_time= time_to_major_bleed); 


%fine_stratification (in_data= comp_eff.propensity_score_trimmed_cs(where=(cancer_type_lung_cancer=1)), exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
					  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
					  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
					  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
					  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
					  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm
					  rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing
					  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
					  CHF HT STT VD Dia AKF ALF bleed alcohol
					  anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
					  Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall
					  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi, 

					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,

					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_3, survival_time= time_to_major_bleed); 

%fine_stratification (in_data= comp_eff.propensity_score_trimmed_cs(where=(cancer_type_prostate_cancer=1)), exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
					  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
					  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
					  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
					  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
					  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm
					  rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing
					  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
					  CHF HT STT VD Dia AKF ALF bleed alcohol
					  anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
					  Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall
					  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi, 

					  ps_cont_var_list= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician,

					  interactions= , PSS_method=exposure,
					  n_of_strata= 50 , out_data= PS_FS, id_var= patient_id, estimand= ATE, effect_estimate= HR,
					  outcome= censor_flag_3, survival_time= time_to_major_bleed); 





**********************************************************************************************************************************************************************;
**********************************************************************************************************************************************************************;
********************************************************* Third outcome: Time to all-cause death  ********************************************************************;

** Trimmed IPTW association of ischemic stroke or systematic embolism;

proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_breast_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_colorectal_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_lung_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_prostate_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cs(where=(cancer_type_bladder_cancer=1));
	class doac_flag init_yr/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
