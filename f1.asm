.MODEL          SMALL
.STACK          64
.DATA

    ; PROMPTS
    MSG1    DB  "   WELCOME TO MALAYSIA AIRLINE TICKET BOOKING SYSTEM   $"
    Line    DB  "--------------------------------------------------------$" 
    MSG2    DB  "PLEASE SELECT THE QUANTITY OF TICKET TO PURCHASE (1-9): $"
    MSG3    DB  "THE QUANTITY OF TICKET PURCHASED: $"
    MSG4    DB  "TOTAL PRICE: RM $"
    ERRMSG  DB  "INVALID INPUT!$"

    ; CONSTANTS
    TICKET_PRICE DW 300    ; TICKET PRICE = RM300 
    SERVICE_TAX  DB 50     ; SERVICE TAX = RM50 
    HANDLING_FEE DB 50     ; HANDLING FEE = RM50 

    ; VARIABLES
    INPUT_Q     DB ?       ; INPUT QUANTITY (1-9)
    TOTAL_PRICE DW ? ; TOTAL PRICE (2 bytes for large values)

;----------------------------------------------------------------------------------------------------------------------------

.CODE

MAIN PROC FAR

    MOV AX, @DATA
    MOV DS, AX

    ; Print Line
    MOV AH, 09H            ; Print --------------
    LEA DX, Line
    INT 21H
  
    ; NEW LINE
    CALL NEWLINE

    ; PROMPT TITLE
    MOV AH, 09H            ; Print "WELCOME TO MALAYSIA AIRLINE TICKET BOOKING SYSTEM"
    LEA DX, MSG1
    INT 21H

    ; NEW LINE
    CALL NEWLINE

    ; Print Line
    MOV AH, 09H            ; Print --------------
    LEA DX, Line
    INT 21H

    ; NEW LINE
    CALL NEWLINE

    ;PROMPT SELECT QUANTITY
    MOV AH, 09H            ; Print "PLEASE SELECT THE QUANTITY OF TICKET TO PURCHASE (1-9):"
    LEA DX, MSG2
    INT 21H

    ; INPUT
    MOV AH, 01H            ; User input
    INT 21H
    SUB AL, 30H            ; Convert ASCII to integer (0-9)

    ; VALIDATE INPUT (1-9)
    CMP AL, 1
    JL INVALID_INPUT       ; If less than 1, jump to error message
    CMP AL, 9
    JG INVALID_INPUT       ; If greater than 9, jump to error message

    ; VALID INPUT
    MOV INPUT_Q, AL       ; Store input quantity in INPUT_Q

    ; NEW LINE 
    CALL NEWLINE

    ; DISPLAY QUANTITY
    MOV AH, 09H            ; Print "THE QUANTITY OF TICKET PURCHASED: "
    LEA DX, MSG3
    INT 21H

    MOV AL, INPUT_Q        ; Load quantity into AL
    ADD AL, 30H            ; Convert back to ASCII
    MOV DL, AL             
    MOV AH, 02H            ; Print character
    INT 21H

    ; NEW LINE after displaying quantity
    CALL NEWLINE

    ; CALCULATE TOTAL PRICE
    XOR AX, AX             ; Clear AX (start from 0)
    MOV CL, INPUT_Q        ; Load the number of tickets into CL
    MOV BX, TICKET_PRICE   ; Load the ticket price into BL

CALCULATE_PRICE:
    ADD AX, BX             ; Add ticket price to AX
    DEC CL
    JNZ CALCULATE_PRICE    ; Decrease CL and loop until CL is 0

    ; After calculating ticket prices, add service and handling fees
    ADD AL, SERVICE_TAX    ; Add service tax
    ADD AL, HANDLING_FEE   ; Add handling fee

    ; STORE TOTAL PRICE (AX is 16-bit, so store the low and high byte in DBs)
    MOV [TOTAL_PRICE], AX  ; Store the total price in the TOTAL_PRICE variable (2 bytes)

    ; PROMPT TOTAL PRICE
    MOV AH, 09H            ; Print "TOTAL PRICE: RM"
    LEA DX, MSG4
    INT 21H

    ; DISPLAY TOTAL PRICE
    MOV AX, [TOTAL_PRICE]  ; Load the total price from memory
    CALL DISPLAY_NUMBER    ; Display the total price

    ; Exit program
    MOV AX, 4C00H
    INT 21H
;------------------------------------------------------------------------------------------------------------

INVALID_INPUT:

    ; NEW LINE
    CALL NEWLINE

    ; DISPLAY ERROR MESSAGE
    MOV AH, 09H
    LEA DX, ERRMSG
    INT 21H

    ; NEW LINE
    CALL NEWLINE

    JMP MAIN               ; Restart the program

;--------------------------------------------------------------------------------------------------

NEWLINE PROC                
    MOV DL, 0AH            ; Line Feed
    MOV AH, 02H
    INT 21H

    MOV DL, 0DH            ; Carriage Return
    MOV AH, 02H
    INT 21H
    RET
NEWLINE ENDP

;----------------------------------------------------------------------------------------------------------

; Procedure: DISPLAY_NUMBER
; Displays a number in AX as ASCII characters.
DISPLAY_NUMBER PROC
    PUSH AX                ; Save AX
    MOV CX, 0              ; Clear digit count
    MOV BX, 10             ; Divisor for decimal system

DIVIDE_LOOP:
    XOR DX, DX             ; Clear DX
    DIV BX                 ; Divide AX by 10 (result in AX, remainder in DX)
    PUSH DX                ; Store remainder (digit) on stack
    INC CX                 ; Increase digit count
    CMP AX, 0              ; Check if quotient is zero
    JNZ DIVIDE_LOOP        ; If not, repeat

    ; Now CX contains the digit count, and stack contains digits in reverse order
DISPLAY_DIGITS:
    POP DX                 ; Pop the digit from stack
    ADD DL, '0'            ; Convert to ASCII
    MOV AH, 02H
    INT 21H                ; Display the digit
    LOOP DISPLAY_DIGITS    ; Repeat until all digits are displayed

    POP AX                 ; Restore AX
    RET
DISPLAY_NUMBER ENDP 

MAIN ENDP
END MAIN