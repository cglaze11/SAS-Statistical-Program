## 药时曲线系列图[模板](Graphics/TemplateMix.sas)使用说明

```
dynamic _byval_ _byval2_ _byval3_ XAXISLABEL YAXISLABEL 
			xtickvaluelist ytickvaluelist ytickvaluelistlog
			XTICKMIN XTICKMAX YTICKMIN YTICKMAX
			YVAR LOGYVAR XVAR GRPVAR LOWBAR UPBAR LENGEDTITLE ;
```

### 平均血药浓度-时间曲线图（Mean±SD，线性和半对数）

```
proc sgrender data=final template=celldefine ;
	dynamic XAXISLABEL='Time(h)' YAXISLABEL='Concentration (ug/mL)' 
	xtickvaluelist='0 10 26 50 98 168'
	ytickvaluelist =''
	ytickvaluelistlog='1 10 100 1000'
	XTICKMIN='0' XTICKMAX='169' YTICKMIN='' YTICKMAX='1000'
	YVAR='Mean' LOGYVAR='logmean' XVAR='ATPTN' LENGEDTITLE='剂量组：' GRPVAR='DOSE' LOWBAR='Meanlow' UPBAR='Meanhig';
run;
```

### 平均血药浓度-时间曲线图（Mean±SD，线性）

```
proc sgrender data=final template=celldefine ;
	dynamic XAXISLABEL='Visit' YAXISLABEL='Concentration (ug/mL)' 
	xtickvaluelist=''
	ytickvaluelist =''
	ytickvaluelistlog=''
	XTICKMIN='0' XTICKMAX='169' YTICKMIN='' YTICKMAX='1000'
	YVAR='Mean' XVAR='PCTPTREF' LENGEDTITLE='剂量组：' GRPVAR='DOSE' LOWBAR='Meanlow' UPBAR='Meanhig';
run;
```

### 中位血药浓度-时间曲线图（线性和半对数）

```
proc sgrender data=final template=celldefine ;
	dynamic XAXISLABEL='Time(h)' YAXISLABEL='Concentration (ug/mL)' 
	xtickvaluelist='0 10 26 50 98 168'
	ytickvaluelist =''
	ytickvaluelistlog='1 10 100 1000'
	XTICKMIN='0' XTICKMAX='169' YTICKMIN='' YTICKMAX='1000'
	YVAR='Median' LOGYVAR='logmed' XVAR='ATPTN' LENGEDTITLE='剂量组：' GRPVAR='DOSE' LOWBAR='' UPBAR='';
run;
```

### 中位血药浓度-时间曲线图（线性）

```
proc sgrender data=final template=celldefine ;
	dynamic XAXISLABEL='Visit' YAXISLABEL='Concentration (ug/mL)' 
	xtickvaluelist=''
	ytickvaluelist =''
	ytickvaluelistlog=''
	XTICKMIN='0' XTICKMAX='169' YTICKMIN='' YTICKMAX='1000'
	YVAR='median' XVAR='PCTPTREF' LENGEDTITLE='剂量组：' GRPVAR='DOSE' LOWBAR='' UPBAR='';
run;
```

### 血药浓度-时间曲线个体叠加图（线性和半对数）

```
proc sgrender data=final template=celldefine ;
	by dose;
	dynamic XAXISLABEL='Time(h)' YAXISLABEL='Concentration (ug/mL)' 
	xtickvaluelist='0 10 26 50 98 168'
	ytickvaluelist =''
	ytickvaluelistlog='1 10 100 1000'
	XTICKMIN='0' XTICKMAX='169' YTICKMIN='' YTICKMAX='1000'
	YVAR='AVAL3' LOGYVAR='LOGAVAL' XVAR='AWNLRT' LENGEDTITLE='受试者ID：' GRPVAR='SUBJID' LOWBAR='' UPBAR='';
run;
```

### 血药浓度-时间曲线个体叠加图（线性）

```
proc sgrender data=final template=celldefine ;
	by dose;
	dynamic XAXISLABEL='Visit' YAXISLABEL='Concentration (ug/mL)' 
	xtickvaluelist=''
	ytickvaluelist =''
	ytickvaluelistlog=''
	XTICKMIN='0' XTICKMAX='120' YTICKMIN='' YTICKMAX='1000'
	YVAR='AVAL3' XVAR='PCTPTREF' LENGEDTITLE='受试者ID：' GRPVAR='SUBJID' LOWBAR='' UPBAR='';
run;
```
