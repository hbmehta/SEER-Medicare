/****************************************************************************
| Program name : 14_covariate - frailty
| Date (update):
| Project name :
| Purpose      : Create covariate - frailty
|
|
****************************************************************************/

 

/* Find out cohort in NCH/OUTPAT/MEDPAR & assign flag for each frailty*/
/* NCH */
%macro fra1 (out_file, in_file);
data comp_eff.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty DGNS_CD1-DGNS_CD12 hcpcs_cd in=in1) comp_eff.covariate_11 (keep=patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;

	*Find out diagnosis code for each frailty: ;
	Home_O2 = 0; 			*Home oxygen use;
	Osteoporotic_frac = 0;  *Osteoporotic fracture;
	Walker = 0; 			*Walker use;
	Wheelchair = 0; 		*Wheelchair use;
	Home_hosp_bed = 0; 		*home hospital bed; 
	fall = 0;				*Recent fall;

	if hcpcs_cd in ("E1390","E1391","E1392","E0431","E0433","E0434","E0435","E0439","E0441","E0442","E0443") then Home_O2=1;
	if hcpcs_cd in ("E0130","E0135","E0140","E0141","E0143","E0144","E0147","E0148","E0149","E0154","E0155","E0156","E0157","E0158") then Walker=1;
	if hcpcs_cd in ("E1050","E1060","E1070","E1083","E1084","E1085","E1086","E1087","E1088","E1089","E1090","E1091","E1092","E1093","E1100","E1110",
					"E1120","E1140","E1150","E1160","E1161","E1170","K0001","K0002","K0003","K0004","K0005","K0006","K0007","K0008","K0009") then Wheelchair=1;
	if hcpcs_cd in ("E0250","E0251","E0255","E0256","E0260","E0261","E0265","E0266","E0270","E0290","E0291",
					"E0292","E0293","E0294","E0295","E0296","E0297","E0301","E0302","E0303","E0304","E0316") then Home_hosp_bed=1;

	array DGNS_CD {12};
	do k = 1 to 12;

		if DGNS_CD{k} in: ("73300","73313","M8008XA","M8008XD","M8008XG","M8008XK","M8008XP","M8008XS","M8088XA","M8088XD","M8088XG","M8088XK","M8088XP","M8088XS") 
		then Osteoporotic_frac=1;

		if DGNS_CD{k} in: ("E880","E881","E882","E883","E884","E885","E886","E888","E9681","E987","W00","W01","W02","W03","W04","W05","W06","W07","W08","W09","W10",
							"W11","W12","W13","W14","W15","W160","W161","W162","W163","W164","W17","W180","W181","W182","W183","W19") 
		then fall=1;
		

	end;
   
	drop k;

run;
%mend fra1;

%fra1 (nch_fra_09, nch09);
%fra1 (nch_fra_10, nch10);
%fra1 (nch_fra_11, nch11);
%fra1 (nch_fra_12, nch12);
%fra1 (nch_fra_13, nch13);
%fra1 (nch_fra_14, nch14);
%fra1 (nch_fra_15, nch15);
%fra1 (nch_fra_16, nch16);


data comp_eff.nch_fra;
	set comp_eff.nch_fra_09-comp_eff.nch_fra_16;
	keep PATIENT_ID claim_date Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall;
run;
proc sort data=comp_eff.nch_fra out=comp_eff.nch_fra nodupkey;    * ;
	by _all_;
run;


/* outsaf */
%macro fra2 (out_file, in_file);
data comp_eff.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty DGNS_CD1-DGNS_CD25 hcpcs_cd in=in1) comp_eff.covariate_11 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(from_dtm,from_dtd,from_dty);
	format claim_date mmddyy10.;

	*Find out diagnosis code for each frailty: ;
	Home_O2 = 0; 			*Home oxygen use;
	Osteoporotic_frac = 0;  *Osteoporotic fracture;
	Walker = 0; 			*Walker use;
	Wheelchair = 0; 		*Wheelchair use;
	Home_hosp_bed = 0; 		*home hospital bed; 
	fall = 0;				*Recent fall;

	if hcpcs_cd in ("E1390","E1391","E1392","E0431","E0433","E0434","E0435","E0439","E0441","E0442","E0443") then Home_O2=1;
	if hcpcs_cd in ("E0130","E0135","E0140","E0141","E0143","E0144","E0147","E0148","E0149","E0154","E0155","E0156","E0157","E0158") then Walker=1;
	if hcpcs_cd in ("E1050","E1060","E1070","E1083","E1084","E1085","E1086","E1087","E1088","E1089","E1090","E1091","E1092","E1093","E1100","E1110",
					"E1120","E1140","E1150","E1160","E1161","E1170","K0001","K0002","K0003","K0004","K0005","K0006","K0007","K0008","K0009") then Wheelchair=1;
	if hcpcs_cd in ("E0250","E0251","E0255","E0256","E0260","E0261","E0265","E0266","E0270","E0290","E0291",
					"E0292","E0293","E0294","E0295","E0296","E0297","E0301","E0302","E0303","E0304","E0316") then Home_hosp_bed=1;

	array DGNS_CD {25};
	do k = 1 to 25;

		if DGNS_CD{k} in: ("73300","73313","M8008XA","M8008XD","M8008XG","M8008XK","M8008XP","M8008XS","M8088XA","M8088XD","M8088XG","M8088XK","M8088XP","M8088XS") 
		then Osteoporotic_frac=1;

		if DGNS_CD{k} in: ("E880","E881","E882","E883","E884","E885","E886","E888","E9681","E987","W00","W01","W02","W03","W04","W05","W06","W07","W08","W09","W10",
							"W11","W12","W13","W14","W15","W160","W161","W162","W163","W164","W17","W180","W181","W182","W183","W19") 
		then fall=1;
		

	end;
   
	drop k;
run;
%mend fra2;
%fra2 (outsaf_fra_09, outsaf09);
%fra2 (outsaf_fra_10, outsaf10);
%fra2 (outsaf_fra_11, outsaf11);
%fra2 (outsaf_fra_12, outsaf12);
%fra2 (outsaf_fra_13, outsaf13);
%fra2 (outsaf_fra_14, outsaf14);
%fra2 (outsaf_fra_15, outsaf15);
%fra2 (outsaf_fra_16, outsaf16);

data comp_eff.outsaf_fra;
	set comp_eff.outsaf_fra_09-comp_eff.outsaf_fra_16;
	keep PATIENT_ID claim_date Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall;
run;
proc sort data=comp_eff.outsaf_fra out=comp_eff.outsaf_fra nodupkey;			*  359387;
	by _all_;
run;


/* Medpar */
%macro fra3 (out_file, in_file);
data comp_eff.&out_file;
 	merge seermed.&in_file(keep=PATIENT_ID ADMSNDTM ADMSNDTD ADMSNDTY DGNSCD1-DGNSCD25 in=in1) comp_eff.covariate_10 (keep = patient_id in=in2);
	by patient_id;
	if in1 and in2;

	claim_date = mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	format claim_date mmddyy10.;
	
	*Find out diagnosis code for each frailty: ;
	Home_O2 = 0; 			*Home oxygen use;
	Osteoporotic_frac = 0;  *Osteoporotic fracture;
	Walker = 0; 			*Walker use;
	Wheelchair = 0; 		*Wheelchair use;
	Home_hosp_bed = 0; 		*home hospital bed; 
	fall = 0;				*Recent fall;

	array DGNSCD {25};
	do k = 1 to 25;

		if DGNSCD{k} in: ("73300","73313","M8008XA","M8008XD","M8008XG","M8008XK","M8008XP","M8008XS","M8088XA","M8088XD","M8088XG","M8088XK","M8088XP","M8088XS") 
		then Osteoporotic_frac=1;

		if DGNSCD{k} in: ("E880","E881","E882","E883","E884","E885","E886","E888","E9681","E987","W00","W01","W02","W03","W04","W05","W06","W07","W08","W09","W10",
							"W11","W12","W13","W14","W15","W160","W161","W162","W163","W164","W17","W180","W181","W182","W183","W19") 
		then fall=1;
		

	end;
   
	drop k;
run;
%mend fra3;
%fra3 (medpar_fra_09, medpar09);
%fra3 (medpar_fra_10, medpar10);
%fra3 (medpar_fra_11, medpar11);
%fra3 (medpar_fra_12, medpar12);
%fra3 (medpar_fra_13, medpar13);
%fra3 (medpar_fra_14, medpar14);
%fra3 (medpar_fra_15, medpar15);
%fra3 (medpar_fra_16, medpar16);

data comp_eff.medpar_fra;
	set comp_eff.medpar_fra_09-comp_eff.medpar_fra_16;
	keep PATIENT_ID claim_date Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall;
run;
proc sort data=comp_eff.medpar_fra out=comp_eff.medpar_fra nodupkey;			* ;
	by _all_;
run;



/* combine the three */
data comp_eff.fra;
	set comp_eff.medpar_fra comp_eff.nch_fra comp_eff.outsaf_fra;
run;
proc sort data=comp_eff.fra out=comp_eff.fra nodupkey;					* ;
	by _all_;
run;


/* filter for diagnosis one year prior the index_date */
data comp_eff.fra_2;
	merge comp_eff.fra(in=in1) comp_eff.covariate_11(keep=patient_id index_date oneyo in=in2);
	by patient_id;
	if in1 and in2;
	
   if claim_date > index_date or claim_date < oneyo then
      do;
		Home_O2 = 0; 			
		Osteoporotic_frac = 0;  
		Walker = 0; 			
		Wheelchair = 0; 		
		Home_hosp_bed = 0; 		
		fall = 0;				
      end;
run;

/* summarize table */
proc sql;				*;

	create table comp_eff.fra_summarized as				
	select patient_id, max(Home_O2) as Home_O2, max(Osteoporotic_frac) as Osteoporotic_frac, max(Walker) as Walker, max(Wheelchair) as Wheelchair, 
			max(Home_hosp_bed) as Home_hosp_bed, max(fall) as fall
	from comp_eff.fra_2
	group by patient_id
	;

quit;

data comp_eff.fra_final;
	merge comp_eff.fra_summarized comp_eff.covariate_11;
	by patient_id;
	keep PATIENT_ID Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall;
run;



PROC FREQ DATA=comp_eff.fra_final;
    TABLES Home_O2 Osteoporotic_frac Walker Wheelchair Home_hosp_bed fall;
RUN;


* Delete datasets no long need;
proc datasets lib=comp_eff nolist;
delete nch_fra_09-nch_fra_16 outsaf_fra_09-outsaf_fra_16 medpar_fra_09-medpar_fra_16 medpar_fra nch_fra outsaf_fra fra fra_2 fra_summarized;
run;


/* Final step - merge to cohort */
data comp_eff.covariate_12;
	merge comp_eff.covariate_11 comp_eff.fra_final;
	by patient_id;
run;
