/****************************************************************************
| Program name : 18_Hazard ratios
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/

/* Add time from cancer diagnosis to index date to dataset */
data comp_eff.event_12_new;
	set comp_eff.event_12;
	time_cancer_to_index = index_date - cancer_date;
run;
proc univariate data=comp_eff.event_12_new; var time_cancer_to_index; histogram; run;

%let covaraites = age sex racem_black racem_hispanic racem_white racem_other maritalm dualflag
 				  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
				  /*rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing*/
				  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
				  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
				  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
				  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
				  cancer_type_stomach_cancer cancer_type_uterus_cancer
				  number_prior_hospitalization number_prior_physician
				  chemo				  
/*				  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016*/
				  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
				  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
				  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
				  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
				  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm
				  
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
			  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
			  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
			  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
			  cancer_type_stomach_cancer cancer_type_uterus_cancer
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
			  Osteoporotic_frac fall
/*			  Home_O2  Walker Wheelchair Home_hosp_bed */
			  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi;
		psmodel doac_flag(treated='1')= &covaraites;
		assess lps var=(&covaraites)
						/ varinfo nlargestwgt=6 plots=(barchart boxplot(display=(lps )) wgtcloud) weight=atewgt(stabilize=yes);
output out(obs=all)=comp_eff.propensity_score atewgt(stabilize=yes)=_ATEWgt_;
run;
proc univariate data=comp_eff.propensity_score; var _ps_; class doac_flag; histogram; run; /*propensity score*/
proc univariate data=comp_eff.propensity_score; var _ATEWgt_; histogram; run; /*stabilized weights*/
proc sgplot data=comp_eff.propensity_score;       
  histogram _ps_ / group=doac_flag transparency=0.5;     
  density _ps_ / type=kernel group=doac_flag; 
run;
proc sgplot data=comp_eff.propensity_score;          
  density _ps_ / type=kernel group=doac_flag; 
run;
/*Trimming at 1st and 99th percentile*/
data comp_eff.propensity_score_trimmed; 
set comp_eff.propensity_score; 
if 0< _ATEWgt_ < 0.510683 then _ATEWgt_=0.510683; 
if _ATEWgt_ > 2.891309 then _ATEWgt_=2.891309; 
if _ATEWgt_=. then delete; 
run;
proc sgplot data=comp_eff.propensity_score_trimmed;       
  histogram _ATEWgt_ / group=doac_flag transparency=0.5;     
  density _ATEWgt_ / type=kernel group=doac_flag; 
run;
proc sgplot data=comp_eff.propensity_score_trimmed;           
  density _ATEWgt_ / type=kernel group=doac_flag; 
run;
proc sgplot data=comp_eff.propensity_score_trimmed;       
  histogram _ps_ / group=doac_flag transparency=0.5;     
  density _ps_ / type=kernel group=doac_flag; 
run;


/********************************************************************************
     Derive PS and get Std Diff before and after weighting & include init_yr
********************************************************************************/
proc psmatch data=comp_eff.event_12_new region=allobs;
		class doac_flag sex maritalm dualflag chemo
			  racem_black racem_hispanic racem_white racem_other
			  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
			  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
			  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
			  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
			  cancer_type_stomach_cancer cancer_type_uterus_cancer
			  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
			  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
			  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
			  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
			  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
			  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm 
/*			  rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing*/
			  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
			  CHF HT STT VD Dia AKF ALF bleed alcohol
			  anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
			  Osteoporotic_frac fall
/*			  Home_O2  Walker Wheelchair Home_hosp_bed */
			  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi;
		psmodel doac_flag(treated='1')= &covaraites;
		assess lps var=(&covaraites)
						/ varinfo nlargestwgt=6 plots=(barchart boxplot(display=(lps )) wgtcloud) weight=atewgt(stabilize=yes);
output out(obs=all)=comp_eff.propensity_score_with_yr atewgt(stabilize=yes)=_ATEWgt_;
run;
proc univariate data=comp_eff.propensity_score_with_yr; var _ps_; class doac_flag; histogram; run; /*propensity score*/
proc univariate data=comp_eff.propensity_score_with_yr; var _ATEWgt_; histogram; run; /*stabilized weights*/

/*Trimming at 1st and 99th percentile*/
data comp_eff.propensity_score_trimmed_with_yr; 
set comp_eff.propensity_score_with_yr; 
if 0< _ATEWgt_ < 0.452208 then _ATEWgt_=0.452208; 
if _ATEWgt_ > 3.722562 then _ATEWgt_=3.722562; 
if _ATEWgt_=. then delete; 
run;

/********************************************************************************
     Derive PS and get Std Diff before and after weighting & include init_yr & time_cancer_to_index
********************************************************************************/
proc psmatch data=comp_eff.event_12_new region=allobs;
		class doac_flag sex maritalm dualflag chemo
			  racem_black racem_hispanic racem_white racem_other
			  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
			  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
			  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
			  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
			  cancer_type_stomach_cancer cancer_type_uterus_cancer
			  init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
			  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
			  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
			  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
			  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
			  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm 
/*			  rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing*/
			  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
			  CHF HT STT VD Dia AKF ALF bleed alcohol
			  anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
			  Osteoporotic_frac fall
/*			  Home_O2  Walker Wheelchair Home_hosp_bed */
			  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi;
		psmodel doac_flag(treated='1')= &covaraites;
		assess lps var=(&covaraites)
						/ varinfo nlargestwgt=6 plots=(barchart boxplot(display=(lps )) wgtcloud) weight=atewgt(stabilize=yes);
output out(obs=all)=comp_eff.propensity_score_with_yr_time atewgt(stabilize=yes)=_ATEWgt_;
run;
proc univariate data=comp_eff.propensity_score_with_yr_time; var _ATEWgt_; histogram; run; /*stabilized weights*/

/*Trimming at 1st and 99th percentile*/
data comp_eff.propensity_score_trimmed_yr_time; 
set comp_eff.propensity_score_with_yr_time; 
if 0< _ATEWgt_ < 0.452184 then _ATEWgt_=0.452184; 
if _ATEWgt_ > 3.690396 then _ATEWgt_=3.690396; 
if _ATEWgt_=. then delete; 
run;


***************************************************************************************************************************************************************;
***************************************************************************************************************************************************************;
***************************************************************************************************************************************************************;
***************************************************************************************************************************************************************;

****************************** Primary outcome: Time to ischemic stroke or systemic embolism ******************************************************************;

proc freq data=comp_eff.propensity_score;
	table (censor_flag censor_flag_2 censor_flag_pneumonia_2)*doac_flag;
run;
/***. Unadjusted Hazard ratio for ischemic stroke or systematic embolism - competing risk model*/
proc phreg data=comp_eff.propensity_score;
	class doac_flag / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag / eventcode=1 risklimits;
run;
/*proc phreg data=comp_eff.propensity_score2(where=(cancer_type_lung_cancer=1));*/
/*	class doac_flag / param=ref ref=first; */
/*	model time_to_stroke_embolism*censor_flag(0,2) = doac_flag / eventcode=1 risklimits;*/
/*run;*/
/*proc phreg data=comp_eff.propensity_score2(where=(cancer_type_prostate_cancer=1));*/
/*	class doac_flag / param=ref ref=first; */
/*	model time_to_stroke_embolism*censor_flag(0,2) = doac_flag / eventcode=1 risklimits;*/
/*run;*/
/*proc phreg data=comp_eff.propensity_score2(where=(cancer_type_breast_cancer=1) drop=cancer_type_lung_cancer);*/
/*	class doac_flag / param=ref ref=first; */
/*	model time_to_stroke_embolism*censor_flag(0,2) = doac_flag / eventcode=1 risklimits;*/
/*run;*/

proc lifetest data=comp_eff.event_1 plots=cif(test); *Cumulative incidence curve for ischemic stroke or systemic embolism;
   time time_to_stroke_embolism*censor_flag(0)/eventcode=1;
   strata doac_flag / order=internal;
run;


**2. Trimmed IPTW association of ischemic stroke or systematic embolism;
proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
data treat;
doac_flag = 1; output;
doac_flag = 0; output; run;
proc phreg data=comp_eff.propensity_score_trimmed  plots(overlay)=cif;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	baseline covariates=treat  / rowid=doac_flag;
run;

proc phreg data=comp_eff.propensity_score_trimmed_with_yr;
	class doac_flag / param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag  time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_yr_time;
	class doac_flag / param=ref ref=first;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

**3. Fine stratification;

%include 'D:\SEER Medicare_Huijun\Manuscript 2_comparative effectiveness\SAS codes\macro\Weighted Table 1s.sas';
%include 'D:\SEER Medicare_Huijun\Manuscript 2_comparative effectiveness\SAS codes\macro\PSS weighted analysis.sas';

%fine_stratification (in_data= comp_eff.propensity_score_trimmed, exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
					  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
					  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
					  cancer_type_stomach_cancer cancer_type_uterus_cancer
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
********************************************************* Secondary outcome: Time to all-cause death *****************************************************************;

/***. Unadjusted Hazard ratio for all-cause death - cox regression model*/

proc phreg data=comp_eff.propensity_score;
	class / param=ref ref=first; 
	model time_to_death*censor_flag_2(0) = doac_flag / eventcode=1 risklimits;
run;

proc lifetest data=comp_eff.propensity_score plots=survival(nocensor);  *Kaplan-Meier survival curve for all-cause death;
time time_to_death * censor_flag_2(0);
strata doac_flag;
run;


**2. Trimmed IPTW association of all-cause death;
proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed plots(overlay)=survival;
   class doac_flag init_yr(ref='2016')/ param=ref ref=first;
   model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index;
   weight _ATEWgt_;
   baseline covariates=comp_eff.propensity_score_trimmed outdiff=Diff1 survival=_all_/diradj group=doac_flag;
run;
proc phreg data=comp_eff.propensity_score_trimmed_with_yr;
	class doac_flag/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_yr_time;
	class doac_flag/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

**3. Fine stratification;
%fine_stratification (in_data= comp_eff.propensity_score_trimmed, exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
					  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
					  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
					  cancer_type_stomach_cancer cancer_type_uterus_cancer
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
					  outcome= censor_flag_2, survival_time= time_to_death); 




**********************************************************************************************************************************************************************;
**********************************************************************************************************************************************************************;
********************************************************* NC outcomes: Time to asthma and time to pneumonia *****************************************************************;



/***. Unadjusted Hazard ratio for asthma - cox regression model*/
proc phreg data=comp_eff.event_3;
	class / param=ref ref=first; 
	model time_to_asthma*censor_flag_asthma(0) = doac_flag / eventcode=1 risklimits;
run;

/***. Unadjusted Hazard ratio for pneumonia - competing risk model*/
proc phreg data=comp_eff.event_3;
	class / param=ref ref=first; 
	model time_to_pneumonia*censor_flag_pneumonia_2(0) = doac_flag / eventcode=1 risklimits;
run;


**2. Trimmed IPTW association of ischemic stroke or systematic embolism;
proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag / param=ref ref=first;
	model time_to_pneumonia*censor_flag_pneumonia_2(0) = doac_flag / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

**3. Fine stratification;
%fine_stratification (in_data= comp_eff.propensity_score_trimmed, exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
					  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
					  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
					  cancer_type_stomach_cancer cancer_type_uterus_cancer
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
					  outcome= censor_flag_pneumonia_2, survival_time= time_to_pneumonia); 


					  

**********************************************************************************************************************************************************************;
**********************************************************************************************************************************************************************;
********************************************************* NC outcomes: Time to hip/pelvic fracture *****************************************************************;



/***. Unadjusted Hazard ratio for hip/pelvic fracture - competing risk model*/
proc phreg data=comp_eff.event_10;
	class / param=ref ref=first; 
	model time_to_hipp*censor_flag_hipp_2(0) = doac_flag / eventcode=1 risklimits;
run;


**2. Trimmed IPTW association of ischemic stroke or systematic embolism;
proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag / param=ref ref=first;
	model time_to_hipp*censor_flag_hipp_2(0) = doac_flag / eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

**3. Fine stratification;
%fine_stratification (in_data= comp_eff.propensity_score_trimmed, exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
					  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
					  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
					  cancer_type_stomach_cancer cancer_type_uterus_cancer
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
					  outcome= censor_flag_hipp_2, survival_time= time_to_hipp); 


					  

**********************************************************************************************************************************************************************;
**********************************************************************************************************************************************************************;
********************************************************* NC outcomes: Time to sepsis *****************************************************************;



/***. Unadjusted Hazard ratio for hip/pelvic fracture - competing risk model*/
proc phreg data=comp_eff.event_11;
	class / param=ref ref=first; 
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag / eventcode=1 risklimits;
run;


**2. Trimmed IPTW association of ischemic stroke or systematic embolism;
proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;
proc phreg data=comp_eff.propensity_score_trimmed_with_yr;
	class doac_flag/ param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;
proc phreg data=comp_eff.propensity_score_trimmed_yr_time;
	class doac_flag/ param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;

**3. Fine stratification;
%fine_stratification (in_data= comp_eff.propensity_score_trimmed, exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

					  ps_class_var_list= m_sex maritalm dualflag chemo
					  racem_black racem_hispanic racem_white racem_other
					  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
					  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
					  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
					  cancer_type_stomach_cancer cancer_type_uterus_cancer
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
					  outcome= censor_flag_sepsis_2, survival_time= time_to_sepsis); 
