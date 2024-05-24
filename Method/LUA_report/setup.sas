
%GLOBAL SAS_PATH _WPATH;

/*Some macro definitions*/
%let SPONSOR =%str(Cglazey11);
%let gvStudy = %str(Header and footnote automated generating);

%let gtitle1 = &SPONSOR;
%let gtitle2 = 方案号: &gvStudy;
%let gtitle3= CDISC Optimize;
%let gtitle4= Tables;
%let gfootnote1= 版本：V1.0;

%let LS = 132;
%let PS = 60;

*===================================================================;
* Set up the template ;
*===================================================================;
options orientation=landscape;
option nodate nonumber;
proc template;
        define style styles.custom;
        parent=styles.rtf;
          replace fonts/
		      'TitleFont1'         = ("宋体",9pt)
              'TitleFont2'         = ("宋体",9pt)
              'TitleFont'          = ("宋体",9pt)
              'StrongFont'         = ("宋体",10pt)
              'EmphasisFont'       = ("宋体",10pt)
              'FixedEmphasisFont'  = ("宋体",10pt)
              'FixedStrongFont'    = ("宋体",10pt)
              'FixedHeadingFont'   = ("宋体",10pt)
              'BatchFixedFont'     = ("宋体",10pt)
              'headingEmphasisFont'= ("宋体",10pt)
              'headingFont'        = ("宋体",10pt)
              'FixedFont'          = ("宋体",10pt)
              'docFont'            = ("宋体",10pt)
              'footFont'           = ("宋体",9pt);
        replace Body from Document "Controls the Body file." /
              topmargin    = 0.01in
              bottommargin = 0.01in
              rightmargin  = 1in
              leftmargin   = 1in;
         style header /
			 font=("宋体",10pt);
		style RowHeaderEmpty from RowHeader/ 
			borderbottomwidth=5;
        replace Table from Output /
        	rules=group
			frame = above
        	cellpadding = 1pt  
        	cellspacing = 1pt 
        	borderwidth = 1pt;
    end;
run;


*===================================================================;
* TFL information definitions
*===================================================================;

%LET SAS_PATH=%QSUBSTR(%SYSGET(SAS_EXECFILEPATH),1,%EVAL(%LENGTH(%SYSGET(SAS_EXECFILEPATH))-%LENGTH(%SYSGET(SAS_EXECFILENAME))-1)); 

/*TFL list datasets*/
proc import datafile="&sas_path./header_footnote.xlsx" out=tfl dbms=xlsx replace;
	sheet="TFL";
run;

/*Header datasets*/
proc import datafile="&sas_path./header_footnote.xlsx" out=type dbms=xlsx replace;
	sheet="TYPE";
run;

/*TFL datasets path*/
libname tfl "&sas_path./data";

%inc "&sas_path.\luareport.sas";
options nomprint;

%luareport(libname=tfl,tflmeta=tfl,headersrc=type,saspath=&sas_path.\report_part,rtfpath='&sas_path.\\report_part',runnow=);

options mprint;
