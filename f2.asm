.MODEL SMALL
.STACK 64
.DATA
    ; PROMPT MSG
    MSG1    DB "TOTAL SEATS IN THE PLANE: 150 $"
    MSG2    DB "PLEASE SELECT THE QUANTITY OF SEATS TO RESERVE: $"
    MSG3    DB "REMAINING SEATS: $"
    ERR_MSG DB "INVALID INPUT! PLEASE ENTER A VALID NUMBER (1-9).$"

    ; VARIABLES 
    SEAT    DB 0               ; Total seats to reserve
    REMAIN  DB 0               ; Remaining seats after reservation

    ; CONSTANT
    TOTAL   DB 150             ; Total seats in plane
;-----------------------------------------------------------------------------------------------

.CODE
MAIN PROC FAR
    MOV AX, @DATA
    MOV DS, AX

    ; PROMPT FOR TOTAL SEATS
    MOV AH, 09H
    LEA DX, MSG1
    INT 21H

    ; MAKE NEWLINE
    MOV DL, 0AH  
    MOV AH, 02H   
    INT 21H

    MOV DL, 0DH  
    MOV AH, 02H   
    INT 21H

    ; PROMPT FOR SEATS TO RESERVE
RE_ENTER:                       ; Label for re-entering input
    MOV AH, 09H
    LEA DX, MSG2
    INT 21H

    ; INPUT SEATS TO RESERVE
    CALL INPUT_NUMBER           ; Call the input number procedure

    CMP SEAT, 0FFH              ; Check if invalid input (we will use 0FFH to mark invalid input)
    JE RE_ENTER                 ; If invalid input, re-enter the input

    ; CALCULATE REMAINING SEATS
    MOV AL, TOTAL               ; Load total seats
    SUB AL, SEAT                ; Remaining = TOTAL - SEAT
    MOV REMAIN, AL              ; Store the result in REMAIN

    ; MAKE NEWLINE
    MOV DL, 0AH  
    MOV AH, 02H   
    INT 21H

    MOV DL, 0DH  
    MOV AH, 02H   
    INT 21H

    ; PROMPT REMAINING SEATS
    MOV AH, 09H                 ; Print "REMAINING SEATS: "
    LEA DX, MSG3
    INT 21H

    ; DISPLAY REMAINING SEATS
    MOV AL, REMAIN              ; Load remaining seats
    CALL DISPLAY_NUMBER         ; Display remaining seats

    ; EXIT PROGRAM
    MOV AX, 4C00H
    INT 21H

MAIN ENDP

;-----------------------------------------------------------------------------------------------
; INPUT_NUMBER: Reads a valid single-digit number from the user and stores it in SEAT.
; If invalid input is entered, SEAT is set to 0FFH.
INPUT_NUMBER PROC
    MOV AH, 01H                 ; Read a character
    INT 21H
    CMP AL, 0DH                 ; Check if Enter key was pressed
    JE InvalidInput             ; If Enter pressed without input, invalid

    CMP AL, '0'                 ; Check if input is less than '0'
    JL InvalidInput             ; If less, it's invalid input

    CMP AL, '9'                 ; Check if input is greater than '9'
    JG InvalidInput             ; If greater, it's invalid input

    SUB AL, '0'                 ; Convert ASCII to numeric
    MOV SEAT, AL                ; Store valid input in SEAT
    RET

InvalidInput:
    ; MAKE NEWLINE
    MOV DL, 0AH  
    MOV AH, 02H   
    INT 21H

    MOV DL, 0DH  
    MOV AH, 02H   
    INT 21H

    ; Display error message for invalid input
    MOV AH, 09H
    LEA DX, ERR_MSG
    INT 21H

    ; Newline after error message
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H

    MOV DL, 0DH
    MOV AH, 02H
    INT 21H

    MOV SEAT, 0FFH              ; Set SEAT to invalid marker (0FFH)
    RET
INPUT_NUMBER ENDP

;-----------------------------------------------------------------------------------------------
; DISPLAY_NUMBER: Displays the number in AL as ASCII.
DISPLAY_NUMBER PROC
    PUSH AX                     ; Save AL (which is a byte)
    XOR CX, CX                  ; Clear count

    TEST AL, AL                 ; Check if AL is zero
    JZ PrintZero                ; If zero, go to print zero

ConvertLoop:
    MOV BL, 10                  ; Divisor for decimal
    XOR AH, AH                  ; Clear AH for division (AX = AL)
    DIV BL                      ; AL = AL / 10; AH = remainder
    PUSH AX                     ; Save result (remaining value)
    INC CX                      ; Increase count
    TEST AL, AL                 ; Check if AL is zero
    JNZ ConvertLoop             ; Repeat if not zero

PrintLoop:
    POP AX                      ; Get last digit (in AL)
    MOV DL, AH                  ; Move remainder (digit) to DL
    ADD DL, '0'                 ; Convert to ASCII
    MOV AH, 02H                 ; DOS function to display character
    INT 21H                     ; Display the character
    LOOP PrintLoop              ; Repeat for all digits

    POP AX                      ; Restore original AL
    RET

PrintZero:
    MOV DL, '0'                 ; Print zero
    MOV AH, 02H               
    INT 21H                   
    RET

DISPLAY_NUMBER ENDP

END MAIN
