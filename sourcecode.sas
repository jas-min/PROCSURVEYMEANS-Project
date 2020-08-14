/* PROC SURVEY MEANS PROJECT  */

data bar;
	input date $7. num_drinks;
	
/* let's say:
 on August 10, there were 300 groups
 on August 11, there were 275 groups
 on August 12, there were 310 groups
 if there were 10 bars observed, sampling weight is here:
 Aug 10: 10/300
 Aug 11: 10/275
 Aug 12: 10/310
 
 Now let's modify our data*/

	if date = "10AUG20 " then weight = 300/10;
	if date = "11AUG20 " then weight = 275/10;
	if date = "12AUG20 " then weight = 310/10;
	
/* making the strata dataset */

	datalines;
10AUG20 476
10AUG20 380
10AUG20 499
10AUG20 331
10AUG20 310
10AUG20 254
10AUG20 427
10AUG20 218
10AUG20 496
10AUG20 378
11AUG20 203
11AUG20 357
11AUG20 463
11AUG20 269
11AUG20 240
11AUG20 285
11AUG20 325
11AUG20 421
11AUG20 286
11AUG20 379
12AUG20 281
12AUG20 425
12AUG20 493
12AUG20 227
12AUG20 458
12AUG20 484
12AUG20 382
12AUG20 391
12AUG20 283
12AUG20 211
;

data groups;
	length date $7.;
	date = "10AUG20 "; 
		_total_= 300; 
		output;
	date = "11AUG20 "; 
		_total_ = 275; 
		output;
	date = "12AUG20 "; 
		_total_ = 310; 
		output;

run;
proc print data=bar;
title "Number of Drinks Sold at Bars: SIMULATED RAW SURVEY DATA";
run;
proc print data = groups;
title "Bar Strata";
run;

proc surveymeans data=bar N=groups mean sum t clm stderr;
	strata date / list;
	var num_drinks;
	weight weight;
	ods output stratainfo=strata
			   statistics=bar_results;
title "PROC SURVEYMEANS";
run;
		
proc means data=bar mean sum t clm stderr;
	var num_drinks;
	weight weight;
title "PROC MEANS WEIGHTED";
run;
	
proc means data=bar mean sum t clm stderr;
	var num_drinks;
title "PROC MEANS NO WEIGHT";
run;	
	
	
/* NOW A MORE COMPLICAED SURVEY DESIGN */
/* Lets say we have 3 stratum:
 	calpoly students = C
 	not calpoly students below 35 = N
 	over 35 = O
   Because of simulated data I'm counting groups as one. */
 	
data bar_goers;
 	input stratum $1. bar :$15. groups alone pairs all;
 	
 	datalines;
C FrogAndPeach 29 39 52 172
C Library 78 96 67 308
C Motav 150 97 183 595
C McLintocks 100 97 183 545
C SideCar 100 30 78 286
C CreekyTiki 70 68 87 312
C TheGraduate 96 67 12 187
C BlackSheep 66 85 95 341
C BullsTavern 13 6 80 179
C Libertine 0 8 34 76
N FrogAndPeach 18 35 56 165
N Library 77 71 42 232
N Motav 20 9 37 103
N McLintocks 15 97 39 190
N SideCar 61 59 21 162
N CreekyTiki 13 4 44 105
N TheGraduate 98 46 84 312
N BlackSheep 95 87 17 216
N BullsTavern 25 54 58 195
N Libertine 5 1 38 82
O Library 13 0 12 37
O Motav 150 1 10 15 35
O CreekyTiki 5 2 6 19
O TheGraduate 7 3 8 26
O BlackSheep 4 11 9 33
O BullsTavern 3 13 6 28
O Libertine 10 11 14 49
;

data survey_misc;
	length stratum $1.;
	input stratum $ _total_;
	datalines;
C 3001
N 1762
O 227
;
run;
proc print data = bar_goers;
run;
proc print data = survey_misc;
run;
/* you then should sort your data by stratum but I already did that.  */

proc means data = bar_goers;
	by stratum;
	var all;
	output out=mean_data n=n;
run;

data bar_goers;
	merge bar_goers survey_misc mean_data;
	by stratum;
	weight = _total_/n;
run;

proc print data = bar_goers;
title "Bar Scene: Simulated Raw Data";
run;

proc surveymeans data = bar_goers total=survey_misc sum clsum mean clm t;
	strata stratum / list; 
	var all;
	weight weight;
	domain bar / CLDIFF;
run;


proc surveymeans data = bar_goers total=survey_misc sum clsum mean clm t;
	strata stratum / list; 
	var all;
	weight weight;
	domain stratum / CLDIFF;
	ods output stratainfo=strata
		       statistics=bar_goers_results;
run;
