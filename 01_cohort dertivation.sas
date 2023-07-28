/****************************************************************************
| Program name : 01_cohort dertivation
| Date (update):
| Project name :
| Purpose      :
|
|
****************************************************************************/
libname seermed "C:\Seer medicare data";
libname oac_can "C:\Projects\Manuscript 1 - cancer\SAS datasets";


/************************************************************************************
	STEP 1. All cancers	N = 1,436,930
************************************************************************************/

data oac_can.all_cancer;
	set seermed.bladder_cancer 		
		seermed.breast_cancer 		
		seermed.colorectal_cancer 	
		seermed.esophagus_cancer 	
		seermed.kidney_cancer 		
		seermed.lung_cancer 		
		seermed.ovary_cancer		
		seermed.pancreas_cancer 	
		seermed.prostate_cancer 	
		seermed.stomach_cancer 		
		seermed.uterus_cancer		indsname = source;
	libref = scan(source,1,'.');  		/* extract the libref */
	cancer_type = scan(source,2,'.');  /* extract the data set name */
run;

/***********************************************************************************************
	Create ALL variables in a new data for cohort derivation (missing cancer date N =8,210)
	N = 1 428 720
***********************************************************************************************/
Data oac_can.all_cancer_v01 (keep = PATIENT_ID cancer_date cancer_type MODX1 DTDX1 YRDX1 BIRTHM BIRTHYR med_dodm med_dodd med_dody
							m_sex Race marst1 dajcc7_01 cstum1 grade1
							state2009 state2010 state2011 state2012 state2013 state2014 state2015 state2016
							zip5_2009 zip5_2010 zip5_2011 zip5_2012 zip5_2013 zip5_2014 zip5_2015 zip5_2016
							mon217 - mon312  gho217 - gho312 plan09_01 - plan09_12 plan10_01 - plan10_12 
							plan11_01 - plan11_12 plan12_01 - plan12_12 plan13_01 - plan13_12 
							plan14_01 - plan14_12 plan15_01 - plan15_12 plan16_01 - plan16_12
							dual09_01-dual09_12 dual10_01-dual10_12 dual11_01-dual11_12 dual12_01-dual12_12
			 				dual13_01-dual13_12 dual14_01-dual14_12 dual15_01-dual15_12 dual16_01-dual16_12);
set oac_can.all_cancer ;
		DTDX1 = 1;								
		cancer_date=mdy(MODX1,DTDX1,YRDX1);			/*cancer date*/
		   format cancer_date mmddyy10.;
/*		  informat cancer_type $10.;*/
		 if cancer_date = . then delete;
run;


proc freq data=oac_can.all_cancer_v01(where=(YRDX1 in ("2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016")));
	table yrdx1*cancer_type/nopercent nocol norow;
run;

/************************************************************************************
	STEP 2. Cancer between 2010 and 2016 (multiple cancer patient, not unique)	N = 1,061,410
************************************************************************************/
Data oac_can.all_cancer_v02;
set oac_can.all_cancer_v01;
	if year(cancer_date)>=2010 and year(cancer_date)<=2016;
run;

/************************************************************************************
	STEP 3. Select first cancer if patients have multiple cancers N = 1,028,784
************************************************************************************/
proc sort Data = oac_can.all_cancer_v02;
by patient_id cancer_date;
run;

data oac_can.all_cancer_v03;
set oac_can.all_cancer_v02;
by patient_id;
if first.patient_id;
run;

/************************************************************************************
	STEP 4. Select patients with NVAF diagnosis 	N = 158,744
************************************************************************************/

**4.1 Identify NVAF from all files;
/*ICD-10-CM: I48.0, I48.1x, I48.2x, or I48.91 */
/*ICD-9-CM:  427.31*/

%let afib_code = ('42731', 'I480', 'I481', 'I4811', 'I4819', 'I482', 'I4820', 'I4821', 'I4891');
/*NCH*/
%macro nch (out_file, in_file);
	data oac_can.&out_file;
		set seermed.&in_file (where=(DGNS_CD1 in &afib_code  or DGNS_CD2 in &afib_code  or
									DGNS_CD3 in &afib_code  or DGNS_CD4 in &afib_code  or
							   	    DGNS_CD5 in &afib_code  or DGNS_CD6 in &afib_code  or
									DGNS_CD7 in &afib_code  or DGNS_CD8 in &afib_code  or
									DGNS_CD9 in &afib_code  or DGNS_CD10 in &afib_code  or
									DGNS_CD11 in &afib_code  or DGNS_CD12 in &afib_code
							));
		NVAF_date=mdy(from_dtm,from_dtd,from_dty);
    	format NVAF_date mmddyy10.;
		keep PATIENT_ID NVAF_date;
	run;
%mend nch;

%nch (nch_09, Nch09);
%nch (nch_10, Nch10);
%nch (nch_11, Nch11);
%nch (nch_12, Nch12);
%nch (nch_13, Nch13);
%nch (nch_14, Nch14);
%nch (nch_15, Nch15);
%nch (nch_16, Nch16);

/*OUTSAF*/
%macro outsaf (out_file, in_file);
	data oac_can.&out_file;
		set seermed.&in_file(where=(DGNS_CD1 in &afib_code  or DGNS_CD2 in &afib_code  or
									DGNS_CD3 in &afib_code  or DGNS_CD4 in &afib_code  or
							   	    DGNS_CD5 in &afib_code  or DGNS_CD6 in &afib_code  or
									DGNS_CD7 in &afib_code  or DGNS_CD8 in &afib_code  or
									DGNS_CD9 in &afib_code  or DGNS_CD10 in &afib_code  or
									DGNS_CD11 in &afib_code  or DGNS_CD12 in &afib_code  or
									DGNS_CD13 in &afib_code  or DGNS_CD14 in &afib_code  or
									DGNS_CD15 in &afib_code  or DGNS_CD16 in &afib_code  or
									DGNS_CD17 in &afib_code  or DGNS_CD18 in &afib_code  or
									DGNS_CD19 in &afib_code  or DGNS_CD20 in &afib_code  or
									DGNS_CD21 in &afib_code  or DGNS_CD21 in &afib_code  or
									DGNS_CD23 in &afib_code  or DGNS_CD24 in &afib_code  or
									DGNS_CD25 in &afib_code ));
		NVAF_date=mdy(from_dtm,from_dtd,from_dty);
	    format NVAF_date mmddyy10.;
		keep PATIENT_ID NVAF_date; 
	run;
%mend outsaf;

%outsaf (outsaf_09, outsaf09);
%outsaf (outsaf_10, outsaf10);
%outsaf (outsaf_11, outsaf11);
%outsaf (outsaf_12, outsaf12);
%outsaf (outsaf_13, outsaf13);
%outsaf (outsaf_14, outsaf14);
%outsaf (outsaf_15, outsaf15);
%outsaf (outsaf_16, outsaf16);

/*MedPAR*/
%macro medpar (out_file, in_file);
	data oac_can.&out_file;
		set seermed.&in_file(where=(DGNSCD1 in &afib_code  or DGNSCD2  in &afib_code  or
									DGNSCD3 in &afib_code  or DGNSCD4  in &afib_code  or
							   	    DGNSCD5 in &afib_code  or DGNSCD6  in &afib_code  or
									DGNSCD7 in &afib_code  or DGNSCD8  in &afib_code  or
									DGNSCD9 in &afib_code  or DGNSCD10 in &afib_code  or
									DGNSCD11 in &afib_code  or DGNSCD12 in &afib_code  or
									DGNSCD13 in &afib_code  or DGNSCD14 in &afib_code  or
									DGNSCD15 in &afib_code  or DGNSCD16 in &afib_code  or
									DGNSCD17 in &afib_code  or DGNSCD18 in &afib_code  or
									DGNSCD19 in &afib_code  or DGNSCD20 in &afib_code  or
									DGNSCD21 in &afib_code  or DGNSCD21 in &afib_code  or
									DGNSCD23 in &afib_code  or DGNSCD24 in &afib_code  or
									DGNSCD25 in &afib_code ));
		NVAF_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	    format NVAF_date mmddyy10.;
		keep PATIENT_ID NVAF_date; 
	run;
%mend medpar;

%medpar (medpar_09, medpar09);
%medpar (medpar_10, medpar10);
%medpar (medpar_11, medpar11);
%medpar (medpar_12, medpar12);
%medpar (medpar_13, medpar13);
%medpar (medpar_14, medpar14);
%medpar (medpar_15, medpar15);
%medpar (medpar_16, medpar16);

proc sql;
    create table data_count as
    select memname, nobs 
    from dictionary.tables
    where 	libname = 'OAC_CAN' and 
        	memtype = 'DATA';
quit;

proc print data = data_count;
run;

/* ****NOT UPDATED****
****
Obs memname nobs 
1 ALL_CANCER 1131158 
2 ALL_CANCER_V01 1124801 
3 ALL_CANCER_V02 837395 
4 ALL_CANCER_V03 815966 
5 MEDPAR_09 49515 
6 MEDPAR_10 61162 
7 MEDPAR_11 83447 
8 MEDPAR_12 90242 
9 MEDPAR_13 94849 
10 MEDPAR_14 97421 
11 MEDPAR_15 103015 
12 MEDPAR_16 82686 
13 NCH_09 1249879 
14 NCH_10 1406894 
15 NCH_11 1449891 
16 NCH_12 1511241 
17 NCH_13 1567282 
18 NCH_14 1557505 
19 NCH_15 1520898 
20 NCH_16 1294411 
21 OUTSAF_09 425479 
22 OUTSAF_10 438865 
23 OUTSAF_11 507797 
24 OUTSAF_12 537368 
25 OUTSAF_13 560822 
26 OUTSAF_14 593265 
27 OUTSAF_15 616069 
28 OUTSAF_16 648179 
********/

**4.2 Remove duplicates --		Overwriting datasets;
proc sort data=oac_can.nch_09 out=oac_can.nch_09 nodupkey;	by _all_;	run;
proc sort data=oac_can.nch_10 out=oac_can.nch_10 nodupkey;	by _all_;	run;
proc sort data=oac_can.nch_11 out=oac_can.nch_11 nodupkey;	by _all_;	run;
proc sort data=oac_can.nch_12 out=oac_can.nch_12 nodupkey;	by _all_;	run;
proc sort data=oac_can.nch_13 out=oac_can.nch_13 nodupkey;	by _all_;	run;
proc sort data=oac_can.nch_14 out=oac_can.nch_14 nodupkey;	by _all_;	run;
proc sort data=oac_can.nch_15 out=oac_can.nch_15 nodupkey;	by _all_;	run;
proc sort data=oac_can.nch_16 out=oac_can.nch_16 nodupkey;	by _all_;	run;

proc sort data=oac_can.outsaf_09 out=oac_can.outsaf_09 nodupkey;	by _all_;	run;
proc sort data=oac_can.outsaf_10 out=oac_can.outsaf_10 nodupkey;	by _all_;	run;
proc sort data=oac_can.outsaf_11 out=oac_can.outsaf_11 nodupkey;	by _all_;	run;
proc sort data=oac_can.outsaf_12 out=oac_can.outsaf_12 nodupkey;	by _all_;	run;
proc sort data=oac_can.outsaf_13 out=oac_can.outsaf_13 nodupkey;	by _all_;	run;
proc sort data=oac_can.outsaf_14 out=oac_can.outsaf_14 nodupkey;	by _all_;	run;
proc sort data=oac_can.outsaf_15 out=oac_can.outsaf_15 nodupkey;	by _all_;	run;
proc sort data=oac_can.outsaf_16 out=oac_can.outsaf_16 nodupkey;	by _all_;	run;

proc sort data=oac_can.medpar_09 out=oac_can.medpar_09 nodupkey;	by _all_;	run;
proc sort data=oac_can.medpar_10 out=oac_can.medpar_10 nodupkey;	by _all_;	run;
proc sort data=oac_can.medpar_11 out=oac_can.medpar_11 nodupkey;	by _all_;	run;
proc sort data=oac_can.medpar_12 out=oac_can.medpar_12 nodupkey;	by _all_;	run;
proc sort data=oac_can.medpar_13 out=oac_can.medpar_13 nodupkey;	by _all_;	run;
proc sort data=oac_can.medpar_14 out=oac_can.medpar_14 nodupkey;	by _all_;	run;
proc sort data=oac_can.medpar_15 out=oac_can.medpar_15 nodupkey;	by _all_;	run;
proc sort data=oac_can.medpar_16 out=oac_can.medpar_16 nodupkey;	by _all_;	run;

proc sql;
    create table data_count as
    select memname, nobs 
    from dictionary.tables
    where 	libname = 'OAC_CAN' and 
        	memtype = 'DATA';
quit;

proc print data = data_count;
run;

/*
Obs memname nobs 
1 ALL_CANCER 1131158 
2 ALL_CANCER_V01 1124801 
3 ALL_CANCER_V02 837395 
4 ALL_CANCER_V03 815966 
5 MEDPAR_09 49515 
6 MEDPAR_10 61162 
7 MEDPAR_11 83447 
8 MEDPAR_12 90242 
9 MEDPAR_13 94849 
10 MEDPAR_14 97421 
11 MEDPAR_15 103015 
12 MEDPAR_16 82686 
13 NCH_09 1249879 
14 NCH_10 1406894 
15 NCH_11 1449891 
16 NCH_12 1511241 
17 NCH_13 1567282 
18 NCH_14 1557505 
19 NCH_15 1520898 
20 NCH_16 1294411 
21 OUTSAF_09 425479 
22 OUTSAF_10 438865 
23 OUTSAF_11 507797 
24 OUTSAF_12 537368 
25 OUTSAF_13 560822 
26 OUTSAF_14 593265 
27 OUTSAF_15 616069 
28 OUTSAF_16 648179 
*/
 
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

data oac_can.index_date;			**158744
;
	set oac_can.cancer_date_and_NVAF_date;
	by PATIENT_id;
	if first.PATIENT_id=1 then count=1;
	else count+1;
	if count=1 then output oac_can.index_date;
	keep patient_id NVAF_date;
	rename NVAF_date = index_date;
run;

proc sql;							**158744;
create table oac_can.All_cancer_v04
as select * from
oac_can.All_cancer_v03 as A left join oac_can.index_date as B
on A.patient_id = B.patient_id
where B.index_date NE .;
quit;



/************************************************************************************	
	STEP 5: Exclude prevalent NVAF patients 	N = 137,573
	(Diagnosis of NVAF in 1-year prior to the index date)
************************************************************************************/

data oac_can.index_date_1year_prior;
	set oac_can.index_date;
	oneyo = intnx('year',index_date,-1,"sameday");
	format oneyo mmddyy10.
           index_date mmddyy10.;
run;

data oac_can.exclusion_1; /*create a list of patient ids with prevalent NVAF diagnosis*/
   merge oac_can.cancer_date_and_NVAF_date_all(in=in1) oac_can.index_date_1year_prior(in=in2);
   by PATIENT_ID;
   if in1 and in2 and NVAF_date > oneyo and NVAF_date < index_date;
   keep PATIENT_ID;
run;

proc sort data=oac_can.exclusion_1 out=oac_can.exclusion_1 nodupkey;	
	by _all_;
run;

data oac_can.All_cancer_v05;								* 137 573;
Merge oac_can.All_cancer_v04 (in = a) oac_can.exclusion_1  (in = b);
by patient_id;
if a = 1 and b = 0;
run;
proc sort data = oac_can.All_cancer_v05; by patient_id; run;
