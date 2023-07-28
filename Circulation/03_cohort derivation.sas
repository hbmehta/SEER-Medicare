/************************************************************************************
	STEP 8. Exclude mitral valve		N =  16,465
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
%macro hist (out_file, in_file);
data comp_eff.&out_file;
 	set seermed.&in_file;

	array DGNS_CD {12};
	condition_met = 0;
	do k = 1 to 12;
      if substr(DGNS_CD{k},1,3) in ("394","395","396") or DGNS_CD(k) in ("4240","4241","V422","V433") or DGNS_CD(k) in &mitral_icd10cm
		then condition_met=1;
	end;
   
	if condition_met=1;
	drop k;
run;
%mend hist;

%hist (nch_hist09, nch09);
%hist (nch_hist10, nch10);
%hist (nch_hist11, nch11);
%hist (nch_hist12, nch12);
%hist (nch_hist13, nch13);
%hist (nch_hist14, nch14);
%hist (nch_hist15, nch15);
%hist (nch_hist16, nch16);

data comp_eff.nch_hist;
	set comp_eff.nch_hist09-comp_eff.nch_hist16;
	Mitral_date=mdy(from_dtm,from_dtd,from_dty);
	keep PATIENT_ID Mitral_date;		/*Changedrenamed date to mitral date*/
run;
proc sort data=comp_eff.nch_hist out=comp_eff.nch_hist nodupkey;		* 1476649;
	by _all_;
run; 

/***********************************************/
/*OUTSAF*/

%macro hist2 (out_file, in_file);
data comp_eff.&out_file;
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

%hist2 (outsaf_hist09, outsaf09);
%hist2 (outsaf_hist10, outsaf10);
%hist2 (outsaf_hist11, outsaf11);
%hist2 (outsaf_hist12, outsaf12);
%hist2 (outsaf_hist13, outsaf13);
%hist2 (outsaf_hist14, outsaf14);
%hist2 (outsaf_hist15, outsaf15);
%hist2 (outsaf_hist16, outsaf16);

data comp_eff.outsaf_hist;
	set comp_eff.outsaf_hist09-comp_eff.outsaf_hist16;
	Mitral_date=mdy(from_dtm,from_dtd,from_dty);
	keep PATIENT_ID Mitral_date;
run;
proc sort data=comp_eff.outsaf_hist out=comp_eff.outsaf_hist nodupkey;	* 298265;
	by _all_;
run;

/***********************************************/
/*medpar*/
%macro hist3 (out_file, in_file);
data comp_eff.&out_file;
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

%hist3 (medpar_hist09, medpar09);
%hist3 (medpar_hist10, medpar10);
%hist3 (medpar_hist11, medpar11);
%hist3 (medpar_hist12, medpar12);
%hist3 (medpar_hist13, medpar13);
%hist3 (medpar_hist14, medpar14);
%hist3 (medpar_hist15, medpar15);
%hist3 (medpar_hist16, medpar16);

data comp_eff.medpar_hist;
	set comp_eff.medpar_hist09-comp_eff.medpar_hist16;
	Mitral_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	keep PATIENT_ID Mitral_date;
run;
proc sort data=comp_eff.medpar_hist out=comp_eff.medpar_hist nodupkey;	*214703;
	by _all_;
run;

data comp_eff.hist;
	set comp_eff.medpar_hist comp_eff.nch_hist comp_eff.outsaf_hist;
run;
proc sort data=comp_eff.hist out=comp_eff.hist nodupkey;					*1841450;
	by _all_;
run;

data comp_eff.exclusion_1; /*create a list of patient ids with prevalent mitral valve diagnosis*/
   merge comp_eff.hist(in=in1) comp_eff.index_date(in=in2);
   by PATIENT_ID;
   if in1 and in2 and (oneyo < Mitral_date < index_date);
   keep PATIENT_ID;
run;


proc sql;
	create table comp_eff.All_cancer_v08 as 
	select *
	from comp_eff.All_cancer_v07
	where PATIENT_ID not in (select PATIENT_ID from comp_eff.exclusion_1) 
	order by PATIENT_ID;
quit;


**Delete individual datasets -- i have stacked data;
proc datasets lib=comp_eff nolist;
delete 	nch_hist09-nch_hist16 
	 	outsaf_hist09-outsaf_hist16 
		medpar_hist09-medpar_hist16;
run;




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
