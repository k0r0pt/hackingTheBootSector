; This program is licensed under the GNU General Public Licence v3. 
;
; https://www.github.com/k0r0pt/hackingTheBootSector
;
; Author: Sudo <sudiptosarkar@visioplanet.org>
; Sample asm program, that prints a string with BIOS interrupt 0x10, and then
; makes a far jump to 0000:FFFF to reboot the computer. We tell the processor,
; that the variable declarations are in the same place, as there is code. So, we
; copy the contents of CODE SEGMENT register to DATA SEGMENT register. And then 
; we also copy CS to ES

jmp 0x07C0:START

START:
        push cs                 ; We copy CS to DS, to tell processor, that
        pop ds                  ; variables are in the same place as program
                                ; code.
        ; update es also
        push cs                 ; We copy CS to ES again.
        pop es

; MY working code start here

        mov ax, 0x0003          ; Switch to text mode AH asks processor to 
        int 0x10                ; change video mode. AL is set to 0x03, which is
                                ; the text mode. INT then executes this up.

; Now read sector 4 from floppy disk, where the next program is located

        mov ax, 0x0202
        mov cx, 0x0004
        mov dx, 0x0000
        mov bx, 0x0000
        int 0x13

        mov ax, es
        mov bx, ax
        mov di, 0x10
        mult:
        add ax, bx
        dec di
        jnz mult
        add ax, 0x0000
        jmp ax                  ; Jump control to our program

        times 510-($-$$) db 0   ; Fill remaining space
signature DW 0xAA55             ; 0xAA55 tells BIOS
                                ; that boot sector routine ends.
