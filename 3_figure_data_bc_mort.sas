****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: Format data to generate risk curves
                    for breast cancer-specific mortality
****************************************************************************;

***************************************************************************;

libname results 'filepath\results';

****************************************************************************;

data simsurv;
   set results.simsurv_bc_mort;
run;
proc contents; run;


data forrisk ;
   set simsurv (keep = risk1-risk5 int _sample_);
run;

****************************************************************************;

*** Natural course ***;

data nc (keep = time risk _sample_) ;
set forrisk(where = (int = 0)) ;
array riska{*} risk1-risk5 ;
do time = 0 to 0;
   risk = 0;
   output;
end;
do time = 1 to 5 ;
   i = time + 1 ;
   risk = riska[time];
   output ;
end;
run;

proc sort data = nc ;
by time _sample_ ;
run;


data nc0 ;
set nc (where = (_sample_ = 0));
keep time risk;
run;


proc univariate data = nc (where = (_sample_ > 0)) noprint ;
var risk ;
output out = ncbounds
       pctlpre = risk0 
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
set forrisk(where = (int = 1));
array riska{*} risk1-risk5 ;
do time = 0 to 0;
   risk = 0;
   output;
end;
do time = 1 to 5 ;
   i = time + 1 ;
   risk = riska[time];
   output ;
end;
run;

data int1_0 ;
set int1 (where = (_sample_ = 0));
keep time risk;
run;

proc sort data = int1 ;
by time _sample_;
run;

proc univariate data = int1 (where = (_sample_ > 0)) noprint;
var risk  ;
output out = int1bounds
       pctlpre = risk1  
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
set forrisk(where = (int = 2));
array riska{*} risk1-risk5 ;
do time = 0 to 0;
   risk = 0;
   output;
end;
do time = 1 to 5 ;
   i = time + 1 ;
   risk = riska[time];
   output ;
end;
run;

data int2_0 ;
set int2 (where = (_sample_ = 0));
keep time risk;
run;

proc sort data = int2 ;
by time _sample_;
run;

proc univariate data = int2 (where = (_sample_ > 0)) noprint;
var risk  ;
output out = int2bounds
       pctlpre = risk2  
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
set forrisk(where = (int = 3));
array riska{*} risk1-risk5 ;
do time = 0 to 0;
   risk = 0;
   output;
end;
do time = 1 to 5 ;
   i = time + 1 ;
   risk = riska[time];
   output ;
end;
run;

data int3_0 ;
set int3 (where = (_sample_ = 0));
keep time risk;
run;

proc sort data = int3 ;
by time _sample_;
run;

proc univariate data = int3 (where = (_sample_ > 0)) noprint;
var risk  ;
output out = int3bounds
       pctlpre = risk3  
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
set forrisk(where = (int = 4));
array riska{*} risk1-risk5 ;
do time = 0 to 0;
   risk = 0;
   output;
end;
do time = 1 to 5 ;
   i = time + 1 ;
   risk = riska[time];
   output ;
end;
run;

data int4_0 ;
set int4 (where = (_sample_ = 0));
keep time risk;
run;

proc sort data = int4 ;
by time _sample_;
run;

proc univariate data = int4 (where = (_sample_ > 0)) noprint;
var risk  ;
output out = int4bounds
       pctlpre = risk4  
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
ncgraph (rename = (risk = risk0)) 
int1graph (rename = (risk = risk1)) 
int2graph (rename = (risk = risk2)) 
int3graph (rename = (risk = risk3))
int4graph (rename = (risk = risk4))
;
by time ;
run;


* Save dataset for graphs;
data results.forgraphs_bc_mort;
set allgraphs;
run;

proc print data = results.forgraphs_bc_mort; run;

