CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
	
STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS

DATA    SEGMENT PARA 'DATA'
DIGITS  DB 0C0h, 0F9h, 0A4h, 0B0h, 99h, 92h, 82h, 0F8h, 80h, 90h			; 0 to 9
DELETED DB 50 DUP(0)
DELPTR  DW 00h								; points to last empty place
DATA    ENDS


START PROC


MOV AX, DATA
MOV DS, AX

   ;You may write one time jobs here
	 MOV DX, 0AFh
	 MOV AL, 081h				; IO(1),Mode 0(00), Port A output(0), Port C upper output, Port b Mod 0 output, PortC lower input
	 OUT DX, AL
 
	; BL First Digit, BH Second, DL Third, DH last Digit
	MOV AH, DIGITS[0]			
	MOV BL, AH
	MOV BH, AH
	MOV DL, AH
	MOV DH, AH
	; At first assign 0 to all
MAINLOOP:
       CALL TAKE_INPUT
RET
START ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TAKE_INPUT PROC NEAR
	MOV SI, 0				; COUNT of *s pressed
ENDLESS:
       XOR AX,AX				; Make sure AX is zero
       CALL SHOW
   ACTIVE_FIRST_COL:      
	 MOV AL, 00100000b			; Activate Column 1
	 OUT 0ABh, AL				; Send to PORT B
	 
	 IN AL, 0ADh				; Read from PORT C
	 AND AL, 0Fh				; See the lower 4 bits of PORT C
	 JNZ CHECK_FIRST_COL
	 
   ACTIVE_SECOND_COL:      
	 MOV AL, 01000000b			; Activate Column 2
	 OUT 0ABh, AL				
	 
	 IN AL, 0ADh				
	 AND AL, 0Fh
	 JNZ CHECK_SECOND_COL
	 
   ACTIVE_THIRD_COL:      
	 MOV AL, 10000000b			; Activate Column 3
	 OUT 0ABh, AL				
	 
	 IN AL, 0ADh				
	 AND AL, 0Fh
	 JNZ CHECK_THIRD_COL
	 
   CHECK_FIRST_COL:
     CHECK_ONE:
	 TEST AL, 01h				; was it one ?
	 JZ CHECK_FOUR
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[1]		 
	 CALL SCROLL_TO_LEFT			; Scroll the numbers to the left
	 CALL SHOW				; SHOW 1
	 JMP ENDLESS
	 
     CHECK_FOUR:	
	 TEST AL, 02h				; was it four ?
	 JZ CHECK_SEVEN
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[4]
	 CALL SCROLL_TO_LEFT	 
	 CALL SHOW			
	 JMP ENDLESS
	 
     CHECK_SEVEN:	
	 TEST AL, 04h				; was it 7 ? 
	 JZ CHECK_STAR	
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[7]			
	 CALL SCROLL_TO_LEFT		
	 CALL SHOW
	 JMP ENDLESS
	 
     CHECK_STAR:	
	 TEST AL, 08h				; was it *
	 JZ ENDLESS
	 CMP SI,5
	 JZ MAKE_ALL_ZERO
	 INC SI
	 JMP ENDLESS
	 
   CHECK_SECOND_COL:
     CHECK_TWO:
	 TEST AL, 01h				; was it 2 ?
	 JZ CHECK_FIVE
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[2]			
	 CALL SCROLL_TO_LEFT			; Scroll the numbers to the left
	 CALL SHOW				; SHOW 2
	 JMP ENDLESS
	 
     CHECK_FIVE:	
	 TEST AL, 02h				; was it 5 ?
	 JZ CHECK_EIGHT
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[5]
	 CALL SCROLL_TO_LEFT	 
	 CALL SHOW			
	 JMP ENDLESS
	 
     CHECK_EIGHT:	
	 TEST AL, 04h				; was it 8 ? 
	 JZ CHECK_ZERO	
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[8]			
	 CALL SCROLL_TO_LEFT		
	 CALL SHOW
	 JMP ENDLESS
	 
     CHECK_ZERO:	
	 TEST AL, 08h				; was it 0 ?
	 JZ ENDLESS
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[0]			
	 CALL SCROLL_TO_LEFT			
	 CALL SHOW
	 JMP ENDLESS     
   CHECK_THIRD_COL:   
     CHECK_THREE:
	 TEST AL, 01h				; was it 2 ?
	 JZ CHECK_SIX
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[3]			
	 CALL SCROLL_TO_LEFT			; Scroll the numbers to the left
	 CALL SHOW				; SHOW 2
	 JMP ENDLESS
	 
     CHECK_SIX:	
	 TEST AL, 02h				; was it 5 ?
	 JZ CHECK_NINE
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[6]
	 CALL SCROLL_TO_LEFT	 
	 CALL SHOW			
	 JMP ENDLESS
	 
     CHECK_NINE:	
	 TEST AL, 04h				; was it 8 ? 
	 JZ CHECK_HASH	
	 CALL SAVE_DELETED_DIGIT		; Secure the last digit that is currently inside of BL
	 MOV BL, DIGITS[9]			
	 CALL SCROLL_TO_LEFT		
	 CALL SHOW
	 JMP ENDLESS
	 
     CHECK_HASH:	
	 TEST AL, 08h				; was it # ?
	 JZ ENDLESS				
	 CALL SCROLL_TO_RIGHT			; HERE before calling DI contains last deleted digit
	 JMP ENDLESS
	 
MAKE_ALL_ZERO:	 
	MOV AH, DIGITS[0]			
	MOV BL, AH
	MOV BH, AH
	MOV DL, AH
	MOV DH, AH
	JMP ENDLESS
RET
TAKE_INPUT ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SHOW PROC NEAR
     MOV CL, 0Fh
L1:     
     CALL SHOW_NUMBERS
     LOOP L1
     RET
SHOW ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SHOW_NUMBERS PROC NEAR			; CL-1, CH-2, DL-3,DH-4 AH TEMP
      ;ENDLESS:	
        MOV AL, 1h	
	OUT 0ABh, AL	
	
	MOV AL, BL
	OUT 0A9h, AL
	
	CALL WAIT_A_LITTLE
	
	MOV AL, 2h
	OUT 0ABh, AL
	
	MOV AL, BH
	OUT 0A9h, AL
	
	CALL WAIT_A_LITTLE
	
	MOV AL, 4h
	OUT 0ABh, AL
	
	MOV AL, DL
	OUT 0A9h, AL
	
	CALL WAIT_A_LITTLE
	
	MOV AL, 8h
	OUT 0ABh, AL
	
	MOV AL, DH
	OUT 0A9h, AL
	
	CALL WAIT_A_LITTLE
	
	;JMP ENDLESS
RET
SHOW_NUMBERS ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SCROLL_TO_LEFT PROC NEAR			; BL-1, BH-2, DL-3,DH-4 AH TEMP
   MOV AH, BL
   MOV BL, BH
   MOV BH, DL
   MOV DL, DH
   MOV DH, AH
RET
SCROLL_TO_LEFT ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
SCROLL_TO_RIGHT PROC NEAR			; BL-1, BH-2, DL-3,DH-4 AH TEMP
   CALL GET_DELETED_DIGIT		; AFter call DI contains last deleted digit
   MOV AX, DI				; Get deleted digit into AL
   MOV DH,DL
   MOV DL,BH
   MOV BH, BL
   MOV BL, AL

RET
SCROLL_TO_RIGHT ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
GET_DELETED_DIGIT PROC NEAR			
   PUSH BX
   DEC WORD PTR DELPTR				; Decrement the DELPTR one
   MOV BX, 0
   CMP DELPTR, BX				; Check bounds of DELETED array
   JG L_SCR
   MOV BX, 50					; IF out of range, make the DELPTR 50
   MOV DELPTR, BX 
 L_SCR:  
   MOV BX, DELPTR
   XOR AX,AX
   MOV AL, DELETED[BX]
   MOV DI, AX			; Get the last deleted digit into DI
   POP BX
RET
GET_DELETED_DIGIT ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
SAVE_DELETED_DIGIT PROC NEAR			
   PUSH BX
   
   MOV AL, BL				; Secure the last digit
   MOV DI, AX
   
   MOV BX, DELPTR			; Get the pointer
   MOV DELETED[BX], AL
   INC WORD PTR DELPTR
   
   ; When DELPTR reaches 50th element, round the pointer back to 0
   MOV BX, 50
   CMP DELPTR, BX
   JL END_OF_DELETE_DIGIT
   XOR BX,BX
   MOV DELPTR, BX
   
   
END_OF_DELETE_DIGIT:
   POP BX
   
RET
SAVE_DELETED_DIGIT ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WAIT_A_LITTLE PROC NEAR
   PUSH CX
   MOV CX, 0300H
   LOOP1: 
      NOP
      LOOP LOOP1
   POP CX
RET
WAIT_A_LITTLE ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CODE    ENDS
        END START