Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3.asm  Page 1



1                          ; tim3.asm
2      
3                          ; This file is used to generate DSP code for the 250 MHz fiber optic
4                          ; timing board using a DSP56303 as its main processor.
5                          ; This is the AzCam version based on ARC Gen3 code.
6                          ; 20Aug03 last change by Michael Lesser
7      
8                                    PAGE    132                               ; Printronix page width - 132 columns
9      
10                         ; *** include heade and boot files so addressing is easy ***
11                                   INCLUDE "tim3_hdr.asm"
12                                COMMENT *
13     
14                         timhdr.asm for Gen3
15     
16                         This is a header file that is shared between the fiber optic timing board
17                         boot and application code files for Rev. 5 = 250 MHz timing boards
18     
19                         Utility board support version
20     
21                         Last change 20Aug04 MPL
22     
23                                 *
24     
25                                   PAGE    132                               ; Printronix page width - 132 columns
26     
27                         ; Various addressing control registers
28        FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
29        FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
30        FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
31        FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
32        FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
33        FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
34        FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
35        FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
36     
37                         ; Port E is the Synchronous Communications Interface (SCI) port
38        FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
39        FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
40        FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
41        FFFF9C           SCR       EQU     $FFFF9C                           ; SCI Control Register
42        FFFF9B           SCCR      EQU     $FFFF9B                           ; SCI Clock Control Register
43     
44        FFFF9A           SRXH      EQU     $FFFF9A                           ; SCI Receive Data Register, High byte
45        FFFF99           SRXM      EQU     $FFFF99                           ; SCI Receive Data Register, Middle byte
46        FFFF98           SRXL      EQU     $FFFF98                           ; SCI Receive Data Register, Low byte
47     
48        FFFF97           STXH      EQU     $FFFF97                           ; SCI Transmit Data register, High byte
49        FFFF96           STXM      EQU     $FFFF96                           ; SCI Transmit Data register, Middle byte
50        FFFF95           STXL      EQU     $FFFF95                           ; SCI Transmit Data register, Low byte
51     
52        FFFF94           STXA      EQU     $FFFF94                           ; SCI Transmit Address Register
53        FFFF93           SSR       EQU     $FFFF93                           ; SCI Status Register
54     
55        000009           SCITE     EQU     9                                 ; X:SCR bit set to enable the SCI transmitter
56        000008           SCIRE     EQU     8                                 ; X:SCR bit set to enable the SCI receiver
57        000000           TRNE      EQU     0                                 ; This is set in X:SSR when the transmitter
58                                                                             ;  shift and data registers are both empty
59        000001           TDRE      EQU     1                                 ; This is set in X:SSR when the transmitter
60                                                                             ;  data register is empty
61        000002           RDRF      EQU     2                                 ; X:SSR bit set when receiver register is full
62        00000F           SELSCI    EQU     15                                ; 1 for SCI to backplane, 0 to front connector
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_hdr.asm  Page 2



63     
64     
65                         ; ESSI Flags
66        000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
67        000007           RDF       EQU     7                                 ; Set when receiver is full of data
68        000010           TE        EQU     16                                ; Transmitter enable
69     
70                         ; Phase Locked Loop initialization
71        050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 2 = 100 MHz
72     
73                         ; Port B general purpose I/O
74        FFFFC4           HPCR      EQU     $FFFFC4                           ; Control register (bits 1-6 cleared for GPIO)
75        FFFFC9           HDR       EQU     $FFFFC9                           ; Data register
76        FFFFC8           HDDR      EQU     $FFFFC8                           ; Data Direction Register bits (=1 for output)
77     
78                         ; Port C is Enhanced Synchronous Serial Port 0 = ESSI0
79        FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
80        FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
81        FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
82        FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register #0
83        FFFFB8           RX0       EQU     $FFFFB8                           ; Receive data register
84        FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
85        FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
86        FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
87     
88                         ; Port D is Enhanced Synchronous Serial Port 1 = ESSI1
89        FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
90        FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
91        FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
92        FFFFAC           TX10      EQU     $FFFFAC                           ; Transmit Data Register 0
93        FFFFA7           SSISR1    EQU     $FFFFA7                           ; Status Register
94        FFFFA6           CRB1      EQU     $FFFFA6                           ; Control Register B
95        FFFFA5           CRA1      EQU     $FFFFA5                           ; Control Register A
96     
97                         ; Timer module addresses
98        FFFF8F           TCSR0     EQU     $FFFF8F                           ; Timer control and status register
99        FFFF8E           TLR0      EQU     $FFFF8E                           ; Timer load register = 0
100       FFFF8D           TCPR0     EQU     $FFFF8D                           ; Timer compare register = exposure time
101       FFFF8C           TCR0      EQU     $FFFF8C                           ; Timer count register = elapsed time
102       FFFF83           TPLR      EQU     $FFFF83                           ; Timer prescaler load register => milliseconds
103       FFFF82           TPCR      EQU     $FFFF82                           ; Timer prescaler count register
104       000000           TIM_BIT   EQU     0                                 ; Set to enable the timer
105       000009           TRM       EQU     9                                 ; Set to enable the timer preloading
106       000015           TCF       EQU     21                                ; Set when timer counter = compare register
107    
108                        ; Board specific addresses and constants
109       FFFFF1           RDFO      EQU     $FFFFF1                           ; Read incoming fiber optic data byte
110       FFFFF2           WRFO      EQU     $FFFFF2                           ; Write fiber optic data replies
111       FFFFF3           WRSS      EQU     $FFFFF3                           ; Write switch state
112       FFFFF5           WRLATCH   EQU     $FFFFF5                           ; Write to a latch
113       010000           RDAD      EQU     $010000                           ; Read A/D values into the DSP
114       000009           EF        EQU     9                                 ; Serial receiver empty flag
115    
116                        ; DSP port A bit equates
117       000000           PWROK     EQU     0                                 ; Power control board says power is OK
118       000001           LED1      EQU     1                                 ; Control one of two LEDs
119       000002           LVEN      EQU     2                                 ; Low voltage power enable
120       000003           HVEN      EQU     3                                 ; High voltage power enable
121       00000E           SSFHF     EQU     14                                ; Switch state FIFO half full flag
122    
123                        ; Port D equate
124       000001           SSFEF     EQU     1                                 ; Switch state FIFO empty flag
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_hdr.asm  Page 3



125    
126                        ; Other equates
127       000002           WRENA     EQU     2                                 ; Enable writing to the EEPROM
128    
129                        ; Latch U12 bit equates
130       000000           CDAC      EQU     0                                 ; Clear the analog board DACs
131       000002           ENCK      EQU     2                                 ; Enable the clock outputs
132       000004           SHUTTER   EQU     4                                 ; Control the shutter
133       000005           TIM_U_RST EQU     5                                 ; Reset the utility board
134    
135                        ; Software status bits, defined at X:<STATUS = X:0
136       000000           ST_RCV    EQU     0                                 ; Set to indicate word is from SCI = utility board
137       000002           IDLMODE   EQU     2                                 ; Set if need to idle after readout
138       000003           ST_SHUT   EQU     3                                 ; Set to indicate shutter is closed, clear for open
139       000004           ST_RDC    EQU     4                                 ; Set if executing 'RDC' command - reading out
140       000005           SPLIT_S   EQU     5                                 ; Set if split serial
141       000006           SPLIT_P   EQU     6                                 ; Set if split parallel
142       000007           MPP       EQU     7                                 ; Set if parallels are in MPP mode
143       000008           NOT_CLR   EQU     8                                 ; Set if not to clear CCD before exposure
144       00000A           TST_IMG   EQU     10                                ; Set if controller is to generate a test image
145       00000B           SHUT      EQU     11                                ; Set if opening shutter at beginning of exposure
146       00000C           ST_DITH   EQU     12                                ; Set if to dither during exposure
147       00000D           NOREAD    EQU     13                                ; Set if not to call RDCCD after expose MPL
148    
149                        ; Address for the table containing the incoming SCI words
150       000400           SCI_TABLE EQU     $400
151    
152    
153                        ; Specify controller configuration bits of the X:STATUS word
154                        ;   to describe the software capabilities of this application file
155                        ; The bit is set (=1) if the capability is supported by the controller
156    
157    
158                                COMMENT *
159    
160                        BIT #'s         FUNCTION
161                        2,1,0           Video Processor
162                                                000     CCD Rev. 3
163                                                001     CCD Gen I
164                                                010     IR Rev. 4
165                                                011     IR Coadder
166                                                100     CCD Rev. 5, Differential input
167                                                101     8x IR
168    
169                        4,3             Timing Board
170                                                00      Rev. 4, Gen II
171                                                01      Gen I
172                                                10      Rev. 5, Gen III, 250 MHz
173    
174                        6,5             Utility Board
175                                                00      No utility board
176                                                01      Utility Rev. 3
177    
178                        7               Shutter
179                                                0       No shutter support
180                                                1       Yes shutter support
181    
182                        9,8             Temperature readout
183                                                00      No temperature readout
184                                                01      Polynomial Diode calibration
185                                                10      Linear temperature sensor calibration
186    
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_hdr.asm  Page 4



187                        10              Subarray readout
188                                                0       Not supported
189                                                1       Yes supported
190    
191                        11              Binning
192                                                0       Not supported
193                                                1       Yes supported
194    
195                        12              Split-Serial readout
196                                                0       Not supported
197                                                1       Yes supported
198    
199                        13              Split-Parallel readout
200                                                0       Not supported
201                                                1       Yes supported
202    
203                        14              MPP = Inverted parallel clocks
204                                                0       Not supported
205                                                1       Yes supported
206    
207                        16,15           Clock Driver Board
208                                                00      Rev. 3
209                                                11      No clock driver board (Gen I)
210    
211                        19,18,17                Special implementations
212                                                000     Somewhere else
213                                                001     Mount Laguna Observatory
214                                                010     NGST Aladdin
215                                                xxx     Other
216                                *
217    
218                        CCDVIDREV3B
219       000000                     EQU     $000000                           ; CCD Video Processor Rev. 3
220       000001           VIDGENI   EQU     $000001                           ; CCD Video Processor Gen I
221       000002           IRREV4    EQU     $000002                           ; IR Video Processor Rev. 4
222       000003           COADDER   EQU     $000003                           ; IR Coadder
223       000004           CCDVIDREV5 EQU    $000004                           ; Differential input CCD video Rev. 5
224       000000           TIMREV4   EQU     $000000                           ; Timing Revision 4 = 50 MHz
225       000008           TIMGENI   EQU     $000008                           ; Timing Gen I = 40 MHz
226       000010           TIMREV5   EQU     $000010                           ; Timing Revision 5 = 250 MHz
227       000020           UTILREV3  EQU     $000020                           ; Utility Rev. 3 supported
228       000080           SHUTTER_CC EQU    $000080                           ; Shutter supported
229       000100           TEMP_POLY EQU     $000100                           ; Polynomial calibration
230                        TEMP_LINEAR
231       000200                     EQU     $000200                           ; Linear calibration
232       000400           SUBARRAY  EQU     $000400                           ; Subarray readout supported
233       000800           BINNING   EQU     $000800                           ; Binning supported
234                        SPLIT_SERIAL
235       001000                     EQU     $001000                           ; Split serial supported
236                        SPLIT_PARALLEL
237       002000                     EQU     $002000                           ; Split parallel supported
238       004000           MPP_CC    EQU     $004000                           ; Inverted clocks supported
239       018000           CLKDRVGENI EQU    $018000                           ; No clock driver board - Gen I
240       020000           MLO       EQU     $020000                           ; Set if Mount Laguna Observatory
241       040000           NGST      EQU     $040000                           ; NGST Aladdin implementation
242                                  INCLUDE "tim3_boot.asm"
243                               COMMENT *
244    
245                        This file is used to generate boot DSP code for the 250 MHz fiber optic
246                                timing board using a DSP56303 as its main processor.
247                        Added utility board support Dec. 2002
248                                *
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 5



249                                  PAGE    132                               ; Printronix page width - 132 columns
250    
251                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
252                                  IF      @SCP("HOST","ROM")
259                                  ENDIF
260    
261                                  IF      @SCP("HOST","HOST")
262       P:000000 P:000000                   ORG     P:0,P:0
263       P:000000 P:000000 0C018E            JMP     <INIT
264       P:000001 P:000001 000000            NOP
265                                           ENDIF
266    
267                                 ;  This ISR receives serial words a byte at a time over the asynchronous
268                                 ;    serial link (SCI) and squashes them into a single 24-bit word
269       P:000002 P:000002 602400  SCI_RCV   MOVE              R0,X:<SAVE_R0           ; Save R0
270       P:000003 P:000003 052139            MOVEC             SR,X:<SAVE_SR           ; Save Status Register
271       P:000004 P:000004 60A700            MOVE              X:<SCI_R0,R0            ; Restore R0 = pointer to SCI receive regist
er
272       P:000005 P:000005 542300            MOVE              A1,X:<SAVE_A1           ; Save A1
273       P:000006 P:000006 452200            MOVE              X1,X:<SAVE_X1           ; Save X1
274       P:000007 P:000007 54A600            MOVE              X:<SCI_A1,A1            ; Get SRX value of accumulator contents
275       P:000008 P:000008 45E000            MOVE              X:(R0),X1               ; Get the SCI byte
276       P:000009 P:000009 0AD041            BCLR    #1,R0                             ; Test for the address being $FFF6 = last by
te
277       P:00000A P:00000A 000000            NOP
278       P:00000B P:00000B 000000            NOP
279       P:00000C P:00000C 000000            NOP
280       P:00000D P:00000D 205862            OR      X1,A      (R0)+                   ; Add the byte into the 24-bit word
281       P:00000E P:00000E 0E0013            JCC     <MID_BYT                          ; Not the last byte => only restore register
s
282       P:00000F P:00000F 545C00  END_BYT   MOVE              A1,X:(R4)+              ; Put the 24-bit word into the SCI buffer
283       P:000010 P:000010 60F400            MOVE              #SRXL,R0                ; Re-establish first address of SCI interfac
e
                            FFFF98
284       P:000012 P:000012 2C0000            MOVE              #0,A1                   ; For zeroing out SCI_A1
285       P:000013 P:000013 602700  MID_BYT   MOVE              R0,X:<SCI_R0            ; Save the SCI receiver address
286       P:000014 P:000014 542600            MOVE              A1,X:<SCI_A1            ; Save A1 for next interrupt
287       P:000015 P:000015 05A139            MOVEC             X:<SAVE_SR,SR           ; Restore Status Register
288       P:000016 P:000016 54A300            MOVE              X:<SAVE_A1,A1           ; Restore A1
289       P:000017 P:000017 45A200            MOVE              X:<SAVE_X1,X1           ; Restore X1
290       P:000018 P:000018 60A400            MOVE              X:<SAVE_R0,R0           ; Restore R0
291       P:000019 P:000019 000004            RTI                                       ; Return from interrupt service
292    
293                                 ; Clear error condition and interrupt on SCI receiver
294       P:00001A P:00001A 077013  CLR_ERR   MOVEP             X:SSR,X:RCV_ERR         ; Read SCI status register
                            000025
295       P:00001C P:00001C 077018            MOVEP             X:SRXL,X:RCV_ERR        ; This clears any error
                            000025
296       P:00001E P:00001E 000004            RTI
297    
298       P:00001F P:00001F                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
299       P:000030 P:000030                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
300       P:000040 P:000040                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
301    
302                                 ; Tune the table so the following instruction is at P:$50 exactly.
303       P:000050 P:000050 0D0002            JSR     SCI_RCV                           ; SCI receive data interrupt
304       P:000051 P:000051 000000            NOP
305       P:000052 P:000052 0D001A            JSR     CLR_ERR                           ; SCI receive error interrupt
306       P:000053 P:000053 000000            NOP
307    
308                                 ; *******************  Command Processing  ******************
309    
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 6



310                                 ; Read the header and check it for self-consistency
311       P:000054 P:000054 609F00  START     MOVE              X:<IDL_ADR,R0
312       P:000055 P:000055 018FA0            JSET    #TIM_BIT,X:TCSR0,CHK_TIM          ; MPL If exposing go check the timer
                            000379
313                                 ;       JSET    #ST_RDC,X:<STATUS,CONTINUE_READING
314       P:000057 P:000057 0AE080            JMP     (R0)
315    
316       P:000058 P:000058 330700  TST_RCV   MOVE              #<COM_BUF,R3
317       P:000059 P:000059 0D00A3            JSR     <GET_RCV
318       P:00005A P:00005A 0E0059            JCC     *-1
319    
320                                 ; Check the header and read all the remaining words in the command
321       P:00005B P:00005B 0C00FD  PRC_RCV   JMP     <CHK_HDR                          ; Update HEADER and NWORDS
322       P:00005C P:00005C 578600  PR_RCV    MOVE              X:<NWORDS,B             ; Read this many words total in the command
323       P:00005D P:00005D 000000            NOP
324       P:00005E P:00005E 01418C            SUB     #1,B                              ; We've already read the header
325       P:00005F P:00005F 000000            NOP
326       P:000060 P:000060 06CF00            DO      B,RD_COM
                            000068
327       P:000062 P:000062 205B00            MOVE              (R3)+                   ; Increment past what's been read already
328       P:000063 P:000063 0B0080  GET_WRD   JSCLR   #ST_RCV,X:STATUS,CHK_FO
                            0000A7
329       P:000065 P:000065 0B00A0            JSSET   #ST_RCV,X:STATUS,CHK_SCI
                            0000D3
330       P:000067 P:000067 0E0063            JCC     <GET_WRD
331       P:000068 P:000068 000000            NOP
332       P:000069 P:000069 330700  RD_COM    MOVE              #<COM_BUF,R3            ; Restore R3 = beginning of the command
333    
334                                 ; Is this command for the timing board?
335       P:00006A P:00006A 448500            MOVE              X:<HEADER,X0
336       P:00006B P:00006B 579B00            MOVE              X:<DMASK,B
337       P:00006C P:00006C 459A4E            AND     X0,B      X:<TIM_DRB,X1           ; Extract destination byte
338       P:00006D P:00006D 20006D            CMP     X1,B                              ; Does header = timing board number?
339       P:00006E P:00006E 0EA07E            JEQ     <COMMAND                          ; Yes, process it here
340       P:00006F P:00006F 0E909B            JLT     <FO_XMT                           ; Send it to fiber optic transmitter
341    
342                                 ; Transmit the command to the utility board over the SCI port
343       P:000070 P:000070 060600            DO      X:<NWORDS,DON_XMT                 ; Transmit NWORDS
                            00007C
344       P:000072 P:000072 60F400            MOVE              #STXL,R0                ; SCI first byte address
                            FFFF95
345       P:000074 P:000074 44DB00            MOVE              X:(R3)+,X0              ; Get the 24-bit word to transmit
346       P:000075 P:000075 060380            DO      #3,SCI_SPT
                            00007B
347       P:000077 P:000077 019381            JCLR    #TDRE,X:SSR,*                     ; Continue ONLY if SCI XMT is empty
                            000077
348       P:000079 P:000079 445800            MOVE              X0,X:(R0)+              ; Write to SCI, byte pointer + 1
349       P:00007A P:00007A 000000            NOP                                       ; Delay for the status flag to be set
350       P:00007B P:00007B 000000            NOP
351                                 SCI_SPT
352       P:00007C P:00007C 000000            NOP
353                                 DON_XMT
354       P:00007D P:00007D 0C0054            JMP     <START
355    
356                                 ; Process the receiver entry - is it in the command table ?
357       P:00007E P:00007E 0203DF  COMMAND   MOVE              X:(R3+1),B              ; Get the command
358       P:00007F P:00007F 205B00            MOVE              (R3)+
359       P:000080 P:000080 205B00            MOVE              (R3)+                   ; Point R3 to the first argument
360       P:000081 P:000081 302800            MOVE              #<COM_TBL,R0            ; Get the command table starting address
361       P:000082 P:000082 061E80            DO      #NUM_COM,END_COM                  ; Loop over the command table
                            000089
362       P:000084 P:000084 47D800            MOVE              X:(R0)+,Y1              ; Get the command table entry
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 7



363       P:000085 P:000085 62E07D            CMP     Y1,B      X:(R0),R2               ; Does receiver = table entries address?
364       P:000086 P:000086 0E2089            JNE     <NOT_COM                          ; No, keep looping
365       P:000087 P:000087 00008C            ENDDO                                     ; Restore the DO loop system registers
366       P:000088 P:000088 0AE280            JMP     (R2)                              ; Jump execution to the command
367       P:000089 P:000089 205800  NOT_COM   MOVE              (R0)+                   ; Increment the register past the table addr
ess
368                                 END_COM
369       P:00008A P:00008A 0C008B            JMP     <ERROR                            ; The command is not in the table
370    
371                                 ; It's not in the command table - send an error message
372       P:00008B P:00008B 479D00  ERROR     MOVE              X:<ERR,Y1               ; Send the message - there was an error
373       P:00008C P:00008C 0C008E            JMP     <FINISH1                          ; This protects against unknown commands
374    
375                                 ; Send a reply packet - header and reply
376       P:00008D P:00008D 479800  FINISH    MOVE              X:<DONE,Y1              ; Send 'DON' as the reply
377       P:00008E P:00008E 578500  FINISH1   MOVE              X:<HEADER,B             ; Get header of incoming command
378       P:00008F P:00008F 469C00            MOVE              X:<SMASK,Y0             ; This was the source byte, and is to
379       P:000090 P:000090 330700            MOVE              #<COM_BUF,R3            ;     become the destination byte
380       P:000091 P:000091 46935E            AND     Y0,B      X:<TWO,Y0
381       P:000092 P:000092 0C1ED1            LSR     #8,B                              ; Shift right eight bytes, add it to the
382       P:000093 P:000093 460600            MOVE              Y0,X:<NWORDS            ;     header, and put 2 as the number
383       P:000094 P:000094 469958            ADD     Y0,B      X:<SBRD,Y0              ;     of words in the string
384       P:000095 P:000095 200058            ADD     Y0,B                              ; Add source board's header, set Y1 for abov
e
385       P:000096 P:000096 000000            NOP
386       P:000097 P:000097 575B00            MOVE              B,X:(R3)+               ; Put the new header on the transmitter stac
k
387       P:000098 P:000098 475B00            MOVE              Y1,X:(R3)+              ; Put the argument on the transmitter stack
388       P:000099 P:000099 570500            MOVE              B,X:<HEADER
389       P:00009A P:00009A 0C0069            JMP     <RD_COM                           ; Decide where to send the reply, and do it
390    
391                                 ; Transmit words to the host computer over the fiber optics link
392       P:00009B P:00009B 63F400  FO_XMT    MOVE              #COM_BUF,R3
                            000007
393       P:00009D P:00009D 060600            DO      X:<NWORDS,DON_FFO                 ; Transmit all the words in the command
                            0000A1
394       P:00009F P:00009F 57DB00            MOVE              X:(R3)+,B
395       P:0000A0 P:0000A0 0D00E9            JSR     <XMT_WRD
396       P:0000A1 P:0000A1 000000            NOP
397       P:0000A2 P:0000A2 0C0054  DON_FFO   JMP     <START
398    
399                                 ; Check for commands from the fiber optic FIFO and the utility board (SCI)
400       P:0000A3 P:0000A3 0D00A7  GET_RCV   JSR     <CHK_FO                           ; Check for fiber optic command from FIFO
401       P:0000A4 P:0000A4 0E80A6            JCS     <RCV_RTS                          ; If there's a command, check the header
402       P:0000A5 P:0000A5 0D00D3            JSR     <CHK_SCI                          ; Check for an SCI command
403       P:0000A6 P:0000A6 00000C  RCV_RTS   RTS
404    
405                                 ; Because of FIFO metastability require that EF be stable for two tests
406       P:0000A7 P:0000A7 0A8989  CHK_FO    JCLR    #EF,X:HDR,TST2                    ; EF = Low,  Low  => CLR SR, return
                            0000AA
407       P:0000A9 P:0000A9 0C00AD            JMP     <TST3                             ;      High, Low  => try again
408       P:0000AA P:0000AA 0A8989  TST2      JCLR    #EF,X:HDR,CLR_CC                  ;      Low,  High => try again
                            0000CF
409       P:0000AC P:0000AC 0C00A7            JMP     <CHK_FO                           ;      High, High => read FIFO
410       P:0000AD P:0000AD 0A8989  TST3      JCLR    #EF,X:HDR,CHK_FO
                            0000A7
411    
412       P:0000AF P:0000AF 08F4BB            MOVEP             #$028FE2,X:BCR          ; Slow down RDFO access
                            028FE2
413       P:0000B1 P:0000B1 000000            NOP
414       P:0000B2 P:0000B2 000000            NOP
415       P:0000B3 P:0000B3 5FF000            MOVE                          Y:RDFO,B
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 8



                            FFFFF1
416       P:0000B5 P:0000B5 2B0000            MOVE              #0,B2
417       P:0000B6 P:0000B6 0140CE            AND     #$FF,B
                            0000FF
418       P:0000B8 P:0000B8 0140CD            CMP     #>$AC,B                           ; It must be $AC to be a valid word
                            0000AC
419       P:0000BA P:0000BA 0E20CF            JNE     <CLR_CC
420       P:0000BB P:0000BB 4EF000            MOVE                          Y:RDFO,Y0   ; Read the MS byte
                            FFFFF1
421       P:0000BD P:0000BD 0C1951            INSERT  #$008010,Y0,B
                            008010
422       P:0000BF P:0000BF 4EF000            MOVE                          Y:RDFO,Y0   ; Read the middle byte
                            FFFFF1
423       P:0000C1 P:0000C1 0C1951            INSERT  #$008008,Y0,B
                            008008
424       P:0000C3 P:0000C3 4EF000            MOVE                          Y:RDFO,Y0   ; Read the LS byte
                            FFFFF1
425       P:0000C5 P:0000C5 0C1951            INSERT  #$008000,Y0,B
                            008000
426       P:0000C7 P:0000C7 000000            NOP
427       P:0000C8 P:0000C8 516300            MOVE              B0,X:(R3)               ; Put the word into COM_BUF
428       P:0000C9 P:0000C9 0A0000            BCLR    #ST_RCV,X:<STATUS                 ; Its a command from the host computer
429       P:0000CA P:0000CA 000000  SET_CC    NOP
430       P:0000CB P:0000CB 0AF960            BSET    #0,SR                             ; Valid word => SR carry bit = 1
431       P:0000CC P:0000CC 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
432       P:0000CE P:0000CE 00000C            RTS
433       P:0000CF P:0000CF 0AF940  CLR_CC    BCLR    #0,SR                             ; Not valid word => SR carry bit = 0
434       P:0000D0 P:0000D0 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
435       P:0000D2 P:0000D2 00000C            RTS
436    
437                                 ; Test the SCI (= synchronous communications interface) for new words
438       P:0000D3 P:0000D3 44F000  CHK_SCI   MOVE              X:(SCI_TABLE+33),X0
                            000421
439       P:0000D5 P:0000D5 228E00            MOVE              R4,A
440       P:0000D6 P:0000D6 209000            MOVE              X0,R0
441       P:0000D7 P:0000D7 200045            CMP     X0,A
442       P:0000D8 P:0000D8 0EA0CF            JEQ     <CLR_CC                           ; There is no new SCI word
443       P:0000D9 P:0000D9 44D800            MOVE              X:(R0)+,X0
444       P:0000DA P:0000DA 446300            MOVE              X0,X:(R3)
445       P:0000DB P:0000DB 220E00            MOVE              R0,A
446       P:0000DC P:0000DC 0140C5            CMP     #(SCI_TABLE+32),A                 ; Wrap it around the circular
                            000420
447       P:0000DE P:0000DE 0EA0E2            JEQ     <INIT_PROCESSED_SCI               ;   buffer boundary
448       P:0000DF P:0000DF 547000            MOVE              A1,X:(SCI_TABLE+33)
                            000421
449       P:0000E1 P:0000E1 0C00E7            JMP     <SCI_END
450                                 INIT_PROCESSED_SCI
451       P:0000E2 P:0000E2 56F400            MOVE              #SCI_TABLE,A
                            000400
452       P:0000E4 P:0000E4 000000            NOP
453       P:0000E5 P:0000E5 567000            MOVE              A,X:(SCI_TABLE+33)
                            000421
454       P:0000E7 P:0000E7 0A0020  SCI_END   BSET    #ST_RCV,X:<STATUS                 ; Its a utility board (SCI) word
455       P:0000E8 P:0000E8 0C00CA            JMP     <SET_CC
456    
457                                 ; Transmit the word in B1 to the host computer over the fiber optic data link
458                                 XMT_WRD
459       P:0000E9 P:0000E9 08F4BB            MOVEP             #$028FE2,X:BCR          ; Slow down RDFO access
                            028FE2
460       P:0000EB P:0000EB 60F400            MOVE              #FO_HDR+1,R0
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 9



                            000002
461       P:0000ED P:0000ED 060380            DO      #3,XMT_WRD1
                            0000F1
462       P:0000EF P:0000EF 0C1D91            ASL     #8,B,B
463       P:0000F0 P:0000F0 000000            NOP
464       P:0000F1 P:0000F1 535800            MOVE              B2,X:(R0)+
465                                 XMT_WRD1
466       P:0000F2 P:0000F2 60F400            MOVE              #FO_HDR,R0
                            000001
467       P:0000F4 P:0000F4 61F400            MOVE              #WRFO,R1
                            FFFFF2
468       P:0000F6 P:0000F6 060480            DO      #4,XMT_WRD2
                            0000F9
469       P:0000F8 P:0000F8 46D800            MOVE              X:(R0)+,Y0              ; Should be MOVEP  X:(R0)+,Y:WRFO
470       P:0000F9 P:0000F9 4E6100            MOVE                          Y0,Y:(R1)
471                                 XMT_WRD2
472       P:0000FA P:0000FA 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
473       P:0000FC P:0000FC 00000C            RTS
474    
475                                 ; Check the command or reply header in X:(R3) for self-consistency
476       P:0000FD P:0000FD 46E300  CHK_HDR   MOVE              X:(R3),Y0
477       P:0000FE P:0000FE 579600            MOVE              X:<MASK1,B              ; Test for S.LE.3 and D.LE.3 and N.LE.7
478       P:0000FF P:0000FF 20005E            AND     Y0,B
479       P:000100 P:000100 0E208B            JNE     <ERROR                            ; Test failed
480       P:000101 P:000101 579700            MOVE              X:<MASK2,B              ; Test for either S.NE.0 or D.NE.0
481       P:000102 P:000102 20005E            AND     Y0,B
482       P:000103 P:000103 0EA08B            JEQ     <ERROR                            ; Test failed
483       P:000104 P:000104 579500            MOVE              X:<SEVEN,B
484       P:000105 P:000105 20005E            AND     Y0,B                              ; Extract NWORDS, must be > 0
485       P:000106 P:000106 0EA08B            JEQ     <ERROR
486       P:000107 P:000107 44E300            MOVE              X:(R3),X0
487       P:000108 P:000108 440500            MOVE              X0,X:<HEADER            ; Its a correct header
488       P:000109 P:000109 550600            MOVE              B1,X:<NWORDS            ; Number of words in the command
489       P:00010A P:00010A 0C005C            JMP     <PR_RCV
490    
491                                 ;  *****************  Boot Commands  *******************
492    
493                                 ; Test Data Link - simply return value received after 'TDL'
494       P:00010B P:00010B 47DB00  TDL       MOVE              X:(R3)+,Y1              ; Get the data value
495       P:00010C P:00010C 0C008E            JMP     <FINISH1                          ; Return from executing TDL command
496    
497                                 ; Read DSP or EEPROM memory ('RDM' address): read memory, reply with value
498       P:00010D P:00010D 47DB00  RDMEM     MOVE              X:(R3)+,Y1
499       P:00010E P:00010E 20EF00            MOVE              Y1,B
500       P:00010F P:00010F 0140CE            AND     #$0FFFFF,B                        ; Bits 23-20 need to be zeroed
                            0FFFFF
501       P:000111 P:000111 21B000            MOVE              B1,R0                   ; Need the address in an address register
502       P:000112 P:000112 20EF00            MOVE              Y1,B
503       P:000113 P:000113 000000            NOP
504       P:000114 P:000114 0ACF14            JCLR    #20,B,RDX                         ; Test address bit for Program memory
                            000118
505       P:000116 P:000116 07E087            MOVE              P:(R0),Y1               ; Read from Program Memory
506       P:000117 P:000117 0C008E            JMP     <FINISH1                          ; Send out a header with the value
507       P:000118 P:000118 0ACF15  RDX       JCLR    #21,B,RDY                         ; Test address bit for X: memory
                            00011C
508       P:00011A P:00011A 47E000            MOVE              X:(R0),Y1               ; Write to X data memory
509       P:00011B P:00011B 0C008E            JMP     <FINISH1                          ; Send out a header with the value
510       P:00011C P:00011C 0ACF16  RDY       JCLR    #22,B,RDR                         ; Test address bit for Y: memory
                            000120
511       P:00011E P:00011E 4FE000            MOVE                          Y:(R0),Y1   ; Read from Y data memory
512       P:00011F P:00011F 0C008E            JMP     <FINISH1                          ; Send out a header with the value
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 10



513       P:000120 P:000120 0ACF17  RDR       JCLR    #23,B,ERROR                       ; Test address bit for read from EEPROM memo
ry
                            00008B
514       P:000122 P:000122 479400            MOVE              X:<THREE,Y1             ; Convert to word address to a byte address
515       P:000123 P:000123 220600            MOVE              R0,Y0                   ; Get 16-bit address in a data register
516       P:000124 P:000124 2000B8            MPY     Y0,Y1,B                           ; Multiply
517       P:000125 P:000125 20002A            ASR     B                                 ; Eliminate zero fill of fractional multiply
518       P:000126 P:000126 213000            MOVE              B0,R0                   ; Need to address memory
519       P:000127 P:000127 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
520       P:000128 P:000128 0D0176            JSR     <RD_WORD                          ; Read word from EEPROM
521       P:000129 P:000129 21A700            MOVE              B1,Y1                   ; FINISH1 transmits Y1 as its reply
522       P:00012A P:00012A 0C008E            JMP     <FINISH1
523    
524                                 ; Program WRMEM ('WRM' address datum): write to memory, reply 'DON'.
525       P:00012B P:00012B 47DB00  WRMEM     MOVE              X:(R3)+,Y1              ; Get the address to be written to
526       P:00012C P:00012C 20EF00            MOVE              Y1,B
527       P:00012D P:00012D 0140CE            AND     #$0FFFFF,B                        ; Bits 23-20 need to be zeroed
                            0FFFFF
528       P:00012F P:00012F 21B000            MOVE              B1,R0                   ; Need the address in an address register
529       P:000130 P:000130 20EF00            MOVE              Y1,B
530       P:000131 P:000131 46DB00            MOVE              X:(R3)+,Y0              ; Get datum into Y0 so MOVE works easily
531       P:000132 P:000132 0ACF14            JCLR    #20,B,WRX                         ; Test address bit for Program memory
                            000136
532       P:000134 P:000134 076086            MOVE              Y0,P:(R0)               ; Write to Program memory
533       P:000135 P:000135 0C008D            JMP     <FINISH
534       P:000136 P:000136 0ACF15  WRX       JCLR    #21,B,WRY                         ; Test address bit for X: memory
                            00013A
535       P:000138 P:000138 466000            MOVE              Y0,X:(R0)               ; Write to X: memory
536       P:000139 P:000139 0C008D            JMP     <FINISH
537       P:00013A P:00013A 0ACF16  WRY       JCLR    #22,B,WRR                         ; Test address bit for Y: memory
                            00013E
538       P:00013C P:00013C 4E6000            MOVE                          Y0,Y:(R0)   ; Write to Y: memory
539       P:00013D P:00013D 0C008D            JMP     <FINISH
540       P:00013E P:00013E 0ACF17  WRR       JCLR    #23,B,ERROR                       ; Test address bit for write to EEPROM
                            00008B
541       P:000140 P:000140 013D02            BCLR    #WRENA,X:PDRC                     ; WR_ENA* = 0 to enable EEPROM writing
542       P:000141 P:000141 460E00            MOVE              Y0,X:<SV_A1             ; Save the datum to be written
543       P:000142 P:000142 479400            MOVE              X:<THREE,Y1             ; Convert word address to a byte address
544       P:000143 P:000143 220600            MOVE              R0,Y0                   ; Get 16-bit address in a data register
545       P:000144 P:000144 2000B8            MPY     Y1,Y0,B                           ; Multiply
546       P:000145 P:000145 20002A            ASR     B                                 ; Eliminate zero fill of fractional multiply
547       P:000146 P:000146 213000            MOVE              B0,R0                   ; Need to address memory
548       P:000147 P:000147 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
549       P:000148 P:000148 558E00            MOVE              X:<SV_A1,B1             ; Get the datum to be written
550       P:000149 P:000149 060380            DO      #3,L1WRR                          ; Loop over three bytes of the word
                            000152
551       P:00014B P:00014B 07588D            MOVE              B1,P:(R0)+              ; Write each EEPROM byte
552       P:00014C P:00014C 0C1C91            ASR     #8,B,B
553       P:00014D P:00014D 469E00            MOVE              X:<C100K,Y0             ; Move right one byte, enter delay = 1 msec
554       P:00014E P:00014E 06C600            DO      Y0,L2WRR                          ; Delay by 12 milliseconds for EEPROM write
                            000151
555       P:000150 P:000150 060CA0            REP     #12                               ; Assume 100 MHz DSP56303
556       P:000151 P:000151 000000            NOP
557                                 L2WRR
558       P:000152 P:000152 000000            NOP                                       ; DO loop nesting restriction
559                                 L1WRR
560       P:000153 P:000153 013D22            BSET    #WRENA,X:PDRC                     ; WR_ENA* = 1 to disable EEPROM writing
561       P:000154 P:000154 0C008D            JMP     <FINISH
562    
563                                 ; Load application code from P: memory into its proper locations
564       P:000155 P:000155 47DB00  LDAPPL    MOVE              X:(R3)+,Y1              ; Application number, not used yet
565       P:000156 P:000156 0D0158            JSR     <LOAD_APPLICATION
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 11



566       P:000157 P:000157 0C008D            JMP     <FINISH
567    
568                                 LOAD_APPLICATION
569       P:000158 P:000158 60F400            MOVE              #$8000,R0               ; Starting EEPROM address
                            008000
570       P:00015A P:00015A 0D0176            JSR     <RD_WORD                          ; Number of words in boot code
571       P:00015B P:00015B 21A600            MOVE              B1,Y0
572       P:00015C P:00015C 479400            MOVE              X:<THREE,Y1
573       P:00015D P:00015D 2000B8            MPY     Y0,Y1,B
574       P:00015E P:00015E 20002A            ASR     B
575       P:00015F P:00015F 213000            MOVE              B0,R0                   ; EEPROM address of start of P: application
576       P:000160 P:000160 0AD06F            BSET    #15,R0                            ; To access EEPROM
577       P:000161 P:000161 0D0176            JSR     <RD_WORD                          ; Read number of words in application P:
578       P:000162 P:000162 61F400            MOVE              #(X_BOOT_START+1),R1    ; End of boot P: code that needs keeping
                            000226
579       P:000164 P:000164 06CD00            DO      B1,RD_APPL_P
                            000167
580       P:000166 P:000166 0D0176            JSR     <RD_WORD
581       P:000167 P:000167 07598D            MOVE              B1,P:(R1)+
582                                 RD_APPL_P
583       P:000168 P:000168 0D0176            JSR     <RD_WORD                          ; Read number of words in application X:
584       P:000169 P:000169 61F400            MOVE              #END_COMMAND_TABLE,R1
                            000036
585       P:00016B P:00016B 06CD00            DO      B1,RD_APPL_X
                            00016E
586       P:00016D P:00016D 0D0176            JSR     <RD_WORD
587       P:00016E P:00016E 555900            MOVE              B1,X:(R1)+
588                                 RD_APPL_X
589       P:00016F P:00016F 0D0176            JSR     <RD_WORD                          ; Read number of words in application Y:
590       P:000170 P:000170 310100            MOVE              #1,R1                   ; There is no Y: memory in the boot code
591       P:000171 P:000171 06CD00            DO      B1,RD_APPL_Y
                            000174
592       P:000173 P:000173 0D0176            JSR     <RD_WORD
593       P:000174 P:000174 5D5900            MOVE                          B1,Y:(R1)+
594                                 RD_APPL_Y
595       P:000175 P:000175 00000C            RTS
596    
597                                 ; Read one word from EEPROM location R0 into accumulator B1
598       P:000176 P:000176 060380  RD_WORD   DO      #3,L_RDBYTE
                            000179
599       P:000178 P:000178 07D88B            MOVE              P:(R0)+,B2
600       P:000179 P:000179 0C1C91            ASR     #8,B,B
601                                 L_RDBYTE
602       P:00017A P:00017A 00000C            RTS
603    
604                                 ; Come to here on a 'STP' command so 'DON' can be sent
605                                 STOP_IDLE_CLOCKING
606       P:00017B P:00017B 305800            MOVE              #<TST_RCV,R0            ; Execution address when idle => when not
607       P:00017C P:00017C 601F00            MOVE              R0,X:<IDL_ADR           ;   processing commands or reading out
608       P:00017D P:00017D 0A0002            BCLR    #IDLMODE,X:<STATUS                ; Don't idle after readout
609       P:00017E P:00017E 0C008D            JMP     <FINISH
610    
611                                 ; Routines executed after the DSP boots and initializes
612       P:00017F P:00017F 305800  STARTUP   MOVE              #<TST_RCV,R0            ; Execution address when idle => when not
613       P:000180 P:000180 601F00            MOVE              R0,X:<IDL_ADR           ;   processing commands or reading out
614       P:000181 P:000181 44F400            MOVE              #50000,X0               ; Delay by 500 milliseconds
                            00C350
615       P:000183 P:000183 06C400            DO      X0,L_DELAY
                            000186
616       P:000185 P:000185 06E8A3            REP     #1000
617       P:000186 P:000186 000000            NOP
618                                 L_DELAY
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 12



619       P:000187 P:000187 57F400            MOVE              #$020002,B              ; Normal reply after booting is 'SYR'
                            020002
620       P:000189 P:000189 0D00E9            JSR     <XMT_WRD
621       P:00018A P:00018A 57F400            MOVE              #'SYR',B
                            535952
622       P:00018C P:00018C 0D00E9            JSR     <XMT_WRD
623    
624       P:00018D P:00018D 0C0054            JMP     <START                            ; Start normal command processing
625    
626                                 ; *******************  DSP  INITIALIZATION  CODE  **********************
627                                 ; This code initializes the DSP right after booting, and is overwritten
628                                 ;   by application code
629       P:00018E P:00018E 08F4BD  INIT      MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL to 100 MHz
                            050003
630       P:000190 P:000190 000000            NOP
631    
632                                 ; Set operation mode register OMR to normal expanded
633       P:000191 P:000191 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
634       P:000192 P:000192 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
635    
636                                 ; Program the AA = address attribute pins
637       P:000193 P:000193 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts commands
                            FFFC21
638       P:000195 P:000195 08F4B8            MOVEP             #$008909,X:AAR1         ; P = $008000 to $00FFFF accesses the EEPROM
                            008909
639       P:000197 P:000197 08F4B7            MOVEP             #$010C11,X:AAR2         ; X = $010000 to $010FFF reads A/D values
                            010C11
640       P:000199 P:000199 08F4B6            MOVEP             #$080621,X:AAR3         ; Y = $080000 to $0BFFFF R/W from SRAM
                            080621
641    
642                                 ; Program the DRAM memory access and addressing
643       P:00019B P:00019B 08F4BB            MOVEP             #$028FE1,X:BCR          ; Bus Control Register
                            028FE1
644    
645                                 ; Program the Host port B for parallel I/O
646       P:00019D P:00019D 08F484            MOVEP             #>1,X:HPCR              ; All pins enabled as GPIO
                            000001
647       P:00019F P:00019F 08F489            MOVEP             #$810C,X:HDR
                            00810C
648       P:0001A1 P:0001A1 08F488            MOVEP             #$B10E,X:HDDR           ; Data Direction Register
                            00B10E
649                                                                                     ;  (1 for Output, 0 for Input)
650    
651                                 ; Port B conversion from software bits to schematic labels
652                                 ;       PB0 = PWROK             PB08 = PRSFIFO*
653                                 ;       PB1 = LED1              PB09 = EF*
654                                 ;       PB2 = LVEN              PB10 = EXT-IN0
655                                 ;       PB3 = HVEN              PB11 = EXT-IN1
656                                 ;       PB4 = STATUS0           PB12 = EXT-OUT0
657                                 ;       PB5 = STATUS1           PB13 = EXT-OUT1
658                                 ;       PB6 = STATUS2           PB14 = SSFHF*
659                                 ;       PB7 = STATUS3           PB15 = SELSCI
660    
661                                 ; Program the serial port ESSI0 = Port C for serial communication with
662                                 ;   the utility board
663       P:0001A3 P:0001A3 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
664       P:0001A5 P:0001A5 07F435            MOVEP             #$180809,X:CRA0         ; Divide 100 MHz by 20 to get 5.0 MHz
                            180809
665                                                                                     ; DC[4:0] = 0 for non-network operation
666                                                                                     ; WL0-WL2 = 3 for 24-bit data words
667                                                                                     ; SSC1 = 0 for SC1 not used
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 13



668       P:0001A7 P:0001A7 07F436            MOVEP             #$020020,X:CRB0         ; SCKD = 1 for internally generated clock
                            020020
669                                                                                     ; SCD2 = 0 so frame sync SC2 is an output
670                                                                                     ; SHFD = 0 for MSB shifted first
671                                                                                     ; FSL = 0, frame sync length not used
672                                                                                     ; CKP = 0 for rising clock edge transitions
673                                                                                     ; SYN = 0 for asynchronous
674                                                                                     ; TE0 = 1 to enable transmitter #0
675                                                                                     ; MOD = 0 for normal, non-networked mode
676                                                                                     ; TE0 = 0 to NOT enable transmitter #0 yet
677                                                                                     ; RE = 1 to enable receiver
678       P:0001A9 P:0001A9 07F43F            MOVEP             #%111001,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000039
679       P:0001AB P:0001AB 07F43E            MOVEP             #%000110,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            000006
680       P:0001AD P:0001AD 07F43D            MOVEP             #%000100,X:PDRC         ; Data Register - WR_ENA* = 1
                            000004
681    
682                                 ; Port C version = Analog boards
683                                 ;       MOVEP   #$000809,X:CRA0 ; Divide 100 MHz by 20 to get 5.0 MHz
684                                 ;       MOVEP   #$000030,X:CRB0 ; SCKD = 1 for internally generated clock
685                                 ;       MOVEP   #%100000,X:PCRC ; Control Register (0 for GPIO, 1 for ESSI)
686                                 ;       MOVEP   #%000100,X:PRRC ; Data Direction Register (0 for In, 1 for Out)
687                                 ;       MOVEP   #%000000,X:PDRC ; Data Register: 'not used' = 0 outputs
688    
689       P:0001AF P:0001AF 07F43C            MOVEP             #0,X:TX00               ; Initialize the transmitter to zero
                            000000
690       P:0001B1 P:0001B1 000000            NOP
691       P:0001B2 P:0001B2 000000            NOP
692       P:0001B3 P:0001B3 013630            BSET    #TE,X:CRB0                        ; Enable the SSI transmitter
693    
694                                 ; Conversion from software bits to schematic labels for Port C
695                                 ;       PC0 = SC00 = UTL-T-SCK
696                                 ;       PC1 = SC01 = 2_XMT = SYNC on prototype
697                                 ;       PC2 = SC02 = WR_ENA*
698                                 ;       PC3 = SCK0 = TIM-U-SCK
699                                 ;       PC4 = SRD0 = UTL-T-STD
700                                 ;       PC5 = STD0 = TIM-U-STD
701    
702                                 ; Program the serial port ESSI1 = Port D for serial transmission to
703                                 ;   the analog boards and two parallel I/O input pins
704       P:0001B4 P:0001B4 07F42F            MOVEP             #>0,X:PCRD              ; Software reset of ESSI0
                            000000
705       P:0001B6 P:0001B6 07F425            MOVEP             #$000809,X:CRA1         ; Divide 100 MHz by 20 to get 5.0 MHz
                            000809
706                                                                                     ; DC[4:0] = 0
707                                                                                     ; WL[2:0] = ALC = 0 for 8-bit data words
708                                                                                     ; SSC1 = 0 for SC1 not used
709       P:0001B8 P:0001B8 07F426            MOVEP             #$000030,X:CRB1         ; SCKD = 1 for internally generated clock
                            000030
710                                                                                     ; SCD2 = 1 so frame sync SC2 is an output
711                                                                                     ; SHFD = 0 for MSB shifted first
712                                                                                     ; CKP = 0 for rising clock edge transitions
713                                                                                     ; TE0 = 0 to NOT enable transmitter #0 yet
714                                                                                     ; MOD = 0 so its not networked mode
715       P:0001BA P:0001BA 07F42F            MOVEP             #%100000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000020
716                                                                                     ; PD3 = SCK1, PD5 = STD1 for ESSI
717       P:0001BC P:0001BC 07F42E            MOVEP             #%000100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            000004
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 14



718       P:0001BE P:0001BE 07F42D            MOVEP             #%000100,X:PDRD         ; Data Register: 'not used' = 0 outputs
                            000004
719       P:0001C0 P:0001C0 07F42C            MOVEP             #0,X:TX10               ; Initialize the transmitter to zero
                            000000
720       P:0001C2 P:0001C2 000000            NOP
721       P:0001C3 P:0001C3 000000            NOP
722       P:0001C4 P:0001C4 012630            BSET    #TE,X:CRB1                        ; Enable the SSI transmitter
723    
724                                 ; Conversion from software bits to schematic labels for Port D
725                                 ; PD0 = SC10 = 2_XMT_? input
726                                 ; PD1 = SC11 = SSFEF* input
727                                 ; PD2 = SC12 = PWR_EN
728                                 ; PD3 = SCK1 = TIM-A-SCK
729                                 ; PD4 = SRD1 = PWRRST
730                                 ; PD5 = STD1 = TIM-A-STD
731    
732                                 ; Program the SCI port to communicate with the utility board
733       P:0001C5 P:0001C5 07F41C            MOVEP             #$0B04,X:SCR            ; SCI programming: 11-bit asynchronous
                            000B04
734                                                                                     ;   protocol (1 start, 8 data, 1 even parity
,
735                                                                                     ;   1 stop); LSB before MSB; enable receiver
736                                                                                     ;   and its interrupts; transmitter interrup
ts
737                                                                                     ;   disabled.
738       P:0001C7 P:0001C7 07F41B            MOVEP             #$0003,X:SCCR           ; SCI clock: utility board data rate =
                            000003
739                                                                                     ;   (390,625 kbits/sec); internal clock.
740       P:0001C9 P:0001C9 07F41F            MOVEP             #%011,X:PCRE            ; Port Control Register = RXD, TXD enabled
                            000003
741       P:0001CB P:0001CB 07F41E            MOVEP             #%000,X:PRRE            ; Port Direction Register (0 = Input)
                            000000
742    
743                                 ;       PE0 = RXD
744                                 ;       PE1 = TXD
745                                 ;       PE2 = SCLK
746    
747                                 ; Program one of the three timers as an exposure timer
748       P:0001CD P:0001CD 07F403            MOVEP             #$C34F,X:TPLR           ; Prescaler to generate millisecond timer,
                            00C34F
749                                                                                     ;  counting from the system clock / 2 = 50 M
Hz
750       P:0001CF P:0001CF 07F40F            MOVEP             #$208200,X:TCSR0        ; Clear timer complete bit and enable presca
ler
                            208200
751       P:0001D1 P:0001D1 07F40E            MOVEP             #0,X:TLR0               ; Timer load register
                            000000
752    
753                                 ; Enable interrupts for the SCI port only
754       P:0001D3 P:0001D3 08F4BF            MOVEP             #$000000,X:IPRC         ; No interrupts allowed
                            000000
755       P:0001D5 P:0001D5 08F4BE            MOVEP             #>$80,X:IPRP            ; Enable SCI interrupt only, IPR = 1
                            000080
756       P:0001D7 P:0001D7 00FCB8            ANDI    #$FC,MR                           ; Unmask all interrupt levels
757    
758                                 ; Initialize the fiber optic serial receiver circuitry
759       P:0001D8 P:0001D8 061480            DO      #20,L_FO_INIT
                            0001DD
760       P:0001DA P:0001DA 5FF000            MOVE                          Y:RDFO,B
                            FFFFF1
761       P:0001DC P:0001DC 0605A0            REP     #5
762       P:0001DD P:0001DD 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 15



763                                 L_FO_INIT
764    
765                                 ; Pulse PRSFIFO* low to revive the CMDRST* instruction and reset the FIFO
766       P:0001DE P:0001DE 44F400            MOVE              #1000000,X0             ; Delay by 10 milliseconds
                            0F4240
767       P:0001E0 P:0001E0 06C400            DO      X0,*+3
                            0001E2
768       P:0001E2 P:0001E2 000000            NOP
769       P:0001E3 P:0001E3 0A8908            BCLR    #8,X:HDR
770       P:0001E4 P:0001E4 0614A0            REP     #20
771       P:0001E5 P:0001E5 000000            NOP
772       P:0001E6 P:0001E6 0A8928            BSET    #8,X:HDR
773    
774                                 ; Reset the utility board
775       P:0001E7 P:0001E7 0A0F05            BCLR    #5,X:<LATCH
776       P:0001E8 P:0001E8 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Clear reset utility board bit
                            00000F
777       P:0001EA P:0001EA 06C8A0            REP     #200                              ; Delay by RESET* low time
778       P:0001EB P:0001EB 000000            NOP
779       P:0001EC P:0001EC 0A0F25            BSET    #5,X:<LATCH
780       P:0001ED P:0001ED 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Clear reset utility board bit
                            00000F
781       P:0001EF P:0001EF 56F400            MOVE              #200000,A               ; Delay 2 msec for utility boot
                            030D40
782       P:0001F1 P:0001F1 06CE00            DO      A,*+3
                            0001F3
783       P:0001F3 P:0001F3 000000            NOP
784    
785                                 ; Put all the analog switch inputs to low so they draw minimum current
786       P:0001F4 P:0001F4 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
787       P:0001F5 P:0001F5 56F400            MOVE              #$0C3000,A              ; Value of integrate speed and gain switches
                            0C3000
788       P:0001F7 P:0001F7 20001B            CLR     B
789       P:0001F8 P:0001F8 241000            MOVE              #$100000,X0             ; Increment over board numbers for DAC write
s
790       P:0001F9 P:0001F9 45F400            MOVE              #$001000,X1             ; Increment over board numbers for WRSS writ
es
                            001000
791       P:0001FB P:0001FB 060F80            DO      #15,L_ANALOG                      ; Fifteen video processor boards maximum
                            000203
792       P:0001FD P:0001FD 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
793       P:0001FE P:0001FE 200040            ADD     X0,A
794       P:0001FF P:0001FF 5F7000            MOVE                          B,Y:WRSS    ; This is for the fast analog switches
                            FFFFF3
795       P:000201 P:000201 0620A3            REP     #800                              ; Delay for the serial data transmission
796       P:000202 P:000202 000000            NOP
797       P:000203 P:000203 200068            ADD     X1,B                              ; Increment the video and clock driver numbe
rs
798                                 L_ANALOG
799       P:000204 P:000204 0A0F00            BCLR    #CDAC,X:<LATCH                    ; Enable clearing of DACs
800       P:000205 P:000205 0A0F02            BCLR    #ENCK,X:<LATCH                    ; Disable clock and DAC output switches
801       P:000206 P:000206 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Execute these two operations
                            00000F
802       P:000208 P:000208 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
803       P:000209 P:000209 0C021E            JMP     <SKIP
804    
805                                 ; Transmit contents of accumulator A1 over the synchronous serial transmitter
806                                 XMIT_A_WORD
807       P:00020A P:00020A 547000            MOVE              A1,X:SV_A1
                            00000E
808       P:00020C P:00020C 01A786            JCLR    #TDE,X:SSISR1,*                   ; Start bit
                            00020C
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 16



809       P:00020E P:00020E 07F42C            MOVEP             #$010000,X:TX10
                            010000
810       P:000210 P:000210 060380            DO      #3,L_XMIT
                            000216
811       P:000212 P:000212 01A786            JCLR    #TDE,X:SSISR1,*                   ; Three data bytes
                            000212
812       P:000214 P:000214 04CCCC            MOVEP             A1,X:TX10
813       P:000215 P:000215 0C1E90            LSL     #8,A
814       P:000216 P:000216 000000            NOP
815                                 L_XMIT
816       P:000217 P:000217 01A786            JCLR    #TDE,X:SSISR1,*                   ; Zeroes to bring transmitter low
                            000217
817       P:000219 P:000219 07F42C            MOVEP             #0,X:TX10
                            000000
818       P:00021B P:00021B 54F000            MOVE              X:SV_A1,A1
                            00000E
819       P:00021D P:00021D 00000C            RTS
820    
821                                 SKIP
822    
823                                 ; Set up the circular SCI buffer, 32 words in size
824       P:00021E P:00021E 64F400            MOVE              #SCI_TABLE,R4
                            000400
825       P:000220 P:000220 051FA4            MOVE              #31,M4
826       P:000221 P:000221 647000            MOVE              R4,X:(SCI_TABLE+33)
                            000421
827    
828                                           IF      @SCP("HOST","ROM")
836                                           ENDIF
837    
838       P:000223 P:000223 44F400            MOVE              #>$AC,X0
                            0000AC
839       P:000225 P:000225 440100            MOVE              X0,X:<FO_HDR
840    
841       P:000226 P:000226 0C017F            JMP     <STARTUP
842    
843                                 ;  ****************  X: Memory tables  ********************
844    
845                                 ; Define the address in P: space where the table of constants begins
846    
847                                  X_BOOT_START
848       000225                              EQU     @LCV(L)-2
849    
850                                           IF      @SCP("HOST","ROM")
852                                           ENDIF
853                                           IF      @SCP("HOST","HOST")
854       X:000000 X:000000                   ORG     X:0,X:0
855                                           ENDIF
856    
857                                 ; Special storage area - initialization constants and scratch space
858       X:000000 X:000000         STATUS    DC      $1064                             ; Controller status bits
859    
860       000001                    FO_HDR    EQU     STATUS+1                          ; Fiber optic write bytes
861       000005                    HEADER    EQU     FO_HDR+4                          ; Command header
862       000006                    NWORDS    EQU     HEADER+1                          ; Number of words in the command
863       000007                    COM_BUF   EQU     NWORDS+1                          ; Command buffer
864       00000E                    SV_A1     EQU     COM_BUF+7                         ; Save accumulator A1
865    
866                                           IF      @SCP("HOST","ROM")
871                                           ENDIF
872    
873                                           IF      @SCP("HOST","HOST")
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_boot.asm  Page 17



874       X:00000F X:00000F                   ORG     X:$F,X:$F
875                                           ENDIF
876    
877                                 ; Parameter table in P: space to be copied into X: space during
878                                 ;   initialization, and is copied from ROM by the DSP boot
879       X:00000F X:00000F         LATCH     DC      $7A                               ; Starting value in latch chip U25
880                                  EXPOSURE_TIME
881       X:000010 X:000010                   DC      0                                 ; Exposure time in milliseconds
882                                  ELAPSED_TIME
883       X:000011 X:000011                   DC      0                                 ; Time elapsed so far in the exposure
884       X:000012 X:000012         ONE       DC      1                                 ; One
885       X:000013 X:000013         TWO       DC      2                                 ; Two
886       X:000014 X:000014         THREE     DC      3                                 ; Three
887       X:000015 X:000015         SEVEN     DC      7                                 ; Seven
888       X:000016 X:000016         MASK1     DC      $FCFCF8                           ; Mask for checking header
889       X:000017 X:000017         MASK2     DC      $030300                           ; Mask for checking header
890       X:000018 X:000018         DONE      DC      'DON'                             ; Standard reply
891       X:000019 X:000019         SBRD      DC      $020000                           ; Source Identification number
892       X:00001A X:00001A         TIM_DRB   DC      $000200                           ; Destination = timing board number
893       X:00001B X:00001B         DMASK     DC      $00FF00                           ; Mask to get destination board number
894       X:00001C X:00001C         SMASK     DC      $FF0000                           ; Mask to get source board number
895       X:00001D X:00001D         ERR       DC      'ERR'                             ; An error occurred
896       X:00001E X:00001E         C100K     DC      100000                            ; Delay for WRROM = 1 millisec
897       X:00001F X:00001F         IDL_ADR   DC      TST_RCV                           ; Address of idling routine
898       X:000020 X:000020         EXP_ADR   DC      0                                 ; Jump to this address during exposures
899    
900                                 ; Places for saving register values
901       X:000021 X:000021         SAVE_SR   DC      0                                 ; Status Register
902       X:000022 X:000022         SAVE_X1   DC      0
903       X:000023 X:000023         SAVE_A1   DC      0
904       X:000024 X:000024         SAVE_R0   DC      0
905       X:000025 X:000025         RCV_ERR   DC      0
906       X:000026 X:000026         SCI_A1    DC      0                                 ; Contents of accumulator A1 in RCV ISR
907       X:000027 X:000027         SCI_R0    DC      SRXL
908    
909                                 ; Command table
910       000028                    COM_TBL_R EQU     @LCV(R)
911       X:000028 X:000028         COM_TBL   DC      'TDL',TDL                         ; Test Data Link
912       X:00002A X:00002A                   DC      'RDM',RDMEM                       ; Read from DSP or EEPROM memory
913       X:00002C X:00002C                   DC      'WRM',WRMEM                       ; Write to DSP memory
914       X:00002E X:00002E                   DC      'LDA',LDAPPL                      ; Load application from EEPROM to DSP
915       X:000030 X:000030                   DC      'STP',STOP_IDLE_CLOCKING
916       X:000032 X:000032                   DC      'DON',START                       ; Nothing special
917       X:000034 X:000034                   DC      'ERR',START                       ; Nothing special
918    
919                                  END_COMMAND_TABLE
920       000036                              EQU     @LCV(R)
921    
922                                 ; The table at SCI_TABLE is for words received from the utility board, written by
923                                 ;   the interrupt service routine SCI_RCV. Note that it is 32 words long,
924                                 ;   hard coded, and the 33rd location contains the pointer to words that have
925                                 ;   been processed by moving them from the SCI_TABLE to the COM_BUF.
926    
927                                           IF      @SCP("HOST","ROM")
929                                           ENDIF
930    
931       000036                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
932    
933       P:000227 P:000227                   ORG     P:,P:
934    
935       000090                    CC        EQU     CCDVIDREV3B+TIMREV5+SHUTTER_CC
936    
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3.asm  Page 18



937                                 ; Put number of words of application in P: for loading application from EEPROM
938       P:000227 P:000227                   DC      TIMBOOT_X_MEMORY-@LCV(L)-1
939    
940                                 ; *** include readout routines ***
941                                           INCLUDE "tim3_rdccd.asm"
942                                 ; rdccd.asm - AzCam CCD Readout routines for ARC Gen 3
943                                 ; Based on a the ICE readout code developed by Skip Schaller and Michael Lesser.
944                                 ; 20Aug04 last change by Michael Lesser
945    
946                                 ; Routines contained in this file are:
947    
948                                 ; RDCCD
949                                 ; PDATA
950                                 ; PDSKIP
951                                 ; PSKIP
952                                 ; PQSKIP
953                                 ; RSKIP
954                                 ; FSSKIP
955                                 ; SSKIP
956                                 ; SDATA
957                                 ; CNSAMPS
958                                 ; CNPAMPS
959                                 ; PCLOCK
960                                 ; CLEAR
961                                 ; CLR_CCD
962                                 ; FOR_PSHIFT
963                                 ; PAR_PSHIFT
964                                 ; START_IDLE_CLOCKING
965                                 ; IDLE
966    
967                                 ; *******************************************************************
968                                 ; Shift and read CCD
969                                 RDCCD
970       P:000228 P:000228 0A0024            BSET    #ST_RDC,X:<STATUS                 ; Set status to reading out
971       P:000229 P:000229 0D03F2            JSR     <PCI_READ_IMAGE                   ; Get the PCI board reading the image
972    
973       P:00022A P:00022A 0A00AA            JSET    #TST_IMG,X:STATUS,SYNTHETIC_IMAGE ; jump for fake image
                            0003BF
974    
975       P:00022C P:00022C 68A500            MOVE                          Y:<AFPXFER0,R0 ; frame transfer
976       P:00022D P:00022D 0D0402            JSR     <CLOCK
977       P:00022E P:00022E 301500            MOVE              #<FRAMET,R0
978       P:00022F P:00022F 0D0291            JSR     <PQSKIP
979       P:000230 P:000230 0E8054            JCS     <START
980    
981       P:000231 P:000231 300E00            MOVE              #<NPPRESKIP,R0          ; skip to underscan
982       P:000232 P:000232 0D0285            JSR     <PSKIP
983       P:000233 P:000233 0E8054            JCS     <START
984       P:000234 P:000234 68A600            MOVE                          Y:<AFPXFER2,R0
985       P:000235 P:000235 0D0402            JSR     <CLOCK
986       P:000236 P:000236 300700            MOVE              #<NSCLEAR,R0
987       P:000237 P:000237 0D02A9            JSR     <FSSKIP
988    
989       P:000238 P:000238 300F00            MOVE              #<NPUNDERSCAN,R0        ; read underscan
990       P:000239 P:000239 0D025E            JSR     <PDATA
991       P:00023A P:00023A 0E8054            JCS     <START
992    
993       P:00023B P:00023B 68A500            MOVE                          Y:<AFPXFER0,R0 ; skip to ROI
994       P:00023C P:00023C 0D0402            JSR     <CLOCK
995       P:00023D P:00023D 301000            MOVE              #<NPSKIP,R0
996       P:00023E P:00023E 0D0285            JSR     <PSKIP
997       P:00023F P:00023F 0E8054            JCS     <START
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_rdccd.asm  Page 19



998       P:000240 P:000240 68A600            MOVE                          Y:<AFPXFER2,R0
999       P:000241 P:000241 0D0402            JSR     <CLOCK
1000      P:000242 P:000242 300700            MOVE              #<NSCLEAR,R0
1001      P:000243 P:000243 0D02A9            JSR     <FSSKIP
1002   
1003      P:000244 P:000244 300200            MOVE              #<NPDATA,R0             ; read ROI
1004      P:000245 P:000245 0D025E            JSR     <PDATA
1005      P:000246 P:000246 0E8054            JCS     <START
1006   
1007      P:000247 P:000247 68A500            MOVE                          Y:<AFPXFER0,R0 ; skip to overscan
1008      P:000248 P:000248 0D0402            JSR     <CLOCK
1009      P:000249 P:000249 301100            MOVE              #<NPPOSTSKIP,R0
1010      P:00024A P:00024A 0D0285            JSR     <PSKIP
1011      P:00024B P:00024B 0E8054            JCS     <START
1012      P:00024C P:00024C 68A600            MOVE                          Y:<AFPXFER2,R0
1013      P:00024D P:00024D 0D0402            JSR     <CLOCK
1014      P:00024E P:00024E 300700            MOVE              #<NSCLEAR,R0
1015      P:00024F P:00024F 0D02A9            JSR     <FSSKIP
1016   
1017      P:000250 P:000250 301200            MOVE              #<NPOVERSCAN,R0         ; read parallel overscan
1018      P:000251 P:000251 0D025E            JSR     <PDATA
1019      P:000252 P:000252 0E8054            JCS     <START
1020   
1021                                RDC_END
1022      P:000253 P:000253 0A0082            JCLR    #IDLMODE,X:<STATUS,NO_IDL         ; Don't idle after readout
                            000259
1023      P:000255 P:000255 60F400            MOVE              #IDLE,R0
                            000303
1024      P:000257 P:000257 601F00            MOVE              R0,X:<IDL_ADR
1025      P:000258 P:000258 0C025B            JMP     <RDC_E
1026                                NO_IDL
1027      P:000259 P:000259 305800            MOVE              #<TST_RCV,R0
1028      P:00025A P:00025A 601F00            MOVE              R0,X:<IDL_ADR
1029                                RDC_E
1030      P:00025B P:00025B 0D03FF            JSR     <WAIT_TO_FINISH_CLOCKING
1031      P:00025C P:00025C 0A0004            BCLR    #ST_RDC,X:<STATUS                 ; Set status to not reading out
1032   
1033      P:00025D P:00025D 0C0054            JMP     <START                            ; DONE flag set by PCI when finished
1034   
1035                                ; *******************************************************************
1036                                PDATA
1037      P:00025E P:00025E 0D02D4            JSR     <CNPAMPS                          ; compensate for split register
1038      P:00025F P:00025F 0EF277            JLE     <PDATA0
1039      P:000260 P:000260 06CE00            DO      A,PDATA0                          ; loop through # of binned rows into each se
rial register
                            000276
1040      P:000262 P:000262 300400            MOVE              #<NPBIN,R0              ; shift NPBIN rows into serial register
1041      P:000263 P:000263 0D0278            JSR     <PDSKIP
1042      P:000264 P:000264 0E0267            JCC     <PDATA1
1043      P:000265 P:000265 00008C            ENDDO
1044      P:000266 P:000266 0C0277            JMP     <PDATA0
1045                                PDATA1
1046      P:000267 P:000267 300900            MOVE              #<NSPRESKIP,R0          ; skip to serial underscan
1047      P:000268 P:000268 0D02B1            JSR     <SSKIP
1048      P:000269 P:000269 300A00            MOVE              #<NSUNDERSCAN,R0        ; read underscan
1049      P:00026A P:00026A 0D02BB            JSR     <SDATA
1050      P:00026B P:00026B 300B00            MOVE              #<NSSKIP,R0             ; skip to ROI
1051      P:00026C P:00026C 0D02B1            JSR     <SSKIP
1052      P:00026D P:00026D 300100            MOVE              #<NSDATA,R0             ; read ROI
1053      P:00026E P:00026E 0D02BB            JSR     <SDATA
1054      P:00026F P:00026F 300C00            MOVE              #<NSPOSTSKIP,R0         ; skip to serial overscan
1055      P:000270 P:000270 0D02B1            JSR     <SSKIP
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_rdccd.asm  Page 20



1056      P:000271 P:000271 300D00            MOVE              #<NSOVERSCAN,R0         ; read overscan
1057      P:000272 P:000272 0D02BB            JSR     <SDATA
1058      P:000273 P:000273 0AF940            BCLR    #0,SR                             ; set CC
1059      P:000274 P:000274 000000            NOP
1060      P:000275 P:000275 000000            NOP
1061      P:000276 P:000276 000000            NOP
1062                                PDATA0
1063      P:000277 P:000277 00000C            RTS
1064   
1065                                ; *******************************************************************
1066                                PDSKIP
1067      P:000278 P:000278 5EE000            MOVE                          Y:(R0),A    ; shift data lines into serial reg
1068      P:000279 P:000279 200003            TST     A
1069      P:00027A P:00027A 0EF284            JLE     <PDSKIP0
1070      P:00027B P:00027B 066040            DO      Y:(R0),PDSKIP0
                            000283
1071      P:00027D P:00027D 68A800            MOVE                          Y:<APDXFER,R0
1072      P:00027E P:00027E 0D02DE            JSR     <PCLOCK
1073      P:00027F P:00027F 0D00A3            JSR     <GET_RCV
1074      P:000280 P:000280 0E0283            JCC     <PDSKIP1
1075      P:000281 P:000281 00008C            ENDDO
1076      P:000282 P:000282 000000            NOP
1077                                PDSKIP1
1078      P:000283 P:000283 000000            NOP
1079                                PDSKIP0
1080      P:000284 P:000284 00000C            RTS
1081   
1082                                ; *******************************************************************
1083                                PSKIP
1084      P:000285 P:000285 0D02D4            JSR     <CNPAMPS
1085      P:000286 P:000286 0EF290            JLE     <PSKIP0
1086      P:000287 P:000287 06CE00            DO      A,PSKIP0
                            00028F
1087      P:000289 P:000289 68A700            MOVE                          Y:<APXFER,R0
1088      P:00028A P:00028A 0D02DE            JSR     <PCLOCK
1089      P:00028B P:00028B 0D00A3            JSR     <GET_RCV
1090      P:00028C P:00028C 0E028F            JCC     <PSKIP1
1091      P:00028D P:00028D 00008C            ENDDO
1092      P:00028E P:00028E 000000            NOP
1093                                PSKIP1
1094      P:00028F P:00028F 000000            NOP
1095                                PSKIP0
1096      P:000290 P:000290 00000C            RTS
1097   
1098                                ; *******************************************************************
1099                                PQSKIP
1100      P:000291 P:000291 0D02D4            JSR     <CNPAMPS
1101      P:000292 P:000292 0EF29C            JLE     <PQSKIP0
1102      P:000293 P:000293 06CE00            DO      A,PQSKIP0
                            00029B
1103      P:000295 P:000295 68A900            MOVE                          Y:<APQXFER,R0
1104      P:000296 P:000296 0D02DE            JSR     <PCLOCK
1105      P:000297 P:000297 0D00A3            JSR     <GET_RCV
1106      P:000298 P:000298 0E029B            JCC     <PQSKIP1
1107      P:000299 P:000299 00008C            ENDDO
1108      P:00029A P:00029A 000000            NOP
1109                                PQSKIP1
1110      P:00029B P:00029B 000000            NOP
1111                                PQSKIP0
1112      P:00029C P:00029C 00000C            RTS
1113   
1114                                ; *******************************************************************
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_rdccd.asm  Page 21



1115                                RSKIP
1116      P:00029D P:00029D 0D02D4            JSR     <CNPAMPS
1117      P:00029E P:00029E 0EF2A8            JLE     <RSKIP0
1118      P:00029F P:00029F 06CE00            DO      A,RSKIP0
                            0002A7
1119      P:0002A1 P:0002A1 68AA00            MOVE                          Y:<ARXFER,R0
1120      P:0002A2 P:0002A2 0D02DE            JSR     <PCLOCK
1121      P:0002A3 P:0002A3 0D00A3            JSR     <GET_RCV
1122      P:0002A4 P:0002A4 0E02A7            JCC     <RSKIP1
1123      P:0002A5 P:0002A5 00008C            ENDDO
1124      P:0002A6 P:0002A6 000000            NOP
1125                                RSKIP1
1126      P:0002A7 P:0002A7 000000            NOP
1127                                RSKIP0
1128      P:0002A8 P:0002A8 00000C            RTS
1129   
1130                                ; *******************************************************************
1131                                FSSKIP
1132      P:0002A9 P:0002A9 0D02CE            JSR     <CNSAMPS
1133      P:0002AA P:0002AA 0EF2B0            JLE     <FSSKIP0
1134      P:0002AB P:0002AB 06CE00            DO      A,FSSKIP0
                            0002AF
1135      P:0002AD P:0002AD 68AB00            MOVE                          Y:<AFSXFER,R0
1136      P:0002AE P:0002AE 0D0402            JSR     <CLOCK
1137      P:0002AF P:0002AF 000000            NOP
1138                                FSSKIP0
1139      P:0002B0 P:0002B0 00000C            RTS
1140   
1141                                ; *******************************************************************
1142                                SSKIP
1143      P:0002B1 P:0002B1 0D02CE            JSR     <CNSAMPS
1144      P:0002B2 P:0002B2 0EF2BA            JLE     <SSKIP0
1145      P:0002B3 P:0002B3 06CE00            DO      A,SSKIP0
                            0002B9
1146      P:0002B5 P:0002B5 68AC00            MOVE                          Y:<ASXFER0,R0
1147      P:0002B6 P:0002B6 0D0402            JSR     <CLOCK
1148      P:0002B7 P:0002B7 68AE00            MOVE                          Y:<ASXFER2,R0
1149      P:0002B8 P:0002B8 0D0402            JSR     <CLOCK
1150      P:0002B9 P:0002B9 000000            NOP
1151                                SSKIP0
1152      P:0002BA P:0002BA 00000C            RTS
1153   
1154                                ; *******************************************************************
1155                                SDATA
1156      P:0002BB P:0002BB 0D02CE            JSR     <CNSAMPS
1157      P:0002BC P:0002BC 0EF2CD            JLE     <SDATA0
1158      P:0002BD P:0002BD 06CE00            DO      A,SDATA0
                            0002CC
1159      P:0002BF P:0002BF 68AC00            MOVE                          Y:<ASXFER0,R0
1160      P:0002C0 P:0002C0 0D0402            JSR     <CLOCK
1161      P:0002C1 P:0002C1 449200            MOVE              X:<ONE,X0               ; Get bin-1
1162      P:0002C2 P:0002C2 5E8300            MOVE                          Y:<NSBIN,A
1163      P:0002C3 P:0002C3 200044            SUB     X0,A
1164      P:0002C4 P:0002C4 0EF2CA            JLE     <SDATA1
1165      P:0002C5 P:0002C5 06CE00            DO      A,SDATA1
                            0002C9
1166      P:0002C7 P:0002C7 68AD00            MOVE                          Y:<ASXFER1,R0
1167      P:0002C8 P:0002C8 0D0402            JSR     <CLOCK
1168      P:0002C9 P:0002C9 000000            NOP
1169                                SDATA1
1170      P:0002CA P:0002CA 68AF00            MOVE                          Y:<ASXFER2D,R0
1171      P:0002CB P:0002CB 0D0402            JSR     <CLOCK
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_rdccd.asm  Page 22



1172                                SDATA0T
1173      P:0002CC P:0002CC 000000            NOP
1174                                SDATA0
1175      P:0002CD P:0002CD 00000C            RTS
1176   
1177                                ; *******************************************************************
1178                                ; Compensate count for split serial
1179      P:0002CE P:0002CE 5EE000  CNSAMPS   MOVE                          Y:(R0),A    ; get num pixels to read
1180      P:0002CF P:0002CF 0A05C0            JCLR    #0,Y:<NSAMPS,CNSAMP1              ; split register?
                            0002D2
1181      P:0002D1 P:0002D1 200022            ASR     A                                 ; yes, divide by 2
1182      P:0002D2 P:0002D2 200003  CNSAMP1   TST     A
1183      P:0002D3 P:0002D3 00000C            RTS
1184   
1185                                ; *******************************************************************
1186                                ; Compensate count for split parallel
1187      P:0002D4 P:0002D4 5EE000  CNPAMPS   MOVE                          Y:(R0),A    ; get num rows to shift
1188      P:0002D5 P:0002D5 0A06C0            JCLR    #0,Y:<NPAMPS,CNPAMP1              ; split parallels?
                            0002D8
1189      P:0002D7 P:0002D7 200022            ASR     A                                 ; yes, divide by 2
1190      P:0002D8 P:0002D8 200003  CNPAMP1   TST     A
1191      P:0002D9 P:0002D9 000000            NOP                                       ; MPL for Gen3
1192      P:0002DA P:0002DA 000000            NOP                                       ; MPL for Gen3
1193      P:0002DB P:0002DB 0AF940            BCLR    #0,SR                             ; clear carry
1194      P:0002DC P:0002DC 000000            NOP                                       ; MPL for Gen3
1195      P:0002DD P:0002DD 00000C            RTS
1196   
1197                                ; *******************************************************************
1198                                ; slow clock for parallel shifts - Gen3 version
1199                                PCLOCK
1200      P:0002DE P:0002DE 0A898E            JCLR    #SSFHF,X:HDR,*                    ; Only write to FIFO if < half full
                            0002DE
1201      P:0002E0 P:0002E0 000000            NOP
1202      P:0002E1 P:0002E1 0A898E            JCLR    #SSFHF,X:HDR,PCLOCK               ; Guard against metastability
                            0002DE
1203      P:0002E3 P:0002E3 4CD800            MOVE                          Y:(R0)+,X0  ; # of waveform entries
1204      P:0002E4 P:0002E4 06C400            DO      X0,PCLK1                          ; Repeat X0 times
                            0002EA
1205      P:0002E6 P:0002E6 5ED800            MOVE                          Y:(R0)+,A   ; get waveform
1206      P:0002E7 P:0002E7 062040            DO      Y:<PMULT,PCLK2
                            0002E9
1207      P:0002E9 P:0002E9 09CE33            MOVEP             A,Y:WRSS                ; 30 nsec write the waveform to the SS
1208      P:0002EA P:0002EA 000000  PCLK2     NOP
1209      P:0002EB P:0002EB 000000  PCLK1     NOP
1210      P:0002EC P:0002EC 00000C            RTS                                       ; Return from subroutine
1211   
1212                                ; *******************************************************************
1213      P:0002ED P:0002ED 0D02EF  CLEAR     JSR     <CLR_CCD                          ; clear CCD, executed as a command
1214      P:0002EE P:0002EE 0C008D            JMP     <FINISH
1215   
1216                                ; *******************************************************************
1217                                CLR_CCD
1218      P:0002EF P:0002EF 68A500            MOVE                          Y:<AFPXFER0,R0 ; prep for fast flush
1219      P:0002F0 P:0002F0 0D0402            JSR     <CLOCK
1220      P:0002F1 P:0002F1 300800            MOVE              #<NPCLEAR,R0            ; shift all rows
1221      P:0002F2 P:0002F2 0D0291            JSR     <PQSKIP
1222      P:0002F3 P:0002F3 68A600            MOVE                          Y:<AFPXFER2,R0 ; set clocks on clear exit
1223      P:0002F4 P:0002F4 0D0402            JSR     <CLOCK
1224      P:0002F5 P:0002F5 300700            MOVE              #<NSCLEAR,R0            ; flush serial register
1225      P:0002F6 P:0002F6 0D02A9            JSR     <FSSKIP
1226      P:0002F7 P:0002F7 00000C            RTS
1227   
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_rdccd.asm  Page 23



1228                                ; *******************************************************************
1229                                FOR_PSHIFT
1230      P:0002F8 P:0002F8 301300            MOVE              #<NPXSHIFT,R0           ; forward shift rows
1231      P:0002F9 P:0002F9 0D0285            JSR     <PSKIP
1232      P:0002FA P:0002FA 0C008D            JMP     <FINISH
1233   
1234                                ; *******************************************************************
1235                                REV_PSHIFT
1236      P:0002FB P:0002FB 301300            MOVE              #<NPXSHIFT,R0           ; reverse shift rows
1237      P:0002FC P:0002FC 0D029D            JSR     <RSKIP
1238      P:0002FD P:0002FD 0C008D            JMP     <FINISH
1239   
1240                                ; *******************************************************************
1241                                ; Set software to IDLE mode
1242                                START_IDLE_CLOCKING
1243      P:0002FE P:0002FE 60F400            MOVE              #IDLE,R0                ; Exercise clocks when idling
                            000303
1244      P:000300 P:000300 601F00            MOVE              R0,X:<IDL_ADR
1245      P:000301 P:000301 0A0022            BSET    #IDLMODE,X:<STATUS                ; Idle after readout
1246      P:000302 P:000302 0C008D            JMP     <FINISH                           ; Need to send header and 'DON'
1247   
1248                                ; Keep the CCD idling when not reading out - MPL modified for AzCam
1249      P:000303 P:000303 060740  IDLE      DO      Y:<NSCLEAR,IDL1                   ; Loop over number of pixels per line
                            00030C
1250      P:000305 P:000305 68AB00            MOVE                          Y:<AFSXFER,R0 ; Serial transfer on pixel
1251      P:000306 P:000306 0D0402            JSR     <CLOCK                            ; Go to it
1252      P:000307 P:000307 330700            MOVE              #COM_BUF,R3
1253      P:000308 P:000308 0D00A3            JSR     <GET_RCV                          ; Check for FO or SSI commands
1254      P:000309 P:000309 0E030C            JCC     <NO_COM                           ; Continue IDLE if no commands received
1255      P:00030A P:00030A 00008C            ENDDO
1256      P:00030B P:00030B 0C005B            JMP     <PRC_RCV                          ; Go process header and command
1257      P:00030C P:00030C 000000  NO_COM    NOP
1258                                IDL1
1259      P:00030D P:00030D 68A900            MOVE                          Y:<APQXFER,R0 ; Address of parallel clocking waveform
1260      P:00030E P:00030E 0D0402            JSR     <CLOCK                            ; Go clock out the CCD charge
1261                                ;       JSR     <PCLOCK                 ; Go clock out the CCD charge
1262      P:00030F P:00030F 0C0303            JMP     <IDLE
1263   
1264                                ; *** include misc routines ***
1265                                          INCLUDE "tim3_misc.asm"
1266                                ; Miscellaneous control routines
1267                                ; This is the GEN3 AzCam version developed first for 90Prime
1268                                ; Requires a call to CLR before calling SEX.
1269                                ; last change 20Aug04 by Michael Lesser
1270   
1271                                ; Routines contained in this file are:
1272   
1273                                ; POWER_OFF
1274                                ; POWER_ON
1275                                ; SET_BIASES
1276                                ; CLR_SWS
1277                                ; CLEAR_SWITCHES_AND_DACS
1278                                ; OPEN_SHUTTER
1279                                ; CLOSE_SHUTTER
1280                                ; OSHUT
1281                                ; CSHUT
1282                                ; EXPOSE
1283                                ; START_EXPOSURE
1284                                ; SET_EXPOSURE_TIME
1285                                ; READ_EXPOSURE_TIME
1286                                ; PAUSE_EXPOSURE
1287                                ; RESUME_EXPOSURE
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 24



1288                                ; ABORT_ALL
1289                                ; SYNTHETIC_IMAGE
1290                                ; XMT_PIX
1291                                ; READ_AD
1292                                ; PCI_READ_IMAGE
1293                                ; WAIT_TO_FINISH_CLOCKING
1294                                ; CLOCK
1295                                ; PAL_DLY
1296                                ; TEST_XMIT
1297                                ; READ_CONTROLLER_CONFIGURATION
1298                                ; ST_GAIN
1299                                ; SET_DC
1300                                ; SET_BIAS_NUMBER
1301                                ;
1302   
1303                                ; *******************************************************************
1304                                POWER_OFF
1305      P:000310 P:000310 0D0346            JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1306      P:000311 P:000311 0A8922            BSET    #LVEN,X:HDR
1307      P:000312 P:000312 0A8923            BSET    #HVEN,X:HDR
1308      P:000313 P:000313 0C008D            JMP     <FINISH
1309   
1310                                ; *******************************************************************
1311                                ; Execute the power-on cycle, as a command
1312                                POWER_ON
1313      P:000314 P:000314 0D0346            JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1314   
1315                                ; Turn on the low voltages (+/- 6.5V, +/- 16.5V) and delay
1316      P:000315 P:000315 0A8902            BCLR    #LVEN,X:HDR                       ; Set these signals to DSP outputs
1317      P:000316 P:000316 44F400            MOVE              #2000000,X0
                            1E8480
1318      P:000318 P:000318 06C400            DO      X0,*+3                            ; Wait 20 millisec for settling
                            00031A
1319      P:00031A P:00031A 000000            NOP
1320   
1321                                ; Turn on the high +36 volt power line and delay
1322      P:00031B P:00031B 0A8903            BCLR    #HVEN,X:HDR                       ; HVEN = Low => Turn on +36V
1323      P:00031C P:00031C 44F400            MOVE              #2000000,X0
                            1E8480
1324      P:00031E P:00031E 06C400            DO      X0,*+3                            ; Wait 20 millisec for settling
                            000320
1325      P:000320 P:000320 000000            NOP
1326   
1327      P:000321 P:000321 0A8980            JCLR    #PWROK,X:HDR,PWR_ERR              ; Test if the power turned on properly
                            000328
1328      P:000323 P:000323 0D032D            JSR     <SET_BIASES                       ; Turn on the DC bias supplies
1329      P:000324 P:000324 60F400            MOVE              #IDLE,R0                ; Put controller in IDLE state
                            000303
1330      P:000326 P:000326 601F00            MOVE              R0,X:<IDL_ADR
1331      P:000327 P:000327 0C008D            JMP     <FINISH
1332   
1333                                ; The power failed to turn on because of an error on the power control board
1334      P:000328 P:000328 0A8922  PWR_ERR   BSET    #LVEN,X:HDR                       ; Turn off the low voltage emable line
1335      P:000329 P:000329 0A8923            BSET    #HVEN,X:HDR                       ; Turn off the high voltage emable line
1336      P:00032A P:00032A 0C008B            JMP     <ERROR
1337   
1338                                ; *******************************************************************
1339                                SET_BIAS_VOLTAGES
1340      P:00032B P:00032B 0D032D            JSR     <SET_BIASES
1341      P:00032C P:00032C 0C008D            JMP     <FINISH
1342   
1343                                ; Set all the DC bias voltages and video processor offset values, reading
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 25



1344                                ;   them from the 'DACS' table
1345                                SET_BIASES
1346      P:00032D P:00032D 012F23            BSET    #3,X:PCRD                         ; Turn on the serial clock
1347      P:00032E P:00032E 0A0F01            BCLR    #1,X:<LATCH                       ; Separate updates of clock driver
1348      P:00032F P:00032F 0A0F20            BSET    #CDAC,X:<LATCH                    ; Disable clearing of DACs
1349      P:000330 P:000330 0A0F22            BSET    #ENCK,X:<LATCH                    ; Enable clock and DAC output switches
1350      P:000331 P:000331 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1351      P:000333 P:000333 0D040D            JSR     <PAL_DLY                          ; Delay for all this to happen
1352   
1353                                ; Read DAC values from a table, and write them to the DACs
1354                                ;       MOVE    #DACS,R0                ; Get starting address of DAC values
1355      P:000334 P:000334 68B000            MOVE                          Y:<ADACS,R0 ; MPL
1356      P:000335 P:000335 000000            NOP
1357      P:000336 P:000336 000000            NOP
1358      P:000337 P:000337 000000            NOP
1359      P:000338 P:000338 065840            DO      Y:(R0)+,L_DAC                     ; Repeat Y:(R0)+ times
                            00033C
1360      P:00033A P:00033A 5ED800            MOVE                          Y:(R0)+,A   ; Read the table entry
1361      P:00033B P:00033B 0D020A            JSR     <XMIT_A_WORD                      ; Transmit it to TIM-A-STD
1362      P:00033C P:00033C 000000            NOP
1363                                L_DAC
1364   
1365                                ; Let the DAC voltages all ramp up before exiting
1366      P:00033D P:00033D 44F400            MOVE              #400000,X0
                            061A80
1367      P:00033F P:00033F 06C400            DO      X0,*+3                            ; 4 millisec delay
                            000341
1368      P:000341 P:000341 000000            NOP
1369      P:000342 P:000342 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1370      P:000343 P:000343 00000C            RTS
1371   
1372                                ; *******************************************************************
1373      P:000344 P:000344 0D0346  CLR_SWS   JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1374      P:000345 P:000345 0C008D            JMP     <FINISH
1375   
1376                                CLEAR_SWITCHES_AND_DACS
1377      P:000346 P:000346 0A0F00            BCLR    #CDAC,X:<LATCH                    ; Clear all the DACs
1378      P:000347 P:000347 0A0F02            BCLR    #ENCK,X:<LATCH                    ; Disable all the output switches
1379      P:000348 P:000348 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1380      P:00034A P:00034A 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
1381      P:00034B P:00034B 56F400            MOVE              #$0C3000,A              ; Value of integrate speed and gain switches
                            0C3000
1382      P:00034D P:00034D 20001B            CLR     B
1383      P:00034E P:00034E 241000            MOVE              #$100000,X0             ; Increment over board numbers for DAC write
s
1384      P:00034F P:00034F 45F400            MOVE              #$001000,X1             ; Increment over board numbers for WRSS writ
es
                            001000
1385      P:000351 P:000351 060F80            DO      #15,L_VIDEO                       ; Fifteen video processor boards maximum
                            000358
1386      P:000353 P:000353 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1387      P:000354 P:000354 200040            ADD     X0,A
1388      P:000355 P:000355 5F7000            MOVE                          B,Y:WRSS
                            FFFFF3
1389      P:000357 P:000357 0D040D            JSR     <PAL_DLY                          ; Delay for the serial data transmission
1390      P:000358 P:000358 200068            ADD     X1,B
1391                                L_VIDEO
1392      P:000359 P:000359 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1393      P:00035A P:00035A 00000C            RTS
1394   
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 26



1395                                ; *******************************************************************
1396                                ; Open the shutter by setting the backplane bit TIM-LATCH0
1397      P:00035B P:00035B 0A0023  OSHUT     BSET    #ST_SHUT,X:<STATUS                ; Set status bit to mean shutter open
1398      P:00035C P:00035C 0A0F04            BCLR    #SHUTTER,X:<LATCH                 ; Clear hardware shutter bit to open
1399      P:00035D P:00035D 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1400      P:00035F P:00035F 00000C            RTS
1401   
1402                                ; *******************************************************************
1403                                ; Close the shutter by clearing the backplane bit TIM-LATCH0
1404      P:000360 P:000360 0A0003  CSHUT     BCLR    #ST_SHUT,X:<STATUS                ; Clear status to mean shutter closed
1405      P:000361 P:000361 0A0F24            BSET    #SHUTTER,X:<LATCH                 ; Set hardware shutter bit to close
1406      P:000362 P:000362 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1407      P:000364 P:000364 00000C            RTS
1408   
1409                                ; *******************************************************************
1410                                ; Open the shutter from the timing board, executed as a command
1411                                OPEN_SHUTTER
1412      P:000365 P:000365 0D035B            JSR     <OSHUT
1413      P:000366 P:000366 0C008D            JMP     <FINISH
1414   
1415                                ; *******************************************************************
1416                                ; Close the shutter from the timing board, executed as a command
1417                                CLOSE_SHUTTER
1418      P:000367 P:000367 0D0360            JSR     <CSHUT
1419      P:000368 P:000368 0C008D            JMP     <FINISH
1420   
1421                                ; *******************************************************************
1422                                ; Start the exposure timer and monitor its progress
1423      P:000369 P:000369 579000  EXPOSE    MOVE              X:<EXPOSURE_TIME,B
1424      P:00036A P:00036A 20000B            TST     B                                 ; Special test for zero exposure time
1425      P:00036B P:00036B 0EA37B            JEQ     <END_EXP                          ; Don't even start an exposure
1426      P:00036C P:00036C 01418C            SUB     #1,B                              ; Timer counts from X:TCPR0+1 to zero
1427      P:00036D P:00036D 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Enable the timer #0
1428      P:00036E P:00036E 577000            MOVE              B,X:TCPR0
                            FFFF8D
1429      P:000370 P:000370 330700  CHK_RCV   MOVE              #COM_BUF,R3             ; The beginning of the command buffer
1430      P:000371 P:000371 0A8989            JCLR    #EF,X:HDR,EXP1                    ; Simple test for fast execution
                            000375
1431      P:000373 P:000373 0D00A3            JSR     <GET_RCV                          ; Check for an incoming command
1432      P:000374 P:000374 0E805B            JCS     <PRC_RCV                          ; If command is received, go check it
1433      P:000375 P:000375 0A008C  EXP1      JCLR    #ST_DITH,X:STATUS,CHK_TIM
                            000379
1434      P:000377 P:000377 68AB00            MOVE                          Y:<AFSXFER,R0
1435      P:000378 P:000378 0D0402            JSR     <CLOCK
1436      P:000379 P:000379 018F95  CHK_TIM   JCLR    #TCF,X:TCSR0,CHK_RCV              ; Wait for timer to equal compare value
                            000370
1437      P:00037B P:00037B 010F00  END_EXP   BCLR    #TIM_BIT,X:TCSR0                  ; Disable the timer
1438      P:00037C P:00037C 0AE780            JMP     (R7)                              ; This contains the return address
1439   
1440                                ; *******************************************************************
1441                                ; Start the exposure, operate the shutter, and initiate CCD readout
1442                                START_EXPOSURE
1443      P:00037D P:00037D 57F400            MOVE              #$020102,B
                            020102
1444      P:00037F P:00037F 0D00E9            JSR     <XMT_WRD
1445      P:000380 P:000380 57F400            MOVE              #'IIA',B                ; responds to host with DON
                            494941
1446      P:000382 P:000382 0D00E9            JSR     <XMT_WRD                          ;  indicating exposure started
1447   
1448      P:000383 P:000383 305800            MOVE              #<TST_RCV,R0            ; Process commands, don't idle,
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 27



1449      P:000384 P:000384 601F00            MOVE              R0,X:<IDL_ADR           ;  during the exposure
1450      P:000385 P:000385 0A008B            JCLR    #SHUT,X:STATUS,L_SEX0
                            000388
1451      P:000387 P:000387 0D035B            JSR     <OSHUT                            ; Open the shutter if needed
1452      P:000388 P:000388 67F400  L_SEX0    MOVE              #L_SEX1,R7              ; Return address at end of exposure
                            00038B
1453      P:00038A P:00038A 0C0369            JMP     <EXPOSE                           ; Delay for specified exposure time
1454                                L_SEX1
1455      P:00038B P:00038B 0A008B            JCLR    #SHUT,X:STATUS,S_DEL0
                            000398
1456      P:00038D P:00038D 0D0360            JSR     <CSHUT                            ; Close the shutter if necessary
1457   
1458                                ; shutter delay
1459      P:00038E P:00038E 5E9900            MOVE                          Y:<SH_DEL,A
1460      P:00038F P:00038F 200003            TST     A
1461      P:000390 P:000390 0EF398            JLE     <S_DEL0
1462      P:000391 P:000391 449E00            MOVE              X:<C100K,X0             ; assume 100 MHz DSP
1463      P:000392 P:000392 06CE00            DO      A,S_DEL0                          ; Delay by Y:SH_DEL milliseconds
                            000397
1464      P:000394 P:000394 06C400            DO      X0,S_DEL1
                            000396
1465      P:000396 P:000396 000000            NOP
1466      P:000397 P:000397 000000  S_DEL1    NOP
1467      P:000398 P:000398 000000  S_DEL0    NOP
1468   
1469      P:000399 P:000399 0C0054            JMP     <START                            ;
1470   
1471                                ; *******************************************************************
1472                                ; Set the desired exposure time
1473                                SET_EXPOSURE_TIME
1474      P:00039A P:00039A 46DB00            MOVE              X:(R3)+,Y0
1475      P:00039B P:00039B 461000            MOVE              Y0,X:EXPOSURE_TIME
1476      P:00039C P:00039C 07F00D            MOVEP             X:EXPOSURE_TIME,X:TCPR0
                            000010
1477      P:00039E P:00039E 0C008D            JMP     <FINISH
1478   
1479                                ; *******************************************************************
1480                                ; Read the time remaining until the exposure ends
1481                                READ_EXPOSURE_TIME
1482      P:00039F P:00039F 47F000            MOVE              X:TCR0,Y1               ; Read elapsed exposure time
                            FFFF8C
1483      P:0003A1 P:0003A1 0C008E            JMP     <FINISH1
1484   
1485                                ; *******************************************************************
1486                                ; Pause the exposure - close the shutter, and stop the timer
1487                                PAUSE_EXPOSURE
1488      P:0003A2 P:0003A2 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the DSP exposure timer
1489      P:0003A3 P:0003A3 0D0360            JSR     <CSHUT                            ; Close the shutter
1490      P:0003A4 P:0003A4 0C008D            JMP     <FINISH
1491   
1492                                ; *******************************************************************
1493                                ; Resume the exposure - open the shutter if needed and restart the timer
1494                                RESUME_EXPOSURE
1495      P:0003A5 P:0003A5 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Re-enable the DSP exposure timer
1496      P:0003A6 P:0003A6 0A008B            JCLR    #SHUT,X:STATUS,L_RES
                            0003A9
1497      P:0003A8 P:0003A8 0D035B            JSR     <OSHUT                            ; Open the shutter ir necessary
1498      P:0003A9 P:0003A9 0C008D  L_RES     JMP     <FINISH
1499   
1500                                ; *******************************************************************
1501                                ; Special ending after abort command to send a 'DON' to the host computer
1502                                ABORT_ALL
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 28



1503      P:0003AA P:0003AA 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the DSP exposure timer
1504      P:0003AB P:0003AB 0D0360            JSR     <CSHUT                            ; Close the shutter
1505      P:0003AC P:0003AC 44F400            MOVE              #100000,X0
                            0186A0
1506      P:0003AE P:0003AE 06C400            DO      X0,L_WAIT0                        ; Wait one millisecond to delimit
                            0003B0
1507      P:0003B0 P:0003B0 000000            NOP                                       ;   image data and the 'DON' reply
1508                                L_WAIT0
1509      P:0003B1 P:0003B1 0A0082            JCLR    #IDLMODE,X:<STATUS,NO_IDL2        ; Don't idle after readout
                            0003B7
1510      P:0003B3 P:0003B3 60F400            MOVE              #IDLE,R0
                            000303
1511      P:0003B5 P:0003B5 601F00            MOVE              R0,X:<IDL_ADR
1512      P:0003B6 P:0003B6 0C03B9            JMP     <RDC_E2
1513      P:0003B7 P:0003B7 305800  NO_IDL2   MOVE              #<TST_RCV,R0
1514      P:0003B8 P:0003B8 601F00            MOVE              R0,X:<IDL_ADR
1515      P:0003B9 P:0003B9 0D03FF  RDC_E2    JSR     <WAIT_TO_FINISH_CLOCKING
1516      P:0003BA P:0003BA 0A0004            BCLR    #ST_RDC,X:<STATUS                 ; Set status to not reading out
1517   
1518      P:0003BB P:0003BB 44F400            MOVE              #$000202,X0             ; Send 'DON' to the host computer
                            000202
1519      P:0003BD P:0003BD 440500            MOVE              X0,X:<HEADER
1520      P:0003BE P:0003BE 0C008D            JMP     <FINISH
1521   
1522                                ; *******************************************************************
1523                                ; Generate a synthetic image by simply incrementing the pixel counts
1524                                SYNTHETIC_IMAGE
1525      P:0003BF P:0003BF 200013            CLR     A
1526                                ;       DO      Y:<NPR,LPR_TST          ; Loop over each line readout
1527                                ;       DO      Y:<NSR,LSR_TST          ; Loop over number of pixels per line
1528      P:0003C0 P:0003C0 061C40            DO      Y:<NPIMAGE,LPR_TST                ; Loop over each line readout
                            0003CB
1529      P:0003C2 P:0003C2 061B40            DO      Y:<NSIMAGE,LSR_TST                ; Loop over number of pixels per line
                            0003CA
1530      P:0003C4 P:0003C4 0614A0            REP     #20                               ; #20 => 1.0 microsec per pixel
1531      P:0003C5 P:0003C5 000000            NOP
1532      P:0003C6 P:0003C6 014180            ADD     #1,A                              ; Pixel data = Pixel data + 1
1533      P:0003C7 P:0003C7 000000            NOP
1534      P:0003C8 P:0003C8 21CF00            MOVE              A,B
1535      P:0003C9 P:0003C9 0D03CD            JSR     <XMT_PIX                          ;  transmit them
1536      P:0003CA P:0003CA 000000            NOP
1537                                LSR_TST
1538      P:0003CB P:0003CB 000000            NOP
1539                                LPR_TST
1540      P:0003CC P:0003CC 0C0253            JMP     <RDC_END                          ; Normal exit
1541   
1542                                ; *******************************************************************
1543                                ; Transmit the 16-bit pixel datum in B1 to the host computer
1544      P:0003CD P:0003CD 0C1DA1  XMT_PIX   ASL     #16,B,B
1545      P:0003CE P:0003CE 000000            NOP
1546      P:0003CF P:0003CF 216500            MOVE              B2,X1
1547      P:0003D0 P:0003D0 0C1D91            ASL     #8,B,B
1548      P:0003D1 P:0003D1 000000            NOP
1549      P:0003D2 P:0003D2 216400            MOVE              B2,X0
1550      P:0003D3 P:0003D3 000000            NOP
1551      P:0003D4 P:0003D4 09C532            MOVEP             X1,Y:WRFO
1552      P:0003D5 P:0003D5 09C432            MOVEP             X0,Y:WRFO
1553      P:0003D6 P:0003D6 00000C            RTS
1554   
1555                                ; *******************************************************************
1556                                ; Test the hardware to read A/D values directly into the DSP instead
1557                                ;   of using the SXMIT option, A/Ds #2 and 3.
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 29



1558      P:0003D7 P:0003D7 57F000  READ_AD   MOVE              X:(RDAD+2),B
                            010002
1559      P:0003D9 P:0003D9 0C1DA1            ASL     #16,B,B
1560      P:0003DA P:0003DA 000000            NOP
1561      P:0003DB P:0003DB 216500            MOVE              B2,X1
1562      P:0003DC P:0003DC 0C1D91            ASL     #8,B,B
1563      P:0003DD P:0003DD 000000            NOP
1564      P:0003DE P:0003DE 216400            MOVE              B2,X0
1565      P:0003DF P:0003DF 000000            NOP
1566      P:0003E0 P:0003E0 09C532            MOVEP             X1,Y:WRFO
1567      P:0003E1 P:0003E1 09C432            MOVEP             X0,Y:WRFO
1568      P:0003E2 P:0003E2 060AA0            REP     #10
1569      P:0003E3 P:0003E3 000000            NOP
1570      P:0003E4 P:0003E4 57F000            MOVE              X:(RDAD+3),B
                            010003
1571      P:0003E6 P:0003E6 0C1DA1            ASL     #16,B,B
1572      P:0003E7 P:0003E7 000000            NOP
1573      P:0003E8 P:0003E8 216500            MOVE              B2,X1
1574      P:0003E9 P:0003E9 0C1D91            ASL     #8,B,B
1575      P:0003EA P:0003EA 000000            NOP
1576      P:0003EB P:0003EB 216400            MOVE              B2,X0
1577      P:0003EC P:0003EC 000000            NOP
1578      P:0003ED P:0003ED 09C532            MOVEP             X1,Y:WRFO
1579      P:0003EE P:0003EE 09C432            MOVEP             X0,Y:WRFO
1580      P:0003EF P:0003EF 060AA0            REP     #10
1581      P:0003F0 P:0003F0 000000            NOP
1582      P:0003F1 P:0003F1 00000C            RTS
1583   
1584                                ; *******************************************************************
1585                                ; Alert the PCI interface board that images are coming soon
1586                                PCI_READ_IMAGE
1587      P:0003F2 P:0003F2 57F400            MOVE              #$020104,B              ; Send header word to the FO transmitter
                            020104
1588      P:0003F4 P:0003F4 0D00E9            JSR     <XMT_WRD
1589      P:0003F5 P:0003F5 57F400            MOVE              #'RDA',B
                            524441
1590      P:0003F7 P:0003F7 0D00E9            JSR     <XMT_WRD
1591                                ;       MOVE    Y:NSR,B                 ; Number of columns to read
1592      P:0003F8 P:0003F8 5FF000            MOVE                          Y:NSIMAGE,B ; Number of columns to read
                            00001B
1593      P:0003FA P:0003FA 0D00E9            JSR     <XMT_WRD
1594                                ;       MOVE    Y:NPR,B                 ; Number of rows to read
1595      P:0003FB P:0003FB 5FF000            MOVE                          Y:NPIMAGE,B ; Number of columns to read
                            00001C
1596      P:0003FD P:0003FD 0D00E9            JSR     <XMT_WRD
1597      P:0003FE P:0003FE 00000C            RTS
1598   
1599                                ; *******************************************************************
1600                                ; Wait for the clocking to be complete before proceeding
1601                                WAIT_TO_FINISH_CLOCKING
1602      P:0003FF P:0003FF 01ADA1            JSET    #SSFEF,X:PDRD,*                   ; Wait for the SS FIFO to be empty
                            0003FF
1603      P:000401 P:000401 00000C            RTS
1604   
1605                                ; *******************************************************************
1606                                ; This MOVEP instruction executes in 30 nanosec, 20 nanosec for the MOVEP,
1607                                ;   and 10 nanosec for the wait state that is required for SRAM writes and
1608                                ;   FIFO setup times. It looks reliable, so will be used for now.
1609   
1610                                ; Core subroutine for clocking out CCD charge
1611                                CLOCK
1612      P:000402 P:000402 0A898E            JCLR    #SSFHF,X:HDR,*                    ; Only write to FIFO if < half full
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 30



                            000402
1613      P:000404 P:000404 000000            NOP
1614      P:000405 P:000405 0A898E            JCLR    #SSFHF,X:HDR,CLOCK                ; Guard against metastability
                            000402
1615      P:000407 P:000407 4CD800            MOVE                          Y:(R0)+,X0  ; # of waveform entries
1616      P:000408 P:000408 06C400            DO      X0,CLK1                           ; Repeat X0 times
                            00040A
1617      P:00040A P:00040A 09D8F3            MOVEP             Y:(R0)+,Y:WRSS          ; 30 nsec Write the waveform to the SS
1618                                CLK1
1619      P:00040B P:00040B 000000            NOP
1620      P:00040C P:00040C 00000C            RTS                                       ; Return from subroutine
1621   
1622                                ; *******************************************************************
1623                                ; Work on later !!!
1624                                ; This will execute in 20 nanosec, 10 nanosec for the MOVE and 10 nanosec
1625                                ;   the one wait state that is required for SRAM writes and FIFO setup times.
1626                                ;   However, the assembler gives a WARNING about pipeline problems if its
1627                                ;   put in a DO loop. This problem needs to be resolved later, and in the
1628                                ;   meantime I'll be using the MOVEP instruction.
1629   
1630                                ;       MOVE    #$FFFF03,R6             ; Write switch states, X:(R6)
1631                                ;       MOVE    Y:(R0)+,A  A,X:(R6)
1632   
1633                                ; Delay for serial writes to the PALs and DACs by 8 microsec
1634      P:00040D P:00040D 062083  PAL_DLY   DO      #800,DLY                          ; Wait 8 usec for serial data transmission
                            00040F
1635      P:00040F P:00040F 000000            NOP
1636      P:000410 P:000410 000000  DLY       NOP
1637      P:000411 P:000411 00000C            RTS
1638   
1639                                ; *******************************************************************
1640                                ; Test the analog serial word transmitter
1641                                TEST_XMIT
1642      P:000412 P:000412 56DB00            MOVE              X:(R3)+,A
1643      P:000413 P:000413 0D020A            JSR     <XMIT_A_WORD
1644      P:000414 P:000414 0C008D            JMP     <FINISH
1645   
1646                                ; *******************************************************************
1647                                ; Let the host computer read the controller configuration
1648                                READ_CONTROLLER_CONFIGURATION
1649      P:000415 P:000415 4F9A00            MOVE                          Y:<CONFIG,Y1 ; Just transmit the configuration
1650      P:000416 P:000416 0C008E            JMP     <FINISH1
1651   
1652                                ; *******************************************************************
1653                                ; Set the video processor gain and integrator speed for all video boards
1654                                ;  Command syntax is  SGN  #GAIN #SPEED,        #GAIN = 1, 2, 5 or 10
1655                                ;                                                       #SPEED = 0 for slow, 1 for fast
1656      P:000417 P:000417 012F23  ST_GAIN   BSET    #3,X:PCRD                         ; Turn the serial clock on
1657      P:000418 P:000418 56DB00            MOVE              X:(R3)+,A               ; Gain value (1,2,5 or 10)
1658      P:000419 P:000419 44F400            MOVE              #>1,X0
                            000001
1659      P:00041B P:00041B 200045            CMP     X0,A                              ; Check for gain = x1
1660      P:00041C P:00041C 0E2420            JNE     <STG2
1661      P:00041D P:00041D 57F400            MOVE              #>$77,B
                            000077
1662      P:00041F P:00041F 0C0434            JMP     <STG_A
1663      P:000420 P:000420 44F400  STG2      MOVE              #>2,X0                  ; Check for gain = x2
                            000002
1664      P:000422 P:000422 200045            CMP     X0,A
1665      P:000423 P:000423 0E2427            JNE     <STG5
1666      P:000424 P:000424 57F400            MOVE              #>$BB,B
                            0000BB
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 31



1667      P:000426 P:000426 0C0434            JMP     <STG_A
1668      P:000427 P:000427 44F400  STG5      MOVE              #>5,X0                  ; Check for gain = x5
                            000005
1669      P:000429 P:000429 200045            CMP     X0,A
1670      P:00042A P:00042A 0E242E            JNE     <STG10
1671      P:00042B P:00042B 57F400            MOVE              #>$DD,B
                            0000DD
1672      P:00042D P:00042D 0C0434            JMP     <STG_A
1673      P:00042E P:00042E 44F400  STG10     MOVE              #>10,X0                 ; Check for gain = x10
                            00000A
1674      P:000430 P:000430 200045            CMP     X0,A
1675      P:000431 P:000431 0E208B            JNE     <ERROR
1676      P:000432 P:000432 57F400            MOVE              #>$EE,B
                            0000EE
1677   
1678      P:000434 P:000434 56DB00  STG_A     MOVE              X:(R3)+,A               ; Integrator Speed (0 for slow, 1 for fast)
1679      P:000435 P:000435 000000            NOP
1680      P:000436 P:000436 0ACC00            JCLR    #0,A1,STG_B
                            00043B
1681      P:000438 P:000438 0ACD68            BSET    #8,B1
1682      P:000439 P:000439 000000            NOP
1683      P:00043A P:00043A 0ACD69            BSET    #9,B1
1684      P:00043B P:00043B 44F400  STG_B     MOVE              #$0C3C00,X0
                            0C3C00
1685      P:00043D P:00043D 20004A            OR      X0,B
1686      P:00043E P:00043E 000000            NOP
1687      P:00043F P:00043F 5F1700            MOVE                          B,Y:<GAIN   ; Store the GAIN value for later use
1688   
1689                                ; Send this same value to 15 video processor boards whether they exist or not
1690      P:000440 P:000440 241000            MOVE              #$100000,X0             ; Increment value
1691      P:000441 P:000441 21EE00            MOVE              B,A
1692      P:000442 P:000442 060F80            DO      #15,STG_LOOP
                            000446
1693      P:000444 P:000444 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1694      P:000445 P:000445 0D040D            JSR     <PAL_DLY                          ; Wait for SSI and PAL to be empty
1695      P:000446 P:000446 200048            ADD     X0,B                              ; Increment the video processor board number
1696                                STG_LOOP
1697      P:000447 P:000447 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1698      P:000448 P:000448 0C008D            JMP     <FINISH
1699      P:000449 P:000449 56DB00  ERR_SGN   MOVE              X:(R3)+,A
1700      P:00044A P:00044A 0C008B            JMP     <ERROR
1701   
1702                                ; *******************************************************************
1703                                ; Set the video processor boards in DC-coupled diagnostic mode or not
1704                                ; Command syntax is  SDC #      # = 0 for normal operation
1705                                ;                               # = 1 for DC coupled diagnostic mode
1706      P:00044B P:00044B 012F23  SET_DC    BSET    #3,X:PCRD                         ; Turn the serial clock on
1707      P:00044C P:00044C 44DB00            MOVE              X:(R3)+,X0
1708      P:00044D P:00044D 0AC420            JSET    #0,X0,SDC_1
                            000452
1709      P:00044F P:00044F 0A174A            BCLR    #10,Y:<GAIN
1710      P:000450 P:000450 0A174B            BCLR    #11,Y:<GAIN
1711      P:000451 P:000451 0C0454            JMP     <SDC_A
1712      P:000452 P:000452 0A176A  SDC_1     BSET    #10,Y:<GAIN
1713      P:000453 P:000453 0A176B            BSET    #11,Y:<GAIN
1714      P:000454 P:000454 241000  SDC_A     MOVE              #$100000,X0             ; Increment value
1715      P:000455 P:000455 060F80            DO      #15,SDC_LOOP
                            00045A
1716      P:000457 P:000457 5E9700            MOVE                          Y:<GAIN,A
1717      P:000458 P:000458 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1718      P:000459 P:000459 0D040D            JSR     <PAL_DLY                          ; Wait for SSI and PAL to be empty
1719      P:00045A P:00045A 200048            ADD     X0,B                              ; Increment the video processor board number
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 32



1720                                SDC_LOOP
1721      P:00045B P:00045B 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1722      P:00045C P:00045C 0C008D            JMP     <FINISH
1723   
1724                                ; *******************************************************************
1725                                ; Set a particular DAC numbers, for setting DC bias voltages, clock driver
1726                                ;   voltages and video processor offset
1727                                ;
1728                                ; SBN  #BOARD  #DAC  ['CLK' or 'VID']  voltage
1729                                ;
1730                                ;                               #BOARD is from 0 to 15
1731                                ;                               #DAC number
1732                                ;                               #voltage is from 0 to 4095
1733   
1734                                SET_BIAS_NUMBER                                     ; Set bias number
1735      P:00045D P:00045D 012F23            BSET    #3,X:PCRD                         ; Turn on the serial clock
1736      P:00045E P:00045E 56DB00            MOVE              X:(R3)+,A               ; First argument is board number, 0 to 15
1737      P:00045F P:00045F 0614A0            REP     #20
1738      P:000460 P:000460 200033            LSL     A
1739      P:000461 P:000461 000000            NOP
1740      P:000462 P:000462 21C400            MOVE              A,X0
1741      P:000463 P:000463 56DB00            MOVE              X:(R3)+,A               ; Second argument is DAC number
1742      P:000464 P:000464 060EA0            REP     #14
1743      P:000465 P:000465 200033            LSL     A
1744      P:000466 P:000466 200042            OR      X0,A
1745      P:000467 P:000467 57DB00            MOVE              X:(R3)+,B               ; Third argument is 'VID' or 'CLK' string
1746      P:000468 P:000468 44F400            MOVE              #'VID',X0
                            564944
1747      P:00046A P:00046A 20004D            CMP     X0,B
1748      P:00046B P:00046B 0E2470            JNE     <CLK_DRV
1749      P:00046C P:00046C 0ACC73            BSET    #19,A1                            ; Set bits to mean video processor DAC
1750      P:00046D P:00046D 000000            NOP
1751      P:00046E P:00046E 0ACC72            BSET    #18,A1
1752      P:00046F P:00046F 0C0474            JMP     <VID_BRD
1753      P:000470 P:000470 44F400  CLK_DRV   MOVE              #'CLK',X0
                            434C4B
1754      P:000472 P:000472 20004D            CMP     X0,B
1755      P:000473 P:000473 0E247E            JNE     <ERR_SBN
1756      P:000474 P:000474 21C400  VID_BRD   MOVE              A,X0
1757      P:000475 P:000475 56DB00            MOVE              X:(R3)+,A               ; Fourth argument is voltage value, 0 to $ff
f
1758      P:000476 P:000476 46F400            MOVE              #$000FFF,Y0             ; Mask off just 12 bits to be sure
                            000FFF
1759      P:000478 P:000478 200056            AND     Y0,A
1760      P:000479 P:000479 200042            OR      X0,A
1761      P:00047A P:00047A 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1762      P:00047B P:00047B 0D040D            JSR     <PAL_DLY                          ; Wait for the number to be sent
1763      P:00047C P:00047C 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1764      P:00047D P:00047D 0C008D            JMP     <FINISH
1765      P:00047E P:00047E 56DB00  ERR_SBN   MOVE              X:(R3)+,A               ; Read and discard the fourth argument
1766      P:00047F P:00047F 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1767      P:000480 P:000480 0C008B            JMP     <ERROR
1768   
1769                                ; Specify the MUX value to be output on the clock driver board
1770                                ; Command syntax is  SMX  #clock_driver_board #MUX1 #MUX2
1771                                ;                               #clock_driver_board from 0 to 15
1772                                ;                               #MUX1, #MUX2 from 0 to 23
1773      P:000481 P:000481 012F23  SET_MUX   BSET    #3,X:PCRD                         ; Turn on the serial clock
1774      P:000482 P:000482 56DB00            MOVE              X:(R3)+,A               ; Clock driver board number
1775      P:000483 P:000483 0614A0            REP     #20
1776      P:000484 P:000484 200033            LSL     A
1777      P:000485 P:000485 44F400            MOVE              #$003000,X0
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 33



                            003000
1778      P:000487 P:000487 200042            OR      X0,A
1779      P:000488 P:000488 000000            NOP
1780      P:000489 P:000489 21C500            MOVE              A,X1                    ; Move here for storage
1781   
1782                                ; Get the first MUX number
1783      P:00048A P:00048A 56DB00            MOVE              X:(R3)+,A               ; Get the first MUX number
1784      P:00048B P:00048B 0AF0A9            JLT     ERR_SM1
                            0004CF
1785      P:00048D P:00048D 44F400            MOVE              #>24,X0                 ; Check for argument less than 32
                            000018
1786      P:00048F P:00048F 200045            CMP     X0,A
1787      P:000490 P:000490 0AF0A1            JGE     ERR_SM1
                            0004CF
1788      P:000492 P:000492 21CF00            MOVE              A,B
1789      P:000493 P:000493 44F400            MOVE              #>7,X0
                            000007
1790      P:000495 P:000495 20004E            AND     X0,B
1791      P:000496 P:000496 44F400            MOVE              #>$18,X0
                            000018
1792      P:000498 P:000498 200046            AND     X0,A
1793      P:000499 P:000499 0E249C            JNE     <SMX_1                            ; Test for 0 <= MUX number <= 7
1794      P:00049A P:00049A 0ACD63            BSET    #3,B1
1795      P:00049B P:00049B 0C04A7            JMP     <SMX_A
1796      P:00049C P:00049C 44F400  SMX_1     MOVE              #>$08,X0
                            000008
1797      P:00049E P:00049E 200045            CMP     X0,A                              ; Test for 8 <= MUX number <= 15
1798      P:00049F P:00049F 0E24A2            JNE     <SMX_2
1799      P:0004A0 P:0004A0 0ACD64            BSET    #4,B1
1800      P:0004A1 P:0004A1 0C04A7            JMP     <SMX_A
1801      P:0004A2 P:0004A2 44F400  SMX_2     MOVE              #>$10,X0
                            000010
1802      P:0004A4 P:0004A4 200045            CMP     X0,A                              ; Test for 16 <= MUX number <= 23
1803      P:0004A5 P:0004A5 0E24CF            JNE     <ERR_SM1
1804      P:0004A6 P:0004A6 0ACD65            BSET    #5,B1
1805      P:0004A7 P:0004A7 20006A  SMX_A     OR      X1,B1                             ; Add prefix to MUX numbers
1806      P:0004A8 P:0004A8 000000            NOP
1807      P:0004A9 P:0004A9 21A700            MOVE              B1,Y1
1808   
1809                                ; Add on the second MUX number
1810      P:0004AA P:0004AA 56DB00            MOVE              X:(R3)+,A               ; Get the next MUX number
1811      P:0004AB P:0004AB 0E908B            JLT     <ERROR
1812      P:0004AC P:0004AC 44F400            MOVE              #>24,X0                 ; Check for argument less than 32
                            000018
1813      P:0004AE P:0004AE 200045            CMP     X0,A
1814      P:0004AF P:0004AF 0E108B            JGE     <ERROR
1815      P:0004B0 P:0004B0 0606A0            REP     #6
1816      P:0004B1 P:0004B1 200033            LSL     A
1817      P:0004B2 P:0004B2 000000            NOP
1818      P:0004B3 P:0004B3 21CF00            MOVE              A,B
1819      P:0004B4 P:0004B4 44F400            MOVE              #$1C0,X0
                            0001C0
1820      P:0004B6 P:0004B6 20004E            AND     X0,B
1821      P:0004B7 P:0004B7 44F400            MOVE              #>$600,X0
                            000600
1822      P:0004B9 P:0004B9 200046            AND     X0,A
1823      P:0004BA P:0004BA 0E24BD            JNE     <SMX_3                            ; Test for 0 <= MUX number <= 7
1824      P:0004BB P:0004BB 0ACD69            BSET    #9,B1
1825      P:0004BC P:0004BC 0C04C8            JMP     <SMX_B
1826      P:0004BD P:0004BD 44F400  SMX_3     MOVE              #>$200,X0
                            000200
1827      P:0004BF P:0004BF 200045            CMP     X0,A                              ; Test for 8 <= MUX number <= 15
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3_misc.asm  Page 34



1828      P:0004C0 P:0004C0 0E24C3            JNE     <SMX_4
1829      P:0004C1 P:0004C1 0ACD6A            BSET    #10,B1
1830      P:0004C2 P:0004C2 0C04C8            JMP     <SMX_B
1831      P:0004C3 P:0004C3 44F400  SMX_4     MOVE              #>$400,X0
                            000400
1832      P:0004C5 P:0004C5 200045            CMP     X0,A                              ; Test for 16 <= MUX number <= 23
1833      P:0004C6 P:0004C6 0E208B            JNE     <ERROR
1834      P:0004C7 P:0004C7 0ACD6B            BSET    #11,B1
1835      P:0004C8 P:0004C8 200078  SMX_B     ADD     Y1,B                              ; Add prefix to MUX numbers
1836      P:0004C9 P:0004C9 000000            NOP
1837      P:0004CA P:0004CA 21AE00            MOVE              B1,A
1838      P:0004CB P:0004CB 0D020A            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1839      P:0004CC P:0004CC 0D040D            JSR     <PAL_DLY                          ; Delay for all this to happen
1840      P:0004CD P:0004CD 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1841      P:0004CE P:0004CE 0C008D            JMP     <FINISH
1842      P:0004CF P:0004CF 56DB00  ERR_SM1   MOVE              X:(R3)+,A
1843      P:0004D0 P:0004D0 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1844      P:0004D1 P:0004D1 0C008B            JMP     <ERROR
1845   
1846                                 TIMBOOT_X_MEMORY
1847      0004D2                              EQU     @LCV(L)
1848   
1849                                ;  ****************  Setup memory tables in X: space ********************
1850   
1851                                ; Define the address in P: space where the table of constants begins
1852   
1853                                          IF      @SCP("HOST","HOST")
1854      X:000036 X:000036                   ORG     X:END_COMMAND_TABLE,X:END_COMMAND_TABLE
1855                                          ENDIF
1856   
1857                                          IF      @SCP("HOST","ROM")
1859                                          ENDIF
1860   
1861                                ; Application commands
1862      X:000036 X:000036                   DC      'PON',POWER_ON
1863      X:000038 X:000038                   DC      'POF',POWER_OFF
1864      X:00003A X:00003A                   DC      'SBV',SET_BIAS_VOLTAGES
1865      X:00003C X:00003C                   DC      'IDL',START_IDLE_CLOCKING
1866      X:00003E X:00003E                   DC      'OSH',OPEN_SHUTTER
1867      X:000040 X:000040                   DC      'CSH',CLOSE_SHUTTER
1868      X:000042 X:000042                   DC      'RDC',RDCCD
1869      X:000044 X:000044                   DC      'CLR',CLEAR
1870   
1871                                ; Exposure and readout control routines
1872      X:000046 X:000046                   DC      'SET',SET_EXPOSURE_TIME
1873      X:000048 X:000048                   DC      'RET',READ_EXPOSURE_TIME
1874      X:00004A X:00004A                   DC      'SEX',START_EXPOSURE
1875      X:00004C X:00004C                   DC      'PEX',PAUSE_EXPOSURE
1876      X:00004E X:00004E                   DC      'REX',RESUME_EXPOSURE
1877      X:000050 X:000050                   DC      'AEX',ABORT_ALL
1878      X:000052 X:000052                   DC      'ABR',ABORT_ALL                   ; MPL temporary
1879      X:000054 X:000054                   DC      'FPX',FOR_PSHIFT
1880      X:000056 X:000056                   DC      'RPX',REV_PSHIFT
1881                                ;       DC      'ABR',ABR_RDC                   ; MPL
1882                                ;       DC      'CRD',CONT_RD                   ; MPL
1883   
1884                                ; Support routines
1885      X:000058 X:000058                   DC      'SGN',ST_GAIN
1886      X:00005A X:00005A                   DC      'SDC',SET_DC
1887      X:00005C X:00005C                   DC      'SBN',SET_BIAS_NUMBER
1888      X:00005E X:00005E                   DC      'SMX',SET_MUX
1889      X:000060 X:000060                   DC      'CSW',CLR_SWS
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  tim3.asm  Page 35



1890      X:000062 X:000062                   DC      'RCC',READ_CONTROLLER_CONFIGURATION
1891   
1892                                 END_APPLICATON_COMMAND_TABLE
1893      000064                              EQU     @LCV(L)
1894   
1895                                          IF      @SCP("HOST","HOST")
1896      00001E                    NUM_COM   EQU     (@LCV(R)-COM_TBL_R)/2             ; Number of boot + application commands
1897      000379                    EXPOSING  EQU     CHK_TIM                           ; Address if exposing
1898                                ;CONTINUE_READING       EQU     CONT_RD                 ; Address if reading out
1899                                          ENDIF
1900   
1901                                          IF      @SCP("HOST","ROM")
1903                                          ENDIF
1904   
1905                                ; Now let's go for the timing waveform tables
1906                                          IF      @SCP("HOST","HOST")
1907      Y:000000 Y:000000                   ORG     Y:0,Y:0
1908                                          ENDIF
1909   
1910                                ; *** include waveform table ***
1911                                          INCLUDE "waveforms.asm"
1912                                ; waveforms.asm for Gen3 - lbtguider
1913                                ; 05Oct04 last change by Michael Lesser
1914                                ; 08 Feb 06 - changes by R. Tucker
1915   
1916                                ; *** boards and timing delays ***
1917      000000                    VIDEO     EQU     $000000                           ; Video processor board (all are addressed t
ogether)
1918      002000                    CLK2      EQU     $002000                           ; Clock driver board select = board 2 low ba
nk
1919      003000                    CLK3      EQU     $003000                           ; Clock driver board select = board 2 high b
ank
1920                                ;P_DELAY        EQU     $620000 ; 4 usec parallel clock delay
1921      300000                    P_DELAY   EQU     $300000                           ; 2 usec parallel clock delay - new
1922      030000                    S_DELAY   EQU     $030000                           ; serial clock delay
1923      000000                    V_DELAY   EQU     $000000                           ; video processor delay
1924      300000                    DWELL     EQU     $300000                           ; 2 usec pixel integration
1925      000001                    PARMULT   EQU     1                                 ; P_DELAY multiplier
1926      000001                    GENCNT    EQU     1                                 ; Gen clock counter (2 for gen1/2, 1 for gen
3)
1927   
1928                                ; *** video channels ***
1929                                ;  for LBT guider dewars, OS1 is right output, OS0 is left output
1930                                ;SXMIT  EQU     $00F000 ; Transmit A/D = 0
1931      00F041                    SXMIT     EQU     $00F041                           ; Transmit A/D = 1
1932                                ;SXMIT  EQU     $00F040 ; Transmit A/Ds = 0 to 1
1933   
1934                                ; *** DSP Y memory parameter table - written by AzCamTool
1935                                          INCLUDE "Ypars.asm"
1936                                ; Values in this block start at Y:0 and are overwritten by AzCamTool
1937                                ; with WRM commands.  They are not overwritten by waveform tables.
1938                                ; All values are unbinned pixels unless noted.
1939   
1940      Y:000000 Y:000000         CAMSTAT   DC      0                                 ; not used
1941      Y:000001 Y:000001         NSDATA    DC      1                                 ; number BINNED serial columns in ROI
1942      Y:000002 Y:000002         NPDATA    DC      1                                 ; number of BINNED parallel rows in ROI
1943      Y:000003 Y:000003         NSBIN     DC      1                                 ; Serial binning parameter (>= 1)
1944      Y:000004 Y:000004         NPBIN     DC      1                                 ; Parallel binning parameter (>= 1)
1945   
1946      Y:000005 Y:000005         NSAMPS    DC      0                                 ; 0 => 1 amp, 1 => split serials
1947      Y:000006 Y:000006         NPAMPS    DC      0                                 ; 0 => 1 amp, 1 => split parallels
1948      Y:000007 Y:000007         NSCLEAR   DC      1                                 ; number of columns to clear during flush
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  Ypars.asm  Page 36



1949      Y:000008 Y:000008         NPCLEAR   DC      1                                 ; number of rows to clear during flush
1950   
1951      Y:000009 Y:000009         NSPRESKIP DC      0                                 ; number of cols to skip before underscan
1952                                 NSUNDERSCAN
1953      Y:00000A Y:00000A                   DC      0                                 ; number of BINNED columns in underscan
1954      Y:00000B Y:00000B         NSSKIP    DC      0                                 ; number of cols to skip between underscan a
nd data
1955      Y:00000C Y:00000C         NSPOSTSKIP DC     0                                 ; number of cols to skip between data and ov
erscan
1956      Y:00000D Y:00000D         NSOVERSCAN DC     0                                 ; number of BINNED columns in overscan
1957   
1958      Y:00000E Y:00000E         NPPRESKIP DC      0                                 ; number of rows to skip before underscan
1959                                 NPUNDERSCAN
1960      Y:00000F Y:00000F                   DC      0                                 ; number of BINNED rows in underscan
1961      Y:000010 Y:000010         NPSKIP    DC      0                                 ; number of rows to skip between underscan a
nd data
1962      Y:000011 Y:000011         NPPOSTSKIP DC     0                                 ; number of rows to skip between data and ov
erscan
1963      Y:000012 Y:000012         NPOVERSCAN DC     0                                 ; number of BINNED rows in overscan
1964   
1965      Y:000013 Y:000013         NPXSHIFT  DC      0                                 ; number of rows to parallel shift
1966      Y:000014 Y:000014         TESTDATA  DC      0                                 ; 0 => normal, 1 => send incremented fake da
ta
1967      Y:000015 Y:000015         FRAMET    DC      0                                 ; number of storage rows for frame transfer 
shift
1968      Y:000016 Y:000016         PREFLASH  DC      0                                 ; not used
1969      Y:000017 Y:000017         GAIN      DC      0                                 ; Video proc gain and integrator speed store
d here
1970      Y:000018 Y:000018         TST_DAT   DC      0                                 ; Place for synthetic test image pixel data
1971      Y:000019 Y:000019         SH_DEL    DC      100                               ; Delay (msecs) between shutter closing and 
image readout
1972      Y:00001A Y:00001A         CONFIG    DC      CC                                ; Controller configuration
1973      Y:00001B Y:00001B         NSIMAGE   DC      1                                 ; total number of columns in image
1974      Y:00001C Y:00001C         NPIMAGE   DC      1                                 ; total number of rows in image
1975      Y:00001D Y:00001D         PAD3      DC      0                                 ; unused
1976      Y:00001E Y:00001E         PAD4      DC      0                                 ; unused
1977      Y:00001F Y:00001F         IDLEONE   DC      2                                 ; lines to shift in IDLE (really 1)
1978   
1979                                ; Values in this block start at Y:20 and are overwritten if waveform table
1980                                ; is downloaded
1981      Y:000020 Y:000020         PMULT     DC      PARMULT                           ; parallel clock multiplier
1982      Y:000021 Y:000021         ACLEAR0   DC      TNOP                              ; Clear prologue - NOT USED
1983      Y:000022 Y:000022         ACLEAR2   DC      TNOP                              ; Clear epilogue - NOT USED
1984      Y:000023 Y:000023         AREAD0    DC      TNOP                              ; Read prologue - NOT USED
1985      Y:000024 Y:000024         AREAD8    DC      TNOP                              ; Read epilogue - NOT USED
1986      Y:000025 Y:000025         AFPXFER0  DC      FPXFER0                           ; Fast parallel transfer prologue
1987      Y:000026 Y:000026         AFPXFER2  DC      FPXFER2                           ; Fast parallel transfer epilogue
1988      Y:000027 Y:000027         APXFER    DC      PXFER                             ; Parallel transfer - storage only
1989      Y:000028 Y:000028         APDXFER   DC      PXFER                             ; Parallel transfer (data) - storage only
1990      Y:000029 Y:000029         APQXFER   DC      PQXFER                            ; Parallel transfer - storage and image
1991      Y:00002A Y:00002A         ARXFER    DC      RXFER                             ; Reverse parallel transfer (for focus)
1992      Y:00002B Y:00002B         AFSXFER   DC      FSXFER                            ; Fast serial transfer
1993      Y:00002C Y:00002C         ASXFER0   DC      SXFER0                            ; Serial transfer prologue
1994      Y:00002D Y:00002D         ASXFER1   DC      SXFER1                            ; Serial transfer ( * colbin-1 )
1995      Y:00002E Y:00002E         ASXFER2   DC      SXFER2                            ; Serial transfer epilogue - no data
1996      Y:00002F Y:00002F         ASXFER2D  DC      SXFER2D                           ; Serial transfer epilogue - data
1997      Y:000030 Y:000030         ADACS     DC      DACS
1998   
1999                                ; *** clock rails ***
2000      2.700000E+000             RG_HI     EQU     +2.7                              ; Reset Gate    (+4.0)
2001      -9.300000E+000            RG_LO     EQU     -9.3                              ;               (-8.0)
2002      7.000000E-001             S_HI      EQU     +0.7                              ; Serial clocks (+2.0)
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  waveforms.asm  Page 37



2003      -8.300000E+000            S_LO      EQU     -8.3                              ;               (-8.0)
2004      -9.300000E+000            SW_HI     EQU     -9.3                              ; Dump gate     (-5.0)
2005      -9.300000E+000            SW_LO     EQU     -9.3                              ;               (-5.0)
2006      2.700000E+000             P_HI      EQU     +2.7                              ; Parallel clock phases 1 & 2
2007      -8.300000E+000            P_LO      EQU     -8.3                              ; (+4.0 / -10.0)
2008      7.000000E-001             P3_HI     EQU     +0.7                              ; Parallel clock phase 3 (MPP)
2009      -1.000000E+001            P3_LO     EQU     -10.0                             ; (+4.0 / -10.0)
2010      0.000000E+000             TG_HI     EQU     0.0                               ; Transfer gate - not used
2011      0.000000E+000             TG_LO     EQU     0.0
2012   
2013                                ; *** bias voltages ***
2014      2.070000E+001             VOD       EQU     +20.7                             ; Output Drains (+24.0)
2015      8.700000E+000             VRD       EQU     +8.7                              ; Reset Drain   (+12.0)
2016      -7.300000E+000            VOG       EQU     -7.3                              ; Output Gates  (-3.0)
2017      5.000000E+000             B5        EQU     5.0                               ; not used
2018      5.000000E+000             B7        EQU     5.0                               ; not used
2019   
2020                                ; *** video output offset ***
2021                                ; higher value here lowers output value (~4.8 DN change/unit change here)
2022      000000                    OFFSET    EQU     0                                 ; global offset to all channels
2023      000000                    OFFSET0   EQU     0                                 ; offsets for channel 0
2024      000000                    OFFSET1   EQU     0                                 ; offsets for channel 1
2025   
2026                                ; *** clock rail aliases ***
2027      7.000000E-001             S1_HI     EQU     S_HI
2028      -8.300000E+000            S1_LO     EQU     S_LO
2029      7.000000E-001             S2_HI     EQU     S_HI
2030      -8.300000E+000            S2_LO     EQU     S_LO
2031      7.000000E-001             S3_HI     EQU     S_HI
2032      -8.300000E+000            S3_LO     EQU     S_LO
2033      2.700000E+000             P1_HI     EQU     P_HI
2034      -8.300000E+000            P1_LO     EQU     P_LO
2035      2.700000E+000             P2_HI     EQU     P_HI
2036      -8.300000E+000            P2_LO     EQU     P_LO
2037      2.700000E+000             Q1_HI     EQU     P_HI
2038      -8.300000E+000            Q1_LO     EQU     P_LO
2039      2.700000E+000             Q2_HI     EQU     P_HI
2040      -8.300000E+000            Q2_LO     EQU     P_LO
2041      7.000000E-001             Q3_HI     EQU     P3_HI
2042      -1.000000E+001            Q3_LO     EQU     P3_LO
2043   
2044                                ; *** clock state bits ***
2045                                          INCLUDE "SwitchStates.asm"
2046                                ; Switch state bits for clocks
2047                                ; ITL standard Gen2/Gen3 edge connector
2048   
2049                                ; low bank (usually CLK2)
2050      000000                    RGL       EQU     0                                 ;       CLK0    Pin 1
2051      000001                    RGH       EQU     1                                 ;       CLK0
2052      000000                    P1L       EQU     0                                 ;       CLK1    Pin 2
2053      000002                    P1H       EQU     2                                 ;       CLK1
2054      000000                    P2L       EQU     0                                 ;       CLK2    Pin 3
2055      000004                    P2H       EQU     4                                 ;       CLK2
2056      000000                    P3L       EQU     0                                 ;       CLK3    Pin 4
2057      000008                    P3H       EQU     8                                 ;       CLK3
2058      000000                    S1L       EQU     0                                 ;       CLK4    Pin 5
2059      000010                    S1H       EQU     $10                               ;       CLK4
2060      000000                    S3L       EQU     0                                 ;       CLK5    Pin 6
2061      000020                    S3H       EQU     $20                               ;       CLK5
2062      000000                    S2L       EQU     0                                 ;       CLK6    Pin 7
2063      000040                    S2H       EQU     $40                               ;       CLK6
2064      000000                    Q3L       EQU     0                                 ;       CLK7    Pin 8
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  SwitchStates.asm  Page 38



2065      000080                    Q3H       EQU     $80                               ;       CLK7
2066      000000                    Q2L       EQU     0                                 ;       CLK8    Pin 9
2067      000100                    Q2H       EQU     $100                              ;       CLK8
2068      000000                    Q1L       EQU     0                                 ;       CLK9    Pin 10
2069      000200                    Q1H       EQU     $200                              ;       CLK9
2070      000000                    SWL       EQU     0                                 ;       CLK10   Pin 11
2071      000400                    SWH       EQU     $400                              ;       CLK10
2072      000000                    TGL       EQU     0                                 ;       CLK10   Pin 12
2073      000800                    TGH       EQU     $800                              ;       CLK10
2074   
2075                                ; high bank (usually CLK3) - not used
2076      000000                    Z1L       EQU     0                                 ;       CLK12   Pin 13
2077      001000                    Z1H       EQU     $1000                             ;       CLK12
2078      000000                    Z2L       EQU     0                                 ;       CLK13   Pin 14
2079      002000                    Z2H       EQU     $2000                             ;       CLK13
2080      000000                    Z3L       EQU     0                                 ;       CLK14   Pin 15
2081      004000                    Z3H       EQU     $4000                             ;       CLK14
2082      000000                    Z4L       EQU     0                                 ;       CLK15   Pin 16
2083      008000                    Z4H       EQU     $8000                             ;       CLK15
2084      000000                    Z5L       EQU     0                                 ;       CLK16   Pin 17
2085      010000                    Z5H       EQU     $10000                            ;       CLK16
2086      000000                    Z6L       EQU     0                                 ;       CLK17   Pin 18
2087      020000                    Z6H       EQU     $20000                            ;       CLK17
2088      000000                    Z7L       EQU     0                                 ;       CLK18   Pin 19
2089      040000                    Z7H       EQU     $40000                            ;       CLK18
2090      000000                    Z8L       EQU     0                                 ;       CLK19   Pin 33
2091      080000                    Z8H       EQU     $80000                            ;       CLK19
2092      000000                    Z9L       EQU     0                                 ;       CLK20   Pin 34
2093      100000                    Z9H       EQU     $100000                           ;       CLK20
2094      000000                    Z10L      EQU     0                                 ;       CLK21   Pin 35
2095      200000                    Z10H      EQU     $200000                           ;       CLK21
2096      000000                    Z11L      EQU     0                                 ;       CLK22   Pin 36
2097      400000                    Z11H      EQU     $400000                           ;       CLK22
2098      000000                    Z12L      EQU     0                                 ;       CLK23   Pin 37
2099      800000                    Z12H      EQU     $800000                           ;       CLK23
2100   
2101                                ; *** default clock states ***
2102      000041                    SDEF      EQU     S1L+S2H+S3L+RGH+SWL               ; during parallel shifting
2103      000000                    PDEF      EQU     P1L+P2L+P3L                       ; during serial shifting
2104      000000                    QDEF      EQU     Q1L+Q2L+Q3L                       ; "  "
2105      000000                    PQDEF     EQU     PDEF+QDEF                         ; "  "
2106   
2107                                ; *** parallel shifting of storage only ***
2108      Y:000031 Y:000031         PXFER     DC      EPXFER-PXFER-GENCNT
2109                                          INCLUDE "p_3123_mpp.asm"
2110                                ; P shift, 3-1-2-3 MPP
2111      Y:000032 Y:000032                   DC      CLK2+P_DELAY+SDEF+P1L+P2L+P3H+QDEF
2112      Y:000033 Y:000033                   DC      CLK2+P_DELAY+SDEF+P1H+P2L+P3H+QDEF
2113      Y:000034 Y:000034                   DC      CLK2+P_DELAY+SDEF+P1H+P2L+P3L+QDEF
2114      Y:000035 Y:000035                   DC      CLK2+P_DELAY+SDEF+P1H+P2H+P3L+QDEF
2115      Y:000036 Y:000036                   DC      CLK2+P_DELAY+SDEF+P1L+P2H+P3L+QDEF
2116      Y:000037 Y:000037                   DC      CLK2+P_DELAY+SDEF+P1L+P2H+P3H+QDEF
2117      Y:000038 Y:000038                   DC      CLK2+P_DELAY+SDEF+P1L+P2L+P3H+QDEF
2118      Y:000039 Y:000039                   DC      CLK2+P_DELAY+SDEF+P1L+P2L+P3L+QDEF
2119                                EPXFER
2120   
2121                                ; *** parallel shifting of entire device ***
2122      Y:00003A Y:00003A         PQXFER    DC      EPQXFER-PQXFER-GENCNT
2123                                          INCLUDE "pq_3123_mpp.asm"
2124                                ; PQ shift, 3-1-2-3-MPP
2125      Y:00003B Y:00003B                   DC      CLK2+P_DELAY+SDEF+P1L+P2L+P3H+Q1L+Q2L+Q3H
2126      Y:00003C Y:00003C                   DC      CLK2+P_DELAY+SDEF+P1H+P2L+P3H+Q1H+Q2L+Q3H
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  pq_3123_mpp.asm  Page 39



2127      Y:00003D Y:00003D                   DC      CLK2+P_DELAY+SDEF+P1H+P2L+P3L+Q1H+Q2L+Q3L
2128      Y:00003E Y:00003E                   DC      CLK2+P_DELAY+SDEF+P1H+P2H+P3L+Q1H+Q2H+Q3L
2129      Y:00003F Y:00003F                   DC      CLK2+P_DELAY+SDEF+P1L+P2H+P3L+Q1L+Q2H+Q3L
2130      Y:000040 Y:000040                   DC      CLK2+P_DELAY+SDEF+P1L+P2H+P3H+Q1L+Q2H+Q3H
2131      Y:000041 Y:000041                   DC      CLK2+P_DELAY+SDEF+P1L+P2L+P3H+Q1L+Q2L+Q3H
2132      Y:000042 Y:000042                   DC      CLK2+P_DELAY+SDEF+P1L+P2L+P3L+Q1L+Q2L+Q3L
2133                                EPQXFER
2134   
2135                                ; *** reverse shifting of entire device during focus ***
2136      000031                    RXFER     EQU     PXFER
2137                                ;RXFER  DC      ERXFER-RXFER-GENCNT
2138                                ;       INCLUDE "xxx"
2139                                ;ERXFER
2140   
2141                                ; *** serial shifting ***
2142                                          INCLUDE "s_12_123n.asm"
2143                                ; s_12_123n
2144                                ; optimized for speed
2145   
2146      032000                    PARS      EQU     CLK2+PQDEF+S_DELAY
2147      000000                    VIDS      EQU     VIDEO+V_DELAY
2148   
2149                                ; setup for fast flush
2150      Y:000043 Y:000043         FPXFER0   DC      EFPXFER0-FPXFER0-GENCNT
2151      Y:000044 Y:000044                   DC      PARS+RGH+S1H+S2H+S3H
2152      Y:000045 Y:000045                   DC      PARS+RGH+S1H+S2H+S3H
2153                                EFPXFER0
2154   
2155                                ; end fast flush
2156      Y:000046 Y:000046         FPXFER2   DC      EFPXFER2-FPXFER2-GENCNT
2157      Y:000047 Y:000047                   DC      PARS+RGL+S1H+S2H+S3L
2158      Y:000048 Y:000048                   DC      PARS+RGL+S1H+S2H+S3L
2159                                EFPXFER2
2160   
2161                                ; fast serial shift
2162      Y:000049 Y:000049         FSXFER    DC      EFSXFER-FSXFER-GENCNT
2163      Y:00004A Y:00004A                   DC      PARS+RGH+S1L+S2H+S3L
2164      Y:00004B Y:00004B                   DC      PARS+RGL+S1L+S2H+S3H
2165      Y:00004C Y:00004C                   DC      PARS+RGL+S1L+S2L+S3H
2166      Y:00004D Y:00004D                   DC      PARS+RGL+S1H+S2L+S3H
2167      Y:00004E Y:00004E                   DC      PARS+RGL+S1H+S2L+S3L
2168      Y:00004F Y:00004F                   DC      PARS+RGL+S1H+S2H+S3L
2169                                EFSXFER
2170   
2171                                ; video clocks are [xfer, A/D, integ, Pol+, Pol-, DCclamp, rst](1 => switch open)
2172      Y:000050 Y:000050         SXFER0    DC      ESXFER0-SXFER0-GENCNT
2173      Y:000051 Y:000051                   DC      PARS+RGH+S1L+S2H+S3L              ; reset
2174      Y:000052 Y:000052                   DC      VIDS+%1110100
2175      Y:000053 Y:000053                   DC      PARS+RGL+S1L+S2H+S3H
2176      Y:000054 Y:000054                   DC      PARS+RGL+S1L+S2L+S3H
2177      Y:000055 Y:000055                   DC      PARS+RGL+S1H+S2L+S3H
2178                                          INCLUDE "int_noise.asm"
2179                                ; CDS integrate on noise
2180      Y:000056 Y:000056                   DC      VIDS+%1110111                     ; Stop resetting integrator
2181      Y:000057 Y:000057                   DC      VIDS+%1110111                     ; Delay for Pgnal to settle
2182      Y:000058 Y:000058                   DC      VIDEO+DWELL+%0000111              ; Integrate noise
2183      Y:000059 Y:000059                   DC      VIDS+%0011011                     ; Stop Integrate, switch POL
2184      Y:00005A Y:00005A                   DC      PARS+RGL+S1H+S2L+S3L
2185      Y:00005B Y:00005B                   DC      PARS+RGL+S1H+S2H+S3L
2186                                ESXFER0
2187   
2188      Y:00005C Y:00005C         SXFER1    DC      ESXFER1-SXFER1-GENCNT
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  s_12_123n.asm  Page 40



2189      Y:00005D Y:00005D                   DC      PARS+RGL+S1L+S2H+S3L
2190      Y:00005E Y:00005E                   DC      PARS+RGL+S1L+S2H+S3H
2191      Y:00005F Y:00005F                   DC      PARS+RGL+S1L+S2L+S3H
2192      Y:000060 Y:000060                   DC      PARS+RGL+S1H+S2L+S3H
2193      Y:000061 Y:000061                   DC      PARS+RGL+S1H+S2L+S3L
2194      Y:000062 Y:000062                   DC      PARS+RGL+S1H+S2H+S3L
2195                                ESXFER1
2196   
2197      Y:000063 Y:000063         SXFER2    DC      ESXFER2-SXFER2-GENCNT
2198      Y:000064 Y:000064                   DC      PARS+RGL+S1H+S2H+S3L
2199                                          INCLUDE "int_signal.asm"
2200                                ; CDS integrate on signal
2201      Y:000065 Y:000065                   DC      VIDS+%0011011                     ; Delay for Pgnal to settle
2202      Y:000066 Y:000066                   DC      VIDEO+DWELL+%0001011              ; Integrate signal
2203      Y:000067 Y:000067                   DC      VIDS+%0011011                     ; Stop integrate, clamp, reset, A/D is sampl
ing
2204                                ESXFER2
2205   
2206      Y:000068 Y:000068         SXFER2D   DC      ESXFER2D-SXFER2D-GENCNT
2207      Y:000069 Y:000069                   DC      SXMIT                             ; Transmit A/D data to host
2208      Y:00006A Y:00006A                   DC      PARS+RGL+S1H+S2H+S3L
2209                                          INCLUDE "int_signal.asm"
2210                                ; CDS integrate on signal
2211      Y:00006B Y:00006B                   DC      VIDS+%0011011                     ; Delay for Pgnal to settle
2212      Y:00006C Y:00006C                   DC      VIDEO+DWELL+%0001011              ; Integrate signal
2213      Y:00006D Y:00006D                   DC      VIDS+%0011011                     ; Stop integrate, clamp, reset, A/D is sampl
ing
2214                                ESXFER2D
2215   
2216                                ; *** bias voltage table ***
2217                                          INCLUDE "DACS.asm"
2218                                ; This table is sent by the SETBIAS command to update clock board values.
2219                                ; The format is BBBB DDDD DDMM VVVV VVVV VVVV (board, DAC, Mode, Value)
2220   
2221      Y:00006E Y:00006E         DACS      DC      EDACS-DACS-GENCNT
2222      Y:00006F Y:00006F                   DC      (CLK2<<8)+(0<<14)+@CVI((RG_HI+10.0)/20.0*4095) ; RG High
2223      Y:000070 Y:000070                   DC      (CLK2<<8)+(1<<14)+@CVI((RG_LO+10.0)/20.0*4095) ; RG Low
2224      Y:000071 Y:000071                   DC      (CLK2<<8)+(2<<14)+@CVI((P1_HI+10.0)/20.0*4095) ; P1 High -- storage
2225      Y:000072 Y:000072                   DC      (CLK2<<8)+(3<<14)+@CVI((P1_LO+10.0)/20.0*4095) ; P1 Low
2226      Y:000073 Y:000073                   DC      (CLK2<<8)+(4<<14)+@CVI((P2_HI+10.0)/20.0*4095) ; P2 High
2227      Y:000074 Y:000074                   DC      (CLK2<<8)+(5<<14)+@CVI((P2_LO+10.0)/20.0*4095) ; P2 Low
2228      Y:000075 Y:000075                   DC      (CLK2<<8)+(6<<14)+@CVI((P3_HI+10.0)/20.0*4095) ; P3 High
2229      Y:000076 Y:000076                   DC      (CLK2<<8)+(7<<14)+@CVI((P3_LO+10.0)/20.0*4095) ; P3 Low
2230      Y:000077 Y:000077                   DC      (CLK2<<8)+(8<<14)+@CVI((S1_HI+10.0)/20.0*4095) ; S1 High -- serials
2231      Y:000078 Y:000078                   DC      (CLK2<<8)+(9<<14)+@CVI((S1_LO+10.0)/20.0*4095) ; S1 Low
2232      Y:000079 Y:000079                   DC      (CLK2<<8)+(10<<14)+@CVI((S3_HI+10.0)/20.0*4095) ; S3 High
2233      Y:00007A Y:00007A                   DC      (CLK2<<8)+(11<<14)+@CVI((S3_LO+10.0)/20.0*4095) ; S3 Low
2234      Y:00007B Y:00007B                   DC      (CLK2<<8)+(12<<14)+@CVI((S2_HI+10.0)/20.0*4095) ; S2 High
2235      Y:00007C Y:00007C                   DC      (CLK2<<8)+(13<<14)+@CVI((S2_LO+10.0)/20.0*4095) ; S2 Low
2236      Y:00007D Y:00007D                   DC      (CLK2<<8)+(14<<14)+@CVI((Q3_HI+10.0)/20.0*4095) ; Q3 High -- image
2237      Y:00007E Y:00007E                   DC      (CLK2<<8)+(15<<14)+@CVI((Q3_LO+10.0)/20.0*4095) ; Q3 Low
2238      Y:00007F Y:00007F                   DC      (CLK2<<8)+(16<<14)+@CVI((Q2_HI+10.0)/20.0*4095) ; Q2 High
2239      Y:000080 Y:000080                   DC      (CLK2<<8)+(17<<14)+@CVI((Q2_LO+10.0)/20.0*4095) ; Q2 Low
2240      Y:000081 Y:000081                   DC      (CLK2<<8)+(18<<14)+@CVI((Q1_HI+10.0)/20.0*4095) ; Q1 High
2241      Y:000082 Y:000082                   DC      (CLK2<<8)+(19<<14)+@CVI((Q1_LO+10.0)/20.0*4095) ; Q1 Low
2242      Y:000083 Y:000083                   DC      (CLK2<<8)+(20<<14)+@CVI((SW_HI+10.0)/20.0*4095) ; SW High
2243      Y:000084 Y:000084                   DC      (CLK2<<8)+(21<<14)+@CVI((SW_LO+10.0)/20.0*4095) ; SW Low
2244      Y:000085 Y:000085                   DC      (CLK2<<8)+(22<<14)+@CVI((TG_HI+10.0)/20.0*4095) ; TG High
2245      Y:000086 Y:000086                   DC      (CLK2<<8)+(23<<14)+@CVI((TG_LO+10.0)/20.0*4095) ; TG Low
2246   
2247                                ; Set gain and integrator speed [$board-c3-speed-gain]
2248                                ;  speed: f => fast, c => slow
Motorola DSP56300 Assembler  Version 6.3.4   11-06-03  13:11:41  DACS.asm  Page 41



2249                                ;  gain: 77, bb, dd, ee => 1x,2x,5x,10x; [ChanB+ChanA]
2250   
2251      Y:000087 Y:000087                   DC      $0c3cdd                           ; x5 Gain, slow integrate, board #0
2252   
2253                                ; Output offset voltages to get around 1000 DN A/D units on a dark frame
2254   
2255      Y:000088 Y:000088                   DC      $0c4000+OFFSET0+OFFSET            ; Output video offset, Output #0
2256      Y:000089 Y:000089                   DC      $0cc000+OFFSET1+OFFSET            ; Output video offset, Output #1
2257   
2258                                ; DC bias voltages
2259   
2260      Y:00008A Y:00008A                   DC      $0d0000+@CVI((VOD-7.5)/22.5*4095) ; Vod (7.5-30), pin #1,  VID0
2261      Y:00008B Y:00008B                   DC      $0d4000+@CVI((VOD-7.5)/22.5*4095) ; Vod (7.5-30), pin #2,  VID0
2262      Y:00008C Y:00008C                   DC      $0d8000+@CVI((VRD-5.0)/15.0*4095) ; Vrd (5-20),   pin #3,  VID0
2263      Y:00008D Y:00008D                   DC      $0e0000+@CVI((B5-5.0)/15.0*4095)  ; B5  (5-20),   pin #5,  VID0
2264      Y:00008E Y:00008E                   DC      $0f0000+@CVI((B7+5.0)/10.0*4095)  ; B7  (-5-+5),  pin #9,  VID0
2265      Y:00008F Y:00008F                   DC      $0f8000+@CVI((VOG+10.0)/20.0*4095) ; Vog (-10-+10),pin #11, VID0
2266      Y:000090 Y:000090                   DC      $0fc000+@CVI((VOG+10.0)/20.0*4095) ; Vog (-10-+10),pin #12, VID0
2267                                EDACS
2268   
2269                                ; *** timing NOP ***
2270      Y:000091 Y:000091         TNOP      DC      ETNOP-TNOP-GENCNT
2271      Y:000092 Y:000092                   DC      $00E000
2272      Y:000093 Y:000093                   DC      $00E000
2273                                ETNOP
2274   
2275                                ; ******** END OF WAVEFORM.ASM **********
2276   
2277                                 END_APPLICATON_Y_MEMORY
2278      000094                              EQU     @LCV(L)
2279   
2280                                ; End of program
2281                                          END

0    Errors
0    Warnings


