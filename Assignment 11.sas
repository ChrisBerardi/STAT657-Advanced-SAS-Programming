/*************************************************************************
Author: Chris Berardi
Creation Date: 4/13/17
Program Name: Assignment 11
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment11.sas
Last Run Date: 4/14/17
Purpose: To complete Assignment 11 for STAT657, Spring 2017
************************************************************************/

*Assign librefs and filerefs;
libname orion 'C:\Users\Saistout\Desktop\657\homework\data\SQL_Files' access=readonly;
libname ncaa 'C:\Users\Saistout\Desktop\657\homework\data' access=readonly;
filename output 'C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW11_output.pdf';


*open pdf;
ods pdf file=output bookmarkgen=no;

*Part 1;
*Use the three macro options to show macro resolution, code and execution;
options symbolgen mprint mlogic;

*Part 2-5;
*All comments are for this assignment only;

*Make startdt and enddt positional, so they go first, the other two are keyword;
%macro donations(startdt, enddt, outlib=WORK, gender=Female);
%let gender=%sysfunc(propcase(&gender));
proc sql;
	create table &outlib..&gender.%substr(&startdt,6) as
		select p.Employee_ID label='ID', Employee_Name label='Name', Salary format dollar8., Qtr1, Qtr2, Qtr3, Qtr4, sum(qtr1,qtr2,qtr3,qtr4) as total_donation label='Ann. Donation'
			from orion.employee_payroll as p
			left join
				orion.employee_addresses as a
				on p.Employee_ID=a.Employee_ID
			left join
				orion.employee_donations as d
				on d.employee_id=p.employee_id
/*Use make macro logic to create two different where commands, one for if there is an endt date, one without an end date
Use the ne operator since to check if enddy exists*/
			%if &enddt ne %then %do;
				where employee_gender = "%substr(&Gender,1,1)" and employee_hire_date between "&startdt"d and "&enddt"d and not employee_term_date
			%end;
			%else %do;
/*If there is not end date change the between to greater than to select all employess hired after that date*/
				where employee_gender = "%substr(&Gender,1,1)" and employee_hire_date ge "&startdt"d and not employee_term_date
			%end;
	;
quit;
/*Use macro logic to change the title based on the existance of the enddt parameter*/
%if &enddt ne %then %do;
	title "Donations of " "&Gender" " Employees Hired between " "&startdt" " and " "&enddt";
%end;
%else %do;
	title "Donations of &Gender Employees Hired on or after &startdt";
%end;

footnote "&syslast";
proc sql;
	select *
	from &outlib..&gender.%substr(&startdt,6);
quit;

title;
footnote;
%mend;

*Part 6;
*Call the macro specifying only the first parameter;
%donations(01Jan2004)

*Part 7;
*Call the macro for male employess hired between 01Jan2000 and 31Dec2006;
%donations(01Jan2000,31Dec2006,gender=Male)

*Part 8;
*Create a table using the ncaam06 dataset;
proc sql;
	create table ncaa06 as
	select seed, school, region, player, ppg, rpg
	from ncaa.ncaam06
/*Use the group by and the count() to select only schools with more than 5 players listed*/
		group by school
		having count(player) ge 5;
quit;


*Part 9;
*Create a data driven macro that will create separate reports for each region;
*Create each part outside of the macro first then replace hardcoding with macro variables;
%macro region (dataset);
/*Use proc sql to create a table containing an unduplicated list of region names*/
	proc sql;
		create table regions as
			select unique region
			from &dataset;
	quit;

/*Use a data step to create macro variables for each region*/
	data _null_;
		set regions end=no_more;
		call symputx('region'||left(_n_),region);
/*Will rewrite the &num_region each interation of the data step, ending with the number of regions*/
        call symputx('num_region',_n_);
	run;

/*Use a macro loop to generate the code needed to produce the &num_region number of loops*/
	%do i=1 %to &num_region;
		proc report data=&dataset nowd;
/*Indirect reference to regions based on the naming convention created in the data step above*/
			where region ="&&region&i";
			columns ("Region = &&region&i" seed school ppg rpg);
			define seed / group 'Seed';
			define school /group 'Team';
			define ppg /mean format=8.1 'Average Points';
			define rpg / mean format=8.1 'Average Rebounds';
		run;
	%end;
%mend;
*Call the macro to generate the reports;
%region(ncaa06)

*Housekeeping;
ods pdf close;
footnote;
title;
