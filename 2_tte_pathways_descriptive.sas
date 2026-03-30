****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: Create descriptive table of baseline charateristics
 and output descriptive numbers for the text
****************************************************************************;

****************************************************************************;

%include 'filepath\table1.11152018.sas';
%include 'filepath\1_tte_pathways_data_prep.sas';

libname data 'filepath\data';
libname results 'filepath\results';

****************************************************************************;

****************************************************************************;
***************        CREATE DESCRIPTIVE TABLE         ********************
****************************************************************************;

* Load data, restrict to baseline (time 0), and format;
data table1;
	set bytimes_cens;

	if nodal_status = 2 then nodal_status = 0;
	Elix_ca_weight_cat_1 = Elix_ca_weight_cat + 1;
	race_ethnicity_1 = Race_ethnicity;
	if race_ethnicity_1 = 4 then Race_ethnicity_1 = 5;
	if race_ethnicity_1 = 3 and Asian = 1 then race_ethnicity_1 = 3;
	if race_ethnicity_1 = 3 and pi = 1 then race_ethnicity_1 = 4;
	if Stage_ajcc = 10 then stage_ajcc_1 = 1;
	if Stage_ajcc = 30 then stage_ajcc_1 = 2;
	if Stage_ajcc = 50 then stage_ajcc_1 = 3;
	her2_neg_1 = 0;
	if her2_stat = 2 then her2_neg_1 = 1;
	her2_stat_1 = her2_stat;
	if her2_stat_1 = 8 then her2_stat_1 = 3;
	if Surgery = 30 then surgery_1 = 3;
	if Surgery = 20 then surgery_1 = 2;
	if Surgery = 0 then surgery_1 = 1;
	if er_pr_status = 1 then er_pr_stat_1 = 1;
	if er_pr_status in (2, 3) then er_pr_stat_1 = 2;
	if er_pr_status = 4 then er_pr_stat_1 = 3;
	if wtlift_methr >= 1.6666667 then wtlift_freq_1 = 1;
	else if wtlift_methr < 1.6666667 then wtlift_freq_1 = 0;

	* Create categorical version of year of diagnosis;
	if Year_dx >=2005 and Year_dx <= 2007 then year_dx_cat = 1;
	if Year_dx >=2008 and Year_dx <= 2010 then year_dx_cat = 2;
	if Year_dx >=2011 and Year_dx <= 2013 then year_dx_cat = 3;

	* Create new categorical Elixhauser variable;
	if Wghtelixwocancer <0 then elix_ca_weight_cat_new = 1;
	else if (Wghtelixwocancer >=0 and Wghtelixwocancer <2) then elix_ca_weight_cat_new = 2;
	else if Wghtelixwocancer>=2 then elix_ca_weight_cat_new = 3;

	* Create new hours/week moderate and vigorous activity variables - only subtract weight lifting from moderate since no levels count as vigorous;
	moderate_min = (Nonsed_mod_hr - Wtlift_hr)*60;
	vigorous_min = Nonsed_vig_hr*60;

	aerobic_metmin = aerobic_methr*60;

	rec_aerobic_metmin = rec_aerobic_methr*60;


	if period = 0 then output;
run;

* Format data;
proc format;
   value RACE_ETHNICITY_1F
                  1 = 'non-Hispanic White'
                  2 = 'non-Hispanic Black'
                  3 = 'Asian'
				  4 = 'PI'
                  5 = 'Hispanic'
                  6 = 'AIAN';

   value elix_1F
   			1 = '0 comorbidities'
			2 = '1 comorbidity'
			3 = '>=2 comorbidites';

   value elix_new1F
   			1 = '< 0'
			2 = '0 - 2'
			3 = '>=2 ';

	value stage_1F
			1 = 'stage I'
			2 = 'stage II'
			3 = 'stage III';

	value surgery_1F
			1 = 'no Surgery'
            2 = 'lumpectomy'
            3 = 'mastectomy';

	value erpr_1F
			1 = 'er+/pr+'
            2 = 'er- or pr-'
            3 = 'er-/pr-';

	value her2_1F
			1 = 'pos'
            2 = 'neg'
            3 = 'ordered - n/a';

	value year_dx_catF
			1 = '2005 - 2007'
            2 = '2008 - 2010'
            3 = '2011 - 2013';			


run;

data table1;
	set table1;
	format race_ethnicity_1 RACE_ETHNICITY_1F.;
	format Elix_ca_weight_cat_1 elix_1F. ;
	format elix_ca_weight_cat_new elix_new1F. ;
	format stage_ajcc_1 stage_1F.;
	format surgery_1 surgery_1F.;
	format er_pr_stat_1 erpr_1F.;
	format her2_stat_1 her2_1F.;
	format year_dx_cat year_dx_catF.;
run;

* Check data;
proc freq;
tables her2_stat her2_stat_1 her2_neg_1 Surgery surgery_1
	   er_pr_status er_pr_stat_1 wtlift_freq_bl wtlift_freq_1 
	   year_dx_cat
	   race_ethnicity_1 Race_ethnicity;
run;

* Create table;
%table1(data = table1,
		noexp = T,
	    varlist = age_dx Meno_status_bl race_ethnicity_1 educ income
                 moderate_min vigorous_min aerobic_metmin rec_aerobic_metmin wtlift_freq_1
                 bmi_cat_bl smoke_status_bl elix_ca_weight_cat_new
                 stage_ajcc_1 nodal_status er_pr_stat_1 her2_stat_1 
                 year_dx_cat horm chemo rad surgery_1,
	    file = 2_tte_pathways_descriptive,
	    cat = Meno_status_bl
		      wtlift_freq_1
              nodal_status 
              horm chemo rad,
	    poly = race_ethnicity_1 educ income wrlift_freq_bl
               bmi_cat_bl smoke_status_bl elix_ca_weight_cat_new
               stage_ajcc_1 er_pr_stat_1 her2_stat_1
			   year_dx_cat 
               surgery_1,
		mdn = age_dx moderate_min vigorous_min aerobic_metmin rec_aerobic_metmin,
		pctn = pctn,
		dec = 1,
        ageadj = F);
run;
