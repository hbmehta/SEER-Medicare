/************************************************************************************
	Step 6. Age >= 66 years		N = 125 142

************************************************************************************/

data oac_can.age_exclusion;
set oac_can.all_cancer_v03;		/*use v03 data - unique pts*/
DOB = mdy(BIRTHM, 1, BIRTHYR); /*Date of Birth*/
format DOB mmddyy10.;
keep DOB patient_id;
run;
proc sort data = oac_can.age_exclusion; by patient_id; run;

Data oac_can.All_cancer_v06;
Merge oac_can.All_cancer_v05 (in = a) oac_can.age_exclusion (in = b);
by patient_id;
if a = 1 and b = 1;
run;

Data oac_can.All_cancer_v06;
set oac_can.All_cancer_v06;
	age = floor ((intck('month',DOB,index_date) - (day(index_date) < day(DOB))) / 12); 
	format index_date mmddyy10.
			DOB mmddyy10.;
	if age>=66;
run;

/************************************************************************************
	Step 7. Continuous enrollment	N = 51 437
************************************************************************************/

**7.1 Part A B;
data oac_can.All_cancer_v07_1;	*119 127;
	set oac_can.All_cancer_v06;

	Diag_index = (year(index_date)-2010)*12+month(index_date)+12;
	start_mon= Diag_index-12;

	ARRAY ENTY{96} $ mon217 - mon312;
	Entyflag = 0;
	DO  i = start_mon TO Diag_index;
		IF ENTY{i} in ('3') THEN Entyflag=Entyflag+1; 
		END;
	if Entyflag=13;
run;

data oac_can.All_cancer_v07_2;	* 85 717;
set oac_can.All_cancer_v07_1;
	ARRAY HMOY{96} $ gho217 - gho312;
	Hmoyflag = 0;
	DO  i = start_mon TO Diag_index;
		IF HMOY{i} in ('0') THEN Hmoyflag=Hmoyflag+1; 
		END;
	if Hmoyflag=13;

run;

data oac_can.All_cancer_v07_3;	*51 437;
	set oac_can.All_cancer_v07_2;

	ARRAY plan{96} $ plan09_01 - plan09_12 plan10_01 - plan10_12 plan11_01 - plan11_12 plan12_01 - plan12_12
					plan13_01 - plan13_12 plan14_01 - plan14_12 plan15_01 - plan15_12 plan16_01 - plan16_12;

	Dflag = 0;
	DO  i = start_mon TO Diag_index;
		IF plan{i} in ('0','','N','*') THEN Dflag=Dflag+1; 
	END;

	if Dflag=0;
run;
