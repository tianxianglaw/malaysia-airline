TITLE MEMBERSHIP POINT 
.MODEL SMALL
.STACK 64
.DATA
    BASE_POINT DB 2000/256, 2000 MOD 256     ; Base point in decimal (two bytes)
    EXPIRED_POINT DB 1000/256, 1000 MOD 256  ; Expired point in decimal (two bytes)
    USED_POINT DB ?                           ; Used points (1 byte)
    EXTRA_EARNED DB ?                         ; Extra earned points (1 byte)
    TOTAL_POINT DB 2 DUP (0)                  ; Total points (2 bytes)
    REMAINING_POINT DB 2 DUP (0)              ; Remaining points (2 bytes)
    BASEPOINTMSG DB 'Base Point: $'
    EXPIREDMSG DB 'Expired Point: $'
    MSG1 DB 'Total membership point: $'
    MSG2 DB 'Remaining Membership point: $'
    NEWLINE DB 0DH, 0AH, '$'
    RESULT DB 6 DUP ('$')                     ; Buffer for printing numbers (6 for 5 digits + null)
    INPUTMSG DB 'Enter Used Points (0-9): $'
    INPUTMSG2 DB 'Enter Extra Earned Points (0-9): $'
    ERRMSG DB 'Invalid input! Please re-enter!!!$' 
;------------------------------------------------------------------------------------------------------------
.CODE
MAIN PROC FAR
    MOV AX, @DATA
    MOV DS, AX

    ; Display base point
    MOV DX, OFFSET BASEPOINTMSG
    MOV AH, 09H
    INT 21H

    ; Load Base Points into AX
    MOV AL, BASE_POINT[1]     ; Load low byte
    MOV AH, BASE_POINT[0]     ; Load high byte
    CALL PrintNum 

    ; New line
    MOV DX, OFFSET NEWLINE
    MOV AH, 09H
    INT 21H
	
    ; Display expired point
    MOV DX, OFFSET EXPIREDMSG
    MOV AH, 09H
    INT 21H
	
    ; Load Expired Points into AX
    MOV AL, EXPIRED_POINT[1]  ; Load low byte
    MOV AH, EXPIRED_POINT[0]  ; Load high byte
    CALL PrintNum 
    ; New line
    MOV DX, OFFSET NEWLINE
    MOV AH, 09H
    INT 21H
	
    ; Get used points
    MOV DX, OFFSET INPUTMSG
    MOV AH, 09H
    INT 21H

    CALL GetInput
    MOV USED_POINT, AL
	
	; New line
    MOV DX, OFFSET NEWLINE
    MOV AH, 09H
    INT 21H

    ; Get extra earned points
    MOV DX, OFFSET INPUTMSG2
    MOV AH, 09H
    INT 21H

    CALL GetInput
    MOV EXTRA_EARNED, AL
	
	; New line
    MOV DX, OFFSET NEWLINE
    MOV AH, 09H
    INT 21H
	
    ; Calculate total points
    ; Total Points = Base Points + Extra Earned
    MOV AL, BASE_POINT[1]     ; Load low byte of base points
    ADD AL, EXTRA_EARNED       ; Add extra earned points to low byte
    MOV TOTAL_POINT[1], AL     ; Store result in total low byte
    MOV AL, BASE_POINT[0]      ; Load high byte of base points
    ADC AL, 0                  ; Add carry from low byte
    MOV TOTAL_POINT[0], AL     ; Store result in total high byte

    ; Subtract used points from total points
    MOV AL, TOTAL_POINT[1]     ; Load low byte of total points into AL
    SUB AL, USED_POINT         ; Subtract used points from low byte
    MOV TOTAL_POINT[1], AL     ; Store the result in total low byte
    MOV AL, TOTAL_POINT[0]     ; Load high byte of total points into AL
    SBB AL, 0                  ; Subtract borrow from high byte if necessary
    MOV TOTAL_POINT[0], AL     ; Store the result in total high byte

    ; Subtract expired points from total points to get remaining points
    MOV AL, TOTAL_POINT[1]     ; Load low byte of total points into AL
    SUB AL, EXPIRED_POINT[1]   ; Subtract expired low byte
    MOV REMAINING_POINT[1], AL ; Store the result in remaining low byte
    MOV AL, TOTAL_POINT[0]     ; Load high byte of total points into AL
    SBB AL, EXPIRED_POINT[0]   ; Subtract expired high byte with borrow
    MOV REMAINING_POINT[0], AL ; Store the result in remaining high byte

    ; Subtract 1 from remaining points
    MOV AL, REMAINING_POINT[1] ; Load low byte of remaining points
    DEC AL                      ; Subtract 1
    JZ RemainingUnderflow       ; Check for underflow (if it becomes 0)
    MOV REMAINING_POINT[1], AL  ; Store the updated low byte of remaining points
    JMP DisplayResults          ; Go to display results

RemainingUnderflow:
    ; If the low byte becomes 0, we should also check the high byte
    MOV AL, REMAINING_POINT[0] ; Load high byte of remaining points
    DEC AL                      ; Subtract 1 from high byte
    MOV REMAINING_POINT[0], AL  ; Store updated high byte of remaining points

DisplayResults:
    ; Display total points
    MOV DX, OFFSET MSG1
    MOV AH, 09H
    INT 21H

    ; Prepare for printing total points
    MOV AL, TOTAL_POINT[1]     ; Load low byte of total points
    MOV AH, TOTAL_POINT[0]     ; Load high byte of total points
    CALL PrintNum 

    ; New line
    MOV DX, OFFSET NEWLINE
    MOV AH, 09H
    INT 21H

    ; Display remaining points
    MOV DX, OFFSET MSG2
    MOV AH, 09H
    INT 21H

    ; Prepare for printing remaining points
    MOV AL, REMAINING_POINT[1] ; Load low byte of remaining points
    MOV AH, REMAINING_POINT[0] ; Load high byte of remaining points
    CALL PrintNum  

    ; Exit program
    MOV AX, 4C00H
    INT 21H

MAIN ENDP

; Procedure to get user input
GetInput PROC
    MOV AL, 0                  ; Clear AL for input

ReadInput:
    MOV AH, 01H                ; Read a character
    INT 21H
    CMP AL, '0'                ; Check if it's less than '0'
    JL InvalidInput            ; Jump if invalid
    CMP AL, '9'                ; Check if it's greater than '9'
    JG InvalidInput            ; Jump if invalid
    SUB AL, '0'                ; Convert from ASCII to number

    RET

InvalidInput:
    ; Display error message
    MOV DX, OFFSET ERRMSG
    MOV AH, 09H
    INT 21H

    ; New line
    MOV DX, OFFSET NEWLINE
    MOV AH, 09H
    INT 21H

    ; Prepare for re-entering the input on the same line
    MOV DX, OFFSET INPUTMSG    ; Re-display input message
    MOV AH, 09H
    INT 21H

    ; Clear the input buffer (optional)
    ; This part will ensure we don't leave behind the invalid character
    MOV AH, 0                  ; Clear the screen to allow for clean input
    INT 10H

    ; Restart the input process
    JMP ReadInput              ; Retry input
GetInput ENDP

; Procedure to print a number
PrintNum PROC
    MOV SI, OFFSET RESULT       
    XOR CX, CX                  ; Clear digit count
    XOR DX, DX                  ; Clear DX

    TEST AX, AX                  ; Check if AX is zero
    JZ PrintZero                ; If AX is zero, go to PrintZero

ConvertLoop:
    XOR DX, DX                  ; Clear DX for division
    MOV BX, 10                  ; Set base to 10
    DIV BX                      ; Divide AX by 10
    ADD DL, '0'                 ; Convert remainder to ASCII
    MOV [SI], DL                ; Store ASCII digit
    INC SI                      ; Move to next position
    INC CX                      ; Increment digit count
    TEST AX, AX                 ; Check if AX is zero
    JNZ ConvertLoop             ; Repeat if not zero

    DEC SI                      ; Point to last stored digit
    MOV BYTE PTR [SI + 1], '$'  ; Null terminate string for display

PrintLoop:
    MOV DL, [SI]                ; Get digit
    MOV AH, 02H                 ; Function to display character
    INT 21H                     ; Call DOS
    DEC SI                      ; Move to previous digit
    LOOP PrintLoop              ; Repeat for all digits

    RET

PrintZero:
    MOV BYTE PTR [RESULT], '0'  ; Prepare to print '0'
    MOV BYTE PTR [RESULT + 1], '$' ; Null terminate string
    MOV AH, 09H                 ; Function to display string
    INT 21H
    RET
PrintNum ENDP

END MAIN
