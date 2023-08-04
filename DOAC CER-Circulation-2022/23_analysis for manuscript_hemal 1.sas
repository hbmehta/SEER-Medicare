/************************************************************************************
All analyses based on event_8 data - removed hospice patients - n=7630
************************************************************************************/

proc freq data = comp_eff.event_8;
/*table cancer_type*doac_flag*censor_flag;*/
table doac_flag*censor_flag;
table doac_flag*censor_flag_2;
table doac_flag*censor_flag_pneumonia_2;
table doac_flag*censor_flag_3;
run;


proc sql;
select sum (time_to_stroke_embolism) as sum_time_to_stroke_embolism, CALCULATED sum_time_to_stroke_embolism/365.25 as pers_yr_stroke, doac_flag 
from comp_eff.event_8
group by doac_flag;
quit;


/*ESOPHAGUS_CANCER*/
/*STOMACH_CANCER*/
/*OVARY_CANCER*/


%let covaraites = 	age 
				  	sex 
					racem_black racem_hispanic racem_white racem_other
					maritalm 
					dualflag 
			  		regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
					rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
			    	cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
			    	cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
			    	cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
			    	cancer_type_stomach_cancer cancer_type_uterus_cancer
			    	stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
			    	grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
			    	tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
			    	tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
			    	tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm 
					chemo
					CHF HT STT VD Dia AKF ALF bleed alcohol
				    anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
				    Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall
				    acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi
				    number_prior_hospitalization 
				    number_prior_physician
;

proc psmatch data=comp_eff.event_8 region=allobs;
		class doac_flag 
				sex  
				racem_black racem_hispanic racem_white racem_other
				maritalm 
				dualflag 
			  	regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west
				rank_income_char_0 rank_income_char_1 rank_income_char_2 rank_income_char_3 rank_income_char_Missing
			    cancer_type_bladder_cancer cancer_type_breast_cancer cancer_type_colorectal_cancer
			    cancer_type_esophagus_cancer cancer_type_kidney_cancer cancer_type_lung_cancer
			    cancer_type_ovary_cancer cancer_type_pancreas_cancer cancer_type_prostate_cancer
			    cancer_type_stomach_cancer cancer_type_uterus_cancer
			    stage_stage_0 stage_stage_I stage_stage_II stage_stage_III stage_stage_IV stage_unknown
			    grade_grade_I grade_grade_II grade_grade_III grade_grade_IV grade_T_cell_B_cell_cell_type_no
			    tumor_size_0cm tumor_size_0cm___tumor_size___1c tumor_size_1cm___tumor_size___2c
			    tumor_size_2cm___tumor_size___3c tumor_size_3cm___tumor_size___4c tumor_size_4cm___tumor_size___5c
			    tumor_size_NA_Site_specific_code tumor_size_tumor_size___5cm 
				chemo		  
			  	CHF HT STT VD Dia AKF ALF bleed alcohol
			  	anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
			  	Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall
			  	acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi
			  	init_yr_2010 init_yr_2011 init_yr_2012 init_yr_2013 init_yr_2014 init_yr_2015 init_yr_2016
				/*rank_edu_char_0 rank_edu_char_1 rank_edu_char_2 rank_edu_char_3 rank_edu_char_Missing*/
				;

		psmodel doac_flag(treated='1')= /*&covaraites*/ age 
				  	sex 
					racem_black racem_hispanic  racem_other
					maritalm 
					dualflag 
			  		regionm_midwest regionm_missing regionm_northeast  regionm_west;

		assess lps var=(age 
				  	sex 
					racem_black racem_hispanic racem_white racem_other
					maritalm 
					dualflag 
			  		regionm_midwest regionm_missing regionm_northeast regionm_south regionm_west)
						/ varinfo nlargestwgt=6 plots=(barchart boxplot(display=(lps )) wgtcloud) weight=atewgt(stabilize=yes);

output out(obs=all)=/*comp_eff.*/propensity_score atewgt(stabilize=yes)=_ATEWgt_;

run;

proc sgplot data=/*comp_eff.*/propensity_score;       
  histogram _ps_ / group=doac_flag transparency=0.5;     
  density _ps_ / type=kernel group=doac_flag; 
run;
