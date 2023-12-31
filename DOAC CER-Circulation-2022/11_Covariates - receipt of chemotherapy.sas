/****************************************************************************
| Program name : 12_Covariates - receipt of chemotherapy
| Date (update):
| Project name :
| Purpose      :
|
|
****************************************************************************/


%let chemo_hcpcs_list=%str(964.|Q008[3-5]|51720|J9[\d\d\d]|9650[0-9]|965[1-4][0-9]);

/*NCH*/
%macro chemo1 (out_file, in_file);
data comp_eff.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty hcpcs_cd DGNS_CD1-DGNS_CD12 in=in1) comp_eff.covariate_06(keep=patient_id index_date oneyo in=in2);
	by patient_id;
	if in1 and in2;

	chemo_date=mdy(from_dtm,from_dtd,from_dty);
	format chemo_date mmddyy10.;

	array DGNS_CD {12};
	chemo = 0;

	if prxmatch("/(&chemo_hcpcs_list)/", hcpcs_cd) then chemo=1;

	do k = 1 to 12;
      if DGNS_CD(k) in: ("V5811","V662","V672","Z5111","Z5189","Z08","Z09")
		then chemo=1;
	end;
	
	if chemo_date > index_date or chemo_date < oneyo then chemo=0;

	drop k;
run;
%mend chemo1;

%chemo1 (nch_chemo09, nch09);
%chemo1 (nch_chemo10, nch10);
%chemo1 (nch_chemo11, nch11);
%chemo1 (nch_chemo12, nch12);
%chemo1 (nch_chemo13, nch13);
%chemo1 (nch_chemo14, nch14);
%chemo1 (nch_chemo15, nch15);
%chemo1 (nch_chemo16, nch16);

data comp_eff.nch_chemo;
	set comp_eff.nch_chemo09-comp_eff.nch_chemo16;
	keep PATIENT_ID chemo;		/*Changedrenamed date to chemo date*/
run;
proc sort data=comp_eff.nch_chemo out=comp_eff.nch_chemo nodupkey;		*    8874;
	by _all_;
run; 




/* OUTSAF */
%macro chemo2 (out_file, in_file);
data comp_eff.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty hcpcs_cd DGNS_CD1-DGNS_CD25 in=in1) comp_eff.covariate_06(keep=patient_id index_date oneyo in=in2);
	by patient_id;
	if in1 and in2;

	chemo_date=mdy(from_dtm,from_dtd,from_dty);
	format chemo_date mmddyy10.;

	array DGNS_CD {25};
	chemo = 0;

	if prxmatch("/(&chemo_hcpcs_list)/", hcpcs_cd) then chemo=1;

	do k = 1 to 25;
      if DGNS_CD(k) in: ("V5811","V662","V672","Z5111","Z5189","Z08","Z09")
		then chemo=1;
	end;
	
	if chemo_date > index_date or chemo_date < oneyo then chemo=0;

	drop k;

run;
%mend chemo2;

%chemo2 (outsaf_chemo09, outsaf09);
%chemo2 (outsaf_chemo10, outsaf10);
%chemo2 (outsaf_chemo11, outsaf11);
%chemo2 (outsaf_chemo12, outsaf12);
%chemo2 (outsaf_chemo13, outsaf13);
%chemo2 (outsaf_chemo14, outsaf14);
%chemo2 (outsaf_chemo15, outsaf15);
%chemo2 (outsaf_chemo16, outsaf16);

data comp_eff.outsaf_chemo;
	set comp_eff.outsaf_chemo09-comp_eff.outsaf_chemo16;
	keep PATIENT_ID chemo;
run;
proc sort data=comp_eff.outsaf_chemo out=comp_eff.outsaf_chemo nodupkey;			*  8283;
	by _all_;
run;




/* Medpar */
%macro chemo3 (out_file, in_file);
data comp_eff.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID ADMSNDTM ADMSNDTD ADMSNDTY DGNSCD1-DGNSCD25 PRCDRCD1-PRCDRCD25 in=in1) comp_eff.covariate_06(keep=patient_id index_date oneyo in=in2);
	by patient_id;
	if in1 and in2;

	chemo_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	format chemo_date mmddyy10.;

	array DGNSCD {25};
	array PRCDRCD {25};
	chemo = 0;

	do k = 1 to 25;
      if DGNSCD(k) in: ("V5811","V662","V672","Z5111","Z5189","Z08","Z09")  or PRCDRCD{k} in: ("9925","3E03305","3E04305")
		then chemo=1;
	end;
	
	if chemo_date > index_date or chemo_date < oneyo then chemo=0;

	drop k;
run;
%mend chemo3;
%chemo3 (medpar_chemo09, medpar09);
%chemo3 (medpar_chemo10, medpar10);
%chemo3 (medpar_chemo11, medpar11);
%chemo3 (medpar_chemo12, medpar12);
%chemo3 (medpar_chemo13, medpar13);
%chemo3 (medpar_chemo14, medpar14);
%chemo3 (medpar_chemo15, medpar15);
%chemo3 (medpar_chemo16, medpar16);

data comp_eff.medpar_chemo;
	set comp_eff.medpar_chemo09-comp_eff.medpar_chemo16;
	keep PATIENT_ID chemo;
run;
proc sort data=comp_eff.medpar_chemo out=comp_eff.medpar_chemo nodupkey;			*   6930;
	by _all_;
run;



/* combine the three */
data comp_eff.chemo;
	set comp_eff.medpar_chemo comp_eff.nch_chemo comp_eff.outsaf_chemo;
run;
proc sort data=comp_eff.chemo out=comp_eff.chemo nodupkey;					*    9484;
	by _all_;
run;


/* summarize table */
proc sql;				*7334;

	create table comp_eff.chemo_summarized as				
	select patient_id, max(chemo) as chemo
	from comp_eff.chemo
	group by patient_id
	;

quit;

* Delete datasets no long need;
proc datasets lib=comp_eff nolist;
delete nch_chemo09-nch_chemo16 outsaf_chemo09-outsaf_chemo16 medpar_chemo09-medpar_chemo16 medpar_chemo nch_chemo outsaf_chemo;
run;


/* Final step - merge to cohort */
data comp_eff.covariate_07;
	merge comp_eff.covariate_06(in=in1) comp_eff.chemo_summarized(keep=patient_id chemo);
	by patient_id;
	if in1;
run;
