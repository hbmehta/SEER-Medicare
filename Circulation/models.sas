proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag / param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag/ eventcode=1 risklimits;
run;
proc phreg data=comp_eff.propensity_score_trimmed;
	class init_yr(ref='2016');
	model time_to_sepsis*censor_flag_sepsis_2(0) = init_yr/ eventcode=1 risklimits;
run;
proc freq data=comp_eff.propensity_score_trimmed;
	table init_yr*censor_flag_sepsis_2;
run;

proc phreg data=comp_eff.propensity_score_trimmed;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr/ eventcode=1 risklimits;
run;

/*******************************************************************************************************************************/
* 2021/11/21 control for cancer as an indicator for all-cause mortality IPTW adjusted HR;
proc freq data=comp_eff.propensity_score_trimmed;
	table cancer_type;
run;
data comp_eff.propensity_score_trimmed_cancer;
	set comp_eff.propensity_score_trimmed;
	if cancer_type = "BREAST_CANCER" or cancer_type = "PROSTATE_CANCER" then breast_prostate = 1;
	else breast_prostate = 0;
run;

* All-cause death;
proc phreg data=comp_eff.propensity_score_trimmed_cancer;
	class doac_flag init_yr(ref='2016') breast_prostate(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index breast_prostate/ risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_cancer;
	class doac_flag init_yr(ref='2016') cancer_type/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index cancer_type/ risklimits;
	weight _ATEWgt_ / normalize;
run;

/*******************************************************************************************************************************/
* 2021/11/21 interaction terms of subgroups with DOAC;
data comp_eff.propensity_score_trimmed_4;
	set comp_eff.propensity_score_trimmed_3;
	if age >= 75 then age_75up = 1;
	else age_75up = 0;
run;

* All-cause death;
proc phreg data=comp_eff.propensity_score_trimmed_4;
	class doac_flag init_yr(ref='2016') age_75up(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = age_75up doac_flag doac_flag|age_75up init_yr time_cancer_to_index/risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (age_75up=all) diff = pairwise; run;
run;
proc phreg data=comp_eff.propensity_score_trimmed_4;
	class doac_flag init_yr(ref='2016') sex(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag sex doac_flag*sex init_yr time_cancer_to_index/ risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_4;
	class doac_flag init_yr(ref='2016') active_cancer(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag active_cancer doac_flag*active_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_4;
	class doac_flag init_yr(ref='2016') cancer_type_breast_cancer(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = doac_flag cancer_type_breast_cancer doac_flag*cancer_type_breast_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

/*******************************************************************************************************************************/
* 2021/11/24 Censor at 2yr, 3yr, 4yr for all-cause mortality outcome;
data comp_eff.propensity_score_trimmed_5;
	set comp_eff.propensity_score_trimmed_4;
	
	* 2yr, 3yr, 4yr variables;
	index_2yr =  intnx('year',index_date,+2, 'sameday');
	index_3yr =  intnx('year',index_date,+3, 'sameday');
	index_4yr =  intnx('year',index_date,+4, 'sameday');
	format index_2yr index_3yr index_4yr mmddyy10.;

	* participate_end_date = minimum of (censor_date, death_date, 2yr/3yr/4yr);
	participate_end_date_2 = min(participate_end_date, index_2yr);
	participate_end_date_3 = min(participate_end_date, index_3yr);
	participate_end_date_4 = min(participate_end_date, index_4yr);
	format participate_end_date_2 participate_end_date_3 participate_end_date_4 mmddyy10.;
	
	/************************************ Censor flag and outcomes ***************************************************************/

	* censor flag for cox regression model for time to death;
	if participate_end_date_2 = death_date_v1 then censor_flag_2yr = 1; * event coded =1;
	else censor_flag_2yr = 0;
	if participate_end_date_3 = death_date_v1 then censor_flag_3yr = 1; * event coded =1;
	else censor_flag_3yr = 0;
	if participate_end_date_4 = death_date_v1 then censor_flag_4yr = 1; * event coded =1;
	else censor_flag_4yr = 0;
	
	* outcome variables;
	time_to_death_2 = participate_end_date_2 - index_date;
	time_to_death_3 = participate_end_date_3 - index_date;
	time_to_death_4 = participate_end_date_4 - index_date;

run;



proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') / param=ref ref=first;
	model time_to_death_2*censor_flag_2yr(0) = doac_flag init_yr time_cancer_to_index / risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') / param=ref ref=first;
	model time_to_death_3*censor_flag_3yr(0) = doac_flag init_yr time_cancer_to_index / risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') / param=ref ref=first;
	model time_to_death_4*censor_flag_4yr(0) = doac_flag init_yr time_cancer_to_index / risklimits;
	weight _ATEWgt_ / normalize;
run;



/****************************************************************************************/
* 2021/11/24 Number of follow-up and events for mortality for each cancer - what we report in Table 3, need similar numbers for eTable 4, only for cancer site and mortality outcome;
* cancer site: breast, colorectal, lung, prostate, bladder;
proc sql;
	select doac_flag, sum(years_to_death) as sum
	from comp_eff.event_1
	where cancer_type = "BREAST_CANCER"
	group by doac_flag;
quit; 

proc sql;
	select doac_flag, sum(years_to_death) as sum
	from comp_eff.event_1
	where cancer_type = "COLORECTAL_CANCER"
	group by doac_flag;
quit; 

proc sql;
	select doac_flag, sum(years_to_death) as sum
	from comp_eff.event_1
	where cancer_type = "LUNG_CANCER"
	group by doac_flag;
quit; 

proc sql;
	select doac_flag, sum(years_to_death) as sum
	from comp_eff.event_1
	where cancer_type = "PROSTATE_CANCER"
	group by doac_flag;
quit; 

proc sql;
	select doac_flag, sum(years_to_death) as sum
	from comp_eff.event_1
	where cancer_type = "BLADDER_CANCER"
	group by doac_flag;
quit; 

proc freq data=comp_eff.event_1(where=(censor_flag_2=1));
	table cancer_type*doac_flag/norow nocol nopercent;
run;











*********************************************************************************************;
***2021/12/13 p-value for interaction *******************************************************;
data comp_eff.propensity_score_trimmed_5;
	set comp_eff.propensity_score_trimmed_3;
	if age < 75 then age_75low = 1;
	else age_75low = 0;
	if sex =0 then men = 1;
	else men = 0;
run;

* age;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag(ref='0') init_yr(ref='2016') age_75low(ref='0')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = age_75low doac_flag doac_flag|age_75low init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (age_75low=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') age_75low(ref='0')/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = age_75low doac_flag doac_flag|age_75low init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (age_75low=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') age_75low(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = age_75low doac_flag doac_flag|age_75low init_yr time_cancer_to_index/risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (age_75low=all) diff = pairwise; 
run;

* sex;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag(ref='0') init_yr(ref='2016') men(ref='0')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = men doac_flag doac_flag|men init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (men=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') men(ref='0')/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = men doac_flag doac_flag|men init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (men=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') men(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = men doac_flag doac_flag|men init_yr time_cancer_to_index/risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (men=all) diff = pairwise; 
run;

* active cancer;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag(ref='0') init_yr(ref='2016') active_cancer(ref='0')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = active_cancer doac_flag doac_flag|active_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (active_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') active_cancer(ref='0')/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = active_cancer doac_flag doac_flag|active_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (active_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') active_cancer(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = active_cancer doac_flag doac_flag|active_cancer init_yr time_cancer_to_index/risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (active_cancer=all) diff = pairwise; 
run;

* breast cancer;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag(ref='0') init_yr(ref='2016') cancer_type_breast_cancer(ref='0')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = cancer_type_breast_cancer doac_flag doac_flag|cancer_type_breast_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_breast_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_breast_cancer(ref='0')/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = cancer_type_breast_cancer doac_flag doac_flag|cancer_type_breast_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_breast_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_breast_cancer(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = cancer_type_breast_cancer doac_flag doac_flag|cancer_type_breast_cancer init_yr time_cancer_to_index/risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_breast_cancer=all) diff = pairwise; 
run;

* colorectal cancer;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag(ref='0') init_yr(ref='2016') cancer_type_colorectal_cancer(ref='0')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = cancer_type_colorectal_cancer doac_flag doac_flag|cancer_type_colorectal_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_colorectal_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_colorectal_cancer(ref='0')/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = cancer_type_colorectal_cancer doac_flag doac_flag|cancer_type_colorectal_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_colorectal_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_colorectal_cancer(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = cancer_type_colorectal_cancer doac_flag doac_flag|cancer_type_colorectal_cancer init_yr time_cancer_to_index/risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_colorectal_cancer=all) diff = pairwise; 
run;

* lung cancer;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag(ref='0') init_yr(ref='2016') cancer_type_lung_cancer(ref='0')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = cancer_type_lung_cancer doac_flag doac_flag|cancer_type_lung_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_lung_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_lung_cancer(ref='0')/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = cancer_type_lung_cancer doac_flag doac_flag|cancer_type_lung_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_lung_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_lung_cancer(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = cancer_type_lung_cancer doac_flag doac_flag|cancer_type_lung_cancer init_yr time_cancer_to_index/risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_lung_cancer=all) diff = pairwise; 
run;

* Prostate cancer;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag(ref='0') init_yr(ref='2016') cancer_type_prostate_cancer(ref='0')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = cancer_type_prostate_cancer doac_flag doac_flag|cancer_type_prostate_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_prostate_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_prostate_cancer(ref='0')/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = cancer_type_prostate_cancer doac_flag doac_flag|cancer_type_prostate_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_prostate_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_prostate_cancer(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = cancer_type_prostate_cancer doac_flag doac_flag|cancer_type_prostate_cancer init_yr time_cancer_to_index/risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_prostate_cancer=all) diff = pairwise; 
run;

* bladder cancer;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag(ref='0') init_yr(ref='2016') cancer_type_bladder_cancer(ref='0')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = cancer_type_bladder_cancer doac_flag doac_flag|cancer_type_bladder_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_bladder_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_bladder_cancer(ref='0')/ param=ref ref=first;
	model time_to_major_bleed*censor_flag_3(0) = cancer_type_bladder_cancer doac_flag doac_flag|cancer_type_bladder_cancer init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_bladder_cancer=all) diff = pairwise; 
run;
proc phreg data=comp_eff.propensity_score_trimmed_5;
	class doac_flag init_yr(ref='2016') cancer_type_bladder_cancer(ref='0')/ param=ref ref=first;
	model time_to_death*censor_flag_2(0) = cancer_type_bladder_cancer doac_flag doac_flag|cancer_type_bladder_cancer init_yr time_cancer_to_index/risklimits;
	weight _ATEWgt_ / normalize;
	hazardratio 'H1' doac_flag  / at (cancer_type_bladder_cancer=all) diff = pairwise; 
run;

proc freq data=comp_eff.propensity_score_trimmed_5;
	table censor_type*doac_flag/norow nocol nopercent;
run;
