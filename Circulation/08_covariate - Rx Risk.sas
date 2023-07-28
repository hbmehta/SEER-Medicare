/****************************************************************************
| Program name : 08_covariate - Rx Risk
| Date (update):
| Project name :
| Purpose      : Create covariate - Rx Risk index
|
|
****************************************************************************/

 
/* Step 1 - read in redbook and keep only ndc number, brand and generic name*/
data comp_eff.redbook; 			*415512;
	set comp_eff.Redbook2018;
	keep NDCNUM PRODNME GENNME /*THRCLDS THRGRDS*/;
	rename PRODNME = brand GENNME = generic NDCNUM = ndc;
run;
proc sort data=comp_eff.redbook out=comp_eff.redbook;
	by generic brand;
run;

/* Step 2 - read in ATC codes and modify unwanted strings */
proc import datafile="D:\SEER Medicare_Huijun\results\manuscript\drug\ATC.csv"
        out=comp_eff.ATC_raw
        dbms=csv
        replace;
run;

data comp_eff.ATC_raw; 			 *5591;
	set comp_eff.ATC_raw;
	if length(ATC_code) = 7;
	if ATC_code = "A09AA02" then ATC_level_name = "lipase";
	
	ATC_level_name=tranwrd(ATC_level_name, ", combinations", ""); 

run;
data comp_eff.ATC_raw;		 	 *5592;
	set comp_eff.ATC_raw end=eof;
	output;
	if eof then do;
		ATC_code = "A09AA02";
		ATC_level_name = "protease";
	    output;
	 end;
run;

/*Step 3 - create Comorbidity lists using ATC codes*/
%let list1=%str(N07BB0.);
%let list2=%str(R01AC.|R01AD0[1-9]|R01AD[1-5][0-9]|R01AD60|R06A[E-W].|R06AD(?!01)|R06AX0[1-9]|R06AX1[0-9]|R06AX2[0-7]|R06AB04);
%let list3=%str(B01AA(?!01|02)|B01AB0[1–6]|B01AE07|B01AF01|B01AF02|B01AX05);
%let list4=%str(B01AC0[4–9]|B01AC1[0–9]|B01AC2[0–9]|B01AC30);
%let list5=%str(N05BA0[1–9]|N05BA1[0–2]|N05BE01);
%let list6=%str(C01AA05|C01B[A-C].|C01BD01|C07AA07);
%let list7=%str(G04CA.|G04CB01|G04CB02);
%let list8=%str(N05AN01);
%let list9=%str(R03AC(?!01)|R03A(?!A|B|C).|R03[B|C].|R03D[A|B].|R03DC0[1-3]|R03DX05);
%let list10=%str(C07AB07|C07AG02|C07AB12|C03DA04); 
%let list10_1=%str(C03C[A|B].|C03CC01|C09A[A-X].|C09C[A-X].);
%let list11=%str(N06DA0[2–4]|N06DX01); 
%let list12=%str(N06A[A-F].|N06AG0[1-2]| N06AX0[3-9]|N06AX1[0|1|3–8]|N06AX2[1–6]); 
%let list13=%str(A10[A|B][A-X].|A10A[Y|Z].); 
%let list14=%str(N03A[A-X].);
%let list15=%str(S01EA.|S01EB0[1-3]|S01EC(?!01|02)|S01E[D-X].);
%let list16=%str(A02B[A-W].|A02BX0[1-5]);
%let list17=%str(M04A[A|B].|M04AC01);
%let list18=%str(J05AF08|J05AF10|J05AF11);
%let list19=%str(J05AB54|L03AB10|L03AB11|L03AB60|L03AB61|J05AE14|J05AE1[1|2]|J05AX14|J05AX15|J05AX65|J05AB04);
%let list20=%str(J05AE[01–10]|J05AF1[2–9]|J05AF[2-9][0–9]|J05AG0[1-5]|J05AR.|J05AX0[7–9]|J05AX12|J05AF0[1–7]|J05AF09);
%let list21=%str(V03AE01);
%let list22=%str(C10A.|C10B[A-W].|C10BX0[1-9]);
%let list23=%str(C03A.|C03BA0[1-9]|C03BA1[0-1]|C03DB0|C03DB99|C03EA01|C09BA0[2–9]|C09DA0[2-8]|C02AB.|C02AC0[1-5]|C02DB0[2–9]|C02DB[1-9][0–9]);
%let list24=%str(H03BA02|H03BB01);
%let list25=%str(H03AA0[1|2]);
%let list26=%str(A07EC0[1–4]|A07EA0[1|2]|A07EA06|L04AA33);
%let list27=%str(C01DA0[2–9]|C01DA1[0–4]|C01DX16|C08EX02);
%let list28=%str(C07AG01|C08C.|C08DA.|C08DB01|C09DB0[1–4]|C09DX01|C09BB0[2–9]|C09BB10|C07AB03|C09DX03);
%let list29=%str(G04BD.);
%let list30=%str(M01A[B-G].|M01AH0[1-6]);
%let list31=%str(A06AD11|A07AA11);
%let list32=%str(L01[A-W].|L01X[A-W].|L01XX0[1-9]|L01XX[1-3][0-9]|L01XX4[0-1]);
%let list33=%str(B05BA0[1–9]|B05BA10);
%let list34=%str(N02C[A-W].|N02CX01);
%let list35=%str(M05BA.|M05BB0[1-5]|M05BX03|M05BX04|G03XC01|H05AA02);
%let list36=%str(N02A[A-W].|N02AX0[1|2]|N02AX06|N02AX52|N02BE51);
%let list37=%str(A09AA02);
%let list38=%str(N04A.|N04B[A-W].|N04BX0[1|2]);
%let list39=%str(D05AA.|D05BB0[1|2]|D05AX02|D05AC0[1–9]|D05AC[1-4][0–9]|D05AC5[0–1]|D05AX52);
%let list40=%str(N05AA.|N05AB0[1-2]|N05AB0[6-9]|N05AB[1-9][0-9]|N05AL0[1-7]|N05A[C-K].|N05AX0[7–9]|N05AX1[0–3]);
%let list41=%str(C02KX0[1–5]);
%let list42=%str(B03XA0[1–3]|A11CC0[1–4]|V03AE0[2|3|5]);
%let list43=%str(N07BA0[1–3]|N06AX12);
%let list44=%str(H02AB0[1–9]|H02AB10);
%let list45=%str(L04AA06|L04AA10|L04AA18|L04AD01b|L04AD02);
%let list46=%str(J04AC0[1–9]|J04AC[1-4][0–9]|J04AC5[0–1]|J04AM.);


data comp_eff.ATC;
	set comp_eff.ATC_raw;
	informat CC $50.;
	LABEL CC = 'Comorbidity Category';

	if prxmatch("/(&list1)/", ATC_code) then CC = 'Alcohol_dependency';
	if prxmatch("/(&list2)/", ATC_code) then CC = 'Allergies';
	if prxmatch("/(&list3)/", ATC_code) then CC = 'Anticoagulants';
	if prxmatch("/(&list4)/", ATC_code) then CC = 'Antiplatelets';
	if prxmatch("/(&list5)/", ATC_code) then CC = 'Anxiety';
	if prxmatch("/(&list6)/", ATC_code) then CC = 'Arrhythmia';
	if prxmatch("/(&list7)/", ATC_code) then CC = 'Benign_PH'; /*Benign_prostatic_hyperplasia*/
	if prxmatch("/(&list8)/", ATC_code) then CC = 'Bipolar_disorder';
	if prxmatch("/(&list9)/", ATC_code) then CC = 'Chronic_airways_D'; /*Chronic_airways_disease*/
	if prxmatch("/(&list10)/", ATC_code) then CC = 'C_heart_failure'; /*Congestive_heart_failure*/
	if prxmatch("/(&list10_1)/", ATC_code) then CC = 'Multiple';
	if prxmatch("/(&list11)/", ATC_code) then CC = 'Dementia';
	if prxmatch("/(&list12)/", ATC_code) then CC = 'Depression';
	if prxmatch("/(&list13)/", ATC_code) then CC = 'Diabetes';
	if prxmatch("/(&list14)/", ATC_code) then CC = 'Epilepsy';
	if prxmatch("/(&list15)/", ATC_code) then CC = 'Glaucoma';
	if prxmatch("/(&list16)/", ATC_code) then CC = 'Gastrooesophageal_RD'; /*Gastrooesophageal_reflux_disease*/
	if prxmatch("/(&list17)/", ATC_code) then CC = 'Gout';
	if prxmatch("/(&list18)/", ATC_code) then CC = 'Hepatitis_B';
	if prxmatch("/(&list19)/", ATC_code) then CC = 'Hepatitis_C';
	if prxmatch("/(&list20)/", ATC_code) then CC = 'HIV';
	if prxmatch("/(&list21)/", ATC_code) then CC = 'Hyperkalaemia';
	if prxmatch("/(&list22)/", ATC_code) then CC = 'Hyperlipidaemia';
	if prxmatch("/(&list23)/", ATC_code) then CC = 'Hypertension';
	if prxmatch("/(&list24)/", ATC_code) then CC = 'Hyperthyroidism';
	if prxmatch("/(&list25)/", ATC_code) then CC = 'Hypothyroidism';
	if prxmatch("/(&list26)/", ATC_code) then CC = 'Irritable_bowel_S'; /*Irritable_bowel_syndrome*/
	if prxmatch("/(&list27)/", ATC_code) then CC = 'IHD_angina'; /*Ischaemic heart disease:angina*/
	if prxmatch("/(&list28)/", ATC_code) then CC = 'IHD_hypertension'; /*Ischaemic heart disease:hypertension*/
	if prxmatch("/(&list29)/", ATC_code) then CC = 'Incontinence';
	if prxmatch("/(&list30)/", ATC_code) then CC = 'Inflammation_pain';
	if prxmatch("/(&list31)/", ATC_code) then CC = 'Liver_failure';
	if prxmatch("/(&list32)/", ATC_code) then CC = 'Malignancies';
	if prxmatch("/(&list33)/", ATC_code) then CC = 'Malnutrition';
	if prxmatch("/(&list34)/", ATC_code) then CC = 'Migraine';
	if prxmatch("/(&list35)/", ATC_code) then CC = 'Osteoporosis_Pagets';
	if prxmatch("/(&list36)/", ATC_code) then CC = 'Pain';
	if prxmatch("/(&list37)/", ATC_code) then CC = 'Pancreatic_insuff'; /*Pancreatic_insufficiency*/
	if prxmatch("/(&list38)/", ATC_code) then CC = 'Parkinsons_disease';
	if prxmatch("/(&list39)/", ATC_code) then CC = 'Psoriasis';
	if prxmatch("/(&list40)/", ATC_code) then CC = 'Psychotic_illness';
	if prxmatch("/(&list41)/", ATC_code) then CC = 'Pulmonary_hypert'; /*Pulmonary_hypertension*/
	if prxmatch("/(&list42)/", ATC_code) then CC = 'Renal_disease';
	if prxmatch("/(&list43)/", ATC_code) then CC = 'Smoking_cessation';
	if prxmatch("/(&list44)/", ATC_code) then CC = 'Steroid_responsive_D'; /*Steroid_responsive_disease*/
	if prxmatch("/(&list45)/", ATC_code) then CC = 'Transplant';
	if prxmatch("/(&list46)/", ATC_code) then CC = 'Tuberculosis';

	if CC ne "";
run;

data comp_eff.ATC_rx_left;
	infile datalines dlm = ",";
	informat ATC_code $7. ATC_level_name $30. cc $50.;
	input ATC_code ATC_level_name cc;
	datalines;
		A10BH03,   saxagliptin,                   Hyperlipidaemia
		C10BX03,   atorvastatin and amlodipine,   IHD_hypertension
	;
run;

data comp_eff.ATC;
	set comp_eff.ATC comp_eff.ATC_rx_left;
run;

proc sort data=comp_eff.ATC out=comp_eff.ATC nodup;
	by ATC_code ATC_level_name CC;
run;

/*Step 4 - match generic names from ATC to redbook*/
proc sql noprint;
select distinct trim(ATC_level_name) into :genName separated by "|" from comp_eff.ATC;
quit;
%put &genName;


data comp_eff.ndc; 			*135900;
	if _N_ = 1 then do;
		regEX = prxparse(cats("/(", "&genName", ")/i"));
		array pos[2] 3 _temporary_;
	end;

	retain regEX;

	set comp_eff.Redbook;
	length gn $50;

	call prxsubstr(regEx, generic, pos[1], pos[2]);

	if pos[1] then gn = substr(generic, pos[1], pos[2]);
	else do;
		call prxsubstr(regEx, brand, pos[1], pos[2]);
	if pos[1] then gn = substr(brand, pos[1], pos[2]);
	end;

	if pos[1] then do;
		gn = lowcase(gn);
		output;
	end;
run;


proc sort data = comp_eff.ndc(keep = ndc gn brand generic) out = comp_eff.ndc nodup;
by gn ndc;
run;

/*Step 5 - create a list of matched generic name with ATC code, Comorbidity category, and ndc number*/
proc sql undo_policy = none;
create table comp_eff.ndc_2 as
select *
from comp_eff.ndc as a, comp_eff.ATC as b
where a.gn = b.ATC_level_name;
quit;


/*To cross check with prod_thera excel file*/
/*proc sql;*/
/*create table drug.verify_1*/
/*as select generic,  brand, count (ndc) as num_ndc*/
/*from drug.ndc_2*/
/*group by generic,brand;*/
/*quit;*/
/**/
/*proc sql;*/
/*create table drug.verify_2*/
/*as select generic,  count (ndc) as num_ndc*/
/*from drug.ndc_2*/
/*group by generic;*/
/*quit;*/



/*Step 6 - Find prescriptions in the pde file (also patient ids in comp_eff.covariate_4) by using the "ndc" dataset*/
proc sort data = comp_eff.pdesaf out = comp_eff.pdesaf nodup; by patient_id; run; *177158183;
data comp_eff.Pdesaf_rx;				*2078853;
	merge comp_eff.pdesaf comp_eff.covariate_03(keep = patient_id in=in2);
	by patient_id;
	if in2;
run;
proc sort data = comp_eff.Pdesaf_rx out = comp_eff.Pdesaf_rx nodup; by patient_id; run;

proc sql;							*1767418;
create table comp_eff.ndc_3 as
select a.ndc, a.ATC_code, a.CC, b.prod_srvc_id, b.patient_id, b.days_suply_num
from comp_eff.ndc_2 as a, comp_eff.Pdesaf_rx as b
where a.ndc = b.prod_srvc_id;
quit;

proc sort data = comp_eff.ndc_3 out = comp_eff.ndc_3 nodup; by patient_id ATC_code CC; run;		*  527064;

/*Step 7 - Solve some problems with Comorbidity category */

/*Problem 1 - Need multiple drug to define CC*/
data comp_eff.ndc_p1;
	set comp_eff.ndc_3;
	keep patient_id CC ATC_code;
	if CC = "Multiple";
run;
proc sort data = comp_eff.ndc_p1 out = comp_eff.ndc_p1 nodup; by patient_id ATC_code; run;

	
data comp_eff.ndc_p1_v2;
    set comp_eff.ndc_p1 (keep = patient_id ATC_code);
    by patient_id;
    length combined_atc $100.;
    retain combined_atc;

    if first.patient_id then
        combined_atc=ATC_code;
    else
        combined_atc=catx('|', combined_atc, ATC_code);

    if last.patient_id then
        output;
	keep patient_id combined_atc;
run;
data comp_eff.ndc_p1_v3;
    set comp_eff.ndc_p1_v2;
	combined_atc = cats('"/(', combined_atc, ')/"');
run;

proc sort data = comp_eff.ndc_p1_v3 out = comp_eff.ndc_p1_v3 nodup; by patient_id combined_atc; run;

%let list_a=%str(C03C[A|B].|C03CC01);
%let list_b=%str(C09A[A-X].|C09C[A-X].);
data comp_eff.ndc_p1_v4;
	set comp_eff.ndc_p1_v3;
	informat CC $50.;
	LABEL CC = 'Comorbidity Category';

	if prxmatch("/(&list_a)/", combined_atc) or prxmatch("/(&list_b)/", combined_atc) then CC = "Hypertension";
	if prxmatch("/(&list_a)/", combined_atc) and prxmatch("/(&list_b)/", combined_atc) then CC = "C_heart_failure";

	keep patient_id CC;
run;

data  comp_eff.ndc_p1_multiple;
	set comp_eff.ndc_3;
	if CC = "Multiple";
	drop CC;
run;
data  comp_eff.ndc_p1_non_multiple;
	set comp_eff.ndc_3;
	if CC ne "Multiple";
run;
data  comp_eff.ndc_p1_multiple_new;
   merge comp_eff.ndc_p1_multiple(in=in1) comp_eff.ndc_p1_v4(in=in2);
   by PATIENT_ID;
   if in1 and in2;
run;
data comp_eff.ndc_4;			* 527064;
	set comp_eff.ndc_p1_non_multiple comp_eff.ndc_p1_multiple_new;
run;

/*Problem 2 - >=1 dispensed*/
proc sql;
create table comp_eff.drug_count as 
select patient_id,  CC, sum (DAYS_SUPLY_NUM) as total_days_supply
from comp_eff.ndc_4
group by patient_id,  CC;
quit;

data comp_eff.drug_count_2;
	set comp_eff.drug_count;
	if total_days_supply >1;
	Flag = 1;
	drop total_days_supply;
run;


/*Step 8 - Summarize */
proc transpose data=comp_eff.drug_count_2 out=comp_eff.drug_count_3(drop =_name_);
    by patient_id ;
    id CC;
    var Flag;
run;


data comp_eff.drug_covariate;
 	set comp_eff.covariate_03;

	M_sex = M_sex-1;
	if death_date = "." then dead_flag = 0;
	else dead_flag = 1;

	keep patient_id M_sex age dead_flag;	
run;

data comp_eff.drug_count_4;
   merge comp_eff.drug_count_3 comp_eff.drug_covariate;
   by PATIENT_ID;
run;

data comp_eff.drug_final_data;
   set comp_eff.drug_count_4;
   array all _numeric_;
        do over all;
            if all=. then all=0;
        end;
 run;

 /*Logistic regression*/
 proc logistic data=comp_eff.drug_final_data descending;
  class Alcohol_dependency(ref="0") 		Allergies(ref="0") 					Anticoagulants(ref="0") 				Antiplatelets(ref="0") 
		Anxiety(ref="0") 					Arrhythmia(ref="0") 				Benign_PH(ref="0") 						Bipolar_disorder(ref="0")
		Chronic_airways_D(ref="0") 			C_heart_failure(ref="0") 			Dementia(ref="0") 						Depression(ref="0") 
		Diabetes(ref="0") 					Epilepsy(ref="0") 					Glaucoma(ref="0") 						Gastrooesophageal_RD(ref="0") 	
		Gout(ref="0")						Hepatitis_B(ref="0") 				Hepatitis_C(ref="0") 					HIV(ref="0") 	
		Hyperkalaemia(ref="0") 				Hyperlipidaemia(ref="0") 			Hypertension(ref="0") 					Hyperthyroidism(ref="0") 
		Hypothyroidism(ref="0") 			Irritable_bowel_S(ref="0")			IHD_angina(ref="0") 					IHD_hypertension(ref="0") 
		Incontinence(ref="0") 				Inflammation_pain(ref="0") 			Liver_failure(ref="0") 					Malignancies(ref="0")
		Malnutrition(ref="0") 				Migraine(ref="0") 					Osteoporosis_Pagets(ref="0") 			Pain(ref="0") 
		Pancreatic_insuff(ref="0") 			Parkinsons_disease(ref="0") 		Psoriasis(ref="0") 						Psychotic_illness(ref="0") 
		Pulmonary_hypert(ref="0") 			Renal_disease(ref="0") 				Smoking_cessation(ref="0") 				Steroid_responsive_D(ref="0") 
		Transplant(ref="0") 				Tuberculosis(ref="0")				M_sex(ref="0");

  model dead_flag = Alcohol_dependency 		Allergies 				Anticoagulants 				Antiplatelets 
					Anxiety 				Arrhythmia 				Benign_PH				 	Bipolar_disorder
					Chronic_airways_D 		C_heart_failure 		Dementia 					Depression
					Diabetes 				Epilepsy 				Glaucoma 					Gastrooesophageal_RD	
					Gout					Hepatitis_B 			Hepatitis_C 				HIV
					Hyperkalaemia 			Hyperlipidaemia 		Hypertension 				Hyperthyroidism
					Hypothyroidism 			Irritable_bowel_S		IHD_angina					IHD_hypertension
					Incontinence 			Inflammation_pain 		Liver_failure				Malignancies
					Malnutrition 			Migraine 				Osteoporosis_Pagets			Pain
					Pancreatic_insuff 		Parkinsons_disease 		Psoriasis					Psychotic_illness
					Pulmonary_hypert 		Renal_disease 			Smoking_cessation			Steroid_responsive_D
					Transplant 				Tuberculosis			M_sex;
  ODS output OddsRatios = comp_eff.output_odds_ratio;
  ODS output ParameterEstimates = comp_eff.output_estimates;
run;

data comp_eff.output_odds_ratio;
	set comp_eff.output_odds_ratio;
	if Effect ne "age" then Effect = substr(Effect,1,length(Effect)-7);
run;

proc sql;
	create table comp_eff.output as
	select a.effect, a.OddsRatioEst, b.variable, b.ProbChisq
	from comp_eff.output_odds_ratio as a, comp_eff.output_estimates as b
	where a.effect = b.variable;
quit;

data comp_eff.weight_table;
	set comp_eff.output;

	weight = .;
	if ProbChisq >0.1 then weight = 0;
	if OddsRatioEst <1 and ProbChisq <=0.1 then weight = -1;
	if OddsRatioEst >=1 and OddsRatioEst <1.2 and ProbChisq <=0.1 then weight = 1;
	if OddsRatioEst >=1.2 and OddsRatioEst <1.4 and ProbChisq <=0.1 then weight = 2;
	if OddsRatioEst >=1.4 and OddsRatioEst <1.6 and ProbChisq <=0.1 then weight = 3;
	if OddsRatioEst >=1.6 and OddsRatioEst <1.8 and ProbChisq <=0.1 then weight = 4;
	if OddsRatioEst >=1.8 and OddsRatioEst <2.0 and ProbChisq <=0.1 then weight = 5;
	if OddsRatioEst >=2.0 and ProbChisq <=0.1 then weight = 6;

	keep variable weight;
	if variable ne "age" and variable ne "M_SEX";
run;


/*Step 9 - Generate Rx risk score*/
proc transpose data=comp_eff.weight_table out=comp_eff.weight_wide(drop =_name_);
    id variable;
    var weight;
run;

data comp_eff.weight_wide;
	set comp_eff.weight_wide;
	patient_id = "weight";
run;

data comp_eff.rx_risk_final_data_1;
	set comp_eff.drug_final_data;
	drop M_sex age dead_flag;
run;

data comp_eff.rx_risk;
	set comp_eff.rx_risk_final_data_1 comp_eff.weight_wide;
run;


PROC TRANSPOSE data=comp_eff.rx_risk out=comp_eff.rx_risk_t NAME=CC;
	id patient_id;
	VAR Alcohol_dependency 		Allergies 				Anticoagulants 				Antiplatelets 
		Anxiety 				Arrhythmia 				Benign_PH				 	Bipolar_disorder
		Chronic_airways_D 		C_heart_failure 		Dementia 					Depression
		Diabetes 				Epilepsy 				Glaucoma 					Gastrooesophageal_RD	
		Gout					Hepatitis_B 			Hepatitis_C 				HIV
		Hyperkalaemia 			Hyperlipidaemia 		Hypertension 				Hyperthyroidism
		Hypothyroidism 			Irritable_bowel_S		IHD_angina					IHD_hypertension
		Incontinence 			Inflammation_pain 		Liver_failure				Malignancies
		Malnutrition 			Migraine 				Osteoporosis_Pagets			Pain
		Pancreatic_insuff 		Parkinsons_disease 		Psoriasis					Psychotic_illness
		Pulmonary_hypert 		Renal_disease 			Smoking_cessation			Steroid_responsive_D
		Transplant 				Tuberculosis;
RUN;


data comp_eff.rx_risk_t_2;
	set comp_eff.rx_risk_t;
	array nums {*} _numeric_;
	do _n_ = 1 to dim(nums)-1;
	   nums{_n_} = nums{_n_} * weight;
	end;
	drop weight;
run;

PROC TRANSPOSE data=comp_eff.rx_risk_t_2 out=comp_eff.rx_risk_t_3 NAME=patient_id;
	id CC;
RUN;

data comp_eff.rx_risk_final;
	set comp_eff.rx_risk_t_3;

	rx_risk_index = SUM(of _numeric_);
	patient_id = SUBSTR(patient_id,2);
	keep patient_id rx_risk_index;
	label patient_id = "patient_id";
run;

/* Delete used datasets*/
proc datasets lib=comp_eff nolist;
delete redbook ATC_rx_left ATC_raw ATC Drug_count Drug_count_2-Drug_count_4 Drug_covarite Drug_final_data 
	   Ndc Ndc_2-Ndc_4 Ndc_p1 Ndc_p1_multiple Ndc_p1_multiple_new Ndc_p1_non_multiple Ndc_p1_v2-Ndc_p1_v4
	   Output Output_estimates Output_odds_ratio pdesaf_rx rx_risk rx_risk_final_data_1 rx_risk_t rx_risk_t_2 rx_risk_t_3 weight_table weight_wide;
run;

/* Final step - merge to cohort */
data comp_eff.covariate_04;
	merge comp_eff.covariate_03 comp_eff.rx_risk_final;
	by patient_id;
run;

