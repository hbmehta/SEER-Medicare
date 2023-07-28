/****************************************************************************
| Program name : 14_create negative control outcomes
| Date (update):
| Project name :
| Purpose      :
|
| 
****************************************************************************/

/******************************* NC outcome: Pneumonia ********************************************************************/

%macro pneumonia (out_file, in_file);
data comp_eff.&out_file;
 	set seermed.&in_file;

	if DGNSCD1 in:("481","4820","4821","4822","4823","4824","48282", "48283","48284","48289","4829","483","485","486",
					"A481","J13","J14","J15","J16","J180","J181","J188","J189")  then condition_met=1;
   
	if condition_met=1;
	drop condition_met;
run;
%mend pneumonia;

%pneumonia (medpar_pneumonia09, medpar09);
%pneumonia (medpar_pneumonia10, medpar10);
%pneumonia (medpar_pneumonia11, medpar11);
%pneumonia (medpar_pneumonia12, medpar12);
%pneumonia (medpar_pneumonia13, medpar13);
%pneumonia (medpar_pneumonia14, medpar14);
%pneumonia (medpar_pneumonia15, medpar15);
%pneumonia (medpar_pneumonia16, medpar16);

data comp_eff.pneumonia;
	set comp_eff.medpar_pneumonia09-comp_eff.medpar_pneumonia16;
	pneumonia_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	keep PATIENT_ID pneumonia_date;		/*Changedrenamed date to pneumonia date*/
	if pneumonia_date ne .;
run;
proc sort data=comp_eff.pneumonia out=comp_eff.pneumonia nodupkey;					*   135509;
	by _all_;
	format pneumonia_date mmddyy10.;
run;

**Delete individual datasets -- i have stacked data;
proc datasets lib=comp_eff nolist;
delete medpar_pneumonia09-medpar_pneumonia16;
run;


data comp_eff.pneumonia_v01;
	merge comp_eff.pneumonia(in=in1) comp_eff.covariate_13(keep=patient_id index_date in=in2);
	by patient_id;
	if in1 and in2;
	if pneumonia_date > index_date;
	if first.patient_id;
run;

data comp_eff.covariate_14;
	merge comp_eff.covariate_13 comp_eff.pneumonia_v01(keep=patient_id pneumonia_date);
	by patient_id;
run;



/* Create censoring variables */
data comp_eff.event_3;
	set comp_eff.covariate_14;
	
	* asthma_date_w_censor = minimum of (censor_date, death_date, asthma_date);
	asthma_date_w_censor = min(asthma_date, participate_end_date);
	format asthma_date_w_censor mmddyy10.;
	
	years_to_asthma = (asthma_date_w_censor - index_date)/365;

	* pneumonia_date_w_censor = minimum of (censor_date, death_date, pneumonia_date);
	pneumonia_date_w_censor = min(pneumonia_date, participate_end_date);
	format pneumonia_date_w_censor mmddyy10.;
	
	years_to_pneumonia = (pneumonia_date_w_censor - index_date)/365;

	/************************************ Censor flag and outcomes ***************************************************************/
	* censor flag for asthma;
	if asthma_date_w_censor = asthma_date then censor_flag_asthma = 1; * event coded =1;
	else censor_flag_asthma = 0;

	* censor flag for pneumonia;
	if pneumonia_date_w_censor = pneumonia_date then censor_flag_pneumonia = 1; * event coded =1;
	else censor_flag_pneumonia = 0;
	
	
	if pneumonia_date_w_censor = pneumonia_date then censor_flag_pneumonia_2 = 1; * event coded =1;
	else if pneumonia_date_w_censor = death_date_v1 then censor_flag_pneumonia_2 = 2;
	else censor_flag_pneumonia_2 = 0;

	* outcome variables;
	time_to_asthma = asthma_date_w_censor - index_date;
	time_to_pneumonia = pneumonia_date_w_censor - index_date;

run;

proc freq data=comp_eff.event_3;
	tables censor_flag_asthma*doac_flag censor_flag_pneumonia*doac_flag;
run;









/******************************* NC outcome: hip/pelvic ********************************************************************/

%macro hipp (out_file, in_file);
data comp_eff.&out_file;
 	set seermed.&in_file;

	if DGNSCD1 in:( "73314", "73315", "73396", "73397", "73398", "808", "820",
 "M80051A", "M80052A", "M80059A", "M80851A", "M80852A", "M80859A", "M84350A",
"M84351A", "M84352A", "M84353A", "M84359A", "M84451A", "M84452A", "M84453A",
"M84459A", "M84550A", "M84551A", "M84552A", "M84553A", "M84559A", "M84650A",
"M84651A", "M84652A", "M84653A", "M84659A", "S32301A", "S32301B", "S32302A",
"S32302B", "S32309A", "S32309B", "S32311A", "S32311B", "S32312A", "S32312B", "S32313A",
"S32313B", "S32314A", "S32314B", "S32315A", "S32315B", "S32316A", "S32316B", "S32391A",
"S32391B", "S32392A", "S32392B", "S32399A", "S32399B", "S32401A", "S32401B", "S32402A",
"S32402B", "S32409A", "S32409B", "S32411A", "S32411B", "S32412A", "S32412B", "S32413A",
"S32413B", "S32414A", "S32414B", "S32415A", "S32415B", "S32416A", "S32416B", "S32421A",
"S32421B", "S32422A", "S32422B", "S32423A", "S32423B", "S32424A", "S32424B", "S32425A",
"S32425B", "S32426A", "S32426B", "S32431A", "S32431B", "S32432A", "S32432B", "S32433A",
"S32433B", "S32434A", "S32434B", "S32435A", "S32435B", "S32436A", "S32436B", "S32441A",
"S32441B", "S32442A", "S32442B", "S32443A", "S32443B", "S32444A", "S32444B", "S32445A",
"S32445B", "S32446A", "S32446B", "S32451A", "S32451B", "S32452A", "S32452B", "S32453A",
"S32453B", "S32454A", "S32454B", "S32455A", "S32455B", "S32456A", "S32456B", "S32461A",
"S32461B", "S32462A", "S32462B", "S32463A", "S32463B", "S32464A", "S32464B", "S32465A",
"S32465B", "S32466A", "S32466B", "S32471A", "S32471B", "S32472A", "S32472B", "S32473A",
"S32473B", "S32474A", "S32474B", "S32475A", "S32475B", "S32476A", "S32476B", "S32481A",
"S32481B", "S32482A", "S32482B", "S32483A", "S32483B", "S32484A", "S32484B", "S32485A",
"S32485B", "S32486A", "S32486B", "S32491A", "S32491B", "S32492A", "S32492B", "S32499A",
"S32499B", "S32501A", "S32501B", "S32502A", "S32502B", "S32509A", "S32509B", "S32511A",
"S32511B", "S32512A", "S32512B", "S32519A", "S32519B", "S32591A", "S32591B", "S32592A",
"S32592B", "S32599A", "S32599B", "S32601A", "S32601B", "S32602A", "S32602B", "S32609A",
"S32609B", "S32611A", "S32611B", "S32612A", "S32612B", "S32613A", "S32613B", "S32614A",
"S32614B", "S32615A", "S32615B", "S32616A", "S32616B", "S32691A", "S32691B", "S32692A",
"S32692B", "S32699A", "S32699B", "S32810A", "S32810B", "S32811A", "S32811B", "S3282XA",
"S3282XB", "S3289XA", "S3289XB", "S329XXA", "S329XXB", "S72001A", "S72001B", "S72001C",
"S72002A", "S72002B", "S72002C", "S72009A", "S72009B", "S72009C", "S72011A", "S72011B",
"S72011C", "S72012A", "S72012B", "S72012C", "S72019A", "S72019B", "S72019C", "S72021A",
"S72021B", "S72021C", "S72022A", "S72022B", "S72022C", "S72023A", "S72023B", "S72023C",
"S72024A", "S72024B", "S72024C", "S72025A", "S72025B", "S72025C", "S72026A", "S72026B",
"S72026C", "S72031A", "S72031B", "S72031C", "S72032A", "S72032B", "S72032C", "S72033A",
"S72033B", "S72033C", "S72034A", "S72034B", "S72034C", "S72035A", "S72035B", "S72035C",
"S72036A", "S72036B", "S72036C", "S72041A", "S72041B", "S72041C", "S72042A", "S72042B",
"S72042C", "S72043A", "S72043B", "S72043C", "S72044A", "S72044B", "S72044C", "S72045A",
"S72045B", "S72045C", "S72046A", "S72046B", "S72046C", "S72051A", "S72051B", "S72051C",
"S72052A", "S72052B", "S72052C", "S72059A", "S72059B", "S72059C", "S72061A", "S72061B",
"S72061C", "S72062A", "S72062B", "S72062C", "S72063A", "S72063B", "S72063C", "S72064A",
"S72064B", "S72064C", "S72065A", "S72065B", "S72065C", "S72066A", "S72066B", "S72066C",
"S72091A", "S72091B", "S72091C", "S72092A", "S72092B", "S72092C", "S72099A", "S72099B",
"S72099C", "S72101A", "S72101B", "S72101C", "S72102A", "S72102B", "S72102C", "S72109A",
"S72109B", "S72109C", "S72111A", "S72111B", "S72111C", "S72112A", "S72112B", "S72112C",
"S72113A", "S72113B", "S72113C", "S72114A", "S72114B", "S72114C", "S72115A", "S72115B",
"S72115C", "S72116A", "S72116B", "S72116C", "S72121A", "S72121B", "S72121C", "S72122A",
"S72122B", "S72122C", "S72123A", "S72123B", "S72123C", "S72124A", "S72124B", "S72124C",
"S72125A", "S72125B", "S72125C", "S72126A", "S72126B", "S72126C", "S72131A", "S72131B",
"S72131C", "S72132A", "S72132B", "S72132C", "S72133A", "S72133B", "S72133C", "S72134A",
"S72134B", "S72134C", "S72135A", "S72135B", "S72135C", "S72136A", "S72136B", "S72136C",
"S72141A", "S72141B", "S72141C", "S72142A", "S72142B", "S72142C", "S72143A", "S72143B",
"S72143C", "S72144A", "S72144B", "S72144C", "S72145A", "S72145B", "S72145C", "S72146A",
"S72146B", "S72146C", "S7221XA", "S7221XB", "S7221XC", "S7222XA", "S7222XB", "S7222XC",
"S7223XA", "S7223XB", "S7223XC", "S7224XA", "S7224XB", "S7224XC", "S7225XA", "S7225XB",
"S7225XC", "S7226XA", "S7226XB", "S7226XC", "S79001A", "S79002A", "S79009A", "S79011A",
"S79012A", "S79019A", "S79091A", "S79092A", "S79099A")  then condition_met=1;
   
	if condition_met=1;
	drop condition_met;
run;
%mend hipp;

%hipp (medpar_hipp09, medpar09);
%hipp (medpar_hipp10, medpar10);
%hipp (medpar_hipp11, medpar11);
%hipp (medpar_hipp12, medpar12);
%hipp (medpar_hipp13, medpar13);
%hipp (medpar_hipp14, medpar14);
%hipp (medpar_hipp15, medpar15);
%hipp (medpar_hipp16, medpar16);

data comp_eff.hipp;
	set comp_eff.medpar_hipp09-comp_eff.medpar_hipp16;
	hipp_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	keep PATIENT_ID hipp_date;		/*Changedrenamed date to hipp date*/
	if hipp_date ne .;
run;
proc sort data=comp_eff.hipp out=comp_eff.hipp nodupkey;					*   135509;
	by _all_;
	format hipp_date mmddyy10.;
run;

**Delete individual datasets -- i have stacked data;
proc datasets lib=comp_eff nolist;
delete medpar_hipp09-medpar_hipp16;
run;


data comp_eff.hipp_v01;
	merge comp_eff.hipp(in=in1) comp_eff.covariate_13(keep=patient_id index_date in=in2);
	by patient_id;
	if in1 and in2;
	if hipp_date > index_date;
	if first.patient_id;
run;

data comp_eff.event_7;
	merge comp_eff.event_6 comp_eff.hipp_v01(keep=patient_id hipp_date);
	by patient_id;
run;



/* Create censoring variables */
data comp_eff.event_10;
	set comp_eff.event_7;

	* hipp_date_w_censor = minimum of (censor_date, death_date, hipp_date);
	hipp_date_w_censor = min(hipp_date, participate_end_date);
	format hipp_date_w_censor mmddyy10.;
	
	years_to_hipp = (hipp_date_w_censor - index_date)/365;

	/************************************ Censor flag and outcomes ***************************************************************/

	* censor flag for hipp;
	if hipp_date_w_censor = hipp_date then censor_flag_hipp = 1; * event coded =1;
	else censor_flag_hipp = 0;
	
	
	if hipp_date_w_censor = hipp_date then censor_flag_hipp_2 = 1; * event coded =1;
	else if hipp_date_w_censor = death_date_v1 then censor_flag_hipp_2 = 2;
	else censor_flag_hipp_2 = 0;

	* outcome variables;
	time_to_hipp = hipp_date_w_censor - index_date;

run;

proc freq data=comp_eff.event_10;
	tables censor_flag_hipp*doac_flag;
run;





/******************************* NC outcome: sepsis ********************************************************************/

%macro sepsis (out_file, in_file);
data comp_eff.&out_file;
 	set seermed.&in_file;

	if DGNSCD1 in ("380","3810","3811","3812","3819","382","383","3840","3841",
				   "3842","3843","3844","3849","388","389","99591","99592",
				   "A400","A401","A403","A408","A409","A412","A4101","A4102",
				   "A411","A403","A414","A4150","A413","A4151","A4152","A4159",
				   "A4181","A4189","A427","A419","A4153","A427","A5486","B377",
				   "R6520","R6521")  then condition_met=1;
   
	if condition_met=1;
	drop condition_met;
run;
%mend sepsis;

%sepsis (medpar_sepsis09, medpar09);
%sepsis (medpar_sepsis10, medpar10);
%sepsis (medpar_sepsis11, medpar11);
%sepsis (medpar_sepsis12, medpar12);
%sepsis (medpar_sepsis13, medpar13);
%sepsis (medpar_sepsis14, medpar14);
%sepsis (medpar_sepsis15, medpar15);
%sepsis (medpar_sepsis16, medpar16);

data comp_eff.sepsis;
	set comp_eff.medpar_sepsis09-comp_eff.medpar_sepsis16;
	sepsis_date=mdy(ADMSNDTM,ADMSNDTD,ADMSNDTY);
	keep PATIENT_ID sepsis_date;		/*Changedrenamed date to sepsis date*/
	if sepsis_date ne .;
run;
proc sort data=comp_eff.sepsis out=comp_eff.sepsis nodupkey;					*   135509;
	by _all_;
	format sepsis_date mmddyy10.;
run;

**Delete individual datasets -- i have stacked data;
proc datasets lib=comp_eff nolist;
delete medpar_sepsis09-medpar_sepsis16;
run;


data comp_eff.sepsis_v01;
	merge comp_eff.sepsis(in=in1) comp_eff.covariate_13(keep=patient_id index_date in=in2);
	by patient_id;
	if in1 and in2;
	if sepsis_date > index_date;
	if first.patient_id;
run;

data comp_eff.covariate_16;
	merge comp_eff.event_10 comp_eff.sepsis_v01(keep=patient_id sepsis_date);
	by patient_id;
run;



/* Create censoring variables */
data comp_eff.event_11;
	set comp_eff.covariate_16;

	* sepsis_date_w_censor = minimum of (censor_date, death_date, sepsis_date);
	sepsis_date_w_censor = min(sepsis_date, participate_end_date);
	format sepsis_date_w_censor mmddyy10.;
	
	years_to_sepsis = (sepsis_date_w_censor - index_date)/365;

	/************************************ Censor flag and outcomes ***************************************************************/

	* censor flag for sepsis;
	if sepsis_date_w_censor = sepsis_date then censor_flag_sepsis = 1; * event coded =1;
	else censor_flag_sepsis = 0;
	
	
	if sepsis_date_w_censor = sepsis_date then censor_flag_sepsis_2 = 1; * event coded =1;
	else if sepsis_date_w_censor = death_date_v1 then censor_flag_sepsis_2 = 2;
	else censor_flag_sepsis_2 = 0;

	* outcome variables;
	time_to_sepsis = sepsis_date_w_censor - index_date;

run;

proc freq data=comp_eff.event_11;
	tables censor_flag_sepsis_2*doac_flag;
run;
