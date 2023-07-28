/************************************************************************************
	Step 7. Select patients with NVAF diagnosis one year prior	N =   28,055
************************************************************************************/

**8.1 Identify NVAF from all files;
/*ICD-10-CM: I48.0, I48.1x, I48.2x, or I48.91 */
/*ICD-9-CM:  427.31*/

%let afib_code = ('42731', 'I480', 'I481', 'I4811', 'I4819', 'I482', 'I4820', 'I4821', 'I4891');
/*NCH*/
%macro nch (out_file, in_file);
	data comp_eff.&out_file;
		merge seermed.&in_file(in=in1 where=(DGNS_CD1 in &afib_code  or DGNS_CD2 in &afib_code  or
									DGNS_CD3 in &afib_code  or DGNS_CD4 in &afib_code  or
							   	    DGNS_CD5 in &afib_code  or DGNS_CD6 in &afib_code  or
									DGNS_CD7 in &afib_code  or DGNS_CD8 in &afib_code  or
									DGNS_CD9 in &afib_code  or DGNS_CD10 in &afib_code  or
									DGNS_CD11 in &afib_code  or DGNS_CD12 in &afib_code))
			  comp_eff.index_date(in=in2);		
		by patient_id;

		NVAF_date=mdy(from_dtm,from_dtd,from_dty);
    	format NVAF_date mmddyy10.;
		if NVAF_date < index_date;
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
	data comp_eff.&out_file;
		merge seermed.&in_file(in=in1 where=(DGNS_CD1 in &afib_code  or DGNS_CD2 in &afib_code  or
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
									DGNS_CD25 in &afib_code ))
			comp_eff.index_date(in=in2);
		by patient_id;

		NVAF_date=mdy(from_dtm,from_dtd,from_dty);
	    format NVAF_date mmddyy10.;
		if NVAF_date < index_date;
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
	data comp_eff.&out_file;
		merge seermed.&in_file(in=in1 where=(DGNSCD1 in &afib_code  or DGNSCD2  in &afib_code  or
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
									DGNSCD25 in &afib_code ))
			comp_eff.index_date(in=in2);
		by patient_id;

		NVAF_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	    format NVAF_date mmddyy10.;
		if NVAF_date < index_date;
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


**8.2 Remove duplicates --		Overwriting datasets;
proc sort data=comp_eff.nch_09 out=comp_eff.nch_09 nodupkey;	by _all_;	run;
proc sort data=comp_eff.nch_10 out=comp_eff.nch_10 nodupkey;	by _all_;	run;
proc sort data=comp_eff.nch_11 out=comp_eff.nch_11 nodupkey;	by _all_;	run;
proc sort data=comp_eff.nch_12 out=comp_eff.nch_12 nodupkey;	by _all_;	run;
proc sort data=comp_eff.nch_13 out=comp_eff.nch_13 nodupkey;	by _all_;	run;
proc sort data=comp_eff.nch_14 out=comp_eff.nch_14 nodupkey;	by _all_;	run;
proc sort data=comp_eff.nch_15 out=comp_eff.nch_15 nodupkey;	by _all_;	run;
proc sort data=comp_eff.nch_16 out=comp_eff.nch_16 nodupkey;	by _all_;	run;

proc sort data=comp_eff.outsaf_09 out=comp_eff.outsaf_09 nodupkey;	by _all_;	run;
proc sort data=comp_eff.outsaf_10 out=comp_eff.outsaf_10 nodupkey;	by _all_;	run;
proc sort data=comp_eff.outsaf_11 out=comp_eff.outsaf_11 nodupkey;	by _all_;	run;
proc sort data=comp_eff.outsaf_12 out=comp_eff.outsaf_12 nodupkey;	by _all_;	run;
proc sort data=comp_eff.outsaf_13 out=comp_eff.outsaf_13 nodupkey;	by _all_;	run;
proc sort data=comp_eff.outsaf_14 out=comp_eff.outsaf_14 nodupkey;	by _all_;	run;
proc sort data=comp_eff.outsaf_15 out=comp_eff.outsaf_15 nodupkey;	by _all_;	run;
proc sort data=comp_eff.outsaf_16 out=comp_eff.outsaf_16 nodupkey;	by _all_;	run;

proc sort data=comp_eff.medpar_09 out=comp_eff.medpar_09 nodupkey;	by _all_;	run;
proc sort data=comp_eff.medpar_10 out=comp_eff.medpar_10 nodupkey;	by _all_;	run;
proc sort data=comp_eff.medpar_11 out=comp_eff.medpar_11 nodupkey;	by _all_;	run;
proc sort data=comp_eff.medpar_12 out=comp_eff.medpar_12 nodupkey;	by _all_;	run;
proc sort data=comp_eff.medpar_13 out=comp_eff.medpar_13 nodupkey;	by _all_;	run;
proc sort data=comp_eff.medpar_14 out=comp_eff.medpar_14 nodupkey;	by _all_;	run;
proc sort data=comp_eff.medpar_15 out=comp_eff.medpar_15 nodupkey;	by _all_;	run;
proc sort data=comp_eff.medpar_16 out=comp_eff.medpar_16 nodupkey;	by _all_;	run;

 
**8.3	Identify first NVAF date;
data comp_eff.nch;		
	set comp_eff.nch_09-comp_eff.nch_16; 
	if NVAF_date = . then delete;
run;
proc sort data=comp_eff.nch; by PATIENT_ID NVAF_date; run;

data comp_eff.outsaf;	
	set comp_eff.outsaf_09-comp_eff.outsaf_16; 
	if NVAF_date = . then delete;
run;
proc sort data=comp_eff.outsaf; by PATIENT_ID NVAF_date; run;

data comp_eff.medpar;	
	set comp_eff.medpar_09-comp_eff.medpar_16; 
	if NVAF_date = . then delete;
run;
proc sort data=comp_eff.medpar; by PATIENT_ID NVAF_date; run;

* filter for at least 2 records in outsaf/carrier;
data comp_eff.NVAF_dates_1;
set comp_eff.nch comp_eff.outsaf;
by PATIENT_id;
	if first.PATIENT_id or last.patient_id;
	if first.PATIENT_id=1 then count=1;
	else count+1;
if count = 2;
keep patient_id;
run;

* create a list of patient_ids with NVAF one year prior;
data comp_eff.NVAF_dates_2; 
set comp_eff.NVAF_dates_1 comp_eff.medpar(keep=patient_id);
run;
proc sort data=comp_eff.NVAF_dates_2 out=comp_eff.NVAF_dates_2 nodupkey; by PATIENT_ID; run;

**Delete individual datasets -- i have stacked data;
proc datasets lib=comp_eff nolist;
delete nch_09-nch_16 outsaf_09-outsaf_16 medpar_09-medpar_16 NVAF_dates_1;
run;


data comp_eff.all_cancer_v07; * 28,055;
	merge comp_eff.all_cancer_v06_3(in=in1) comp_eff.NVAF_dates_2(in=in2);
	by patient_id;
	if in1 and in2;
run;
