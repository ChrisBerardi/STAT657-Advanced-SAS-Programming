/*************************************************************************
Author: Chris Berardi
Creation Date: 2/14/17
Program Name: Assignment 5
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment6.sas
Last Run Date: 2/18/17
Purpose: To compelete Assignment 6 for STAT657, Spring 2017
************************************************************************/

*Assign librefs for the folders containing the homework data make the folder read-only;
libname ncaa "C:\Users\Saistout\Desktop\657\homework\data\" access=readonly;
libname orion "C:\Users\Saistout\Desktop\657\homework\data\SQL_Files" access=readonly;

*Assign a fileref for the output file;
filename output "C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW06_output.pdf";

*Open the pfd output;
options nonumber;
ods pdf file=output bookmarklist=show;

*Part 1;
proc sql;
*Give the correct title;
	title'2003 NCAA Team Scoring Analysis';
	select ncaa.team, 
/* Use the code as in homework 5, add in table aliases*/
		   count(ncaa.team) as players label='Players', 
		   avg(ncaa.ppg) as avg_ppg label='Average PPG' format=4.1,
		   calculated avg_ppg/ppg.avg_ppg_all as team_per label='Team vs. Overall'format=percent8.1,
		   case  
			 when calculated avg_ppg/ppg.avg_ppg_all > 1 then 'Above Avg.'
			 else 'Avg. or Below'
			 end as percent label='PPG Level'
/*Create an in-line view to create the average tournament ppg*/
	from (select mean(ppg) as avg_ppg_all
			from ncaa.scholarship03
			where seed_ lt 15) as ppg,
		  ncaa.scholarship03 as ncaa
/*Remove teams seeded lower than 14*/
	where seed_ lt 15
/* Group by team to calculate the team average correctly and prevent remerging*/
	group by ncaa.team
	having players > 4
	order by avg_ppg desc
	;
quit;
*Reset titles;
title;

*Part 3;
proc sql;
title 'Duplicate Givers';
*Select desired variables or the list;
	select employee_id,
		   employee_name,
		   qtr1,
		   qtr2,
		   qtr3,
		   qtr4,
		   Recipients
	from ncaa.givers
/*Group by employee_name to allow for counting of double names
  The employee_id column contains errors and cannot be used*/
	group by employee_name
/*Choose only employee_names that appear more than once*/
		having count(employee_name) > 1
	;
quit;
title;


*Part4;
proc sql;
title'Active Employees not on Giver List';
/*Select the desired output columns from the payroll and addresses tables*/
	select unique p.Employee_id ,
		    a.employee_name
/*Use a left join with payroll and addresses on the condition that the ids are the same
  to prevent a very unwanted cartesian product*/
	from orion.employee_payroll as p
         left join
		 orion.employee_addresses as a
	on p.employee_id =a.employee_id
/*Use a subquery in the where clause to include those employee ids not found in the giver file
  Also only take employee's whose term date DNE*/
	where p.employee_id not in(select employee_id 
				from ncaa.givers) 
           and not p.employee_term_date 
/*Order by name to match the desired output*/
	order by a.employee_name
	;
quit;
title;

*Part 5;
proc sql;
title'Terminated Givers';
	select p.employee_id label='ID',
		   a.employee_name label='Name',
		   p.employee_gender label='Gender'
/*Perform a left join on id numbers to bring in names*/
	from orion.employee_payroll as p
	left join
		 orion.employee_addresses as a
	on p.employee_id=a.employee_id
/*Take only employee numbers found on the giver list with a termination date*/
	where p.employee_id in (select employee_id 
				from ncaa.givers)
		  and p.employee_term_date
	order by a.employee_name
;
quit;

*Part 6;
proc sql;
title"Orion's Customers Who Bought Products Other Than Shoes";
/*Use the unique keyword to elimate outputting multiple rows for the same product group for a given customer*/
	select unique c.customer_id label='ID',
		   c.customer_name label='Name',
		   c.customer_address label='Address',
           c.country,
		   d.product_group,
		   month(c.birth_date) as Month label='Birth Month'
/*Use two joins to join customer data to order data, then to product data to obtain all desired columns
  The first join is right join since some customers did not order any products, and we only want customers
  that bought something*/
	from orion.customer c
	right join
		orion.order_fact f
		on c.customer_id=f.customer_id
	left join 
		orion.product_dim d
		on d.product_id=f.product_id
/*The word shoe appears in three diferent positions in the data, use the find function to search for it*/
	where not find(d.product_group,'Shoes', ' ')
	order by country, month, customer_name, product_group
	;
quit;

*Close pdf output;
ods pdf close;

*Housekeeping;
title;
footnote;
