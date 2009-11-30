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

CSEG
	TypematicRateTable:
		;number of 10000uS intervals, number of 1000uS intervals
		DB 03h, 03h	;00h
		DB 03h, 07h	;01h
		DB 04h, 02h	;02h
		DB 04h, 06h	;03h
		DB 04h, 08h	;04h
		DB 05h, 04h	;05h
		DB 05h, 08h	;06h
		DB 06h, 03h	;07h
		DB 06h, 07h	;08h
		DB 07h, 05h	;09h
		DB 08h, 03h	;0Ah
		DB 09h, 02h	;0Bh
		DB 09h, 0Ah	;0Ch
		DB 0Ah, 09h	;0Dh
		DB 0Bh, 06h	;0Eh
		DB 0Ch, 05h	;0Fh
		DB 0Dh, 03h	;10h
		DB 0Eh, 09h	;11h
		DB 10h, 07h	;12h
		DB 12h, 02h	;13h
		DB 13h, 0Ah	;14h
		DB 15h, 07h	;15h
		DB 17h, 03h	;16h
		DB 18h, 0Ah	;17h
		DB 1Bh, 00h	;18h
		DB 1Eh, 03h	;19h
		DB 21h, 03h	;1Ah
		DB 25h, 00h	;1Bh
		DB 27h, 0Ah	;1Ch
		DB 2Bh, 05h	;1Dh
		DB 2Fh, 06h	;1Eh
		DB 31h, 0Ah	;1Fh

	TypematicDelayTable:
		;number of 50000uS intervals
		DB 05h	;00h
		DB 0Ah	;01h
		DB 0Fh	;02h
		DB 14h	;03h



	;Modifies:
	;	Registers:
	;		A, PSW, R0, R1
	CheckForHostCommand:
		;check for low data line
		MOV C, HostData
		JC CheckForHostCommandEnd

		;check for high clock line
		MOV C, HostClock
		JNC CheckForHostCommandEnd

		;save the value of TR0
		MOV C, TR0
		MOV ACC.0, C
		PUSH ACC

		;disable the typematic timer while
		;reading/handling a host command
		CLR TR0

		CALL ReadHostCommand

		;restore the value of TR0
		POP ACC
		MOV C, ACC.0
		MOV TR0, C

	CheckForHostCommandEnd:
	RET





	ReadHostCommand:
		CallReadHostByte:
		CALL ReadHostByteWithRetry

		;if success, then send an ack
		JC SendAck

		;otherwise ReadHostByteWithRetry failed. All we can do is
		;return and try again next iteration
		RET

		SendAck:
		MOV R1, #0FAh
		CALL SendByte

		CALL HandleHostCommand
	RET



	HandleHostCommand:
		MOV A, R0
		CPL A

		ADD A, #0EDh
		JNC LookupCommand

		LJMP NotSupported

		LookupCommand:

		MOV A, R0
		CPL A

		MOV B, #03h
		MUL AB

		MOV DPTR, #CommandHandlerTable
		JMP @A+DPTR

		CommandHandlerTable:
			LJMP Reset					;0xFF
			LJMP ResendLastByte			;0xFE
			LJMP NotSupported			;0xFD
			LJMP NotSupported			;0xFC
			LJMP NotSupported			;0xFB
			LJMP NotSupported			;0xFA
			LJMP NotSupported			;0xF9
			LJMP NotSupported			;0xF8
			LJMP NotSupported			;0xF7
			LJMP SetDefault				;0xF6
			LJMP Disable				;0xF5
			LJMP Enable					;0xF4
			LJMP SetTypematicRateDelay	;0xF3
			LJMP ReadID					;0xF2
			LJMP NotSupported			;0xF1
			LJMP SetScanCodeSet			;0xF0
			LJMP NotSupported			;0xEF
			LJMP Echo					;0xEE
			LJMP SetLEDs				;0xED



	ResendLastByte:
		MOV R1, LastSentByte
		CALL SendByte
	RET

	SetDefault:
		;set typematic rate to 10.9 CPS
		MOV TypematicRepeatDelay1, #08h
		MOV TypematicRepeatDelay2, #01h

		;set typematic delay to 500ms
		MOV TypematicInitialDelay, #0Ah
	RET

	Disable:
		CALL SetDefault

		CLR TR0
		CLR TR1

		;initialize timer 1 to 100 cycles
		MOV TH1, #0FFh
		MOV TL1, #09Ch

		MOV KeyboardEnabled, #00h
	RET

	Enable:
		MOV KeyboardEnabled, #01h

		MOV P1, #00h
		SETB TR1
	RET


	SetScanCodeSet:
		CALL WaitForHostRequest
		JNC SetTypematicRateDelayEnd
		CALL ReadHostByteWithRetry

		;If ReadHostByteWithRetry failed, just return
		JNC SetScanCodeSetEnd

		;We recieved the byte successfully, so send an ack
		MOV R1, #0FAh
		CALL SendByte

		;Check if the byte was a new command. If so, abandon processing this command
		;and switch to the new command
		MOV A, R0
		ADD A, #013h
		JNC SetScanCodeSet_HandleParameterByte

		LJMP HandleHostCommand

		SetScanCodeSet_HandleParameterByte:


		MOV A, R0
		JNZ SelectScanCodeSet

		MOV R1, #02h
		CALL SendByte
		RET

		SelectScanCodeSet:
		MOV A, R0
		CJNE A, #02h, ScanCodeSetNotSupported
		RET

		ScanCodeSetNotSupported:
		;we only support scan code set 2. Send an error
		;if it was anything other than 2
		MOV R1, #0FFh
		CALL SendByte

	SetScanCodeSetEnd:
	RET


	Echo:
		MOV R1, #0EEh
		CALL SendByte
	RET



	ReadID:
		MOV R1, #0ABh
		CALL SendByte
		MOV R1, #083h
		CALL SendByte
	RET

	SetTypematicRateDelay:
		CALL WaitForHostRequest

		JNC SetTypematicRateDelayEnd
		CALL ReadHostByteWithRetry

		;If ReadHostByteWithRetry failed, just return
		JNC SetTypematicRateDelayEnd

		;We recieved the byte successfully, so send an ack
		MOV R1, #0FAh
		CALL SendByte

		;Check if the byte was a new command. If so, abandon processing this command
		;and switch to the new command
		MOV A, R0
		ADD A, #013h
		JNC SetTypematicRateDelay_HandleParameterByte

		LJMP HandleHostCommand

		SetTypematicRateDelay_HandleParameterByte:

		;move the low 5 bits of the byte we read into A
		MOV A, R0
		ANL A, #01Fh

		;lookup the appropriate delays from TypematicRateTable
		RL A
		;save the value of A, so we don't have to recalculate
		MOV B, A
		MOV DPTR, #TypematicRateTable
		MOVC A, @A+DPTR
		MOV TypematicRepeatDelay1, A
		DEC TypematicRepeatDelay1

		MOV A, B
		INC A
		MOVC A, @A+DPTR
		MOV TypematicRepeatDelay2, A
		DEC TypematicRepeatDelay2

		;get bits 5 and 6 of the byte we read, and move them
		;to bits 0 and 1 in A
		MOV A, R0
		ANL A, #060h
		SWAP A
		RR A

		;lookup the typematic delay in TypematicDelayTable
		MOV DPTR, #TypematicDelayTable
		MOVC A, @A+DPTR
		MOV TypematicInitialDelay, A
		DEC TypematicInitialDelay

		SetTypematicRateDelayEnd:
	RET

	SetLEDs:
		CALL WaitForHostRequest
		JNC SetLEDEnd
		CALL ReadHostByteWithRetry

		;If ReadHostByteWithRetry failed, just return
		JNC SetLEDEnd

		;We recieved the byte successfully, so send an ack
		MOV R1, #0FAh
		CALL SendByte

		;Check if the byte was a new command. If so, abandon processing this command
		;and switch to the new command
		MOV A, R0
		ADD A, #013h
		JNC SetLEDs_HandleParameterByte

		LJMP HandleHostCommand

		SetLEDs_HandleParameterByte:

		;nothing else to do for now.. the LEDs are on the left DH unit
	SetLEDEnd:
	RET

	NotSupported:
	RET


	ReadHostByteWithRetry:
		CALL ReadByte

		;if parity error, try up to two more times
		JC ReadHostByteWithRetryEnd
		MOV R1, #0FEh ;resend
		CALL SendByte

		CALL WaitForHostRequest
		JNC ReadHostByteWithRetry_SendErrorAndQuit
		CALL ReadByte
		JC ReadHostByteWithRetryEnd

		MOV R1, #0FEh ;resend
		CALL SendByte

		CALL WaitForHostRequest
		JNC ReadHostByteWithRetry_SendErrorAndQuit
		CALL ReadByte
		JC ReadHostByteWithRetryEnd

		;apparently it's a systematic error, let's just skip it
		;and try again next tick
		RET

		ReadHostByteWithRetry_SendErrorAndQuit:
		MOV R1, #0FEh
		CALL SendByte
		;return failure
		CLR C

	ReadHostByteWithRetryEnd:
	RET



	;waits for the host to request to send data
	;Return:
	;	C contains 1 if the host is requesting to send data, 0 otherwise
	;Modifies:
	;	Registers:
	;		R6, PSW
	WaitForHostRequest:
		;wait for up to 1000uS for the host to bring data low
		MOV R6, #200
		WaitForDataLowLoop:
			MOV C, HostData				;1uS
			JNC DataIsLow				;2uS
			DJNZ R6, WaitForDataLowLoop	;2uS

	 	CLR C
		RET

		DataIsLow:
		;wait for up to 200uS for the host to release clock
		MOV R6, #40
		WaitForClockHighLoop:
			MOV C, HostClock
			JC ClockIsHigh
			DJNZ R6, WaitForClockHighLoop

		CLR C
		RET

		ClockIsHigh:
		SETB C
	RET