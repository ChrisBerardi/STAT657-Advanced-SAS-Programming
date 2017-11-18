/*************************************************************************
Author: Chris Berardi
Creation Date: 4/17/17
Program Name: Assignment 12
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment12.sas
Last Run Date: 4/19/17
Purpose: To complete Assignment 12 for STAT657, Spring 2017
************************************************************************/

*Assign librefs and filerefs;
libname ncaa 'C:\Users\Saistout\Desktop\657\homework\data' access=readonly;
filename output 'C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW12_output.pdf';

*Options to display macro things to the log;
options symbolgen mprint mlogic;

*open pdf and set the options to match the desired output;
option nonumber;
ods pdf file=output bookmarkgen=no;

*Part 1;
*Part 8 from the last assignment copied with no changes;
proc sql;
	create table ncaa06 as
		select seed, school, region, player, ppg, rpg
		from ncaa.ncaam06
		group by school
		having count(player) ge 5;
quit;

*Part 2;
%macro region(dataset);
/*Suppress the output to prevent printing of the first sql query.*/
	proc sql noprint number;
	/*Create a table containing an unduplicated list of region names*/
		create table regions as
			select unique region
			from &dataset;
	/*Create a macro variable that contains the number of regions from &sqlobs*/
		%let num_region= &sqlobs;
	/*Create a macro variable for each region using the form region1 etc. use the &num_region to 
	define the number of regions.*/
		select region into :region1-:region&num_region
		from regions;
	/*Turn on priting to print the desired reports*/
		reset print;
	/*Use a loop to process the query for each region*/
		%do i=1 %to &num_region;
	/*Use indirection reference to the reigon name*/
			title"Team Statistics for the &&region&i Region";
	/*Create labels for all of the colunms and formats use the distinct option 
	to prevent repeats in the output for school*/
			select distinct school label='Team', 
				avg(ppg) label='Average Points' format=8.1 as avgp, 
				avg(rpg) label='Average Rebounds' format=8.1 as avgr
			from ncaa06
	/*Find only the current region*/
			where region = "&&region&i"
	/*Group by school to calculate the averages for the school*/
			group by school
	/*Order by seed to get the desired output order*/
			order by seed;
		%end;	
	quit;
	/*Housekeeping*/
	title;
%mend;

*Call macro;
%region(ncaa06)

*Part 3;
*Set the outobs option to return only the top 20;
proc sql outobs=20;
	title'Top 20 Scorers';
	select Player label='Name', PPG label='Points', School label='Team', Region, Seed
	from ncaa.ncaam06
/*Order by ppg descending to get the 20 highest when combined with outobs*/
	order by ppg desc;
quit;

*Part 4;
%macro rebound(region, n_rebound=7);
/*Use the %upcase to change the region into all caps*/
	%let region=%upcase(&region);
/*Create a table with the selected region and a # of rebounds ge to the parameter value*/
	data rebounds;
		set ncaa.ncaam06;
		where region="&region" and rpg ge &n_rebound;
	run;
/*Use the vtable view, using the nobs variable to create a macro variable
that contains the number of observations*/
	proc sql noprint;
		select nobs into :num_obs
		from sashelp.vtable
		where memname="REBOUNDS";
	quit;
	title"Players from the &region Region Averaging &n_rebound or More Rebounds Per Game";
/*If there are no observation, print that as text to the pdf
Use startpagenow to force a page break*/
	%if &num_obs eq 0 %then %do;
		ods pdf startpage=now;
		ods pdf text ="No players from &region average &n_rebound or more rebounds per game.";
	%end;
	%else %do;
/*Use another startpagenow to force a pagebreak*/
		ods pdf startpage=now;
		proc sql number;
			select Player label='Name', RPG label='Rebounds' format=8.1, School label='Team', Seed
			from rebounds
			order by rpg desc;
		quit;	
	%end;
%mend;
*Call the macros;
%rebound(wdc, n_rebound=10)
%rebound(ATL)

*Housekeeping;
ods pdf close;
title;
footnote;
