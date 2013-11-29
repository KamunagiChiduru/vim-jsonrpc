vim-jsonrpc                               Remote Procedure Call client for vim
--------------------------------------------------------------------------------
this can call server-side function easily.

vim's dictionary which is data structure like JSON.
and, fortunately, i know a nice JSON encode/decode library for vim.
it's Vital.Web.JSON(see `vim-jp/vital.vim').


how to install
--------------------------------------------------------------------------------
if you use `Shougo/neobundle.vim', you can write below configuration to your
.vimrc.

```vim:how-to-install
    NeoBundle 'KamunagiChiduru/vim-jsonrpc', {
        'depends': ['Shougo/vimproc'],
    \}
```

