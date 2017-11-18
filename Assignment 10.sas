/*************************************************************************
Author: Chris Berardi
Creation Date: 3/27/17
Program Name: Assignment 10
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment10.sas
Last Run Date: 4/8/17
Purpose: To complete Assignment 10 for STAT657, Spring 2017
************************************************************************/
*Macro variable for assignment number for fileref;
%let assignment=10;

*Part 3;
*Turn on the triad, symbolgen for macro values as they created, mprint for text
generated from macros and mlogic for logic done with macros;
options symbolgen mprint;
*Leave mlogic off to prevent a lot of ouput from the %colormac macro
mlogic;

*Part 4;
*Set the sasautos option to allow for autocall of the donate macro
include the sasautos as well to allow for calling SAS auto macros;
options sasautos = ('C:\Users\Saistout\Desktop\657\homework\',sasautos);

*Part 5;
*Use nrstr to allow for the use A&M in the file path, use the assignment macro variable for the assignment number;
filename output "C:\Users\Saistout\Desktop\657\homework\%nrstr(A&M)\Chris.Berardi_HW&assignment._output.pdf";
ods pdf file=output bookmarkgen=no;

*Part 6;
*Run the colormac macro to test if sasautos were includedin the sasautos option;
%colormac(help)

*Part 7;
*Call the donate macro with the specificed inputs;
%donate(work, female, 01Jan1996, 31Dec2005)

*Part 8;
*Use proc catalog to list macros in the work library. 
Answer is at the end of the program;
proc catalog cat=work.sasmacr;
title'Compiled Macros in the Work Library';
	contents;
quit;

*Part 9;
data salary_f9605 (keep= employee_id employee_name salary);
	set Female1996;
*labels like output;
	label employee_id = "ID" employee_name= "Name" salary="Salary";
*If if the first time through the loop set the em_id and salary macros with symputx;
	if _N_=1 then do;
		call symputx('emp_id', employee_id); 
		call symputx('salary', salary);
	end;
*Use symget to retrieve the stored macro variables
If the current value for salary exceeds the stores value overwrite it
with symputx;
	if symget('salary') < salary then do;
		call symputx('emp_id', employee_id); 
		call symputx('salary', salary);
	end;
*Concatenate name with the employee id with the left blanks trimed 
with a scan to select the second work in employee_name then the first;
call symputx('name'||left(employee_id),scan(employee_name,-1)||' '||scan(employee_name,1));
run;

*Part 10;
proc print data=salary_f9605 label noobs;
*make titles;
title'Salary Analysis of Selected Employees';
*Use sysfunc with a putn to get the salary macro variable in the correct format
Then us an indirect reference to the macro which contains First Name Last Name;
title2"Top Salary = %sysfunc(putn(&salary,dollar8.)) to: &&name&emp_id";
run;

*Housekeeping;
ods pdf close;
title;
footnote;

*************************************************/
Answer to question in Part 8
All executed macros, as well as all autocall macros
go in the work library when they are compiled.
/************************************************
