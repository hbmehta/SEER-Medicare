/****************************************************************************
| Program name : 07_covariate
| Date (update):
| Project name :
| Purpose      : Create covariates - Overall health utilization & Education & Income  & time_cancer_to_afib & time_afib_to_oac & init_year & size
|
|
****************************************************************************/


/* Create covariates - Overall health utilization
1. Number of prior hospitalization	- Count of hospitalizations (in Medpar)
2. Number of prior physician visits	- Count of physician visits (in OUTPAT)
***************************************************************************/

/**** Number of hospitalization **************************/
%macro hosp (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID ADMSNDTM ADMSNDTD ADMSNDTY in=in1) oac_can.All_cancer_v10 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;
	claim_date = mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	format claim_date mmddyy10.;
run;

data oac_can.&out_file;
 	merge oac_can.&out_file (keep=PATIENT_ID claim_date in=in1) oac_can.index_date_1year_prior(in=in2);
	by patient_id;
	if in1 and in2;
	if oneyo < claim_date < index_date;
run;

%mend hosp;
%hosp (hospitalization_09, medpar09);
%hosp (hospitalization_10, medpar10);
%hosp (hospitalization_11, medpar11);
%hosp (hospitalization_12, medpar12);
%hosp (hospitalization_13, medpar13);
%hosp (hospitalization_14, medpar14);
%hosp (hospitalization_15, medpar15);
%hosp (hospitalization_16, medpar16);

data oac_can.hospitalization;					 * 22488;
	set oac_can.hospitalization_09-oac_can.hospitalization_16;
run;
proc sort data=oac_can.hospitalization out=oac_can.hospitalization nodupkey;    *  22465;
	by _all_;
run;

proc sql;				*10620;
	create table oac_can.hospitalization_summarized as				
	select patient_id, count(claim_date) as number_prior_hospitalization
	from oac_can.hospitalization
	group by patient_id;
quit;

* Delete datasets no long need;
proc datasets lib=oac_can nolist;
delete hospitalization_09-hospitalization_16 hospitalization;
run;

/**** Number of prior physician visits *******************/
%macro physician (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty in=in1) oac_can.All_cancer_v10 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;
	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;
run;

data oac_can.&out_file;
 	merge oac_can.&out_file (keep=PATIENT_ID claim_date in=in1) oac_can.index_date_1year_prior(in=in2);
	by patient_id;
	if in1 and in2;
	if oneyo < claim_date < index_date;
run;

%mend physician;
%physician (physician_09, outsaf09);
%physician (physician_10, outsaf10);
%physician (physician_11, outsaf11);
%physician (physician_12, outsaf12);
%physician (physician_13, outsaf13);
%physician (physician_14, outsaf14);
%physician (physician_15, outsaf15);
%physician (physician_16, outsaf16);

data oac_can.physician;					 * 1955272;
	set oac_can.physician_09-oac_can.physician_16;
run;
proc sort data=oac_can.physician out=oac_can.physician nodupkey;    * 229192;
	by _all_;
run;

proc sql;				* 24612;
	create table oac_can.physician_summarized as				
	select patient_id, count(claim_date) as number_prior_physician
	from oac_can.physician
	group by patient_id;
quit;

/** Delete datasets no long need;*/
/*proc datasets lib=oac_can nolist;*/
/*delete physician_09-physician_16 physician;*/
/*run;*/

data oac_can.cohort_v04;

	*Number of prior hospitalization;
	merge oac_can.cohort_v03(in=in1) oac_can.hospitalization_summarized; 
	by patient_id;
	if in1;

	*Number of prior physician visits;
	merge oac_can.cohort_v03 oac_can.physician_summarized; 
	by patient_id;
run;


/***************************************************************************************************************************************/
/********************************* census data process ***********************************/
data oac_can.census;
	set seermed.census_zip(where=(filetype='03'));
	edu = 100 - zpnon;
	keep zip5 zppci edu;
	rename zppci = per_capita_income;
run;

/* Add covarite - Education & Income & Medicaid eligibility & time_cancer_to_afib & time_afib_to_oac*/
proc sort data = oac_can.cohort_v04; by zip5; run;
	
data oac_can.cohort_v05;
	
	*Education & Income;
	merge oac_can.cohort_v04(in=in1) oac_can.census(in=in2); 
	by zip5;
	if in1;
	
	*time_cancer_to_afib - Time from cancer to atrial fibrillation diagnosis;
	time_cancer_to_afib = index_date - cancer_date;

	*time_afib_to_oac - Time from atrial fibrillation to first prescription of oral anticoagulants;
	time_afib_to_oac = init_date - index_date;

	*Year of oral anticoagulation use;
	init_year = year(init_date);

	* grade;
	if grade1 = '1' then grade = "Grade I					";
	else if grade1 = '2' then grade = "Grade II					";
	else if grade1 = '3' then grade = "Grade III					";
	else if grade1 = '4' then grade = "Grade IV					";
	else if grade1 in ('5','6','9') then grade = "T-cell/B-cell/cell type not determined";

	drop grade1;
	
	* size;
	numeric_cstum1 = input(cstum1, 3.);
	
	if numeric_cstum1 in (0, 990) then tumor_size = "0cm					";
	else if 0 < numeric_cstum1 <=10 or numeric_cstum1 = 991 then tumor_size = "0cm < tumor_size <=1cm			";
	else if 10 < numeric_cstum1 <=20 or numeric_cstum1 = 992 then tumor_size = "1cm < tumor_size <=2cm			";
	else if 20 < numeric_cstum1 <=30 or numeric_cstum1 = 993 then tumor_size = "2cm < tumor_size <=3cm			";
	else if 30 < numeric_cstum1 <=40 or numeric_cstum1 = 994 then tumor_size = "3cm < tumor_size <=4cm			";
	else if 40 < numeric_cstum1 <=50 or numeric_cstum1 = 995 then tumor_size = "4cm < tumor_size <=5cm			";
	else if 50 < numeric_cstum1 <=989 or numeric_cstum1 = 995 then tumor_size = "tumor_size > 5cm			";
	else if numeric_cstum1 in (888, 999) or 996 <= numeric_cstum1 <=998 or numeric_cstum1 = 995 then tumor_size = "NA/Site-specific codes					";

	drop numeric_cstum1 cstum1;
run;

proc sort data = oac_can.cohort_v04; by _all_; run;
proc sort data = oac_can.cohort_v05; by _all_; run;
