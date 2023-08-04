/****************************************************************************
| Program name : 26_Sensitivity analysis - receipt of chemo after index date
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/

proc import datafile="D:\SEER Medicare_Huijun\Manuscript 2_comparative effectiveness\ndconc_results.csv"
        out=ndconc_results
        dbms=csv
        replace;
run;

data comp_eff.ndconc_results;
	set ndconc_results;
	NDC_11 = compress(NDC_11__Package_,"-");
run;

%let chemo_hcpcs_list_1=%str(J85[1|2|3|6]0|J85[2|6]1|J856[2|5]|J8600|J8610|J8700|J8705|J8999|J900[0-2]|J901[0|5|7|9]|J902[0|5|7]|J903[1|3|5]|J904[0-3|5|7]|J905[0|5]|J906[0|2|5]|J90[7-9]0|J909[1-8]);
%let chemo_hcpcs_list_2=%str(J91[0-5]0|J915[1|5]|J916[0|5]|J917[0|1|5|8|9]|J918[1|2|5]|J9190|J920[0|1|2|6-9]|J921[1-9]|J922[5|6|8]|J9230|J9245|J9250);
%let chemo_hcpcs_list_3=%str(J926[0-6|8]|J92[7-9]0|J929[1|3]|J930[0|2|3|5-7]|J931[0|5]|J932[0|8]J93[3-5]0|J935[1|4|5|7]|J93[6-9]0|J937[1|5]|J9395|J9[4|6]00|J9999|Q204[3|9]|Q2050|Q0138);


/*NCH*/
%macro chemo_1 (out_file, in_file);
data &out_file;
 	merge seermed.&in_file(keep=patient_id from_dtm from_dtd from_dty hcpcs_cd in=in1) comp_eff.propensity_score_trimmed_2(keep=patient_id index_date in=in2);
	by patient_id;
	if in1 and in2;

	chemo_date=mdy(from_dtm,from_dtd,from_dty);
	format chemo_date mmddyy10.;

	chemo_after = 0;
	
	if prxmatch("/(&chemo_hcpcs_list_1)/", hcpcs_cd) or
	   prxmatch("/(&chemo_hcpcs_list_2)/", hcpcs_cd) or
	   prxmatch("/(&chemo_hcpcs_list_3)/", hcpcs_cd) then chemo_after=1;

	if chemo_date < index_date then chemo_after=0;

	if chemo_after=1;

	keep patient_id chemo_date chemo_after;
run;
%mend chemo_1;

%chemo_1 (nch_chemo09, nch09);
%chemo_1 (nch_chemo10, nch10);
%chemo_1 (nch_chemo11, nch11);
%chemo_1 (nch_chemo12, nch12);
%chemo_1 (nch_chemo13, nch13);
%chemo_1 (nch_chemo14, nch14);
%chemo_1 (nch_chemo15, nch15);
%chemo_1 (nch_chemo16, nch16);

data nch_chemo;
	set nch_chemo09-nch_chemo16;
run;
proc sort data=nch_chemo out=comp_eff.nch_chemo_after nodupkey;		
	by _all_;
run; 
data comp_eff.nch_chemo_after;
	set comp_eff.nch_chemo_after;
	by patient_id chemo_date;
	if first.patient_id;
run;




/* OUTSAF */
%macro chemo_2 (out_file, in_file);
data &out_file;
 	merge seermed.&in_file(keep=PATIENT_ID from_dtm from_dtd from_dty hcpcs_cd in=in1) comp_eff.propensity_score_trimmed_2(keep=patient_id index_date in=in2);
	by patient_id;
	if in1 and in2;

	chemo_date=mdy(from_dtm,from_dtd,from_dty);
	format chemo_date mmddyy10.;

	chemo_after = 0;

	if prxmatch("/(&chemo_hcpcs_list_1)/", hcpcs_cd) or
	   prxmatch("/(&chemo_hcpcs_list_2)/", hcpcs_cd) or
	   prxmatch("/(&chemo_hcpcs_list_3)/", hcpcs_cd) then chemo_after=1;
	
	if chemo_date < index_date then chemo_after=0;

	if chemo_after=1;

	keep patient_id chemo_date chemo_after;

run;
%mend chemo_2;

%chemo_2 (outsaf_chemo09, outsaf09);
%chemo_2 (outsaf_chemo10, outsaf10);
%chemo_2 (outsaf_chemo11, outsaf11);
%chemo_2 (outsaf_chemo12, outsaf12);
%chemo_2 (outsaf_chemo13, outsaf13);
%chemo_2 (outsaf_chemo14, outsaf14);
%chemo_2 (outsaf_chemo15, outsaf15);
%chemo_2 (outsaf_chemo16, outsaf16);

data outsaf_chemo;
	set outsaf_chemo09-outsaf_chemo16;
run;
proc sort data=outsaf_chemo out=comp_eff.outsaf_chemo_after nodupkey;			
	by _all_;
run;


/* Part D */
%macro chemo_3 (out_file, out_file2, in_file);
proc sql;
	create table &out_file as 
	select patient_id, srvc_mon, srvc_day, srvc_yr
	from seermed.&in_file
	where PROD_SRVC_ID in (select NDC_11 from comp_eff.ndconc_results) 
	order by PATIENT_ID;
quit;

data &out_file;
	set &out_file;
	chemo_date=mdy(srvc_mon,srvc_day,srvc_yr);
	format chemo_date mmddyy10.;
	drop srvc_mon srvc_day srvc_yr;
run;
proc sort data=&out_file nodup; by _all_; run;

proc sql;
	create table &out_file2 as 
	select a.patient_id, b.chemo_date, 1 as chemo_after
	from comp_eff.propensity_score_trimmed_2 as a, &out_file as b
	where a.patient_id = b.patient_id and b.chemo_date > a.index_date;
quit;
proc sort data=&out_file2 nodup; by _all_; run;
%mend chemo_3;

%chemo_3 (pde_09, pde_chemo_09, Pdesaf09);
%chemo_3 (pde_10, pde_chemo_10, Pdesaf10);
%chemo_3 (pde_11, pde_chemo_11, Pdesaf11);
%chemo_3 (pde_12, pde_chemo_12, Pdesaf12);
%chemo_3 (pde_13, pde_chemo_13, Pdesaf13);
%chemo_3 (pde_14, pde_chemo_14, Pdesaf14);
%chemo_3 (pde_15, pde_chemo_15, Pdesaf15);
%chemo_3 (pde_16, pde_chemo_16, Pdesaf16);

data pde_chemo;
	set pde_chemo_09-pde_chemo_16;
run;
proc sort data=pde_chemo out=comp_eff.pde_chemo_after nodupkey;			
	by _all_;
run;

data chemo_after;
	set comp_eff.pde_chemo_after comp_eff.outsaf_chemo_after comp_eff.nch_chemo_after;
run;
proc sort data=chemo_after out=chemo_after nodupkey;			
	by _all_;
run;
data comp_eff.chemo_after;
	set chemo_after;
	by patient_id chemo_date;
	if first.patient_id;
run;
data comp_eff.chemo_after;
	set comp_eff.chemo_after;
	waittime = chemo_date - index_date;
run;
/* Final step - merge to cohort */
data comp_eff.propensity_score_trimmed_3;
	merge comp_eff.propensity_score_trimmed_2(in=in1) comp_eff.chemo_after(keep=patient_id chemo_date chemo_after waittime);
	by patient_id;
	if in1;
	if chemo_after ne 1 then chemo_after = 0;
run;
proc freq data=comp_eff.propensity_score_trimmed_3;
	table chemo_after;
run;

* Chemo after;
* death;
proc phreg data=test;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index chemo_flag/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	if waittime >= time_to_death or waittime = . then chemo_flag = 0;	else chemo_flag =1;
run;
proc phreg data=test(where=(chemo_flag=1));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index chemo_flag/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;

run;
proc phreg data=test(where=(chemo_flag=0));
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag_2(0) = doac_flag init_yr time_cancer_to_index chemo_flag/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

data test;
	set comp_eff.propensity_score_trimmed_3;
	waittime = chemo_date - index_date;
	if waittime >= time_to_death or waittime = . then chemo_flag = 0;	else chemo_flag =1;
run;
proc freq data=test;
	table chemo_flag;
run;
	





