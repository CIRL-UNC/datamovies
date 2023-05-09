****************************
Producing Data Movies in SAS

Authors:
Lauren C. Zalla, Department of Epidemiology, Johns Hopkins Bloomberg School of Public Health (lzalla1@jhu.edu)
Jacqueline E. Rudolph, Department of Epidemiology, Johns Hopkins Bloomberg School of Public Health

Last Update:
January 21, 2023
****************************

Steps:

(1) Download and import the example data and annotation dataset. The annotation dataset controls the placement and appearance of text, images, etc. that are overlaid on the plot space.
(2) Generate an attribute map to ensure consistent attributes (colors, ordering of groups, etc.) across all frames.
(4) Run the code below to produce the desired type of data movie.

Notes:

The code below supports histograms, line plots, and butterfly plots, but can be modified to produce other types of data movies.
The .svg file format has a 'pause' feature, and is supported by most browsers. Movies can also be output in .gif format by changing <printerpath=svg> to <printerpath=gif>.
The example data are publicly available from https://www.cdc.gov/nchhstp/atlas/index.htm
The example data movies are simplified versions of those published in: https://doi.org/10.2105/AJPH.2020.306131
;

%let filepath=C:\Users\lcz3\OneDrive - University of North Carolina at Chapel Hill\Papers\Data Movies;

*Example Data; proc import datafile="&filepath.\AtlasPlusTableData.csv" out=data dbms=csv replace; guessingrows=1000; getnames=yes; run;
*Annotation Dataset; proc import datafile="&filepath.\anno.xlsx" out=anno dbms=xlsx replace; run;
*Attribute Map;
data attrmap;
retain show "attrmap";
input id $1-6 value $9-30 linecolor $33-40;
fillcolor=linecolor;
linethickness=2;
datalines;
raceth  Black/African American  CX34ACE0
raceth  Hispanic/Latino         CXFFB142
raceth  White                   CXFF5252
;
run;

******************
Type I: Histogram;

%macro histogram (start=,end=);

%DO year=&start. %TO &end.;
data anno&year.; set anno; where year=&year.; run;

	%IF &year.=&start. OR &year.=&end. %THEN %DO copy=1 %TO 8;
	proc sgpanel data=data dattrmap=attrmap sganno=anno&year.;
		where year=&year. and raceth in("Black/African American","Hispanic/Latino","White");
		panelby sex / columns=2 headerattrs=(size=12) spacing=25 novarname noheaderborder noborder;
		vbar age / stat=sum response=diagnoses group=raceth attrid=raceth barwidth=0.9 grouporder=data;
		rowaxis label="Number of HIV Diagnoses" values=(0 to 12000 by 2000)  labelattrs=(size=11) valueattrs=(size=11) offsetmin=0;
		colaxis label="Age Group" type=discrete labelattrs=(size=9) valueattrs=(size=9);
		title height=12pt "Evolving Demographics of US HIV Diagnoses";
		footnote height=10pt justify=center  "Data from the CDC's AtlasPlus Tool";
		footnote2 height=8pt justify=center "Data movie produced for demonstration purposes only. Diagnoses among Asian, American Indian/Alaska Native, Native Hawaiian/Pacific Islander, and multiracial individuals not shown.";
		keylegend / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) down=1 position=bottom title="";
	run;
	%END;
	%ELSE %DO;
	proc sgpanel data=data dattrmap=attrmap sganno=anno&year.;
		where year=&year. and raceth in("Black/African American","Hispanic/Latino","White");
		panelby sex / columns=2 headerattrs=(size=12) spacing=25 novarname noheaderborder noborder;
		vbar age / stat=sum response=diagnoses group=raceth attrid=raceth barwidth=0.9 grouporder=data;
		rowaxis label="Number of HIV Diagnoses" values=(0 to 12000 by 2000) labelattrs=(size=11) valueattrs=(size=11) offsetmin=0;
		colaxis label="Age Group" type=discrete labelattrs=(size=9) valueattrs=(size=9);
		title height=12pt "Evolving Demographics of US HIV Diagnoses";
		footnote height=10pt justify=center  "Data from the CDC's AtlasPlus Tool";
		footnote2 height=8pt justify=center "Data movie produced for demonstration purposes only. Diagnoses among Asian, American Indian/Alaska Native, Native Hawaiian/Pacific Islander, and multiracial individuals not shown.";
		keylegend / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) down=1 position=bottom title="";
	run;
	%END;
%END;
%mend histogram;


OPTIONS papersize=("7 in", "6 in") printerpath=svg animation=start animduration=0.250 animloop=yes noanimoverlay nodate nonumber; 
ODS PRINTER file="&filepath.\histogram.svg";
ODS GRAPHICS on / width=7in height=6in imagefmt=gif noborder;
%histogram(start=2008,end=2019);
OPTIONS printerpath=svg animation=stop;
ODS PRINTER close;


******************
Type II: Line Plot;

%macro line (start=,end=);

%DO year=&start. %TO &end.;
data anno&year.; set anno; where year=&year.; run;

	%IF &year.=&start. OR &year.=&end. %THEN %DO copy=1 %TO 8;
	proc sgpanel data=data dattrmap=attrmap sganno=anno&year.; 
		where year=&year. and raceth in("Black/African American","Hispanic/Latino","White");
		panelby sex / columns=2 headerattrs=(size=12) spacing=25 novarname noheaderborder noborder;
		series x=age y=rate / group=raceth attrid=raceth grouporder=data lineattrs=(thickness=4 pattern=solid);
		rowaxis label="HIV Diagnoses per 100,000 Population" values=(0 to 150 by 25) labelattrs=(size=10) valueattrs=(size=10) offsetmin=0;
		colaxis label="Age Group" type=discrete labelattrs=(size=9) valueattrs=(size=9);
		title height=12pt "Evolving Demographics of US HIV Diagnoses";
		footnote1 height=10pt justify=center "Data from the CDC's AtlasPlus Tool";
		footnote2 height=8pt justify=center "Data movie produced for demonstration purposes only. Diagnosis rates among Asian, American Indian/Alaska Native, Native Hawaiian/Pacific Islander, and multiracial individuals not shown.";
		keylegend / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) position=bottom title=""; 
	run;
	%END;
	%ELSE %DO;
	proc sgpanel data=data dattrmap=attrmap sganno=anno&year.; 
		where year=&year. and raceth in("Black/African American","Hispanic/Latino","White");
		panelby sex / columns=2 headerattrs=(size=12) spacing=25 novarname noheaderborder noborder;
		series x=age y=rate / group=raceth attrid=raceth grouporder=data lineattrs=(thickness=4 pattern=solid);
		rowaxis label="HIV Diagnoses per 100,000 Population" values=(0 to 150 by 25) labelattrs=(size=10) valueattrs=(size=10) offsetmin=0;
		colaxis label="Age Group" type=discrete labelattrs=(size=9) valueattrs=(size=9);
		title height=12pt "Evolving Demographics of US HIV Diagnoses";
		footnote1 height=10pt justify=center "Data from the CDC's AtlasPlus Tool";
		footnote2 height=8pt justify=center "Data movie produced for demonstration purposes only. Diagnosis rates among Asian, American Indian/Alaska Native, Native Hawaiian/Pacific Islander, and multiracial individuals not shown.";
		keylegend / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) position=bottom title=""; 
	run;
	%END;
%END;
%mend line;

OPTIONS papersize=("7 in", "6 in") printerpath=svg animation=start animduration=0.250 animloop=yes noanimoverlay nodate nonumber; 
ODS PRINTER file="&filepath.\line.svg";
ODS GRAPHICS / width=7in height=6in imagefmt=gif noborder;
%line(start=2008,end=2019);
OPTIONS printerpath=svg animation=stop;
ODS PRINTER close;


******************
Type III: Butterfly Plot;

data data; set data;
if sex="Female" then diagnoses1=-1*diagnoses; else diagnoses1=.;
if sex="Male" then diagnoses2=diagnoses; else diagnoses2=.;
run;
proc format;
picture positive
low-<0='0000'
0<-high='0000';
run;

*Annotation Dataset; proc import datafile="&filepath.\anno.xlsx" out=anno dbms=xlsx replace; run;
proc print data=data (obs=10); run;
%macro butterfly (start=,end=);

%DO year=&start. %TO &end.;
data anno&year.; set anno; where year in(&year.,.); run;

	%IF &year.=&start. OR &year.=&end. %THEN %DO copy=1 %TO 8;
	proc sgpanel data=data dattrmap=attrmap sganno=anno&year.; 
		where year=&year. and age ne "55+" and raceth in("Black/African American","Hispanic/Latino","White");
		panelby age / columns=2 spacing=25 novarname noheader noheaderborder noborder;
		hbarparm category=raceth response=diagnoses1 / group=raceth attrid=raceth barwidth=0.6 name = 'diagnoses1' grouporder=data;
		hbarparm category=raceth response=diagnoses2 / group=raceth attrid=raceth barwidth=0.6 grouporder=data;
		format diagnoses1 diagnoses2 positive.; 
		colaxis label="Number of HIV Diagnoses" values=(-2500 to 5000 by 2500) labelattrs=(size=11) valueattrs=(size=11) offsetmin=0.05 offsetmax=0.05;
		rowaxis display=(nolabel noticks novalues);
		title height=12pt "Evolving Demographics of US HIV Diagnoses";
		footnote1 height=10pt justify=center "Data from the CDC's AtlasPlus Tool";
		footnote2 height=8pt justify=center "Data movie produced for demonstration purposes only. Diagnoses among Asian, American Indian/Alaska Native, Native Hawaiian/Pacific Islander, and multiracial individuals and all individuals ages 55+ not shown.";
		keylegend 'diagnoses1' / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) down=1 position=bottom title="";
	run;
	%END;
	%ELSE %DO;
	proc sgpanel data=data dattrmap=attrmap sganno=anno&year.; 
		where year=&year. and age ne "55+" and raceth in("Black/African American","Hispanic/Latino","White");
		panelby age / columns=2 spacing=25 novarname noheader noheaderborder noborder;
		hbarparm category=raceth response=diagnoses1 / group=raceth attrid=raceth barwidth=0.6 name = 'diagnoses1' grouporder=data;
		hbarparm category=raceth response=diagnoses2 / group=raceth attrid=raceth barwidth=0.6 grouporder=data;
		format diagnoses1 diagnoses2 positive.; 
		colaxis label="Number of HIV Diagnoses" values=(-2500 to 5000 by 2500) labelattrs=(size=11) valueattrs=(size=11) offsetmin=0.05 offsetmax=0.05;
		rowaxis display=(nolabel noticks novalues);
		title height=12pt "Evolving Demographics of US HIV Diagnoses";
		footnote1 height=10pt justify=center "Data from the CDC's AtlasPlus Tool";
		footnote2 height=8pt justify=center "Data movie produced for demonstration purposes only. Diagnoses among Asian, American Indian/Alaska Native, Native Hawaiian/Pacific Islander, and multiracial individuals and all individuals ages 55+ not shown.";
		keylegend 'diagnoses1' / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) down=1 position=bottom title="";
	run;
	%END;
%END;
%mend butterfly;

OPTIONS papersize=("7 in", "6 in") printerpath=svg animation=start animduration=0.250 animloop=yes noanimoverlay nodate nonumber; 
ODS PRINTER file="&filepath.\butterfly.svg";
ODS GRAPHICS / width=7in height=6in imagefmt=gif noborder;
%butterfly(start=2008,end=2019);
OPTIONS printerpath=svg animation=stop;
ODS PRINTER close;
