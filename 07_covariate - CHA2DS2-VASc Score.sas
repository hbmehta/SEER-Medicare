/****************************************************************************
| Program name : 09_covariate - CHA2DS2-VASc Score
| Date (update):
| Project name :
| Purpose      : Create covariate - CHA2DS2-VASc Score
|
|
****************************************************************************/

 
/* Find out cohort in NCH/OUTPAT/MEDPAR & assign flag for each comorbidity*/
/* NCH */
%macro find1 (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty DGNS_CD1-DGNS_CD12 in=in1) oac_can.All_cancer_v10 (keep=patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;

	*Find out diagnosis code for each comorbidity;
	array DGNS_CD {12};
	CHF = 0;
	HT = 0;
	STT = 0;
	VD = 0;
	Dia = 0;
	
	do k = 1 to 12;

		if DGNS_CD{k} in ("39891","40201","40211", "40291", "40401", "40411", "40403", "40413", "40491", "40493", "I110", "I130", "I132") or 
		   substr(DGNS_CD{k},1,3) in ("428", "I50") 
		then CHF=1;

        if substr(DGNS_CD{k},1,3) in ("401","402","403", "404", "405", "I10", "I11", "I12", "I13", "I15") 
		then HT=1;

		if DGNS_CD{k} in:("433","434","435", "436", "437", "451", "453", "41511", "41512", "41519", "I63", "I649", "I74", "I26",
						 "G450", "G451" "G452", "G454", "G455", "G456", "G457", "G458", "G459") 
		then STT=1;
		/***** Another selection of diagnosis codes for STT based on Am Heart J 25497246 **************
		****** Will result in only 10% of patients having this comobidity *****************************
		if DGNS_CD{k} in:("43301","43311","43321","43331","43391", "434","435", "v1254", "I63", "I649", "I74", "I26",
						 "G450", "G451" "G452", "G454", "G455", "G456", "G457", "G458", "G459") 
		then STT=1;
		***********************************************************************************************/

		if DGNS_CD{k} in:("412","410","44020","44021","44022","44023","44024","44029","44030","44031","44032","4439","444","445","440",
							"I21","I23","I700","I702","I703","I704","I705","I706","I707","I708","I709","I71","I739") 
									  
		then VD=1;

		if DGNS_CD{k} in:("250","3620","E10","E11") or DGNS_CD{k} in ("3572","36641") 
		then Dia=1;

	end;
   
	drop k;

run;
%mend find1;

%find1 (nch_cv_09, nch09);
%find1 (nch_cv_10, nch10);
%find1 (nch_cv_11, nch11);
%find1 (nch_cv_12, nch12);
%find1 (nch_cv_13, nch13);
%find1 (nch_cv_14, nch14);
%find1 (nch_cv_15, nch15);
%find1 (nch_cv_16, nch16);


data oac_can.nch_cv;
	set oac_can.nch_cv_09-oac_can.nch_cv_16;
	keep PATIENT_ID claim_date CHF HT STT VD Dia;
run;
proc sort data=oac_can.nch_cv out=oac_can.nch_cv nodupkey;    * 4949785;
	by _all_;
run;



/* outsaf */
%macro find2 (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty DGNS_CD1-DGNS_CD25 in=in1) oac_can.All_cancer_v10 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;

	*Find out diagnosis code for each comorbidity;
	array DGNS_CD {25};
	CHF = 0;
	HT = 0;
	STT = 0;
	VD = 0;
	Dia = 0;
	

	do k = 1 to 25;
		
		if DGNS_CD{k} in ("39891","40201","40211", "40291", "40401", "40411", "40403", "40413", "40491", "40493", "I110", "I130", "I132") or 
		   substr(DGNS_CD{k},1,3) in ("428", "I50") 
		then CHF=1;


        if substr(DGNS_CD{k},1,3) in ("401","402","403", "404", "405", "I10", "I11", "I12", "I13", "I15") 
		then HT=1;

		if DGNS_CD{k} in:("433","434","435", "436", "437", "451", "453", "41511", "41512", "41519", "I63", "I649", "I74", "I26",
						 "G450", "G451" "G452", "G454", "G455", "G456", "G457", "G458", "G459") 
		then STT=1;
		/***** Another selection of diagnosis codes for STT based on Am Heart J 25497246 **************
		****** Will result in only 10% of patients having this comobidity *****************************
		if DGNS_CD{k} in:("43301","43311","43321","43331","43391", "434","435", "v1254", "I63", "I649", "I74", "I26",
						 "G450", "G451" "G452", "G454", "G455", "G456", "G457", "G458", "G459") 
		then STT=1;
		***********************************************************************************************/

		if DGNS_CD{k} in:("412","410","44020","44021","44022","44023","44024","44029","44030","44031","44032","4439","444","445","440",
							"I21","I23","I700","I702","I703","I704","I705","I706","I707","I708","I709","I71","I739") 
		then VD=1;
		
		if DGNS_CD{k} in:("250","3620","E10","E11") or DGNS_CD{k} in ("3572","36641") 
		then Dia=1;

	end;
   
	drop k;
run;
%mend find2;
%find2 (outsaf_cv_09, outsaf09);
%find2 (outsaf_cv_10, outsaf10);
%find2 (outsaf_cv_11, outsaf11);
%find2 (outsaf_cv_12, outsaf12);
%find2 (outsaf_cv_13, outsaf13);
%find2 (outsaf_cv_14, outsaf14);
%find2 (outsaf_cv_15, outsaf15);
%find2 (outsaf_cv_16, outsaf16);

data oac_can.outsaf_cv;
	set oac_can.outsaf_cv_09-oac_can.outsaf_cv_16;
	keep PATIENT_ID claim_date CHF HT STT VD Dia;
run;
proc sort data=oac_can.outsaf_cv out=oac_can.outsaf_cv nodupkey;			*  1081301;
	by _all_;
run;


/* Medpar */
%macro find3 (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID ADMSNDTM ADMSNDTD ADMSNDTY DGNSCD1-DGNSCD25 in=in1) oac_can.All_cancer_v10 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	format claim_date mmddyy10.;
	
	*Find out diagnosis code for each comorbidity;
	array DGNSCD {25};
	CHF = 0;
	HT = 0;
	STT = 0;
	VD = 0;
	Dia = 0;

	do k = 1 to 25;

		if DGNSCD{k} in ("39891","40201","40211", "40291", "40401", "40411", "40403", "40413", "40491", "40493", "I110", "I130", "I132") or 
		   substr(DGNSCD{k},1,3) in ("428", "I50") 
		then CHF=1;

        if substr(DGNSCD{k},1,3) in ("401","402","403", "404", "405", "I10", "I11", "I12", "I13", "I15") 
		then HT=1;

		if DGNSCD{k} in:("433","434","435", "436", "437", "451", "453", "41511", "41512", "41519", "I63", "I649", "I74", "I26",
						 "G450", "G451" "G452", "G454", "G455", "G456", "G457", "G458", "G459") 
		then STT=1;
		/***** Another selection of diagnosis codes for STT based on Am Heart J 25497246 **************
		****** Will result in only 10% of patients having this comobidity *****************************
		if DGNSCD{k} in:("43301","43311","43321","43331","43391", "434","435", "v1254", "I63", "I649", "I74", "I26",
						 "G450", "G451" "G452", "G454", "G455", "G456", "G457", "G458", "G459") 
		then STT=1;
		***********************************************************************************************/


		if DGNSCD{k} in:("412","410","44020","44021","44022","44023","44024","44029","44030","44031","44032","4439","444","445","440",
							"I21","I23","I700","I702","I703","I704","I705","I706","I707","I708","I709","I71","I739") 
		then VD=1;
		
		if DGNSCD{k} in:("250","3620","E10","E11") or DGNSCD{k} in ("3572","36641") 
		then Dia=1;

	end;
   
	drop k;
run;
%mend find3;
%find3 (medpar_cv_09, medpar09);
%find3 (medpar_cv_10, medpar10);
%find3 (medpar_cv_11, medpar11);
%find3 (medpar_cv_12, medpar12);
%find3 (medpar_cv_13, medpar13);
%find3 (medpar_cv_14, medpar14);
%find3 (medpar_cv_15, medpar15);
%find3 (medpar_cv_16, medpar16);

data oac_can.medpar_cv;
	set oac_can.medpar_cv_09-oac_can.medpar_cv_16;
	keep PATIENT_ID claim_date CHF HT STT VD Dia;
run;
proc sort data=oac_can.medpar_cv out=oac_can.medpar_cv nodupkey;			* 142700;
	by _all_;
run;



/* combine the three */
data oac_can.cv;
	set oac_can.medpar_cv oac_can.nch_cv oac_can.outsaf_cv;
run;
proc sort data=oac_can.cv out=oac_can.cv nodupkey;					*5557384;
	by _all_;
run;


/* filter for diagnosis one year prior the index_date */
data oac_can.cv_2;
	merge oac_can.cv(in=in1) oac_can.index_date_1year_prior(in=in2);
	by patient_id;
	if in1 and in2;
	
   if claim_date > index_date or claim_date < oneyo then
      do;
        CHF = 0;
		HT = 0;
		STT = 0;
		VD = 0;
		Dia = 0;
      end;
run;

/* summarize table */
proc sql;				*27784;

	create table oac_can.cv_summarized as				
	select patient_id, max(CHF) as CHF, max(HT) as HT, max(STT) as STT, max(VD) as VD, max(Dia) as Dia
	from oac_can.cv_2
	group by patient_id
	;

quit;

data oac_can.cv_final;
	merge oac_can.cv_summarized oac_can.All_cancer_v10;
	by patient_id;
	keep PATIENT_ID CHF HT STT VD Dia age m_sex;
run;

data oac_can.cv_score;
	set oac_can.cv_final;
	cv_score=0;
	if age <65 then cv_score = 0;
	if age>=65 and age<=74 then cv_score = 1;
	if age >=75 then cv_score = 2;
	if m_sex="2" then cv_score = cv_score+1;
	if CHF = "1" then cv_score = cv_score+1;
	if HT = "1" then cv_score = cv_score+1;
	if STT = "1" then cv_score = cv_score+2;
	if VD = "1" then cv_score = cv_score+1;
	if Dia = "1" then cv_score = cv_score+1;
run;


PROC FREQ DATA=oac_can.cv_score;
    TABLES cv_score;
RUN;


* Delete datasets no long need;
/*proc datasets lib=oac_can nolist;*/
/*delete nch_cv_09-nch_cv_16 outsaf_cv_09-outsaf_cv_16 medpar_cv_09-medpar_cv_16 medpar_cv nch_cv outsaf_cv cv cv_2 cv_summarized cv_final;*/
/*run;*/


/* Final step - merge to cohort */
data oac_can.cohort_v06;
	merge oac_can.cohort_v05 oac_can.cv_score(keep=patient_id cv_score CHF HT STT VD Dia);
	by patient_id;
run;
