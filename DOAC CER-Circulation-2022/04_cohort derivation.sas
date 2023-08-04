/************************************************************************************
	STEP 9. Exclude Prevalent OAC users    N =  7,762
************************************************************************************/ 
data comp_eff.Exclusion_2;
   merge comp_eff.pdesaf_oa(in=in1) comp_eff.index_date(in=in2);
   by PATIENT_ID;
   if in1 and in2 and (oneyo < srvc_date < index_date);
   keep PATIENT_ID;
run;


proc sql;		
	create table comp_eff.All_cancer_v09 as 
	select *
	from comp_eff.All_cancer_v08
	where PATIENT_ID not in (select PATIENT_ID from comp_eff.exclusion_2) 
	order by PATIENT_ID;
quit;

/*/********************************************************** We don't do this step now ***********************************************************************************************/*/
/************************************************************************************
	STEP 10. Exclude Prevalent stroke patients    N =  7,587
************************************************************************************/ 

/*/***********************************************/*/
/*/*medpar*/*/
/*%macro stroke (out_file, in_file);*/
/*data comp_eff.&out_file;*/
/* 	set seermed.&in_file;*/
/**/
/*	if DGNSCD1 in:("43301","43311","43321","43331","43381","43391","43401","43411","43491","436","I63","444","I74")  then condition_met=1;*/
/*   */
/*	if condition_met=1;*/
/*	drop condition_met;*/
/*run;*/
/*%mend stroke;*/
/**/
/*%stroke (medpar_stroke09, medpar09);*/
/*%stroke (medpar_stroke10, medpar10);*/
/*%stroke (medpar_stroke11, medpar11);*/
/*%stroke (medpar_stroke12, medpar12);*/
/*%stroke (medpar_stroke13, medpar13);*/
/*%stroke (medpar_stroke14, medpar14);*/
/*%stroke (medpar_stroke15, medpar15);*/
/*%stroke (medpar_stroke16, medpar16);*/
/**/
/*data comp_eff.stroke;*/
/*	set comp_eff.medpar_stroke09-comp_eff.medpar_stroke16;*/
/*	stroke_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);*/
/*	keep PATIENT_ID stroke_date;		/*Changedrenamed date to stroke date*/*/
/*run;*/
/*proc sort data=comp_eff.stroke out=comp_eff.stroke nodupkey;		*   43027;*/
/*	by _all_;*/
/*run;*/
/**/
/***Delete individual datasets -- i have stacked data;*/
/*proc datasets lib=comp_eff nolist;*/
/*delete medpar_stroke09-medpar_stroke16;*/
/*run;*/
/**/
/**/
/*data comp_eff.exclusion_3; /*create a list of patient ids with prevalent stroke diagnosis*/*/
/*   merge comp_eff.stroke(in=in1) comp_eff.index_date(in=in2);*/
/*   by PATIENT_ID;*/
/*   if in1 and in2 and (oneyo < stroke_date < index_date);*/
/*   keep PATIENT_ID;*/
/*run;*/
/**/
/**/
/*proc sql;*/
/*	create table comp_eff.All_cancer_v10 as */
/*	select **/
/*	from comp_eff.All_cancer_v09*/
/*	where PATIENT_ID not in (select PATIENT_ID from comp_eff.exclusion_3) */
/*	order by PATIENT_ID;*/
/*quit;*/;



/************************************************************************************
	STEP 11. Patients who received both warfarin and DOAC on the index date   N =  7,741
************************************************************************************/ 

/***********************************************/

proc sql;
create table comp_eff.Pdesaf_oa_v1 as
	select b.*
	from comp_eff.All_cancer_v10 as a, comp_eff.Pdesaf_oa as b
	where a.patient_id = b.patient_id and b.srvc_date = a. index_date
	order by patient_id, srvc_date;
quit;

data comp_eff.Pdesaf_oa_v2;
	set comp_eff.Pdesaf_oa_v1;
	by patient_id;

	if gnn = "WARFARIN SODIUM" then init_drug_class = "Warfarin";
	else init_drug_class = "DOAC";

	if first.patient_id then count = 1;
	else count = 2;
	if count = 2;
run;

proc sql;
	create table comp_eff.All_cancer_v10 as 
	select *
	from comp_eff.All_cancer_v09
	where PATIENT_ID not in (select PATIENT_ID from comp_eff.Pdesaf_oa_v2) 
	order by PATIENT_ID;
quit;




/*********************************************************************************/
/*				                                                                 */
/*				Exclude Patients receiving hospice care                          */
/*				                                                                 */
/*********************************************************************************/

data hospice_09_16 (keep = patient_id Hospice_from_dt Hospice_thru_dt diff UTIL_DAY);
set seermed.hspsaf09
	seermed.hspsaf10
	seermed.hspsaf11
	seermed.hspsaf12
	seermed.hspsaf13
	seermed.hspsaf14
	seermed.hspsaf15
	seermed.hspsaf16;

Hospice_from_dt=mdy(FROM_DTM,FROM_DTD,FROM_DTY);			
Hospice_thru_dt=mdy(THRU_DTM,THRU_DTD,THRU_DTY);			

format Hospice_from_dt mmddyy10.;
format Hospice_thru_dt mmddyy10.;

diff = Hospice_thru_dt - Hospice_from_dt + 1;

run;

/*hospice use in prior 1 year - use Hospice_thru_dt - end of hospice care date*/
proc sql;
create table hospice_cohort_01 as 
select b.*, a.index_date
from comp_eff.event_7 as a, hospice_09_16 as b
where a.patient_id =b.patient_id and Hospice_thru_dt BETWEEN index_date and index_date-365
order by patient_id, hospice_thru_dt;
quit;
		
proc sort data=hospice_cohort_01 out = hospice_cohort_02  nodupkey;
by patient_id;
run;

data hospice_cohort_02 (keep = patient_id hospice_base);
set hospice_cohort_02;
hospice_base = 1;
run;

/*hospice use in follow-up time - use hospice_from_dt - start of hospice care date*/
proc sql;
create table hospice_cohort_03 as 
select b.*, a.index_date
from comp_eff.All_cancer_v10 as a, hospice_09_16 as b
where a.patient_id =b.patient_id and hospice_from_dt > index_date 
order by patient_id, hospice_from_dt;
quit;
		
proc sort data=hospice_cohort_03 out = hospice_cohort_04  nodupkey;
by patient_id;
run;

data hospice_cohort_04 (keep = patient_id hospice_after hospice_from_dt);
set hospice_cohort_04;
hospice_after = 1;
run;

/*Analytic file with hospitce pts excluded from baseline and hospice varible in follow-up*/
data comp_eff.All_cancer_v11;
merge comp_eff.All_cancer_v10 (in=a) hospice_cohort_02 (in=b)  hospice_cohort_04 (in=c);
by patient_id;
if a = 1 and b = 0;
run;
