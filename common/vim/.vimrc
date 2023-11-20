set rtp+=~/.local/lib/python$PYTHON_VERSION/site-packages/powerline/bindings/zsh/powerline.zsh

let g:minBufExplForceSyntaxEnable=1
source ~/.local/lib/python$PYTHON_VERSION/site-packages/powerline/bindings/vim/plugin/powerline.vim

syntax enable
set nocompatible
set encoding=utf-8
set number
set cursorline
set t_Co=256
set autoindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set colorcolumn=80
"set spell
set modifiable
set background=dark
colorscheme darcula

set laststatus=2
set noshowmode
set completeopt=longest,menu
set backspace=indent,eol,start

" Vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'Valloric/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'rhysd/vim-clang-format'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'

"ycm let g:ycm_global_ycm_extra_conf='~/.vim/bundle/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py'
"ycm let g:ycm_server_python_interpreter='/usr/bin/python$PYTHON_VERSION'

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let g:clang_format#style_options = {
            \ "AccessModifierOffset": -2,
            \ "AllowShortIfStatementsOnASingleLine": "true",
            \ "AlwaysBreakTemplateDeclarations": "true",
            \ "Standard": "C++11"}

autocmd FileType c,cpp ClangFormatAutoEnable

call vundle#end()
filetype plugin indent on
