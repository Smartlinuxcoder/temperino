section .data
    msg db "Getting input!", 0xA ; The string to print with a newline
    len equ $ - msg                          ; Calculate the length of the string

section .bss
    buffer resb 128 ; 128 bytes of input

section .text
    global _start

_start:
    ; Write to stdout
    mov rax, 1          ; System call number for sys_write
    mov rdi, 1          ; File descriptor (1 = stdout)
    mov rsi, msg        ; Pointer to the message
    mov rdx, len        ; Length of the message
    syscall             ; Use syscall instruction for 64-bit

    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    syscall

    mov rax, 1
    mov rdx, 1
    mov rsi, buffer
    mov rdx, 128
    syscall

    ; Exit the program
    mov rax, 60         ; System call number for sys_exit
    xor rdi, rdi        ; Exit code (0)
    syscall             ; Use syscall instruction for 64-bit
