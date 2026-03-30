****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: Run parametric g-formula for all-cause mortality
****************************************************************************;

****************************************************************************;

%include 'filepath\1_tte_pathways_data_prep.sas';
%include 'filepath\1_tte_pathways_strategies.sas';
%include 'filepath\gformula4.0.sas';

libname results 'filepath\results';

****************************************************************************;

****************************************************************************;
*******************     RUN PARAMETRIC G-FORMULA      ***********************
****************************************************************************;

OPTIONS NONOTES;

%gformula(
    data = bytimes_cens, 
    id = id, 
    time = period, 
    timepoints = 5,
    timeptype = concat,
    timeknots = 1 2 3 4,
    outc = death_1,
    outctype = binsurv,  
    interval = 2,
    censor =  censor,
	censorwherem = (period in (1, 3)),
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

    nsimul=10000,
    nsamples = 0, 
    sample_start = 0,
    sample_end = 0,

    rungraphs = 1,   
	check_cov_models = 1,
	print_cov_means = 1,
	save_raw_covmean = 1,
	covmeandata = results.covmean,
    graphfile = all_mort_graph.pdf,           
    printlogstats = 0,

    numint = 4
    );

OPTIONS NOTES;

