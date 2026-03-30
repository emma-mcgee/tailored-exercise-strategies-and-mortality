****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: Specify the physical activity strategies
****************************************************************************;

****************************************************************************;
******************     SPECIFY THE STRATEGIE(S)      **********************
****************************************************************************;

* INTERVENTION 1 - Increase aeorobic activity levels by 30 minutes moderate activity;
%let interv1  =
    intno     = 1,
    intlabel  = 'Increase aerobic by 30 minutes moderate',
    intcond   = (xcond = 0),
    nintvar   = 1,
    intvar1   = aerobic_methr,
    inttype1  = 3,
    intchg1   = 1.6666667,
    intpr1    = 1,
    inttimes1 = 0 1 2 3 ;

* INTERVENTION 2 - Increase aerobic activity levels by 60 minutes moderate activity;
%let interv2  =
    intno     = 2,
    intlabel  = 'Increase aerobic by 60 minutes moderate',
    intcond   = (xcond = 0),
    nintvar   = 1,
    intvar1   = aerobic_methr,
    inttype1  = 3,
    intchg1   = 3.3333333,
    intpr1    = 1,
    inttimes1 = 0 1 2 3 ;

* INTERVENTION 3 - Increase aerobic activity levels by 90 minutes moderate activity;
%let interv3  =
    intno     = 3,
    intlabel  = 'Increase aerobic by 90 minutes moderate',
    intcond   = (xcond = 0),
    nintvar   = 1,
    intvar1   = aerobic_methr,
    inttype1  = 3,
    intchg1   = 5,
    intpr1    = 1,
    inttimes1 = 0 1 2 3 ;

* INTERVENTION 4 - Increase aerobic activity levels by 120 minutes moderate activity;
%let interv4  =
    intno     = 4,
    intlabel  = 'Increase aerobic by 120 minutes moderate',
    intcond   = (xcond = 0),
    nintvar   = 1,
    intvar1   = aerobic_methr,
    inttype1  = 3,
    intchg1   = 6.6666667,
    intpr1    = 1,
    inttimes1 = 0 1 2 3  ;
