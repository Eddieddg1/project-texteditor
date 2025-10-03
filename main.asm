[org 0x7c00]

mov sp, 0x85FF
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax

mov dx, 0x92
in al, dx
or al, 2
out dx, al

mov ah, 42h
cmp dl, 0x80
jb  is_floppy
jmp cont

is_floppy:
  mov ah, 0x0E
  mov al, 'F'
  int 10h
  mov ah, 01h
  int 13h
  jmp $


cont:

mov byte [0x8600], 0x10
mov byte [0x8601], 0x00
mov word [0x8602], 1
mov word [0x8604], 0x0000
mov word [0x8606], 0x0900
mov dword [0x8608], 1
mov dword [0x860C], 0

mov si, 0x8600
mov di, 0x0000

mov dl,0x80 
int 13h
jc disk_error

mov ah, 0x0E
mov al, 'L'
int 10h
jmp after_load

disk_error:
  mov bh, ah
  mov ah, 0x0E
  mov al, 'E'
  int 10h

  jmp $

after_load:

mov dword [0x8610], 0x00000000
mov dword [0x8614], 0x00000000
mov dword [0x8618], 0x0000FFFF
mov dword [0x861C], 0x00CF9A00
mov dword [0x8620], 0x0000FFFF
mov dword [0x8624], 0x00CF9200
mov word [0x8628], 0x0017
mov dword [0x862A], 0x00008610

cli
lgdt [0x8628]

mov eax, cr0
or eax, 1
mov cr0, eax

jmp 0x08:0x9000

times 510-($-$$) db 0
dw 0xAA55
