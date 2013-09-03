"+--------------------------------------------------------------------------+
"|                   Vim global plugin for generate table                   |
"|--------------------------------------------------------------------------|
"|    FileName: |  table.vim                                                |
"|--------------+-----------------------------------------------------------|
"|      Author: |  codepiano                                                |
"|--------------+-----------------------------------------------------------|
"|       Email: |  codepiano@gmail.com                                      |
"|--------------+-----------------------------------------------------------|
"|    HomePage: |  http://pianoisy.sinaapp.com/                             |
"|--------------+-----------------------------------------------------------|
"|  LastChange: |  2013-03-24 13:46:11                                      |
"|--------------+-----------------------------------------------------------|
"|  Maintainer: |  codepiano <codepiano@gmail.com>                          |
"|--------------+-----------------------------------------------------------|
"|     License: |  This file is placed in the public domain.                |
"+--------------------------------------------------------------------------+

"防止脚本重复加载，用户也可以手动设置该变量阻止该插件加载
if exists("g:loaded_tableknight")
    finish                      
endif                         
let g:loaded_tableknight = 1     

let s:save_cpo = &cpo
set cpo&vim

"设置按键绑定，绑定前先进行判断，防止覆盖用户自定义绑定
if !hasmapto("<Plug>TableKnight")
    map <unique> <Leader>tk  <Plug>TableKnight
endif

noremap <unique> <script> <Plug>TableKnight  <SID>Princess

noremap <SID>Princess :call <SID>Princess()<CR>

"脚本内部使用的变量定义
"边框交叉点的字符cross:"+"
"横向边框的连接线horizontal:"-"
"纵向边框的连接线vertical_line:"|"
if exists("g:tk_decoration")
    let s:tk_decoration = g:tk_decoration
else
    let s:tk_decoration = {
                \"cross": "+",
                \"horizontal": "-",
                \"horizontal_north_border": "-",
                \"horizontal_north_cross": "-",
                \"horizontal_south_border": "-",
                \"horizontal_south_cross": "-",
                \"vertical": "|",
                \"vertical_west_border": "|",
                \"vertical_west_cross": "|",
                \"vertical_east_border": "|",
                \"vertical_east_cross": "|",
                \"northwest": "+",
                \"southwest": "+",
                \"southest": "+",
                \"northest": "+",
                \"space": " "}
endif
"单元格的默认宽度
let s:tk_td_width = "9"
"单元格的默认分割符
if exists("g:tk_td_separate")
    let s:tk_td_separate = g:tk_td_separate
else
    let s:tk_td_separate = "[|]"
endif

"Princess
function s:Princess() range
    let l:startline = abs(0 + a:firstline)
    let l:endline = abs(0 + a:lastline)
    if l:startline >= l:endline
        let l:tk_args = input("请输入行数和列数:")
        if strlen(l:tk_args) == 0
            echo "没有参数"
            return
        else
            let l:tk_args_list = split(l:tk_args,"[, -]")
        endif
        let l:row_number = abs(0 + l:tk_args_list[0])
        let l:column_number = abs(0 + l:tk_args_list[1])
        "参数合法性检查
        if(l:row_number == 0 || l:column_number == 0)
            echo "行数和列数不能为0"
            return
        endif
        call s:Kinght_Build_Table(l:row_number,l:column_number)
    else
        call s:Kinght_Designer(l:startline,l:endline)
    endif
endfunction

"获取每列的最大长度
"@param startline 起始行数
"@param endline 结束行数
function s:Kinght_Designer(startline,endline)
    "记录每列最长宽度的list
    let l:td_width_list = []
    let l:line_index = a:startline
    "遍历每一行
    while l:line_index <= a:endline
        let l:line_content = getline(l:line_index)
        let l:td_list = split(l:line_content,s:tk_td_separate,1)
        let l:td_index = 0
        "遍历每一个单元格
        for l:td_content in l:td_list
            let l:td_length = strdisplaywidth(l:td_content)
            "处理split函数截取的长度为0的字符串
            if l:td_length == 0
                let l:td_length = l:td_length + 1
            endif
            let l:cache_td_length = get(l:td_width_list,l:td_index,-1)
            if l:cache_td_length == -1
                call add(l:td_width_list,l:td_length)
            elseif l:td_length > l:cache_td_length
                let l:td_width_list[l:td_index] = l:td_length
            endif
            let l:td_index = l:td_index + 1
        endfor
        let l:line_index = l:line_index + 1
    endwhile
    call s:Kinght_Gardener(a:startline,a:endline,l:td_width_list)
endfunction

"生成表格
"@param startline 起始行数
"@param endline 结束行数
"@param td_width_list 记录每列最长宽度的list
function s:Kinght_Gardener(startline,endline,td_width_list)
    let l:line_index = a:startline
    let l:line_end = a:endline
    let l:fence = s:Kinght_Make_Enclosure(a:td_width_list,s:tk_decoration)
    let l:space_cache = {}
    call cursor(a:startline,1)
    normal! O
    call setline('.',l:fence["fence_top"])
    let l:line_index = l:line_index + 1
    let l:line_end = l:line_end + 1
    "遍历每一行
    while l:line_index <= l:line_end 
        let l:line_content = getline(l:line_index)
        let l:td_list = split(l:line_content,s:tk_td_separate,1)
        let l:count = len(a:td_width_list) - len(l:td_list)
        let l:td_list = s:Kinght_Fill_List(l:td_list,l:count)
        let l:td_index = 0
        "遍历每一个单元格
        for l:td_content in l:td_list
            let l:td_length = strdisplaywidth(l:td_content)
            let l:cache_td_length = get(a:td_width_list,l:td_index,0)
            let l:space_width = l:cache_td_length - l:td_length
            "是否从缓存获取
            if !has_key(l:space_cache,l:space_width)
                "根据宽度拼接
                let l:space_part = ""
                let l:index = 0
                while l:index < l:space_width
                    let l:space_part = l:space_part . s:tk_decoration["space"]
                    let l:index = l:index + 1
                endwhile
                let l:space_cache[space_width] = l:space_part
            endif
            let l:td_list[l:td_index] = l:td_list[l:td_index] . l:space_cache[l:space_width] 
            let l:td_index = l:td_index + 1
        endfor
        let l:wrapped_td = s:tk_decoration["vertical_west_border"] . join(l:td_list,s:tk_decoration["vertical"]) . s:tk_decoration["vertical_east_border"]
        call setline(l:line_index,l:wrapped_td)
        call cursor(l:line_index,1)
        normal! o
        call setline('.',l:fence["fence_trellis"])
        let l:line_index = l:line_index + 2
        let l:line_end = l:line_end + 1
    endwhile
    call setline('.',l:fence["fence_bottom"])
endfunction

"在列数不足的行中填充空格
"@param list 单元格列表
"@param count 补充数
function s:Kinght_Fill_List(td_list,count)
    let l:fill_count = a:count
    while l:fill_count > 0
        call add(a:td_list,' ')
        let l:fill_count = l:fill_count - 1
    endwhile
    return a:td_list
endfunction

"生成空表格
"@param row_number 行数
"@param column_number 列数
"@param decoration 构成边框的字符，默认线条为'-'，交叉点为'+'
function s:Kinght_Build_Table(row_number,column_number)
    let l:fence = {}
    let l:column_width_list = s:Kinght_Calc_Width(a:column_number)
    if(len(l:column_width_list) > 0)
        let l:fence = s:Kinght_Make_Enclosure(column_width_list,s:tk_decoration)
    endif
    let l:line_number = line(".")
    let l:count = 1
    normal! o
    call setline('.',l:fence["fence_top"])
    while l:count < a:row_number
        let l:count = l:count + 1
        normal! o
        call setline('.',l:fence["fence_content"])
        normal! o
        call setline('.',l:fence["fence_trellis"])
    endwhile
    normal! o
    call setline('.',l:fence["fence_content"])
    normal! o
    call setline('.',l:fence["fence_bottom"])
    return l:fence
endfunction

"计算空表格的每行宽度
"@param column_number 列数
"@return column_width_list 记录列宽的list
function s:Kinght_Calc_Width(column_number)
    let l:column_width_list = []
    "判断是否开启折行
    let l:is_wrap = &wrap
    let l:line_width = 78
    "默认单元格宽度 TODO fixed
    if(l:is_wrap == 1)
        "获取每行最大宽度
        let l:line_width = &textwidth
    endif
    if(l:line_width < 1)
        "如果没有定义textwidth，默认为78
        let l:line_width = 78
    endif
    let l:td_width = (l:line_width - a:column_number - 1) / a:column_number
    "使用默认单元格宽度
    if(s:tk_td_width < l:td_width)
        let l:td_width = s:tk_td_width
    endif
    "填充单元格宽度数据
    if(l:td_width > 0)
        let l:index = 0
        while l:index < a:column_number
            call add(l:column_width_list,l:td_width)
            let l:index = l:index + 1
        endwhile
    endif
    return l:column_width_list
endfunction

"构造表格的边框
"@param olumn_width_list 存放每列宽度的list
"@param decoration 构成边框的字符，默认线条为'-'，交叉点为'+'
function s:Kinght_Make_Enclosure(column_width_list,decoration)
    let l:fence = {} 
    let l:enclosure = [] 
    let l:enclosure_north = [] 
    let l:enclosure_south = [] 
    "确定装饰字符
    if empty(a:decoration)
        let l:decoration = s:tk_decoration
    else
        let l:decoration = a:decoration
    endif
    let l:fence_cache = {}
    let l:fence_cache_north = {}
    let l:fence_cache_south = {}
    for l:td_width in a:column_width_list
        "是否从缓存获取
        if has_key(l:fence_cache,l:td_width)
            call add(l:enclosure,l:fence_cache[l:td_width])
            call add(l:enclosure_north,l:fence_cache_north[l:td_width])
            call add(l:enclosure_south,l:fence_cache_south[l:td_width])
            "根据宽度拼接
        else
            let l:fence_part = ""
            let l:fence_part_north = ""
            let l:fence_part_south = ""
            let l:index = 0
            while l:index < td_width
                let l:fence_part = l:fence_part . l:decoration["horizontal"]
                let l:fence_part_north = l:fence_part_north . l:decoration["horizontal_north_border"]
                let l:fence_part_south = l:fence_part_south . l:decoration["horizontal_south_border"]
                let l:index = l:index + 1
            endwhile
            let l:fence_cache[l:td_width] = l:fence_part
            let l:fence_cache_north[l:td_width] = l:fence_part_north
            let l:fence_cache_south[l:td_width] = l:fence_part_south
            call add(l:enclosure,l:fence_part)
            call add(l:enclosure_north,l:fence_part_north)
            call add(l:enclosure_south,l:fence_part_south)
        endif
    endfor
    let l:fence["fence_top"] = l:decoration["northwest"] . join(l:enclosure_north,l:decoration["horizontal_north_cross"]) . l:decoration["northest"]
    let l:fence["fence_content"] = l:decoration["vertical_west_border"] . join(l:enclosure,l:decoration["vertical"]) . l:decoration["vertical_east_border"]
    let l:fence["fence_content"] = substitute(l:fence["fence_content"],l:decoration["horizontal"],l:decoration["space"],"g")
    let l:fence["fence_trellis"] = l:decoration["vertical_west_cross"] . join(l:enclosure,l:decoration["cross"]) . l:decoration["vertical_east_cross"]
    let l:fence["fence_bottom"] = l:decoration["southwest"] . join(l:enclosure_south,l:decoration["horizontal_south_cross"]) . l:decoration["southest"]
    return l:fence
endfunction

if !exists(":Tk")
endif

let &cpo = s:save_cpo
