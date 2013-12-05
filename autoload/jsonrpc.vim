"
" Author: kamichidu
" Last Change: 06-Dec-2013.
" Lisence: The MIT License (MIT)
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
"
let s:save_cpo= &cpo
set cpo&vim

let s:V= vital#of('vim-jsonrpc')
let s:J= s:V.import('Web.JSON')
unlet s:V

let s:prototype= {
\   'socket': -1,
\   '_timeout_length': 2.0,
\}

function! jsonrpc#client(host, port)
    let l:obj= deepcopy(s:prototype)

    try
        let l:obj.socket= vimproc#socket_open(a:host, a:port)
    catch /^vimproc:/
        throw 'jsonrpc: could not connect to ' . a:host . ':' . a:port
    endtry

    return l:obj
endfunction

" http://www.jsonrpc.org/specification
function! s:prototype.call(func_name, ...)
    let l:request= {
    \   'jsonrpc': '2.0',
    \   'method': a:func_name,
    \   'params': a:000,
    \   'id':     'tmpv1wraMY2',
    \}

    call self.socket.write(s:J.encode(l:request), 10)

    let l:response= ''
    let l:start= s:now()
    while !self.socket.eof
        let l:part= self.socket.read(1024, 10)

        if !empty(l:response) && empty(l:part)
            break
        elseif s:now() - l:start >= self._timeout_length
            throw 'jsonrpc: connection timed out!'
        endif

        let l:response.= l:part
    endwhile

    let l:decoded_response= s:J.decode(l:response)

    if l:request.id !=# l:decoded_response.id
        throw 'jsonrpc: invalid response received'
    endif

    if has_key(l:decoded_response, 'result')
        return l:decoded_response.result
    elseif has_key(l:decoded_response, 'error')
        throw 'jsonrpc: got an error - ' . string(l:decoded_response.error.message)
    else
        throw 'jsonrpc: got an undefined response'
    endif
endfunction

function! s:prototype.close()
    call self.socket.close()

    let self.socket= -1
endfunction

function! s:prototype.timeout_length(seconds)
    if type(0.0) != type(a:seconds)
        throw 'jsonrpc: argument must be float value'
    endif

    let self._timeout_length= a:seconds
endfunction

function! s:now()
    return str2float(reltimestr(reltime()))
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo

