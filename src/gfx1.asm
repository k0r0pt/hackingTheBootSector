; This program is licensed under the GNU General Public Licence v3. 
;
; https://www.github.com/k0r0pt/hackingTheBootSector
;
; Author: Sudo <sudiptosarkar@visioplanet.org>
; Sample asm program, that prints a rectangle in BIOS 256 color graphics mode
; and then makes a far jump to 0000:FFFF to reboot the computer.

START:
        mov ax,0x0013		; Switch to 256 color VGA mode
        int 0x10
; Set BG White
        mov ah, 0x07
        mov bh, 0x01
        int 0x10

        mov cx, 200
LOOP_4_LINE1:
        mov ah, 0x0c
        mov al, 0x0f
        mov bh, 0x00
        mov dx, 50
        SUB cx, 0x01
        int 0x10
        jnz LOOP_4_LINE1

        mov cx, 200
LOOP_4_LINE2:
        mov ah, 0x0c
        mov al, 0x0f
        mov bh, 0x00
        mov dx, 100
        sub cx, 0x01
        int 0x10
        jnz LOOP_4_LINE2

        mov dx, 100
LOOP_4_LINE3:
        mov ah, 0x0c
        mov al, 0x0f
        mov bh, 0x00
        mov cx, 0
        sub dx, 0x01
        int 0x10
        mov ax, dx
        sub ax, 50
        jnz LOOP_4_LINE3

        mov dx, 100
LOOP_4_LINE4:
        mov ah, 0x0c
        mov al, 0x0f
        mov bh, 0x00
        mov cx, 200
        sub dx, 0x01
        int 0x10
        mov ax, dx
        sub ax, 50
        jnz LOOP_4_LINE4

WAIT_FOR_KEY_PRESS:
        mov ah,0x00
        int 0x16
REBOOT:
        db 0xEA
        dw 0x0000
        dw 0xFFFF

        times 510-($-$$) db 0
SIGNATURE dw 0xaa55
