TableKnight
===========

vim插件，惟一用途是在文本文件中来展示表格，使用字符来模拟表格的边框

会破坏原始数据，不便于复制，请谨慎使用

第一次写vim插件，功能和设置上都有不完善的地方

有问题欢迎联系 anyexingchen999@qq.com

使用方式
-----------

插件默认的绑定是&lt;leader&gt;tk

&lt;leader&gt;的说明请参照:help leader

如果未使用可视模式选择数据，则会要求输入行数和列数，然后根据行数和列数生成空表格，参数的分隔符是空格，逗号，或者'-'

如果使用可视模式选择了数据，则会根据选择的内容生成表格，默认的分隔符是|

例如：

		1|2
		|1|2|||3
		1|2|3|4|5

会生成：

		+===========+
		|1|2| | | | |
		|-+-+-+-+-+-|
		| |1|2| | |3|
		|-+-+-+-+-+-|
		|1|2|3|4|5| |
		+===========+

用于分割列的字符的转义操作并未处理，插件提供了自定义机制，可以自定义分隔符，请自行更改

自定义符号
-----------

可以对用来表示表格边框的符号和分隔符进行自定义

符号的配置在插件中，可以在vimrc文件中添加下列配置，通过vimrc来空格插件的行为

符号配置的说明如下：

  let g:tk_decoration = {                                           
  \    'cross' : '┼' , 
  \    'horizontal' : '─' ,
  \    'horizontal_north_border' : '─' ,
  \    'horizontal_north_cross' : '┬' ,
  \    'horizontal_south_border' : '─' ,
  \    'horizontal_south_cross' : '┴' ,
  \    'vertical' : '│' ,
  \    'vertical_west_border' : '│' ,
  \    'vertical_west_cross' : '├' ,
  \    'vertical_east_border' : '│' ,
  \    'vertical_east_cross' : '┤' ,
  \    'northwest' : '┌' ,
  \    'southwest' : '└' ,
  \    'southest' : '┘' ,
  \    'northest' : '┐' ,
  \    'space' : ' ' 
  \    }

单元格的默认分割符，修改时只用修改[]中的部分

  let g:tk_td_separate = "[|]"

TODO LIST
-----------

1. 使用户可以通过vimrc对插件进行配置

1. 加入还原的功能，将表格还原为原始数据

1. 完善帮助文档

