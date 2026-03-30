****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: Run parametric g-formula for all-cause mortality
                    strategies and eligibility similar to Challenge trial
****************************************************************************;

****************************************************************************;

%include 'filepath\1_tte_pathways_data_prep_challenge_stage.sas';
%include 'filepath\1_tte_pathways_strategies_challenge.sas';
%include 'filepath\gformula4.0.sas';

libname results 'filepath\results';

****************************************************************************;


****************************************************************************;
*******************     RUN PARAMETRIC G-FORMULA      ***********************
****************************************************************************;

ods pdf file = "results/2_tte_pathways_all_mort_challenge_stage.pdf";

OPTIONS NONOTES;

%gformula(
    data = bytimes_cens, 
    id = id, 
    time = period, 
    timepoints = 4,
    timeptype = concat,
    timeknots = 1 2 3 4,
    outc = death_1,
    outctype = binsurv,  
    interval = 2,
    censor =  censor,
	censorwherem = (period in (1, 3)),
    compevent = ,
    compevent_cens = 0, 

	hazardratio = 1,
	intcomp = 1 2, 
	bootstrap_hazard = 1,

fixedcov = age_dx_cat_2 age_dx_cat_3 age_dx_cat_4 age_dx_cat_5 age_dx_cat_6
        race_ethnicity_2 race_ethnicity_3 race_ethnicity_4 race_ethnicity_5
        educ_2 educ_3 educ_4
        stage_2 stage_3
        nodal_status
        er_pr_stat_2 er_pr_stat_3
        year_dx_2 year_dx_3 year_dx_4
        elix_ca_weight_cat_0 elix_ca_weight_cat_1 elix_ca_weight_cat_2
        smoke_status_bl_2 smoke_status_bl_3
        Meno_status_bl
		horm
		chemo
		rad
		surgery_2 surgery_3
		,

    ncov=4,
	
    cov1  = xcond3,  cov1otype   = 2,  cov1ptype  = tsswitch1,
    cov2  = lbmi,   cov2otype   = 3,  cov2ptype  = lag1spl,  cov2knots = 3.03 3.21 3.52 3.76, cov2skip = 2 4,
    cov3  = wtlift_methr,    cov3otype = 4,   cov3ptype = lag1cat,   cov3knots = 0.5 1 2 5, cov3skip = 2 4,
    cov4  = rec_aerobic_methr,    cov4otype   = 3,  cov4ptype  = lag1spl,  cov4knots = 0.1 2.6 7.5 24, cov4skip = 2 4,

    seed= 7865,

    savelib = results,
    survdata = results.simsurv_all_mort_challenge_stage,
    covmeandata = results.covmean_all_mort_challenge_stage,
	resultsdata = results.results_all_mort_challenge_stage,

    nsimul=10000,
    nsamples = 500, 
    sample_start = 0,
    sample_end = 500,

    rungraphs = 0,              
    printlogstats = 0,

    numint = 2,
	refint = 1
    );

OPTIONS NOTES;

ods pdf close;

* Check number of events;
proc freq data =  bytimes_cens;
    tables death_1 / out = n_events;
    where death_1 = 1 and period le 3; /* deaths during the first 8 years of follow-up */
run;
* Create formatted results;
data results;
    merge results.results_all_mort_challenge_stage n_events(keep = COUNT);
    format pd pd_llim95 pd_ulim95 rd RD_llim95 RD_ulim95 comma9.1;
    risk_95 = cat(put(pd, comma9.1), ' (', strip(put(pd_llim95, comma9.1)), 
                  ', ', strip(put(pd_ulim95, comma9.1)), ')');
    rd_95 = cat(put(rd, comma9.1), ' (', strip(put(RD_llim95, comma9.1)),
                   ', ', strip(put(RD_ulim95, comma9.1)), ')');
    rr_95 = cat(put(rr, comma9.2), ' (', strip(put(RR_llim95, comma9.2)),
                   ', ', strip(put(RR_ulim95, comma9.2)), ')');
    a_intervened = cat(put(averinterv, comma9.1), ' %');
    c_intervened = cat(put(intervened, comma9.1), ' %');
    if int = 1 then do;
        rd_95 = "0 (reference)";
        rr_95 = "1 (reference)";
    end;

    retain _count;
    if not missing(count) then _count=count;
    else count =_count;
    drop _count;
run;

* Export results to Excel;
ods tagsets.excelxp
  file = "results/2_tte_pathways_all_mort_challenge_stage.xls"
  style=minimal
  options ( absolute_column_width = '15,5,10,10,10,10,10') ;
  proc print data = results noobs;
       var int2 ssize count obsp risk_95 rd_95 rr_95 a_intervened c_intervened;
  run;
ods tagsets.excelxp close; 

