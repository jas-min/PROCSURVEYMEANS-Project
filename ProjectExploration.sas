title 'Simulating Samples from a Normal Density';
data x;
run;

ods graphics on;
proc mcmc data=x outpost=simout seed=23 nmc=10000 diagnostics=none;
   ods exclude nobs;
   parm alpha 0;
   prior alpha ~ normal(24, sd=3);
   model general(0);
run;


 proc kde data=simout;
      ods exclude inputs controls;
      univar alpha /out=sample;
run;
   data den;
      set sample;
      alpha = value;
      true  = pdf('normal', alpha, 23, 3);
      keep alpha density true;
run;

proc sgplot data=den;
         yaxis label="Density";
         series y=density x=alpha / legendlabel = "MCMC Kernel";
         series y=true x=alpha / legendlabel = "True Density";
         discretelegend;
run;

ods graphics off;

/*  page 5855*/
title 'Regenerating Diagnostics Plots';
data Class;
   input Name $ Height Weight;
   datalines;
		Alfred 69.0 112.3	
		Alice 56.5 84.0	
		Barbara 65.3 98.0
		Carol 62.8 102.5 	
		Henry 63.5 102.5	
		James 57.3 83.0
		Jane 59.0 84.5	
		Janet 62.5 112.5	
		Jeffrey 62.5 84.0
		John 59.0 99.5	
		Joyce 62.5 50.5	
		Judy 64.3 90.0
		Louise 56.3 77.0	
		Mary 66.5 112.0	
		Philip 72.0 150.0
		Robert 64.8 128.0	
		Ronald 67.0 133.0	
		Thomas 57.5 85.0
		William 66.5 112.0
		;
run;

ods graphics on;
proc mcmc data=class nmc=50000 thin=5 outpost=classout seed=246810;
	parms beta0 0 beta1 0;
    parms sigma2 1;
    prior beta0 beta1 ~ normal(0, var = 1e6);
    prior sigma2 ~ igamma(3/10, scale = 10/3);
    mu = beta0 + beta1*height;
    model weight ~ normal(mu, var = sigma2);
run;
ods graphics off;


ods graphics on;
   %tadplot(data=classout, var=beta0 logpost);
ods graphics off;
