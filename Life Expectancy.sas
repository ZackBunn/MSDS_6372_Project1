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
model lifeExpectancy = adultMortality hivaids	infantDeaths	alcohol	percentageExpenditure	hepatitisB	measles	bmi	underFiveDeaths	polio	totalExpenditure	diphtheria	gdp	population	thinness1_19Years	thinness5_9Years	incomeCompositionOfResources	schooling/VIF;
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
model logex = adultMortality	totalExpenditure	diphtheria	hivAids	gdp	thinness1_19Years	thinness5_9Years	incomeCompositionOfResources	schooling    /  selection = lasso( choose = cv stop = none ) CVDETAILS;
run;

proc glm data = who;
class logex;
model adultMortality	totalExpenditure = logex;
means logex / hovtest = bf bon cldiff;
run;
