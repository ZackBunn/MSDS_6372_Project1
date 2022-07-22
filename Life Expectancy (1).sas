proc print data = who;

data who;
set who;
logex=log(lifeExpectancy);
run;

data who;
set who;
hivaids=log(hivAids);
run;

proc sgscatter data=who;
  matrix lifeExpectancy	adultMortality	infantDeaths	alcohol	percentageExpenditure	incomeCompositionOfResources	schooling;
  run;
  
  proc contents data = who;
  run;


proc reg data=who;
model  logex = adultMortality	totalExpenditure	diphtheria	hivAids	gdp	thinness1_19Years	thinness5_9Years	incomeCompositionOfResources	schooling    /  selection = lasso( choose = cv stop = none ) CVDETAILS;
run;


*FWD SELECTION;
proc glmselect data = who plots(stepaxis = number) = (criterionpanel ASEPlot) seed = 123;
partition fraction(test = .15); 
model logex = adultMortality	infantDeaths alcohol	percentageExpenditure	polio	totalExpenditure	diphtheria		gdp	thinness1_19Years	thinness5_9Years	incomeCompositionOfResources	schooling    / selection = forward( stop = none);
run;
*Backward;
proc glmselect data = who plots(stepaxis = number) = (criterionpanel ASEPlot) seed = 123;
partition fraction(test = .15); 
model logex = adultMortality	infantDeaths alcohol	percentageExpenditure	polio	totalExpenditure	diphtheria	hivaids	gdp	thinness1_19Years	thinness5_9Years	incomeCompositionOfResources	schooling    / selection =backward 	( stop = none);
run;
*Stepwise;
proc glmselect data = who plots(stepaxis = number) = (criterionpanel ASEPlot) seed = 123;
partition fraction(test = .15); 
model logex = adultMortality	infantDeaths alcohol	percentageExpenditure	polio	totalExpenditure	diphtheria	hivaids	gdp	thinness1_19Years	thinness5_9Years	incomeCompositionOfResources	schooling    / selection=stepwise	( stop = none);
run;


*Lasso;
 proc glmselect data = who plots(stepaxis = number) = (criterionpanel ASEPlot) seed = 123;
partition fraction(test = .15); 
model logex = adultMortality	totalExpenditure	diphtheria	hivAids	gdp	thinness1_19Years	thinness5_9Years	incomeCompositionOfResources	schooling    /  selection = lasso( choose = cv stop = none ) stats = all;
run;

%put &=GLSIND;

proc glm data = who;
model logex = &_GLSIND/solution clparm;
run;

data whotest;
set who;
partition fraction(test = .15);
proc glm data = who  seed = 123;
partition fraction(test = .15); 
model logex = adultMortality	diphtheria 	hivAids	gdp	thinness5_9Years	incomeCompositionOfResources	schooling    / clparm 
run;

proc glmselect data = who seed = 123;
partition fraction(test = .5); 
model  logex = adultMortality	totalExpenditure	diphtheria	hivAids	gdp	thinness1_19Years	thinness5_9Years	incomeCompositionOfResources	schooling;
run;


proc glm data = who;
class logex;
model adultMortality	totalExpenditure = logex;
means logex / hovtest = bf bon cldiff;
run;
