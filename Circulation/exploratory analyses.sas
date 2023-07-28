/**** Exploratory analyses ****/

%include 'D:\SEER Medicare_Huijun\Manuscript 2_comparative effectiveness\SAS codes\macro\stddiff.sas';

** cancer tumor characteristics (stage, grade, tumor size etc.);
%stddiff(inds = comp_eff.event_12, 
		 groupvar = doac_flag, 
		 numvars = age,
		 charvars = stage stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
					grade grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
					tumor_size tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
					tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
					tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm,  
   		 stdfmt = 8.5,
		 outds = stddiff_result) 

 

** Other covariates;
%stddiff(inds = comp_eff.event_12, 
		 groupvar = doac_flag, 
		 numvars = per_capita_income NCIindex rx_risk_index cv_score hb_score number_prior_hospitalization number_prior_physician, 
		 charvars =  maritalm dualflag chemo
					 racem racem_black racem_hispanic racem_white racem_other
					 regionm regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					 cancer_type cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
					 			 cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
								 cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
								 cancer_type_stomach_cancer cancer_type_uterus_cancer
					 index_yr index_yr_2010 index_yr_2011 index_yr_2012 index_yr_2013 index_yr_2014 index_yr_2015 index_yr_2016
/*					 rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing*/
					 rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing,  
   		 stdfmt = 8.5,
		 outds = stddiff_result)

** comorbidities & co-medications;
%stddiff(inds = comp_eff.event_12, 
		 groupvar = doac_flag, 
		 charvars = sex anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
					Osteoporotic_frac fall
					acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi,  
   		 stdfmt = 8.5,
		 outds = stddiff_result)
%stddiff(inds = comp_eff.event_12, 
		 groupvar = doac_flag, 
		 charvars = CHF HT STT VD Dia AKF ALF bleed alcohol,  
   		 stdfmt = 8.5,
		 outds = stddiff_result)

%stddiff(inds = comp_eff.propensity_score_trimmed, 

		 groupvar = doac_flag, 
		 numvars = age number_prior_hospitalization number_prior_physician,
		 charvars =  stage stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
					 grade grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
					 tumor_size tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
					tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
					tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm
					maritalm dualflag chemo
					  racem racem_black racem_hispanic racem_white racem_other
					  regionm regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					  cancer_type cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
					 			 cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
								 cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
								 cancer_type_stomach_cancer cancer_type_uterus_cancer
					 rank_income_char rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
					sex anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
					Osteoporotic_frac fall
					acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi
					CHF HT STT VD Dia AKF ALF bleed alcohol,  
		wtvar = _ATEWgt_,
   		 stdfmt = 8.5,
		 outds = stddiff_result)
%stddiff(inds = comp_eff.propensity_score_trimmed, 

		 groupvar = doac_flag, 
		 numvars =  number_prior_hospitalization number_prior_physician, 
		 charvars = ,  
		wtvar = _ATEWgt_,
   		 stdfmt = 8.5,
		 outds = stddiff_result)

proc freq data = comp_eff.event_12;
	table censor_type*doac_flag;
run;
proc freq data = comp_eff.covariate_11;
	table CHF*doac_flag HT*doac_flag STT*doac_flag VD*doac_flag Dia*doac_flag AKF*doac_flag ALF*doac_flag bleed*doac_flag alcohol*doac_flag;
run;


 


proc means data=comp_eff.covariate_11 mean std; var age; run;
proc means data=comp_eff.covariate_11 median p25 p75; var years_to_end; run;
proc means data=comp_eff.event_6 median p25 p75; var years_to_bleed; run;


/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
/*****************************************************************************************************************************/

/**************************************** clusters of variables **************************************************************/

/*****************************************************************************************************************************/
/*****************************************************************************************************************************/
%let independent= age NCIindex rx_risk_index number_prior_hospitalization number_prior_physician
				  m_sex maritalm dualflag chemo
				  racem_black racem_hispanic racem_white racem_other
				  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
				  cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
				  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
				  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
				  cancer_type_stomach_cancer cancer_type_uterus_cancer
				  index_yr_2010 index_yr_2011 index_yr_2012 index_yr_2013 index_yr_2014 index_yr_2015 index_yr_2016
				  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
				  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
				  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
				  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
				  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm
				  rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing
				  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
				  CHF HT STT VD Dia AKF ALF bleed alcohol;
%let demographic= age m_sex maritalm 
				  racem_black racem_hispanic racem_white racem_other
				  regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
				  rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing
				  rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing;
%let cancer_char= cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
				  cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
				  cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
				  cancer_type_stomach_cancer cancer_type_uterus_cancer chemo
			   	  stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
				  grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
				  tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
				  tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
				  tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm;
%let comorbidity= NCIindex rx_risk_index CHF HT STT VD Dia AKF ALF bleed alcohol;
%let other_covar= number_prior_hospitalization number_prior_physician;
/***. Unadjusted Hazard ratio for ischemic stroke or systematic embolism - competing risk model*/
proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag / eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag age/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag NCIindex/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag rx_risk_index/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag m_sex / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag &independent/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag m_sex / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag &demographic/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag m_sex / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag &cancer_char/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag m_sex / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag &comorbidity/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag m_sex / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag &other_covar/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag m_sex / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag dualflag/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag m_sex / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag &demographic &cancer_char/ eventcode=1 risklimits;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag m_sex / param=ref ref=first; 
	model time_to_stroke_embolism*censor_flag(0) = doac_flag &demographic &cancer_char &comorbidity/ eventcode=1 risklimits;
run;

data plot;
set comp_eff.covariate_16;
	index_yr = year(index_date);
run;
proc freq data=plot; table doac_flag*index_yr; run;
