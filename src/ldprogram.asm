; This program is licensed under the GNU General Public Licence v3. 
;
; https://www.github.com/k0r0pt/hackingTheBootSector
;
; Author: Sudo <sudiptosarkar@visioplanet.org>
; Sample asm program 2, that prints a logo with BIOS interrupt 0x10, and then
; makes a far jump to 0000:FFFF to reboot the computer. We tell the processor,
; that the variable declarations are in the same place, as there is code. So, we
; copy the contents of CODE SEGMENT register to DATA SEGMENT register. And then 
; we also copy CS to ES. This program is executed by our bootsector example
; program 2.

jmp START

msg db 10,13,\
'           XX          %XX%                %XX%',10,13,\
'           XX         SXXXXS              SXXXXS               XX',10,13,\
'           XX        ;X%  %X;            ;X%  %X;              XX',10,13,\
'           XX  tXX.  %X.  .X%   XX %XXX  %X.  .X%  XX.%XS:   XXXXXXX',10,13,\
'           XX ;XX.   SX    XS   XXSXXXX  SX    XS  XXSXXXX.  XXXXXXX',10,13,\
'           XX;XX.    XX %% XX   XX%.     XX %% XX  XX%  %X%    XX',10,13,\
'           XXXX;     XX %% XX   XX       XX %% XX  XX    XS    XX',10,13,\
'           XXXXX     SX    XS   XX       SX    XS  XX    XX    XX',10,13,\
'           XX tX%    %X.  .X%   XX       %X.  .X%  XX    XS    XX',10,13,\
'           XX  XX:   ;X%  %X;   XX       ;X%  %X;  XX%  %X%    XX.',10,13,\
'           XX  ;XS    SXXXXS    XX        SXXXXS   XXSXXXX.    %XXXX',10,13,\
'           XX   SXt    %XX%     XX         %XX%    XX %XS:     .%XXX',10,13,\
'                                                   XX',10,13,\
'                                                   XX',10,13,\
'                                                   XX',10,13,0

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
                                ; the text mode.
; Print Logo

        mov bx, 0x0004
        mov cx, 0x03c5
        mov bp, msg
        add bp, 0x0202
        mov ax, 0x1301
        int 0x10

; Wait for key press
        mov ah,0x00             ; INT 0x16 reads AH, and sees it is to wait for
        int 0x16                ; a keypress

; Reboot
        db 0xea                 ; We simply declare the bytes. 0xEA is to make
        dw 0x0000               ; far jumps. The next two bytes specify the
        dw 0xffff               ; segment and offset of memory address to jump
                                ; to
