; Real-Time Clock Example
;
; Uses the clock circuit and VIA on the OSI 610 board to generate
; interrupts at 10 ms intervals. An interrupt service routine will
; increment counters for time including hours, minutes, and seconds.
;
; The following hardware needs to be set up:
;
; 1. You need an OSI 610 expander board fully populated with memory.
; The program location could be adjusted depending on the memory
; available.
; 2. Jumper pad for the the 6820 IRQ line (near pin 38) to the /IRQ
; line (next to it and to the right when facing the front of the
; board).
; 3. Connect the 10mS timer signal (pad from U10 pin 9) to the pad for
; signal CA1 (the rightmost of the four pads near it).
;
; There is a Basic program provided in the file time.bas that can also
; be run to show how the clock runs even while Basic is executing. To
; ensure that Basic does not wipe out the program, from cold start,
; enter 30000 to the MEMORY SIZE? prompt.
;
; The timer hardware is not exactly 10 ms, so the clock is not
; particularly accurate but could be calibrated in software to improce
; accuracy.
;
; This version count 100ths of seconds, seconds, minutes, and hours.
; Once it runs it returns and is all interrupt driven.
; Could use from BASIC and PEEK the time values. Have to make sure
; program does not use memory used by BASIC.  Also risk of clobbering IRQ
; vector because it is set to $0100 which is in the stack (programmed in
; ROM so we can't change it at run time).
;
; TODO:
; Make fine adjustment to compensate for clock frequency.

        .org    $7530   ; First reserved memory if 30000 was entered for MEMORY SIZE?

; 6820/6821 PIA Chip registers

        PORTA   = $C000 ; Peripheral Register A
        DDRA    = $C000 ; Data Direction Register A
        CREGA   = $C001 ; Control Register A
        PORTB   = $C002 ; Peripheral Register B
        DDRB    = $C002 ; Data Direction Register b
        CREGB   = $C003 ; Control Register b

        IRQ     = $01C0 ; IRQ vector

JIFFIES:        .res 1  ; 100ths of seconds
SECONDS:        .res 1  ; counts seconds
MINUTES:        .res 1  ; counts minutes
HOURS:          .res 1  ; counts hours

INIT:   SEI             ; mask interrupts
        LDA     #$4C    ; JMP ISR instruction
        STA     IRQ     ; Store at interrupt vector
        LDA     #<ISR
        STA     IRQ+1
        LDA     #>ISR
        STA     IRQ+2

        LDA     #0      ; Set clock to zero
        STA     JIFFIES
        STA     SECONDS
        STA     MINUTES
        STA     HOURS

; Set port A for interrupt when CA1 goes low

        LDA     #%11000001
        STA     CREGA   ; Write to control register

        CLI             ; enable interrupts
        RTS             ; Done

; Interrupt service routine
ISR:    PHA             ; save A
        BIT     CREGA   ; Clears interrupt

        LDA     JIFFIES
        CLC
        ADC     #1
        STA     JIFFIES
        CMP     #100    ; reached 1 second?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset jiffies
        STA     JIFFIES
        LDA     SECONDS ; increment seconds
        CLC
        ADC     #1
        STA     SECONDS
        CMP     #60     ; reached 1 minute?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset seconds
        STA     SECONDS
        LDA     MINUTES ; increment minutes
        CLC
        ADC     #1
        STA     MINUTES
        CMP     #60     ; reached 1 hour?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset minutes
        STA     MINUTES
        LDA     HOURS   ; increment hours
        CLC
        ADC     #1
        STA     HOURS
        CMP     #24     ; reached 24 hours?
        BNE     DONE    ; if not, done for now

        LDA     #0      ; reset hours
        STA     HOURS

DONE:   PLA             ; restore A
        RTI             ; and return
