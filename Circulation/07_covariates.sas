/****************************************************************************
| Program name : 07_Covariates 
| Date (update):
| Project name :
| Purpose      :
|
|
****************************************************************************/


data comp_eff.covariate_01;
	set comp_eff.event_1;


	/**************** cancer tumor characteristics (stage, grade, tumor size etc.)***********/

	* stage;
	if dajcc7_01 in ("000", "010", "020") then stage = "Stage 0      ";
	else if 100 <= dajcc7_01 <= 220 then stage = "Stage I      ";
	else if 300 <= dajcc7_01 <= 430 then stage = "Stage II      ";
	else if 500 <= dajcc7_01 <= 630 then stage = "Stage III      ";
	else if 700 <= dajcc7_01 <= 740 then stage = "Stage IV      ";
	else if 888 <= dajcc7_01 <= 999 then stage = "Unknown";

	drop dajcc7_01;

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

	drop numeric_cstum1;


	
	/**************** demographic characteristics (race, Marital status, region)***********/
	/*Sex*/
	m_sex = m_sex - 1;

	/*Race*/
	IF RACE = '1' THEN Racem = 'White	';
	else IF RACE = '2' THEN Racem = 'Black	';
	else IF RACE = '5' THEN Racem = 'Hispanic	';
	else IF RACE in ('3', '4', '6', '0') THEN Racem = 'Other	';
	drop race;

	/*Marital status*/
	Maritalm = 0;
	IF marst1 = '2' THEN Maritalm = 1;*Married;

	drop marst1;

	
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

	/*********************************** Medicaid eligibility ********************************/

	*Medicaid eligibility;
	
	ARRAY dual{96} $ dual09_01-dual09_12 dual10_01-dual10_12 dual11_01-dual11_12 dual12_01-dual12_12
					 dual13_01-dual13_12 dual14_01-dual14_12 dual15_01-dual15_12 dual16_01-dual16_12;
	Dualflag = 0;

	DO i = start_mon TO Diag_index-1;
		IF dual{i} in ('01','02','03','04','05','06', '07','08','09') THEN Dualflag=1; 
	END;

	drop mon217 - mon312  
		 plan09_01 - plan09_12 plan10_01 - plan10_12 plan11_01 - plan11_12 plan12_01 - plan12_12
		 plan13_01 - plan13_12 plan14_01 - plan14_12 plan15_01 - plan15_12 plan16_01 - plan16_12
		 dual09_01-dual09_12 dual10_01-dual10_12 dual11_01-dual11_12 dual12_01-dual12_12
		 dual13_01-dual13_12 dual14_01-dual14_12 dual15_01-dual15_12 dual16_01-dual16_12;

	/*********************************** Year ********************************/
	* Year of DOAC initation date;
	
	init_yr = year(init_date);
run;


		 

/************************************************************ Overall health utilization ****************************************************************************************

1. Number of prior hospitalization	- Count of hospitalizations (in Medpar)
2. Number of prior physician visits	- Count of physician visits (in OUTPAT)

********************************************************************************************************************************************************************************/

/******************************************************************* 1.Number of hospitalization *******************************************************************************/
%macro hosp (out_file, in_file);
data comp_eff.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID ADMSNDTM ADMSNDTD ADMSNDTY in=in1) comp_eff.covariate_01 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;
	claim_date = mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	format claim_date mmddyy10.;
run;

data comp_eff.&out_file;
 	merge comp_eff.&out_file (keep=PATIENT_ID claim_date in=in1) comp_eff.covariate_01(keep=patient_id oneyo index_date in=in2);
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

data comp_eff.hospitalization;					 * 11318;
	set comp_eff.hospitalization_09-comp_eff.hospitalization_16;
run;
proc sort data=comp_eff.hospitalization out=comp_eff.hospitalization nodupkey;    * 11295;
	by _all_;
run;

proc sql;				*4991;
	create table comp_eff.hospitalization_summarized as				
	select patient_id, count(claim_date) as number_prior_hospitalization
	from comp_eff.hospitalization
	group by patient_id;
quit;




/******************************************************************* 2.Number of prior physician visits *******************************************************************************/
%macro physician (out_file, in_file);
data comp_eff.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty in=in1) comp_eff.Covariate_01 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;
	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;
run;

data comp_eff.&out_file;
 	merge comp_eff.&out_file (keep=PATIENT_ID claim_date in=in1) comp_eff.covariate_01(keep=patient_id oneyo index_date in=in2);
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

data comp_eff.physician;					 * 558 450;
	set comp_eff.physician_09-comp_eff.physician_16;
run;
proc sort data=comp_eff.physician out=comp_eff.physician nodupkey;    *  67 795;
	by _all_;
run;


proc sql;				* 6876;
	create table comp_eff.physician_summarized as				
	select patient_id, count(claim_date) as number_prior_physician
	from comp_eff.physician
	group by patient_id;
quit;

* Delete datasets no long need;
proc datasets lib=comp_eff nolist;
delete hospitalization_09-hospitalization_16 hospitalization physician_09-physician_16 physician;
run;

data comp_eff.covariate_02;

	*Number of prior hospitalization;
	merge comp_eff.covariate_01(in=in1) comp_eff.hospitalization_summarized; 
	by patient_id;
	if in1;

	*Number of prior physician visits;
	merge comp_eff.covariate_01(in=in2) comp_eff.physician_summarized; 
	by patient_id;
	if in2;

	if number_prior_hospitalization = "." then number_prior_hospitalization = 0;
	if number_prior_physician = "." then number_prior_physician = 0;
run;


/******************************************************************************************************************************************************************************/
/***************************************************** census data process ****************************************************************************/
/******************************************************************************************************************************************************************************/
/******************************************************************************************************************************************************************************/
/******************************************************************************************************************************************************************************/
/******************************************************************************************************************************************************************************/

data comp_eff.census;
	set seermed.census_zip(where=(filetype='03'));
	edu = 100 - zpnon; * average percent high school graduates;
	keep zip5 zppci edu;
	rename zppci = per_capita_income;
run;

/* Add covarite - Education & Income*/
proc sort data = comp_eff.covariate_02; by zip5; run;
	
data comp_eff.covariate_03;
	
	*Education & Income;
	merge comp_eff.covariate_02(in=in1) comp_eff.census(in=in2); 
	by zip5;
	if in1;
	
run;

proc sort data = comp_eff.covariate_02; by _all_; run;
proc sort data = comp_eff.covariate_03; by _all_; run;
