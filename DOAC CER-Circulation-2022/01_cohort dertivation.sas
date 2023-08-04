/****************************************************************************
| Program name : 01_cohort dertivation
| Date (update):
| Project name :
| Purpose      :
|
|
****************************************************************************/
libname seermed "D:\SEER Medicare_Huijun\combined data";
libname comp_eff "D:\SEER Medicare_Huijun\Manuscript 2_comparative effectiveness\SAS datasets";

/************************************************************************************
	STEP 1. All cancers	N = 1,436,930
************************************************************************************/

data comp_eff.all_cancer;
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

/************************************************************************************
	Included patients with primary cancer of that particular tumor - Hemal 7.12.2021
		N = 1,243,274
************************************************************************************/
data comp_eff.all_cancer_v00;
set comp_eff.all_cancer;
if 
(	cancer_type in ("BLADDER_CANCER") 	and siterwho1 in ("29010")	) OR
(	cancer_type in ("BREAST_CANCER")  	and siterwho1 in ("26000")	) OR
(	cancer_type in ("COLORECTAL_CANCER")and siterwho1 in ("21041", "21042", "21043", "21044", "21045", "21046", "21047", "21048", "21049", "21051", "21052", "21060")	) OR
(	cancer_type in ("ESOPHAGUS_CANCER") and siterwho1 in ("21010")	) OR
(	cancer_type in ("KIDNEY_CANCER") 	and siterwho1 in ("29020")	) OR
(	cancer_type in ("LUNG_CANCER") 		and siterwho1 in ("22030")	) OR
(	cancer_type in ("OVARY_CANCER") 	and siterwho1 in ("27040")	) OR
(	cancer_type in ("PANCREAS_CANCER") 	and siterwho1 in ("21100")	) OR
(	cancer_type in ("PROSTATE_CANCER") 	and siterwho1 in ("28010")	) OR
(	cancer_type in ("STOMACH_CANCER") 	and siterwho1 in ("21020")	) OR
(	cancer_type in ("UTERUS_CANCER") 	and siterwho1 in ("27020", "27030")	) 
;
run;

/***********************************************************************************************
	Create ALL variables in a new data for cohort derivation (missing cancer date N =)
	N = 1 236 500
***********************************************************************************************/
Data comp_eff.all_cancer_v01 (keep = PATIENT_ID cancer_date cancer_type MODX1 DTDX1 YRDX1 BIRTHM BIRTHYR med_dodm med_dodd med_dody
							m_sex Race marst1 dajcc7_01 cstum1 grade1
							state2009 state2010 state2011 state2012 state2013 state2014 state2015 state2016
							zip5_2009 zip5_2010 zip5_2011 zip5_2012 zip5_2013 zip5_2014 zip5_2015 zip5_2016
							mon217 - mon312  gho217 - gho312 plan09_01 - plan09_12 plan10_01 - plan10_12 
							plan11_01 - plan11_12 plan12_01 - plan12_12 plan13_01 - plan13_12 
							plan14_01 - plan14_12 plan15_01 - plan15_12 plan16_01 - plan16_12
							dual09_01-dual09_12 dual10_01-dual10_12 dual11_01-dual11_12 dual12_01-dual12_12
			 				dual13_01-dual13_12 dual14_01-dual14_12 dual15_01-dual15_12 dual16_01-dual16_12);
set comp_eff.all_cancer_v00 ;
		DTDX1 = 1;								
		cancer_date=mdy(MODX1,DTDX1,YRDX1);			/*cancer date*/
		   format cancer_date mmddyy10.;
/*		  informat cancer_type $10.;*/
		 if cancer_date = . then delete;
run;


/************************************************************************************
	STEP 2. Cancer between 2010 and 2016 (multiple cancer patient, not unique)	N = 1,012,721
************************************************************************************/
Data comp_eff.all_cancer_v02;
set comp_eff.all_cancer_v01;
	if year(cancer_date)>=2010 and year(cancer_date)<=2016;
run;

/************************************************************************************
	STEP 3. Select first cancer if patients have multiple cancers N = 1,012,721
************************************************************************************/
proc sort Data = comp_eff.all_cancer_v02; by patient_id cancer_date; run;

data comp_eff.all_cancer_v03;
	set comp_eff.all_cancer_v02;
	by patient_id;
	if first.patient_id;
run;

/************************************************************************************
	STEP 4. Select patients who received prescription of oral anticoagulants from 2010 to 2016	N = 105 923
************************************************************************************/

/*extract only useful columns in PDE*/
data comp_eff.pdesaf09;	set seermed.pdesaf09;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID; 	run;
data comp_eff.pdesaf10;	set seermed.pdesaf10;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data comp_eff.pdesaf11;	set seermed.pdesaf11;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data comp_eff.pdesaf12;	set seermed.pdesaf12;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data comp_eff.pdesaf13;	set seermed.pdesaf13;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data comp_eff.pdesaf14;	set seermed.pdesaf14;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data comp_eff.pdesaf15;	set seermed.pdesaf15;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data comp_eff.pdesaf16;	set seermed.pdesaf16;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;

data comp_eff.pdesaf;				*177170622;
	set comp_eff.pdesaf09-comp_eff.pdesaf16;
run;


%macro oa (out_file, in_file);
data comp_eff.&out_file;
 	set comp_eff.&in_file(where=(GNN = 'WARFARIN SODIUM' or 
						   BN in ('PRADAXA', 'XARELTO', 'ELIQUIS', 'SAVAYSA') ));
	srvc_date=mdy(srvc_mon,srvc_day,srvc_yr);
	format srvc_date mmddyy10.;
	keep PATIENT_ID srvc_date gnn bn days_suply_num;
run;
%mend oa;

%oa (pdesaf_oa_09, pdesaf09);
%oa (pdesaf_oa_10, pdesaf10);
%oa (pdesaf_oa_11, pdesaf11);
%oa (pdesaf_oa_12, pdesaf12);
%oa (pdesaf_oa_13, pdesaf13);
%oa (pdesaf_oa_14, pdesaf14);
%oa (pdesaf_oa_15, pdesaf15);
%oa (pdesaf_oa_16, pdesaf16);

data comp_eff.pdesaf_oa;				*2 941 598;
	set comp_eff.pdesaf_oa_09-comp_eff.pdesaf_oa_16;
run;
proc sort data = comp_eff.pdesaf_oa; by patient_id srvc_date; run;

**Delete individual datasets -- i have stacked data;
proc datasets lib=comp_eff nolist;
delete pdesaf09-pdesaf16 pdesaf_oa_09-pdesaf_oa_16;
run;


data comp_eff.index_date_v1; * 1 211 767;
	merge comp_eff.pdesaf_oa(in=in1 where=(2010<=year(srvc_date)<=2016)) comp_eff.all_cancer_v03(in=in2 keep=patient_id cancer_date);
	by  patient_id;
	if in1 and in2;
	if srvc_date > cancer_date;
run;
proc sort data = comp_eff.index_date_v1; by patient_id srvc_date; run;

data comp_eff.index_date; *  105 923;
	set comp_eff.index_date_v1;
	by patient_id;
	if first.patient_id;
	oneyo = intnx('year',srvc_date,-1,"sameday");
	twoyo = intnx('year',srvc_date,-2,"sameday");
	format oneyo mmddyy10.
           index_date mmddyy10.;
	keep patient_id oneyo srvc_date twoyo;
	rename srvc_date = index_date;
run;


data comp_eff.all_cancer_v04; *105 923;
	merge comp_eff.all_cancer_v03(in=in1) comp_eff.index_date(in=in2);
	by patient_id;
	if in1 and in2;
run;


/*proc sql;*/
/*	create table comp_eff.patient_id as*/
/*	select distinct patient_id */
/*	from comp_eff.all_cancer_v04;*/
/*quit;*/

/************************************************************************************
	Step 5. Age >= 66 years		N =  92 685
************************************************************************************/
Data comp_eff.all_cancer_v05; 			* 94 700;
	set comp_eff.all_cancer_v04;

	DOB = mdy(BIRTHM, 1, BIRTHYR); /*Date of Birth*/
	format DOB mmddyy10.;
	
	age = floor ((intck('month',DOB,index_date) - (day(index_date) < day(DOB))) / 12); 
	format index_date mmddyy10.
			DOB mmddyy10.;
	if age>=66;
run;

/************************************************************************************
	Step 6. Continuous enrollment	N = 46 948
************************************************************************************/

**6.1 Part A B;
data comp_eff.All_cancer_v06_1;	* 89 181;
	set comp_eff.all_cancer_v05;

	Diag_index = (year(index_date)-2010)*12+month(index_date)+12;
	start_mon= Diag_index-12;

	ARRAY ENTY{96} $ mon217 - mon312;
	Entyflag = 0;
	DO  i = start_mon TO Diag_index;
		IF ENTY{i} in ('3') THEN Entyflag=Entyflag+1; 
		END;
	if Entyflag=13;
run;

**6.2 No HMO;
data comp_eff.All_cancer_v06_2;	* 53 060;
	set comp_eff.All_cancer_v06_1;

	ARRAY HMOY{96} $ gho217 - gho312;
	Hmoyflag = 0;
	DO  i = start_mon TO Diag_index;
		IF HMOY{i} in ('0') THEN Hmoyflag=Hmoyflag+1; 
		END;
	if Hmoyflag=13;
	
	drop gho217 - gho312;
run;

**6.3 Part D;
data comp_eff.All_cancer_v06_3;	*45 943;
	set comp_eff.All_cancer_v06_2;

	ARRAY plan{96} $ plan09_01 - plan09_12 plan10_01 - plan10_12 plan11_01 - plan11_12 plan12_01 - plan12_12
					plan13_01 - plan13_12 plan14_01 - plan14_12 plan15_01 - plan15_12 plan16_01 - plan16_12;

	Dflag = 0;
	DO  i = start_mon TO Diag_index;
		IF plan{i} in ('0','','N','*') THEN Dflag=Dflag+1; 
	END;

	if Dflag=0;
run;
/**/
/*/*************************************************************************************/
/*	Step 7. Diagnosis of cancer within 1-year prior to the index date	N = 30 382*/
/*************************************************************************************/*/
/*data comp_eff.All_cancer_v07;	* 30 382;*/
/*	set comp_eff.All_cancer_v06_3;*/
/*	if oneyo < cancer_date < index_date;*/
/*run;*/


