vim.cmd [[
  autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
  augroup vimtex_mac
    autocmd!
    autocmd FileType tex call SetServerName()
  augroup END
  
  function! SetServerName()
    call system('echo ' . v:servername . ' > /tmp/curvimserver')
  endfunction
]]
