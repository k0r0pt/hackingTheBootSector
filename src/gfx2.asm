; This program is licensed under the GNU General Public Licence v3. 
;
; https://www.github.com/k0r0pt/hackingTheBootSector
;
; Author: Sudo <sudiptosarkar@visioplanet.org>
; Sample asm program, that prints colors as you'd see in those olden TV
; transmissions in BIOS 256 color graphics mode and then makes a far jump to
; 0000:FFFF to reboot the computer.

START:
        mov ax,0x0013
        int 0x10
; Set BG White
        mov ah, 0x07
        mov bh, 0x01
        int 0x10

        mov cx, 0
        mov al, 0x00
        mov bh, 0x00
LOOP_4_X:
        mov dx, 0
LOOP_4_Y:
        mov ah, 0x0c
        int 0x10
       	add dx, 0x01
        mov si, 199
        sub si, dx
        jnz LOOP_4_Y
        add cx, 0x01
        inc al
        mov si, 319
        sub si, cx
        jnz LOOP_4_X

WAIT_FOR_KEY_PRESS:
        mov ah,0x00
        int 0x16
REBOOT:
        db 0xEA
        dw 0x0000
        dw 0xFFFF

        times 510-($-$$) db 0
SIGNATURE dw 0xaa55