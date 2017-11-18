/*************************************************************************
Author: Chris Berardi
Creation Date: 3/24/17
Program Name: Assignment 9
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment9.sas
Last Run Date: 3/27/17
Purpose: To complete Assignment 9 for STAT657, Spring 2017
************************************************************************/

*Part 1;
*Turn on the triad, symbolgen for macro values as they created, mprint for text
generated from macros and mlogic for logic done with macros;
options symbolgen 
mprint 
mlogic;

*Create libref for the permanent data library;
libname homework 'C:\Users\Saistout\Desktop\657\homework\data';

*Create libref to orion data;
libname orion 'C:\Users\Saistout\Desktop\657\homework\data\SQL_Files' access=readonly;

*output fileref;
filename output "C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW09_output.pdf";

*remove page numbers and dates;
option nodate nonumber;

*open the ods output, remove bookmarks from the pdf;
ods pdf file=output bookmarkgen=no;

*Part 2;
*Global macros, using the names in the homework, to define start date, end date, gender and library for output table;
%let startdt=01Jan2006;
%let enddt=31Dec2006;
%let outlib=work;
%let gender=F;

*Code from homework 8 with hardcoded variables replaced with macro variables;
*Use two outer left joins to combine the 3 tables on the common Employee_ID key;
proc sql;
	create table &outlib..&gender.donors as
		select p.Employee_ID label='ID', Employee_Name label='Name', Salary format dollar8., Qtr1, Qtr2, Qtr3, Qtr4, sum(qtr1,qtr2,qtr3,qtr4) as total_donation label='Ann. Donation'
			from orion.employee_payroll as p
			left join
				orion.employee_addresses as a
				on p.Employee_ID=a.Employee_ID
			left join
				orion.employee_donations as d
				on d.employee_id=p.employee_id
/*Select only macro gender employees, use a list in case of errors in the data, use the macros to define the start and end dates, take only employees without a termination date*/
			where employee_gender = "&gender" and employee_hire_date between "&startdt"d and "&enddt"d and not employee_term_date
	;
quit;

*Part 3
Use a proc print to print out the data portion using the syslast macro variable;
proc print data=&syslast;
*Use the trim function with sysfunc to apply it to a macro to remove the trailing spaces on &syslast;
title 'Data Portion of the ' "%sysfunc(trim(&syslast))" ' Data Set';
run;

*Part 4;
%macro donations(outlib, gender, startdt, enddt);
*Code from homework 8 with hardcoded variables replaced with macro variables;
*Use two outer left joins to combine the 3 tables on the common Employee_ID key;
*Use the propcase inside of sysfunc to apply the function to gender, assuring the first letter is capitalized;
%let gender=%sysfunc(propcase(&gender));
proc sql;
*Use a substr to take the last 4 chars of the startdt to get the year;
	create table &outlib..&gender.%substr(&startdt,6) as
		select p.Employee_ID label='ID', Employee_Name label='Name', Salary format dollar8., Qtr1, Qtr2, Qtr3, Qtr4, sum(qtr1,qtr2,qtr3,qtr4) as total_donation label='Ann. Donation'
			from orion.employee_payroll as p
			left join
				orion.employee_addresses as a
				on p.Employee_ID=a.Employee_ID
			left join
				orion.employee_donations as d
				on d.employee_id=p.employee_id
/*Select only macro gender employees, use a list in case of errors in the data, use the macros to define the start and end dates, take only employees without a termination date*/
			where employee_gender = "%substr(&Gender,1,1)" and employee_hire_date between "&startdt"d and "&enddt"d and not employee_term_date
	;
quit;
/*Print the results, add a footnote*/
title "Donations of " "&Gender" " Employees Hired between " "&startdt" " and " "&enddt";
footnote "&syslast";
*Print the data table to the output;
proc sql;
	select *
/*Use a substr to take the last 4 chars of the startdt to get the year*/
	from &outlib..&gender.%substr(&startdt,6);
quit;
/*Housekeeping*/
title;
footnote;
%mend;

*Part 5
Call the macro, no semicolon required!;
%donations(homework, male, 01Jan1974, 30Jun1974)

*Part 6;
*Set the mstored option to allow saving of macros and the sasmstore to specify the permanent library;
options mstored SASMSTORE=homework;
*use the /store option to store the macro in the permanent data library;
%macro donations(outlib, gender, startdt, enddt) /store;
*Code from homework 8 with hardcoded variables replaced with macro variables;
*Use two outer left joins to combine the 3 tables on the common Employee_ID key;
*Use the propcase inside of sysfunc to apply the function to gender, assuring the first letter is capitalized;
%let gender=%sysfunc(propcase(&gender));
proc sql;
/*Use a substr to take the last 4 chars of the startdt to get the year*/
	create table &outlib..&gender.%substr(&startdt,6) as
		select p.Employee_ID label='ID', Employee_Name label='Name', Salary format dollar8., Qtr1, Qtr2, Qtr3, Qtr4, sum(qtr1,qtr2,qtr3,qtr4) as total_donation label='Ann. Donation'
			from orion.employee_payroll as p
			left join
				orion.employee_addresses as a
				on p.Employee_ID=a.Employee_ID
			left join
				orion.employee_donations as d
				on d.employee_id=p.employee_id
/*Select only macro gender employees, use a list in case of errors in the data, use the macros to define the start and end dates, take only employees without a termination date*/
			where employee_gender = "%substr(&Gender,1,1)" and employee_hire_date between "&startdt"d and "&enddt"d and not employee_term_date
	;
quit;
/*Print the results, add a footnote*/
title "Donations of " "&Gender" " Employees Hired between " "&startdt" " and " "&enddt";
footnote "&syslast";
proc sql;
	select *
/*Use a substr to take the last 4 chars of the enddt to get the year*/
	from &outlib..&gender.%substr(&startdt,6);
quit;
/*Housekeeping*/
title;
footnote;
%mend;

*Part 7;
*Use proc catalog to print a list of the complied macros in my permanent library;
proc catalog cat=homework.sasmacr;
	contents;
	title "Complied Macros in My Permanent Library";
quit;

*Close the pdf and housekeeping;
ods pdf close;
title;
footnote;
