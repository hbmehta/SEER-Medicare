/****************************************************************************
| Program name : 05_create outcomes dates and initiation and censoring scenarios
| Date (update):
| Project name :
| Purpose      :
|
| 
****************************************************************************/

****************************** ischemic stroke date (433.x1, 434.x1 and 436, I63) or systemic embolism(444, I74) ***********************************;
%macro outcome (out_file, in_file);
data comp_eff.&out_file;
 	set seermed.&in_file;

	if DGNSCD1 in:("43301","43311","43321","43331","43381","43391","43401","43411","43491","436","I63","444","I74")  then condition_met=1;
   
	if condition_met=1;
	drop condition_met;
run;
%mend outcome;

%outcome (medpar_outcome09, medpar09);
%outcome (medpar_outcome10, medpar10);
%outcome (medpar_outcome11, medpar11);
%outcome (medpar_outcome12, medpar12);
%outcome (medpar_outcome13, medpar13);
%outcome (medpar_outcome14, medpar14);
%outcome (medpar_outcome15, medpar15);
%outcome (medpar_outcome16, medpar16);

data comp_eff.outcome;
	set comp_eff.medpar_outcome09-comp_eff.medpar_outcome16;
	outcome_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	keep PATIENT_ID outcome_date;		/*Changed renamed date to stroke date*/
	if outcome_date ne .;
run;
proc sort data=comp_eff.outcome out=comp_eff.outcome nodupkey;					*   53287;
	by _all_;
	format outcome_date mmddyy10.;
run;

**Delete individual datasets -- i have stacked data;
proc datasets lib=comp_eff nolist;
delete medpar_outcome09-medpar_outcome16;
run;


data comp_eff.outcome_v01;
	merge comp_eff.outcome(in=in1) comp_eff.all_cancer_v10(keep=patient_id index_date in=in2);
	by patient_id;
	if in1 and in2;
	if outcome_date > index_date;
	if first.patient_id;
run;

data comp_eff.outcome_v02;
	merge comp_eff.all_cancer_v10 comp_eff.outcome_v01(keep=patient_id outcome_date);
	by patient_id;
run;



****************************** all-cause death date ***********************************;

data comp_eff.outcome_v03;
	set comp_eff.outcome_v02;
	
	death_date = mdy(med_dodm, med_dodd, med_dody); 	/*Date of Death*/
	study_end_date = "31Dec2016"d;
	format death_date mmddyy10. study_end_date  mmddyy10.;
	if death_date > study_end_date then death_date_v1 = .;
	else death_date_v1 = death_date;
	format death_date_v1 mmddyy10.;
	
run;



**************************** Initiation of Warfarin/DOAC ****************************************************;

proc sql;
create table comp_eff.outcome_v04 as
	select b.*
	from comp_eff.outcome_v03 as a, comp_eff.Pdesaf_oa as b
	where a.patient_id = b.patient_id and b.srvc_date >= a. index_date
	order by patient_id, srvc_date;
quit;

Data comp_eff.outcome_v05;
set comp_eff.outcome_v04;
by patient_id; 
if first.patient_id;
	if gnn = "WARFARIN SODIUM" then init_drug_class = "Warfarin";
	else init_drug_class = "DOAC";
	if gnn = " " then init_oac = 0;	else init_oac = 1;
rename 	srvc_date = init_date
		gnn = init_drug;
run;
proc freq data= comp_eff.outcome_v05; tables init_drug_class; run;


Data comp_eff.outcome_v06;
merge comp_eff.outcome_v03 comp_eff.outcome_v05(keep=patient_id init_date init_drug_class init_drug);
by patient_id;
run;
proc freq data= comp_eff.outcome_v06; tables outcome_date*init_drug_class/ missing; run;
proc freq data= comp_eff.outcome_v06; tables death_date_v1*init_drug_class/ missing; run;




/***********************************************************************************************************************************************
************************************************************************************************************************************************
																Censoring
************************************************************************************************************************************************
************************************************************************************************************************************************/

/*	Patients will be censored if they switch oral anticoagulants (switching between DOACs will be allowed), ************************************
 *	discontinuation of oral anticoagulants (no prescription refills for the index drug within 30 days after the estimated last day of supply), *
 *	disenrollment from Medicare, ***************************************************************************************************************
 *	death, *************************************************************************************************************************************
 *	or at the end of the study period **********************************************************************************************************
 *  NEW --- Hospice ****************************************************************************************************************************/



/**** Scenario 1 - Switching ************/

data comp_eff.outcome_switch_1;
	set comp_eff.outcome_v04;

	if gnn = "WARFARIN SODIUM" then init_drug_class = "Warfarin";
	else init_drug_class = "DOAC";

	keep patient_id init_drug_class srvc_date;
run;
proc sort data=comp_eff.outcome_switch_1 out=comp_eff.outcome_switch_1 nodup;
	by patient_id init_drug_class srvc_date;
run;


data comp_eff.outcome_switch_2;
	set comp_eff.outcome_switch_1;

	by patient_id init_drug_class;

	if first.patient_id=1 | first.init_drug_class=1 then count=1;
	else count+1;
run;
proc sort data=comp_eff.outcome_switch_2 out=comp_eff.outcome_switch_2 nodup;
	by patient_id srvc_date init_drug_class;
run;


data comp_eff.outcome_switch_3;     *Final list of patients switched with switch drug class and switch date 729;
	set comp_eff.outcome_switch_2;
	if count = 1;
	
	by patient_id;
	if first.patient_id=1 then count_2=1;
	else count_2+1;
	if count_2=2;

	switch_drug_class = init_drug_class;
	switch_date = srvc_date;
	format switch_date mmddyy10.;


	keep patient_id switch_drug_class switch_date;
run;
PROC FREQ DATA=comp_eff.outcome_switch_3;
    TABLES switch_drug_class;
RUN;


/**** Scenario 2 - discontinuation ************/

data comp_eff.outcome_discon_1;
	set comp_eff.outcome_v04;

	end_date = srvc_date+days_suply_num;
	format end_date mmddyy10.;

	keep patient_id srvc_date end_date;
run;
proc sort data=comp_eff.outcome_discon_1 out=comp_eff.outcome_discon_1 nodup;
	by patient_id srvc_date;
run;

data comp_eff.outcome_discon_2;
	set comp_eff.outcome_discon_1;

	last_end_date = lag(end_date);
	format last_end_date mmddyy10.;
	
	by patient_id;
	if first.patient_id then last_end_date = "";
	
	gap_days = srvc_date - last_end_date;

	if gap_days > 30;
	
run;


data comp_eff.outcome_discon_3;
	set comp_eff.outcome_discon_2;

	by patient_id;
	if first.patient_id then count = 1;
	else count+1;

	if count=1;
	

	keep patient_id srvc_date;
	rename srvc_date = discontinuation_date;
run;



/**** Scenario 3 - disenrollment from Medicare ************/
/**** disenrollment from Medicare (A,B or D, just one month  - from index date to death date) *****/

**1 Part A B disenrollment;
data comp_eff.outcome_disenroll_1;
	set comp_eff.outcome_v03;

	Diag_index = (year(index_date)-2010)*12+month(index_date)+12; 
	if death_date_v1 ne "." then end_mon = (year(death_date_v1)-2010)*12+month(death_date_v1)+12; 
	else end_mon = 96;
	
	ARRAY ENTY{96} $ mon217 - mon312;
	Entyflag = 0;
	DO  i = Diag_index TO end_mon;
		IF ENTY{i} not in ('3') THEN Entyflag=Entyflag+1;
		END;
	if Entyflag ne 0;

run;


data comp_eff.outcome_disenroll_1_1;
	set comp_eff.outcome_disenroll_1;

	ARRAY ENTY{96} $ mon217 - mon312;

	dise_mon = 0;
	DO  i = Diag_index TO end_mon until (ENTY{i} not in ('3'));
		 dise_mon = i;
		END;
	
	disenroll_mon = mod(dise_mon-12,12);
	disenroll_yr = (dise_mon-12-disenroll_mon)/12+2010;

	
	disenrollment_A_B_date=mdy(disenroll_mon,1,disenroll_yr);
	format disenrollment_A_B_date mmddyy10.;
	
	keep patient_id disenrollment_A_B_date;

run;


**2 Part D disenrollment;
data comp_eff.outcome_disenroll_2;	*46 948;
	set comp_eff.outcome_v03;
	
	Diag_index = (year(index_date)-2010)*12+month(index_date)+12; 
	if death_date_v1 ne "." then end_mon = (year(death_date_v1)-2010)*12+month(death_date_v1)+12; 
	else end_mon = 96;

	ARRAY plan{96} $ plan09_01 - plan09_12 plan10_01 - plan10_12 plan11_01 - plan11_12 plan12_01 - plan12_12
					plan13_01 - plan13_12 plan14_01 - plan14_12 plan15_01 - plan15_12 plan16_01 - plan16_12;

	Dflag = 0;
	DO  i = Diag_index TO end_mon;
		IF plan{i} in ('0','','N','*') THEN Dflag=Dflag+1; 
	END;

	if Dflag ne 0;
run;

data comp_eff.outcome_disenroll_2_1;
	set comp_eff.outcome_disenroll_2;

	ARRAY plan{96} $ plan09_01 - plan09_12 plan10_01 - plan10_12 plan11_01 - plan11_12 plan12_01 - plan12_12
					plan13_01 - plan13_12 plan14_01 - plan14_12 plan15_01 - plan15_12 plan16_01 - plan16_12;

	dise_mon = 0;
	DO  i = Diag_index TO end_mon until (plan{i} in ('0','','N','*'));
		 dise_mon = i;
		END;
	
	disenroll_mon = mod(dise_mon-12,12);
	disenroll_yr = (dise_mon-12-disenroll_mon)/12+2010;

	
	if disenroll_mon=0 then disenrollment_D_date=mdy(12,1,disenroll_yr-1);
	else disenrollment_D_date=mdy(disenroll_mon,1,disenroll_yr);

	format disenrollment_D_date mmddyy10.;
	keep patient_id disenrollment_D_date;

run;




/**** Scenario 4 - admission to hospice ************/

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
from comp_eff.event_7 as a, hospice_09_16 as b
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



/**** Merge the censoring types to main dataset ************/

/**** Merge Scenario 1 - Switching ************/
data comp_eff.outcome_v07;
	merge comp_eff.outcome_v06 comp_eff.outcome_switch_3;
	by patient_id;
run;
/**** Merge Scenario 2 - discontinuation ************/
data comp_eff.outcome_v08;
	merge comp_eff.outcome_v07 comp_eff.outcome_discon_3;
	by patient_id;
run;
/**** Merge Scenario 3 - disenrollment from Medicare ************/
data comp_eff.outcome_v09;
	merge comp_eff.outcome_v08 comp_eff.outcome_disenroll_1_1;
	by patient_id;
run;
data comp_eff.outcome_v10;
	merge comp_eff.outcome_v09 comp_eff.outcome_disenroll_2_1;
	by patient_id;
run;
/**** Merge Scenario 4 - admission to hospice ************/
data comp_eff.outcome_v11;
merge comp_eff.outcome_v10 (in=a) hospice_cohort_02 (in=b)  hospice_cohort_04 (in=c);
by patient_id;
if a = 1 and b = 0;
run;

/* Final Censoring ********/
data comp_eff.outcome_v12;
	set comp_eff.outcome_v11;

	censor_date=999999;
	array date{6} $ death_date_v1 switch_date discontinuation_date disenrollment_A_B_date disenrollment_D_date hospice_from_dt;
	do i=1 to 6;
		if date{i} lt censor_date and date{i} ne "." then censor_date=date{i};
	end;

	if censor_date=999999 then censor_date = ".";

	format censor_date mmddyy10.;
	
	*Define censoring type;
	if censor_date = "." then censor_type = "none						";
	else if censor_date = death_date_v1 then censor_type = "death			";
	else if censor_date = switch_date then censor_type = "switching			";
	else if censor_date = discontinuation_date then censor_type = "discontinuation			";
	else if censor_date = disenrollment_A_B_date or censor_date = disenrollment_D_date then censor_type = "disenrollment			";
	else if censor_date = hospice_from_dt then censor_type = "Hospice_admission			";

	if censor_date ne switch_date then switch_drug_class = ".";
run;

PROC FREQ DATA=comp_eff.outcome_v12;
    TABLES censor_type*init_drug_class /missing;
RUN;
