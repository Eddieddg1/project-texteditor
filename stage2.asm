[bits 32]
[org 9000]

_start:
  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov fs, ax
  mov gs, ax

  mov byte [0xB8000], 'A'
  mov byte [0xB8001], 0x07

hang:
  jmp hang
