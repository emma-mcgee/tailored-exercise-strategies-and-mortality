****************************************************************************
Programmer: Emma McGee 
Date: October 27, 2024
Purpose of Program: Specify the physical activity strategies
                    Strategies similar to prior observational studies
****************************************************************************;

****************************************************************************;
******************     SPECIFY THE STRATEGIE(S)      **********************
****************************************************************************;

* INTERVENTION 1 - Minimal aerobic active;
%let interv1  =
    intno     = 1,
    intlabel  = 'Minimal aerobic active',
    nintvar   = 1,
    intvar1   = aerobic_methr,
    inttype1  = 2,
    intmax1   = 1.66666,
    intpr1    = 1,
    inttimes1 = 0 1 2 3 ;


* INTERVENTION 2 - Insufficient aerobic active;
%let interv2  =
    intno     = 2,
    intlabel  = 'Insufficient aerobic active',
    nintvar   = 1,
    intvar1   = aerobic_methr,
    inttype1  = 2,
    intmin1   = 1.66667,
    intmax1   = 8.33332,
    intpr1    = 1,
    inttimes1 = 0 1 2 3 ;


* INTERVENTION 3 - Active ;
%let interv3  =
    intno     = 3,
    intlabel  = 'Active aerobic activity',
    nintvar   = 1,
    intvar1   = aerobic_methr,
    inttype1  = 2,
    intmin1   = 8.33333,
    intmax1   = 16.66666,
    intpr1    = 1,
    inttimes1 = 0 1 2 3 ;


* INTERVENTION 4 - Highly active aerobic activity;
%let interv4  =
    intno     = 4,
    intlabel  = 'Highly active aerobic activity',
    nintvar   = 1,
    intvar1   = aerobic_methr,
    inttype1  = 2,
    intmin1   = 16.66667,
    intpr1    = 1,
    inttimes1 = 0 1 2 3  ;
