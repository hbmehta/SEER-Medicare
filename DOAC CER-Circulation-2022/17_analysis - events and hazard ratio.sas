/****************************************************************************
| Program name : 14_Events per 100 patient years
| Date (update):
| Project name :
| Purpose      :
|
| 
****************************************************************************/

/************************* Events per 100 patient years ****************************/


****************************** Primary outcome: Time to ischemic stroke or systemic embolism ***********************************;
/**** poisson model for outcome rate *****/
proc sql;
	create table comp_eff.outcome_personyr as
	select doac_flag, sum(years_to_end) as sum
	from comp_eff.event_1
	group by doac_flag;
quit; 
data comp_eff.outcome_personyr_2;
set comp_eff.outcome_personyr;
if doac_flag=0 then outcome=42;
if doac_flag=1 then outcome=52;
rateper100 = (outcome*100)/sum;
run;
proc genmod data=comp_eff.outcome_personyr_2;
model rateper100 = doac_flag;
run;

********************************************************* Secondary outcome: Time to all-cause death *****************************************************************;
/**** poisson model for death rate *****/
proc sql;
	create table comp_eff.outcome_personyr_3 as
	select doac_flag, sum(years_to_death) as sum
	from comp_eff.event_1
	group by doac_flag;
quit; 
data comp_eff.outcome_personyr_4;
set comp_eff.outcome_personyr_3;
if doac_flag=0 then outcome=471;
if doac_flag=1 then outcome=298;
rateper100 = (outcome*100)/sum;
run;
proc genmod data=comp_eff.outcome_personyr_4;
model rateper100 = doac_flag;
run;





********************************************************* NC outcome: Time to pneumonia *****************************************************************;
/**** poisson model for death rate *****/
proc sql;
	create table comp_eff.outcome_personyr_7 as
	select doac_flag, sum(years_to_pneumonia) as sum
	from comp_eff.event_3
	group by doac_flag;
quit; 
data comp_eff.outcome_personyr_8;
set comp_eff.outcome_personyr_7;
if doac_flag=0 then outcome=164;
if doac_flag=1 then outcome=109;
rateper100 = (outcome*100)/sum;
run;
proc genmod data=comp_eff.outcome_personyr_8;
model rateper100 = doac_flag;
run;


********************************************************* NC outcome: Time to hip/pelvic fracutre *****************************************************************;
/**** poisson model for death rate *****/
proc sql;
	create table comp_eff.outcome_personyr_9 as
	select doac_flag, sum(years_to_hipp) as sum
	from comp_eff.event_10
	group by doac_flag;
quit; 
data comp_eff.outcome_personyr_10;
set comp_eff.outcome_personyr_9;
if doac_flag=0 then outcome=53;
if doac_flag=1 then outcome=39;
rateper100 = (outcome*100)/sum;
run;

********************************************************* NC outcome: Time to sepsis *****************************************************************;
/**** poisson model for death rate *****/
proc sql;
	create table comp_eff.outcome_personyr_11 as
	select doac_flag, sum(years_to_sepsis) as sum
	from comp_eff.event_11
	group by doac_flag;
quit; 
data comp_eff.outcome_personyr_12;
set comp_eff.outcome_personyr_11;
if doac_flag=0 then outcome=70;
if doac_flag=1 then outcome=105;
rateper100 = (outcome*100)/sum;
run;
