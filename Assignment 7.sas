/*************************************************************************
Author: Chris Berardi
Creation Date: 2/20/17
Program Name: Assignment 7
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment7.sas
Last Run Date: 2/22/17
Purpose: To compelete Assignment 7 for STAT657, Spring 2017
************************************************************************/

*Assign librefs for the folders containing the homework data make the folder read-only;
libname ncaa "C:\Users\Saistout\Desktop\657\homework\data\" access=readonly;

*Assign a fileref for the output file;
filename output "C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW07_output.pdf";

*Suppress page numbers and date printing on report;
options nonumber nodate;

*Supress bookmarks in the pdf output;
ods pdf file=output bookmarkgen=no;

*Part 1;
proc sql;
title'Players in Both 2003 and 2004 NCAA Championship Tournaments';
*Create a view of players in both tournaments on the same team name for each tournament using an intersect operator;
	create view playboth as
		select player, team from ncaa.ncaam03
			intersect
		select player, team from ncaa.ncaam04;
*Use a Union set operator to combine the 2003 and 2004 tables using a where clause to take
 only the players in the view from above
 Use an inline-view to add the tournament year to each table;
	select * 
		from 
		(select 2003 as year, team, seed_, player, ppg
		from ncaa.ncaam03
		 where player in (select player from playboth))
	union
	select *
		from 
		(select 2004 as year label='Year', team, seed_, player, ppg
		 from ncaa.ncaam04
		 where player in (select player from playboth))
	order by player, ppg desc
;
quit;
title;

*Part 2;
options date;

proc sql;
title'Comparison of Teams from 2003, 2004, and 2006 NCAA Championship Tournaments';
*Create a view that contains the names of the schools in all tournaments using an intersect operators;
create view in_all_tourn as
	select team
	from ncaa.ncaam03
	intersect
	select team
	from ncaa.ncaam04
	intersect
	select school
	from ncaa.ncaam06;

*Perfrom two union set operation to combine the three data sets, subsetting
 based on the view created above;
*Group by team to correctly calculate the team average ppg;
	select * 
	from (select team, seed_,
			mean(ppg) as avg_ppg label="Average Player PPG" format=4.1,
			2003 as year label="Year"
		 from ncaa.ncaam03
		 where team in(select * from in_all_tourn)
		 group by team)
	union
	select *
		from (select team, seed_,
			mean(ppg) as avg_ppg label="Average Player PPG",
			2004 as year label="Year"
		 from ncaa.ncaam04
		 where team in(select * from in_all_tourn)
		 group by team)
	union
	select *
/*Since this table uses a different name for the team and seed_ columns, create new columns with the desired names
  to allow for the union*/
		from (select school as team, seed as seed_,
			mean(ppg) as avg_ppg label="Average Player PPG",
			2006 as year label="Year"
		 from ncaa.ncaam06
		 where team in(select * from in_all_tourn)
		 group by team)
	order by team, year
;
quit;


ods pdf close;
*Housekeeping;
title;
footnote;
