/****************************************************************************
| Program name : 05_create outcomes
| Date (update):
| Project name :
| Purpose      :
|
|
****************************************************************************/


Data oac_can.cohort_v01;
set oac_can.cohort;
	afib_year = year (index_date);
	afib_mon = month (index_date);

	study_end_date = "31Dec2016"D;

	death_year = year (death_date);
	if death_date > study_end_date then death_date_v1 = .;
	else death_date_v1 = death_date;
	death_year_v1 = year (death_date_v1);

	time_afib_death = intck ('month', index_date, death_date_v1);
	
	format study_end_date mmddyy10.  death_date_v1 mmddyy10.;

run;

proc freq data = oac_can.cohort_v01; 
/*tables afib_year/ list; */
/*tables afib_year*afib_mon / list; */
/*tables death_year death_year_v1;*/ 
tables time_afib_death;
run;

proc sql;
create table oac_can.outcome_v01 as
	select b.*
	from oac_can.cohort_v01 as a, oac_can.Pdesaf_oa as b
	where a.patient_id = b.patient_id and b.srvc_date >= a. index_date
	order by patient_id, srvc_date;
quit;

Data oac_can.outcome_v02;
set oac_can.outcome_v01;
by patient_id; 
if first.patient_id;
	if gnn = "WARFARIN SODIUM" then init_drug_class = "Warfarin";
	else init_drug_class = "DOAC";
	if gnn = " " then init_oac = 0;	else init_oac = 1;
rename 	srvc_date = init_date
		gnn = init_drug;
run;
/*proc freq data= oac_can.outcome_v02; tables gnn; run;*/

proc sql;
create table oac_can.cohort_v02 as
select a.*, b.init_date, b.init_drug, b.init_drug_class, b.init_oac
from oac_can.cohort_v01 as a left join oac_can.outcome_v02 as b
on a.patient_id = b.patient_id;
quit;

data oac_can.cohort_v03;
set oac_can.cohort_v02;
	time_afib_init = intck ('month', index_date, init_date);
	if 0<= time_afib_init <=3 then time_afib_init_v1 =   "0_1 to 3 mon      ";
	if 4<= time_afib_init <=6 then time_afib_init_v1 =   "1_4 to 6 mon      ";
	if 7<= time_afib_init <=12 then time_afib_init_v1=   "2_7 to 12 mon     ";
	if 13<= time_afib_init <=84 then time_afib_init_v1 = "3_more 12 mon";

	/*Sex*/
	m_sex = m_sex - 1;

	/*Race*/
	IF RACE = '1' THEN Racem = 'White	';
	else IF RACE = '2' THEN Racem = 'Black	';
	else IF RACE = '5' THEN Racem = 'Hispanic	';
	else IF RACE in ('3', '4', '6', '0') THEN Racem = 'Other	';
	drop race;

	/*Age*/
	if 66 <= AGE <= 69 then age_grp = "1: 66-69";
    else if 70 <= AGE <= 74 then age_grp = "2: 70-74";
	else if 75 <= AGE <= 79 then age_grp = "3: 75-79";
	else if 80 <= AGE <= 84 then age_grp = "4: 80-84";
	else if 85 <= AGE <= 89 then age_grp = "5: 85-89";
	else if 90 <= AGE <= 94 then age_grp = "6: 90-94";
	else if AGE >= 95 then age_grp = "7: >=95";

	/*Marital status*/
	Maritalm = 0;
	IF marst1 = '2' THEN Maritalm = 1;*Married;

	drop marst1;

	/*Cancer stage*/
	if dajcc7_01 in ("000", "010", "020") then stage = "Stage 0      ";
	else if 100 <= dajcc7_01 <= 220 then stage = "Stage I      ";
	else if 300 <= dajcc7_01 <= 430 then stage = "Stage II      ";
	else if 500 <= dajcc7_01 <= 630 then stage = "Stage III      ";
	else if 700 <= dajcc7_01 <= 740 then stage = "Stage IV      ";
	else if 888 <= dajcc7_01 <= 999 then stage = "Unknown";

	drop dajcc7_01;
	
	/*Region*/
	statec = cats(state2009, state2010, state2011, state2012, state2013, state2014, state2015, state2016);
	state = substr(statec,1,2);
	IF state in ('06','49','15','35','53','02',
				 '04','08','16','30','32','56','41')              THEN Regionm = 'West		' ;
	IF state in ('09','34','23','25','33','36','42','44','50')    THEN Regionm = 'Northeast		' ; 
	IF state in ('19','26','17','18','20','27',
				 '29','31','38','39','46','55')                   THEN Regionm = 'Midwest		' ; 
	IF state in ('13','22','21','01','05','10','11','12','24',
				 '28','37','40','45','47','48','51','54')         THEN Regionm = 'South		' ; 
	if regionm not in ('West', 'Northeast', 'Midwest' ,'South')   THEN Regionm = 'Missing		';
	drop state2009-state2016 statec state;

	/*Zip code*/
	zipc = cats(zip5_2009, zip5_2010, zip5_2011, zip5_2012, zip5_2013, zip5_2014, zip5_2015, zip5_2016);
	zip5 = substr(zipc,1,5);

	drop zip5_2009-zip5_2016 zipc;


run;

/************************************************************************************
	Initiation rate
************************************************************************************/
proc univariate data= oac_can.cohort_v03;
var time_afib_init;
histogram;
run;

**Anytime;
proc freq data = oac_can.cohort_v03;
/*tables time_afib_init_v1*init_oac / missing;*/
tables afib_year*afib_mon/ list missing;
/*where time_afib_death=. or time_afib_death >3;*/
run;




/***********************************************************************************
************************************************************************************
			Switching
************************************************************************************
***********************************************************************************/



data oac_can.outcome_switch_1;
	set oac_can.outcome_v01;

	end_date = srvc_date+days_suply_num;
	format end_date mmddyy10.;

	if gnn = "WARFARIN SODIUM" then init_drug_class = "Warfarin";
	else init_drug_class = "DOAC";

	keep patient_id init_drug_class srvc_date end_date;
run;


proc sort data=oac_can.outcome_switch_1 out=oac_can.outcome_switch_1 nodup;
	by patient_id init_drug_class srvc_date;
run;

data oac_can.outcome_switch_2;
	set oac_can.outcome_switch_1;

	by patient_id init_drug_class;

	if first.patient_id=1 | first.init_drug_class=1 then count=1;
	else count+1;
run;
proc sort data=oac_can.outcome_switch_2 out=oac_can.outcome_switch_2 nodup;
	by patient_id srvc_date init_drug_class;
run;
data oac_can.outcome_switch_3;
	set oac_can.outcome_switch_2;

	last_end_date = lag(end_date);
	if first.patient_id then last_end_date = "";
	format last_end_date mmddyy10.;
	gap_days = srvc_date - last_end_date;

run;


data oac_can.outcome_switch_4;
	set oac_can.outcome_switch_3;
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
PROC FREQ DATA=oac_can.outcome_switch_4;
    TABLES switch_drug_class;
RUN;

/*Exclusion criteria - patient have gap days more than 30, being discontinued*/
data oac_can.patient_discontinued; 
	merge oac_can.outcome_switch_4 oac_can.outcome_switch_3;
	by patient_id;
	if gap_days >30 and srvc_date <= switch_date;
	keep patient_id;
run;

proc sql;
	create table oac_can.outcome_switch_final as 
	select *
	from oac_can.outcome_switch_4
	where PATIENT_ID not in (select PATIENT_ID from oac_can.patient_discontinued) 
	order by PATIENT_ID;
quit;

proc datasets lib=oac_can nolist;
delete patient_discontinued outcome_switch_1-outcome_switch_3;
run;


/* Exploratory analyses for switching */
data oac_can.outcome_summary_1;
	merge oac_can.cohort_v03(where=(time_afib_death>3 or time_afib_death = .) in=in1) oac_can.outcome_switch_4;
	by patient_id;
	if in1;
run;
PROC FREQ DATA=oac_can.outcome_summary_1;
    TABLES switch_drug_class;
RUN;

data oac_can.outcome_summary_2;
	merge oac_can.cohort_v03(where=(time_afib_death>3 or time_afib_death = .) in=in1) oac_can.outcome_switch_final;
	by patient_id;
	if in1;
	
	time_init_death = intck ('month', init_date, death_date_v1);
	
	time_init_switch = intck ('month', init_date, switch_date);

run;
PROC FREQ DATA=oac_can.outcome_summary_2;
    TABLES init_drug_class switch_drug_class;
RUN;

proc freq data = oac_can.outcome_summary_2(where=(time_init_death>3 or time_init_death = .)); *initiation rate among patients who did not die within the first three months;
tables init_drug_class;
tables switch_drug_class / missing;
tables time_init_switch;
run;

proc freq data = oac_can.outcome_summary_2(where=(time_init_death>6 or time_init_death = .)); *initiation rate among patients who did not die within the first six months;
tables init_drug_class;
tables switch_drug_class / missing;
run;
proc freq data = oac_can.outcome_summary_2(where=(time_init_death>12 or time_init_death = .)); *initiation rate among patients who did not die within the first 12 months;
tables init_drug_class;
tables switch_drug_class / missing;
run;
