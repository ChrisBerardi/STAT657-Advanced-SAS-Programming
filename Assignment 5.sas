/*************************************************************************
Author: Chris Berardi
Creation Date: 2/8/17
Program Name: Assignment 5
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment5.sas
Last Run Date: 2/11/17
Purpose: To compelete Assignment 5 for STAT657, Spring 2017
************************************************************************/

*Part 1;
*Assign a libref for the folder containing the homework data make the folder read-only;
libname ncaa "C:\Users\Saistout\Desktop\657\homework\data\" access=readonly;

*Assign a fileref for the output file;
filename output "C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW05_output.pdf";

*Turn off page numbering in the output;
options nonumber;

*Part 2;
*Create a new table, scoring3 with the player, team, regio and PPG
columns from scholarship03 dataset;
proc sql;
	create table scoring03 as
		select player, 
			   team, 
			   region, 
			   ppg, 
	 /*Create a 5th column that is the mean of of tournament PPG.
		Since the select statement contains a summary statistic and columns not summarized, this 
	    column will be remegered with the data*/
			   mean(ppg) as tourPPG
		from ncaa.scholarship03
/* Exclude those teams that are seeded lower than 14*/
		where seed_ lt 15;
quit;

*Part3;
*Open the ods pdf output to the fileref destination
Set the style to minimal and the use the startpage option to set the second query to print below the first on the same page;
ods pdf file=output style=minimal startpage=no;

*Define the escapechar to add in empty lines and center text later;
ods escapechar='^';

proc sql;
/*Create the Average State School Scholarship report*/
/*Give the appropriate title*/
title'Average Scholarships for State Schools';
	select Player, 
		   Team,
	/*Since proc sql does not allow lists, use each column name, give the correct label and format*/
		   sum(amt1,amt2,amt3,amt4,amt5,amt6,amt7,amt8,amt9,amt10) as totSchol label="Total Scholarship" format=dollar7., 
	/*Since proc sql does not allow lists, use each column name, give the correct label and format*/
		   max(amt1,amt2,amt3,amt4,amt5,amt6,amt7,amt8,amt9,amt10) as maxSchol label="Maximum Scholarship" format=dollar6., 
	/*Count the number of non-emtpy columns using n, since count will not work for 10 columns, give the correct label*/
		   n(amt1,amt2,amt3,amt4,amt5,amt6,amt7,amt8,amt9,amt10) as numSchol label="Scholarships"
	from ncaa.scholarship03
	/*Take only those player that have more than one scholarship*/
	where calculated numSchol gt 1 and
	/*Since Stanford and St.Jonhs have 'St' at the start of the word, look for St after the 3rd position
	  Take only those school where those letters are found*/
		  find(Team,"St",3) >0
	/*Order by team then by descending total Scholarship*/
	order by team, totSchol desc
    ;
*Part 4;
*Add two blank lines between the last report and the title for the second report using the escape char;
ods text='^2n';
/*Add the "title" text for the second report on the first page, center the text*/
ods text='^{style [textalign=c] 2003 NCAA Team Scoring Analysis}';
/*Create the desired title*/
title'2003 NCAA Team Scoring Analysis';
	select team,
		/*Use the count function to determine the number of per team*/
		   count(team) as number label="Players",
		/*Take the average ppg, the group by team clause will make this the average per team*/
		   avg(ppg) as avg_ppg label='Average PPG' format=4.1,
		/*Determine the average team ppg as a percentage of the average tournament ppg*/
		   calculated avg_ppg/tourppg as team_avg_per label='Team vs. Overall' format=percent8.1,
		/*Use a case statement to assign an above or below average value for each team average ppg*/
		   case 
			when calculated team_avg_per > 1 then 'Above Avg.'
			else 'Avg. or Below'
		   end as ppg_over label='PPG Level'
	from scoring03
	/*Group by team to cause the average to be calculated by team, and by tourppg to prevent remerging*/
	group by team, tourppg
	/*Take only teams with 5 players*/
	having number > 4
	/*Output from highest to lowest average team ppg*/
	order by avg_ppg desc
 ;
quit;

*Close the pdf ods to create the file;
ods pdf close;

*Housekeeping;
title;
footnote;
