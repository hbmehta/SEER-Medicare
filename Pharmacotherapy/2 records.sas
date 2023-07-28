
**4.3	Identify first NVAF date;
data oac_can.nch;		*4 948 441;
set oac_can.nch_09-oac_can.nch_16;
run;
proc sort data=oac_can.nch;
by PATIENT_ID NVAF_date;
run;

data oac_can.outsaf;	*1 309 008;
set oac_can.outsaf_09-oac_can.outsaf_16;
run;
proc sort data=oac_can.outsaf;
by PATIENT_ID NVAF_date;
run;

data oac_can.medpar;	*661 611;
set oac_can.medpar_09-oac_can.medpar_16;
run;
proc sort data=oac_can.medpar;
by PATIENT_ID NVAF_date;
run;

/** 2 records in outsaf/carrier **/
data oac_can.NVAF_dates_1;
set oac_can.nch oac_can.outsaf;
if NVAF_date = . then delete;
by PATIENT_id;
	if first.PATIENT_id or last.patient_id;
	if first.PATIENT_id=1 then count=1;
	else count+1;
run;
data oac_can.NVAF_dates_2;
set oac_can.NVAF_dates_1;
if count=2;
run;
data oac_can.NVAF_dates_3;
merge oac_can.NVAF_dates_1(in=in1) oac_can.NVAF_dates_2(keep=patient_id in=in2);
by patient_id;
if in1 and in2;
if count = 1;
keep patient_id NVAF_date;
run;
data oac_can.NVAF_dates_4;
set oac_can.NVAF_dates_3 oac_can.medpar;
if NVAF_date = . then delete;
run;
proc sort data=oac_can.NVAF_dates_4 out=oac_can.NVAF_dates_4 nodupkey;
	by PATIENT_ID NVAF_date;
run;

**Delete individual datasets -- i have stacked data;
proc datasets lib=oac_can nolist;
delete nch_09-nch_16 outsaf_09-outsaf_16 medpar_09-medpar_16;
run;

**4.4 Identify index date;
data oac_can.cancer_date_and_NVAF_date_all (keep = patient_id nvaf_date cancer_date);
   merge oac_can.all_cancer_v03(in=in1) oac_can.NVAF_dates_4(in=in2);
   by PATIENT_ID;
   if in1 and in2;
run;

data oac_can.cancer_date_and_NVAF_date;
	set oac_can.cancer_date_and_NVAF_date_all;
	if NVAF_date > cancer_date;
run;

proc sort data= oac_can.cancer_date_and_NVAF_date;
by PATIENT_ID NVAF_date;
run;

data oac_can.index_date;			**195 049 158744
;
	set oac_can.cancer_date_and_NVAF_date;
	by PATIENT_id;
	if first.PATIENT_id=1 then count=1;
	else count+1;
	if count=1 then output oac_can.index_date;
	keep patient_id NVAF_date;
	rename NVAF_date = index_date;
run;

proc sql;							**195 049;
create table oac_can.All_cancer_v04
as select * from
oac_can.All_cancer_v03 as A left join oac_can.index_date as B
on A.patient_id = B.patient_id
where B.index_date NE .;
quit;
