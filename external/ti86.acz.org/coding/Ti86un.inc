;These are some useful 86 equates that haven't been officially released by TI.
;Dux Gregis  assets@eden.rutgers.edu
;March 18, 1998

;
;ROM calls

;from Pat Milheron's Pede

_shracc            equ      4383h
_jforce            equ      409Ch	;force out of program (easier to remember)
_formreal          equ      5191h
_ckop1fp0          equ      449Bh	;check OP1 for flt point 0, set z if true
_ckop1pos          equ      450Fh
_mov10op2add       equ      5464h
_cphlde            equ      403Ch	;compare hl and de, set z flag if equal
_ldhlind           equ      4010h


;
;
_off			equ	$4101		;turn calc off normally
_dispahl		equ	$4a33		;displays ahl
_dispOP1		equ	$515b		;display op1 as result
_cpOP1OP2		equ	$41fb		;compare OP1 to OP2
_clrText		equ	$4ab5		;clear text shadow
_ldhlz		equ	$437b		;write b zeros to (hl)
_ldhlhl		equ	$5928		;move the contents of (hl) into hl
_error		equ	$419c		;invoke error message, _ERRNO = error #
_instError		equ	$41a1		;install error handler, hl = handler
_removError		equ	$41a4		;remove error handler
_exec_basic		equ	$4c47		;program name in OP1
_conv_ahl		equ	$4633		;convert abs address in ahl to asic
_inc_ahl		equ	$4637		;increment ahl
_resetAPD		equ	$4060		;reset APD counter
_cursOn		equ	$4994		;turn on cursor at curRow, curCol
_HLdivA		equ	$4048		;divide hl by a, product output in hl
_HLdiv10		equ	$4044		;divide hl by 10
_negOP1		equ	$5494		;negate OP1
_setxxOP1		equ	$4613		;convert hex # in a to flt point in OP1
_setxxxxOP2		equ	$461b		;convert hex # in hl to flt point in OP2
_setxxOP2		equ	$4617		;convert hex # in a to flt point in OP2
_setTok		equ	$5221		;set token at ahl with de
_removTok		equ	$4119		;remove all user tokens

_randint		equ	$5544
;Random Integer in OP1, for b >= a
;Input: _OP1 = a; _FPS = b; a and b are the range of the random integer
;Output: _OP1 = random integer

_checkasm		equ	$46af
;check if program is assembly
;Input: pointer in bde (use rst 10h)
;Output: pointer in ahl, z flag set if asm

_instTok		equ	$575c
;install user function
;Input: function name in OP1, bc = end of program, de = symbol table,
;		hl = menu table


#define create_menu	call $49c8 \ call $49e8
;Input: hl = pointer to menu data table

;Example,
;To invoke the math menu do this:

 ld hl,_mMath
 create_menu


;***************************************************************************

;
;flags

APDflags		equ	8		;iy offset
APDable		equ	2		;enable APD counter
APDlock		equ	3		;lock APD
APDdone		equ	4		;APD has expired

;Example,
;To turn off the calc using APD do this:

 res APDlock,(iy+APDflags)
 set APDdone,(iy+APDflags)
 call _off


altflags		equ	$23		;iy offset
altFont		equ	0		;enable user font
altExec		equ	2		;enable user interrupt routine
altOn			equ	3		;enable user on routine
altLink		equ	4		;enable user link routine
altExpr		equ	6		;enable [sqrt]EXPR
altOff		equ	7		;enable user off routine


;
eshflags		equ	$24		;iy offset
eshParse		equ	0		;enable [sqrt]PARSE
eshForm		equ	1		;enable [sqrt]FORM
eshExec		equ	2		;enable [sqrt]EXEC
eshHome		equ	4		;enable [sqrt]HOME
eshCmdtok		equ	5		;enable [sqrt]CMDTOK
eshKey		equ	6		;enable [sqrt]KEY
eshGrf		equ	7		;enable [sqrt]GRF



;asm flag offsets (for programmers)
i1flags		equ	$28		;iy offset
i2flags		equ	$29		;iy offset
i3flags		equ	$2a		;iy offset
i4flags		equ	$2b		;iy offset
i5flags		equ	$2c		;iy offset
i6flags		equ	$2d		;iy offset
i7flags		equ	$2e		;iy offset

dotflags		equ	$2f		;iy offset
dot39			equ	7		;the 39 steps

;***************************************************************************

;
;Esh equates

sqrtEXPR			equ		$5988
sqrtPARSE			equ		$59b3
sqrtEXEC			equ		$59f4
sqrtFORM			equ		$5a13
sqrtCMDTOK			equ		$5a37
sqrtHOME			equ		$5a69
sqrtKEY			equ		$5a92
sqrtGRF			equ		$5ab6

;Example,
;To put the program name [sqrt]EXEC in OP1 do this:

 ld hl,sqrtEXEC
 rst 20h

;***************************************************************************

;
;calc state equates

sHome		equ	1		;home screen
sPoly		equ	2		;polynomial solver
sSimult	equ	3		;simultaneous equation solver
sCons		equ	5		;constant editor
sVectr	equ	6		;vector editor
sMatrx	equ	7		;matrix editor
sPrgm		equ	8		;program editor
sInter	equ	$0c		;interpolate/extrapolate editor
sList		equ	$0e		;list/stat editor
sTol		equ	$12		;tolerance
sTable	equ	$19		;table
sTblst	equ	$1a		;table setup
sLink		equ	$1b		;link
sMem		equ	$1d		;reset mem prompt
sDefaults	equ	$1e		;reset defaults prompt
sAll		equ	$1f		;reset all prompt
sRAM		equ	$20		;RAM
sMode		equ	$21		;mode/self test
sDelete	equ	$23		;delete variables
sFunc		equ	$49		;function editor (all modes)
sWind		equ	$4a		;window editor
sGraph	equ	$4c		;graph
sIntCond	equ	$53		;initial conditions prompt
sForm		equ	$62		;graph format
sCatlg	equ	$96		;catlg-vars
sError	equ	$98		;error message

_CXCURAPP			equ	$c1b4		;current calc state


;***************************************************************************

;
;error state equates

;To find the error state add the error number (in hex) to $80.
;This can be used with _CXCURAPP to override error keypresses.
;Some common error states:

eBreak	equ	$86
eSyntax	equ	$87
eDataType	equ	$8a
eUndefined	equ	$8e

_ERRNO			equ	$c381		;present error state
_errOffset			equ	$c384		;cursor offset of error on line

;Example,
;To create an error handler that throws a data type exception error:

 ld hl,errorhandler
 call _instError
;code
 jp _removError

errorhandler:
 ld a,eDataType
 ld (_ERRNO),a
 jp _error


;***************************************************************************

;
;RAM addresses

_P_IMATHPTR1		equ	$c0d8
_P_IMATHPTR2		equ	$c0db
_P_IMATHPTR3		equ	$c0de
_P_IMATHPTR4		equ	$c0e1
_P_IMATHPTR5		equ	$c0e4
_textShadCur		equ	$c1a1
_textShadTop		equ	$c1a3
_textShadAlph		equ	$c1a4
_textShadIns		equ	$c1a5
_textAccent			equ	$c1a6
_cxMain			equ	$c1a7
_cxPPutAway			equ	$c1a9
_cxPutAway			equ	$c1ab
_cxRedisp			equ	$c1ad
_cxErrorEP			equ	$c1af
_cxSizeWind			equ	$c1b1
_cxPage			equ	$c1b3
_varType			equ	$c1ee
_varCurrent			equ	$c1ef
_menuDyn1			equ	$c242
_ioPrompt			equ	$c324
_FPBASE			equ	$d28b
_FPS				equ	$d28d
_OPBASE			equ	$d28f
_OPS				equ	$d291
_PTempCnt			equ	$d293
_CLEANTMP			equ	$d295
_MCustM			equ	$d1c3		;custom menu
_CustMSav			equ	$d1c5
_custmnames			equ	$d1e3
_altlfontptr		equ	$d2ed
_alt_ret_status		equ	$d2f9		;$11 to enable alt asm ret
_alt_ret_jmp_page		equ	$d2fa
_alt_ret_jmp_addr		equ	$d2fb
_alt_int_chksum		equ	$d2fd
_alt_interrupt_exec	equ	$d2fe
_alt_slink_chksum 	equ	$d3C6
_alt_slink_exec		equ	$d3c7
_alt_on_chksum		equ	$d48f
_alt_on_exec		equ	$d490
_alt_off_chksum		equ	$d558
_alt_off_exec		equ	$d559
_ASAP_IND			equ	$d623
_mMath			equ	$d64c		;math menu
_mMath_asap1		equ	$d65a
_mMath_asap2		equ	$d65c
_mMath_asap3		equ	$d65e
_iASAP1			equ	$d66c
_iASAP2			equ	$d678
_iASAP3			equ	$d684
_iASAP4			equ	$d690
_iASAP5			equ	$d69c
_iASAP6			equ	$d6a8
_iASAP7			equ	$d6b4
_iASAP8			equ	$d6c0
_iASAP9			equ	$d6cc
_asap_nl1			equ	$d6d8
_asap_nl2			equ	$d6e1
_asap_nl3			equ	$d6ea
_asapvar			equ	$d6fc
_tokspell_asap1		equ	$d706
_tokspell_asap2		equ	$d708
_tokspell_asap3		equ	$d70a
_numtok_asap1		equ	$d70e
_numtok_asap2		equ	$d70f
_numtok_asap3		equ	$d710
_eostbl_asap1		equ	$d712
_eostbl_asap2		equ	$d714
_eostbl_asap3		equ	$d716
_reinstall_asap1		equ	$d722
_reinstall_asap2		equ	$d724
_reinstall_asap3		equ	$d726
_lcdmem			equ	$fc00
_VIDEOMEM			equ	$fc00
