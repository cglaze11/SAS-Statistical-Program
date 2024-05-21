
/* For SAS Studio */
%LET SAS_PATH=%QSUBSTR(&_SASPROGRAMFILE,1,%LENGTH(&_SASPROGRAMFILE)-%LENGTH(%SCAN(&_SASPROGRAMFILE,-1,/))-1);
/* For SAS Local */
/* %LET SAS_PATH=%QSUBSTR(%SYSGET(SAS_EXECFILEPATH),1,%EVAL(%LENGTH(%SYSGET(SAS_EXECFILEPATH))-%LENGTH(%SYSGET(SAS_EXECFILENAME))-1)); */

proc import datafile="&sas_path./header_footnote.xlsx" out=tfl dbms=xlsx replace;
	sheet="TFL";
run;

proc import datafile="&sas_path./header_footnote.xlsx" out=type dbms=xlsx replace;
	sheet="TYPE";
run;

libname tfl "&sas_path./data";

%let lib=TFL;
%let pgm=T_5_1_4;
%let T_5_1_4=Table 5.1.4 Test table title;

data options;
	set tfl(where=(tfl_number=upcase("&pgm.")));
	call symputx("type",cats(type_id));
	call symputx("Orient",cats(Orient));
	call symputx("page",cats(page));
	call symputx(cats(tfl_number),cats(Title));
run;

data header;
	set type;
	if upcase(type_id)=upcase("&type");
	drop type_id;
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

data work.foo(keep=name); set sashelp.vcolumn; where libname =upcase("&lib") and memname = upcase("&pgm"); run;

data _null_;
	call symput("lib2",cats(put("&lib",$quote20.)));
	call symput("pgm2",cats(put("&pgm",$quote20.)));
run;

options nonotes nosource nosource2 nodate nodetails nonumber;
dm 'output; clear;';
dm 'log; clear;';

filename fileref "&sas_path./report_part/&pgm..sas";
proc printto log=fileref print=fileref new;run;

proc lua;
submit "lib=%NRBQUOTE(&lib2.);pgm=%NRBQUOTE(&pgm2.)";

	local dsnm="header"
	local lib=lib
	local pgm=pgm

--	Input tfl options about Orientation, Page break number, title, and footnotes.
--	sas.submit('%inc "&sas_path./modules/options.luc";')	
	local options_ds="work.options"
	if (sas.exists(options_ds)) then
		local tbl = sas.read_ds(options_ds)
		
		if tbl ~= nil then
			k, vars=pairs(tbl[1])
			footnotes={}
			title=vars["title"]
			Orient=vars["orient"]
			perpage=vars["page"]
			
			for i=1,10 do
				if vars[sas.cats("footnote",i)] ~= "" then
					footnotes[i]=vars[sas.cats("footnote",i)]
				end
			end
		else
			print("ERROR:Options about",sas.cats(lib,".",pgm),"don't be found in sheet TFL.")
		end
	else
		print("ERROR:The dataset of options about",sas.cats(lib,".",pgm),"don't exist.")
	end
	
--	sas.submit('%inc "&sas_path./modules/tflvars.luc";')	
	
	if (sas.exists("work.foo")) then
		local dsid = sas.open("work.foo")  
		
		dscols=sas.nobs(dsid)
		if dscols ~= 0 then
			local vars = {}
			for var in sas.vars(dsid) do
				vars[var.name:lower()] = var               
			end
			
			tflvars={}
			
			local i=0 
			while (sas.next(dsid) ~= nil) do
				i=i+1
				for vname,var in pairs(vars) do
					tflvars[i]=sas.get_value(dsid, vname)
				end
			end
		else
			print("ERROR:Information about",sas.cats(lib,".",pgm),"don't be found in sashelp.vcolumn.")
		end
		sas.close(dsid)	
	else
		print("ERROR:Information about",sas.cats(lib,".",pgm),"don't be found in sashelp.vcolumn.")
	end
	
--	sas.submit('%inc "&sas_path./modules/headermatrix.luc";')

	if (sas.exists("work.header_matrix")) then
		local dsid = sas.open("work.header_matrix")
		
		header_rows=sas.nobs(dsid)
		
		local vars = {}
		for var in sas.vars(dsid) do
			vars[var.name:lower()] = var               
		end
		
		header_matrix={}
	 
		local i=header_rows 
		while (sas.next(dsid) ~= nil) do
			for vname,var in pairs(vars) do
				header_matrix[i]=sas.get_value(dsid, vname)
			end
			i=i-1
		end
		sas.close(dsid)
	else
		print("ERROR:No header matrix dataset found.")
	end
	
--	Generate part of PROC REPORT
	local page_break=[[
data output_break_page;
    set @lib@.&pgm.;
    page=int(_N_/@page@)+1;
run;]]	
	sas.submit_(page_break,{page=perpage})
	
	if (sas.exists(dsnm)) then

		local dsid = sas.open(dsnm)
		local tbl = sas.read_ds(dsnm)
		
		local nrows=sas.nobs(dsid)
		local ncols=dscols
		
		local column=[[    column page @columns@ ;]]
		local def=[[    define @varnm@/display @varlabel@    style(column)={cellwidth=@collength@% just=l} style(header)=[just=l];]]
		
		merge={}	
		
		for i=1,nrows do
			k, vars=pairs(tbl[nrows-i+1])
			
			if i==1 then
				for j=1,ncols do
					merge[j]=sas.cats(tflvars[j])
				end
			else
				re = sas.prxparse('/(21+)/')
				
				local temp_header=header_matrix[i]

				while (sas.prxmatch(re,temp_header)>0) do
					stpos = sas.prxmatch(re,temp_header)
					endpos = stpos+sas.matchlen(temp_header)-1
--					print(stpos,"<- start pos,end pos ->",endpos)
					
					for m=stpos,endpos do
						if m==stpos then
							merge[m]=sas.catx(" ",sas.cats('("',vars[sas.cats("var",m)],'"'),merge[m])		
						end
						if m==endpos then
							merge[m]=sas.cats(merge[m],")")
						end
					end
					temp_header=sas.prxchange('s/(2)(1+)/1$2/', 1, temp_header)
				end
			end
		end

		local report=[[
options orientation=landscape;
ods rtf file="&sas_path./report_part/&pgm..rtf" style= styles.custom nobodytitle;
ods escapechar='^';
title1 j=l "&gtitle1." j=r "&gtitle3.";
title2 j=l "&gtitle2." j=r "&gtitle4.";

footnote1 j=l "&gfootnote1./ &SYSDATE9." j=c "保密" j=r "^S={protectspecialchars=off}第^{thispage}/^{lastpage}页";
/**===============================================PROC REPORT PART======================================================*/
proc report data=output_break_page headskip split='|' headline missing center nowindows 
	style(header) = [just=c protectspecialchars=off] style(column) = [asis=on]  style(report)={outputwidth=100% pretext="\fs20\s1\b1\outlinelevel1{&&&pgm.}"};
]]
 
 		sas.submit_(report,{lib=lib,pgm=pgm})
 		
		sas.submit_(column,{columns=table.concat(merge," ")})
		
		print("    define page/order noprint;")
		k, vars=pairs(tbl[nrows])
		for j=1,ncols do
			colnm=sas.cats("var",j)
			if vars[colnm]~="" then
				sas.submit_(def,{varnm=tflvars[j],varlabel=sas.cats('"',vars[colnm],'"'),collength=sas.floor(100/ncols)})
			end
		end
		
		print("    break after page/page;")
		print("    compute after _page_;")
		
		local footnote=[[        line @1 "@foot@";]]
		
		for i=1,table.size(footnotes) do
			sas.submit_(footnote,{foot=footnotes[i]})
		end
		
		print("    endcomp;")
		print("run;")		

		print("/**===============================================PROC REPORT END========================================================*/")
		print("ods rtf close;")
		print("ods listing;")		

		sas.close(dsid)
	else
		print("No dataset named [header] found.")
	end
endsubmit;
run;

data _null_;
	infile fileref;
	input;
	file "&sas_path./report_part/temp.sas" ;
	if ^find(_infile_,"SAS 系统") then
		put _infile_;
run;

proc printto;run;
%inc fileref;
filename fileref clear;
options notes source source2 date details number;

/*================================================================Test==========================================================*/

/* data options; */
/* 	set tfl(where=(tfl_number=upcase("&pgm."))); */
/* 	call symputx("type",cats(type_id)); */
/* 	call symputx("Orient",cats(Orient)); */
/* 	call symputx("page",cats(page)); */
/* 	call symputx(cats(tfl_number),cats(Title)); */
/* run; */
/*  */
/*  */
/*  */
/* proc lua; */
/* submit "lib=%NRBQUOTE(&lib.);pgm=%NRBQUOTE(&pgm.)"; */
/*  */
/* 	local dsnm="st" */
/* 	local lib=lib */
/* 	local pgm=pgm */
/* 		 */
/* --	sas.submit('%inc "&sas_path./modules/tflvars.luc";') */
/* --	sas.submit('%inc "&sas_path./modules/headermatrix.luc";') */
/* 	sas.submit('%inc "&sas_path./modules/options.luc";') */
/* 	print(table.tostring(footnotes)) */
/* endsubmit; */
/* run; */


	
