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
	;Waits for the clock to become high, and then ensures clock is high
	;for at least 50uS, then sends a byte of data to the PS2 bus, and
	;saves the byte to LastSentByte
	;Parameters:
	;R1 - the byte of data to send
	;Returns:
	;C - 1 if send succeeded, 0 if send failed. If send failed,
	;the data should be buffered and sent later
	;Modifies:
	;	Registers:
	;		A, R6, R7, PSW
	;	Ports:
	;		KBData, KBClock
	SendByte:
		;try up to 3 times
		MOV R7, #3

		WaitForClockStart:
		;give up if we have tried waiting for the clock 3 times already
		DJNZ R7, WaitForClockHighStart
		JMP SendByteEnd

		WaitForClockHighStart:

		;wait up to 200uS for the clock to go high
		MOV R6, #200
		SendByte_WaitForClockHighLoop:
			MOV C, HostClock						;1uS
			JC SendByte_ClockIsHigh					;2uS
			DJNZ R6, SendByte_WaitForClockHighLoop	;2uS

		SendByte_ClockIsHigh:

		;make sure clock is high for at least 50uS
		MOV R6, #0Ah
		CheckClockLoop:
			MOV C, HostClock		;1uS
			JNC WaitForClockStart	;2uS
			DJNZ R6, CheckClockLoop	;2uS

		;if the host is holding data low, we can't send right now
		MOV C, HostData
		JNC SendByteEnd

		;the clock has been continuously high for 50uS
		;so we can send the data now

		;save the original value of R1, so we can restore it at the
		;end, and save it to LastSentByte
		MOV LastSentByte_temp, R1

		;initialize the parity
		MOV A, #00h

		;send start bit
			;++++++++++++++++++++++++++++++++++++++++++++
			;send the bit
			CLR KBData

			;wait 5uS before we move clock low
			nop
			nop
			nop
			nop
			nop
			nop
			;++++++++++++++++++++++++++++++++++++++++++++
			;--------------------------------------------
			;bring clock low
			CLR KBClock 			;1uS

			;wait
			MOV R6, #0Fh			;31uS
			SendClockLow1:
			DJNZ R6, SendClockLow1
			;--------------------------------------------

		;Send 8 bits of data
			MOV R7, #08h
			;++++++++++++++++++++++++++++++++++++++++++++
			SendDataBit:
			;bring clock high
			SETB KBClock			;1uS

			;wait
			MOV R6, #03h			;7us
			SendClockHigh1:
			DJNZ R6, SendClockHigh1

			;send the next bit
			XCH A, R1				;1uS
			RRC A					;1uS
			MOV KBData, C			;2uS
			XCH A, R1				;1uS

			;update the parity for the bit we just sent
			ADDC A, #00h			;1uS

			;Check if host is holding clock low
			MOV C, HostClock		;1uS
			JC ContinueSending1		;2uS

			;return failure
			CLR C
			JMP SendByteEnd

			ContinueSending1:
			;wait
			MOV R6, #07h			;15uS
			SendClockHigh2:
			DJNZ R6, SendClockHigh2
			;++++++++++++++++++++++++++++++++++++++++++++
			;--------------------------------------------
			;bring clock low
			CLR KBClock 			;1uS

			;wait
			MOV R6, #0Eh			;29uS
			SendClockLow2:
			DJNZ R6, SendClockLow2

			DJNZ R7, SendDataBit	;2uS
			;--------------------------------------------

		;send parity bit
			;++++++++++++++++++++++++++++++++++++++++++++
			;bring clock high
			SETB KBClock			;1uS

			;wait
			MOV R6, #03h			;7uS
			SendClockHigh3:
			DJNZ R6, SendClockHigh3

			;send the parity bit
			MOV C, ACC.0			;1uS
			CPL C					;1uS
			MOV KBData, C			;2uS

			;Check if host is holding clock low
			MOV C, HostClock		;1uS
			JC ContinueSending2		;2uS

			;return failure
			CLR C
			JMP SendByteEnd

			ContinueSending2:
			;wait
			MOV R6, #08h			;17uS
			SendClockHigh4:
			DJNZ R6, SendClockHigh4
			;++++++++++++++++++++++++++++++++++++++++++++
			;--------------------------------------------
			;bring clock low
			CLR KBClock				;1uS

			;wait
			MOV R6, #0Fh			;31uS
			SendClockLow3:
			DJNZ R6, SendClockLow3
			;--------------------------------------------

		;send stop bit
			;++++++++++++++++++++++++++++++++++++++++++++
			;bring clock high
			SETB KBClock			;1us

			MOV R6, #03h			;7us
			SendClockHigh5:
			DJNZ R6, SendClockHigh5

			;send the stop bit
			SETB KBData				;1us

			;Check if host is holding clock low
			MOV C, HostClock		;1uS
			JC ContinueSending3		;2uS

			;return failure
			CLR C
			JMP SendByteEnd

			ContinueSending3:
			MOV R6, #09h			;19us
			SendClockHigh6:
			DJNZ R6, SendClockHigh6

			NOP						;1uS
			;++++++++++++++++++++++++++++++++++++++++++++
			;--------------------------------------------
			;bring clock low
			CLR KBClock				;1us

			;wait
			MOV R6, #0Fh			;31us
			SendClockLow4:
			DJNZ R6, SendClockLow4
			;--------------------------------------------

		;release the clock
		SETB KBClock

		;return success
		SETB C

		;restore the byte that was sent, and
		;save it to LastSentByte
		MOV R1, LastSentByte
		MOV LastSentByte, R1
	SendByteEnd:
		SETB KBClock
		SETB KBData
	RET


	;Reads a byte from the host on the PS2 bus.
	;This function does *not* check if HostData is low and HostClock is high. This should
	;be done before calling this function
	;Return Values:
	;R0 will contain the byte read
	;C will contain the total parity of the 8 data bits and the parity bit sent by the host.
	;		If C is 0, then the byte was not received correctly
	;Modifies:
	;	Registers:
	;		A, R0, R6, R7 PSW
	;	Ports:
	;		KBClock, KBData
	ReadByte:
		;initialize the parity
		MOV A,#00h

		;initialize the pulse counter
		MOV R7, #08h


		;Read the 8 data bits
			;--------------------------------------------
			ReadDataBit:
			;bring clock low
			CLR KBClock				;1us

			;wait
			MOV R6, #0Fh			;31us
			ReadClockLow1:
			DJNZ R6, ReadClockLow1
			;--------------------------------------------
			;++++++++++++++++++++++++++++++++++++++++++++
			;bring clock high
			SETB KBClock			;1us

			;wait
			MOV R6, #05h			;11us
			ReadClockHigh1:
			DJNZ R6, ReadClockHigh1

			;read the bit
			MOV C, HostData			;1uS

			;store the data bit in R0
			XCH A, R0				;1uS
			RR A					;1uS
			MOV ACC.7, C			;2uS
			XCH A, R0				;1uS

			;update the parity
			ADDC A, #00h			;1uS

			;wait
			MOV R6, #05h			;11uS
			ReadClockHigh2:
			DJNZ R6, ReadClockHigh2

			DJNZ R7, ReadDataBit	;2uS
			;++++++++++++++++++++++++++++++++++++++++++++

		;read the parity bit
			;--------------------------------------------
			;bring clock low
			CLR KBClock				;1us

			;wait
			MOV R6, #0Fh			;31us
			ReadClockLow2:
			DJNZ R6, ReadClockLow2
			;--------------------------------------------
			;++++++++++++++++++++++++++++++++++++++++++++
			;bring clock high
			SETB KBClock			;1uS

			;wait
			MOV R6, #05h			;11uS
			ReadClockHigh3:
			DJNZ R6, ReadClockHigh3

			;read the parity bit
			MOV C, HostData			;1uS

			;update the parity
			ADDC A, #00h			;1uS

			MOV R6, #08h			;17uS
			ReadClockHigh4:
			DJNZ R6, ReadClockHigh4

			NOP						;1uS
			;++++++++++++++++++++++++++++++++++++++++++++

		;send the ack bit
			;--------------------------------------------
			;bring clock low
			CLR KBClock				;1us

			;wait
			MOV R6, #0Fh			;31us
			ReadClockLow3:
			DJNZ R6, ReadClockLow3
			;--------------------------------------------
			;++++++++++++++++++++++++++++++++++++++++++++
			;bring clock high
			SETB KBClock			;1uS

			;wait
			MOV R6, #05h			;11uS
			ReadClockHigh5:
			DJNZ R6, ReadClockHigh5

			;send the ack bit
			CLR KBData				;1uS

			MOV R6, #09h			;19uS
			ReadClockHigh6:
			DJNZ R6, ReadClockHigh6
			;++++++++++++++++++++++++++++++++++++++++++++

		;one more low pulse, for the host to read the ack bit
			;--------------------------------------------
			;bring clock low
			CLR KBClock				;1us

			;wait
			MOV R6, #0Fh			;31us
			ReadClockLow4:
			DJNZ R6, ReadClockLow4
			;--------------------------------------------

		;release the clock
		SETB KBClock

		;wait 5uS
		NOP
		NOP
		NOP
		NOP
		NOP

		;release the data line
		SETB KBData

		MOV C, ACC.0
	RET