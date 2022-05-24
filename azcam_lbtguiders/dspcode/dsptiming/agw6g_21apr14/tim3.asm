; tim3.asm

; This file is used to generate DSP code for the 250 MHz fiber optic
; timing board using a DSP56303 as its main processor.
; This is the AzCam version based on ARC Gen3 code.
; 20Aug03 last change by Michael Lesser

	PAGE    132     ; Printronix page width - 132 columns

; *** include heade and boot files so addressing is easy ***
	INCLUDE	"tim3_hdr.asm"
	INCLUDE	"tim3_boot.asm"

	ORG	P:,P:

CC	EQU	CCDVIDREV3B+TIMREV5+SHUTTER_CC

; Put number of words of application in P: for loading application from EEPROM
	DC	TIMBOOT_X_MEMORY-@LCV(L)-1

; *** include readout routines ***
	INCLUDE "tim3_rdccd.asm"

; *** include misc routines ***
	INCLUDE "tim3_misc.asm"

TIMBOOT_X_MEMORY	EQU	@LCV(L)

;  ****************  Setup memory tables in X: space ********************

; Define the address in P: space where the table of constants begins

	IF	@SCP("DOWNLOAD","HOST")
	ORG     X:END_COMMAND_TABLE,X:END_COMMAND_TABLE
	ENDIF

	IF	@SCP("DOWNLOAD","ROM")
	ORG     X:END_COMMAND_TABLE,P:
	ENDIF

; Application commands
	DC	'PON',POWER_ON
	DC	'POF',POWER_OFF
	DC	'SBV',SET_BIAS_VOLTAGES
	DC	'IDL',START_IDLE_CLOCKING
	DC	'OSH',OPEN_SHUTTER
	DC	'CSH',CLOSE_SHUTTER
	DC	'RDC',RDCCD   
	DC	'CLR',CLEAR   

; Exposure and readout control routines
	DC	'SET',SET_EXPOSURE_TIME
	DC	'RET',READ_EXPOSURE_TIME
	DC	'SEX',START_EXPOSURE
	DC	'PEX',PAUSE_EXPOSURE
	DC	'REX',RESUME_EXPOSURE
	DC	'AEX',ABORT_ALL
	DC	'ABR',ABORT_ALL		; MPL temporary
	DC	'FPX',FOR_PSHIFT
	DC	'RPX',REV_PSHIFT
;	DC	'ABR',ABR_RDC			; MPL
;	DC	'CRD',CONT_RD			; MPL

; Support routines
	DC	'SGN',ST_GAIN
	DC	'SDC',SET_DC
	DC	'SBN',SET_BIAS_NUMBER
	DC	'SMX',SET_MUX
	DC	'CSW',CLR_SWS
	DC	'RCC',READ_CONTROLLER_CONFIGURATION

END_APPLICATON_COMMAND_TABLE	EQU	@LCV(L)

	IF	@SCP("DOWNLOAD","HOST")
NUM_COM	EQU	(@LCV(R)-COM_TBL_R)/2	; Number of boot + application commands
EXPOSING		EQU	CHK_TIM		; Address if exposing
;CONTINUE_READING	EQU	CONT_RD 		; Address if reading out
	ENDIF

	IF	@SCP("DOWNLOAD","ROM")
	ORG     Y:0,P:
	ENDIF

; Now let's go for the timing waveform tables
	IF	@SCP("DOWNLOAD","HOST")
 	ORG     Y:0,Y:0
	ENDIF

; *** include waveform table ***
	INCLUDE "waveforms.asm"

END_APPLICATON_Y_MEMORY	EQU	@LCV(L)

; End of program
	END

