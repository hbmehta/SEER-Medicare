/****************************************************************************
| Program name : 15_covariate - co-medications
| Date (update):
| Project name :
| Purpose      : Create covariate - co-medications
|
|
****************************************************************************/

 
* Step 1. Find the cohort in PDE file;

proc sort data = oac_can.pdesaf out = oac_can.pdesaf nodup; by patient_id; run; *177158183;
data oac_can.Pdesaf_rx;				* 6954340;
	merge oac_can.pdesaf oac_can.cohort_v08(keep = patient_id in=in2);
	by patient_id;
	if in2;
run;
proc sort data = oac_can.Pdesaf_rx out = oac_can.Pdesaf_rx nodup; by patient_id; run;

* Step 2 - read in redbook and keep only ndc number, brand and generic name;
data oac_can.redbook; 			*415512;
	set seermed.Redbook2018;
	keep NDCNUM PRODNME GENNME /*THRCLDS THRGRDS*/;
	rename PRODNME = brand GENNME = generic NDCNUM = ndc;
run;
proc sort data=oac_can.redbook out=redbook; by generic brand; run;

* Step 3 - put medication classes into strings - generate strings of generic names to match to redbook later;
%let acei=%str(benazepril|captopril|cilazapril|enalapril|enalaprilat|fosinopril|lisinopril|moexipril|perindopril|quinapril|ramipril|trandolapril|spirapril|temocapril|zofenopril|imidapril|delapril);
%put &acei; *Angiotensin-converting enzyme inhibitors;
%let arb=%str(valsartan|olmesartan|eprosartan|telmisartan|irbesartan|tasosartan|azilsartan|fimasartan|candesartan|losartan);
%put &arb; *Angiotensin-receptor blockers;
%let av=%str(nitroglycerin|glyceryl trinitrate|isosorbide dinitrate|isosorbide mononitrate|erythrityl tetranitrate|pentaerythritol tetranitrate|nicorandil|molsidomine|trapidil|imolamine|hexobendine);
%put &av; *Antiangina vasodilators;
%let antiarrhythmics=%str(quinidine|procainamide|disopyramide|sparteine|ajmaline|prajmaline|lorajmine|hydroquinidine|lidocaine|mexiletine|tocainide|aprindine|propafenone|flecainide|lorcainide|encainide|ethacizine|amiodarone|bretylium|bunaftine|dofetilide|ibutilide|tedisamil|dronedarone|moracizine|cibenzoline|vernakalant);
%put &antiarrhythmics; *Antiarrhythmics;
%let antiplatelets=%str(ditazole|cloricromen|picotamide|clopidogrel|ticlopidine|dipyridamole|carbasalate calcium|epoprostenol|indobufen|iloprost|abciximab|aloxiprin|eptifibatide|tirofiban|triflusal|beraprost|treprostinil|prasugrel|cilostazol|ticagrelor|cangrelor|vorapaxar|selexipag);
%put &antiplatelets; *Antiplatelets;
%let aspirin=%str(aspirin|acetylsalicylic acid);
%put &aspirin; *Aspirin;
%let bb=%str(alprenolol|oxprenolol|pindolol|propranolol|timolol|sotalol|nadolol|mepindolol|carteolol|tertatolol|bopindolol|bupranolol|penbutolol|cloranolol|practolol|metoprolol|atenolol|acebutolol|betaxolol|bevantolol|bisoprolol|celiprolol|esmolol|epanolol|s-atenolol|nebivolol|talinolol|landiolol|labetalol|carvedilol);
%put &bb; *Beta-Blockers;
%let ccb=%str(amlodipine|felodipine|isradipine|nicardipine|nifedipine|nimodipine|nisoldipine|nitrendipine|lacidipine|nilvadipine|manidipine|barnidipine|lercanidipine|cilnidipine|benidipine|clevidipine|mibefradil|fendiline|bepridil|lidoflazine|perhexiline);
%put &ccb; *Calcium-channel blockers;
%let diuretics=%str(bendroflumethiazide|hydroflumethiazide|hydrochlorothiazide|chlorothiazide|polythiazide|trichlormethiazide|cyclopenthiazide|methyclothiazide|cyclothiazide|mebutizide|quinethazone|clopamide|chlortalidone|mefruside|clofenamide|metolazone|meticrane|xipamide|indapamide|clorexolone|fenquizone|mersalyl|theobromine|cicletanine|furosemide|bumetanide|piretanide|torasemide|etacrynic acid|tienilic acid|muzolimine|etozolin|spironolactone|potassium canrenoate|canrenone|eplerenone|amiloride|triamterene|tolvaptan|conivaptan);
%put &diuretics; *Diuretics;
%let oa=%str(rescinnamine|reserpine|deserpidine|rauwolfia alkaloids|rauwolfia alkaloids, whole root|combinations of rauwolfia alkaloids|methoserpidine|bietaserpine|methyldopa|clonidine|guanfacine|tolonidine|moxonidine|rilmenidine|trimetaphan|mecamylamine|prazosin|indoramin|trimazosin|doxazosin|urapidil|betanidine|guanethidine|guanoxan|debrisoquine|guanoclor|guanazodine|guanoxabenz|diazoxide|dihydralazine|hydralazine|endralazine|cadralazine|minoxidil|nitroprusside|pinacidil|veratrum|metirosine|pargyline|ketanserin|bosentan|ambrisentan|sitaxentan|macitentan|riociguat|ambrisentan and tadalafil);
%put &oa; *Other antihypertensives;
%let dd=%str(insulin|insulin lispro|insulin aspart|insulin glulisine|insulin degludec and insulin aspart|insulin glargine|insulin detemir|insulin degludec|insulin degludec and liraglutide|insulin glargine and lixisenatide|phenformin|metformin|buformin|glibenclamide|chlorpropamide|tolbutamide|glibornuride|tolazamide|carbutamide|glipizide|gliquidone|gliclazide|metahexamide|glisoxepide|glimepiride|acetohexamide|glymidine|acarbose|miglitol|voglibose|troglitazone|rosiglitazone|pioglitazone|sitagliptin|vildagliptin|saxagliptin|alogliptin|linagliptin|gemigliptin|evogliptin|exenatide|liraglutide|lixisenatide|albiglutide|dulaglutide|semaglutide|dapagliflozin|canagliflozin|empagliflozin|ertugliflozin|ipragliflozin|sotagliflozin|repaglinide|nateglinide|pramlintide|benfluorex|mitiglinide);
%put &dd; *Diabetes drugs;
%let estrogens=%str(ethinylestradiol|estradiol|estriol|chlorotrianisene|estrone|promestriene|conjugated estrogens|dienestrol|diethylstilbestrol|methallenestril|moxestrol|tibolone);
%put &estrogens; *Estrogens;
%let progestins=%str(gestonorone|medroxyprogesterone|hydroxyprogesterone|progesterone|dydrogesterone|megestrol|medrogestone|nomegestrol|demegestone|chlormadinone|promegestone|dienogest|allylestrenol|norethisterone|lynestrenol|ethisterone|etynodiol|methylestrenolone);
%put &progestins; *Progestins;
%let hlmwh=%str(heparin|antithrombin III|dalteparin|enoxaparin|nadroparin|parnaparin|reviparin|danaparoid|tinzaparin|sulodexide|bemiparin);
%put &hlmwh; *Heparin and low-molecular-weight heparins;
%let naid=%str(phenylbutazone|mofebutazone|oxyphenbutazone|clofezone|kebuzone|indometacin|sulindac|tolmetin|zomepirac|diclofenac|alclofenac|bumadizone|etodolac|lonazolac|fentiazac|acemetacin|difenpiramide|oxametacin|proglumetacin|ketorolac|aceclofenac|bufexamac|piroxicam|tenoxicam|droxicam|lornoxicam|meloxicam|ibuprofen|naproxen|ketoprofen|fenoprofen|fenbufen|benoxaprofen|suprofen|pirprofen|flurbiprofen|indoprofen|tiaprofenic acid|oxaprozin|ibuproxam|dexibuprofen|flunoxaprofen|alminoprofen|dexketoprofen|naproxcinod|mefenamic acid|tolfenamic acid|flufenamic acid|meclofenamic acid|celecoxib|rofecoxib|valdecoxib|parecoxib|etoricoxib|lumiracoxib|polmacoxib|nabumetone|niflumic acid|azapropazone|glucosamine|benzydamine|glucosaminoglycan polysulfate|proquazone|orgotein|nimesulide|feprazone|diacerein|morniflumate|tenidap|oxaceprol|chondroitin sulfate);
%put &naid; *Nonsteroidal anti-inflammatory drugs;
%let statins=%str(simvastatin|lovastatin|pravastatin|fluvastatin|atorvastatin|cerivastatin|rosuvastatin|pitavastatin);
%put &statins; *Statins;
%let nlld=%str(clofibrate|bezafibrate|aluminium clofibrate|gemfibrozil|fenofibrate|simfibrate|ronifibrate|ciprofibrate|etofibrate|clofibride|choline fenofibrate|colestyramine|colestipol|colextran|colesevelam|niceritrol|nicotinic acid|nicofuranose|aluminium nicotinate|nicotinyl alcohol (pyridylcarbinol)|pyridylcarbinol|nicotinyl alcohol|acipimox|nicotinic acid, combinations|dextrothyroxine|probucol|tiadenol|meglutol|omega-3 triglycerides|magnesium pyridoxal 5-phosphate glutamate|policosanol|ezetimibe|alipogene tiparvovec|mipomersen|lomitapide|evolocumab|alirocumab|bempedoic acid);
%put &nlld; *Nonstatin lipid-lowering drugs;
%let ppi=%str(omeprazole|pantoprazole|lansoprazole|rabeprazole|esomeprazole|dexlansoprazole|dexrabeprazole|vonoprazan);
%put &ppi; *Proton-pump inhibitors;



* Step 4 - match generic names to redbook and find patient id with the NDC;
%macro rb (out_file_1, out_file_2, string, med);
	data &out_file_1; 			*;
		if _N_ = 1 then do;
			regEX = prxparse(cats("/(", "&string", ")/i"));
			array pos[2] 3 _temporary_;
		end;

		retain regEX;

		set oac_can.redbook;
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

	proc sql;							
		create table oac_can.&out_file_2 as
		select a.ndc, b.prod_srvc_id, b.patient_id, 1 as &med
		from &out_file_1 as a, oac_can.Pdesaf_rx as b
		where a.ndc = b.prod_srvc_id;
	quit;
	
	data oac_can.&out_file_2;
		set oac_can.&out_file_2;
		keep patient_id &med;
	run;

	proc sort data = oac_can.&out_file_2 out = oac_can.&out_file_2 nodup; by patient_id; run;

%mend rb;

%rb(ndc_1, ndc_acei, &acei, acei);
%rb(ndc_2, ndc_arb, &arb, arb);
%rb(ndc_3, ndc_av, &av, av);
%rb(ndc_4, ndc_antiarrhythmics, &antiarrhythmics, antiarrhythmics);
%rb(ndc_5, ndc_antiplatelets, &antiplatelets, antiplatelets);
%rb(ndc_6, ndc_aspirin, &aspirin, aspirin);
%rb(ndc_7, ndc_bb, &bb, bb);
%rb(ndc_8, ndc_ccb, &ccb, ccb);
%rb(ndc_9, ndc_diuretics, &diuretics, diuretics);
%rb(ndc_10, ndc_oa, &oa, oa);
%rb(ndc_11, ndc_dd, &dd, dd);
%rb(ndc_12, ndc_estrogens, &estrogens, estrogens);
%rb(ndc_13, ndc_progestins, &progestins, progestins);
%rb(ndc_14, ndc_hlmwh, &hlmwh, hlmwh);
%rb(ndc_15, ndc_naid, &naid, naid);
%rb(ndc_16, ndc_statins, &statins, statins);
%rb(ndc_17, ndc_nlld, &nlld, nlld);
%rb(ndc_18, ndc_ppi, &ppi, ppi);


/* Final step - merge to cohort */
data oac_can.cohort_v09;

	merge oac_can.cohort_v08(in=in1) oac_can.Ndc_acei; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.Ndc_arb; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_av; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_antiarrhythmics; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_antiplatelets; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_aspirin; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_bb; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_ccb; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_diuretics; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_oa; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_dd; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_estrogens; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_progestins; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_hlmwh; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_naid; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_statins; by patient_id; if in1;

	merge oac_can.cohort_v08(in=in1) oac_can.ndc_nlld; by patient_id; if in1;
	
	merge oac_can.cohort_v08(in=in1) oac_can.ndc_ppi; by patient_id; if in1;

	if acei ne 1 then acei = 0;
	if arb ne 1 then arb = 0;
	if av ne 1 then av = 0;
	if antiarrhythmics ne 1 then antiarrhythmics = 0;
	if antiplatelets ne 1 then antiplatelets = 0;
	if aspirin ne 1 then aspirin = 0;
	if bb ne 1 then bb = 0;
	if ccb ne 1 then ccb = 0;
	if diuretics ne 1 then diuretics = 0;
	if oa ne 1 then oa = 0;
	if dd ne 1 then dd = 0;
	if estrogens ne 1 then estrogens = 0;
	if progestins ne 1 then progestins = 0;
	if hlmwh ne 1 then hlmwh = 0;
	if naid ne 1 then naid = 0;
	if statins ne 1 then statins = 0;
	if nlld ne 1 then nlld = 0;
	if ppi ne 1 then ppi = 0;
run;
