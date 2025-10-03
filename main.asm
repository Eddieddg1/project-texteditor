global _start
extern keybinds

SECTION .bss
  termios: resb 64
  origtermios: resb 64

SECTION .data
saversp dq 0              ; Save place for [rsp+16]

SECTION .text

_start:
  mov rax, [rsp+16]       ; Moves [rsp+16] into rax
  mov [saversp], rax      ; Moves rax into [saversp]
  call rawmode

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

exit:
  mov rax, 16
  mov rdi, 0
  mov rsi, 0x5402
  mov rdx, origtermios
  syscall

  mov rax, 60
  mov rdi, 0
  syscall
