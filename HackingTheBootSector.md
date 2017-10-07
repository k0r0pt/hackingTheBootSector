# Hacking the Boot Sector
  - Sudo (sudiptosarkar@visioplanet.org)

Okay, this seems to be the first article to the first edition of the ezine 
k0r0pt. Like this article, all articles will be divided into sections. This 
article is about hacking the boot sector.


## Table of Contents.

0x01 Introduction
0x02 Details
0x03 Programming
0x04 Programs
0x05 Outtro
0x06 References
0x07 Disclaimer

##.o# 0x01 Introduction #o.

The boot sector has always amused me, and I have always tried to know how it all worked. How the computer sprang up after power, and how it detected all those Operating Systems I had. But after a lot of going through stuffs and research, I could find out less about it, until one day, when I got a paperabout it, and only then I understood that I was not even aware what to search for. This paper [1], was about The Boot Sector, how it worked and how to controlit. Since then I have gone through a couple or so papers on the topic, and adozen programs illustrating how to use the computer after boot up. The how to use part, I was familiar with, as it consisted of BIOS interrupts, about whichI had read while learning assembly & C, and VGA and mouse programming in DOS. And after that, I did a lot of research on using the computer after booting it. This paper is theory, which I came to know about from the references I've mentioned, and my own research, which I have included below. To understand thoseprograms, you must be aware of assembly language, which if you're not, you canlearn from the Internet as there are thousands of tutorials out there.

Another thing that I must tell before going any further, is that I have used two Operating Systems in this research. One is Linux, which runs on my laptop, that happens to be lacking a floppy drive, which I used to boot the other computer, which happens to be running "Microsoft Windows". Sad but true. This is also because, I didn't have a floppy drive in my laptop, otherwise I'd have done it in Linux. So, I used the command line utility Debug for MS-DOS, in order to write to boot sector of the floppy drive. This article will be doing the same. Although I have used Linux for the assembling part, you can do that in Windows as well, in case you use Windows. But in that case, you'd only use the nasm, or some other equivalent assembler for DOS/Windows, like TASM or A386. But if you're more comfortable with the GAS, I'd suggest you do it on Linux, but in which case, you'd have to do the conversion to AT&T format. Keeping in mind, that people are more familiar with the Intel assembler syntax, I'd code in the Intel syntax. Also, dd can be used on Linux to write to the boot sector. But I know little about how to use it. So, I'd leave that upto you to discover.

## .o# 0x02 Details #o.

When you power on the computer, it executes the BIOS, which is located at memory location F000:FFF0. This BIOS is what we also call Basic Input Output System. This BIOS is stored in Electrically Programmable ROM Chips inside the computer. The BIOS then takes control and performs the Power On Self Test, popularly known as the POST. This actually tests for all hardwares and checks them for integrity. It checks the Video card BIOS, and executes it. It is located at memory address 0xC000. Then after checking for other ROM BIOSes, it executes the hard disk BIOS located at 0xC8000. This BIOS is what loads the Operating System.

Back then, the boot sector was made with one objective in mind. That was to enable one computer to run multiple Operating Systems. The boot sector, like all other sectors in a hard disk is 512 Bytes long. So, whatever we put in the boot sector must be 512 Bytes at max. No more than that. However, these standards were laid down by ATA, and only apply to hard disks. in case of other devices, it won't apply ([1]). However, to my surprise, I found a controversy to this fact, while trying to write a 2048 byte code to the first 4 sectors of my floppy disk, only to discover that the code was not executing at all. So, what comes out, is that we only have 512 bytes at our disposal, and we must load another program from disk, if we have to execute something bigger than that.

If I use the debug utility in DOS, to dump the memory address f000:fff0, it would show something like this:

```-d f000:fff0
F000:FFF0 CD 19 E0 00 F0 31 31 2F-32 36 2F 39 39 00 FC 81 .....```

A valid boot Sector must terminate with the two bytes 0xAA55. If a valid Boot Sector is found, the code is loaded into 0000:7C00. Repeating what I said before, as it is merely 512 bytes, that the boot sector code can have, it can't do much. So you must make sure that you write small code, or just execute some other program from it, which is also done in Boot Loaders and Operating Systems.

About writing the code to a magnetic disk, you could simply insert a floppy inside your Windows box, and type w 100 0 0 1 inside DEBUG. This will write the code at 100th location of device 0, which is also the floppy drive A:, from sector 0 to 1.

 ## .o# 0x03 Programming #o.

About the programming part, you could use just the raw code to do the job. No need to link the assembled code, as you're not using it on any OS. You'd be executing it before executing anything else. So, you'd just begin writing, and start doing what you want to do.

In my programs, I've either used BIOS interrupts or have just accessed VGA addresses to do different kinds of things. You could alternatively do many other things. And since there is no other thing in memory, your program will run fast like hell. I assume you have basic knowledge of BIOS interrupts. But if you haven't, fret not because I have well commented code. Alternatively, you could just look for documents out there, that describe the various interrupts I have used. Those will contain full documentation of all the things that can be done with that interrupt.

The first program that I have illustrated here is the classic boot sector program, which you can find just by searching for that. Here, all I do is get control and use BIOS interrupts to print a string. The pre START section does something cryptic though, which is not necessary in normal programs.

```jmp 0x07C0:START```

Here, we just change the offset, which is actually 0000:7c00 to 07c0:START. We do this because it is easier to handle zero offset this way. Then we use the BIOS interrupt 0x10 with ah=0x00 to switch to a video mode. al=0x03 specifies that it is text mode. That is 80x25 and 16 colors. The next step is to print a string stored in memory inside MSG. The comments should explain what's going on. After that, for the reboot, we just make a far jump to 0x0000:0xFFFF. This is the memory location where the reboot code is stored, which is executed after the jump.

The second program just prints out a rectangle on the left end of the screen. We simply draw four lines to make a rectangle. The upper left corner of the screen being 0,0, and the coordinates increasing as we go right and down, we draw the lines at x=50, x=100, y=0 and y=200. To draw the lines, we use the simple algorithm of plotting points on the line. We have used int 0x10 for this. In the graphic initialization, we have used al=0x13, which specifies the vga 256 color mode, which is also known as the graphics mode. As you can see, that we did not make a jump to 0x07c0:START in this program, because we're not using any variables in this program. That is, we do not use any memory references here. So we do not need to change address space. We also do not change ds and es because of this reason.

After that, ah specifies that we're plotting a pixel. al specifies the color. `bh` specifies the memory page, which is 0x00.cx and dx are the x and y coordinates respectively. We go through a loop, as you can see, to change these coordinates.

The third program is the last program that I've included in this section for the graphics part. It is called gfx2.asm. It prints out colors by just incrementing them. We first take one color and draw a vertical line. Then we draw another vertical line on its right side, after incrementing the color. Then we draw another in a similar manner. In this manner, we get what we used to get in olden days' TV transmissions. Vertical color patches. Also, remember that `0x13` switches to 320x200 with 256 colors.

The graphic programs will run faster after the boot, simply because there won't be anything else in the memory. So, we have no competition. It simply works great, and it is fun to work with graphics.

The last program is a classic boot loader, or a bootstrap utility, which explains how 512 bytes are not enough, and how this limit can be bypassed. We read out the floppy disk, where we had written the program ldprogram.asm at the sector number 4. We read that sector, and read 2 sectors starting at sector 4. The start of the code must be understandable by now, because that's what's been happenning in the last few programs. I'll illustrate the disk read part. Here we use the `0x13` BIOS interrupt. We first move `0x0202` to `ax`. `ah` is set to `0x02`, which says read some sectors from a disk. al says that 2 sectors are to be read. `cx` specifies the track and the sector. As we had written 2 sectors starting from the fourth sector, we set it to 0x0004. dh specifies the head position, which is `0x00` and `dl` specifies the drive, that is the device that has to be used. `0x00` is for first floppy drive. So we set `dl` to `0x00`. And finally `ES:BX` is the segment:offset of the buffer where the data is to be loaded. We set the offset to `0x0000`, and do not touch the segment part. Now our program is loaded in the memory location `es:bx`, which is, `es*0x10+bx`. We calculate this up and make a jump to that location. Thus, we succeed in executing our program, and break the 512 byte barrier. Now we are free to do a lot of things, that are beyond these 512 bytes. The rest of the code is no different from the other programs. So, we'd move on to our program ldprogram.asm.

This program is simply printing a long string, which easily crosses the 512 bytes limit, because the string itself is above 600 bytes in length. In fact the program is 1004 bytes, after it is assembled. We'd write this program to the 4th sector of the floppy by using w 100 0 4 2 in the DEBUG program. Again, this is because the floppy drive is drive 0, writing starts at sector number 4, and continues upto 2 consecutive sectors, which provide a space of 1024 bytes, where our program snuggles comfortably. As the rest of the code needs no explanation, we'd directly go on to understand the Print logo part. Here everything is the same as in program 1. But the part which is confusing is why did I add `0x0202` to `bp`. Well I did it because I noticed that without it, the msg started somewhere well before the actual string, and printed gibberish before printing the string. Turned out, that was `0x0202` characters before the actual string.

## .o# 0x04 Programs #o.

* [bs1.asm](src/bs1.asm)
* [gfx1.asm](src/gfx1.asm)
* [gfx2.asm](src/gfx2.asm)
* [bsx.asm](src/bsx.asm)
* [ldprogram.asm](src/ldprogram.asm)

## .o# 0x05 Outtro #o.

Well, it seems that my article has come to an end after all. Before I say goodbye, I'd like to let all my readers know, that this was my first article to the underground, and I hope everyone loves my work.

And enjoy hacking. It's the only fun part of our lives!

## .o# 0x06 References #o.

1. The Boot Sector by Ralph - [http://blacksun.box.sk](http://blacksun.box.sk), [http://awc.rejects.net](http://awc.rejects.net)
2. [Writing Boot Sector Code by Susam Pal](http://susam.in/articles/boot-sector-code/)

## .o# 0x07 Disclaimer #o.


The information contained within this file is purely for educational and informational purposes. If this text is used for illicit purposes or causes any type of damages and/or harm in any direct and/or indirect manner, neither the author nor the k0r0pt staff can be held responsible.

-- Knowledge is responsibility. Use it wisely --