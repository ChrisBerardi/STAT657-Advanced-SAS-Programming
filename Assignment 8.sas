/*************************************************************************
Author: Chris Berardi
Creation Date: 3/11/17
Program Name: Assignment 8
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment8.sas
Last Run Date: 3/13/17
Purpose: To compelete Assignment 8 for STAT657, Spring 2017
************************************************************************/

*Part 1;
*Remove the date and page numbering to match desired output;
options nonumber nodate;

*Create a fileref for the ouput;
filename out "C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW08_output.pdf";

libname hwdata 'C:\Users\Saistout\Desktop\657\homework\data';
ods pdf file=out  bookmarkgen=no;

*Create 2 macrovariables to avoid hardcoding date boundaries use date constants to define the start and end dates for 2006;
%let start='01JAN2006'd;
%let end = '31DEC2006'd;

*Use two outer left joins to combine the 3 tables on the common Employee_ID key;
proc sql;
create view hwdata.femdonors as
	select p.Employee_ID label='ID', Employee_Name label='Name', Salary format dollar8., Qtr1, Qtr2, Qtr3, Qtr4, sum(qtr1,qtr2,qtr3,qtr4) as total_donation label='Ann. Donation'
		from orion.employee_payroll as p
		left join
			orion.employee_addresses as a
			on p.Employee_ID=a.Employee_ID
		left join
			orion.employee_donations as d
			on d.employee_id=p.employee_id
/*Select only female employees, use a list in case of errors in the data, use the macros to define the start and end dates, take only employees without a termination date*/
		where employee_gender in ('F','f') and employee_hire_date between &start and &end and not employee_term_date
/*A using clause to the orion library will make the view definition portable*/
	using libname orion 'C:\Users\Saistout\Desktop\657\homework\data\SQL_Files';
quit;

*Part 2;
*Use a contents procedure to print the contents of the permanent library use the nods option to suppres the descriptor portion;
proc contents data=hwdata._all_ nods;
run;

*Part 3;
*Use a second proc contents to print the descriptor portion of the view created in step 1;
proc contents data=hwdata.femdonors;
run;

*Part 4;
*Use a describe clause to print the definition of the view from 1 part to the log;
proc sql;
describe view hwdata.femdonors;
quit;

*Part 5;
*Create the desired footnotes and titles;
title 'Donations by Active Female Employees Hired in 2006' ;
footnote 'Output from SQL';

*Use proc sql to print the view;
proc sql;
select *
from hwdata.femdonors;
quit;

*Part 6;
*Create the desired footnotes and titles;
footnote 'Output from Proc Print';

*use proc print to print the view, suppress the numbering of observations;
proc print data=hwdata.femdonors label noobs;
run;

*Housekeeping;
ods pdf close;
title;
footnote;
