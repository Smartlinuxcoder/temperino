section .data
    msg db "Gib some celsius", 0xA ; The string to print with a newline
    len equ $ - msg

section .bss
    buffer resb 128     ; 128 bytes for input
    output resb 16      ; 16 bytes for output (enough for large numbers)

section .text
    global _start

_start:
    ; Write prompt
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg        ; Pointer to message
    mov rdx, len        ; Message length
    syscall

    ; Read input
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buffer     ; Input buffer
    mov rdx, 128        ; Max input size
    syscall

    ; Convert input to integer
    xor rsi, rsi        ; Reset index
    xor rax, rax        ; Clear result register

convert_loop:
    movzx rdi, byte [buffer + rsi] ; Load next ASCII character
    test  rdi, rdi                 ; Check for null terminator (or newline)
    jz    done_convert             ; If null terminator, we're done
    cmp   rdi, 0xA                 ; Check for newline (Enter key)
    je    done_convert             ; Stop if newline is reached

    sub   rdi, '0'                 ; Convert ASCII to numeric
    imul  rax, rax, 10             ; Multiply previous result by 10
    add   rax, rdi                 ; Add current digit
    inc   rsi                      ; Increment index
    jmp   convert_loop

done_convert:
    ; Celsius to Fahrenheit: F = C * 9/5 + 32
    mov rbx, 9                     ; Multiplier for (C * 9/5)
    imul rax, rbx                  ; rax = rax * 9
    mov rbx, 5                     ; Divisor
    cqo                            ; Sign-extend rax into rdx for division
    idiv rbx                       ; rax = rax / 5
    add rax, 32                    ; Add 32 for Fahrenheit

    ; Convert result to string in `output`
    mov rsi, output                ; Start of output buffer
    add rsi, 16                    ; Point to the end of the buffer (safe margin)
    xor rcx, rcx                   ; Digit counter

convert_to_ascii:
    xor rdx, rdx                   ; Clear remainder
    mov rbx, 10                    ; Base 10
    div rbx                        ; Divide rax by 10
    add rdx, '0'                   ; Convert remainder to ASCII
    dec rsi                        ; Move output pointer backward
    mov [rsi], dl                  ; Store ASCII character
    inc rcx                        ; Increment digit count
    test rax, rax                  ; Check if rax is 0
    jnz  convert_to_ascii          ; Repeat if more digits to process

    ; Write the result
    mov rax, 1                     ; sys_write
    mov rdi, 1                     ; stdout
    mov rdx, rcx                   ; Length of the string
    syscall

    ; Exit
    mov rax, 60                    ; sys_exit
    xor rdi, rdi                   ; Exit code 0
    syscall
