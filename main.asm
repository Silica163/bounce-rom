    org 0x7c00
%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

%define WIDTH 320
%define HEIGHT 200
%define SIZE 14
%define DELAY 0x00

    mov ah, 0x00
    mov al, 0x0013
    int 0x10            ; mode 13h display

    mov ax, 0xa000
    mov es, ax          ; es -> video buffer
    
    mov bx, 0

mainloop:

;    call clear
    mov ax, [box_y]
    mov [y], ax
    .next_row:
        mov ax, [box_x]
        mov [x], ax

        .next_col:

            mov bx, 0
            mov bx, [y]
            imul bx, SCREEN_WIDTH
            add bx, [x]

            mov al, [color]
            mov [es:bx], al

            inc word [x]

            mov ax, [box_x]
            add ax, SIZE
            cmp [x], ax
        jne .next_col
        
        inc word [y]
        mov ax, [box_y]
        add ax, SIZE
        cmp [y], ax
    jne .next_row

    mov dx, 0

    mov ax, [box_y]
    mov bx, [box_dy]
    mov cx, HEIGHT - SIZE
    call bounce
    mov word [box_y], ax

    cmp [box_dy], bx
    je .ynotchange

    mov dx, 1
    
.ynotchange:
    mov [box_dy], bx

    mov ax, [box_x]
    mov bx, [box_dx]
    mov cx, WIDTH - SIZE
    call bounce
    mov word [box_x], ax
    
    cmp [box_dx], bx
    je .xnotchange

    mov dx, 1
    
.xnotchange:
    mov [box_dx], bx

    cmp dx, 0
    je .next

    mov al, [color]
    inc al
    cmp al, 0x50
    mov [color], al
    jle .next
    sub al, 0x18
    mov [color], al

.next:
    call _wait
    jmp mainloop

bounce:
    ; bx, position_dx
    ; ax, position
    ; cx, edge

    cmp ax, cx
    je .neg
    cmp ax, 0
    je .neg
    jmp .done
    .neg:
        neg bx
.done:
    add ax, bx
    ret

_wait:
    mov bx, 0
    mov al, 0x0
    mov ah, 0x86
    mov cx, DELAY
    int 0x15
    ret

clear:
    ; al => background color
    ; cx => bytes to write
    mov di, 0
    mov al, 0x18
    mov cx, 64000
    rep stosb      ; fill [es:di] with [al] <cx> times
    ret

color: db 0x38

box_dx: dw 1
box_dy: dw 1

x: dw 0x0
y: dw 0x0

box_x: dw (WIDTH - SIZE)/2
box_y: dw (HEIGHT - SIZE)/2

    times 510 - ($-$$) db 0
    dw 0xaa55
