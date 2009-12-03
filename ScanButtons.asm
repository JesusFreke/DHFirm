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

DSEG
	ButtonStateAddr: DS 01h
	ButtonIndex: DS 01h
	NASLock: DS 01h

	;ButtonStates is a table containing the state of each button
	;Each button has 4 bits assigned to it, with the following semantics
	;0000 - not pushed
	;0001 - pushed in normal mode
	;0010 - pushed in NAS mode
	;0011 - pushed in function mode
	;0100 - pushed in game mode
	;52 buttons * 4 bits / 8 bytes per bit = 26 (0x1A)
	ButtonStates: DS 1Ah


CSEG
	;Button Abbreviations:
	;R1L	right hand, first finger, left
	;R1U	right hand, first finger, up
	;R1W	right hand, first finger, well
	;R1R	right hand, first finger, right
	;R1D	right hand, first finger, down
	
	;R2D	right hand, second finger, down
	;R2L	right hand, second finger, left
	;R2U	right hand, second finger, up
	;R2W	right hand, second finger, well
	;R2R	right hand, second finger, right
	
	;R3L	right hand, third finger, left
	;R3U	right hand, third finger, up
	;R3W	right hand, third finger, well
	;R3R	right hand, third finger, right
	;R3D	right hand, third finger, down
	
	;R4D	right hand, fourth finger, down
	;R4L	right hand, fourth finger, left
	;R4U	right hand, fourth finger, up
	;R4W	right hand, fourth finger, well
	;R4R	right hand, fourth finger, right
	
	;R5LO	right hand, thumb, lower outside
	;R5UO	right hand, thumb, upper outside
	;R5D	right hand, thumb, down
	;R5DD	right hand, thumb, down down
	;R5I	right hand, thumb, inside
	;R5U	right hand, thumb, up
	
	
	;L4L	left hand, fourth finger, left
	;L4U	left hand, fourth finger, up
	;L4W	left hand, fourth finger, well
	;L4R	left hand, fourth finger, right
	;L4D	left hand, fourth finger, down
	
	;L3D	left hand, third finger, down
	;L3L	left hand, third finger, left
	;L3U	left hand, third finger, up
	;L3W	left hand, third finger, well
	;L3R	left hand, third finger, right
	
	;L2L	left hand, second finger, left
	;L2U	left hand, second finger, up
	;L2W	left hand, second finger, well
	;L2R	left hand, second finger, right
	;L2D	left hand, second finger, down
	
	;L1D	left hand, first finger, down
	;L1L	left hand, first finger, left
	;L1U	left hand, first finger, up
	;L1W	left hand, first finger, well
	;L1R	left hand, first finger, right
	
	;L5LO	left hand, thumb, lower outside
	;L5UO	left hand, thumb, upper outside
	;L5D	left hand, thumb, down
	;L5DD	left hand, thumb, down down
	;L5I	left hand, thumb, inside
	;L5U	left hand, thumb, up


	NormalMap:
		DB 23h	;0	R1L	'D'
		DB 34h	;1	R1U	'G'
		DB 71h	;2	L4L	DEL (extended)
		DB 4Ah	;3	L4U	'/'
		DB 33h	;4	R1W	'H'
		DB 52h	;5	R1R	'''
		DB 1Ch	;6	L4W	'A'
		DB 46h	;7	L4R	'(' (+shift)
		DB 3Ah	;8	R1D	'M'
		DB 21h	;9	R2D	'C'
		DB 4Ch	;10	L4D	';'
		DB 42h	;11	L3D	'K'
		DB 2Bh	;12	R2L	'F'
		DB 1Dh	;13	R2U	'W'
		DB 76h	;14	L3L	ESC
		DB 41h	;15	L3U	','
		DB 2Ch	;16	R2W	'T'
		DB 0eh	;17	R2R	'`'
		DB 44h	;18	L3W	'O'
		DB 22h	;19	L3R	'X'
		DB 32h	;20	R3L	'B'
		DB 2Ah	;21	R3U	'V'
		DB 0Eh	;22	L2L	'`'
		DB 49h	;23	L2U	'.'
		DB 31h	;24	R3W	'N'
		DB 1Fh	;25	R3R	WIN (extended)
		DB 24h	;26	L2W	'E'
		DB 35h	;27	L2R	'Y'
		DB 2Dh	;28	R3D	'R'
		DB 4Bh	;29	R4D	'L'
		DB 3Bh	;30	L2D	'J'
		DB 4Dh	;31	L1D	'P'
		DB 45h	;32	R4L	')' (+shift)
		DB 1Ah	;33	R4U	'Z'
		DB 52h	;34	L1L	'"' (+shift)
		DB 15h	;35	L1U	'Q'
		DB 1Bh	;36	R4W	'S'
		DB 5Dh	;37	R4R	'\'
		DB 3Ch	;38	L1W	'U'
		DB 43h	;39	L1R	'I'
		DB 11h	;40	R5LO	ALT
		DB 66h	;41	R5UO	Backspace
		DB 14h	;42	L5LO	CTRL
		DB 0Dh	;43	L5UO	TAB
		DB 00h	;44	R5D	NAS Mode (keyboard only)
		DB 00h	;45	R5DD	NAS Lock (keyboard only)
		DB 12h	;46	L5D	Shift
		DB 58h	;47	L5DD	CAPS Lock
		DB 29h	;48	R5I	Space
		DB 00h	;49	R5U	Function Mode (keyboard only)
		DB 5Ah	;50	L5I	Enter
		DB 00h	;51	L5U	Normal Mode (keyboard only)
	
	NASMap:
		DB 36h	;0	R1L	'6'
		DB 3Dh	;1	R1U	'&' (+shift)
		DB 71h	;2	L4L	DEL (extended)
		DB 16h	;3	L4U	'!' (+shift)
		DB 3Dh	;4	R1W	'7'
		DB 00h	;5	R1R	TBD
		DB 16h	;6	L4W	'1'
		DB 54h	;7	L4R	'{' (+shift)
		DB 55h	;8	R1D	'+' (+shift)
		DB 00h	;9	R2D	TBD
		DB 55h	;10	L4D	'='
		DB 00h	;11	L3D	TBD
		DB 36h	;12	R2L	'^' (+shift)
		DB 3Eh	;13	R2U	'^' (+shift)
		DB 76h	;14	L3L	ESC
		DB 1Eh	;15	L3U	'@' (+shift)
		DB 3Eh	;16	R2W	'8'
		DB 00h	;17	R2R	TBD
		DB 1Eh	;18	L3W	'2'
		DB 77h	;19	L3R	NUM LOCK
		DB 00h	;20	R3L	TBD
		DB 54h	;21	R3U	'['
		DB 00h	;22	L2L	TBD
		DB 26h	;23	L2U	'#' (+shift)
		DB 46h	;24	R3W	'9'
		DB 2Fh	;25	R3R	APP (extended)
		DB 26h	;26	L2W	'3'
		DB 00h	;27	L2R	TBD
		DB 00h	;28	R3D	TBD
		DB 00h	;29	R4D	TBD
		DB 2Eh	;30	L2D	'%' (+shift)
		DB 4Eh	;31	L1D	'-'
		DB 5Bh	;32	R4L	'}' (+shift)
		DB 5Bh	;33	R4U	']'
		DB 00h	;34	L1L	TBD
		DB 25h	;35	L1U	'$' (+shift)
		DB 45h	;36	R4W	'0'
		DB 00h	;37	R4R	TBD
		DB 25h	;38	L1W	'4'
		DB 2Eh	;39	L1R	'5'
		DB 11h	;40	R5LO	ALT
		DB 66h	;41	R5UO	Backspace
		DB 14h	;42	L5LO	CTRL
		DB 0Dh	;43	L5UO	TAB
		DB 00h	;44	R5D	NAS Mode (keyboard only)
		DB 00h	;45	R5DD	NAS Lock (keyboard only)
		DB 12h	;46	L5D	Shift
		DB 58h	;47	L5DD	CAPS Lock
		DB 29h	;48	R5I	Space
		DB 00h	;49	R5U	Function Mode (keyboard only)
		DB 5Ah	;50	L5I	Enter
		DB 00h	;51	L5U	Normal Mode (keyboard only)
	
	FMap:
		DB 6Bh	;0	R1L	Left Arrow (extended)
		DB 75h	;1	R1U	Up Arrow (extended)
		DB 71h	;2	L4L	DEL (extended)
		DB 06h	;3	L4U	F2
		DB 6Ch	;4	R1W	Home (extended)
		DB 74h	;5	R1R	Right Arrow (extended)
		DB 00h	;6	L4W	TBD
		DB 7Eh	;7	L4R	Scroll Lock
		DB 72h	;8	R1D	Down Arrow (extended)
		DB 83h	;9	R2D	F7
		DB 05h	;10	L4D	F1
		DB 04h	;11	L3D	F3
		DB 69h	;12	R2L	End (extended)
		DB 0Ah	;13	R2U	F8
		DB 76h	;14	L3L	ESC
		DB 0Ch	;15	L3U	F4
		DB 00h	;16	R2W	TBD
		DB 12h	;17	R2R	Shift
		DB 00h	;18	L3W	TBD
		DB 77h	;19	L3R	NUM LOCK
		DB 70h	;20	R3L	Insert (extended)
		DB 09h	;21	R3U	F10
		DB 00h	;22	L2L	TBD
		DB 0Bh	;23	L2U	F6
		DB 00h	;24	R3W	Print Screen (special scan code)
		DB 1Fh	;25	R3R	WIN (extended)
		DB 00h	;26	L2W	TBD
		DB 00h	;27	L2R	TBD
		DB 01h	;28	R3D	F9
		DB 7Ah	;29	R4D	Page Down (extended)
		DB 03h	;30	L2D	F5
		DB 72h	;31	L1D	Down Arrow (extended)
		DB 78h	;32	R4L	F11
		DB 7Dh	;33	R4U	Page Up (extended)
		DB 6Bh	;34	L1L	Left Arrow (extended)
		DB 75h	;35	L1U	Up Arrow (extended)
		DB 00h	;36	R4W	Pause (special scan code)
		DB 07h	;37	R4R	F12
		DB 6Ch	;38	L1W	Home (Extended)
		DB 74h	;39	L1R	Right Arrow (extended)
		DB 11h	;40	R5LO	ALT
		DB 66h	;41	R5UO	Backspace
		DB 14h	;42	L5LO	CTRL
		DB 0Dh	;43	L5UO	TAB
		DB 00h	;44	R5D	NAS Mode (keyboard only)
		DB 00h	;45	R5DD	NAS Lock (keyboard only)
		DB 12h	;46	L5D	Shift
		DB 58h	;47	L5DD	CAPS Lock
		DB 29h	;48	R5I	Space
		DB 00h	;49	R5U	Function Mode (keyboard only)
		DB 5Ah	;50	L5I	Enter
		DB 00h	;51	L5U	Normal Mode (keyboard only)
	
	GameMap:
		DB 23h	;0	R1L	'D'
		DB 34h	;1	R1U	'G'
		DB 2Eh	;2	L4L	'5'
		DB 16h	;3	L4U	'1'
		DB 33h	;4	R1W	'H'
		DB 52h	;5	R1R	'''
		DB 1Ch	;6	L4W	'A'
		DB 46h	;7	L4R	'9'
		DB 3Ah	;8	R1D	'M'
		DB 21h	;9	R2D	'C'
		DB 4Ch	;10	L4D	';'
		DB 42h	;11	L3D	'K'
		DB 2Bh	;12	R2L	'F'
		DB 1Dh	;13	R2U	'W'
		DB 36h	;14	L3L	'6'
		DB 1Eh	;15	L3U	'2'
		DB 2Ch	;16	R2W	'T'
		DB 0eh	;17	R2R	'`'
		DB 44h	;18	L3W	'O'
		DB 45h	;19	L3R	'0'
		DB 32h	;20	R3L	'B'
		DB 2Ah	;21	R3U	'V'
		DB 3Dh	;22	L2L	'7'
		DB 26h	;23	L2U	'3'
		DB 31h	;24	R3W	'N'
		DB 1Fh	;25	R3R	WIN (extended)
		DB 24h	;26	L2W	'E'
		DB 55h	;27	L2R	'='
		DB 2Dh	;28	R3D	'R'
		DB 4Bh	;29	R4D	'L'
		DB 3Bh	;30	L2D	'J'
		DB 4Dh	;31	L1D	'P'
		DB 45h	;32	R4L	')' (+shift)
		DB 1Ah	;33	R4U	'Z'
		DB 3Eh	;34	L1L	'8'
		DB 25h	;35	L1U	'4'
		DB 1Bh	;36	R4W	'S'
		DB 5Dh	;37	R4R	'\'
		DB 3Ch	;38	L1W	'U'
		DB 4Eh	;39	L1R	'-'
		DB 11h	;40	R5LO	ALT
		DB 66h	;41	R5UO	Backspace
		DB 14h	;42	L5LO	CTRL
		DB 11h	;43	L5UO	ALT
		DB 00h	;44	R5D	NAS Mode (keyboard only)
		DB 00h	;45	R5DD	NAS Lock (keyboard only)
		DB 12h	;46	L5D	Shift
		DB 58h	;47	L5DD	CAPS Lock
		DB 29h	;48	R5I	Space
		DB 00h	;49	R5U	Function Mode (keyboard only)
		DB 29h	;50	L5I	Space
		DB 00h	;51	L5U	Normal Mode (keyboard only)
	
	LEDTable:
		DB 00h	;00h not used
		DB 0Dh	;01h normal mode
		DB 0Eh	;02h NAS mode
		DB 0Bh	;03h Function mode



	ResetButtons:
		CLR A
		MOV R1, #01ah
	
		MOV R0, #ButtonStates
	
		ResetButtonsLoop:
			MOV @R0, A
			INC R0
		DJNZ R1, ResetButtonsLoop
	
		MOV NASLock, #00h
	RET
	
	CheckButtons:
		;The selector value that was on the port when the function started
		CurrentSelector EQU R2
		;Bits 0-3 ontain the states of the 4 button pins (4-7) on the port when the function started
		CurrentButtonState EQU R3
		;Bits 0-3 are boolean flags that indicate whether the button changed states
		ButtonsChanged EQU R4
	
	
		;make sure the keyboard is enabled
		MOV A, KeyboardEnabled
		JNZ CheckTimer1
		RET
	
		;make sure that at least 100uS has passed since the previous selector change
		;This gives the light transmitters/receivers time to come up to steady-state voltage
		;Timer1 will disable itself once 100uS have passed
		CheckTimer1:
		MOV C, TR1
		JC CheckTimer1
	
		;get the current selector value
		MOV A, P1
		ANL A, #0Fh
		MOV CurrentSelector, A
	
		;store the current button state
		MOV CurrentButtonState, P1
	
		;increment the selector and output it to the demux (P1), so that the next button
		;state will be ready for the next iteration
		MOV A, CurrentSelector
		INC A
		CJNE A, #0Dh, UpdateSelector
		CLR A
		UpdateSelector:
		;the upper 4 bits (of the latch) are always 1
		ORL A, #0F0h
		MOV P1, A
		;restart the selector timer, so we know once 100uS have passed
		SETB TR1
	
		;The selector value * 2 is the index into the ButtonStates table
		MOV A, CurrentSelector
		CLR C
		RLC A
		ADD A, #ButtonStates
		MOV ButtonStateAddr, A
	
		;load A with the saved button state for the first two buttons
		MOV R0, A
		MOV A, @R0
	
		;set bits 4 and 5 of A based on the saved state of the first two buttons. The
		;bit for that button should be 1 if it is pressed (in any mode), or 0 if
		;not pressed
		MOV C, ACC.4
		ORL C, ACC.5
		ORL C, ACC.6
		ORL C, ACC.7
		MOV ACC.5, C
	
		MOV C, ACC.0
		ORL C, ACC.1
		ORL C, ACC.2
		ORL C, ACC.3
		MOV ACC.4, C
	
		MOV R1, A
	
		;load A with the saved button state for the second two buttons
		INC R0
		MOV A, @R0
		DEC R0
	
		;set bits 6 and 7 of A based on the saved state of the first two buttons. The
		;bit for that button should be 1 if it is pressed (in any mode), or 0 if
		;not pressed
		MOV C, ACC.4
		ORL C, ACC.5
		ORL C, ACC.6
		ORL C, ACC.7
		MOV ACC.7, C
	
		MOV C, ACC.0
		ORL C, ACC.1
		ORL C, ACC.2
		ORL C, ACC.3
		MOV ACC.6, C
	
		;or in bits 4 and 5 for the first two buttons
		ANL A, #0C0h
		ORL A, R1
	
		;compare the saved button states with the current button states
		;if any bit is 1, then that button changed states
		;Only the most significant 4 bits are relevant. The least significant 4 bits are ignored
		XRL A, CurrentButtonState
		ANL A, #0F0h
		MOV ButtonsChanged, A
	
		JNZ StartCheckButtons
	
		RET
	
		StartCheckButtons:
	
		;one of the buttons changed state. Stop the timer. We'll restart it in
		;the key press/release handler
		CLR TR0
	
		CheckButton0:
			;If ACC.4 is 1, then the button was either pressed or released
			MOV C, ACC.4
			JNC CheckButton1
	
			;Store the index for this button in ButtonIndex
			MOV A, CurrentSelector
			RL A
			RL A
			MOV ButtonIndex, A
	
			;was the button pressed or released?
			MOV A, CurrentButtonState
			MOV C, ACC.4
			JNC Button0Released
	
			MOV A, Mode
			CALL HandleButtonPress
	
			;update the saved button state
			MOV A, Mode
			;get the saved button state
			MOV B, @R0
			;move the current mode to the appropriate bits for this button
			MOV C, ACC.0
			MOV B.0, C
			MOV C, ACC.1
			MOV B.1, C
			MOV C, ACC.2
			MOV B.2, C
			MOV C, ACC.3
			MOV B.3, C
			;and save it back
			MOV @R0, B
			SJMP CheckButton1
	
			Button0Released:
				;Load the button state into bits 0-3 of A
				MOV A, @R0
				ANL A, #0Fh
				CALL HandleButtonRelease
				;update the saved button state
				MOV A, @R0
				ANL A, #0F0h
				MOV @R0, A
	
		CheckButton1:
			;If bit 4 is 1, then the button was either pressed or released
			MOV A, ButtonsChanged
			MOV C, ACC.5
			JNC CheckButton2
	
			;Store the index for this button in ButtonIndex
			MOV A, CurrentSelector
			RL A
			RL A
			INC A
			MOV ButtonIndex, A
	
			;was the button pressed or released?
			MOV A, CurrentButtonState
			MOV C, ACC.5
			JNC Button1Released
	
			MOV A, Mode
			CALL HandleButtonPress
	
			;update the saved button state
			MOV A, Mode
			;get the saved button state
			MOV B, @R0
			;move the current mode to the appropriate bits for this button
			MOV C, ACC.0
			MOV B.4, C
			MOV C, ACC.1
			MOV B.5, C
			MOV C, ACC.2
			MOV B.6, C
			MOV C, ACC.3
			MOV B.7, C
			;and save it back
			MOV @R0, B
			SJMP CheckButton2
	
			Button1Released:
				;Load the button state into bits 0-3 of A
				MOV A, @R0
				SWAP A
				ANL A, #0Fh
				CALL HandleButtonRelease
				;update the saved button state
				MOV A, @R0
				ANL A, #0Fh
				MOV @R0, A
	
	
		CheckButton2:
			;move to the next byte in the table
			INC R0
	
			;If bit 6 is 1, then the button was either pressed or released
			MOV A, ButtonsChanged
			MOV C, ACC.6
			JNC CheckButton3
	
			;Store the index for this button in ButtonIndex
			MOV A, CurrentSelector
			RL A
			RL A
			ADD A, #02h
			MOV ButtonIndex, A
	
			;was the button pressed or released?
			MOV A, CurrentButtonState
			MOV C, ACC.6
			JNC Button2Released
	
			MOV A, Mode
			CALL HandleButtonPress
	
			;update the saved button state
			MOV A, Mode
			;get the saved button state
			MOV B, @R0
			;move the current mode to the appropriate bits for this button
			MOV C, ACC.0
			MOV B.0, C
			MOV C, ACC.1
			MOV B.1, C
			MOV C, ACC.2
			MOV B.2, C
			MOV C, ACC.3
			MOV B.3, C
			;and save it back
			MOV @R0, B
			SJMP CheckButton3
	
			Button2Released:
				;Load the button state into bits 0 and 1 of A
				MOV A, @R0
				ANL A, #0Fh
				CALL HandleButtonRelease
				;update the saved button state
				MOV A, @R0
				ANL A, #0F0h
				MOV @R0, A
	
		CheckButton3:
			;If bit 7 is 1, then the button was either pressed or released
			MOV A, ButtonsChanged
			MOV C, ACC.7
			JNC CheckButtonsEnd
	
			;Store the index for this button in ButtonIndex
			MOV A, CurrentSelector
			RL A
			RL A
			ADD A, #03h
			MOV ButtonIndex, A
	
			;was the button pressed or released?
			MOV A, CurrentButtonState
			MOV C, ACC.7
			JNC Button3Released
	
			MOV A, Mode
			CALL HandleButtonPress
	
			;update the saved button state
			MOV A, Mode
			;get the saved button state
			MOV B, @R0
			;move the current mode to the appropriate bits for this button
			MOV C, ACC.0
			MOV B.4, C
			MOV C, ACC.1
			MOV B.5, C
			MOV C, ACC.2
			MOV B.6, C
			MOV C, ACC.3
			MOV B.7, C
			;and save it back
			MOV @R0, B
			SJMP CheckButtonsEnd
	
			Button3Released:
	
	
				;Load the button state into bits 0 and 1 of A
				MOV A, @R0
				SWAP A
				ANL A, #0Fh
				CALL HandleButtonRelease
				;update the saved button state
				MOV A, @R0
				ANL A, #0Fh
				MOV @R0, A
	
	CheckButtonsEnd:
	RET
	
	;This takes the appropriate action based on the button that was pressed
	;For most keys, it will send the appropriate scancodes
	;For "special" keys (NAS, function mode, modifiers, etc.), it will execute
	;the appropriate functionality
	;Parameters:
	;  A - the button state the button that was pressed
	;	ButtonIndex - the index of the button that was pressed
	;Modifies:
	;	Registers:
	;		DPTR, A, R1, R6, R7, PSW
	;	Memory:
	;		LastSentByte, KeyboardBuffer, KeyboardBufferPosition, PreviousMode, Mode
	;	Ports:
	;		KBData, KBClock, P0
	HandleButtonPress:
		;CheckButtons uses these registers, so we need to save and restore
		;their value
		PUSH AR0
		PUSH AR2
		PUSH AR3
		PUSH AR5
		CALL HandleButtonPress_internal
		POP AR5
		POP AR3
		POP AR2
		POP AR0
	RET
	
	HandleButtonPress_internal:
		MOV R2, A
		;Load the button index
		MOV A, ButtonIndex
		;Each entry in NormalPressTable is 3 bytes
		MOV B, #03h
		MUL AB
		MOV R6, A
	
		MOV DPTR, #PressModeTable
		MOV A, R2
		RL A
		RL A
		JMP @A+DPTR
	
		PressModeTable: ;put in extra nops, so each entry is an even 4 bytes
			nop
			nop
			nop
			nop
			LJMP HandleButtonPress_NormalMode
			nop
			LJMP HandleButtonPress_NASMode
			nop
			LJMP HandleButtonPress_FMode
			nop
			LJMP HandleButtonPress_GameMode
			nop
	
		HandleButtonPress_NormalMode:
			;restore the table index from R6
			MOV A, R6
			MOV R0, #High(NormalMap)
			MOV R1, #Low(NormalMap)
			MOV DPTR, #NormalPressTable
			JMP @A+DPTR
	
			NormalPressTable:
				LJMP NormalPress ;0
				LJMP NormalPress ;1
				LJMP ExtendedPress ;2
				LJMP NormalPress ;3
				LJMP NormalPress ;4
				LJMP NormalPress ;5
				LJMP NormalPress ;6
				LJMP ShiftPress ;7
				LJMP NormalPress ;8
				LJMP NormalPress ;9
				LJMP NormalPress_CheckNormalHold ;10
				LJMP NormalPress_CheckNormalHold ;11
				LJMP NormalPress ;12
				LJMP NormalPress ;13
				LJMP NormalPress ;14
				LJMP NormalPress ;15
				LJMP NormalPress ;16
				LJMP NormalPress ;17
				LJMP NormalPress ;18
				LJMP NormalPress ;19
				LJMP NormalPress ;20
				LJMP NormalPress ;21
				LJMP NormalPress ;22
				LJMP NormalPress ;23
				LJMP NormalPress ;24
				LJMP ExtendedPress ;25
				LJMP NormalPress ;26
				LJMP NormalPress ;27
				LJMP NormalPress ;28
				LJMP NormalPress ;29
				LJMP NormalPress_CheckNormalHold ;30
				LJMP NormalPress_CheckNormalHold ;31
				LJMP ShiftPress ;32
				LJMP NormalPress ;33
				LJMP ShiftPress ;34
				LJMP NormalPress ;35
				LJMP NormalPress ;36
				LJMP NormalPress ;37
				LJMP NormalPress ;38
				LJMP NormalPress ;39
				LJMP NormalPress ;40
				LJMP NormalPress ;41
				LJMP NormalPress ;42
				LJMP NormalPress ;43
				LJMP NASModePress ;44
				LJMP NASLockPress ;45
				LJMP ShiftKeyPress ;46
				LJMP NormalPress ;47
				LJMP NormalPress ;48
				LJMP FunctionModePress ;49
				LJMP NormalPress ;50
				LJMP NormalModePress ;51
	
		HandleButtonPress_NASMode:
			;restore the table index from R6
			MOV A, R6
			MOV R0, #High(NASMap)
			MOV R1, #Low(NASMap)
			MOV DPTR, #NASPressTable
			JMP @A+DPTR
	
			NASPressTable:
				LJMP NormalPress ;0
				LJMP ShiftPress ;1
				LJMP ExtendedPress ;2
				LJMP ShiftPress ;3
				LJMP NormalPress ;4
				LJMP TBD ;5
				LJMP NormalPress ;6
				LJMP ShiftPress ;7
				LJMP ShiftPress ;8
				LJMP TBD ;9
				LJMP NormalPress ;10
				LJMP TBD ;11
				LJMP ShiftPress ;12
				LJMP ShiftPress ;13
				LJMP NormalPress ;14
				LJMP ShiftPress ;15
				LJMP NormalPress ;16
				LJMP TBD ;17
				LJMP NormalPress ;18
				LJMP NormalPress ;19
				LJMP TBD ;20
				LJMP NormalPress ;21
				LJMP TBD ;22
				LJMP ShiftPress ;23
				LJMP NormalPress ;24
				LJMP ExtendedPress ;25
				LJMP NormalPress ;26
				LJMP TBD ;27
				LJMP TBD ;28
				LJMP TBD ;29
				LJMP ShiftPress ;30
				LJMP NormalPress ;31
				LJMP ShiftPress ;32
				LJMP NormalPress ;33
				LJMP TBD ;34
				LJMP ShiftPress ;35
				LJMP NormalPress ;36
				LJMP TBD ;37
				LJMP NormalPress ;38
				LJMP NormalPress ;39
				LJMP NormalPress ;40
				LJMP NormalPress ;41
				LJMP NormalPress ;42
				LJMP NormalPress ;43
				LJMP NASModePress ;44
				LJMP NASLockPress ;45
				LJMP ShiftKeyPress ;46
				LJMP NormalPress ;47
				LJMP NormalPress ;48
				LJMP FunctionModePress ;49
				LJMP NormalPress ;50
				LJMP NormalModePress ;51
	
		HandleButtonPress_FMode:
			;restore the table index from R6
			MOV A, R6
			MOV R0, #High(FMap)
			MOV R1, #Low(FMap)
			MOV DPTR, #FPressTable
			JMP @A+DPTR
	
			FPressTable:
				LJMP ExtendedPress ;0
				LJMP ExtendedPress ;1
				LJMP ExtendedPress ;2
				LJMP NormalPress ;3
				LJMP ExtendedPress ;4
				LJMP ExtendedPress ;5
				LJMP TBD ;6
				LJMP NormalPress ;7
				LJMP ExtendedPress ;8
				LJMP NormalPress ;9
				LJMP NormalPress ;10
				LJMP NormalPress ;11
				LJMP ExtendedPress ;12
				LJMP NormalPress ;13
				LJMP NormalPress ;14
				LJMP NormalPress ;15
				LJMP TBD ;16
				LJMP NormalPress ;17
				LJMP TBD ;18
				LJMP NormalPress ;19
				LJMP ExtendedPress ;20
				LJMP NormalPress ;21
				LJMP TBD ;22
				LJMP NormalPress ;23
				LJMP PrintScreenPress ;24
				LJMP ExtendedPress ;25
				LJMP TBD ;26
				LJMP TBD ;27
				LJMP NormalPress ;28
				LJMP ExtendedPress ;29
				LJMP NormalPress ;30
				LJMP ExtendedPress ;31
				LJMP NormalPress ;32
				LJMP ExtendedPress ;33
				LJMP ExtendedPress ;34
				LJMP ExtendedPress ;35
				LJMP PausePress ;36
				LJMP NormalPress ;37
				LJMP ExtendedPress ;38
				LJMP ExtendedPress ;39
				LJMP NormalPress ;40
				LJMP NormalPress ;41
				LJMP NormalPress ;42
				LJMP NormalPress ;43
				LJMP NASModePress ;44
				LJMP NASLockPress ;45
				LJMP ShiftKeyPress ;46
				LJMP NormalPress ;47
				LJMP NormalPress ;48
				LJMP FunctionModePress ;49
				LJMP NormalPress ;50
				LJMP NormalModePress ;51
	
		HandleButtonPress_GameMode:
			;restore the table index from R6
			MOV A, R6
			MOV R0, #High(GameMap)
			MOV R1, #Low(GameMap)
			MOV DPTR, #GamePressTable
			JMP @A+DPTR
	
			GamePressTable:
				LJMP NormalPress ;0
				LJMP NormalPress ;1
				LJMP NormalPress ;2
				LJMP NormalPress ;3
				LJMP NormalPress ;4
				LJMP NormalPress ;5
				LJMP NormalPress ;6
				LJMP NormalPress ;7
				LJMP NormalPress ;8
				LJMP NormalPress ;9
				LJMP NormalPress ;10
				LJMP NormalPress ;11
				LJMP NormalPress ;12
				LJMP NormalPress ;13
				LJMP NormalPress ;14
				LJMP NormalPress ;15
				LJMP NormalPress ;16
				LJMP NormalPress ;17
				LJMP NormalPress ;18
				LJMP NormalPress ;19
				LJMP NormalPress ;20
				LJMP NormalPress ;21
				LJMP NormalPress ;22
				LJMP NormalPress ;23
				LJMP NormalPress ;24
				LJMP ExtendedPress ;25
				LJMP NormalPress ;26
				LJMP NormalPress ;27
				LJMP NormalPress ;28
				LJMP NormalPress ;29
				LJMP NormalPress ;30
				LJMP NormalPress ;31
				LJMP ShiftPress ;32
				LJMP NormalPress ;33
				LJMP NormalPress ;34
				LJMP NormalPress ;35
				LJMP NormalPress ;36
				LJMP NormalPress ;37
				LJMP NormalPress ;38
				LJMP NormalPress ;39
				LJMP NormalPress ;40
				LJMP NormalPress ;41
				LJMP NormalPress ;42
				LJMP NormalPress ;43
				LJMP NASModePress ;44
				LJMP NASLockPress ;45
				LJMP ShiftKeyPress ;46
				LJMP NormalPress ;47
				LJMP NormalPress ;48
				LJMP FunctionModePress ;49
				LJMP NormalPress ;50
				LJMP NormalModePress ;51
	
	
	;This takes the appropriate action based on the button that was released
	;For most keys, it will send the appropriate scancodes
	;For "special" keys (NAS, function mode, modifiers, etc.), it will execute
	;the appropriate functionality
	;Parameters:
	;  A - the button state the button that was released
	;	ButtonIndex - the index of the button that was pressed
	;Modifies:
	;	Registers:
	;		DPTR, A, R1, R6, R7, PSW
	;	Memory:
	;		LastSentByte, KeyboardBuffer, KeyboardBufferPosition, Mode
	;	Ports:
	;		KBData, KBClock, P0
	HandleButtonRelease:
		;CheckButtons uses these registers, so we need to save and restore
		;their value
		PUSH AR0
		PUSH AR2
		PUSH AR3
		PUSH AR5
		CALL HandleButtonRelease_internal
		POP AR5
		POP AR3
		POP AR2
		POP AR0
	
		;re-enable the typematic timer. It will disable itself
		;if the button is no longer pressed
		SETB TR0
	RET
	
	HandleButtonRelease_internal:
		;save the button state
		MOV R2, A
	
		;Load the button index
		MOV A, ButtonIndex
		;Each entry in NormalPressTable is 3 bytes
		MOV B, #03h
		MUL AB
		MOV R6, A
	
		;The button state (in R2) indicates which mode the button was pressed in
		MOV DPTR, #ReleaseModeTable
		MOV A, R2
		RL A
		RL A
		JMP @A+DPTR
	
		ReleaseModeTable: ;put in extra nops, so each entry is an even 4 bytes
			nop
			nop
			nop
			nop
			LJMP HandleButtonRelease_NormalMode
			nop
			LJMP HandleButtonRelease_NASMode
			nop
			LJMP HandleButtonRelease_FMode
			nop
			LJMP HandleButtonRelease_GameMode
			nop
	
	
		HandleButtonRelease_NormalMode:
			;restore the table index from R6
			MOV A, R6
			MOV R0, #High(NormalMap)
			MOV R1, #Low(NormalMap)
			MOV DPTR, #NormalReleaseTable
			JMP @A+DPTR
	
			NormalReleaseTable:
				LJMP NormalRelease ;0
				LJMP NormalRelease ;1
				LJMP ExtendedRelease ;2
				LJMP NormalRelease ;3
				LJMP NormalRelease ;4
				LJMP NormalRelease ;5
				LJMP NormalRelease ;6
				LJMP NormalRelease ;7
				LJMP NormalRelease ;8
				LJMP NormalRelease ;9
				LJMP NormalRelease ;10
				LJMP NormalRelease ;11
				LJMP NormalRelease ;12
				LJMP NormalRelease ;13
				LJMP NormalRelease ;14
				LJMP NormalRelease ;15
				LJMP NormalRelease ;16
				LJMP NormalRelease ;17
				LJMP NormalRelease ;18
				LJMP NormalRelease ;19
				LJMP NormalRelease ;20
				LJMP NormalRelease ;21
				LJMP NormalRelease ;22
				LJMP NormalRelease ;23
				LJMP NormalRelease ;24
				LJMP ExtendedRelease ;25
				LJMP NormalRelease ;26
				LJMP NormalRelease ;27
				LJMP NormalRelease ;28
				LJMP NormalRelease ;29
				LJMP NormalRelease ;30
				LJMP NormalRelease ;31
				LJMP NormalRelease ;32
				LJMP NormalRelease ;33
				LJMP NormalRelease ;34
				LJMP NormalRelease ;35
				LJMP NormalRelease ;36
				LJMP NormalRelease ;37
				LJMP NormalRelease ;38
				LJMP NormalRelease ;39
				LJMP NormalRelease ;40
				LJMP NormalRelease ;41
				LJMP NormalRelease ;42
				LJMP NormalRelease ;43
				LJMP NASModeRelease ;44
				LJMP NASLockRelease ;45
				LJMP ShiftKeyRelease ;46
				LJMP NormalRelease ;47
				LJMP NormalRelease ;48
				LJMP FunctionModeRelease ;49
				LJMP NormalRelease ;50
				LJMP NormalModeRelease ;51
	
		HandleButtonRelease_NASMode:
			;restore the table index from R6
			MOV A, R6
			MOV R0, #High(NASMap)
			MOV R1, #Low(NASMap)
			MOV DPTR, #NASReleaseTable
			JMP @A+DPTR
	
			NASReleaseTable:
				LJMP NormalRelease ;0
				LJMP NormalRelease ;1
				LJMP ExtendedRelease ;2
				LJMP NormalRelease ;3
				LJMP NormalRelease ;4
				LJMP TBD ;5
				LJMP NormalRelease ;6
				LJMP NormalRelease ;7
				LJMP NormalRelease ;8
				LJMP TBD ;9
				LJMP NormalRelease ;10
				LJMP TBD ;11
				LJMP NormalRelease ;12
				LJMP NormalRelease ;13
				LJMP NormalRelease ;14
				LJMP NormalRelease ;15
				LJMP NormalRelease ;16
				LJMP TBD ;17
				LJMP NormalRelease ;18
				LJMP NormalRelease ;19
				LJMP TBD ;20
				LJMP NormalRelease ;21
				LJMP TBD ;22
				LJMP NormalRelease ;23
				LJMP NormalRelease ;24
				LJMP ExtendedRelease ;25
				LJMP NormalRelease ;26
				LJMP TBD ;27
				LJMP TBD ;28
				LJMP TBD ;29
				LJMP NormalRelease ;30
				LJMP NormalRelease ;31
				LJMP NormalRelease ;32
				LJMP NormalRelease ;33
				LJMP TBD ;34
				LJMP NormalRelease ;35
				LJMP NormalRelease ;36
				LJMP TBD ;37
				LJMP NormalRelease ;38
				LJMP NormalRelease ;39
				LJMP NormalRelease ;40
				LJMP NormalRelease ;41
				LJMP NormalRelease ;42
				LJMP NormalRelease ;43
				LJMP NASModeRelease ;44
				LJMP NASLockRelease ;45
				LJMP ShiftKeyRelease ;46
				LJMP NormalRelease ;47
				LJMP NormalRelease ;48
				LJMP FunctionModeRelease ;49
				LJMP NormalRelease ;50
				LJMP NormalModeRelease ;51
	
		HandleButtonRelease_FMode:
			;restore the table index from R6
			MOV A, R6
			MOV R0, #High(FMap)
			MOV R1, #Low(FMap)
			MOV DPTR, #FReleaseTable
			JMP @A+DPTR
	
			FReleaseTable:
				LJMP ExtendedRelease ;0
				LJMP ExtendedRelease ;1
				LJMP ExtendedRelease ;2
				LJMP NormalRelease ;3
				LJMP ExtendedRelease ;4
				LJMP ExtendedRelease ;5
				LJMP TBD ;6
				LJMP NormalRelease ;7
				LJMP ExtendedRelease ;8
				LJMP NormalRelease ;9
				LJMP NormalRelease ;10
				LJMP NormalRelease ;11
				LJMP ExtendedRelease ;12
				LJMP NormalRelease ;13
				LJMP NormalRelease ;14
				LJMP NormalRelease ;15
				LJMP TBD ;16
				LJMP NormalRelease ;17
				LJMP TBD ;18
				LJMP NormalRelease ;19
				LJMP ExtendedRelease ;20
				LJMP NormalRelease ;21
				LJMP TBD ;22
				LJMP NormalRelease ;23
				LJMP PrintScreenRelease ;24
				LJMP ExtendedRelease ;25
				LJMP TBD ;26
				LJMP TBD ;27
				LJMP NormalRelease ;28
				LJMP ExtendedRelease ;29
				LJMP NormalRelease ;30
				LJMP ExtendedRelease ;31
				LJMP NormalRelease ;32
				LJMP ExtendedRelease ;33
				LJMP ExtendedRelease ;34
				LJMP ExtendedRelease ;35
				LJMP PauseRelease ;36
				LJMP NormalRelease ;37
				LJMP ExtendedRelease ;38
				LJMP ExtendedRelease ;39
				LJMP NormalRelease ;40
				LJMP NormalRelease ;41
				LJMP NormalRelease ;42
				LJMP NormalRelease ;43
				LJMP NASModeRelease ;44
				LJMP NASLockRelease ;45
				LJMP ShiftKeyRelease ;46
				LJMP NormalRelease ;47
				LJMP NormalRelease ;48
				LJMP FunctionModeRelease ;49
				LJMP NormalRelease ;50
				LJMP NormalModeRelease ;51
	
		HandleButtonRelease_GameMode:
			;restore the table index from R6
			MOV A, R6
			MOV R0, #High(GameMap)
			MOV R1, #Low(GameMap)
			MOV DPTR, #GameReleaseTable
			JMP @A+DPTR
	
			GameReleaseTable:
				LJMP NormalRelease ;0
				LJMP NormalRelease ;1
				LJMP NormalRelease ;2
				LJMP NormalRelease ;3
				LJMP NormalRelease ;4
				LJMP NormalRelease ;5
				LJMP NormalRelease ;6
				LJMP NormalRelease ;7
				LJMP NormalRelease ;8
				LJMP NormalRelease ;9
				LJMP NormalRelease ;10
				LJMP NormalRelease ;11
				LJMP NormalRelease ;12		   ,
				LJMP NormalRelease ;13
				LJMP NormalRelease ;14
				LJMP NormalRelease ;15
				LJMP NormalRelease ;16
				LJMP NormalRelease ;17
				LJMP NormalRelease ;18
				LJMP NormalRelease ;19
				LJMP NormalRelease ;20
				LJMP NormalRelease ;21
				LJMP NormalRelease ;22
				LJMP NormalRelease ;23
				LJMP NormalRelease ;24
				LJMP ExtendedRelease ;25
				LJMP NormalRelease ;26
				LJMP NormalRelease ;27
				LJMP NormalRelease ;28
				LJMP NormalRelease ;29
				LJMP NormalRelease ;30
				LJMP NormalRelease ;31
				LJMP NormalRelease ;32
				LJMP NormalRelease ;33
				LJMP NormalRelease ;34
				LJMP NormalRelease ;35
				LJMP NormalRelease ;36
				LJMP NormalRelease ;37
				LJMP NormalRelease ;38
				LJMP NormalRelease ;39
				LJMP NormalRelease ;40
				LJMP NormalRelease ;41
				LJMP NormalRelease ;42
				LJMP NormalRelease ;43
				LJMP NASModeRelease ;44
				LJMP NASLockRelease ;45
				LJMP ShiftKeyRelease ;46
				LJMP NormalRelease ;47
				LJMP NormalRelease ;48
				LJMP FunctionModeRelease ;49
				LJMP NormalRelease ;50
				LJMP NormalModeRelease ;51
	
	
	
	;Handles the press of a "normal" key. A normal
	;key has 1 scancode byte, and doesn't affect the keyboard mode
	;Parameters:
	;	ButtonIndex - the index of the button that was pressed
	;  R0 - The high byte of the address of the scancode lookup table to use
	;	R1 - The low byte of the address of the scancode lookup table to use
	;Modifies:
	;	Registers:
	;		DPTR, A, R0, R1, R2, R3, R6, R7, PSW
	;	Memory:
	;		LastSentByte, KeyboardBuffer, KeyboardBufferPosition
	;	Ports:
	;		KBData, KBClock
	NormalPress:
		;Get the scan code from the appropriate map
		MOV DPH, R0
		MOV DPL, R1
		MOV A, ButtonIndex
		MOVC A, @A+DPTR
		;save the scancode in R3
		MOV R3, A
	
		;let's try to send the data over the PS/2 bus
		MOV R1, A
		CALL SendByte
	
		;If the send failed, buffer the data instead
		JNC NormalPressBufferData
	
		CALL StartTypematicDelayTimer
	
	NormalPressEnd:
	RET
	NormalPressBufferData:
		;add the length byte
		MOV R2, #01h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC NormalPressEnd
	
		;add the data to the buffer
		MOV R1, AR3
		CALL AddByteToBuffer
	
		CALL StartTypematicDelayTimer
	RET
	
	NormalPress_CheckNormalHold:
	
		;check if the normal button is being held. If not, just jump to NormalPress
		MOV A, NormalPressed
		MOV C, ACC.0
		JNC NormalPress
	
		;the normal button is being held down. We're going to send a special button press
	
		; was it the L1D button? if so, send CTRL+V
		MOV A, ButtonIndex
		CJNE A, #01Fh, CheckL2D
		;move the scancode for V into R0
		MOV R0, #02Ah
		CALL SendCtrlSequence
		RET
	
		CheckL2D:
		CJNE A, #01Eh, CheckL3D
		;move the scancode for C into R0
		MOV R0, #021h
		CALL SendCtrlSequence
		RET
	
		CheckL3D:
		CJNE A, #0Bh, CheckL4D
		;move the scancode for X into R0
		MOV R0, #022h
		CALL SendCtrlSequence
		RET
	
		CheckL4D:
		CJNE A, #0Ah, NormalPress
		;set the game mode
		CALL SetGameMode
	RET
	
	
	;Handles the press of an "extended" key. An
	;extended key has 1 scancode byte plus an initial "extended"
	;byte of 0xE0
	;Parameters:
	;	ButtonIndex - the index of the button that was pressed
	;  R0 - The high byte of the address of the scancode lookup table to use
	;	R1 - The low byte of the address of the scancode lookup table to use
	;Modifies:
	;	Registers:
	;		DPTR, A, R0, R1, R2, R3, R6, R7, PSW
	;	Memory:
	;		LastSentByte, KeyboardBuffer, KeyboardBufferPosition
	;	Ports:
	;		KBData, KBClock
	ExtendedPress:
		;Get the scan code from the appropriate map
		MOV DPH, R0
		MOV DPL, R1
		MOV A, ButtonIndex
		MOVC A, @A+DPTR
	
		;save the scancode in R3
		MOV R3, A
	
		;let's try to send the data ovev the PS/2 bus
		MOV R1, #0E0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC ExtendedPressBufferData
	
		MOV R1, AR3
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC ExtendedPressBufferData
	
		CALL StartTypematicDelayTimer
	
	ExtendedPressEnd:
	RET
	ExtendedPressBufferData:
		;add the length byte
		MOV R2, #02h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC ExtendedPressEnd
	
		;add the data to the buffer
		MOV R1, #0E0h
		CALL AddByteToBuffer
	
		MOV R1, AR3
		CALL AddByteToBuffer
	
		CALL StartTypematicDelayTimer
	JMP ExtendedPressEnd
	
	
	ShiftKeyPress:
		MOV ShiftPressed, #01h
		CALL NormalPress
	RET
	
	
	;Modifies:
	;	Memory:
	;		Mode
	;	Ports
	;		P0
	NASLockPress:
		;change the mode
		MOV Mode, #02h
		MOV NASLock, #01h
		;set the LEDs
	
		MOV P0, #0Eh
	RET
	
	;Modifies:
	;	Memory:
	;		PreviousMode, Mode
	;	Ports
	;		P0
	NASModePress:
		;save the mode
		MOV PreviousMode, Mode
		;change the mode
		MOV Mode, #02h
		;set the LEDs
	
		MOV P0, #0Eh
	RET
	
	
	;Modifies:
	;	Memory:
	;		Mode
	;	Ports
	;		P0
	FunctionModePress:
		;change the mode
		MOV Mode, #03h
		MOV NASLock, #00h
	
	
		;set the LEDs
		MOV P0, #0Bh
	RET
	
	NormalModePress:
		MOV NormalPressed, #01h
		;Change the mode
		MOV Mode, #01h
		MOV NASLock, #00h
	
		;set the LEDs
		MOV P0, #0Dh
	RET
	
	SetGameMode:
		;change the mode
		MOV MODE, #04h
		MOV NASLock, #00h
	
		;set the LEDs
		MOV P0, #07h
	RET
	
	;Handles the press of a "shifted" key. A shifted
	;key is a key that would requires shift to be held down on a
	;normal keyboard, for example, all the symbols that are accessed
	;with shift+number keys
	;Parameters:
	;	ButtonIndex - the index of the button that was pressed
	;  R0 - The high byte of the address of the scancode lookup table to use
	;	R1 - The low byte of the address of the scancode lookup table to use
	;Modifies:
	;	Registers:
	;		DPTR, A, R0, R1, R2, R3, R6, R7, PSW
	;	Memory:
	;		LastSentByte, KeyboardBuffer, KeyboardBufferPosition
	;	Ports:
	;		KBData, KBClock
	ShiftPress:
		;Get the scan code from the appropriate map
		MOV DPH, R0
		MOV DPL, R1
		MOV A, ButtonIndex
		MOVC A, @A+DPTR
	
		;save the scancode in R3
		MOV R3, A
	
		;let's try to send the data over the PS/2 bus
	
		;first, send the shift make code
		MOV R1, #012h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC ShiftPressBufferData
	
		MOV R1, AR3
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC ShiftPressBufferData
	
		MOV A, ShiftPressed
		MOV C, ACC.0
		JC SkipShiftBreak
	
		MOV R1, #0F0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC ShiftPressBufferData
	
		MOV R1, #012h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC ShiftPressBufferData
	
	
		SkipShiftBreak:
		CALL StartTypematicDelayTimer
	
	ShiftPressEnd:
	RET
	ShiftPressBufferData:
		MOV A, ShiftPressed
		MOV C, ACC.0
		JC ShiftPressBufferData_NoShiftBreak
	
		;add the length byte
		MOV R2, #04h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC ShiftPressEnd
	
		;add the data to the buffer
		MOV R1, #012h
		CALL AddByteToBuffer
	
		MOV R1, AR3
		CALL AddByteToBuffer
	
		MOV R1, #0F0h
		CALL AddByteToBuffer
	
		MOV R1, #012h
		CALL AddByteToBuffer
	
		CALL StartTypematicDelayTimer
		RET
	
		ShiftPressBufferData_NoShiftBreak:
		;add the length byte
		MOV R2, #02h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC ShiftPressEnd
	
		;add the data to the buffer
		MOV R1, #012h
		CALL AddByteToBuffer
	
		MOV R1, AR3
		CALL AddByteToBuffer
	
	
		CALL StartTypematicDelayTimer
	RET
	
	
	SendCtrlSequence:
		;save the scancode in R3
		MOV R3, AR0
	
		;let's try to send the data over the PS/2 bus
	
		;first, send the ctrl make code
		MOV R1, #014h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC SendCtrlSequenceBufferData
	
		;now send the make code that we were passed
		MOV R1, AR3
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC SendCtrlSequenceBufferData
	
		;now send the break code that we were passed
		MOV R1, #0F0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC SendCtrlSequenceBufferData
	
		MOV R1, AR3
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC SendCtrlSequenceBufferData
	
	
		;now send the ctrl break code
		MOV R1, #0F0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC SendCtrlSequenceBufferData
	
		MOV R1, #014h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC SendCtrlSequenceBufferData
	SendCtrlSequenceEnd:
	RET
	SendCtrlSequenceBufferData:
		;add the length byte
		MOV R2, #06h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC SendCtrlSequenceEnd
	
		;add the data to the buffer
		MOV R1, #014h
		CALL AddByteToBuffer
	
		MOV R1, AR3
		CALL AddByteToBuffer
	
		MOV R1, #0F0h
		CALL AddByteToBuffer
	
		MOV R1, AR3
		CALL AddByteToBuffer
	
		MOV R1, #0F0h
		CALL AddByteToBuffer
	
		MOV R1, #014h
		CALL AddByteToBuffer
	RET
	
	
	;Handles the press of the Print Screen button. This button's
	;scan code is 4 bytes, and is treated as a special case.
	PrintScreenPress:
		;let's try to send the data ovev the PS/2 bus
		MOV R1, #0E0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenPressBufferData
	
		MOV R1, #012h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenPressBufferData
	
		MOV R1, #0E0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenPressBufferData
	
		MOV R1, #07Ch
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenPressBufferData
	
	PrintScreenPressEnd:
	RET
	PrintScreenPressBufferData:
		;add the length byte
		MOV R2, #04h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC PrintScreenPressEnd
	
		;add the data to the buffer
		MOV R1, #0E0h
		CALL AddByteToBuffer
	
		MOV R1, #012h
		CALL AddByteToBuffer
	
		MOV R1, #0E0h
		CALL AddByteToBuffer
	
		MOV R1, #07Ch
		CALL AddByteToBuffer
	RET
	
	;Handles the press of the pause button. This button's
	;scan code is 8 bytes, and is treated as a special case.
	PausePress:
		;let's try to send the data ovev the PS/2 bus
		MOV R1, #0E1h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PausePressBufferData
	
		MOV R1, #014h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PausePressBufferData
	
		MOV R1, #077h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PausePressBufferData
	
		MOV R1, #0E1h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PausePressBufferData
	
		MOV R1, #0F0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PausePressBufferData
	
		MOV R1, #014h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PausePressBufferData
	
		MOV R1, #0F0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PausePressBufferData
	
		MOV R1, #077h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PausePressBufferData
	
	PausePressEnd:
	RET
	PausePressBufferData:
		;add the length byte
		MOV R2, #08h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC PrintScreenPressEnd
	
		;add the data to the buffer
		MOV R1, #0E1h
		CALL AddByteToBuffer
	
		MOV R1, #014h
		CALL AddByteToBuffer
	
		MOV R1, #077h
		CALL AddByteToBuffer
	
		MOV R1, #0E1h
		CALL AddByteToBuffer
	
		MOV R1, #0F0h
		CALL AddByteToBuffer
	
		MOV R1, #014h
		CALL AddByteToBuffer
	
		MOV R1, #0F0h
		CALL AddByteToBuffer
	
		MOV R1, #077h
		CALL AddByteToBuffer
	RET
	
	
	TBD:
	RET
	
	
	
	
	;Handles the release of a "normal" key. A normal
	;key has 1 scancode byte (not including the "break" byte), and
	;doesn't affect the keyboard mode
	;Parameters:
	;	ButtonIndex - the index of the button that was pressed
	;  R0 - The high byte of the address of the scancode lookup table to use
	;	R1 - The low byte of the address of the scancode lookup table to use
	;Modifies:
	;	Registers:
	;		DPTR, A, R0, R1, R2, R3, R6, R7, PSW
	;	Memory:
	;		LastSentByte, KeyboardBuffer, KeyboardBufferPosition
	;	Ports:
	;		KBData, KBClock
	NormalRelease:
	
		;Get the scan code from the appropriate map
		MOV DPH, R0
		MOV DPL, R1
		MOV A, ButtonIndex
		MOVC A, @A+DPTR
		;save the scancode in R3
		MOV R3, A
	
		;let's try to send the data over the PS/2 bus
		MOV R1, #0F0h
		CALL SendByte
		;If the send failed, buffer the data instead
		JNC NormalReleaseBufferData
	
		MOV R1, AR3
		CALL SendByte
		;If the send failed, buffer the data instead
		JNC NormalReleaseBufferData
	
	NormalReleaseEnd:
	RET
	NormalReleaseBufferData:
		;add the length byte
		MOV R2, #02h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC NormalReleaseEnd
	
		;add the data to the buffer
		MOV R1, #0F0h
		CALL AddByteToBuffer
	
		MOV R1, AR3
		CALL AddByteToBuffer
	RET
	
	;Handles the release of an "extended" key. An
	;extended key has 2 scancode bytes (not including the "break"
	;byte): A static extended byte of 0xE0 plus a key-dependent byte
	;Parameters:
	;	ButtonIndex - the index of the button that was pressed
	;  R0 - The high byte of the address of the scancode lookup table to use
	;	R1 - The low byte of the address of the scancode lookup table to use
	;Modifies:
	;	Registers:
	;		DPTR, A, R0, R1, R2, R3, R6, R7, PSW
	;	Memory:
	;		LastSentByte, KeyboardBuffer, KeyboardBufferPosition
	;	Ports:
	;		KBData, KBClock
	ExtendedRelease:
		;Get the scan code from the appropriate map
		MOV DPH, R0
		MOV DPL, R1
		MOV A, ButtonIndex
		MOVC A, @A+DPTR
	
		;save the scancode in R3
		MOV R3, A
	
		;let's try to send the data ovev the PS/2 bus
		MOV R1, #0E0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC ExtendedReleaseBufferData
	
		MOV R1, #0F0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC ExtendedReleaseBufferData
	
		MOV R1, AR3
		CALL Sendbyte
		;if the send failed, buffer the data instead
		JNC ExtendedReleaseBufferData
	
	ExtendedReleaseEnd:
	RET
	ExtendedReleaseBufferData:
		;add the length byte
		MOV R2, #03h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC ExtendedReleaseEnd
	
		;add the data to the buffer
		MOV R1, #0E0h
		CALL AddByteToBuffer
	
		MOV R1, #0F0h
		CALL AddByteToBuffer
	
		MOV R1, AR3
		CALL AddByteToBuffer
	RET
	
	
	;Handles the release of the Print Screen button. This button's
	;break code is 6 bytes, and is treated as a special case.
	PrintScreenRelease:
		;let's try to send the data ovev the PS/2 bus
		MOV R1, #0E0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenReleaseBufferData
	
		MOV R1, #0F0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenReleaseBufferData
	
		MOV R1, #07Ch
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenReleaseBufferData
	
		MOV R1, #0E0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenReleaseBufferData
	
		MOV R1, #0F0h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenReleaseBufferData
	
		MOV R1, #012h
		CALL SendByte
		;if the send failed, buffer the data instead
		JNC PrintScreenReleaseBufferData
	
	PrintScreenReleaseEnd:
	RET
	PrintScreenReleaseBufferData:
		;add the length byte
		MOV R2, #06h
		CALL AddLengthByteToBuffer
		;check for  failure
		JNC PrintScreenReleaseEnd
	
		;add the data to the buffer
		MOV R1, #0E0h
		CALL AddByteToBuffer
	
		MOV R1, #0F0h
		CALL AddByteToBuffer
	
		MOV R1, #07Ch
		CALL AddByteToBuffer
	
		MOV R1, #0E0h
		CALL AddByteToBuffer
	
		MOV R1, #0F0h
		CALL AddByteToBuffer
	
		MOV R1, #012h
		CALL AddByteToBuffer
	RET
	
	PauseRelease:
		;pause doesn't have a break code
	RET
	
	ShiftKeyRelease:
		MOV ShiftPressed, #00h
		CALL NormalRelease
	RET
	
	NormalModeRelease:
		MOV NormalPressed, #00h
	RET
	
	NASLockRelease:
	FunctionModeRelease:
		;nothing to do
	RET
	
	;Modifies:
	;	Registers:
	;		A, DPTR
	;	Memory:
	;		Mode
	;	Ports
	;		P0
	NASModeRelease:
		;only handle this button release if NAS lock isn't on
		MOV A, NASLock
		JNZ NASModeReleaseEnd
	
		;restore the mode
		MOV Mode, PreviousMode
	
		;set the LEDs
		MOV A, Mode
		MOV DPTR, #LEDTable
		MOVC A, @A+DPTR
		MOV P0, A
	NASModeReleaseEnd:
	RET
	
	;Handles the timer1 interrupt. Timer1 is
	;started when the selector is changed. It is
	;set to a remaining value of 100 cycles.
	;Once the 100 cycles elapse, we turn off the timer.
	;CheckForButtons waits for the timer to be turned off
	;before it reads the button states, to ensure that
	;100uS have passed since the last selector change,
	;to ensure that the voltage has time to settle
	;Modifies:
	;	Timer Registers/Flags:
	;		TR1, TL1, TH1
	DemuxSelectorTimerTick:
		CLR TR1
		MOV TL1, #09Ch
		MOV TH1, #0FFh
	RET