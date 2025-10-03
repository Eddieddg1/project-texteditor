global _start

SECTION .bss
  termios: resb 64
  origtermios: resb 64
  filecontent: resb 4096

SECTION .data
  enter_alt db 0x01B, '[?1049h'
  enter_alt_length equ $ - enter_alt
  exit_alt db 0x01B, '[?1049l'
  exit_alt_length equ $ - exit_alt

  input_buffer dq 0
  filedesc dq 0
  rspinput dq 0

  bspace db 8, ' ', 8
  arrowesc db 0, 0, 0

  cu0x0 db 0x01B, '[H'
  cuLine dq 0
  cuChar dq 0

SECTION .text

_start:
  mov rax, [rsp+16]
  mov [rspinput], rax
  call rawmode
  call altscreen

  mov rax, 1
  mov rdi, 1
  mov rsi, cu0x0
  mov rdx, 3
  syscall

  call file_input
  jmp normal

exit:
  call restore

  mov rax, 60
  mov rdi, 0
  syscall

normal:
  xor eax, eax
  mov [input_buffer], rax

  mov rax, 0
  mov rdi, 0
  mov rsi, input_buffer
  mov rdx, 4
  syscall

  mov eax, [input_buffer]
  cmp eax, 69
  jz exit

  cmp eax, 0x69
  jz input

  jmp normal

input:
  xor rax, rax
  mov [input_buffer], rax

  mov rax, 0
  mov rdi, 0
  mov rsi, input_buffer
  mov rdx, 4
  syscall

  cmp rax, 4
  jz fourin

  cmp rax, 3
  jz threein

  cmp rax, 2
  jz twoin

  xor eax, eax

  mov eax, [input_buffer]
  cmp eax, 127
  jz backspace

  cmp eax, 27
  jz first27
  
  jmp input

first27:
  mov eax, [input_buffer+1]
  cmp al, 91
  jnz normal

  mov eax, [input_buffer+2]
  cmp al, 65
  jl not_arrow
  cmp al, 68
  jg not_arrow

  jmp arrow

output:
  mov rax, 1
  mov rdi, 1
  mov rsi, input_buffer
  mov rdx, 1
  syscall

  mov rax, 1
  mov rdi, [filedesc]
  mov rsi, input_buffer
  mov rdx, 1
  syscall

  jmp input

not_arrow:

  jmp input

arrow:
  mov byte [arrowesc], 27
  mov byte [arrowesc+1], 91
  mov byte [arrowesc+2], al

  mov rax, 1
  mov rdi, 1
  mov rsi, arrowesc
  mov rdx, 3
  syscall

  xor rax, rax

  jmp input

backspace:
  mov rax, 1
  mov rdi, 1
  mov rsi, bspace
  mov rdx, 3
  syscall

  mov rax, 8
  mov rdi, [filedesc]
  mov rsi, -1
  mov rdx, 1
  syscall

  mov rsi, rax
  mov rax, 77
  mov rdi, [filedesc]
  syscall

  jmp input

rawmode:
  mov rax, 16
  mov rdi, 0
  mov rsi, 0x5401
  mov rdx, termios
  syscall

  mov rsi, termios
  mov rdi, origtermios
  mov rcx, 64
  rep movsb

  mov eax, [termios+12]
  and eax, 0xFFFFFFF4
  mov [termios+12], eax

  mov rax, 16
  mov rdi, 0
  mov rsi, 0x5402
  mov rdx, termios
  syscall

  ret

altscreen:
  mov rax, 1
  mov rdi, 1
  mov rsi, enter_alt
  mov rdx, enter_alt_length
  syscall

  ret

file_input:
  mov rax, 2
  mov rdi, [rspinput]
  mov rsi, 2
  mov rdx, 0
  syscall

  cmp rax, 0
  jl create_file

  mov [filedesc], rax

  jmp fileout

create_file:
  mov rax, 2
  mov rdi, [rspinput]
  mov rsi, 0102
  mov rdx, 0o644
  syscall

  mov [filedesc], rax

fileout:
  mov rax, 0
  mov rdi, [filedesc]
  mov rsi, filecontent
  mov rdx, 4096
  syscall

  mov rbx, rax

  mov rax, 1
  mov rdi, 1
  mov rsi, filecontent
  mov rdx, rbx
  syscall

  ret

restore:
  mov rax, 1
  mov rdi, 1
  mov rsi, exit_alt
  mov rdx, exit_alt_length
  syscall

  mov rax, 16
  mov rdi, 0
  mov rsi, 0x5402
  mov rdx, origtermios
  syscall

  ret
