    org 0x7c00
%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

%define WIDTH 320
%define HEIGHT 200
%define SIZE 14
%define DELAY 0x00

    xor ah, ah
    mov al, 0x0013
    int 0x10            ; mode 13h display

    mov ax, 0xa000
    mov es, ax          ; es -> video buffer
    
mainloop:

;    call clear

    mov di, [box_y]
    imul di, SCREEN_WIDTH
    add di, [box_x]

    mov bx, SIZE
    mov cx, bx
    mov al, [color]

    .next_row:
        push cx
            rep stosb
        pop cx

        add di, SCREEN_WIDTH - SIZE
        dec bx
    jnz .next_row

    xor dx, dx

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

    inc byte [color]
    cmp byte [color], 0x50
    jle .next
    sub byte [color], 0x18

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
    xor bx, bx
    xor al, al
    mov ah, 0x86
    mov cx, DELAY
    int 0x15
    ret

clear:
    ; al => background color
    ; cx => bytes to write
    xor di, di
    mov al, 0x18
    mov cx, 64000
    rep stosb      ; fill [es:di] with [al] <cx> times
    ret

color: db 0x38

box_dx: dw 1
box_dy: dw 1

box_x: dw (WIDTH - SIZE)/2
box_y: dw (HEIGHT - SIZE)/2

    times 510 - ($-$$) db 0
    dw 0xaa55
