
/* For SAS Studio */
%LET SAS_PATH=%QSUBSTR(&_SASPROGRAMFILE,1,%LENGTH(&_SASPROGRAMFILE)-%LENGTH(%SCAN(&_SASPROGRAMFILE,-1,/))-1);
/* For SAS Local */
/*  %LET SAS_PATH=%QSUBSTR(%SYSGET(SAS_EXECFILEPATH),1,%EVAL(%LENGTH(%SYSGET(SAS_EXECFILEPATH))-%LENGTH(%SYSGET(SAS_EXECFILENAME))-1));  */

proc import datafile="&sas_path./header_footnote.xlsx" out=tfl dbms=xlsx replace;
	sheet="TFL";
run;

proc import datafile="&sas_path./header_footnote.xlsx" out=type dbms=xlsx replace;
	sheet="TYPE";
run;

libname tfl "&sas_path./data";
options nomprint;
%macro luareport(libname=,tfl=tfl,headersrc=type);

data _null_;
	set &tfl;
	call symput("tfl_num",cats(_n_));
run;

%do i=1 %to &tfl_num;

data options;
	set &tfl;
	if _n_=&i.;
	call symputx("type",cats(type_id));
	call symputx("Orient",cats(Orient));
	call symputx("page",cats(page));
	call symputx("pgm",cats(tfl_number));
	call symputx(cats(tfl_number),cats(Title));
run;

data header;
	set &headersrc;
	if upcase(type_id)=upcase("&type");
	drop type_id;
	
	array chars _character_;
	do over chars;
		chars=prxchange('s/(\^\{)([[:graph:]])(\})/$1super $2$3/',-1,chars);
		chars=prxchange('s/(\_\{)([[:graph:]])(\})/^{sub $2$3/',-1,chars);
	end;
run;

options cmplib = _null_;
proc fcmp outlib=work.myfuncs.bates;
	function tempcvt(vars $) $ 1;
		if vars="^" then return("1");
		else if vars="" then return("0");
		else return("2");
	endfunc;
	function matchlen(vars $);
		re=prxparse('/(21+)/');
		if prxmatch(re,vars) then do;
			posn=prxposn(re,1,vars);
			return(length(posn));
		end;
	endfunc;
run;
options cmplib=work.myfuncs;

data header_matrix;
	set header;
	array chars _character_;
	do over chars;
		chars=tempcvt(chars);
	end;
	matric=cats(of _character_);
	keep matric;
run;

data work.foo(keep=name); set sashelp.vcolumn; where libname =upcase("&libname") and memname = upcase("&pgm"); run;

data _null_;
	call symput("lib2",cats(put("&libname",$quote20.)));
	call symput("pgm2",cats(put("&pgm",$quote20.)));
run;

options nonotes nosource nosource2 nodate nodetails nonumber;
dm 'output; clear;';
dm 'log; clear;';

filename fileref "&sas_path./report_part/&pgm..sas";
proc printto log=fileref new;run;

proc lua;

%inc "&sas_path./ForSASlocal/submit.sas";

run;

/* %put &sas_path; */
proc printto;run;

filename fileref "&sas_path./report_part/&pgm..sas";
filename filereff "&sas_path./report_part/temp.sas";

data _null_;
	infile fileref;
	input;
	file filereff;
	if ^find(_infile_,"SAS 系统") then
		put _infile_;
run;

data _null_;
	infile filereff;
	input;
	file fileref;
	put _infile_;
run;

%inc fileref; 


%let infile=&sas_path./report_part/&pgm..rtf;
data _nullrtf_;
	infile "&infile.";
	input;
	length rtftxt $32767;
	rtftxt=_infile_;
run;
data _NULL2_;
	set _nullrtf_;
	rtftxt=prxchange("s/([[:graph:]]+)+(\{\\\*\\bkmkend\s+IDX\})([[:graph:]]+)+/$1$2 \pard\qc\fs20\f1\b1 \outlinelevel1{&&&pgm.}{\par}\pard $3/",-1,rtftxt);
	rtftxt=prxchange("s/([[:graph:]]+)(\{\\\*\\bkmkend\s+IDX\d+\})([[:graph:]]+)/$1$2 \pard\qc\fs20\f1\b1 {&&&pgm.(Continued)}{\par}\pard $3/",-1,rtftxt);
	file "&infile." encoding='ms-936';
	put rtftxt;
run;
proc datasets nolist;delete _nullrtf_;quit;


options notes source source2 date details number;
%end;
%mend luareport;

%luareport(libname=tfl,tfl=tfl,headersrc=type);
	
options mprint;
