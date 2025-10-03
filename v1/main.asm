global _start
SECTION .bss
  termios: resb 64
  origtermios: resb 64
  filecontent: resb 4096

SECTION .data
textbuffer db 0
filedesc dq 0
normalbuffer db 0
bschar db 8, ' ', 8

SECTION .text

_start:
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

  mov rax, 2
  mov rdi, [rsp+16]
  mov rsi, 2
  mov rdx, 0
  syscall

  cmp rax, 0
  jl create_file

  mov [filedesc], rax
  jmp fileout

create_file:
  mov rax, 2
  mov rdi, [rsp+16]
  mov rsi, 0100
  mov rdx, 0o644
  syscall

  mov rax, 2
  mov rdi, [rsp+16]
  mov rsi, 2
  mov rdx, 0
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

normal:
  mov rax, 0
  mov rdi, 0
  mov rsi, normalbuffer
  mov rdx, 1
  syscall

  mov al, [normalbuffer]
  cmp al, 0x69
  jz input
  
  cmp al, 69
  jz exit

  jmp normal

input:
  mov rax, 0
  mov rdi, 0
  mov rsi, textbuffer
  mov rdx, 1
  syscall

  mov al, [textbuffer]
  cmp al, 27
  jz normal

  cmp al, 127
  jz backspace 

write:
  mov rax, 1
  mov rdi, 1
  mov rsi, textbuffer
  mov rdx, 1
  syscall

  mov rax, 1
  mov rdi, [filedesc]
  mov rsi, textbuffer
  mov rdx, 1
  syscall 

  jmp input

backspace:
  mov rax, 1
  mov rdi, 1
  mov rsi, bschar
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

exit:
  mov rax, 16
  mov rdi, 0
  mov rsi, 0x5402
  mov rdx, origtermios
  syscall
  
  mov rax, 60
  mov rdi, 0
  syscall
