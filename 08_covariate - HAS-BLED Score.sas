/****************************************************************************
| Program name : 10_covariate - HAS-BLED Score
| Date (update):
| Project name :
| Purpose      : Create covariate - HAS-BLED Score
|
|
****************************************************************************/


/* Find out cohort in NCH/OUTPAT/MEDPAR & assign flag for each comorbidity*/
/* NCH */
%macro hb1 (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty hcpcs_cd DGNS_CD1-DGNS_CD12 in=in1) oac_can.All_cancer_v10 (keep=patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;
	
	HT = 0; *hypertension;
	AKF = 0; *altered kidney function;
	ALF = 0; *altered liver function;
	Stroke = 0; *Stroke history;
	bleed = 0; *bleeding;
	alcohol = 0; *alcohol use;
	

	if hcpcs_cd in ("90935","90936","90937","90938","90939","90940","90941","90942","90943","90944","90945","90946","90947","90948","90949",
					"90950","90951","90952","90953","90954","90955","90956","90957","90958","90959","90960","90961","90962","90963","90964",
					"90965","90966","90967","90968","90969","90970","90971","90972","90973","90974","90975","90976","90977","90978","90979",
					"90980","90981","90982","90983","90984","90985","90986","90987","90988","90989","90990","90991","90992","90993","99512",
					"99559") then AKF=1;

	if hcpcs_cd = "43255" then bleed = 1;

	*Find out diagnosis code for each comorbidity;
	array DGNS_CD {12};

	do k = 1 to 12;

        if substr(DGNS_CD{k},1,3) in ("401","402","403", "404", "405", "I10", "I11", "I12", "I13", "I15") 
		then HT=1;

		if DGNS_CD{k} in: ("580","581","582", "583", "584", "585", "586", "587", "N02", "N03", "N04", "N05", "N06", "N07", "N08", "N11", "N12", 
						   "N14", "N18", "N19", "N26", "N158", "N159", "N160", "N162", "N163", "N164", "N168", "Q612", "Q613", "Q615", "Q619", "E102", "E112", 
						   "E132", "E142", "I120", "M300", "M313", "M319", "M321B") 
		then AKF=1;

		if DGNS_CD{k} in:("070","571","572","573","5768","4560","4561","4562","1550","1551", "1552", "B15", "B16", "B17", "B18", "B19", "C22", "K70", "K71", "K72", 
						  "K73", "K74", "K75", "K76", "K77", "Z944", "I982", "D684C", "Q618A") 
		then ALF=1;


		if DGNS_CD{k} in:("433","434","435","436","437","I63","I64","I74","G458","G459") 
		then Stroke=1;

		if DGNS_CD{k} in:("430","431","432","5310","5312", "5314", "5316", "5320", "5322", "5324", "5326", "5330", "5332", "5334", "5336", "5340", "5342", "5344", "5346", 
						  "5780", "4552", "4555", "4558", "56202", "56203", "56212", "56213", "56881", "5693", "56983", "56985", "56986", "5781", "5789", "5997",  
						  "7191", "4230", "7863", "7847", "4590", "2850", "2851", "2859", "K250", "K252", "K254", "K260", "K262", "K264", "K270", "K272", "K274", "K280", 
						  "K282", "K290", "K920", "K921", "K922", "D62", "J942", "H113", "H356", "H431", "N02", "R04", "R31", "R58")
		then bleed=1;


		if DGNS_CD{k} in:("291","3030","3039","3050","3575","4255","5711","5712","5713","F10", "K70", "E52", "T51", "K860", "E244", "G312", "I426", "O354", 
						  "Z714", "Z721", "G621", "G721", "K292", "L278A") 
		then alcohol=1;


	end;
   
	drop k;

run;
%mend hb1;

%hb1 (nch_hb_09, nch09);
%hb1 (nch_hb_10, nch10);
%hb1 (nch_hb_11, nch11);
%hb1 (nch_hb_12, nch12);
%hb1 (nch_hb_13, nch13);
%hb1 (nch_hb_14, nch14);
%hb1 (nch_hb_15, nch15);
%hb1 (nch_hb_16, nch16);


data oac_can.nch_hb;
	set oac_can.nch_hb_09-oac_can.nch_hb_16;
	keep PATIENT_ID claim_date HT AKF ALF Stroke bleed alcohol;
run;
proc sort data=oac_can.nch_hb out=oac_can.nch_hb nodupkey;    *   4949310;
	by _all_;
run;



/* OUTSAF */
%macro hb2 (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty hcpcs_cd DGNS_CD1-DGNS_CD25 in=in1) oac_can.All_cancer_v10 (keep=patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;
	
	HT = 0; *hypertension;
	AKF = 0; *altered kidney function;
	ALF = 0; *altered liver function;
	Stroke = 0; *Stroke history;
	bleed = 0; *bleeding;
	alcohol = 0; *alcohol use;



	if hcpcs_cd in ("90935","90936","90937","90938","90939","90940","90941","90942","90943","90944","90945","90946","90947","90948","90949",
					"90950","90951","90952","90953","90954","90955","90956","90957","90958","90959","90960","90961","90962","90963","90964",
					"90965","90966","90967","90968","90969","90970","90971","90972","90973","90974","90975","90976","90977","90978","90979",
					"90980","90981","90982","90983","90984","90985","90986","90987","90988","90989","90990","90991","90992","90993","99512",
					"99559") then AKF=1;

	if hcpcs_cd = "43255" then bleed = 1;

	*Find out diagnosis code for each comorbidity;
	array DGNS_CD {25};

	do k = 1 to 25;

        if substr(DGNS_CD{k},1,3) in ("401","402","403", "404", "405", "I10", "I11", "I12", "I13", "I15") 
		then HT=1;

		if DGNS_CD{k} in: ("580","581","582", "583", "584", "585", "586", "587", "N02", "N03", "N04", "N05", "N06", "N07", "N08", "N11", "N12", 
						   "N14", "N18", "N19", "N26", "N158", "N159", "N160", "N162", "N163", "N164", "N168", "Q612", "Q613", "Q615", "Q619", "E102", "E112", 
						   "E132", "E142", "I120", "M300", "M313", "M319", "M321B")  
		then AKF=1;

		if DGNS_CD{k} in:("070","571","572","573","5768","4560","4561","4562","1550","1551", "1552", "B15", "B16", "B17", "B18", "B19", "C22", "K70", "K71", "K72", 
						  "K73", "K74", "K75", "K76", "K77", "Z944", "I982", "D684C", "Q618A") 
		then ALF=1;

		if DGNS_CD{k} in:("433","434","435","436","437","I63","I64","I74","G458","G459") 
		then Stroke=1;

		if DGNS_CD{k} in:("430","431","432","5310","5312", "5314", "5316", "5320", "5322", "5324", "5326", "5330", "5332", "5334", "5336", "5340", "5342", "5344", "5346", 
						  "5780", "4552", "4555", "4558", "56202", "56203", "56212", "56213", "56881", "5693", "56983", "56985", "56986", "5781", "5789", "5997",  
						  "7191", "4230", "7863", "7847", "4590", "2850", "2851", "2859", "K250", "K252", "K254", "K260", "K262", "K264", "K270", "K272", "K274", "K280", 
						  "K282", "K290", "K920", "K921", "K922", "D62", "J942", "H113", "H356", "H431", "N02", "R04", "R31", "R58")
		then bleed=1;

		if DGNS_CD{k} in:("291","3030","3039","3050","3575","4255","5711","5712","5713","F10", "K70", "E52", "T51", "K860", "E244", "G312", "I426", "O354", 
						  "Z714", "Z721", "G621", "G721", "K292", "L278A") 
		then alcohol=1;
	end;
   
	drop k;

run;
%mend hb2;

%hb2 (outsaf_hb_09, outsaf09);
%hb2 (outsaf_hb_10, outsaf10);
%hb2 (outsaf_hb_11, outsaf11);
%hb2 (outsaf_hb_12, outsaf12);
%hb2 (outsaf_hb_13, outsaf13);
%hb2 (outsaf_hb_14, outsaf14);
%hb2 (outsaf_hb_15, outsaf15);
%hb2 (outsaf_hb_16, outsaf16);

data oac_can.outsaf_hb;
	set oac_can.outsaf_hb_09-oac_can.outsaf_hb_16;
	keep PATIENT_ID claim_date HT AKF ALF Stroke bleed alcohol;
run;
proc sort data=oac_can.outsaf_hb out=oac_can.outsaf_hb nodupkey;			*  1081380;
	by _all_;
run;




/* Medpar */
%macro hb3 (out_file, in_file);
data oac_can.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID ADMSNDTM ADMSNDTD ADMSNDTY DGNSCD1-DGNSCD25 PRCDRCD1-PRCDRCD25 in=in1) oac_can.All_cancer_v10 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	format claim_date mmddyy10.;
	
	*Find out diagnosis code for each comorbidity;
	array DGNSCD {25};
	array PRCDRCD {25};
	HT = 0; *hypertension;
	AKF = 0; *altered kidney function;
	ALF = 0; *altered liver function;
	Stroke = 0; *Stroke history;
	bleed = 0; *bleeding;
	alcohol = 0; *alcohol use;
	

	do k = 1 to 25;

        if substr(DGNSCD{k},1,3) in ("401","402","403", "404", "405", "I10", "I11", "I12", "I13", "I15") 
		then HT=1;

		if DGNSCD{k} in: ("580","581","582", "583", "584", "585", "586", "587", "N02", "N03", "N04", "N05", "N06", "N07", "N08", "N11", "N12", 
						   "N14", "N18", "N19", "N26", "N158", "N159", "N160", "N162", "N163", "N164", "N168", "Q612", "Q613", "Q615", "Q619", "E102", "E112", 
						   "E132", "E142", "I120", "M300", "M313", "M319", "M321B")  or PRCDRCD{k} in ("3995", "5498", "V560", "V568")
		then AKF=1;

		if DGNSCD{k} in:("070","571","572","573","5768","4560","4561","4562","1550","1551", "1552", "B15", "B16", "B17", "B18", "B19", "C22", "K70", "K71", "K72", 
						  "K73", "K74", "K75", "K76", "K77", "Z944", "I982", "D684C", "Q618A")  or PRCDRCD{k} in: ("391", "4291")
		then ALF=1;

		if DGNSCD{k} in:("433","434","435","436","437","I63","I64","I74","G458","G459") 
		then Stroke=1;

		if DGNSCD{k} in:("430","431","432","5310","5312", "5314", "5316", "5320", "5322", "5324", "5326", "5330", "5332", "5334", "5336", "5340", "5342", "5344", "5346", 
						  "5780", "4552", "4555", "4558", "56202", "56203", "56212", "56213", "56881", "5693", "56983", "56985", "56986", "5781", "5789", "5997",  
						  "7191", "4230", "7863", "7847", "4590", "2850", "2851", "2859", "K250", "K252", "K254", "K260", "K262", "K264", "K270", "K272", "K274", "K280", 
						  "K282", "K290", "K920", "K921", "K922", "D62", "J942", "H113", "H356", "H431", "N02", "R04", "R31", "R58") or PRCDRCD{k} in ("4443")
		then bleed=1;
		
		if DGNSCD{k} in:("291","3030","3039","3050","3575","4255","5711","5712","5713","F10", "K70", "E52", "T51", "K860", "E244", "G312", "I426", "O354", 
						  "Z714", "Z721", "G621", "G721", "K292", "L278A") or PRCDRCD{k} in ("9461", "9462", "9463", "9467", "9468", "9469")
		then alcohol=1;
	end;
run;
%mend hb3;
%hb3 (medpar_hb_09, medpar09);
%hb3 (medpar_hb_10, medpar10);
%hb3 (medpar_hb_11, medpar11);
%hb3 (medpar_hb_12, medpar12);
%hb3 (medpar_hb_13, medpar13);
%hb3 (medpar_hb_14, medpar14);
%hb3 (medpar_hb_15, medpar15);
%hb3 (medpar_hb_16, medpar16);

data oac_can.medpar_hb;
	set oac_can.medpar_hb_09-oac_can.medpar_hb_16;
	keep PATIENT_ID claim_date HT AKF ALF Stroke bleed alcohol;
run;
proc sort data=oac_can.medpar_hb out=oac_can.medpar_hb nodupkey;			* 142699;
	by _all_;
run;

/* Drugs for bleeding 
Aspirin, clopidogrel, prasugrel, ticagrelor
NSAIDs (bromfenac, celecoxib, diclofenac, diflunisal, etodolac, fenoprofen, flurbiprofen, ibuprofen, indomethacin, 
ketoprofen, ketorolac, meclofenamate, mefenamic acid, meloxicam, nabumetone, naproxen, oxaprozin, phenylbutazone, piroxicam, sulindac, tolmetin)
*/


%macro bleed (out_file, in_file);
data oac_can.&out_file;
 	merge oac_can.&in_file(keep = PATIENT_ID srvc_mon srvc_day srvc_yr gnn bn in=in1) oac_can.All_cancer_v10 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;

	if lowcase(GNN) in ('aspirin', 'clopidogrel', 'prasugrel', 'ticagrelor', 'bromfenac', 'celecoxib', 'diclofenac', 'diflunisal', 
						'etodolac', 'fenoprofen', 'flurbiprofen', 'ibuprofen', 'indomethacin', 'ketoprofen', 'ketorolac', 'meclofenamate',
 						'mefenamic acid', 'meloxicam', 'nabumetone', 'naproxen', 'oxaprozin', 'phenylbutazone', 'piroxicam', 'sulindac', 'tolmetin') or
	   lowcase(BN) in  ('aspirin', 'clopidogrel', 'prasugrel', 'ticagrelor', 'bromfenac', 'celecoxib', 'diclofenac', 'diflunisal', 
						'etodolac', 'fenoprofen', 'flurbiprofen', 'ibuprofen', 'indomethacin', 'ketoprofen', 'ketorolac', 'meclofenamate',
 						'mefenamic acid', 'meloxicam', 'nabumetone', 'naproxen', 'oxaprozin', 'phenylbutazone', 'piroxicam', 'sulindac', 'tolmetin');

	srvc_date=mdy(srvc_mon,srvc_day,srvc_yr);
	format srvc_date mmddyy10.;

run;
%mend bleed;

%bleed (pdesaf_bleed_09, pdesaf09);
%bleed (pdesaf_bleed_10, pdesaf10);
%bleed (pdesaf_bleed_11, pdesaf11);
%bleed (pdesaf_bleed_12, pdesaf12);
%bleed (pdesaf_bleed_13, pdesaf13);
%bleed (pdesaf_bleed_14, pdesaf14);
%bleed (pdesaf_bleed_15, pdesaf15);
%bleed (pdesaf_bleed_16, pdesaf16);

data oac_can.pdesaf_bleed;
	set oac_can.pdesaf_bleed_09-oac_can.pdesaf_bleed_16;

	HT = 0;
	AKF = 0;
	ALF = 0; 
	Stroke = 0; 
	bleed = 1;
	alcohol = 0;

	keep patient_id srvc_date HT AKF ALF Stroke bleed alcohol;
	rename srvc_date = claim_date;
run;

proc sort data=oac_can.pdesaf_bleed out=oac_can.pdesaf_bleed nodupkey;			*144071;
	by _all_;
run;


/* combine the four */
data oac_can.hb;
	set oac_can.medpar_hb oac_can.nch_hb oac_can.outsaf_hb oac_can.pdesaf_bleed;
run;
proc sort data=oac_can.hb out=oac_can.hb nodupkey;					*  5692018;
	by _all_;
run;

/* filter for diagnosis one year prior the index_date */
data oac_can.hb_2;			
	merge oac_can.hb(in=in1) oac_can.index_date_1year_prior(in=in2);
	by patient_id;
	if in1 and in2;
	if claim_date > index_date or claim_date < oneyo then
      do;
        HT = 0; 
		AKF = 0; 
		ALF = 0; 
		Stroke = 0;
		bleed = 0; 
		alcohol = 0;

      end;
run;


/* summarize table */
proc sql;				*27784;

	create table oac_can.hb_summarized as				
	select patient_id, max(HT) as HT, max(AKF) as AKF, max(ALF) as ALF, max(Stroke) as Stroke, max(bleed) as bleed, max(alcohol) as alcohol
	from oac_can.hb_2
	group by patient_id
	;

quit;

data oac_can.hb_final;
	merge oac_can.hb_summarized oac_can.All_cancer_v10;
	by patient_id;
	keep PATIENT_ID age HT AKF ALF Stroke bleed alcohol;
run;

data oac_can.hb_score;
	set oac_can.hb_final;
	hb_score=0;
	if age>=65 then hb_score = 1;
	if HT = "1" then hb_score = hb_score+1;
	if AKF="1" then hb_score = hb_score+1;
	if ALF = "1" then hb_score = hb_score+1;
	if Stroke = "1" then hb_score = hb_score+2;
	if bleed = "1" then hb_score = hb_score+1;
	if alcohol = "1" then hb_score = hb_score+1;
run;


PROC FREQ DATA=oac_can.hb_score;
    TABLES hb_score;
RUN;


* Delete datasets no long need;
/*proc datasets lib=oac_can nolist;*/
/*delete nch_hb_09-nch_hb_16 outsaf_hb_09-outsaf_hb_16 medpar_hb_09-medpar_hb_16 medpar_hb nch_hb outsaf_hb hb hb_2 hb_summarized hb_final*/
/*		pdesaf_bleed_09-pdesaf_bleed_16 pdesaf_bleed;*/
/*run;*/


/* Final step - merge to cohort */
data oac_can.cohort_v07;
	merge oac_can.cohort_v06(in=in1) oac_can.hb_score(keep=patient_id hb_score AKF ALF bleed alcohol);
	by patient_id;
	if in1;
run;
