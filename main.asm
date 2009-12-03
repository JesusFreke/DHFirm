; [The "BSD licence"]
; Copyright (c) 2009 Ben Gruver
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in the
;    documentation and/or other materials provided with the distribution.
; 3. The name of the author may not be used to endorse or promote products
;    derived from this software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
; IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
; OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
; IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
; INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
; NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
; THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

KBData		BIT P3.2
HostData	BIT P3.3
KBClock		BIT P3.4
HostClock	BIT P3.5

USING 0

DSEG AT 30h
	Mode: DS 1
	PreviousMode: DS 1
	LastSentByte: DS 1
	LastSentByte_temp: DS 1
	KeyboardEnabled: DS 1
	ShiftPressed: DS 1
	NormalPressed: DS 1

;use the indirect memory starting at 80h for the stack
;we shouldn't need this much stack, but we don't need
;the memory for anything else either
ISEG AT 80h
	STACK:	DS 80h

CSEG AT 0h
	;Execution begins here
	JMP Main

;Interrupt handler for Timer0, used for typematic functionality
CSEG AT 0Bh
	CALL TypematicTimerTick ;Typematic.asm
	RETI

;Interrupt handler for Timer1, used to ensure that the IR LED/receiver
;have time to settle after being turned on
CSEG AT 1Bh
	CALL DemuxSelectorTimerTick ;ScanButtons.asm
	RETI

CSEG AT 1Fh
	Main:
		;initialize the stack
		MOV SP, #STACK-1

		CALL _Reset

		;loop
		MainLoop:
			CALL CheckBufferedData
			CALL CheckButtons
			CALL CheckForHostCommand
		SJMP MainLoop

	_Reset:
		;stop the timers
		CLR TR0
		CLR TR1

		MOV KeyboardEnabled, #01h

		;initialize data
		CALL ResetButtons
		CALL ResetKeyboardBuffer
		;set to normal mode
		MOV Mode, #01h
		;set to unshifted
		MOV ShiftPressed, #00h
		;normal mode button is not pressed
		MOV NormalPressed, #00h

		CALL ResetTypematicValues

		;set timer 0 and timer 1 to '16-bit' mode, and enable their interrupts
		MOV TMOD, #011h
		SETB EA
		SETB ET0
		SETB ET1

		;initialize timer 1 to 100 cycles
		MOV TH1, #0FFh
		MOV TL1, #09Ch

		;Select the first set of buttons
		MOV P1, #0F0h

		;wait ~650mS
		MOV R0, #05h
			ResetLoop1:
			MOV R1, #0FFh
				ResetLoop2:
				MOV R2, #0FFh
					ResetLoop3:
					DJNZ R2, ResetLoop3
			DJNZ R1, ResetLoop2
		DJNZ R0, ResetLoop1

		;send the BAT result
		MOV R1, #0AAh
		CALL SendByte

		;set "normal mode" LED
		MOV P0, #0FDh
	RET

$INCLUDE(HostCommands.asm)
$INCLUDE(KeyboardBuffer.asm)
$INCLUDE(PS2.asm)
$INCLUDE(ScanButtons.asm)
$INCLUDE(Typematic.asm)

END

