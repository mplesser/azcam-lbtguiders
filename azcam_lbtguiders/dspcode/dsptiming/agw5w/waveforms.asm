; waveforms.asm for Gen3 - lbtguider
; 05Oct04 last change by Michael Lesser
; 08 Feb 06 - changes by R. Tucker

; 19Aug13 NO SMEAR MPL

; *** boards and timing delays ***
VIDEO		EQU	$000000	; Video processor board (all are addressed together)
CLK2		EQU	$002000	; Clock driver board select = board 2 low bank 
CLK3		EQU	$003000	; Clock driver board select = board 2 high bank
;P_DELAY	EQU	$620000	; 4 usec parallel clock delay
P_DELAY		EQU	$300000	; 2 usec parallel clock delay - new 
S_DELAY		EQU	$030000	; serial clock delay
V_DELAY		EQU	$000000	; video processor delay
DWELL		EQU	$300000	; 2 usec pixel integration
PARMULT	EQU	1		; P_DELAY multiplier
GENCNT	EQU	1		; Gen clock counter (2 for gen1/2, 1 for gen3)

; *** video channels ***
;  for LBT guider dewars, OS1 is right output, OS0 is left output
;SXMIT	EQU	$00F000	; Transmit A/D = 0
SXMIT	EQU	$00F041	; Transmit A/D = 1
;SXMIT	EQU	$00F040	; Transmit A/Ds = 0 to 1

; *** DSP Y memory parameter table - written by AzCamTool
	INCLUDE "Ypars.asm"

; *** clock rails ***
RG_HI		EQU	 +4.0	; Reset Gate
RG_LO		EQU	 -8.0	;		
S_HI		EQU	 +2.0	; Serial clocks	
S_LO		EQU	 -8.0	;		
SW_HI		EQU	 -5.0	; Dump gate	
SW_LO		EQU	 -5.0	;		
P_HI		EQU	 +4.0	; Parallel clock phases 1 & 2
P_LO		EQU	-10.0	; (+4.0 / -10.0)
P3_HI		EQU	 +4.0	; Parallel clock phase 3 (MPP)
P3_LO		EQU	-10.0	; (+4.0 / -10.0)
TG_HI		EQU	  0.0	; Transfer gate - not used
TG_LO		EQU	  0.0

;RG_HI		EQU	 +2.7	; Reset Gate 	(+4.0)
;RG_LO		EQU	 -9.3	;		(-8.0)
;S_HI		EQU	 +0.7	; Serial clocks	(+2.0)
;S_LO		EQU	 -8.3	;		(-8.0)
;SW_HI		EQU	 -9.3	; Dump gate	(-5.0)
;SW_LO		EQU	 -9.3	;		(-5.0)
;P_HI		EQU	 +2.7	; Parallel clock phases 1 & 2
;P_LO		EQU	 -8.3	; (+4.0 / -10.0)
;P3_HI		EQU	 +0.7	; Parallel clock phase 3 (MPP)
;P3_LO		EQU	-10.0	; (+4.0 / -10.0)
;TG_HI		EQU	  0.0	; Transfer gate - not used
;TG_LO		EQU	  0.0

; *** bias voltages ***
VOD		EQU	+24.0	; Output Drains	(+24.0)
VRD		EQU	+12.0	; Reset Drain	(+12.0)
VOG		EQU	 -3.0	; Output Gates	(-3.0)
B5		EQU	  5.0	; not used
B7		EQU	  5.0	; not used

;VOD		EQU	+20.7	; Output Drains	(+24.0)
;VRD		EQU	 +8.7	; Reset Drain	(+12.0)
;VOG		EQU	 -7.3	; Output Gates	(-3.0)

; *** video output offset ***
; higher value here lowers output value (~4.8 DN change/unit change here)
OFFSET	EQU	2000	; global offset to all channels
OFFSET0	EQU	0	; offsets for channel 0
OFFSET1	EQU	0	; offsets for channel 1

; *** clock rail aliases ***
S1_HI		EQU	S_HI
S1_LO		EQU	S_LO
S2_HI		EQU	S_HI
S2_LO		EQU	S_LO
S3_HI		EQU	S_HI
S3_LO		EQU	S_LO
P1_HI		EQU	P_HI
P1_LO		EQU	P_LO	
P2_HI		EQU	P_HI
P2_LO		EQU	P_LO	
Q1_HI		EQU	P_HI
Q1_LO		EQU	P_LO	
Q2_HI		EQU	P_HI
Q2_LO		EQU	P_LO
Q3_HI		EQU	P3_HI
Q3_LO		EQU	P3_LO	

; *** clock state bits ***
	INCLUDE "SwitchStates.asm"

; *** default clock states ***
SDEF		EQU	S1L+S2H+S3L+RGH+SWL		; during parallel shifting
PDEF		EQU	P1L+P2L+P3L				; during serial shifting
QDEF		EQU	Q1L+Q2L+Q3L				; "  "
PQDEF		EQU	PDEF+QDEF				; "  "

; *** parallel shifting of storage only ***
PXFER		DC	EPXFER-PXFER-GENCNT
	INCLUDE "p_3123_mpp.asm"
EPXFER

; *** parallel shifting of entire device ***
PQXFER	DC	EPQXFER-PQXFER-GENCNT
	INCLUDE "pq_3123_mpp.asm"
EPQXFER

; *** reverse shifting of entire device during focus ***
RXFER		EQU	PXFER
;RXFER 	DC	ERXFER-RXFER-GENCNT
;	INCLUDE "xxx"
;ERXFER

; *** serial shifting ***
	INCLUDE "s_12_123n.asm"

; *** bias voltage table ***
	INCLUDE "DACS.asm"

; *** timing NOP ***
TNOP		DC	ETNOP-TNOP-GENCNT
		DC	$00E000
		DC	$00E000
ETNOP

; ******** END OF WAVEFORM.ASM **********
