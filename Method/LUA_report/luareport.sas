%macro luareport(libname=,tflmeta=tfl,headersrc=type,saspath=,rtfpath=,runnow=);

data _null_;
	set &tflmeta;
	call symput("tfl_num",cats(_n_));
run;

%do i=1 %to &tfl_num;

data options;
	set &tflmeta.;
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
	call symput("rtf_outpath",&rtfpath);
run;

options nonotes nosource nosource2 nodate nodetails nonumber;
dm 'output; clear;';
dm 'log; clear;';

filename fileref "&saspath.\&pgm..sas";
proc printto log=fileref new;run;

proc lua;
%inc "&sas_path.\submit.sas";
run;

proc printto;run;

%if &runnow.^= %then %do;
	filename fileref "&saspath.\&pgm..sas";
	%inc fileref; 
%end;

options notes source source2 date details number;
%end;
%mend luareport;
