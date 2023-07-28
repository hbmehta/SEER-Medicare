/****************************************************************************
| Program name : 22_Create hospice variable
| Date (update):
| Project name :
| Purpose      :
|
|
****************************************************************************/

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

/*Analytic file with hospitce pts excluded from baseline and hospice varible in follow-up*/
data comp_eff.event_8;
merge comp_eff.event_7 (in=a) hospice_cohort_02 (in=b)  hospice_cohort_04 (in=c);
by patient_id;
if a = 1 and b = 0;
run;

proc freq data = comp_eff.event_8;
tables doac_flag*hospice_after / missing;
run;


/************************************************************************************
	CREATE NEW CENSORING AND OUTCOMES
	- Add hospice enrollment date as a censoring criteria (Graham, Circulation. 2015;131:157-164. DOI: 10.1161/CIRCULATIONAHA.114.012061. 

************************************************************************************/



Data comp_eff.event_9 (keep = patient_id censor_date hospice_from_dt censor_date_v2 death_date_v1);
set  comp_eff.event_8;

censor_date_v2 = min (censor_date, hospice_from_dt);

* participate_end_date = minimum of (censor_date, death_date);
participate_end_date_v2 = censor_date_v2;
if participate_end_date_v2 = "." then participate_end_date_v2 = study_end_date;
format participate_end_date mmddyy10.;

format censor_date_v2  mmddyy10.;

run;

