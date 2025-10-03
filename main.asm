global _start

SECTION .bss

  termios: resb 64
  origtermios: resb 64

SECTION .data
SECTION .text

_start:
  call rawmode

exit:
  mov rax, 16
  mov rdi, 0
  mov rsi, 0x5402
  mov rdx, origtermios
  syscall

  mov rax, 60
  mov rdi, 0
  syscall

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
