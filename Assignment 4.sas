/*************************************************************************
Author: Chris Berardi
Creation Date: 1/29/17
Program Name: Assignment 4
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment4.sas
Last Run Date: 2/4/17
Purpose: To complete Assignment 4 for STAT657, Spring 2017
************************************************************************/

*Part 1;
*Create a libref for the folder containing the SQL course data (i.e. orion data);
libname ncaa "C:\Users\Saistout\Desktop\657\homework\data\" access=readonly;

*Create  filerefs for the output file;
filename outpdf "C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW04_output.pdf";

*Part2;
*Open a pdf destination for the output, hide bookmarks and apply the analysis style
Use the style Prof. K used to make checking the ouput against his easier;
ods pdf file=outpdf bookmarklist=hide style=ocean;

*Part3;
*Concatenate NCAA03 and NCAA04 into NCAA0304 using a data step;
data NCAA0304;
	set ncaa.NCAAM03 ncaa.NCAAM04;
run;

*Part4;
*Use PROC SQL to print the data portion of the new data set with the headnotes and footnotes shown in the desired output;
proc SQL;
	title1 "Top Teams from 2003 and 2004 Men's NCAA Tournaments"; 
	title2 "Concatenated Data";
	select * 
	from ncaa0304;
quit;


*Part 5;
*Interleave NCAA03 and NCAA04;
*Sort both data sets by player name then by team name to prepare to interleave;
proc sort data=ncaa.Ncaam03 out=ncaa03sort;
	by player team;
run;

proc sort data=ncaa.ncaam04 out=ncaa04sort;
	by player team;
run;

*Interleave the data by player and the by team;
data NCAA0304Inter;
	set NCAA03sort NCAA04sort;
	by Player team;
*Remove the variables not in each data set;
	drop F3 Region;
run;

*Redefine the second title to match what is in the desired output;
title2 'First 30 Records of Interleaved Data';

*Part 6;
*Print out the first 30 observations of the interleaved data set;
proc print data=NCAA0304Inter (obs=30);	
run;	


*Part 7;
*Using the sorted data sets NCAA03sort and NCAA04sort match merge by player
Use a in= option create a temporary variable to determine which tournament a player was in;
data ncaa0304Both;
	merge ncaa03sort (in=nc03) 
		  ncaa04sort (in=nc04);
	by player team;
*Only output players that were in both tournaments;
	if nc03 and nc04;
*Remove variables not in both data sets;
	drop F3 Region;
run;

*Part 8;
*Use proc sql to print only the Player Team and PPG variables from the merged data set;
proc sql;
	title'Player Who Played in Both 2003 and 2004 Tournaments';
	title3 'NOTE: PPG is from 2004';
	footnote 'The 2004 data set was the second data set in the merge statement';
	select Player, Team, PPG
	from ncaa0304both
/*Order by ppg in descedning order to make it look like the desired output*/
	order by ppg DESC;
quit;

*Part 9;
*Sort the NCAAM06 data by player then by school, since it uses a different naming convention;
proc sort data=ncaa.ncaam06 out=ncaa06sort;
	by player school;
run;

*Merge the 3 sorted data sets;
data ncaaAll;
*Determined length needed for player with a proc contents step for all ncaa data;
	length player $23;
*Rename the ppg variables, and school to team;
	merge ncaa03sort (rename=(ppg=ppg2003)) 
		  ncaa04sort (rename=(ppg=ppg2004))
		  ncaa06sort (rename=(ppg=ppg2006 school=team));
		by player team;
*Keep only desired variables;
	keep player team ppg2003 ppg2004 ppg2006;
run;

footnote;
*Part 10;
proc sql;
	title "Three-year NCAA Tournament Statistics";
	describe table ncaaAll;
/*Place columns in the order desired in the output*/
	select Player,
		   Team,
/*Label the PPG columns according to desire output*/
		   PPG2003 label='2003 PPG',
		   PPG2004 label='2004 PPG',
		   PPG2006 label='2006 PPG'
	from ncaaAll
	;
quit;

*Part 11;
*Use proc contents to print the descriptor portion of data sets in the work library;
title 'Descriptor Portion of Data Sets in the Work Library';
proc contents data=_all_;
run;

*Part 12;
*Close the pdf destination;
ods pdf close;

*Reset all headers and footnotes;
title;
footnote;
