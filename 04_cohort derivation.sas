/************************************************************************************
	STEP 9. Exclude Prevalent OAC users *28 368;
************************************************************************************/ 

/*Find anticoagulants in redbook*/
/*
data oa.redbook;
	set drug.Redbook2018;
	keep NDCNUM PRODNME GENNME;
	rename PRODNME = brand GENNME = generic NDCNUM = ndc;
run;
proc sort data=oa.redbook out=oa.redbook;
	by _all_;
run;

data oa.redbook_anticoag;
	set oa.redbook;
	where upcase(generic) like '%WARFARIN%' or upcase(generic) like '%PRADAXA%' or upcase(generic) like '%XARELTO%' or 
		  upcase(generic) like '%ELIQUIS%' or upcase(generic) like '%SAVAYSA%' or
		  upcase(brand) like '%WARFARIN%' or upcase(brand) like '%PRADAXA%' or upcase(brand) like '%XARELTO%' or upcase(brand) like '%ELIQUIS%' or upcase(brand) like '%SAVAYSA%';

run;
proc sort data=oa.redbook_anticoag out=oa.redbook_anticoag nodup;
	by _all_;
run;
*/

/*extract only useful columns in PDE*/
data oac_can.pdesaf09;	set seermed.pdesaf09;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID; 	run;
data oac_can.pdesaf10;	set seermed.pdesaf10;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data oac_can.pdesaf11;	set seermed.pdesaf11;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data oac_can.pdesaf12;	set seermed.pdesaf12;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data oac_can.pdesaf13;	set seermed.pdesaf13;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data oac_can.pdesaf14;	set seermed.pdesaf14;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data oac_can.pdesaf15;	set seermed.pdesaf15;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;
data oac_can.pdesaf16;	set seermed.pdesaf16;	keep PATIENT_ID srvc_mon srvc_day srvc_yr BN GNN DAYS_SUPLY_NUM PROD_SRVC_ID;	run;

data oac_can.pdesaf;				*177170622;
	set oac_can.pdesaf09-oac_can.pdesaf16;
run;

/*
proc sql;
create table oa.oa as
select *
from oa.redbook_anticoag as a, oa.pdesaf as b
where a.ndc = b.prod_srvc_id;
quit;


data oa.pdesaf_oa;
 	set oa.oa;
	srvc_date=mdy(srvc_mon,srvc_day,srvc_yr);
	format srvc_date mmddyy10.;
	keep PATIENT_ID srvc_date;
run;
*/


%macro oa (out_file, in_file);
data oac_can.&out_file;
 	set oac_can.&in_file(where=(GNN = 'WARFARIN SODIUM' or 
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

data oac_can.pdesaf_oa;				*2 941 598;
	set oac_can.pdesaf_oa_09-oac_can.pdesaf_oa_16;
run;
proc sort data = oac_can.pdesaf_oa; by patient_id; run;


data oac_can.Exclusion_3;
   merge oac_can.pdesaf_oa(in=in1) oac_can.index_date_1year_prior(in=in2);
   by PATIENT_ID;
   if in1 and in2 and (oneyo < srvc_date < index_date);
   keep PATIENT_ID;
run;


proc sql;		**28 368;
	create table oac_can.All_cancer_v09 as 
	select *
	from oac_can.All_cancer_v08
	where PATIENT_ID not in (select PATIENT_ID from oac_can.exclusion_3) 
	order by PATIENT_ID;
quit;



/*/*Find the first prescription date of oral anticoagulants*/*/
/*data oa.cancer_date_and_oa_date;*/
/*   merge patient.first_cancer_date(in=in1) oa.pdesaf_oa(in=in2);*/
/*   by PATIENT_ID;*/
/*   if year(srvc_date) ne "2009";*/
/*   if in1 and in2 and cancer_date < srvc_date;*/
/*   keep patient_id srvc_date;*/
/*run;*/
/*proc sort data=oa.cancer_date_and_oa_date out=oa.cancer_date_and_oa_date nodupkey;*/
/*	by patient_id srvc_date;*/
/*run;*/
/**/
/*data oa.first_oa_date;*/
/*	set oa.cancer_date_and_oa_date;*/
/*	by PATIENT_id;*/
/*	if first.PATIENT_id=1 then count=1;*/
/*	else count+1;*/
/*	if count=1 then output oa.first_oa_date;*/
/*	keep patient_id srvc_date;*/
/*run;*/;

/************************************************************************************
	STEP 10. Create flag variable for follow-up enrollment in Medicare part D
		3 mon  27449
		6 mon  26675
		12 mon 24974
	No need to subset datasets and create three separate files
************************************************************************************/

Data oac_can.All_cancer_v10;
set oac_can.All_cancer_v09;

	
	death_date = mdy(med_dodm, med_dodd, med_dody); 	/*Date of Death*/
	format death_date mmddyy10.;

	plan17_01 = "";plan17_02 = "";plan17_03 = "";plan17_04 = "";plan17_05 = "";plan17_06 = "";plan17_07 = "";
	plan17_08 = "";plan17_09 = "";plan17_10 = "";plan17_11 = "";plan17_12 = "";

	ARRAY plan{108} $ plan09_01 - plan09_12 plan10_01 - plan10_12 plan11_01 - plan11_12 plan12_01 - plan12_12
					plan13_01 - plan13_12 plan14_01 - plan14_12 plan15_01 - plan15_12 plan16_01 - plan16_12 plan17_01 - plan17_12;
	Dflag_1 = 0;
	End_mon= Diag_index+3;
	DO  i = Diag_index+1 TO End_mon;
		IF plan{i} in ('0','','N','*') THEN Dflag_1=Dflag_1+1; 
	END;
	
	Dflag_2 = 0;
	if death_date = "." then Dflag_2 = 1;
	IF death_date > index_date and death_date - index_date < 90 then End_mon_Death = (year(death_date)-2009)*12+month(death_date);
	if End_mon_Death = "." then Dflag_2 = 1;
	if End_mon_Death ne "." then DO  j = Diag_index TO End_mon_Death;
		IF plan{j} in ('0','','N','*') THEN Dflag_2=Dflag_2+1; 
	END;

	if Dflag_1 = 0 or Dflag_2 = 0;



	*Medicaid eligibility;
	
	ARRAY dual{96} $ dual09_01-dual09_12 dual10_01-dual10_12 dual11_01-dual11_12 dual12_01-dual12_12
					 dual13_01-dual13_12 dual14_01-dual14_12 dual15_01-dual15_12 dual16_01-dual16_12;
	Dualflag = 0;

	DO i = start_mon TO Diag_index-1;
		IF dual{i} in ('01','02','03','04','05','06', '07','08','09') THEN Dualflag=1; 
	END;

run;
/**/
data test;
	set oac_can.All_cancer_v10; 
	if year(index_date)="2016" and month(index_date) in (/*"7","8","9",*/"10","11","12");
run;

/*NOTE: Whether I change 90, 180 or 365, I am getting the same numbers. WHY?*/
/**/
/*For now, I am keeping 90 days*/

Data oac_can.cohort;
set oac_can.All_cancer_v10;
keep patient_id cancer_type cancer_date index_date dob age death_date m_sex Race dajcc7_01 marst1 cstum1 grade1
	 state2009 state2010 state2011 state2012 state2013 state2014 state2015 state2016
	 zip5_2009 zip5_2010 zip5_2011 zip5_2012 zip5_2013 zip5_2014 zip5_2015 zip5_2016 Dualflag;
study_end_date = "31Dec2016"d;
format death_date mmddyy10. study_end_date  mmddyy10.;
run;

data oac_can.index_date_final;
	merge oac_can.index_date_1year_prior(in=in1) oac_can.All_cancer_v10(keep=patient_id in=in2);
	by patient_id;
	if in1 and in2;
run;
