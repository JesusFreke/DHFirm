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
	KeyBufferPosition: DS 01h

	;The buffer is used to buffer data to send later, for example
	;when the host holds the clock line low.
	;The first byte in the buffer will be the number of bytes in
	;the first group of bytes to send. The byte immediately after
	;that group of bytes will be the number of bytes in the next
	;group, and so on. The KeyBufferPosition variable always contains the
	;offset to the end of the buffer
	KeyBuffer: DS 20h
	KeyBufferEnd:


CSEG
	ResetKeyboardBuffer:
		MOV KeyBufferPosition, #KeyBuffer
	RET


	CheckBufferedData:
		;check if we have any data to send
		MOV A, KeyBufferPosition
		CLR C
		SUBB A, #KeyBuffer
		JNZ CheckEnabled

		RET

		CheckEnabled:
		;check that the keyboard is enabled
		MOV A, KeyboardEnabled
		JNZ SendData

		RET

		SendData:

		;save the state of timer 0, and then disable it
		MOV C, TR0
		MOV ACC.0, C
		MOV R5, A
		CLR TR0


		SendDataLoop:

		CALL SendBufferedData

		;check if we have any more data to send
		MOV A, KeyBufferPosition
		CLR C
		SUBB A, #KeyBuffer
		JZ CheckBufferedDataEnd

		JMP SendDataLoop



	CheckBufferedDataEnd:
		;restore the state of timer 0
		MOV A, R5
		MOV C, ACC.0
		MOV TR0, C
	RET



	SendBufferedData:

		MOV R0, #KeyBuffer
		MOV AR2, @R0

		SendBufferedDataLoop:
		INC R0

		MOV AR1, @R0

		CALL SendByte
		JNC SendBufferedDataEnd

		DJNZ R2, SendBufferedDataLoop

		;ok, we successfully sent that batch of data. Let's move the
		;rest of the data up to the front of the buffer

		MOV R1, #KeyBuffer
		INC R0


		;At the beginning of the loop,
		;R0 contains the address of next byte in the buffer after the data we just sent
		;R1 contains the address of the beginning of the buffer

		MoveDataLoop:

		;check if we're at the end of the buffer.
		MOV A,KeyBufferPosition
		CLR C
		SUBB A, R0
		JNZ MoveNextByte

		MOV KeyBufferPosition, R1
		RET

		MoveNextByte:

		MOV A, @R0
		MOV @R1, A

		INC R0
		INC R1

		JMP MoveDataLoop


	SendBufferedDataEnd:

	RET

	;Adds the initial "length" byte of a group of bytes to the buffer
	;The caller is responsible for subsequently calling AddBytesToBuffer
	;the same number of times
	;Parameters: R2 - The length byte to store in the buffer. The length
	;represents the number of bytes in the group, not including the length byte
	;itself.
	;Returns:
	;C will be 1 if the function was successful. If C is 0, then there wasn't
	;enough room in the buffer, and the caller *must not* call AddByteToBuffer
	;afterwards.
	;Modifies:
	;	Registers:
	;		A, R0, PSW
	;  Memory:
	;		KeyboardBuffer, KeyboardBufferPosition
	AddLengthByteToBuffer:
		;make sure we have R2 + 1 bytes available in the buffer
		MOV A, KeyBufferPosition
		CLR C
		SUBB A, #KeyBuffer
		ADD A, R2
		ADD A, #0E1h
		JC AddLengthByteToBufferFailed

		PUSH AR1
		MOV R1, AR2
		CALL AddByteToBuffer
		POP AR1

		;return success
		SETB C
	RET
	AddLengthByteToBufferFailed:
	;return failure
	CLR C
	RET

	;Adds a byte to the current group in the buffer
	;It is assumed that the caller has already called
	;AddLengthByteToBuffer, and that it returned success
	;Parameters:
	;	R1 - the byte to add to the buffer
	;Modifies:
	;	Registers:
	;		R0, PSW
	;  Memory:
	;		KeyboardBuffer, KeyboardBufferPosition
	AddByteToBuffer:
		;calculate the address of the current position in the keyboard buffer
		MOV R0, KeyBufferPosition

		;add the byte to the buffer
		MOV @R0, AR1
		;increment the buffer position
		INC KeyBufferPosition
	AddByteToBufferEnd:
	RET