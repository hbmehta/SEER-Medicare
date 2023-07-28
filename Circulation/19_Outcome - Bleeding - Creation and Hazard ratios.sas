/****************************************************************************
| Program name : 19_Outcome - Bleeding - Creation and Hazard ratios
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/

/*create outcomes dates and initiation and censoring scenarios*/

****************************** major bleeding  ***********************************;
%macro m_bleed (out_file, in_file);
data comp_eff.&out_file;
 	set seermed.&in_file;

	if DGNSCD1 in:("430","431","4320","4321","4329","8520","8522","8524","8530","4552","4555","4558","4560","45620","5307","53082","5310","5311","5312","5313","5314","5315","5316",
					"5320","5321","5322","5323","5324","5325","5326","5330","5331","5332","5333","5334","5335","5336","5340","5341","5342","5343","5344","5345","5346","71911","7847",
					"53501","53511","53521","53531","53541","53551","53561","53783","56202","56203","56212","56213","56881","5693","56985","5780","5781","5789","4230","4590","5997",
					"7848","7863","I60","I61","I62","S064","S065","S066","I850","K226","K250","K251","K252","K254","K255","K256","K260","K261","K262","K264","K265","K266","K270",
					"K271","K272","K274","K275","K276","K280","K281","K282","K284","K285","K286","K290","K920","K921","K922","I312","R58","R31","M25019","R04")  then condition_met=1;
					
   
	if condition_met=1;
	drop condition_met;
run;
%mend m_bleed;

%m_bleed (medpar_m_bleed09, medpar09);
%m_bleed (medpar_m_bleed10, medpar10);
%m_bleed (medpar_m_bleed11, medpar11);
%m_bleed (medpar_m_bleed12, medpar12);
%m_bleed (medpar_m_bleed13, medpar13);
%m_bleed (medpar_m_bleed14, medpar14);
%m_bleed (medpar_m_bleed15, medpar15);
%m_bleed (medpar_m_bleed16, medpar16);

data comp_eff.m_bleed;
	set comp_eff.medpar_m_bleed09-comp_eff.medpar_m_bleed16;
	m_bleed_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	keep PATIENT_ID m_bleed_date;		/*renamed date to major bleeding date*/
	if m_bleed_date ne .;
run;
proc sort data=comp_eff.m_bleed out=comp_eff.m_bleed nodupkey;					*   53287;
	by _all_;
	format m_bleed_date mmddyy10.;
run;

**Delete individual datasets -- i have stacked data;
proc datasets lib=comp_eff nolist;
delete medpar_m_bleed09-medpar_m_bleed16;
run;


data comp_eff.event_4;
	merge comp_eff.m_bleed(in=in1) comp_eff.event_3(keep=patient_id index_date in=in2);
	by patient_id;
	if in1 and in2;
	if m_bleed_date > index_date;
	if first.patient_id;
run;

data comp_eff.event_5;
	merge comp_eff.event_3 comp_eff.event_4(keep=patient_id m_bleed_date);
	by patient_id;
run;


/************************* Prepare censoring variables & outcomes **************************************************/
data comp_eff.event_6;
	set comp_eff.event_5;
	
	* major_bleed_date_w_censor = minimum of (censor_date, death_date, m_bleed_date);
	major_bleed_date_w_censor = min(m_bleed_date, participate_end_date);
	format major_bleed_date_w_censor mmddyy10.;
	
	years_to_bleed = (major_bleed_date_w_censor - index_date)/365;
	
	/************************************ Censor flag and outcomes ***************************************************************/
	* censor flag for competing risks model for major bleeding;
	if major_bleed_date_w_censor = m_bleed_date then censor_flag_3 = 1; * event coded =1;
	else if major_bleed_date_w_censor = death_date_v1 then censor_flag_3 = 2;
	else censor_flag_3 = 0;
	
	* outcome variables;
	time_to_major_bleed = major_bleed_date_w_censor - index_date;

run;

proc freq data=comp_eff.event_6;
	tables censor_flag_3*doac_flag;
run;


/************************* Events per 100 patient years ****************************/
proc sql;
	create table comp_eff.bleed_personyr as
	select doac_flag, sum(years_to_bleed) as sum
	from comp_eff.event_6
	group by doac_flag;
quit; 

data comp_eff.bleed_personyr_2;
set comp_eff.bleed_personyr;
if doac_flag=0 then outcome=153;
if doac_flag=1 then outcome=126;
rateper100 = (outcome*100)/sum;
run;
proc genmod data=comp_eff.bleed_personyr_2;
model rateper100 = doac_flag;
run;

/***. Unadjusted Hazard ratio for all-cause death - cox regression model*/

proc phreg data=comp_eff.event_6;
	class / param=ref ref=first; 
	model time_to_major_bleed*censor_flag_3(0) = doac_flag / eventcode=1 risklimits;
run;

proc lifetest data=comp_eff.event_6 plots=cif(test); *Cumulative incidence curve for ischemic stroke or systemic embolism;
   time time_to_major_bleed*censor_flag_3(0)/eventcode=1;
   strata doac_flag / order=internal;
run;

/********************************************************************************
     Derive PS and get Std Diff before and after weighting
********************************************************************************/
proc psmatch data=comp_eff.event_6 region=allobs;
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
			  Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall
			  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi;
		psmodel doac_flag(treated='1')= &covaraites;
		assess lps var=(&covaraites)
						/ varinfo nlargestwgt=6 plots=(barchart boxplot(display=(lps )) wgtcloud) weight=atewgt(stabilize=yes);
output out(obs=all)=comp_eff.propensity_score_2 atewgt(stabilize=yes)=_ATEWgt_;
run;
proc univariate data=comp_eff.propensity_score_2; var _ps_; class doac_flag; histogram; run; /*propensity score*/
proc univariate data=comp_eff.propensity_score_2; var _ATEWgt_; class doac_flag; histogram; run; /*propensity score*/

/*Trimming at 1st and 99th percentile*/
data comp_eff.propensity_score_trimmed_2; 
set comp_eff.propensity_score_2; 
if 0< _ATEWgt_ < 0.604470 then _ATEWgt_=0.604470; 
if _ATEWgt_ > 3.955436 then _ATEWgt_=3.955436; 
if _ATEWgt_=. then delete; 
run;

**2. Trimmed IPTW association of all-cause death;
proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_with_yr;
	class doac_flag/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_yr_time;
	class doac_flag/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

**3. Fine stratification;
%fine_stratification (in_data= comp_eff.propensity_score_trimmed_2, exposure= doac_flag, PS_provided= yes , ps_var= _PS_, 

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
					  outcome= censor_flag_3, survival_time= time_to_major_bleed); 
