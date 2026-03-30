****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: Specify the physical activity strategies
****************************************************************************;

****************************************************************************;
******************     SPECIFY THE STRATEGIE(S)      **********************
****************************************************************************;

* INTERVENTION 1 - Health-education;
%let interv1  =
    intno     = 1,
    intlabel  = 'Health-education group',
    intcond   = (xcond3 = 0),
    nintvar   = 1,
    intvar1   = rec_aerobic_methr,
    inttype1  = 2,
    intmax1   = 15,
    intpr1    = 1,
    inttimes1 = 0 1 ;

* INTERVENTION 2 - Exercise;
%let interv2  =
    intno     = 2,
    intlabel  = 'Exercise group',
    intcond   = (xcond3 = 0),
    nintvar   = 1,
    intvar1   = rec_aerobic_methr,
    inttype1  = 2,
    intmin1   = 21.3,
    intpr1    = 1,
    inttimes1 = 0 1 ;
