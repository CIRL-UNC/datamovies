****************************
Producing Data Movies in SAS

Authors:
Lauren C. Zalla, Department of Epidemiology, University of North Carolina at Chapel Hill (zalla@unc.edu)
Jacqueline E. Rudolph, Department of Epidemiology, University of Pittsburgh

Last Update:
August 12, 2020
****************************

Steps:

(1) Prepare the required datasets.
(2) Edit the file paths and text labels in the code below.
(3) Assign the macro variables and run the code to produce the data movie.
(4) Adjust the formatting of the data movie as needed.

Notes:

The code below supports histograms, line plots, and butterfly plots, but can be modified to produce other types of data movies.
The scalable vector graphic (.svg) file format has a 'pause' feature, and is supported by most browsers.
Data movies can also be output in .gif format by changing <printerpath=svg> to <printerpath=gif>.

******************
Type I: Histogram


Datasets Required:

- A dataset containing the integer response variable, a continuous variable defining the time interval, a continuous variable defining the bars of the histogram, and two binary or categorical stratification variables (see variable definitions below).
- An attribute map dataset called 'attrmap'. This dataset controls the color scheme and other properties of the plot. See SAS documentation for details.
- An annotation dataset called 'anno'. This dataset controls the placement and appearance of text and images overlaid on the plot. See SAS documentation for details.

Macro Variables:

- data: name of input dataset
- interval: name of numeric variable indicating time interval (e.g. day, week, quarter)
- start: value of 'interval' at which to start movie
- end: value of 'interval' at which to end movie
- panelby: name of binary or categorical variable by which to panel the histogram (e.g. sex, region)
- xvar: name of continuous variable defining the bars of the histogram (e.g. age group)
- groupvar: name of categorical variable by which to stratify each bar of the histogram (e.g. race, region)
- response: name of variable containing the integer response (e.g. case count, smoothed count)
;

%macro histogram (data=,interval=,start=,end=,panelby=,xvar=,groupvar=,count=);

%DO &interval.=&start. %TO &end.;

	%IF &interval.=&start. OR &interval.=&end. %THEN %DO copy=1 %TO 8;
	proc sgpanel data=&data. dattrmap=attrmap sganno=anno;
		where &interval.=&interval.;
		panelby &panelby. / columns=2 headerattrs=(size=12) spacing=25 novarname noheaderborder noborder;
		vbar &xvar. /stat=sum response=&response. group=&groupvar. attrid=&groupvar. barwidth=0.9 grouporder=data;
		rowaxis label="Response" labelattrs=(size=11) valueattrs=(size=11) offsetmin=0;
		colaxis label="Name of Continuous Variable" type=discrete labelattrs=(size=9) valueattrs=(size=9);
		title height=12pt "Title of Movie";
		footnote height=10pt justify=center  "Data Source";
		keylegend / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) down=1 position=bottom title="";
	run;
	%END;
	%ELSE %DO;
	proc sgpanel data=&data. dattrmap=attrmap sganno=anno; 
		where &interval.=&interval.;
		panelby &panelby. / columns=2 headerattrs=(size=12) spacing=25 novarname noheaderborder noborder;
		vbar &xvar. /stat=sum response=&response. group=&groupvar. attrid=&groupvar. barwidth=0.9 grouporder=data; 
		rowaxis label="Response" labelattrs=(size=11) valueattrs=(size=11) offsetmin=0;
		colaxis label="Name of Continuous Variable" type=discrete labelattrs=(size=9) valueattrs=(size=9);
		title height=12pt "Title of Movie";
		footnote height=10pt justify=center  "Data Source";
		keylegend / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) down=1 position=bottom title="";
	run;
	%END;
%END;
%mend histogram;


OPTIONS papersize=("7 in", "6 in") printerpath=svg animation=start animduration=0.125 animloop=yes noanimoverlay nodate nonumber; 
ODS PRINTER file="filepath\filename.svg";
ODS GRAPHICS on / width=7in height=6in imagefmt=gif noborder;
*assign the macro variables here before running ->; %histogram(data=,interval=,start=,end=,panelby=,xvar=,groupvar=,response=);
OPTIONS printerpath=svg animation=stop;
ODS PRINTER close;


******************
Type II: Line Plot


Datasets Required:

- A dataset containing the continuous response variable, a continous variable defining the time interval, a continuous variable defining the x-axis, and two binary or categorical stratification variables (see variable definitions below).
- An attribute map dataset called 'attrmap'. This dataset controls the color scheme and other properties of the plot. See SAS documentation for details.
- An annotation dataset called 'anno'. This dataset controls the placement and appearance of text and images overlaid on the plot. See SAS documentation for details.

Macro Variables:

- data: name of dataset
- interval: name of numeric variable indicating time interval (e.g. day, week, quarter)
- start: value of 'interval' at which to start movie
- end: value of 'interval' at which to end movie
- panelby: name of binary or categorical variable by which to panel the plot (e.g. sex, region)
- xvar: name of continuous variable defining the points on the line (e.g. age group)
- groupvar: name of categorical variable by which to stratify the line (e.g. race, region)
- response: name of variable containing the continuous response (e.g. risk, rate, count)

Note: This movie can be modified to show color bands instead of lines. Replace the <series> statement with the commented-out <band> statement, and add a numeric dummy variable called 'one' to the dataset taking the value 1;
;

%macro line (data=,interval=,start=,end=,groupvar=);

%DO &interval.=&start. %TO &end.;
	%IF &interval.=&start. OR &interval.=&end. %THEN %DO copy=1 %TO 8;
	proc sgpanel data=&data. dattrmap=attrmap; 
		where &interval.=&interval.;
		panelby &panelby. / columns=2 headerattrs=(size=12) spacing=25 novarname noheaderborder noborder;
		series x=&xvar. y=&response. / group=&groupvar. attrid=&groupvar. grouporder=data lineattrs=(thickness=4 pattern=solid);
		*band x=&xvar. upper=&response lower=one / group=&groupvar. attrid=&groupvar.;
		rowaxis label="Response" labelattrs=(size=10) valueattrs=(size=10) offsetmin=0;
		colaxis label="Name of Continuous Variable" type=discrete labelattrs=(size=9) valueattrs=(size=9);
		title height=12pt "Title of Data Movie";
		footnote1 height=10pt justify=center "Data Source";
		keylegend / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) position=bottom title=""; 
	run;
	%END;
	%ELSE %DO;
	proc sgpanel data=&data. dattrmap=attrmap; 
		where &interval.=&interval.;
		panelby &panelby. / columns=2 headerattrs=(size=12) spacing=25 novarname noheaderborder noborder;
		series x=&xvar. y=&response. / group=&groupvar. attrid=&groupvar. grouporder=data lineattrs=(thickness=4 pattern=solid);
		*band x=&xvar. upper=&response lower=one / group=&groupvar. attrid=&groupvar.;
		rowaxis label="Response" labelattrs=(size=10) valueattrs=(size=10) offsetmin=0;
		colaxis label="Name of Continuous Variable" type=discrete labelattrs=(size=9) valueattrs=(size=9);
		title height=12pt "Title of Data Movie";
		footnote1 height=10pt justify=center "Data Source";
		keylegend / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) position=bottom title="";
	run;
	%END;
%END;
%mend line;

OPTIONS papersize=("7 in", "6 in") printerpath=svg animation=start animduration=0.125 animloop=yes noanimoverlay nodate nonumber; 
ODS PRINTER file="filepath\filename.svg";
ODS GRAPHICS / width=7in height=6in imagefmt=gif noborder;
*assign the macro variables here before running ->; %line(data=,interval=,start=,end=,panelby=,xvar=,response=,groupvar=);
OPTIONS printerpath=svg animation=stop;
ODS PRINTER close;


******************
Type III: Butterfly Plot


Datasets Required:

- A dataset containing the integer response variables, the binary variable defining the butterfly plot, a continuous variable defining the time interval, and two binary or categorical stratification variables (see variable definitions below).
- An attribute map dataset called 'attrmap'. This dataset controls the color scheme and other properties of the plot. See SAS documentation for details.
- An annotation dataset called 'anno'. This dataset controls the placement and appearance of text and images overlaid on the plot. See SAS documentation for details.

Response Variables:

This type of plot takes an integer response (e.g. case count). To create the butterfly plot, define the following two variables in the input dataset:
- response1: set to -1*(value of the response) when pop1=1, set to missing when pop2=1
- response2: set to the value of the response when pop2=1, set to missing when pop1=1
[pop1 and pop2 are indicator variables based on the binary variable (e.g. sex) that splits the butterfly plot]

Macro Variables:

- data: name of dataset
- interval: name of numeric variable indicating time interval (e.g. day, week, quarter)
- start: value of 'interval' at which to start movie
- end: value of 'interval' at which to end movie
- panelby: name of binary or categorical variable by which to panel the plot (e.g. sex, region)
- groupvar: name of categorical variable defining the bars of the histogram (e.g. race, region)
;


%macro butterfly (data=,interval=,start=,end=,panelby=,groupvar=);

%DO &interval.=&start. %TO &end.;

	%IF &interval.=&start. OR &interval.=&end. %THEN %DO copy=1 %TO 8;
	proc sgpanel data=&data. dattrmap=attrmap sganno=anno; 
		where interval=&interval.;
		panelby &panelby. / columns=2 spacing=25 novarname noheader noheaderborder noborder;
		hbarparm category=&groupvar. response=response1 / group=&groupvar. attrid=&groupvar. barwidth=0.9 name = 'response1' grouporder=data;
		hbarparm category=&groupvar. response=response2 / group=&groupvar. attrid=&groupvar. barwidth=0.9 grouporder=data;
		format response1 response2 positive.; 
		colaxis label="Response" labelattrs=(size=11) valueattrs=(size=11) offsetmin=0.05 offsetmax=0.05;
		rowaxis display=(nolabel noticks novalues);
		title height=12pt "Title of Data Movie";
		footnote height=10pt justify=center  "Data Source";
		keylegend 'response1' / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) down=1 position=bottom title="";
	run;
	%END;
	%ELSE %DO;
	proc sgpanel data=&data. dattrmap=attrmap sganno=anno; 
		where interval=&interval.;
		panelby &panelby. / columns=2 spacing=25 novarname noheader noheaderborder noborder;
		hbarparm category=&groupvar. response=response1 / group=&groupvar. attrid=&groupvar. barwidth=0.9 name = 'response1' grouporder=data;
		hbarparm category=&groupvar. response=response2 / group=&groupvar. attrid=&groupvar. barwidth=0.9 grouporder=data;
		format response1 response2 positive.; 
		colaxis label="Response" labelattrs=(size=11) valueattrs=(size=11) offsetmin=0.05 offsetmax=0.05;
		rowaxis display=(nolabel noticks novalues);
		title height=12pt "Title of Data Movie";
		footnote height=10pt justify=center  "Data Source";
		keylegend 'response1' / valueattrs=(size=10) autoitemsize noborder outerpad=(top=10 left=0 right=0 bottom=10) down=1 position=bottom title="";
	run;
	%END;
%END;
%mend butterfly;

OPTIONS papersize=("7 in", "6 in") printerpath=svg animation=start animduration=0.125 animloop=yes noanimoverlay nodate nonumber; 
ODS PRINTER file="filepath\filename.svg";
ODS GRAPHICS / width=7in height=6in imagefmt=GIF noborder;
*assign the macro variables here before running ->; %butterfly(data=,interval=,start=,end=,panelby=,groupvar=);
OPTIONS printerpath=svg animation=stop;
ODS PRINTER close;
