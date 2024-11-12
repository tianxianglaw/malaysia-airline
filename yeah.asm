.MODEL SMALL
.STACK 64
.DATA

    ; Variables
    BASE_ALLOW      DW 1000              ; Base allowance as a word
    ADD_CHR         DB ?                  ; Two-digit additional charges entered by user
    TOT_ALLOW       DW ?                  ; Total allowance as a word
    BASE_MSG        DB "Base Allowance = 1000$", 0DH, 0AH  ; Base allowance message
    ADD_MSG         DB "Enter additional charge (00-99): $" ; Prompt for additional charge
    RESULT_MSG      DB "Cabin Baggage Allowance = $", 0DH, 0AH  ; Result message
    ERR_MSG         DB "Invalid input! Please enter a number between 00-99.$", 0DH, 0AH ; Error message

.CODE

MAIN PROC FAR

    MOV AX, @DATA
    MOV DS, AX

    ; Display base allowance message
    MOV AH, 09H
    LEA DX, BASE_MSG
    INT 21H

    ; Newline after base allowance message
    CALL NEWLINE

RE_ENTER:  ; Label for re-entering input if invalid
    ; Display additional charge input prompt (no newline here)
    MOV AH, 09H
    LEA DX, ADD_MSG
    INT 21H

    ; Input two digits for ADD_CHR (on the same line as the prompt)
    CALL INPUT_TWO_DIGITS

    ; If error, re-enter the input
    CMP BL, 'E'
    JE RE_ENTER  ; If invalid input, go back to re-enter

    ; Newline after valid input
    CALL NEWLINE

    ; Calculate total allowance
    CALL CALCULATE_ALLOWANCE

    ; Display result message
    MOV AH, 09H
    LEA DX, RESULT_MSG
    INT 21H

    ; Display total allowance result
    CALL DISPLAY_TOTAL_ALLOWANCE

    ; Newline after displaying the result
    CALL NEWLINE

    ; End the program
    MOV AX, 4C00H
    INT 21H

MAIN ENDP

;---------------------------------------------------------------------------------------

; Procedure to input two digits (00-99) and convert to numeric
INPUT_TWO_DIGITS PROC
    ; Input first digit
    MOV AH, 01H     
    INT 21H
    CMP AL, '0'
    JL ERROR_REENTRY
    CMP AL, '9'
    JG ERROR_REENTRY
    SUB AL, '0'     ; Convert first ASCII digit to numeric
    MOV BL, AL      ; Store first digit in BL

    ; Input second digit
    MOV AH, 01H     
    INT 21H
    CMP AL, '0'
    JL ERROR_REENTRY
    CMP AL, '9'
    JG ERROR_REENTRY
    SUB AL, '0'     ; Convert second ASCII digit to numeric

    ; Combine digits into ADD_CHR
    MOV AH, 0       ; Clear AH for multiplication
    MOV AL, BL      ; Move first digit to AL for multiplication
    MOV BL, 10      ; Prepare for multiplication by 10
    MUL BL          ; AX = First digit * 10 (result stored in AX)

    ; Add second digit to AL
    ADD AL, [ADD_CHR]  ; Add the second digit, stored in ADD_CHR (fixing previous approach)
    MOV ADD_CHR, AL ; Store the numeric result in ADD_CHR
    RET

ERROR_REENTRY:
    ; Display error message
    MOV AH, 09H
    LEA DX, ERR_MSG
    INT 21H

    ; Newline after error message
    CALL NEWLINE

    MOV BL, 'E'     ; Flag for re-entry
    RET
INPUT_TWO_DIGITS ENDP

;---------------------------------------------------------------------------------------

; Procedure to calculate total allowance (TOT_ALLOW = BASE_ALLOW + ADD_CHR)
CALCULATE_ALLOWANCE PROC
    MOV AX, BASE_ALLOW    ; Load base allowance into AX
    MOV BL, ADD_CHR       ; Load additional charges (from DB) into BL
    ADD AX, BX            ; Add additional charges to AX
    MOV TOT_ALLOW, AX     ; Store the result
    RET
CALCULATE_ALLOWANCE ENDP

;---------------------------------------------------------------------------------------

; Procedure to display total allowance
DISPLAY_TOTAL_ALLOWANCE PROC
    MOV AX, TOT_ALLOW     ; Load total allowance to AX

    ; Convert total allowance from binary to decimal and display
    CALL CONVERT_DECIMAL_TO_ASCII
    RET
DISPLAY_TOTAL_ALLOWANCE ENDP

;---------------------------------------------------------------------------------------

; Procedure to convert a 16-bit binary number in AX to ASCII decimal format and display it
CONVERT_DECIMAL_TO_ASCII PROC
    PUSH AX
    PUSH BX
    PUSH CX

    ; Initialize registers
    MOV CX, 0          ; Counter for digits
    MOV BX, 10         ; Divisor for base-10 conversion

DIV_LOOP:
    XOR DX, DX         ; Clear DX for division
    DIV BX             ; Divide AX by 10, result in AX, remainder in DX
    PUSH DX            ; Push remainder (digit) onto stack
    INC CX             ; Count the digit
    CMP AX, 0
    JNZ DIV_LOOP       ; Repeat until AX is 0

DISPLAY_DIGITS:
    POP DX             ; Pop digit from stack
    ADD DL, '0'        ; Convert digit to ASCII
    MOV AH, 02H
    INT 21H            ; Print the digit
    LOOP DISPLAY_DIGITS

    POP CX
    POP BX
    POP AX
    RET
CONVERT_DECIMAL_TO_ASCII ENDP

;---------------------------------------------------------------------------------------

; Newline procedure
NEWLINE PROC
    MOV DL, 0AH     ; Line Feed
    MOV AH, 02H
    INT 21H

    MOV DL, 0DH     ; Carriage Return
    MOV AH, 02H
    INT 21H
    RET
NEWLINE ENDP

END MAIN
