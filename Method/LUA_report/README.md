
# TFL编程中proc report模块生成

1. 汇总TFL shell中的Tables，Listings的名称、标题、脚注，并预设纸张方向与每页行数。以Excel形式储存元数据。
2. 设定ODS RTF的样式、属性。其中`bodytitle`或`nobodytitle`影响标题脚注的在输出中位置，较为关键。

## 代码说明

+ `setup.sas` : 配置文件（仅更新此文件配置信息即可）
+ `luareport.sas` : 批量处理宏
+ `submit.sas` : `PROC REPORT`模板宏

可实现的功能：

- [ ] 支持元数据与数据集属性校对
- [x] 允许多行标题输出
- [x] 允许脚注输出
- [x] 允许分页
- [ ] 允许设置自定义对齐方式
- [ ] 允许设置自定义列宽
- [x] 允许添加上下角标
- [x] 支持批量输出PROC REPORT块
