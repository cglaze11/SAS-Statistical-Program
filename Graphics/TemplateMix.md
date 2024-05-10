## 药时曲线系列图[模板](Graphics/TemplateMix.sas)使用说明

dynamic variables specification :
```
dynamic _byval_ /*proc sgender 的by变量，用于个体图*/
	_byval2_ /*proc sgender 的by变量，用于个体图，暂时未考虑第2个by变量*/
	_byval3_ /*proc sgender 的by变量，用于个体图，暂时未考虑第3个by变量*/
	XAXISLABEL /*X轴标签*/
	YAXISLABEL /*Y轴标签*/
	xtickvaluelist /*X轴刻度列表*/
	ytickvaluelist /*Y轴线性刻度列表，用于线性图时常置空*/
	ytickvaluelistlog /*Y轴对数刻度列表，用于对数图，常为10指数，1 10 100 1000*/
	XTICKMIN /*X轴刻度最小值，用于调整X轴显示范围*/
	XTICKMAX /*X轴刻度最大值，用于调整X轴显示范围*/
	YTICKMIN /*Y轴刻度最小值，用于调整Y轴显示范围*/
	YTICKMAX /*Y轴刻度最大值，用于调整Y轴显示范围*/
	YVAR /*Y轴变量，如浓度，浓度均值、浓度中位数等*/
	LOGYVAR /*Y轴对数变量，如浓度，浓度均值、中位数等，用于解决YVAR为0时无法正确显示对数刻度的变量*/
	XVAR /*X轴变量*/
	GRPVAR /*分组变量*/
	LOWBAR /*均值图中的下限值变量*/
	UPBAR /*均值图中的上限值变量*/
	LENGEDTITLE /*图例名称*/
	;
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
