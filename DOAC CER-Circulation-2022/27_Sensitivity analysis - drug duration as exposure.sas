/****************************************************************************
| Program name : 27_Sensitivity analysis - drug duration as exposure
| Date (update):
| Project name :
| Purpose      :
| 
|
****************************************************************************/

proc means data=comp_eff.prop_score_drug_duration n min max mean std p25 p50 p75 maxdec = 1;
	var time_to_stroke_embolism;
	*class doac_flag;
run;
data comp_eff.prop_score_drug_duration;
	set comp_eff.propensity_score_trimmed_2;
	if time_to_stroke_embolism < 90 and doac_flag = 0 then drug_dur = "drug duration <90 and warfarin			";
	else if time_to_stroke_embolism < 90 and doac_flag = 1 then drug_dur = "drug duration <90 and doac			";
	else if 90 <= time_to_stroke_embolism < 180  and doac_flag = 0 then drug_dur = "drug duration 90-180 and warfarin			";
	else if 90 <= time_to_stroke_embolism < 180  and doac_flag = 1 then drug_dur = "drug duration 90-180 and doac			";
	else if time_to_stroke_embolism >= 180  and doac_flag = 0 then drug_dur = "drug duration >180 and warfarin			";
	else if time_to_stroke_embolism >= 180  and doac_flag = 1 then drug_dur = "drug duration >180 and doac			";

	if doac_flag = 0 then drug_dur_v01 = 0;
	else if doac_flag = 1 and  time_to_stroke_embolism < 90 		then drug_dur_v01 = 1;
	else if doac_flag = 1 and  90 <= time_to_stroke_embolism < 180 	then drug_dur_v01 = 2;
	else if doac_flag = 1 and  time_to_stroke_embolism >= 180 		then drug_dur_v01 = 3;

run;
proc freq data=comp_eff.prop_score_drug_duration;
	table drug_dur drug_dur_v01;
run;



proc phreg data=comp_eff.prop_score_drug_duration;
	class drug_dur(ref='drug duration <90 and warfarin			') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = drug_dur init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	if time_to_stroke_embolism < 90 and doac_flag = 0 then drug_dur = "drug duration <90 and warfarin			";
	else if time_to_stroke_embolism < 90 and doac_flag = 1 then drug_dur = "drug duration <90 and doac			";
	else if 90 <= time_to_stroke_embolism < 180  and doac_flag = 0 then drug_dur = "drug duration 90-180 and warfarin			";
	else if 90 <= time_to_stroke_embolism < 180  and doac_flag = 1 then drug_dur = "drug duration 90-180 and doac			";
	else if time_to_stroke_embolism >= 180  and doac_flag = 0 then drug_dur = "drug duration >180 and warfarin			";
	else if time_to_stroke_embolism >= 180  and doac_flag = 1 then drug_dur = "drug duration >180 and doac			";
run;

************************************
	Hemal trial/error
************************************;

proc phreg data=comp_eff.prop_score_drug_duration;
	class drug_dur_v01 (ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = drug_dur_v01 init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.prop_score_drug_duration;
	class drug_dur_v01 (ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag(0) = drug_dur_v01 init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;
proc phreg data=comp_eff.prop_score_drug_duration;
	class drug_dur_v01 (ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_death*censor_flag(0) = drug_dur_v01 init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
run;

proc phreg data=comp_eff.prop_score_drug_duration;
	class drug_dur_v02 (ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = drug_dur_v02 init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	if doac_flag = 0 then drug_dur_v02 = 0;
	else if doac_flag = 1 and  time_to_stroke_embolism < 90 		then drug_dur_v02 = 1;
	else if doac_flag = 1 and  90 <= time_to_stroke_embolism < 180 	then drug_dur_v02 = 2;
	else if doac_flag = 1 and  time_to_stroke_embolism >= 180 		then drug_dur_v02 = 3;
run;


************************************
	Hemal match on duration of drug exposure
************************************;
data comp_eff.prop_score_drug_duration;
	set comp_eff.propensity_score_trimmed_2;
	if time_to_stroke_embolism <= 90 			then drug_dur_stroke = 0;		*censor_flag;
	else if 91<= time_to_stroke_embolism <=180 	then drug_dur_stroke = 1;
	else if  time_to_stroke_embolism > 180     	then drug_dur_stroke = 2;

	if time_to_major_bleed <= 90 			then drug_dur_bleed = 0;			*censor_flag_3;
	else if 91<= time_to_major_bleed <=180 	then drug_dur_bleed = 1;
	else if  time_to_major_bleed > 180     	then drug_dur_bleed = 2;

	if time_to_death <= 90 				then drug_dur_death = 0;		*censor_flag_2;
	else if 91<= time_to_death <=180 	then drug_dur_death = 1;
	else if  time_to_death > 180     	then drug_dur_death = 2;

	if time_to_sepsis <= 90 			then drug_dur_sepsis = 0;		*censor_flag_sepsis_2;
	else if 91<= time_to_sepsis <=180 	then drug_dur_sepsis = 1;
	else if  time_to_sepsis > 180     	then drug_dur_sepsis = 2;

run;

proc freq data = comp_eff.prop_score_drug_duration;
tables drug_dur_stroke * censor_flag;
tables drug_dur_bleed * censor_flag_3;
tables drug_dur_death * censor_flag_2;
tables drug_dur_sepsis * censor_flag_sepsis_2;

tables doac_flag*drug_dur_stroke * censor_flag;
tables doac_flag*drug_dur_bleed * censor_flag_3;
tables doac_flag*drug_dur_death * censor_flag_2;
tables doac_flag*drug_dur_sepsis * censor_flag_sepsis_2;

run;

**1. Trimmed IPTW association of ischemic stroke or systematic embolism (<90 days of duration);
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	where drug_dur_stroke = 0 ;
run;
**2. Trimmed IPTW association of ischemic stroke or systematic embolism (91-180 days of duration);
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	where drug_dur_stroke = 1 ;
run;
**3. Trimmed IPTW association of ischemic stroke or systematic embolism (>180 days of duration);
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_stroke_embolism*censor_flag(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	where drug_dur_stroke = 2 ;
run;



**1. Trimmed IPTW association of  bleeding (<90 days of duration);
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	where drug_dur_bleed = 0 ;
run;
**2. Trimmed IPTW association of bleeding (91-180 days of duration);
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	where drug_dur_bleed = 1 ;
run;
**3. Trimmed IPTW association of bleeding (>180 days of duration);
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag(ref='0') init_yr(ref='2016')/ param=ref;
	model time_to_major_bleed*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	where drug_dur_bleed = 2 ;
run;



**1. Trimmed IPTW association of  death (<90 days of duration);
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_death*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	where drug_dur_death = 0 ;
run;
**2. Trimmed IPTW association of death (91-180 days of duration);
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_death*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	where drug_dur_death = 1 ;
run;
**3. Trimmed IPTW association of death (>180 days of duration);
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_death*censor_flag_3(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_ / normalize;
	where drug_dur_death = 2 ;
run;


proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
	where drug_dur_sepsis = 0;
run;
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
	where drug_dur_sepsis = 1;
run;
proc phreg data=comp_eff.prop_score_drug_duration;
	class doac_flag init_yr(ref='2016')/ param=ref ref=first;
	model time_to_sepsis*censor_flag_sepsis_2(0) = doac_flag init_yr time_cancer_to_index/ eventcode=1 risklimits;
	weight _ATEWgt_;
	where drug_dur_sepsis = 2;
run;
ods html close; ods html;
