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
	;The initial typematic delay is TypematicInitialDelay * 50ms
	TypematicInitialDelay: DS 01h

	;The delay for typematic repeat is TypematicRepeatDelay1 * 10ms + TypematicRepeatDelay2 * 1ms
	TypematicRepeatDelay1: DS 01h
	TypematicRepeatDelay2: DS 01h

	TimerInterval1: DS 01h ;the low byte of the current timer interval
	TimerInterval2: DS 01h ;the high byte of the current timer interval
	TimerTicksLeft: DS 01h ;how many ticks of the current interval type are left
	TypematicButtonIndex: DS 01h ;the button to repeat
	TypematicButtonMode: DS 01h ;the mode of the button to repeat

CSEG
	ResetTypematicValues:
		;set typematic rate to 10.9 CPS
		MOV TypematicRepeatDelay1, #02h
		MOV TypematicRepeatDelay2, #02h

		;set typematic delay to 500ms
		MOV TypematicInitialDelay, #0Ah
	RET

	StartTypematicDelayTimer:
		;first, check if timer0's interrupts are enabled.  If they are disabled,
		;it means we're in the timer interrupt handler, and we shouldn't
		;touch the timer
		MOV C, ET0
		JNC StartTypematicDelayTimerEnd

		;set the timer for 50000
		MOV TL0, #0B0h
		MOV TH0, #03Ch
		MOV TimerInterval1, #0B0h
		MOV TimerInterval2, #03Ch
		MOV TimerTicksLeft, TypematicInitialDelay
		MOV TypematicButtonIndex, ButtonIndex
		MOV TypematicButtonMode, Mode
		;and enable the timer
		SETB TR0
	StartTypematicDelayTimerEnd:
	RET


	;Modifies:
	;	Registers:
	;		DPTR, A, B, R0, R1, R6, R7, PSW
	;	Memory:
	;		ButtonIndex, TimerTicksLeft, TimerInterval1, TimerInterval2, KeybordBuffer, KeybordBufferPosition
	;	Timer Registers/Flags
	;		TR0, TL0, TH0
	;	Ports:
	;		KBData, KBClock
	TypematicTimerTick:
		PUSH ACC
		PUSH PSW
		PUSH AR0
		PUSH B
		PUSH AR1
		PUSH AR2
		PUSH AR3
		PUSH AR4
		PUSH AR5
		PUSH AR6
		PUSH AR7
		PUSH DPH
		PUSH DPL
		PUSH ButtonIndex
		CALL _TypematicTimerTick
		POP ButtonIndex
		POP DPL
		POP DPH
		POP AR7
		POP AR6
		POP AR5
		POP AR4
		POP AR3
		POP AR2
		POP AR1
		POP B
		POP AR0
		POP PSW
		POP ACC
	RET


	_TypematicTimerTick:
		;first, check TimerTicksLeft. If that is not 0, then all we have
		;to do is put TimerInterval1 and TimerInterval2 into TL0 and TH0, and
		;decrement TimerTicksLeft
		CLR TR0
		MOV A, TimerTicksLeft
		JZ CheckTimerType
		MOV TL0, TimerInterval1
		MOV TH0, TimerInterval2
		DEC TimerTicksLeft
		SETB TR0
		RET


		CheckTimerType:

		;we've completed this timer interval. What we do next depends
		;on what type of timer interval we just finished. We can tell
		;by looking at the low byte of the timer value
		MOV A, TimerInterval1

		HandleInitialDelayLapse:
		;is this the initial delay timer?
		CJNE A, #0B0h, HandleLongRepeatDelayLapse

		;disable timer 0 interrupts - this is mainly to flag that we're
		;in the interrupt handler
		CLR ET0

		;calculate the ButtonStates table index from the button index
		MOV A, TypematicButtonIndex
		RR A
		ANL A, #07Fh

		;get the byte containing the state for the key from ButtonStates
		ADD A, #ButtonStates
		MOV R0, A
		MOV A, @R0
		MOV R0, A

		;we need to figure out which nibble of the byte we just retrieved
		;contain the button state that we are interested in
		MOV A, TypematicButtonIndex
		ANL A, #00000001B


		JNZ InitialDelay_CheckModOdd
		;the button index is even, so we get the least significant nibble
		MOV A, R0
		ANL A, #00001111B
		JMP InitialDelay_GotButtonStates

		InitialDelay_CheckModOdd:
		;the button index is even, so we get the most significant nibble
		MOV A, R0
		SWAP A
		ANL A, #00001111B


		InitialDelay_GotButtonStates:
		;now the first (least significant) nibble of A contains the button state
		;that we're interested in.

		;if the button is no longer pressed, then stop the timer and don't send a key
		JNZ InitialDelay_RepeatScancode


		CLR TR0
		SETB ET0
		RET

		InitialDelay_RepeatScancode:

		;repeat the scancode
		MOV A, TypematicButtonMode
		MOV ButtonIndex, TypematicButtonIndex
		CALL HandleButtonPress

		SETB ET0

		;change to the long repeat delay (10000uS)
		MOV TL0, #0F0h
		MOV TH0, #0D8h
		MOV TimerInterval1, #0F0h
		MOV TimerInterval2, #0D8h
		MOV TimerTicksLeft, TypematicRepeatDelay1
		SETB TR0
		RET

		HandleLongRepeatDelayLapse:
		;is this the long repeat delay?
		CJNE A, #0F0h, HandleShortRepeatDelayLapse

		;change to the short repeat delay (1000uS)
		MOV TL0, #018h
		MOV TH0, #0FCh
		MOV TimerInterval1, #018h
		MOV TimerInterval2, #0FCh
		MOV TimerTicksLeft, TypematicRepeatDelay2
		SETB TR0
		RET



		HandleShortRepeatDelayLapse:
		;disable timer 0 interrupts - this is mainly to flag that we're
		;in the interrupt handler
		CLR ET0

		 ;calculate the ButtonStates table index from the button index
		MOV A, TypematicButtonIndex
		RR A
		ANL A, #07Fh

		;get the byte containing the state for the key from ButtonStates
		ADD A, #ButtonStates
		MOV R0, A
		MOV A, @R0
		MOV R0, A


		;we need to figure out which nibble of the byte we just retrieved
		;contain the button state that we are interested in
		MOV A, TypematicButtonIndex
		ANL A, #00000001B


		JNZ CheckModOdd
		;the button index is even, so we get the least significant nibble
		MOV A, R0
		ANL A, #00001111B
		JMP InitialDelay_GotButtonStates

		CheckModOdd:
		;the button index is even, so we get the most significant nibble
		MOV A, R0
		SWAP A
		ANL A, #00001111B

		GotButtonStates:
		;now the first (least significant) nibble of A contains the button state
		;that we're interested in.

		;if the button is no longer pressed, then stop the timer and don't send a key
		JNZ RepeatScancode


		CLR TR0
		SETB ET0
		RET

		RepeatScancode:
		;repeat the scancode
		MOV A, TypematicButtonMode
		MOV ButtonIndex, TypematicButtonIndex
		CALL HandleButtonPress

		SETB ET0

		;change back to the long repeat delay (10000uS)
		MOV TL0, #0F0h
		MOV TH0, #0D8h
		MOV TimerInterval1, #0F0h
		MOV TimerInterval2, #0D8h
		MOV TimerTicksLeft, TypematicRepeatDelay1
		SETB TR0
	RET
