" 启用语法高亮
syntax on

" 显示行号
set number

" 使用系统剪贴板
set clipboard=unnamedplus

" 设置缩进
set tabstop=4
set shiftwidth=4
set expandtab

" 搜索高亮
set hlsearch
set incsearch

" 显示光标位置
set ruler

" 启用鼠标支持
set mouse=a

" 文件格式设置
set fileformat=unix
set fileformats=unix,dos

" 显示不可见字符(可选,帮助调试)
set list
set listchars=tab:>-,trail:~,extends:>,precedes:<
" set nolist

" Ctrl+A 全选
nnoremap <C-a> ggVG

" Ctrl+C 复制选中内容
vnoremap <C-c> "+y

" Ctrl+V 粘贴并清理 Windows 行尾符
inoremap <C-v> <C-r><C-r>=substitute(getreg('+'), '\r', '', 'g')<CR>

" Ctrl+X 剪切选中内容
vnoremap <C-x> "+d

" F2 快速删除所有 ^M
nnoremap <F2> :%s/\r//g<CR>

