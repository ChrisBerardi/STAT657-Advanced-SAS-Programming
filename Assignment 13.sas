/*************************************************************************
Author: Chris Berardi
Creation Date: 4/23/17
Program Name: Assignment 13
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment13.sas
Last Run Date: 4/28/17
Purpose: To complete Assignment 13 for STAT657, Spring 2017
************************************************************************/

*Set msglevel to i to print additional index info to the log;
options msglevel=I nodate nonumber;

*Assign librefs and filerefs;
libname ncaa 'C:\Users\Saistout\Desktop\657\homework\data' access=readonly;
filename output 'C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW13_output.pdf';

*Open pdf output;
ods pdf file=output bookmarkgen=no;

*Part 1;
proc sql;
	create table team as
/*Use put to change change seed_ into a char, make certain to allow two spaces for the NA
Unique option to select only one per team*/
	select unique Team as start, put(seed_,2.) as label, '$seednum' as FmtName
	from ncaa.ncaam04;
/*Use insert into to add a row to the table*/
	insert into Team values ('other','NA','$seednum');
quit;
*Use the table created above along with the cntlin option to create a format from the table
Print the documentation for the format with a fmtlib option;
proc format cntlin=team fmtlib;
run;

*Part 2;
*When defining the format, make sure to leave a space for the parenthesis in the prefix
For the High use 99.9 since all the values must have two digits
For medium use a 0 since some will not, leave a space to allow for the parenthesis
For low only one digit, leave a space for the parenthesis;
proc format; 
	picture ppg 
	15-high = '99.9)' (prefix='High(')
	7.7-15 = ' 09.9)' (prefix='Medium(')
	low-7.7 = ' 9.9)' (prefix='Low(');
run;

*Part 3;
*Use proc datasets to copy the ncaam06 to the work library
Use nolist to suppress printing the dataset creation to the output window;
proc datasets nolist;
	copy in=ncaa out=work;
	select ncaam06;
quit;
run;

*Part 4;
proc sql;
/*Use alter table to add columns and change column properties*/
	alter table ncaam06
		add ppgR char(19) label='PPG Rating' 
		add seed04 char(2) label='2004 Seeding'
		modify school char(19) format=$19.;
/*Use update to populate the column, using insert would add them at the bottom*/
	update ncaam06 
		set ppgR = put(ppg,ppg.);
/*Since we want to change specific value use a case, then picking out the first word 
(which are unique for what we want to change)*/
	update ncaam06
		set school =
			case(scan(School,1))
				when 'Indania' then 'Indiana'
				when 'Boston' then 'Boston College'
				when 'George' then 'George Mason'
				when 'Oral' then 'Oral Roberts'
				when 'Wisc' then 'Wisconsin Milwaukee'
/*If it doesn't need to get fixed preserve the correct value*/
				else school
			end;
/*Populate the seed column using the format from Part 1*/
	update ncaam06
		set seed04 = put(school,$seednum.);
quit;

*Part 5;
*Use sql to create the index without reinitializing data set;
proc sql;
	create index athlete
	on ncaam06 (player,school,region);
quit;

*Use proc contents to print the descriptor portion of the data set;
title'Descriptor Portion of ncaam06';
proc contents data=ncaam06;
run;

*Part 6;
/******************************************************************************
A. An index is used for this step, the variable used is the first key variable 
in the index. This is not the most efficient action since to be optimal, at least
2 keys from a composite index must be used.
******************************************************************************/
proc print data=ncaam06 (idxwhere=yes) label;
	var Player School Region Seed ppgR seed04;
	title '6a. IDXWHERE on Player';	
	where player in ('Steve Burtt', 'Jared Dudley', 'Stanley Burrell');
run;

/******************************************************************************
B. Since school is not the first key variable in the index, it cannot be used
to optimize this query, so there is no index that can optimize this clause.
******************************************************************************/
proc print data=ncaam06(idxwhere=yes) label;
	var Player School Region Seed ppgR seed04;
	title '6a. IDXWHERE on School';	
	where school='Texas';
run;

/******************************************************************************
C. Since school is not the first key variable in the index, it cannot be used
to optimize this query even if we try to force to SAS to.
******************************************************************************/
proc print data=ncaam06(idxname=athlete) label;
	var Player School Region Seed ppgR seed04;
	title '6c. IDXNAME on School';	
	where school='Texas';
run;

/******************************************************************************
D. Since this where clause uses the first two keys it will work. However it is
not optimized since the where clause conditions are not connected by an and.
******************************************************************************/
proc print data=ncaam06(idxwhere=yes) label;
	var Player School Region Seed ppgR seed04;
	title '6d. IDXWHERE on Player or School';	
	where player in ('Steve Burtt', 'Jared Dudley', 'Stanley Burrell') or school='Indiana';
run;

/******************************************************************************
E. Since this where clause uses the first two keys it will work. This where clause
is optimized since it uses a substr starting on the first char and and in condition
and those two conditions are joined by an and. Therefore all conditions for optimal
index processing are satisfied. 
******************************************************************************/
proc print data=ncaam06(idxwhere=yes) label ;
	var Player School Region Seed ppgR seed04;
	title '6e. IDXWHERE on Player and School';	
	where substr(player,1,1)='S' and school in ('Duke', 'Oral Roberts', 'Iona', 'Boston College', 'Gonzaga');
run;

*Housekeeping;
ods pdf close;
title;
footnote;
