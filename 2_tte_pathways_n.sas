****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: N for supplemental tables
****************************************************************************;

****************************************************************************;

%include 'filepath\1_tte_pathways_data_prep.sas';

libname results 'filepath\results';

****************************************************************************;


proc sort data = bytimes_cens; by period;
run;


* Export results to Excel;
ods tagsets.excelxp
  file = "results/2_tte_check_n.xls"
  style=minimal ;


* Check N who remain alive and under follow-up at each period;
proc means n nmiss;
    var id;
	by period;
run;

* Check N who are free of excusing conditions at each follow-up period ;
proc means n nmiss;
    var id;
	where xcond = 0 ;
	by period;
run;

* Check N died at each period;
proc means n nmiss;
    var id;
	where death_1 = 1;
	by period;
run;

* Check N LTFU at each period;
proc means n nmiss;
    var id;
	where censor = 1;
	by period;
run;

ods tagsets.excelxp close; 


proc freq;
tables censor;
run;
