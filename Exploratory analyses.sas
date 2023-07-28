/**** Exploratory analyses ****/

/************************************************************************************
	Initiation rate
************************************************************************************/

* Initiation rate table;
proc freq data = oac_can.cohort_v12;
tables init_drug_class / missing;
tables init_drug_class*init_year;
tables time_afib_init_v1;
tables time_afib_death;
run;

proc freq data = oac_can.cohort_v12(where=(time_afib_death>3 or time_afib_death = .)); *initiation rate among patients who did not die within the first three months;
tables init_drug_class / missing;
tables init_drug_class*init_year;
tables time_afib_init_v1;
tables afib_year;
run;

proc freq data = oac_can.cohort_v12(where=(time_afib_death>6 or time_afib_death = .)); *initiation rate among patients who did not die within the first six months;
tables init_drug_class / missing;
run;
proc freq data = oac_can.cohort_v12(where=(time_afib_death>12 or time_afib_death = .)); *initiation rate among patients who did not die within the first 12 months;
tables init_drug_class / missing;
run;

proc freq data = oac_can.cohort_v12(where=(time_afib_death>3 or time_afib_death = .)); 
tables stage / missing;
run;

* Descriptive characteristics for sex, race, cancer site, stage, age for no OAC and OAC;
data oac_can.cohort_v13;
	set oac_can.cohort_v12(where=(time_afib_death>3 or time_afib_death = .));
run;
data oac_can.sub_cohort_No_OAC;
	set oac_can.cohort_v12(where=(time_afib_death>3 or time_afib_death = .));
	if init_drug_class = ""; 
run;
data oac_can.sub_cohort_All_OAC;
	set oac_can.cohort_v12(where=(time_afib_death>3 or time_afib_death = .));
	if init_drug_class ne "";
run;
data oac_can.sub_cohort_DOAC;
	set oac_can.cohort_v12(where=(time_afib_death>3 or time_afib_death = .));
	if init_drug_class = "DOAC";
run;
data oac_can.sub_cohort_Warfarin;
	set oac_can.cohort_v12(where=(time_afib_death>3 or time_afib_death = .));
	if init_drug_class = "Warfarin";
run;


PROC MEANS DATA=oac_can.sub_cohort_No_OAC MEAN STD; VAR age time_cancer_to_afib time_afib_to_oac cv_score hb_score number_prior_hospitalization number_prior_physician; RUN; 
PROC MEANS DATA=oac_can.sub_cohort_All_OAC MEAN STD; VAR age time_cancer_to_afib time_afib_to_oac cv_score hb_score number_prior_hospitalization number_prior_physician; RUN; 
PROC MEANS DATA=oac_can.sub_cohort_DOAC MEAN STD; VAR age time_cancer_to_afib time_afib_to_oac cv_score hb_score number_prior_hospitalization number_prior_physician; RUN; 
PROC MEANS DATA=oac_can.sub_cohort_Warfarin MEAN STD; VAR age time_cancer_to_afib time_afib_to_oac cv_score hb_score number_prior_hospitalization number_prior_physician; RUN; 

PROC FREQ DATA=oac_can.sub_cohort_No_OAC; TABLES age_grp m_sex Racem stage cancer_type maritalm Dualflag regionm afib_year init_year grade tumor_size rank_edu_char rank_income_char chemo/ missing; RUN;
PROC FREQ DATA=oac_can.sub_cohort_All_OAC; TABLES age_grp m_sex Racem stage cancer_type maritalm Dualflag regionm afib_year init_year grade tumor_size rank_edu_char rank_income_char chemo/ missing; RUN;
PROC FREQ DATA=oac_can.sub_cohort_DOAC; TABLES age_grp m_sex Racem stage cancer_type maritalm Dualflag regionm afib_year init_year grade tumor_size rank_edu_char rank_income_char chemo/ missing; RUN;
PROC FREQ DATA=oac_can.sub_cohort_Warfarin; TABLES age_grp m_sex Racem stage cancer_type maritalm Dualflag regionm afib_year init_year grade tumor_size rank_edu_char rank_income_char chemo/ missing; RUN;



PROC FREQ DATA=oac_can.sub_cohort_No_OAC; TABLES cv_score hb_score CHF HT STT VD Dia HT AKF ALF bleed alcohol 
												 anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
												 acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi/ missing; RUN;
PROC FREQ DATA=oac_can.sub_cohort_All_OAC; TABLES cv_score hb_score CHF HT STT VD Dia HT AKF ALF bleed alcohol 
												 anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
												 acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi/ missing; RUN;
PROC FREQ DATA=oac_can.sub_cohort_DOAC; TABLES cv_score hb_score CHF HT STT VD Dia HT AKF ALF bleed alcohol 
												 anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
												 acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi/ missing; RUN;
PROC FREQ DATA=oac_can.sub_cohort_Warfarin; TABLES cv_score hb_score CHF HT STT VD Dia HT AKF ALF bleed alcohol 
												 anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
												 acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi/ missing; RUN;





PROC MEANS DATA=oac_can.cohort_v13 MEAN STD; VAR age time_cancer_to_afib time_afib_to_oac cv_score hb_score number_prior_hospitalization number_prior_physician; CLASS init_oac/missing; RUN; 

PROC MEANS DATA=oac_can.cohort_v13 MEAN STD; VAR age time_cancer_to_afib time_afib_to_oac cv_score hb_score number_prior_hospitalization number_prior_physician; CLASS init_drug_class/missing; RUN; 


PROC FREQ DATA=oac_can.cohort_v13; TABLES (age_grp m_sex Racem stage cancer_type maritalm Dualflag regionm afib_year init_year grade tumor_size rank_edu_char rank_income_char chemo
										  cv_score hb_score CHF HT STT VD Dia HT AKF ALF bleed alcohol 
										  anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
										  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi)*init_oac/ missing; RUN;

PROC FREQ DATA=oac_can.cohort_v13; TABLES (age_grp m_sex Racem stage cancer_type maritalm Dualflag regionm afib_year init_year grade tumor_size rank_edu_char rank_income_char chemo
										  cv_score hb_score CHF HT STT VD Dia HT AKF ALF bleed alcohol 
										  anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR
										  acei arb av antiarrhythmics antiplatelets aspirin bb ccb diuretics oa dd estrogens progestins hlmwh naid statins nlld ppi)*init_drug_class/ missing; RUN;


/* comments */
/*
1- One exclusion criteria was to exclude patients who had diagnosis of mitral stenosis, heart valve surgery, or mitral/aortic valve surgery 
within 12 months prior to atrial fibrillation (AF) diagnosis. Couldyou please look at our current cohort (N=28,368) and 
see how many of them had these diagnoses beyond 12 month prior to AF diagnosis?
*/
data patient_number; /*create a list of patient ids with mitral valve diagnosis*/
   merge oac_can.hist(in=in1) oac_can.All_cancer_v09(in=in2);
   by PATIENT_ID;
   if in1 and in2 and (Mitral_date < index_date);
   keep patient_id index_date Mitral_date;
run;
proc sort data=patient_number nodup; by patient_id Mitral_date;run;
data patient_number_2; 
   set patient_number;
   by PATIENT_ID;
   if last.patient_id;
   format Mitral_date mmddyy10.;
run;

data patient_number_3;
	set patient_number_2;
	day_diff = index_date - Mitral_date;
	if day_diff <365 then year_diff = "<1 year			";
	else if 365 <= day_diff <730 then year_diff = "1-2 year";
	else if 730 <= day_diff <1095 then year_diff = "2-3 year";
	else if 1095 <= day_diff < 1460 then year_diff = "3-4 year";
	else if 1460 <= day_diff  then year_diff = ">4 year";
run;
proc freq data=patient_number_3;
table year_diff;
run;

/*
2- Couldyou you please let us know of those who initiated warfarin, how many patients switched to DOAC within 6 month, 1 year, and >1 year. 
Also, of those who initiated warfarin, how many patients switched to DOACs within 6 month, 1 yesr and >1year?
*/
data test;
	set oac_can.final_cohort;
	if switch_date ne .;
	keep patient_id init_date switch_date switch_drug_class date_diff month_diff;
	date_diff = switch_date - init_date;
	if date_diff <=180 then month_diff = "1_within_6_months";
	else if 180 < date_diff <=365 then month_diff = "2_1year";
	else if date_diff>=365 then month_diff = "3_>1year";
run;

proc freq data=test;
	table switch_drug_class*month_diff;
run;
