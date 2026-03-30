****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: Run parametric g-formula for all-cause mortality
****************************************************************************;

****************************************************************************;

%include 'filepath\1_tte_pathways_data_prep.sas';
%include 'filepath\1_tte_pathways_strategies.sas';
%include 'filepath\gformula4.0.sas';

libname results 'C:\Users\emm463\OneDrive - Harvard University\TTE_NIMHD\results';

****************************************************************************;

****** MAKE DATA FORMATTING UPDATES FOR MLP APPROACH ******;

* Outcomes (death, death due to breast cancer), loss to follow-up, and excusing conditions (xcond)
* are all moved forward by 2 years;
proc freq;
tables death_1*period death_bc_1*period censor*period xcond*period xcond_l1*period;
run;

* Re-create death variables;
proc sort;
 by  id descending period;
run;

proc print data =bytimes_cens(obs=50);
var id period;
run;


data bytimes_cens;
	set bytimes_cens;
	death_1_old = death_1;
	death_bc_1_old = death_bc_1;
	censor_old = censor;
	xcond_old = xcond;
	xcond_l1_old = xcond_l1;
	drop death_1 death_bc_1 censor xcond xcond_l1;
run;


data bytimes_cens;
 set bytimes_cens;
 by id;

 death_1 = lag1(death_1_old);
 death_bc_1 = lag1(death_bc_1_old);
 censor = lag1(censor_old);
 xcond = lag1(xcond_old);
 xcond_l1 = lag1(xcond_l1_old);

run;

proc sort;
 by id period;
run;

proc print data = bytimes_cens(obs=50);
var id period;
run;

data bytimes_cens;
set bytimes_cens;
by id;

if last.id then delete;

* Exclude people who died  during the first two years of follow-up;
if days_to_death ne . and days_to_death <= 730.5 then delete;

run;

*Recheck death and censoring variables;
proc freq;
tables death_1*period death_bc_1*period censor*period xcond*period xcond_l1*period;
run;

proc print data = bytimes_cens(obs = 50);
	var id period xcond xcond_l1 lbmi lbmi_l1 wtlift_methr wtlift_methr_l1 aerobic_methr aerobic_methr_l1 death_1 death_bc_1 censor;
run;

proc freq;
tables period;
run;


****************************************************************************;
*******************     RUN PARAMETRIC G-FORMULA      ***********************
****************************************************************************;

OPTIONS NONOTES;

%gformula(
    data = bytimes_cens, 
    id = id, 
    time = period, 
    timepoints = 4,
    timeptype = concat,
    timeknots = 1 2 3,
    outc = death_1,
    outctype = binsurv,  
    interval = 2,
    censor =  censor,
	censorwherem = (period in (0, 2)),
    compevent = ,
    compevent_cens = 0,  

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
	
    cov1  = xcond,  cov1otype   = 2,  cov1ptype  = tsswitch1,
    cov2  = lbmi,   cov2otype   = 3,  cov2ptype  = lag1spl,  cov2knots = 3.017 3.19990 3.51572 3.76491, cov2skip = 2 4,
    cov3  = wtlift_methr,    cov3otype = 4,   cov3ptype = lag1cat,   cov3knots = 0.5 1 2 5, cov3skip = 2 4,
    cov4  = aerobic_methr,    cov4otype   = 3,  cov4ptype  = lag1spl,  cov4knots = 7.78 19.55 49.67 83.59, cov4skip = 2 4,

    seed= 7865,

    savelib = results,
    survdata = results.simsurv_all_mort_mlp,
    covmeandata = results.covmean_all_mort_mlp,
	resultsdata = results.results_all_mort_mlp,

    nsimul=10000,
    nsamples = 500, 
    sample_start = 0,
    sample_end = 500,

    rungraphs = 0,              
    printlogstats = 0,

    numint = 4
    );

OPTIONS NOTES;

* Check number of events;
proc freq data =  bytimes_cens;
    tables death_1 / out = n_events;
    where death_1 = 1;
run;
* Create formatted results;
data results;
    merge results.results_all_mort_mlp n_events(keep = COUNT);
    format pd pd_llim95 pd_ulim95 rd RD_llim95 RD_ulim95 comma9.1;
    risk_95 = cat(put(pd, comma9.1), ' (', strip(put(pd_llim95, comma9.1)), 
                  ', ', strip(put(pd_ulim95, comma9.1)), ')');
    rd_95 = cat(put(rd, comma9.1), ' (', strip(put(RD_llim95, comma9.1)),
                   ', ', strip(put(RD_ulim95, comma9.1)), ')');
    rr_95 = cat(put(rr, comma9.2), ' (', strip(put(RR_llim95, comma9.2)),
                   ', ', strip(put(RR_ulim95, comma9.2)), ')');
    a_intervened = cat(put(averinterv, comma9.1), ' %');
    c_intervened = cat(put(intervened, comma9.1), ' %');
    if int = 0 then do;
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
  file = "results/2_tte_pathways_all_mort_mlp.xls"
  style=minimal
  options ( absolute_column_width = '15,5,10,10,10,10,10') ;
  proc print data = results noobs;
       var int2 ssize count obsp risk_95 rd_95 rr_95 a_intervened c_intervened;
  run;
ods tagsets.excelxp close; 

