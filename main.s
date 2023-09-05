    .include "main.inc"

    .org $8000

; ===[reset]===
;
; flow jumps here from RESET vector
reset:
    ldx #$ff            ; set initial stack pointer
    txs

    jsr lcd_init        ; init LCD
    jsr acia_init       ; init ACIA

; ===[mainloop]===
;
; pretty self-explanatory
mainloop:
    jsr acia_rx         ; blocking recieve
    jsr pchar           ; print Rx data
    jmp mainloop        ; do it again

;======[ ACIA Routines ]======
acia_init:
    pha
    lda #0
    sta ACIA_STATUS     ; soft reset ACIA chip
    lda #%00011111      ; N-8-1 @ 19200 baud
    sta ACIA_CTRL
    lda #%00001011      ; no parity, no echo, no interrupts
    sta ACIA_CMD
    pla
    rts

; Block until Rx buffer is full
; Return Rx data in A register
;
; clobbers A register with result
acia_rx:
    lda ACIA_STATUS
    and #$08            ; test Rx buffer full flag
    beq acia_rx         ; loop while Rx buffer empty
    lda ACIA_DATA
    rts

;======[ LCD Routines ]======

; ===[pstring]===
;
; Print a null-terminated string to the LCD display
;
;   zp00 = 16-bit pointer to string start
pstring:
    phy
    pha
    ldy #0
.loop1
    lda ($00),y     ; load char into a
    beq .pend       ; jmp to end if char is 0
    jsr pchar       ; print current char
    iny
    jmp .loop1
.pend
    pha
    ply
    rts


; ===[pchar]===
;
; Print a character to the LCD display
;
;   a = character to print
pchar:
    jsr lcd_wait            ; ensure not busy
    sta PORTB_2             ; put character code on data lines
    lda #LCD_RS             ; RS=1 RW=E=0
    sta PORTA_2
    lda #(LCD_RS | LCD_E)   ; RS=1 E=1 RW=0 to send instruction
    sta PORTA_2
    lda #LCD_RS             ; RS=1 RW=E=0
    sta PORTA_2
    rts

; ===[lcd_init]===
;
; Initialize ports and set LCD operating mode
lcd_init:
    lda #%11111111      ; Set all pins on port B_2 to output
    sta DDRB_2
    lda #%11100000      ; Set top 3 pins on port A_2 to output
    sta DDRA_2

    lda #%00111000      ; Set 8-bit mode; 2-line display; 5x8 font
    jsr lcd_cmd
    lda #%00001110      ; Display on; cursor on; blink off
    jsr lcd_cmd
    lda #%00000110      ; Increment and shift cursor; don't shift display
    jsr lcd_cmd
    lda #$00000001      ; Clear display
    jsr lcd_cmd
    rts

; ===[lcd_cmd]===
;
; Send a command to the LCD
;
;   a = command to send
lcd_cmd:
    jsr lcd_wait        ; Ensure not busy
    sta PORTB_2         ; Set command on data lines
    lda #0              ; RS=RW=E=0
    sta PORTA_2
    lda #LCD_E          ; RS=0 RW=0; E=1 to send instruction
    sta PORTA_2
    lda #0              ; RS=RW=E=0
    sta PORTA_2
    rts

; ===[lcd_wait]===
;
; Wait for LCD to be ready for next instruction
lcd_wait:
    pha
    lda #%00000000          ; Set port B to input
    sta DDRB_2
lcdbusy:
    lda #LCD_RW             ; RW=1 E=0
    sta PORTA_2
    lda #(LCD_RW | LCD_E)   ; RW=1 E=1
    sta PORTA_2
    lda PORTB_2             ; Read D7-D0
    and #%10000000          ; Test for busy flag
    bne lcdbusy             ; Loop if busy flag set

    lda #LCD_RW             ; RW=1 E=0
    sta PORTA_2
    lda #%11111111          ; Restore Port B to output
    sta DDRB_2
    pla
    rts

message: .asciiz "Hello, world!"

    .org $fffc
    .word reset
    .word $0000
