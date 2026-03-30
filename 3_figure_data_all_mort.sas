****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: Format data to generate risk curves
                    for all-cause mortality
****************************************************************************;

***************************************************************************;

libname results 'filepath\results';

****************************************************************************;

data simsurv;
   set results.simsurv_all_mort;
run;
proc contents; run;


data forsurv ;
   set simsurv (keep = surv0-surv5 int _sample_);
run;

****************************************************************************;

*** Natural course ***;

data nc (keep = time surv _sample_) ;
set forsurv(where = (int = 0)) ;
array surva{*} surv0-surv5 ;
do time = 0 to 5 ;
   i = time + 1 ;
   surv = surva[i];
   output ;
end;
run;

proc sort data = nc ;
by time _sample_ ;
run;


data nc0 ;
set nc (where = (_sample_ = 0));
keep time surv;
run;


proc univariate data = nc (where = (_sample_ > 0)) noprint ;
var surv ;
output out = ncbounds
       pctlpre = surv0 
       pctlname = _pct025 _pct975 
       pctlpts = 2.5 97.5 ;
by time ;
run;


data ncgraph ;
merge nc0 ncbounds ;
by time ;
run;

****************************************************************************;

*** Intervention 1 ***;

data int1 ;
set forsurv(where = (int = 1));
array surva{*} surv0-surv5 ;
do time = 0 to 5 ;
   i = time + 1 ;
   surv = surva[i];
   output ;
end;
run;

data int1_0 ;
set int1 (where = (_sample_ = 0));
keep time surv;
run;

proc sort data = int1 ;
by time _sample_;
run;

proc univariate data = int1 (where = (_sample_ > 0)) noprint;
var surv  ;
output out = int1bounds
       pctlpre = surv1  
       pctlname = _pct025 _pct975 
       pctlpts = 2.5 97.5 ;
by time ;       
run;

data int1graph ;
merge int1_0 int1bounds ;
by time ;
run;

****************************************************************************;

*** Intervention 2 ***;

data int2 ;
set forsurv(where = (int = 2));
array surva{*} surv0-surv5 ;
do time = 0 to 5 ;
   i = time + 1 ;
   surv = surva[i];
   output ;
end;
run;

data int2_0 ;
set int2 (where = (_sample_ = 0));
keep time surv;
run;

proc sort data = int2 ;
by time _sample_;
run;

proc univariate data = int2 (where = (_sample_ > 0)) noprint;
var surv  ;
output out = int2bounds
       pctlpre = surv2  
       pctlname = _pct025 _pct975 
       pctlpts = 2.5 97.5 ;
by time ;       
run;

data int2graph ;
merge int2_0 int2bounds ;
by time ;
run;

****************************************************************************;

*** Intervention 3 ***;

data int3 ;
set forsurv(where = (int = 3));
array surva{*} surv0-surv5 ;
do time = 0 to 5 ;
   i = time + 1 ;
   surv = surva[i];
   output ;
end;
run;

data int3_0 ;
set int3 (where = (_sample_ = 0));
keep time surv;
run;

proc sort data = int3 ;
by time _sample_;
run;

proc univariate data = int3 (where = (_sample_ > 0)) noprint;
var surv  ;
output out = int3bounds
       pctlpre = surv3  
       pctlname = _pct025 _pct975 
       pctlpts = 2.5 97.5 ;
by time ;       
run;

data int3graph ;
merge int3_0 int3bounds ;
by time ;
run;

****************************************************************************;

*** Intervention 4 ***;

data int4 ;
set forsurv(where = (int = 4));
array surva{*} surv0-surv5 ;
do time = 0 to 5 ;
   i = time + 1 ;
   surv = surva[i];
   output ;
end;
run;

data int4_0 ;
set int4 (where = (_sample_ = 0));
keep time surv;
run;

proc sort data = int4 ;
by time _sample_;
run;

proc univariate data = int4 (where = (_sample_ > 0)) noprint;
var surv  ;
output out = int4bounds
       pctlpre = surv4  
       pctlname = _pct025 _pct975 
       pctlpts = 2.5 97.5 ;
by time ;       
run;

data int4graph ;
merge int4_0 int4bounds ;
by time ;
run;

****************************************************************************;

*** COMBINE DATA ***;

data allgraphs ;
merge 
ncgraph (rename = (surv = surv0)) 
int1graph (rename = (surv = surv1)) 
int2graph (rename = (surv = surv2)) 
int3graph (rename = (surv = surv3))
int4graph (rename = (surv = surv4))
;
by time ;
run;


* Save dataset for graphs;
data results.forgraphs_all_mort;
set allgraphs;
run;

proc print data = results.forgraphs_all_mort; run;

