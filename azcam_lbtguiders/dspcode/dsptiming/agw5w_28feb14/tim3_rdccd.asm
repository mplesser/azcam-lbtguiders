; rdccd.asm - AzCam CCD Readout routines for ARC Gen 3
; Based on a the ICE readout code developed by Skip Schaller and Michael Lesser.  
; 20Aug04 last change by Michael Lesser

; Routines contained in this file are:

; RDCCD
; PDATA
; PDSKIP
; PSKIP
; PQSKIP
; RSKIP
; FSSKIP
; SSKIP
; SDATA
; CNSAMPS
; CNPAMPS
; PCLOCK
; CLEAR
; CLR_CCD
; FOR_PSHIFT
; PAR_PSHIFT
; START_IDLE_CLOCKING
; IDLE

; *******************************************************************
; Shift and read CCD
RDCCD
	BSET	#ST_RDC,X:<STATUS 	; Set status to reading out
	JSR	<PCI_READ_IMAGE		; Get the PCI board reading the image

	JSET	#TST_IMG,X:STATUS,SYNTHETIC_IMAGE	; jump for fake image

	MOVE	Y:<AFPXFER0,R0		; frame transfer
	JSR	<CLOCK
	MOVE  #<FRAMET,R0
	JSR   <PQSKIP
	JCS	<START

	MOVE  #<NPPRESKIP,R0		; skip to underscan
	JSR   <PSKIP
	JCS	<START
	MOVE	Y:<AFPXFER2,R0
	JSR	<CLOCK
	MOVE  #<NSCLEAR,R0
	JSR	<FSSKIP

	MOVE  #<NPUNDERSCAN,R0		; read underscan
	JSR   <PDATA
	JCS	<START

	MOVE	Y:<AFPXFER0,R0		; skip to ROI
	JSR	<CLOCK
	MOVE  #<NPSKIP,R0
	JSR   <PSKIP
	JCS	<START
	MOVE	Y:<AFPXFER2,R0
	JSR	<CLOCK
	MOVE  #<NSCLEAR,R0		
	JSR	<FSSKIP

	MOVE  #<NPDATA,R0			; read ROI
	JSR   <PDATA
	JCS	<START

	MOVE	Y:<AFPXFER0,R0		; skip to overscan
	JSR	<CLOCK
	MOVE  #<NPPOSTSKIP,R0
	JSR   <PSKIP
	JCS	<START
	MOVE	Y:<AFPXFER2,R0
	JSR	<CLOCK
	MOVE  #<NSCLEAR,R0
	JSR	<FSSKIP

	MOVE  #<NPOVERSCAN,R0		; read parallel overscan
	JSR   <PDATA
	JCS	<START

RDC_END	
	JCLR	#IDLMODE,X:<STATUS,NO_IDL	; Don't idle after readout
	MOVE	#IDLE,R0
	MOVE	R0,X:<IDL_ADR
	JMP	<RDC_E
NO_IDL
	MOVE	#<TST_RCV,R0
	MOVE	R0,X:<IDL_ADR
RDC_E
	JSR	<WAIT_TO_FINISH_CLOCKING
	BCLR	#ST_RDC,X:<STATUS		; Set status to not reading out

	JMP	<START			; DONE flag set by PCI when finished

; *******************************************************************
PDATA
	JSR	<CNPAMPS		; compensate for split register
	JLE	<PDATA0
	DO	A,PDATA0		; loop through # of binned rows into each serial register
	MOVE	#<NPBIN,R0		; shift NPBIN rows into serial register
	JSR	<PDSKIP
	JCC	<PDATA1
	ENDDO
	JMP	<PDATA0
PDATA1
	MOVE	#<NSPRESKIP,R0	; skip to serial underscan
	JSR	<SSKIP
	MOVE	#<NSUNDERSCAN,R0	; read underscan
	JSR	<SDATA
	MOVE	#<NSSKIP,R0		; skip to ROI
	JSR	<SSKIP
	MOVE	#<NSDATA,R0		; read ROI
	JSR	<SDATA
	MOVE	#<NSPOSTSKIP,R0	; skip to serial overscan
	JSR	<SSKIP
	MOVE	#<NSOVERSCAN,R0	; read overscan 
	JSR	<SDATA
	BCLR	#0,SR			; set CC
	NOP
	NOP
	NOP
PDATA0
	RTS

; *******************************************************************
PDSKIP
	MOVE	Y:(R0),A		; shift data lines into serial reg
	TST	A
	JLE	<PDSKIP0
	DO	Y:(R0),PDSKIP0
	MOVE	Y:<APDXFER,R0
	JSR	<PCLOCK
	JSR	<GET_RCV
	JCC	<PDSKIP1
	ENDDO
	NOP
PDSKIP1
	NOP
PDSKIP0
	RTS

; *******************************************************************
PSKIP
	JSR	<CNPAMPS
	JLE	<PSKIP0
	DO	A,PSKIP0
	MOVE	Y:<APXFER,R0
	JSR	<PCLOCK
	JSR	<GET_RCV
	JCC	<PSKIP1
	ENDDO
	NOP
PSKIP1
	NOP
PSKIP0
	RTS

; *******************************************************************
PQSKIP
	JSR	<CNPAMPS
	JLE	<PQSKIP0
	DO	A,PQSKIP0
	MOVE	Y:<APQXFER,R0
	JSR	<PCLOCK
	JSR	<GET_RCV
	JCC	<PQSKIP1
	ENDDO
	NOP
PQSKIP1
	NOP
PQSKIP0
	RTS

; *******************************************************************
RSKIP
	JSR	<CNPAMPS
	JLE	<RSKIP0
	DO	A,RSKIP0
	MOVE	Y:<ARXFER,R0
	JSR	<PCLOCK
	JSR	<GET_RCV
	JCC	<RSKIP1
	ENDDO
	NOP
RSKIP1
	NOP
RSKIP0
	RTS

; *******************************************************************
FSSKIP
	JSR	<CNSAMPS
	JLE	<FSSKIP0
	DO	A,FSSKIP0
	MOVE	Y:<AFSXFER,R0
	JSR	<CLOCK
	NOP
FSSKIP0
	RTS

; *******************************************************************
SSKIP
	JSR	<CNSAMPS
	JLE	<SSKIP0
	DO	A,SSKIP0
	MOVE	Y:<ASXFER0,R0
	JSR	<CLOCK
	MOVE	Y:<ASXFER2,R0
	JSR	<CLOCK
	NOP
SSKIP0
	RTS

; *******************************************************************
SDATA
	JSR	<CNSAMPS
	JLE	<SDATA0
	DO	A,SDATA0
	MOVE	Y:<ASXFER0,R0
	JSR	<CLOCK
	MOVE	X:<ONE,X0				; Get bin-1
	MOVE	Y:<NSBIN,A
	SUB	X0,A
	JLE	<SDATA1
	DO	A,SDATA1
	MOVE	Y:<ASXFER1,R0
	JSR	<CLOCK
	NOP
SDATA1
	MOVE	Y:<ASXFER2D,R0
	JSR	<CLOCK
SDATA0T
	NOP
SDATA0
	RTS

; *******************************************************************
; Compensate count for split serial
CNSAMPS	MOVE	Y:(R0),A		; get num pixels to read
	JCLR	#0,Y:<NSAMPS,CNSAMP1	; split register?
	ASR	A				; yes, divide by 2
CNSAMP1	TST	A
	RTS

; *******************************************************************
; Compensate count for split parallel
CNPAMPS	MOVE	Y:(R0),A		; get num rows to shift
	JCLR	#0,Y:<NPAMPS,CNPAMP1	; split parallels?
	ASR	A				; yes, divide by 2
CNPAMP1	TST	A				
	NOP					; MPL for Gen3
	NOP					; MPL for Gen3
	BCLR	#0,SR				; clear carry
	NOP					; MPL for Gen3
	RTS

; *******************************************************************
; slow clock for parallel shifts - Gen3 version
PCLOCK
	JCLR	#SSFHF,X:HDR,*		; Only write to FIFO if < half full
	NOP
	JCLR	#SSFHF,X:HDR,PCLOCK	; Guard against metastability
	MOVE    Y:(R0)+,X0      	; # of waveform entries 
	DO      X0,PCLK1			; Repeat X0 times
	MOVE	Y:(R0)+,A			; get waveform
	DO	Y:<PMULT,PCLK2
	MOVEP	A,Y:WRSS			; 30 nsec write the waveform to the SS 	
PCLK2	NOP
PCLK1 NOP
	RTS                     	; Return from subroutine

; *******************************************************************
CLEAR	JSR	<CLR_CCD			; clear CCD, executed as a command
	JMP     <FINISH

; *******************************************************************
CLR_CCD
	MOVE	Y:<AFPXFER0,R0		; prep for fast flush
	JSR	<CLOCK
	MOVE    #<NPCLEAR,R0		; shift all rows
	JSR     <PQSKIP			
	MOVE	Y:<AFPXFER2,R0		; set clocks on clear exit
	JSR	<CLOCK
	MOVE    #<NSCLEAR,R0		; flush serial register
	JSR	<FSSKIP
	RTS

; *******************************************************************
FOR_PSHIFT
	MOVE	#<NPXSHIFT,R0		; forward shift rows
	JSR	<PSKIP
	JMP	<FINISH

; *******************************************************************
REV_PSHIFT
	MOVE	#<NPXSHIFT,R0		; reverse shift rows
	JSR	<RSKIP
	JMP	<FINISH

; *******************************************************************
; Set software to IDLE mode
START_IDLE_CLOCKING
	MOVE	#IDLE,R0			; Exercise clocks when idling
	MOVE	R0,X:<IDL_ADR
	BSET	#IDLMODE,X:<STATUS	; Idle after readout
	JMP     <FINISH			; Need to send header and 'DON'

; Keep the CCD idling when not reading out - MPL modified for AzCam
IDLE	DO      Y:<NSCLEAR,IDL1	; Loop over number of pixels per line
	MOVE    Y:<AFSXFER,R0 	; Serial transfer on pixel
	JSR     <CLOCK  		; Go to it
	MOVE	#COM_BUF,R3
	JSR	<GET_RCV		; Check for FO or SSI commands
	JCC	<NO_COM			; Continue IDLE if no commands received
	ENDDO
	JMP     <PRC_RCV		; Go process header and command
NO_COM	NOP
IDL1
	MOVE    Y:<APQXFER,R0	; Address of parallel clocking waveform
	JSR     <CLOCK  		; Go clock out the CCD charge
;	JSR     <PCLOCK  		; Go clock out the CCD charge
	JMP     <IDLE
