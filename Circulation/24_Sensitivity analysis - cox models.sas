/****************************************************************************
| Program name : 24_Sensitivity analysis - cox models & HTE
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/

* Create dataset with censor flags for cox models;
data comp_eff.propensity_score_trimmed_cox;
	set comp_eff.propensity_score_trimmed;

	censor_flag_cox = censor_flag;
	censor_flag_3_cox = censor_flag_3;
	censor_flag_sepsis_2_cox = censor_flag_sepsis_2;

	if censor_flag = 2 then censor_flag_cox = 0;
	if censor_flag_3 = 2 then censor_flag_3_cox = 0;
	if censor_flag_sepsis_2 = 2 then censor_flag_sepsis_2_cox = 0;
run;


* stroke;
proc phreg data=comp_eff.propensity_score_trimmed_cox;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag_cox(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* bleeding;
proc phreg data=comp_eff.propensity_score_trimmed_cox;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3_cox(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* sepsis;
proc phreg data=comp_eff.propensity_score_trimmed_cox;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_sepsis*censor_flag_sepsis_2_cox(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;

/***************************************************************************************************************************************/
/***************************************************************************************************************************************/
/***************************************************************************************************************************************/

/************************************************** HTE - age **************************************************************************/

* Create two datasets;
data comp_eff.propensity_score_trimmed_young;
	set comp_eff.propensity_score_trimmed;
	if age < 75;
run;
data comp_eff.propensity_score_trimmed_old;
	set comp_eff.propensity_score_trimmed;
	if age >= 75;
run;

* age < 75;
* stroke;
proc phreg data=comp_eff.propensity_score_trimmed_young;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* bleeding;
proc phreg data=comp_eff.propensity_score_trimmed_young;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* death;
proc phreg data=comp_eff.propensity_score_trimmed_young;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* sepsis;
proc phreg data=comp_eff.propensity_score_trimmed_young;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;

* age >= 75;
* stroke;
proc phreg data=comp_eff.propensity_score_trimmed_old;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* bleeding;
proc phreg data=comp_eff.propensity_score_trimmed_old;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* death;
proc phreg data=comp_eff.propensity_score_trimmed_old;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* sepsis;
proc phreg data=comp_eff.propensity_score_trimmed_old;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;


/***************************************************************************************************************************************/
/***************************************************************************************************************************************/
/***************************************************************************************************************************************/

/************************************************** HTE - gender **************************************************************************/

* Create two datasets;
data comp_eff.propensity_score_trimmed_male;
	set comp_eff.propensity_score_trimmed;
	if sex = 0;
run;
data comp_eff.propensity_score_trimmed_female;
	set comp_eff.propensity_score_trimmed;
	if sex = 1;
run;


* male;
* stroke;
proc phreg data=comp_eff.propensity_score_trimmed_male;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* bleeding;
proc phreg data=comp_eff.propensity_score_trimmed_male;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* death;
proc phreg data=comp_eff.propensity_score_trimmed_male;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* sepsis;
proc phreg data=comp_eff.propensity_score_trimmed_male;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;

* female;
* stroke;
proc phreg data=comp_eff.propensity_score_trimmed_female;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* bleeding;
proc phreg data=comp_eff.propensity_score_trimmed_female;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* death;
proc phreg data=comp_eff.propensity_score_trimmed_female;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* sepsis;
proc phreg data=comp_eff.propensity_score_trimmed_female;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;



/***************************************************************************************************************************************/
/***************************************************************************************************************************************/
/***************************************************************************************************************************************/

/************************************************** HTE - active cancer **************************************************************************/

%let active_cancer_hcpcs_list_1=%str(7726[1-3]|772[8-9][0-9]|773[0-6][0-9]|77370|7737[1-3]|77399|7740[1-9]|7741[0-7]|77418|7742[1-3]|7742[7-9]|774[3-9][0-9]|7752[0-5]|776[0-1][0-9]|77620|777[5-9][0-9]);
%let active_cancer_hcpcs_list_2=%str(J85[1|2|3|6]0|J85[2|6]1|J856[2|5]|J8600|J8610|J8700|J8705|J8999|J900[0-2]|J901[0|5|7|9]|J902[0|5|7]|J903[1|3|5]|J904[0-3|5|7]|J905[0|5]|J906[0|2|5]|J90[7-9]0|J909[1-8]);
%let active_cancer_hcpcs_list_3=%str(J91[0-5]0|J915[1|5]|J916[0|5]|J917[0|1|5|8|9]|J918[1|2|5]|J9190|J920[0|1|2|6-9]|J921[1-9]|J922[5|6|8]|J9230|J9245|J9250);
%let active_cancer_hcpcs_list_4=%str(J926[0-6|8]|J92[7-9]0|J929[1|3]|J930[0|2|3|5-7]|J931[0|5]|J932[0|8]J93[3-5]0|J935[1|4|5|7]|J93[6-9]0|J937[1|5]|J9395|J9[4|6]00|J9999|Q204[3|9]|Q2050|Q0138);
%let active_cancer_procedure_list_1=%str(1160[0-4|6]|1162[0-4|6]|1164[0-4|6]|1730[4-7]|1731[0-5]|1916[0|2]|192[0|2|4]0|1930[1|2|5-7]|4538[4|5]|44139|4414[0|1|3-7]);
%let active_cancer_procedure_list_2=%str(4415[0-3|5-8]|44160|4420[4-8]|4421[0-3]|5815[0|2]58180|582[0|1|4|6]0|5826[2|3|7]|582[7|8][0|5]|5829[0-4]);
%let active_cancer_icd_list=%str(0010|9925|9928|9929|0015);

/*NCH*/
%macro active_cancer_1 (out_file, in_file);
data &out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty hcpcs_cd DGNS_CD1-DGNS_CD12 in=in1) comp_eff.propensity_score_trimmed(keep=patient_id index_date oneyo in=in2);
	by patient_id;
	if in1 and in2;

	active_cancer_date=mdy(from_dtm,from_dtd,from_dty);
	format active_cancer_date mmddyy10.;

	array DGNS_CD {12};
	active_cancer = 0;
	
	if prxmatch("/(&active_cancer_hcpcs_list_1)/", hcpcs_cd) or
	   prxmatch("/(&active_cancer_hcpcs_list_2)/", hcpcs_cd) or
	   prxmatch("/(&active_cancer_hcpcs_list_3)/", hcpcs_cd) or
	   prxmatch("/(&active_cancer_hcpcs_list_4)/", hcpcs_cd) then active_cancer=1;

	do k = 1 to 12;
      if prxmatch("/(&active_cancer_icd_list)/", DGNS_CD(k))
		then active_cancer=1;
	end;
	
	if active_cancer_date > index_date or active_cancer_date < oneyo then active_cancer=0;

	drop k;
run;
%mend active_cancer_1;

%active_cancer_1 (nch_ac09, nch09);
%active_cancer_1 (nch_ac10, nch10);
%active_cancer_1 (nch_ac11, nch11);
%active_cancer_1 (nch_ac12, nch12);
%active_cancer_1 (nch_ac13, nch13);
%active_cancer_1 (nch_ac14, nch14);
%active_cancer_1 (nch_ac15, nch15);
%active_cancer_1 (nch_ac16, nch16);

data nch_ac;
	set nch_ac09-nch_ac16;
	keep PATIENT_ID active_cancer;		/*Changedrenamed date to active cancer date*/
run;
proc sort data=nch_ac out=comp_eff.nch_ac nodupkey;		
	by _all_;
run; 
proc freq data=comp_eff.nch_ac;
	table active_cancer;
run;



/* OUTSAF */
%macro active_cancer_2 (out_file, in_file);
data &out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty hcpcs_cd DGNS_CD1-DGNS_CD25 in=in1) comp_eff.propensity_score_trimmed(keep=patient_id index_date oneyo in=in2);
	by patient_id;
	if in1 and in2;

	active_cancer_date=mdy(from_dtm,from_dtd,from_dty);
	format active_cancer_date mmddyy10.;

	array DGNS_CD {25};
	active_cancer = 0;

	if prxmatch("/(&active_cancer_hcpcs_list_1)/", hcpcs_cd) or
	   prxmatch("/(&active_cancer_hcpcs_list_2)/", hcpcs_cd) or
	   prxmatch("/(&active_cancer_hcpcs_list_3)/", hcpcs_cd) or
	   prxmatch("/(&active_cancer_hcpcs_list_4)/", hcpcs_cd) then active_cancer=1;

	do k = 1 to 25;
      if prxmatch("/(&active_cancer_icd_list)/", DGNS_CD(k))
		then active_cancer=1;
	end;
	
	if active_cancer_date > index_date or active_cancer_date < oneyo then active_cancer=0;

	drop k;

run;
%mend active_cancer_2;

%active_cancer_2 (outsaf_ac09, outsaf09);
%active_cancer_2 (outsaf_ac10, outsaf10);
%active_cancer_2 (outsaf_ac11, outsaf11);
%active_cancer_2 (outsaf_ac12, outsaf12);
%active_cancer_2 (outsaf_ac13, outsaf13);
%active_cancer_2 (outsaf_ac14, outsaf14);
%active_cancer_2 (outsaf_ac15, outsaf15);
%active_cancer_2 (outsaf_ac16, outsaf16);

data outsaf_ac;
	set outsaf_ac09-outsaf_ac16;
	keep PATIENT_ID active_cancer;
run;
proc sort data=outsaf_ac out=comp_eff.outsaf_ac nodupkey;			
	by _all_;
run;




/* Medpar */
%macro active_cancer_3 (out_file, in_file);
data &out_file;
 	merge seermed.&in_file(keep=PATIENT_ID ADMSNDTM ADMSNDTD ADMSNDTY DGNSCD1-DGNSCD25 PRCDRCD1-PRCDRCD25 in=in1) comp_eff.propensity_score_trimmed(keep=patient_id index_date oneyo in=in2);
	by patient_id;
	if in1 and in2;

	active_cancer_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	format active_cancer_date mmddyy10.;

	array DGNSCD {25};
	array PRCDRCD {25};
	active_cancer = 0;

	do k = 1 to 25;
	  if prxmatch("/(&active_cancer_icd_list)/", DGNS_CD(k)) or prxmatch("/(&active_cancer_procedure_list_1)/", PRCDRCD{k}) or prxmatch("/(&active_cancer_procedure_list_2)/", PRCDRCD{k})
		then active_cancer=1;
	end;
	
	if active_cancer_date > index_date or active_cancer_date < oneyo then active_cancer=0;

	drop k;
run;
%mend active_cancer_3;
%active_cancer_3 (medpar_ac09, medpar09);
%active_cancer_3 (medpar_ac10, medpar10);
%active_cancer_3 (medpar_ac11, medpar11);
%active_cancer_3 (medpar_ac12, medpar12);
%active_cancer_3 (medpar_ac13, medpar13);
%active_cancer_3 (medpar_ac14, medpar14);
%active_cancer_3 (medpar_ac15, medpar15);
%active_cancer_3 (medpar_ac16, medpar16);

data medpar_ac;
	set medpar_ac09-medpar_ac16;
	keep PATIENT_ID active_cancer;
run;
proc sort data=medpar_ac out=comp_eff.medpar_ac nodupkey;			
	by _all_;
run;



/* combine the three */
data comp_eff.active_cancer;
	set comp_eff.medpar_ac comp_eff.nch_ac comp_eff.outsaf_ac;
run;
proc sort data=comp_eff.active_cancer out=comp_eff.active_cancer nodupkey;				
	by _all_;
run;


/* summarize table */
proc sql;				

	create table comp_eff.active_cancer_summarized as				
	select patient_id, max(active_cancer) as active_cancer
	from comp_eff.active_cancer
	group by patient_id
	;

quit;


/* Final step - merge to cohort */
data comp_eff.propensity_score_trimmed_2;
	merge comp_eff.propensity_score_trimmed(in=in1) comp_eff.active_cancer_summarized(keep=patient_id active_cancer);
	by patient_id;
	if in1;
run;

proc freq data=comp_eff.propensity_score_trimmed_2;
	table active_cancer;
run;

* Active Cancer;
* stroke;
proc phreg data=comp_eff.propensity_score_trimmed_2(where=(active_cancer=1));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* bleeding;
proc phreg data=comp_eff.propensity_score_trimmed_2(where=(active_cancer=1));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* death;
proc phreg data=comp_eff.propensity_score_trimmed_2(where=(active_cancer=1));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* sepsis;
proc phreg data=comp_eff.propensity_score_trimmed_2(where=(active_cancer=1));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;

* No Active Cancer;
* stroke;
proc phreg data=comp_eff.propensity_score_trimmed_2(where=(active_cancer=0));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* bleeding;
proc phreg data=comp_eff.propensity_score_trimmed_2(where=(active_cancer=0));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* death;
proc phreg data=comp_eff.propensity_score_trimmed_2(where=(active_cancer=0));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

* sepsis;
proc phreg data=comp_eff.propensity_score_trimmed_2(where=(active_cancer=0));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
run;





proc means data=comp_eff.propensity_score_trimmed_2 N mean median p25 p75 maxdec=1; var time_to_stroke_embolism; class doac_flag; run;
