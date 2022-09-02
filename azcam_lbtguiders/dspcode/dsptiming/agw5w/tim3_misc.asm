; Miscellaneous control routines
; This is the GEN3 AzCam version developed first for 90Prime
; Requires a call to CLR before calling SEX.
; last change 20Aug04 by Michael Lesser

; Routines contained in this file are:

; POWER_OFF
; POWER_ON
; SET_BIASES
; CLR_SWS
; CLEAR_SWITCHES_AND_DACS
; OPEN_SHUTTER
; CLOSE_SHUTTER
; OSHUT
; CSHUT
; EXPOSE
; START_EXPOSURE
; SET_EXPOSURE_TIME
; READ_EXPOSURE_TIME
; PAUSE_EXPOSURE
; RESUME_EXPOSURE
; ABORT_ALL
; SYNTHETIC_IMAGE
; XMT_PIX
; READ_AD
; PCI_READ_IMAGE
; WAIT_TO_FINISH_CLOCKING
; CLOCK
; PAL_DLY
; TEST_XMIT
; READ_CONTROLLER_CONFIGURATION
; ST_GAIN
; SET_DC
; SET_BIAS_NUMBER
; 

; *******************************************************************
POWER_OFF
	JSR	<CLEAR_SWITCHES_AND_DACS	; Clear switches and DACs
	BSET	#LVEN,X:HDR 
	BSET	#HVEN,X:HDR 
	JMP	<FINISH

; *******************************************************************
; Execute the power-on cycle, as a command
POWER_ON
	JSR	<CLEAR_SWITCHES_AND_DACS	; Clear switches and DACs

; Turn on the low voltages (+/- 6.5V, +/- 16.5V) and delay
	BCLR	#LVEN,X:HDR		; Set these signals to DSP outputs 
	MOVE	#2000000,X0
	DO      X0,*+3			; Wait 20 millisec for settling
	NOP 	

; Turn on the high +36 volt power line and delay
	BCLR	#HVEN,X:HDR		; HVEN = Low => Turn on +36V
	MOVE	#2000000,X0
	DO      X0,*+3			; Wait 20 millisec for settling
	NOP

	JCLR	#PWROK,X:HDR,PWR_ERR	; Test if the power turned on properly
	JSR	<SET_BIASES		; Turn on the DC bias supplies
	MOVE	#IDLE,R0		; Put controller in IDLE state
	MOVE	R0,X:<IDL_ADR
	JMP	<FINISH

; The power failed to turn on because of an error on the power control board
PWR_ERR	BSET	#LVEN,X:HDR		; Turn off the low voltage emable line
	BSET	#HVEN,X:HDR		; Turn off the high voltage emable line
	JMP	<ERROR

; *******************************************************************
SET_BIAS_VOLTAGES
	JSR	<SET_BIASES
	JMP	<FINISH

; Set all the DC bias voltages and video processor offset values, reading
;   them from the 'DACS' table
SET_BIASES
	BSET	#3,X:PCRD		; Turn on the serial clock
	BCLR	#1,X:<LATCH		; Separate updates of clock driver
	BSET	#CDAC,X:<LATCH		; Disable clearing of DACs
	BSET	#ENCK,X:<LATCH		; Enable clock and DAC output switches
	MOVEP	X:LATCH,Y:WRLATCH	; Write it to the hardware
	JSR	<PAL_DLY		; Delay for all this to happen

; Read DAC values from a table, and write them to the DACs
;	MOVE	#DACS,R0		; Get starting address of DAC values
	MOVE	Y:<ADACS,R0		; MPL
	NOP
	NOP
	NOP
	DO      Y:(R0)+,L_DAC		; Repeat Y:(R0)+ times
	MOVE	Y:(R0)+,A		; Read the table entry
	JSR	<XMIT_A_WORD		; Transmit it to TIM-A-STD
	NOP
L_DAC

; Let the DAC voltages all ramp up before exiting
	MOVE	#400000,X0
	DO	X0,*+3			; 4 millisec delay
	NOP
	BCLR	#3,X:PCRD		; Turn the serial clock off
	RTS

; *******************************************************************
CLR_SWS	JSR	<CLEAR_SWITCHES_AND_DACS	; Clear switches and DACs
	JMP	<FINISH

CLEAR_SWITCHES_AND_DACS
	BCLR	#CDAC,X:<LATCH		; Clear all the DACs
	BCLR	#ENCK,X:<LATCH		; Disable all the output switches
	MOVEP	X:LATCH,Y:WRLATCH	; Write it to the hardware
	BSET	#3,X:PCRD	; Turn the serial clock on
	MOVE	#$0C3000,A	; Value of integrate speed and gain switches
	CLR	B
	MOVE	#$100000,X0	; Increment over board numbers for DAC writes
	MOVE	#$001000,X1	; Increment over board numbers for WRSS writes
	DO	#15,L_VIDEO	; Fifteen video processor boards maximum
	JSR	<XMIT_A_WORD	; Transmit A to TIM-A-STD
	ADD	X0,A
	MOVE	B,Y:WRSS
	JSR	<PAL_DLY	; Delay for the serial data transmission
	ADD	X1,B
L_VIDEO	
	BCLR	#3,X:PCRD		; Turn the serial clock off
	RTS

; *******************************************************************
; Open the shutter by setting the backplane bit TIM-LATCH0
OSHUT	BSET  #ST_SHUT,X:<STATUS 	; Set status bit to mean shutter open
	BCLR	#SHUTTER,X:<LATCH	; Clear hardware shutter bit to open
	MOVEP	X:LATCH,Y:WRLATCH	; Write it to the hardware
      RTS

; *******************************************************************
; Close the shutter by clearing the backplane bit TIM-LATCH0
CSHUT	BCLR  #ST_SHUT,X:<STATUS 	; Clear status to mean shutter closed
	BSET	#SHUTTER,X:<LATCH	; Set hardware shutter bit to close
	MOVEP	X:LATCH,Y:WRLATCH	; Write it to the hardware
      RTS

; *******************************************************************
; Open the shutter from the timing board, executed as a command
OPEN_SHUTTER
	JSR	<OSHUT
	JMP	<FINISH

; *******************************************************************
; Close the shutter from the timing board, executed as a command
CLOSE_SHUTTER
	JSR	<CSHUT
	JMP	<FINISH

; *******************************************************************
; Start the exposure timer and monitor its progress
EXPOSE	MOVE	X:<EXPOSURE_TIME,B
	TST	B			; Special test for zero exposure time
	JEQ	<END_EXP		; Don't even start an exposure
	SUB	#1,B			; Timer counts from X:TCPR0+1 to zero
	BSET	#TIM_BIT,X:TCSR0	; Enable the timer #0
	MOVE	B,X:TCPR0
CHK_RCV	MOVE	#COM_BUF,R3	; The beginning of the command buffer
	JCLR    #EF,X:HDR,EXP1	; Simple test for fast execution
	JSR	<GET_RCV		; Check for an incoming command
	JCS	<PRC_RCV		; If command is received, go check it
EXP1	JCLR	#ST_DITH,X:STATUS,CHK_TIM
	MOVE	Y:<AFSXFER,R0
	JSR	<CLOCK
CHK_TIM	JCLR	#TCF,X:TCSR0,CHK_RCV	; Wait for timer to equal compare value
END_EXP	BCLR	#TIM_BIT,X:TCSR0	; Disable the timer
	JMP	(R7)			; This contains the return address

; *******************************************************************
; Start the exposure, operate the shutter, and initiate CCD readout
START_EXPOSURE
	MOVE	#$020102,B
	JSR	<XMT_WRD
	MOVE	#'IIA',B			; responds to host with DON
	JSR	<XMT_WRD			;  indicating exposure started

	MOVE	#<TST_RCV,R0		; Process commands, don't idle, 
	MOVE	R0,X:<IDL_ADR		;  during the exposure
	JCLR	#SHUT,X:STATUS,L_SEX0
	JSR	<OSHUT			; Open the shutter if needed
L_SEX0	MOVE	#L_SEX1,R7		; Return address at end of exposure
	JMP	<EXPOSE			; Delay for specified exposure time
L_SEX1
	JCLR	#SHUT,X:STATUS,S_DEL0
	JSR	<CSHUT			; Close the shutter if necessary

; shutter delay
	MOVE	Y:<SH_DEL,A
	TST	A
	JLE	<S_DEL0
	MOVE	X:<C100K,X0			; assume 100 MHz DSP             
	DO	A,S_DEL0			; Delay by Y:SH_DEL milliseconds
	DO	X0,S_DEL1
	NOP
S_DEL1	NOP
S_DEL0	NOP

	JMP	<START			; 

; *******************************************************************
; Set the desired exposure time
SET_EXPOSURE_TIME
	MOVE	X:(R3)+,Y0
	MOVE	Y0,X:EXPOSURE_TIME
	MOVEP	X:EXPOSURE_TIME,X:TCPR0
	JMP	<FINISH

; *******************************************************************
; Read the time remaining until the exposure ends
READ_EXPOSURE_TIME
	MOVE	X:TCR0,Y1		; Read elapsed exposure time
	JMP	<FINISH1

; *******************************************************************
; Pause the exposure - close the shutter, and stop the timer
PAUSE_EXPOSURE
	BCLR    #TIM_BIT,X:TCSR0	; Disable the DSP exposure timer
	JSR	<CSHUT			; Close the shutter
	JMP	<FINISH

; *******************************************************************
; Resume the exposure - open the shutter if needed and restart the timer
RESUME_EXPOSURE
	BSET	#TIM_BIT,X:TCSR0	; Re-enable the DSP exposure timer
	JCLR	#SHUT,X:STATUS,L_RES
	JSR	<OSHUT			; Open the shutter ir necessary
L_RES	JMP	<FINISH

; *******************************************************************
; Special ending after abort command to send a 'DON' to the host computer
ABORT_ALL
	BCLR    #TIM_BIT,X:TCSR0	; Disable the DSP exposure timer
	JSR	<CSHUT			; Close the shutter
	MOVE	#100000,X0
	DO	X0,L_WAIT0		; Wait one millisecond to delimit
	NOP				;   image data and the 'DON' reply
L_WAIT0
	JCLR	#IDLMODE,X:<STATUS,NO_IDL2 ; Don't idle after readout
	MOVE	#IDLE,R0
	MOVE	R0,X:<IDL_ADR
	JMP	<RDC_E2
NO_IDL2	MOVE	#<TST_RCV,R0
	MOVE	R0,X:<IDL_ADR
RDC_E2	JSR	<WAIT_TO_FINISH_CLOCKING
	BCLR	#ST_RDC,X:<STATUS	; Set status to not reading out

	MOVE	#$000202,X0		; Send 'DON' to the host computer
	MOVE	X0,X:<HEADER
	JMP	<FINISH

; *******************************************************************
; Generate a synthetic image by simply incrementing the pixel counts
SYNTHETIC_IMAGE
	CLR	A
;	DO      Y:<NPR,LPR_TST      	; Loop over each line readout
;	DO      Y:<NSR,LSR_TST		; Loop over number of pixels per line
	DO      Y:<NPIMAGE,LPR_TST      	; Loop over each line readout
	DO      Y:<NSIMAGE,LSR_TST		; Loop over number of pixels per line
	REP	#20			; #20 => 1.0 microsec per pixel
	NOP
	ADD	#1,A			; Pixel data = Pixel data + 1
	NOP
	MOVE	A,B
	JSR	<XMT_PIX		;  transmit them
	NOP
LSR_TST	
	NOP
LPR_TST	
        JMP     <RDC_END		; Normal exit

; *******************************************************************
; Transmit the 16-bit pixel datum in B1 to the host computer
XMT_PIX	ASL	#16,B,B
	NOP
	MOVE	B2,X1
	ASL	#8,B,B
	NOP
	MOVE	B2,X0
	NOP
	MOVEP	X1,Y:WRFO
	MOVEP	X0,Y:WRFO
	RTS

; *******************************************************************
; Test the hardware to read A/D values directly into the DSP instead
;   of using the SXMIT option, A/Ds #2 and 3.
READ_AD	MOVE	X:(RDAD+2),B
	ASL	#16,B,B
	NOP
	MOVE	B2,X1
	ASL	#8,B,B
	NOP
	MOVE	B2,X0
	NOP
	MOVEP	X1,Y:WRFO
	MOVEP	X0,Y:WRFO
	REP	#10
	NOP
	MOVE	X:(RDAD+3),B
	ASL	#16,B,B
	NOP
	MOVE	B2,X1
	ASL	#8,B,B
	NOP
	MOVE	B2,X0
	NOP
	MOVEP	X1,Y:WRFO
	MOVEP	X0,Y:WRFO
	REP	#10
	NOP
	RTS

; *******************************************************************
; Alert the PCI interface board that images are coming soon
PCI_READ_IMAGE
	MOVE	#$020104,B		; Send header word to the FO transmitter
	JSR	<XMT_WRD
	MOVE	#'RDA',B
	JSR	<XMT_WRD
;	MOVE	Y:NSR,B			; Number of columns to read
	MOVE	Y:NSIMAGE,B			; Number of columns to read
	JSR	<XMT_WRD
;	MOVE	Y:NPR,B			; Number of rows to read		
	MOVE	Y:NPIMAGE,B			; Number of columns to read
	JSR	<XMT_WRD
	RTS

; *******************************************************************
; Wait for the clocking to be complete before proceeding
WAIT_TO_FINISH_CLOCKING
	JSET	#SSFEF,X:PDRD,*		; Wait for the SS FIFO to be empty	
	RTS

; *******************************************************************
; This MOVEP instruction executes in 30 nanosec, 20 nanosec for the MOVEP,
;   and 10 nanosec for the wait state that is required for SRAM writes and 
;   FIFO setup times. It looks reliable, so will be used for now.

; Core subroutine for clocking out CCD charge
CLOCK
	JCLR	#SSFHF,X:HDR,*		; Only write to FIFO if < half full
	NOP
	JCLR	#SSFHF,X:HDR,CLOCK	; Guard against metastability
	MOVE    Y:(R0)+,X0      	; # of waveform entries 
	DO      X0,CLK1                 ; Repeat X0 times
	MOVEP	Y:(R0)+,Y:WRSS		; 30 nsec Write the waveform to the SS 	
CLK1
	NOP
	RTS                     	; Return from subroutine

; *******************************************************************
; Work on later !!!
; This will execute in 20 nanosec, 10 nanosec for the MOVE and 10 nanosec 
;   the one wait state that is required for SRAM writes and FIFO setup times. 
;   However, the assembler gives a WARNING about pipeline problems if its
;   put in a DO loop. This problem needs to be resolved later, and in the
;   meantime I'll be using the MOVEP instruction. 

;	MOVE	#$FFFF03,R6		; Write switch states, X:(R6)
;	MOVE	Y:(R0)+,A  A,X:(R6)

; Delay for serial writes to the PALs and DACs by 8 microsec
PAL_DLY	DO	#800,DLY	 ; Wait 8 usec for serial data transmission
	NOP
DLY	NOP
	RTS

; *******************************************************************
; Test the analog serial word transmitter
TEST_XMIT
	MOVE	X:(R3)+,A
	JSR	<XMIT_A_WORD
	JMP	<FINISH

; *******************************************************************
; Let the host computer read the controller configuration
READ_CONTROLLER_CONFIGURATION
	MOVE	Y:<CONFIG,Y1		; Just transmit the configuration
	JMP	<FINISH1

; *******************************************************************
; Set the video processor gain and integrator speed for all video boards
;  Command syntax is  SGN  #GAIN #SPEED,	#GAIN = 1, 2, 5 or 10	
;							#SPEED = 0 for slow, 1 for fast
ST_GAIN	BSET	#3,X:PCRD	; Turn the serial clock on
	MOVE	X:(R3)+,A	; Gain value (1,2,5 or 10)
	MOVE	#>1,X0
	CMP	X0,A		; Check for gain = x1
	JNE	<STG2
	MOVE	#>$77,B
	JMP	<STG_A
STG2	MOVE	#>2,X0		; Check for gain = x2
	CMP	X0,A
	JNE	<STG5
	MOVE	#>$BB,B
	JMP	<STG_A
STG5	MOVE	#>5,X0		; Check for gain = x5
	CMP	X0,A
	JNE	<STG10
	MOVE	#>$DD,B
	JMP	<STG_A
STG10	MOVE	#>10,X0		; Check for gain = x10
	CMP	X0,A
	JNE	<ERROR
	MOVE	#>$EE,B

STG_A	MOVE	X:(R3)+,A	; Integrator Speed (0 for slow, 1 for fast)
	NOP
	JCLR	#0,A1,STG_B
	BSET	#8,B1
	NOP
	BSET	#9,B1
STG_B	MOVE	#$0C3C00,X0
	OR	X0,B
	NOP
	MOVE	B,Y:<GAIN	; Store the GAIN value for later use

; Send this same value to 15 video processor boards whether they exist or not
	MOVE	#$100000,X0	; Increment value
	MOVE	B,A
	DO	#15,STG_LOOP
	JSR	<XMIT_A_WORD	; Transmit A to TIM-A-STD
	JSR	<PAL_DLY	; Wait for SSI and PAL to be empty
	ADD	X0,B		; Increment the video processor board number
STG_LOOP
	BCLR	#3,X:PCRD	; Turn the serial clock off
	JMP	<FINISH
ERR_SGN	MOVE	X:(R3)+,A
	JMP	<ERROR

; *******************************************************************
; Set the video processor boards in DC-coupled diagnostic mode or not
; Command syntax is  SDC #	# = 0 for normal operation
;				# = 1 for DC coupled diagnostic mode
SET_DC	BSET	#3,X:PCRD	; Turn the serial clock on
	MOVE	X:(R3)+,X0
	JSET	#0,X0,SDC_1
	BCLR	#10,Y:<GAIN
	BCLR	#11,Y:<GAIN
	JMP	<SDC_A
SDC_1	BSET	#10,Y:<GAIN
	BSET	#11,Y:<GAIN
SDC_A	MOVE	#$100000,X0	; Increment value
	DO	#15,SDC_LOOP
	MOVE	Y:<GAIN,A
	JSR	<XMIT_A_WORD	; Transmit A to TIM-A-STD
	JSR	<PAL_DLY	; Wait for SSI and PAL to be empty
	ADD	X0,B		; Increment the video processor board number
SDC_LOOP
	BCLR	#3,X:PCRD	; Turn the serial clock off
	JMP	<FINISH

; *******************************************************************
; Set a particular DAC numbers, for setting DC bias voltages, clock driver  
;   voltages and video processor offset
;
; SBN  #BOARD  #DAC  ['CLK' or 'VID']  voltage
;
;				#BOARD is from 0 to 15
;				#DAC number
;				#voltage is from 0 to 4095

SET_BIAS_NUMBER			; Set bias number
	BSET	#3,X:PCRD	; Turn on the serial clock
	MOVE	X:(R3)+,A	; First argument is board number, 0 to 15
	REP	#20
	LSL	A
	NOP
	MOVE	A,X0
	MOVE	X:(R3)+,A	; Second argument is DAC number
	REP	#14
	LSL	A
	OR	X0,A
	MOVE	X:(R3)+,B	; Third argument is 'VID' or 'CLK' string
	MOVE	#'VID',X0
	CMP	X0,B
	JNE	<CLK_DRV
	BSET	#19,A1		; Set bits to mean video processor DAC
	NOP
	BSET	#18,A1
	JMP	<VID_BRD
CLK_DRV	MOVE	#'CLK',X0
	CMP	X0,B
	JNE	<ERR_SBN
VID_BRD	MOVE	A,X0
	MOVE	X:(R3)+,A	; Fourth argument is voltage value, 0 to $fff
	MOVE	#$000FFF,Y0	; Mask off just 12 bits to be sure
	AND	Y0,A
	OR	X0,A
	JSR	<XMIT_A_WORD	; Transmit A to TIM-A-STD
	JSR	<PAL_DLY	; Wait for the number to be sent
	BCLR	#3,X:PCRD	; Turn the serial clock off
	JMP	<FINISH
ERR_SBN	MOVE	X:(R3)+,A	; Read and discard the fourth argument
	BCLR	#3,X:PCRD	; Turn the serial clock off
	JMP	<ERROR

; Specify the MUX value to be output on the clock driver board
; Command syntax is  SMX  #clock_driver_board #MUX1 #MUX2
;				#clock_driver_board from 0 to 15
;				#MUX1, #MUX2 from 0 to 23
SET_MUX	BSET	#3,X:PCRD	; Turn on the serial clock
	MOVE	X:(R3)+,A	; Clock driver board number
	REP	#20
	LSL	A
	MOVE	#$003000,X0
	OR	X0,A
	NOP
	MOVE	A,X1		; Move here for storage

; Get the first MUX number
	MOVE	X:(R3)+,A	; Get the first MUX number
	JLT	ERR_SM1
	MOVE	#>24,X0		; Check for argument less than 32
	CMP	X0,A
	JGE	ERR_SM1
	MOVE	A,B
	MOVE	#>7,X0
	AND	X0,B
	MOVE	#>$18,X0
	AND	X0,A
	JNE	<SMX_1		; Test for 0 <= MUX number <= 7
	BSET	#3,B1
	JMP	<SMX_A
SMX_1	MOVE	#>$08,X0
	CMP	X0,A		; Test for 8 <= MUX number <= 15
	JNE	<SMX_2
	BSET	#4,B1
	JMP	<SMX_A
SMX_2	MOVE	#>$10,X0
	CMP	X0,A		; Test for 16 <= MUX number <= 23
	JNE	<ERR_SM1
	BSET	#5,B1
SMX_A	OR	X1,B1		; Add prefix to MUX numbers
	NOP
	MOVE	B1,Y1

; Add on the second MUX number
	MOVE	X:(R3)+,A	; Get the next MUX number
	JLT	<ERROR
	MOVE	#>24,X0		; Check for argument less than 32
	CMP	X0,A
	JGE	<ERROR
	REP	#6
	LSL	A
	NOP
	MOVE	A,B
	MOVE	#$1C0,X0
	AND	X0,B
	MOVE	#>$600,X0
	AND	X0,A
	JNE	<SMX_3		; Test for 0 <= MUX number <= 7
	BSET	#9,B1
	JMP	<SMX_B
SMX_3	MOVE	#>$200,X0
	CMP	X0,A		; Test for 8 <= MUX number <= 15
	JNE	<SMX_4
	BSET	#10,B1
	JMP	<SMX_B
SMX_4	MOVE	#>$400,X0
	CMP	X0,A		; Test for 16 <= MUX number <= 23
	JNE	<ERROR
	BSET	#11,B1
SMX_B	ADD	Y1,B		; Add prefix to MUX numbers
	NOP
	MOVE	B1,A
	JSR	<XMIT_A_WORD	; Transmit A to TIM-A-STD
	JSR	<PAL_DLY	; Delay for all this to happen
	BCLR	#3,X:PCRD	; Turn the serial clock off
	JMP	<FINISH
ERR_SM1	MOVE	X:(R3)+,A
	BCLR	#3,X:PCRD	; Turn the serial clock off
	JMP	<ERROR
