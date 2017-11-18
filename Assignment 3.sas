/*************************************************************************
Author: Chris Berardi
Creation Date: 1/22/17
Program Name: Assignment 3
Program Location: C:\Users\Saistout\Desktop\657\homework\Assignment3.sas
Last Run Date: 1/25/17
Purpose: To compelete Assignment 3 for STAT657, Spring 2017
************************************************************************/

*Part 1;
*Create a libref for the folder containing the SQL course data (i.e. orion data);
libname orion "C:\Users\Saistout\Desktop\657\homework\data\SQL_Files" access=readonly;

*Create a libref for the folder containing the Unicornstaff data;
libname unicorn "C:\Users\Saistout\Desktop\657\homework\data\" access=readonly;

*Create a libref for the output from running this program;
libname output "C:\Users\Saistout\Desktop\657\homework\output";

*Create  filerefs for the two output files;
filename outputA "C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW03_outputA.pdf";
filename outputB "C:\Users\Saistout\Desktop\657\homework\output\Chris.Berardi_HW03_outputB.pdf";

*Part 2
*Create a format to display genders as M or F or Unknown;
proc format; 
	value $gender 'M'='Male'
				  'm'='Male'
				  'F'='Female'
				  'f'='Female'
				  other = 'Unknown';
run;

*Create a format to display salary as Very Low to Very High;
proc format;
	value salary      low-26000 = "Very Low"
				   26000<-50000 = "Low"
				   50000<-75000 = "Medium"
				 75000<-100000 = "High"
				 100000<-high   = "Very High";
run;

*Part 3;
*Use proc template to send a list of all availible styles to the default
ouput distination;
proc template;
	list styles;
run;

*Part 4;
*Close all open ODS destinations;
ods _all_ close;

*Open two ods pdf destinations for the program output;
ods pdf (ID=outA) file=outputA bookmarkgen=no;
ods pdf (ID=outB) file=outputB style=FancyPrinter bookmarklist=hide;

*Part 5;
*Define headers and footnotes according to output provided;
title1 'Data Sets Available from Orion';
title3 'For Use by Acquistion Group';
footnote1 'Note:  This output is being sent to two separate documents.';

*Diplay a list of all data sets in the Orion data library, suppress the details
for each data set;
proc contents data=orion._all_ nods;
run;

*Part 6;
*Turn off priting of the date at the top of the output;
option nodate;

*Part 7;
*Change the titles to correspond to the output provided;
title1 'Analysis of Unicorn Athletics Staff List';
title2 "Layout of Data Recovered from CEO's Laptop";
*Print the descriptor potion of the unicornstaff data;
proc contents data=unicorn.unicornstaff;
run;

*Part 8;
*Close the outputA desintion;
ods pdf (ID=outA) close;

*Part 9;
*Redefine the titles to what is seen in the ouput;
title2;
title3 'Unicorn Emplyees Still Working';
*Clear footnotes;
footnote;

*Print out the Employee Id, Hire Date, Salary and Gender variables from the unicornstaff data set. Suppress observation and use labels.;
proc print data=unicorn.unicornstaff noobs label;
	var Emp_ID Hire_dt Job_Title Salary Gender;
	*Use the formats defined earlier for salary and gender, use the mmddyy10. format to make hire date
	appear like the requried output.;
	format gender $gender. salary salary. hire_dt mmddyy10.; 
	*Change the Hire_dt and salary labels to correspond to what is needed for the output;
	label Hire_dt = 'Hire Date' salary = 'Salary Level';
	*Use the Term_Dt variable to select only employees still with the company for output as TrueUnicorn variable contains errors;
	where Term_Dt IS NULL;
run;

*Part 10;
*Close the second output;
ods pdf (outB) close;

*Clear all footnotes and titles;
title;
footnote;
