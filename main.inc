; ===[VIA #1]===
PORTB_1 = $7000
PORTA_1 = $7001
DDRB_1  = $7002
DDRA_1  = $7003

; ===[VIA #2]===
PORTB_2 = $7400
PORTA_2 = $7401
DDRB_2  = $7402
DDRA_2  = $7403

; ===[LCD]===
LCD_E   = %10000000
LCD_RW  = %01000000
LCD_RS  = %00100000

; ===[ACIA]===
ACIA_DATA   = $7800
ACIA_STATUS = $7801
ACIA_CMD    = $7802
ACIA_CTRL   = $7803