/************************************************************************************
	STP 8. Exclude mitral valve		N =  37,374
************************************************************************************/ 

*NOTES
INCLUDED 2016 data
FIXED SUBSTRING FOR ICD-9-CM - V422 AND V33
INCLUDED ICD-10-CM
UPDATED THIS FOR NEW COHORT
I did nto run all highligted codes from Huijun's codes;

/*Exclude patients with a history of mitral or aortic disease, hearty valve surgery or mitral/aortic valve surgery 
in 1 year prior to the index date
Mitral stenosis	ICD-9-CM: 394 to 396, 424.0, 424.1
Heart valve surgery	ICD-9-CM: V42.2, V43.3
Mitral/aortic valve surgery	ICD-9 procedure: 35.10 to 35.14, 35.20 to 35.28
*/
%let mitral_icd10cm = ('I050', 'I051', 'I052', 'I058', 'I060', 'I061', 'I062', 'I068', 'I069', 'I080', 'I088', 'I089', 'I340', 'I348', 'I350', 'I351', 'I352', 'I358', 'I359');
/*%let mitral_icd10pcs = see at the end*/ 

/*NCH*/
/*%macro dgns_nch (out_file, in_file);*/
/*	data oac_can.&out_file;*/
/*		set &in_file;*/
/*		NVAF_date=mdy(from_dtm,from_dtd,from_dty);*/
/*	    format NVAF_date mmddyy10.;*/
/*		keep PATIENT_ID NVAF_date DGNS_CD1-DGNS_CD12;*/
/*	run;*/
/*%mend dgns_nch;*/
/**/
/*%dgns_nch (nch09, seermed.Nch09);*/
/*%dgns_nch (nch10, seermed.Nch10);*/
/*%dgns_nch (nch11, seermed.Nch11);*/
/*%dgns_nch (nch12, seermed.Nch12);*/
/*%dgns_nch (nch13, seermed.Nch13);*/
/*%dgns_nch (nch14, seermed.Nch14);*/
/*%dgns_nch (nch15, seermed.Nch15);*/
/*%dgns_nch (nch16, seermed.Nch16);*/
/**/
/*data oac_can.nch;*/
/*	set oac_can.nch09-oac_can.nch16;*/
/*run;*/

%macro hist (out_file, in_file);
data oac_can.&out_file;
 	set seermed.&in_file;

	array DGNS_CD {12};
	condition_met = 0;
	do k = 1 to 12 until (condition_met=1);
      if substr(DGNS_CD{k},1,3) in ("394","395","396") or DGNS_CD(k) in ("4240","4241","V422","V433") or DGNS_CD(k) in &mitral_icd10cm
		then condition_met=1;
	end;
   
	if condition_met=1;
	drop k;
run;
%mend hist;

%hist (nch09_hist, nch09);
%hist (nch10_hist, nch10);
%hist (nch11_hist, nch11);
%hist (nch12_hist, nch12);
%hist (nch13_hist, nch13);
%hist (nch14_hist, nch14);
%hist (nch15_hist, nch15);
%hist (nch16_hist, nch16);

data oac_can.nch_hist;
	set oac_can.nch09_hist oac_can.nch10_hist oac_can.nch11_hist oac_can.nch12_hist 
		oac_can.nch13_hist oac_can.nch14_hist oac_can.nch15_hist oac_can.nch16_hist;
	Mitral_date=mdy(from_dtm,from_dtd,from_dty);
	keep PATIENT_ID Mitral_date;		/*Changedrenamed date to mitral date*/
run;
proc sort data=oac_can.nch_hist out=oac_can.nch_hist nodupkey;		*1476649;
	by _all_;
run; 

/***********************************************/
/*OUTSAF*/
/*%macro dgns_outsaf (out_file, in_file);*/
/*	data dgns.&out_file;*/
/*		set seermed.&in_file;*/
/*		NVAF_date=mdy(from_dtm,from_dtd,from_dty);*/
/*	    format NVAF_date mmddyy10.;*/
/*		keep PATIENT_ID NVAF_date DGNS_CD1-DGNS_CD25;*/
/*	run;*/
/*%mend dgns_outsaf;*/
/**/
/*%dgns_outsaf (outsaf09, outsaf09);*/
/*%dgns_outsaf (outsaf10, outsaf10);*/
/*%dgns_outsaf (outsaf11, outsaf11);*/
/*%dgns_outsaf (outsaf12, outsaf12);*/
/*%dgns_outsaf (outsaf13, outsaf13);*/
/*%dgns_outsaf (outsaf14, outsaf14);*/
/*%dgns_outsaf (outsaf15, outsaf15);*/
/*%dgns_outsaf (outsaf16, outsaf16);*/

%macro hist2 (out_file, in_file);
data oac_can.&out_file;
 	set seermed.&in_file;
	
	array DGNS_CD {25};
	condition_met = 0;
	do k = 1 to 25 until (condition_met=1);
	  if substr(DGNS_CD{k},1,3) in ("394","395","396") or DGNS_CD(k) in ("4240","4241","V422","V433") or DGNS_CD(k) in &mitral_icd10cm
  	  then condition_met=1;
	end;
   
	if condition_met=1;
	drop k;
run;
%mend hist2;

%hist2 (outsaf09_hist, outsaf09);
%hist2 (outsaf10_hist, outsaf10);
%hist2 (outsaf11_hist, outsaf11);
%hist2 (outsaf12_hist, outsaf12);
%hist2 (outsaf13_hist, outsaf13);
%hist2 (outsaf14_hist, outsaf14);
%hist2 (outsaf15_hist, outsaf15);
%hist2 (outsaf16_hist, outsaf16);

data oac_can.outsaf_hist;
	set oac_can.outsaf09_hist oac_can.outsaf10_hist oac_can.outsaf11_hist oac_can.outsaf12_hist 
		oac_can.outsaf13_hist oac_can.outsaf14_hist oac_can.outsaf15_hist oac_can.outsaf16_hist;
	Mitral_date=mdy(from_dtm,from_dtd,from_dty);
	keep PATIENT_ID Mitral_date;
run;
proc sort data=oac_can.outsaf_hist out=oac_can.outsaf_hist nodupkey;	*298265;
	by _all_;
run;

/***********************************************/
/*medpar*/
/*%macro dgns_medpar (out_file, in_file);*/
/*	data dgns.&out_file;*/
/*		set seermed.&in_file;*/
/*		NVAF_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);*/
/*	    format NVAF_date mmddyy10.;*/
/*		keep PATIENT_ID NVAF_date DGNSCD1-DGNSCD25 PRCDRCD1-PRCDRCD25;*/
/*	run;*/
/*%mend dgns_medpar;*/
/**/
/*%dgns_medpar (medpar09, medpar09);*/
/*%dgns_medpar (medpar10, medpar10);*/
/*%dgns_medpar (medpar11, medpar11);*/
/*%dgns_medpar (medpar12, medpar12);*/
/*%dgns_medpar (medpar13, medpar13);*/
/*%dgns_medpar (medpar14, medpar14);*/
/*%dgns_medpar (medpar15, medpar15);*/
/*%dgns_medpar (medpar16, medpar16);*/

%macro hist3 (out_file, in_file);
data oac_can.&out_file;
 	set seermed.&in_file;
	
	array DGNSCD {25};
	array PRCDRCD {25};
	condition_met = 0;
	do k = 1 to 25 until (condition_met=1);
      if substr(DGNSCD{k},1,3) in ("394","395","396") or DGNSCD(k) in ("4240","4241","V422","V433")  or DGNSCD(k) in &mitral_icd10cm or
		 substr(PRCDRCD{k},1,4) in ("3510","3511","3512","3513","3514","3520","3521","3522","3523","3524","3525","3526","3527","3528") or PRCDRCD(k) in &mitral_icd10pcs
		then condition_met=1;
	end;
   
	if condition_met=1;
	drop k;

run;
%mend hist3;

%hist3 (medpar09_hist, medpar09);
%hist3 (medpar10_hist, medpar10);
%hist3 (medpar11_hist, medpar11);
%hist3 (medpar12_hist, medpar12);
%hist3 (medpar13_hist, medpar13);
%hist3 (medpar14_hist, medpar14);
%hist3 (medpar15_hist, medpar15);
%hist3 (medpar16_hist, medpar16);

data oac_can.medpar_hist;
	set oac_can.medpar09_hist oac_can.medpar10_hist oac_can.medpar11_hist oac_can.medpar12_hist 
		oac_can.medpar13_hist oac_can.medpar14_hist oac_can.medpar15_hist oac_can.medpar16_hist;
	Mitral_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	keep PATIENT_ID Mitral_date;
run;
proc sort data=oac_can.medpar_hist out=oac_can.medpar_hist nodupkey;	* 214703;
	by _all_;
run;

data oac_can.hist;
	set oac_can.medpar_hist oac_can.nch_hist oac_can.outsaf_hist;
run;
proc sort data=oac_can.hist out=oac_can.hist nodupkey;					* 1841450;
	by _all_;
run;

data oac_can.exclusion_2; /*create a list of patient ids with prevalent mitral valve diagnosis*/
   merge oac_can.hist(in=in1) oac_can.index_date_1year_prior(in=in2);
   by PATIENT_ID;
   if in1 and in2 and (oneyo < Mitral_date < index_date);
   keep PATIENT_ID;
run;


proc sql; *37,374;
	create table oac_can.All_cancer_v08 as 
	select *
	from oac_can.All_cancer_v07_3
	where PATIENT_ID not in (select PATIENT_ID from oac_can.exclusion_2) 
	order by PATIENT_ID;
quit;


**Delete individual datasets -- i have stacked data;
proc datasets lib=oac_can nolist;
delete 	nch09_hist 	  nch10_hist 	nch11_hist 	  nch12_hist 	nch13_hist 	  nch14_hist 	nch15_hist 	  nch16_hist 
	 	outsaf09_hist outsaf10_hist outsaf11_hist outsaf12_hist outsaf13_hist outsaf14_hist outsaf15_hist outsaf16_hist 
		medpar09_hist medpar10_hist medpar11_hist medpar12_hist medpar13_hist medpar14_hist medpar15_hist medpar16_hist;
run;

/*data patient.Exclusion_2;*/
/*   merge dgns.hist(in=in1) patient.index_date_1year_prior(in=in2);*/
/*   by PATIENT_ID;*/
/*   if in1 and in2 and NVAF_date > oneyo and NVAF_date < index_date;*/
/*   keep PATIENT_ID;*/
/*run;*/


%let mitral_icd10pcs = 
("02QF0ZZ",
"02QG0ZZ0",
"02QH0ZZ",
"02QJ0ZZ",
"027F04Z",
"027F0DZ",
"027F0ZZ", 
"02NF0ZZ",
"02QF0ZZ",
"027G04Z",
"027G0DZ",
"027G0ZZ",
"02NG0ZZ",
"02QG0ZZ0",
"02VG0ZZ",
"027H04Z",
"027H0DZ",
"027H0ZZ",
"02NH0ZZ",
"02QH0ZZ",
"027J04Z", 
"027J0DZ", 
"027J0ZZ", 
"02NJ0ZZ",
"02QJ0ZZ",
"02RF07Z",
"02RF08Z",
"02RF0JZ",
"02RF0KZ",
"02RF47Z",
"02RF48Z",
"02RF4JZ",
"02RF4KZ",
"02RG07Z",
"02RG08Z",
"02RG0JZ",
"02RG0KZ0",
"02RG47Z",
"02RG48Z",
"02RG4JZ",
"02RG4KZ0",
"02RH07Z",
"02RH08Z",
"02RH0JZ",
"02RH0KZ0",
"02RH47Z",
"02RH48Z",
"02RH4JZ",
"02RH4KZ0",
"02RJ07Z",
"02RJ08Z", 
"02RJ0JZ", 
"02RJ0KZ",
"02RJ47Z", 
"02RJ48Z", 
"02RJ4JZ", 
"02RJ4KZ",
"02RF07Z",
"02RF08Z",
"02RF0KZ",
"02RF47Z",
"02RF48Z",
"02RF4KZ",
"X2RF032",
"X2RF432",
"02RF0JZ",
"02RF4JZ",
"02RG0JZ",
"02RG3JZ",
"02RG4JZ",
"02RH07Z",
"02RH08Z",
"02RH0KZ0",
"02RH47Z",
"02RH48Z",
"02RH4KZ0",
"02RH0JZ",
"02RH4JZ",
"02RJ07Z", 
"02RJ08Z", 
"02RJ0KZ",
"02RJ37Z", 
"02RJ38Z", 
"02RJ3KZ",
"02RJ47Z", 
"02RJ48Z", 
"02RJ4KZ",
"02RJ0JZ", 
"02RJ3JZ", 
"02RJ4JZ"	);
