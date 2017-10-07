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

jmp 0x07C0:START                ; Program starts executing at 0000:7C00
                                ; But it would be easier to handle offset 0
                                ; So, we make a far jump to 0x07C0:START

MSG DB 'Sudo ru135!',13,10,'fuX0r j00!!!',0
START:
        push CS                 ; We copy CS to DS, to tell processor, that
        pop DS                  ; variables are in the same place as program
	                        ; code.
	; update ES also
        push CS                 ; We copy CS to ES again.
        pop ES

; MY working code start here

        MOV AX,0x0003           ; Switch to text mode AH asks processor to 
        INT 0x10                ; change video mode. AL is set to 0x03, which is
                                ; the text mode. INT then executes this up.
; Print String
        MOV AX,0x1301           ; Print a string AH is to print string. AL 
        MOV BX,0x0001           ; specifies that the string consists of 
        MOV CX,0x1b             ; printable characters. CX has string length
        MOV BP,MSG              ; BP points to the string.
        INT 0x10                ; Calling this interrupt reads registers and 
                                ; prints the string.

; Wait for key press
        MOV AH,0x00             ; INT 0x16 reads AH, and sees it is to wait for
        INT 0x16                ; a keypress

; Reboot
        DB 0xEA                 ; We simply declare the bytes. 0xEA is to make
        DW 0x0000               ; far jumps. The next two bytes specify the
        DW 0xFFFF               ; segment and offset of memory address to jump
                                ; to
        TIMES 510-($-$$) DB 0   ; Fill remaining space
SIGNATURE DW 0xAA55             ; 0xAA55 tells BIOS
                                ; that boot sector routine ends.
