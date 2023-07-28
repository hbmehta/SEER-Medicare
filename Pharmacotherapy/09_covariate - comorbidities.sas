/****************************************************************************
| Program name : 14_covariate - comorbidities
| Date (update):
| Project name :
| Purpose      : Create covariate - comorbidities
|
|
****************************************************************************/

 
/* Find out cohort in NCH/OUTPAT/MEDPAR & assign flag for each comorbidity*/
/* NCH */
%macro com1 (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty DGNS_CD1-DGNS_CD12 hcpcs_cd in=in1) oac_can.All_cancer_v10 (keep=patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;

	*Find out diagnosis code for each comorbidity;
	anemia = 0;
	asthma = 0;
	COPD = 0;
	dementia = 0;
	gout = 0;
	HL = 0; *Hyperlipidemia;
	IA = 0; *Inflammatory arthritis;
	Other_IHD = 0; *Other ischemic heart disease;
	Other_CD = 0; *Other cerebrovascular disease;
	PUD = 0; *Peptic ulcer disease;
	CR = 0; * Coronary revascularization;

	if hcpcs_cd in ("33510","33511","33512","33513","33514","33516","33517","33518","33519","33521","33522","33523","33533","33534","33535","33536",
					"92920","92921","92924","92925","92928","92929","92933","92934","92937","92938","92941","92943","92944",
					"C9600","C9601","C9602","C9603","C9604","C9605","C9606","C9607","C9608") then CR=1;

	array DGNS_CD {12};
	do k = 1 to 12;

		if DGNS_CD{k} in: ("280","280","281","282","283","284","285","D50","D51","D52","D53","D55","D56","D5700","D5701","D5702","D571","D5720","D57211","D57212","D57219", 
						   "D573","D5740","D57411","D57412","D57419","D5780","D57811","D57812","D57819","D58","D59","D60","D61","D62","D63","D64") 
		then anemia=1;

		if DGNS_CD{k} in: ("493","J45") 
		then asthma=1;
		
		if DGNS_CD{k} in: ("490","491","494","496","J40","J41","J42","J43","J44","J47") 
		then COPD=1;

		if DGNS_CD{k} in: ('290','2910','2911','2912','29282','2941','3310','3311','3312','33182','F00','F01','F02','F03','G30','F051','G311') 
		then dementia=1;
		
		if DGNS_CD{k} in: ("2740","2741","2748","2749","M10","M1A") 
		then gout=1;
	
		if DGNS_CD{k} in: ("2720","2721","2722","2723","2724","E780","E781","E782","E783","E784","E785") 
		then HL=1;

		if DGNS_CD{k} in: ("7140","7141","7142","7145","7146","7147","7148","7149","M05","M06") 
		then IA=1;

		if DGNS_CD{k} in: ("4111","4118","413","414","I20","I22","I24","I25") 
		then Other_IHD=1;

		if DGNS_CD{k} in: ("430","431","432","I60","I61","I62","I65","I66","I67") 
		then Other_CD=1;

		if DGNS_CD{k} in: ("531","532","533","534","K25","K26","K27","K28") 
		then PUD=1;

	end;
   
	drop k;

run;
%mend com1;

%com1 (nch_com_09, nch09);
%com1 (nch_com_10, nch10);
%com1 (nch_com_11, nch11);
%com1 (nch_com_12, nch12);
%com1 (nch_com_13, nch13);
%com1 (nch_com_14, nch14);
%com1 (nch_com_15, nch15);
%com1 (nch_com_16, nch16);


data oac_can.nch_com;
	set oac_can.nch_com_09-oac_can.nch_com_16;
	keep PATIENT_ID claim_date anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR;
run;
proc sort data=oac_can.nch_com out=oac_can.nch_com nodupkey;    * 1548476;
	by _all_;
run;



/* outsaf */
%macro com2 (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty DGNS_CD1-DGNS_CD25 hcpcs_cd in=in1) oac_can.All_cancer_v10 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;

	*Find out diagnosis code for each comorbidity;
	anemia = 0;
	asthma = 0;
	COPD = 0;
	dementia = 0;
	gout = 0;
	HL = 0; *Hyperlipidemia;
	IA = 0; *Inflammatory arthritis;
	Other_IHD = 0; *Other ischemic heart disease;
	Other_CD = 0; *Other cerebrovascular disease;
	PUD = 0; *Peptic ulcer disease;
	CR = 0;

	if hcpcs_cd in ("33510","33511","33512","33513","33514","33516","33517","33518","33519","33521","33522","33523","33533","33534","33535","33536",
					"92920","92921","92924","92925","92928","92929","92933","92934","92937","92938","92941","92943","92944",
					"C9600","C9601","C9602","C9603","C9604","C9605","C9606","C9607","C9608") then CR=1;

	array DGNS_CD {25};
	do k = 1 to 25;
		
		if DGNS_CD{k} in: ("280","280","281","282","283","284","285","D50","D51","D52","D53","D55","D56","D5700","D5701","D5702","D571","D5720","D57211","D57212","D57219", 
						   "D573","D5740","D57411","D57412","D57419","D5780","D57811","D57812","D57819","D58","D59","D60","D61","D62","D63","D64") 
		then anemia=1;

		if DGNS_CD{k} in: ("493","J45") 
		then asthma=1;
		
		if DGNS_CD{k} in: ("490","491","494","496","J40","J41","J42","J43","J44","J47") 
		then COPD=1;

		if DGNS_CD{k} in: ('290','2910','2911','2912','29282','2941','3310','3311','3312','33182','F00','F01','F02','F03','G30','F051','G311') 
		then dementia=1;
		
		if DGNS_CD{k} in: ("2740","2741","2748","2749","M10","M1A") 
		then gout=1;
	
		if DGNS_CD{k} in: ("2720","2721","2722","2723","2724","E780","E781","E782","E783","E784","E785") 
		then HL=1;

		if DGNS_CD{k} in: ("7140","7141","7142","7145","7146","7147","7148","7149","M05","M06") 
		then IA=1;

		if DGNS_CD{k} in: ("4111","4118","413","414","I20","I22","I24","I25") 
		then Other_IHD=1;

		if DGNS_CD{k} in: ("430","431","432","I60","I61","I62","I65","I66","I67") 
		then Other_CD=1;

		if DGNS_CD{k} in: ("531","532","533","534","K25","K26","K27","K28") 
		then PUD=1;

	end;
   
	drop k;
run;
%mend com2;
%com2 (outsaf_com_09, outsaf09);
%com2 (outsaf_com_10, outsaf10);
%com2 (outsaf_com_11, outsaf11);
%com2 (outsaf_com_12, outsaf12);
%com2 (outsaf_com_13, outsaf13);
%com2 (outsaf_com_14, outsaf14);
%com2 (outsaf_com_15, outsaf15);
%com2 (outsaf_com_16, outsaf16);

data oac_can.outsaf_com;
	set oac_can.outsaf_com_09-oac_can.outsaf_com_16;
	keep PATIENT_ID claim_date anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR;
run;
proc sort data=oac_can.outsaf_com out=oac_can.outsaf_com nodupkey;			*  359387;
	by _all_;
run;


/* Medpar */
%macro com3 (out_file, in_file);
data comp_eff.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID ADMSNDTM ADMSNDTD ADMSNDTY DGNSCD1-DGNSCD25 PRCDRCD1-PRCDRCD25 in=in1) oac_can.All_cancer_v10 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	format claim_date mmddyy10.;
	
	*Find out diagnosis code for each comorbidity;
	anemia = 0;
	asthma = 0;
	COPD = 0;
	dementia = 0;
	gout = 0;
	HL = 0; *Hyperlipidemia;
	IA = 0; *Inflammatory arthritis;
	Other_IHD = 0; *Other ischemic heart disease;
	Other_CD = 0; *Other cerebrovascular disease;
	PUD = 0; *Peptic ulcer disease;
	CR = 0;

	array DGNSCD {25};
	array PRCDRCD {25};

	do k = 1 to 25;

		if DGNSCD{k} in: ("280","280","281","282","283","284","285","D50","D51","D52","D53","D55","D56","D5700","D5701","D5702","D571","D5720","D57211","D57212","D57219", 
						   "D573","D5740","D57411","D57412","D57419","D5780","D57811","D57812","D57819","D58","D59","D60","D61","D62","D63","D64") 
		then anemia=1;

		if DGNSCD{k} in: ("493","J45") 
		then asthma=1;
		
		if DGNSCD{k} in: ("490","491","494","496","J40","J41","J42","J43","J44","J47") 
		then COPD=1;

		if DGNSCD{k} in: ('290','2910','2911','2912','29282','2941','3310','3311','3312','33182','F00','F01','F02','F03','G30','F051','G311') 
		then dementia=1;
		
		if DGNSCD{k} in: ("2740","2741","2748","2749","M10","M1A") 
		then gout=1;
	
		if DGNSCD{k} in: ("2720","2721","2722","2723","2724","E780","E781","E782","E783","E784","E785") 
		then HL=1;

		if DGNSCD{k} in: ("7140","7141","7142","7145","7146","7147","7148","7149","M05","M06") 
		then IA=1;

		if DGNSCD{k} in: ("4111","4118","413","414","I20","I22","I24","I25") 
		then Other_IHD=1;

		if DGNSCD{k} in: ("430","431","432","I60","I61","I62","I65","I66","I67") 
		then Other_CD=1;

		if DGNSCD{k} in: ("531","532","533","534","K25","K26","K27","K28") 
		then PUD=1;

		if PRCDRCD{k} in: ("3610","3611","3612","3613","3614","3615","3616","3617","3619","3609","0066","3606","3607",
							"0210","0211","0212","0213","0270","0271","0272","0273","02C0","02C1","02C2","02C3") 
		then CR=1;

	end;
   
	drop k;
run;
%mend com3;
%com3 (medpar_com_09, medpar09);
%com3 (medpar_com_10, medpar10);
%com3 (medpar_com_11, medpar11);
%com3 (medpar_com_12, medpar12);
%com3 (medpar_com_13, medpar13);
%com3 (medpar_com_14, medpar14);
%com3 (medpar_com_15, medpar15);
%com3 (medpar_com_16, medpar16);

data oac_can.medpar_com;
	set oac_can.medpar_com_09-oac_can.medpar_com_16;
	keep PATIENT_ID claim_date anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR;
run;
proc sort data=oac_can.medpar_com out=oac_can.medpar_com nodupkey;			* 38779;
	by _all_;
run;



/* combine the three */
data oac_can.com;
	set oac_can.medpar_com oac_can.nch_com oac_can.outsaf_com;
run;
proc sort data=oac_can.com out=oac_can.com nodupkey;					* 1748455;
	by _all_;
run;


/* filter for diagnosis one year prior the index_date */
data oac_can.com_2;
	merge oac_can.com(in=in1) oac_can.index_date_1year_prior(keep=patient_id index_date oneyo in=in2);
	by patient_id;
	if in1 and in2;
	
   if claim_date > index_date or claim_date < oneyo then
      do;
        anemia = 0;
		asthma = 0;
		COPD = 0;
		dementia = 0;
		gout = 0;
		HL = 0; 
		IA = 0; 
		Other_IHD = 0; 
		Other_CD = 0; 
		PUD = 0; 
		CR = 0;
      end;
run;

/* summarize table */
proc sql;				*;

	create table oac_can.com_summarized as				
	select patient_id, max(anemia) as anemia, max(asthma) as asthma, max(COPD) as COPD, max(dementia) as dementia, max(gout) as gout, max(HL) as HL, max(IA) as IA,
			max(Other_IHD) as Other_IHD, max(Other_CD) as Other_CD, max(PUD) as PUD, max(CR) as CR
	from oac_can.com_2
	group by patient_id
	;

quit;

data oac_can.com_final;
	merge oac_can.com_summarized oac_can.All_cancer_v10;
	by patient_id;
	keep PATIENT_ID anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR;
run;



PROC FREQ DATA=oac_can.com_final;
    TABLES anemia asthma COPD dementia gout HL IA Other_IHD Other_CD PUD CR;
RUN;


* Delete datasets no long need;
proc datasets lib=oac_can nolist;
delete nch_com_09-nch_com_16 outsaf_com_09-outsaf_com_16 medpar_com_09-medpar_com_16 medpar_com nch_com outsaf_com com com_2 com_summarized;
run;


/* Final step - merge to cohort */
data oac_can.cohort_v08;
	merge oac_can.cohort_v07 oac_can.com_final;
	by patient_id;
run;
