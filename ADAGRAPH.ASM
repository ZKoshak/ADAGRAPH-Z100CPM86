PACKAGE ASSEMBLY ADAGRAPH
						JMP 			MAIN
;******************************************************************************
;******************************************************************************
;PROCEDURE CLS IS USED TO PERFORM A CLEAR SCREEN OPERATION
PROC CLS;
						PUSH			AX
						IN				AL, 0D8H			;SAVE VIDEO STATUS
						PUSH			AX
						MOV				AL, 0FH
						OUT				0D8H, AL			;BLANK THE SCREEN
						IN				AL, 0DBH
						AND				AL, 0F7H
						OUT				0DBH, AL			;SET BIT 3 = 0
						IN				AL, 0D9H
						AND				AL, 0F7H
						OUT				0D9H, AL			;ENABLE CLRSCRN SIGNAL
						MOV				CX, 6680			;INIT COUNTER FOR TIME DELAY
DELAY:			NOP											;TIME DELAY TO ALLOW VIDEO PROCESSOR
						LOOP			DELAY					;TIME TO CLEAR VIDEO MEMORY
						IN				AL, 0D9H
						OR				AL, 08H
						OUT				0D9H, AL			;DISABLE CLRSCRN SIGNAL
						POP				AX
						OUT				0D8H, AL			;RESTORE SYSTEM STATUS
						POP				AX
						RET
END PROC CLS;
;******************************************************************************
;******************************************************************************
;PROCEDURE COLOR IS USED TO ENABLE COLOR PLANES TO PROVIDE THE SELECTED
;COLOR AND THE E SEGMENT REGISTER IS INITIALIZED TO ALLOW WRITING TO
;THE ENABLED COLOR PLANES.
PROC COLOR;
						POP				DX									;SAVE RETURN ADDRESS
						POP				AX									;GET COLOR CODE
						PUSH			DX									;RESTORE RETURN ADDRESS
						AND				AX, 7								;MASK COLOR CODE TO SET STATUS FLAGS
						JNZ				COLORl
						MOV				[COL_PL1], 0C000H		;COLOR IS WHITE
						MOV				[COL_PL2], 0D000H
						MOV				[COL_PL3], 0E000H
						JMP				EXIT_COL
COLORl:			SUB				AL, 1
						JNZ				COLOR2
						MOV				[COL_PL1], 0C000H		;COLOR IS CYAN
						MOV				[COL_PL2], 0E000H
						MOV				[COL_PL3], 0E000H
						JMP				EXIT_COL
COLOR2:			SUB				AL, 1
						JNZ				COLOR3
						MOV				[COL_PL1], 0C000H		;COLOR IS MAGENTA
						MOV				[COL_PL2], 0D000H
						MOV				[COL_PL3], 0D000H
						JMP				EXIT_COL
COLOR3:			SUB				AL, 1
						JNZ				COLOR4
						MOV				[COL_PL1], 0C000H		;COLOR IS BLUE
						MOV				[COL_PL2], 0C000H
						MOV				[COL_PL3], 0C000H
						JMP				EXIT_COL
COLOR4:			SUB				AL, 1
						JNZ				COLOR5
						MOV				[COL_PL1], 0D000H		;COLOR IS YELLOW
						MOV				[COL_PL2], 0E000H
						MOV				[COL_PL3], 0E000H
						JMP				EXIT_COL
COLOR5:			SUB				AL, 1
						JNZ				COLOR6
						MOV				[COL_PL1], 0E000H		;COLOR IS GREEN
						MOV				[COL_PL2], 0E000H
						MOV				[COL_PL3], 0E000H
						JMP				EXIT_COL
COLOR6:			SUB				AL, 1
						JNZ				EXIT_COL
						MOV				[COL_PL1], 0D000H		;COLOR IS RED
						MOV				[COL_PL2], 0D000H
						MOV				[COL_PL3], 0D000H
						JMP				EXIT_COL
EXIT_COL:		MOV				AL, 78H							;DISABLE SIMULTANEOUS WRITE
						OUT				0D8H, AL
						RET
END PROC COLOR;
;******************************************************************************
;******************************************************************************
;PROCEDURE RESET_CURS IS USED TO ERASE THE GRAPHICS CURSOR
;AN (X,Y) POSITION IS INPUT TO THE PROCEDURE AND THE A BLOCK OF
;ADDRESSES IS CLEARED AT THE CURSOR LOCATION
PROC RESET_CURS;
						MOV				[SEGMENT_E], ES 		;SAVE SEG E STATUS
						POP				AX									;SAVE RETURN ADDRESS
						POP				[Y_POS]							;GET Y POSITION
						POP				[X_POS]							;GET X POSITION
						PUSH			AX									;RESTORE RETURN ADDRESS
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			ADJ_SL							;ADJUST Y POSITION TO A DISPLAYABLE
						CALL			REL_VID_ADDR				;SCAN LINE & GET VIDEO ADDRESS
						POP				BX
						CALL			BLANK_GCURS
						SUB				BX, 1
						CALL			BLANK_GCURS
						SUB				[Y_POS], 1
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			ADJ_SL
						CALL			REL_VID_ADDR
						POP				BX
						CALL			BLANK_GCURS
						SUB				[Y_POS], 1
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			ADJ_SL
						CALL			REL_VID_ADDR
						POP				BX
						CALL			BLANK_GCURS
						ADD				[Y_POS], 3
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			ADJ_SL
						CALL			REL_VID_ADDR
						POP				BX
						CALL			BLANK_GCURS
						ADD				[Y_POS], 1
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			ADJ_SL
						CALL			REL_VID_ADDR
						POP				BX
						CALL			BLANK_GCURS
						MOV				ES, [SEGMENT_E]			;RESTORE SEG E
						RET
END PROC RESET_CURS;
;******************************************************************************
;******************************************************************************
;PROCEDURE BLANK_GCURS IS USED BY PROCEDURE RESET_CURS TO ERASE A CURSOR
PROC BLANK_GCURS;
						MOV				AX, [COL_PL1]
						MOV				ES, AX
						SEG				ES
						MOV				[BX], 0
						MOV				AX, [COL_PL2]
						MOV				ES, AX
						SEG				ES
						MOV				[BX], 0
						MOV				AX, [COL_PL3]
						MOV				ES, AX
						SEG				ES
						MOV				[BX], 0
						RET
END PROC BLANK_GCURS;
;******************************************************************************
;******************************************************************************
;PROCEDURE SET_CURS IS USED TO DISPLAY A CURSOR AT THE INPUT
;(X,Y) POSITION. THE GRAPHICS CURSOR DISPLAYED IS A "+"
PROC SET CURS;
; CALCULATE MEMORY ADDRESS OF MEW CURSOR POSITION
						MOV				[SEGMENT_E], ES			;SAVE SEG E STATUS
						POP				AX									;SAVE RETURN ADDRESS
						POP				[Y_POS]							;GET Y POSITION FROM STACK
						POP				[X_POS]							;GET X POSITION FROM STACK
						PUSH			AX									;REPLACE RETURN ADDRESS
						MOV				DX, [Y_POS]
						PUSH			[Y_POS]
						CALL			ADJ_SL
						POP				BX									;GET CORRECTED Y LINE NUMBER
;THE CURSOR IS MADE UP OF FIVE COMPONENTS LABELED CURS_0 TO CURS_4
						MOV				[CURS_0], DX				;PUT THE LINE NUMBER INTO
						MOV				[CURS_1], DX				;EACH OF THE CURSOR ROWS
						MOV				[CURS_2], BX
						MOV				[CURS_3], DX
						MOV				[CURS_4], DX
						SUB				[CURS_0], 2
						MOV				AX, [CURS 0]
						JNS				C0
						MOV				AX, 3
						ADD				[CURS_0], AX				;ADJUST EACH CURSOR ROW TO REFLECT IT
C0: 				PUSH			[CURS_0]						;DISTANCE FROM CURSOR CENTER POSITION
						CALL			ADJ_SL							;WHICH IS CURS_2
						POP				[CURS_0]						;THEN CALL PROCEDURE ADJ_SL TO ASSURE
						SUB				[CURS_1], 1 				;THAT EACH CURSOR ROW IS LOCATED ON
						MOV				AX, [CURS_1]				;A DISFLAYABLE SCAN LINE
						JNS				C1
						ADD				[CURS_1], 2
C1:					PUSH			[CURS_1]
						CALL			ADJ_SL
						POP				[CURS_1]
						ADD				[CURS_3], 1
						PUSH			[CURS_3]
						CALL			ADJ_SL
						POP				[CURS_3]
						ADD				[CURS_4], 2
						PUSH			[CURS_4]
						CALL			ADJ_SL
						POP				[CURS_4]
						PUSH			[X_POS]
						PUSH			BX
						CALL			REL_VID_ADDR
						POP				BX
						PUSH			[X_POS]
						PUSH			[CURS_0]
						CALL			REL_VID_ADDR
						POP				[CURS_0]
						PUSH			[X_POS]
						PUSH			[CURS_1]
						CALL			REL_VID_ADDR
						POP				[CURS_1]
						PUSH			[X_POS]
						PUSH			[CURS_2]
						CALL			REL_VID_ADDR
						POP				[CURS_2]
						PUSH			[X_POS]
						PUSH			[CURS_3]
						CALL			REL_VID_ADDR
						POP				[CURS_3]
						PUSH			[X_POS]
						PUSH			[CURS_4]
						CALL			REL_VID_ADDR
						POP				[CURS_4]
						MOV				AX, [X_POS]					;GET X POSITION FOR TEST
						AND				AX, 07H							;CALCULATE CURSOR BIT POSITION IN ADDR
;
;DRAW THE CURSOR BASED ON CURSOR CENTER BIT POSITION WITHIN A BYTE
;THIS SPLITS THE CURSOR ACROSS BYTE BOUNDARIES FOR FULL SCREEN COVERAGE
						JNZ				BIT1								;TEST FOR CURSOR IN X PIXEL POS. 0
						MOV				AL, 3
						MOV				BX, [CURS_2]
						SUB				BX, 1
						CALL			DISP_GCURS
						MOV				AL, 0E0H
						ADD				BX, 1
						CALL			DISP_GCURS
						MOV				AL, 80H
						MOV				BX, [CURS_0]
						CALL			DISP_GCURS
						MOV				BX, [CURS_1]
						CALL			DISP_GCURS
						MOV				BX, [CURS_3]
						CALL			DISP_GCURS
						MOV				BX, [CURS_4]
						CALL			DISP_GCURS
						JMP				EXIT
BIT1:				SUB				AL, 1								;DECREMENT BIT COUNT FOR NEXT TEST
						JNZ				BIT2								;TEST FOR CURSOR IN X PIXEL POS. 1
						MOV				BX, [CURS_2]
						SUB				BX, 1
						MOV				AL, 1
						CALL			DISP_GCURS
						MOV				AL, 0F0H
						ADD				BX, 1
						CALL			DISP_GCURS
						MOV				AL, 40H
						MOV				BX, [CURS_0]
						CALL			DISP_GCURS
						MOV				BX, [CURS_1]
						CALL			DISP_GCURS
						MOV				BX, [CURS_3]
						CALL			DISP_GCURS
						MOV				BX, [CURS_4]
						CALL			DISP_GCURS
						JMP				EXIT
BIT2:				SUB				AL, 1								;DECREMENT BIT COUNT FOR NEXT TEST
						JNZ				BIT3								;TEST FOR CURSOR IN X PIXEL POS. 2
						MOV				AL, 0F8H
						MOV				BX, [CURS_2]
						CALL			DISP_GCURS
						MOV				AL, 20H
						MOV				BX, [CURS_0]
						CALL			DISP_GCURS
						MOV				BX, [CURS_1]
						CALL			DISP_GCURS
						MOV				BX, [CURS_3]
						CALL			DISP_GCURS
						MOV				BX, [CURS_4]
						CALL			DISP_GCURS
						JMP				EXIT
BIT3:				SUB				AL, 1								;DECREMENT BIT COUNT FOR NEXT TEST
						JNZ				BIT4								;TEST FOR CURSOR IN X PIXEL POS. 3
						MOV				AL, 7CH
						MOV				BX, [CURS_2]
						CALL			DISP_GCURS
						MOV				AL, 10H
						MOV				BX, [CURS_0]
						CALL			DISP_GCURS
						MOV				BX, [CURS_1]
						CALL			DISP_GCURS
						MOV				BX, [CURS_3]
						CALL			DISP_GCURS
						MOV				BX, [CURS_4]
						CALL			DISP_GCURS
						JMP	EXIT
BIT4:				SUB				AL, 1								;DECREMENT BIT COUNT FOR NEXT TEST
						JNZ				BIT5								;TEST FOR CURSOR IN X PIXEL POS. 4
						MOV				AL, 3EH
						MOV				BX, [CURS_2]
						CALL			DISP_GCURS
						MOV				AL, 8
						MOV				BX, [CURS_0]
						CALL			DISP_GCURS
						MOV				BX, [CURS_1]
						CALL			DISP_GCURS
						MOV				BX, [CURS_3]
						CALL			DISP_GCURS
						MOV				BX, [CURS_4]
						CALL			DISP_GCURS
						JMP				EXIT
BIT5:				SUB				AL, 1								;DECREMENT BIT COUNT FOR NEXT TEST
						JNZ				BIT6								;TEST FOR CURSOR IN X PIXEL POS. 5
						MOV				AL, 1FH
						MOV				BX, [CURS_2]
						CALL			DISP_GCURS
						MOV				AL, 4
						MOV				BX, [CURS_0]
						CALL			DISP_GCURS
						MOV				BX, [CURS_1]
						CALL			DISP_GCURS
						MOV				BX, [CURS_3]
						CALL			DISP_GCURS
						MOV				BX, [CURS_4]
						CALL			DISP_GCURS
						JMP				EXIT
BIT6:				SUB				AL, 1								;DECREMENT BIT COUNT FOR NEXT TEST
						JNZ				BIT7								;TEST FOR CURSOR IN X PIXEL POS. 6
						MOV				AL, 0FH
						MOV				BX, [CURS_2]
						CALL			DISP_GCURS
						MOV				AL, 80H
						ADD				BX, 1
						CALL			DISP_GCURS
						MOV				AL, 2
						MOV				BX, [CURS_0]
						CALL			DISP_GCURS
						MOV				BX, [CURS_1]
						CALL			DISP_GCURS
						MOV				BX, [CURS_3]
						CALL			DISP_GCURS
						MOV				BX, [CURS_4]
						CALL			DISP_GCURS
						JMP				EXIT
BIT7:				MOV				AL, 7
						MOV				BX, [CURS_2]
						CALL			DISP_GCURS
						MOV				AL, 0C0H
						ADD				BX, 1
						CALL			DISP_GCURS
						MOV				AL, 1
						MOV				BX, [CURS_0]
						CALL			DISP_GCURS
						MOV				BX, [CURS_1]
						CALL			DISP_GCURS
						MOV				BX, [CURS_3]
						CALL			DISP_GCURS
						MOV				BX, [CURS_4]
						CALL			DISP_GCURS
EXIT:				MOV				ES, [SEGMENT_E] 		;RESTORE SEG E
						RET
END PROC SET_CURS;
;******************************************************************************
;******************************************************************************
;PROCEDURE DISP_GCURS IS USED BY PROCEDURE SET_CURS TO DISPLAY A CURSOR
PROC DISP_GCURS;
						MOV				DX, [COL_PL1]
						MOV				ES, DX
						SEG				ES
						OR				[BX], AL
						MOV				DX, [COL_PL2]
						MOV				ES, DX
						SEG				ES
						OR				[BX], AL
						MOV				DX, [COL_PL3]
						MOV				ES, DX
						SEG				ES
						OR				[BX], AL
						RET
END PROC DISP_GCURS;
;******************************************************************************
;******************************************************************************
;PROCEDURE ADJ_SL IS USED TO CORRECT Y POSITION TO INSURE
;THAT IT OCCURS ON A DISPLAYABLE SCAN LINE
PROC ADJ_SL;
						POP				[RET_ADJ_SL]				;SAVE RETURN ADDRESS
						POP				BX									;GET Y POSITION
						MOV				AX, BX
TST_Y:			SUB				AX, 9
						JNS				ADJ_Y
						JMP				EXIT_SL
ADJ_Y:			ADD				BX, 7
						JMP				TST_Y
EXIT_SL:		PUSH			BX									;RETURN CORRECTED Y POSITION
						PUSH			[RET_ADJ_SL]				;RESTORE RETURN ADDRESS
						RET
END PROC ADJ_SL;
;******************************************************************************
;******************************************************************************
;PROCEDURE REL_VID_ADDR ACCEPTS X AND Y SCREEN COORDINATES AND CONVERTS
;THEM TO A BYTE ADDRESS IN MEMORY CORRESPONDING TO THE X Y POSITION
PROC REL_VID_ADDR;
						POP				[RET_RVA]						;SAVE RETURN ADDRESS
						POP				BX									;GET Y POSITION
						TEST			BX, 8000H						;TEST FOR Y < 0
						JNS				TST_YUPR
						MOV				BX, 0
TST_YUPR:		MOV				AX, 376							;TEST FOR Y > 376
						SUB				AX, BX
						JNS				Y_IN_BND
						MOV				BX, 376
Y_IN_BND:		MOV				AX, 80H							;PUT SCALE FACTOR IN AX
						MUL				BX									;AND SCALE Y BASED ON LINE NUMBER
						POP				BX									;GET X POSITION
						TEST			BX, 8000H						;TEST FOR X < 0
						JNS				TST_XUPR
						MOV				BX, 0
TST_XUPR:		MOV				DX, 639							;TEST FOR X > 639
						SUB				DX, BX
						JNS				X_IN_BND
						MOV				BX, 639
X_IN_BND:		MOV				CL, 3								;AND DETERMINE BYTE X OFFSET
						SHR				BX, CL							;BY DIVIDING X POSITION BY 8
						ADD				BX, AX							;ADD X OFFSET TO GET BYTE ADDRESS
						PUSH			BX									;RETURN RELATIVE BYTE ADDRESS
						PUSH			[RET_RVA]						;RESTORE RETURN ADDRESS
						RET
END PROC REL_VID_ADDR;
;******************************************************************************
;******************************************************************************
;LINE DRAWING PROCEDURE WITH COLOR MIXING FOR CROSSING LINES
PROC DRAW_MLINE;
						POP				[RET_DML]						;SAVE RETURN ADDRESS
						MOV				[COL_MIX], 1				;ENABLE COLOR MIXING
						CALL			DRAWW_LINE					;GO DRAW THE LINE
						PUSH			[RET_DML]						;RESTORE RETURN ADDRESS
						RET
END PROC DRAW_MLINE;
;******************************************************************************
;******************************************************************************
;LINE DRAWING PROCEDURE WITHOUT COLOR MIXING FOR CROSSING LINES
PROC DRAW_LINE;
						POP				[RET_DML]						;SAVE RETURN ADDRESS
						MOV				[COL_MIX], 0				;DISABLE COLOR MIXING
						CALL			DRAWW_LINE					;GO DRAW THE LINE
						PUSH			[RET_DML]						;RESTORE RETURN ADDRESS
						RET
END PROC DRAW_LINE;
;******************************************************************************
;******************************************************************************
;PROCEDURE DRAWW_LINE PROVIDES PRIMITIVE LINE DRAWING CAPABILITIES
;THE SUBROUTINE ACCEPTS AS INPUT A PAIR OF ENDPOINTS IDENTIFIED BY
;(X, Y) COORDINATES
PROC DRAWW_LINE;
						MOV				BP, SP
						PUSH			DS
						MOV				BX, [BP+8]					;GET X START FROM STACK
						MOV				[X_START], BX
						MOV				BX, [BP+6]					;GET Y START FROM STACK
						MOV				[Y_START], BX
						MOV				BX, [BP+4]					;GET X END FROM STACK
						MOV				[X_END], BX
						MOV				AX, [BP+2]					;GET Y END FROM STACK
						MOV				[Y_END], AX
;TEST ORDERING OF Y COORDINATES. THE ALGORITHM EXPECTS TO FIND THE Y
;COORDINATE IN INCREASING ORDER OR 0.
						MOV				AX, [Y_END]
						SUB				AX, [Y_START]
						JNS				STO_DY							;JUMP IF Y ORDERING OK
						MOV				AX, [X_START]				;ELSE SWAP START AND END COORD.
						MOV				BX, [X_END]					;SO Y START VALUE IS LTE Y END
						MOV				[X_START], BX				;VALUE. THEN CALCULATE DELTA Y.
						MOV				[X _END], AX
						MOV				AX, [Y_START]
						MOV				BX, [Y_END]
						MOV				[Y_START], BX
						MOV				[Y_END], AX
						SUB				AX, BX
STO_DY:			MOV				[DELTA_Y], AX
						MOV				AX, [X_END] 				;CALCULATE DELTA X
						SUB				AX, [X_START]
						MOV				[DELTA_X], AX
						MOV				[INC_CTR], 1
						MOV				[L_ERROR], 0
						MOV				AX, [X_START]
						MOV				[X_POS], AX
						MOV				AX, [Y_START]
						MOV				[Y_POS], AX
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			LINE_SEG						;PLOT FIRST POINT
						TEST			[DELTA_X], 8000H		;TEST FOR NEGATIVE SLOPE
						JNS				TST_DY
						JMP				TST_DYZ
TST_DY:			TEST			[DELTA_Y], 7FFFH		;TEST FOR DELTA Y = 0
						JNZ				C_2_OR_3
						SUB				[DELTA_X], 1
CASE_1:			ADD				[X_POS]							;DRAW LINE FOR SPECIAL CASE WHERE
						PUSH			[X_POS]							;DX > 0 AND DY = 0
						PUSH			[Y_POS]
						CALL			LINE_SEG
						SUB				[DELTA_X], 1
						JNS				CASE_2
						JMP				EXIT_DL
C_2_OR_3:		MOV				AX, [DELTA_X]				;DX > 0 AND DY > 0
						SUB				AX, [DELTA_Y]
						JNS				CASE_2
						JMP				CASE_3
CASE_2:			MOV				AX, [DELTA_X]				;DX >= DY
						MOV				[END_CNT], AX
;
						MOV				BX, [DELTA_Y]				;ADD IN CORRECTION FACTOR FOR
						ADD				BX, 1								;SMOOTHING
						JNZ				C_CASE2							;CORR = DX/(DY+1)
						JMP				DR_C2
C_CASE2:		MOV				AX, [DELTA_X]
						MOV				DX, 0
						DIV				BX
						SUB				[L_ERROR], AX			;INIT ERROR VAL. WITH CORR. FACT.
;
DR_C2:			MOV				AX, [END_CNT]				;TEST INCREMENT COUNTER
						SUB				AX, [INC_CTR]
						JNS				DR_C2C
						JMP				EXIT_DL
DR_C2C:			TEST			[L_ERROR], 8000H		;TEST IF ERROR < 0
						JNS				CASE_2C
						ADD				[X_POS], 1					;ERROR < 0
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			LINE_SEG
						MOV				AX, [L_ERROR]
						ADD				AX, [DELTA_Y]
						MOV				[L_ERROR], AX
						ADD				[INC_CTR], 1
						JMP				DR_C2
CASE_2C:		ADD				[X_POS], 1 					;ERROR > 0
						ADD				[Y POS], 1
						PUSH			[X POS]
						PUSH			[Y POS]
						CALL			LINE_SEG
						MOV				AX, [L_ERROR]
						ADD				AX, [DELTA_Y]
						SUB				AX, [DELTA_X]
						MOV				[L_ERROR], AX
						ADD				[INC_CTR], 1
						JMP				DR_C2
CASE_3:			MOV				AX, [DELTA_Y]				;DY > DX
						MOV				[END_CNT], AX
;
						MOV				BX, [DELTA_X]				;ADD IN CORRECTION FACTOR FOR
						ADD				BX, 1								;SMOOTHING
						JNZ				C_CASE3							;CORR = DY/(DX+1)
						JMP				DR_C3
C_CASE3:		MOV				AX, [DELTA_Y]
						MOV				DX, 0
						DIV				BX
						MOV				[L_ERROR], AX				;INIT ERROR VAL. WITH CORR. FACT,
;
DR_C3:			MOV				AX, [END_CNT]				;TEST INCREMENT COUNTER
						SUB				AX, [INC_CTR]
						JNS				DR_C5C
						JMP				EXIT_DL
DR_C3C:			TEST			[L_ERROR], 8000H		;TEST FOR ERROR < 0
						JNS				CASE_3C
						ADD				[X_POS], 1					;ERROR < 0
						ADD				[Y_POS], 1
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			LINE_SEG
						MOV				AX, [L_ERROR]
						SUB				AX, [DELTA_X]
						ADD				AX, [DELTA Y]
						MOV				[L_ERROR], AX
						ADD				[INC_CTR], 1
						JMP				DR_C3								;ERROR >= 0
CASE_3C:		ADD				[Y_POS], 1
						PUSH			[X_POS]
						PUSH			[Y POS]
						CALL			LINE_SEG
						MOV				AX, [L_ERROR]
						SUB				AX, [DELTA_X]
						MOV				[L_ERROR], AX
						ADD				[INC_CTR], 1
						JMP				DR_C3
TST_DYZ:		TEST			[DELTA_Y], 7FFFH 		;TEST FOR DY > 0
						JNZ				C_5_OR_6
						MOV				AX, 0FFFFH					;PROCESS SPECIAL CASE WHERE DX < 0
						SUB				AX, [DELTA_X]				;AND DY = 0
						MOV				[DELTA X], AX
CASE_4:			SUB				[X_POS], 1
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			LINE_SEG
						SUB				[DELTA_X], 1
						JNS				CASE_4
						JMP				EXIT_DL
C_5_OR_6:		MOV				AX, 0								;CASE 3 OR 4. DX < 0 & DY > 0
						SUB				AX, [DELTA_X]
						SUB				AX, [DELTA_Y]
						JNS				CASE_5
						JMP				CASE_6
CASE_5:			MOV				AX, 0								;DY <= ABS(DX)
						SUB				AX, [DELTA_X]
						MOV				[END_CNT], AX
;
						MOV				BX, [DELTA_Y]				;ADD IN CORRECTION FACTOR FOR
						ADD				BX, 1								;SMOOTHING
						JNZ				C_CASE5							;CORR = DX/(DY+1)
						JMP				DR_C5
C_CASE5:		MOV				AX, 0
						SUB				AX, [DELTA_X]
						MOV				DX, 0
						DIV				BX
						SUB				[L_ERROR], AX				;INIT ERROR WITH CORR. FACT.
;
DR_C5:			MOV				AX, [END_CNT]				;TEST INCREMENT COUNTER
						SUB				AX, [INC_CTR]
						JNS				DR_C5C
						JMP				EXIT_DL
DR_C5C:			TEST			[L_ERROR], 8000H		;TEST IF ERROR < 0
						JNS				CASE_5C
						SUB				[X_POS], 1					;ERROR < 0
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			LINE_SEG
						MOV				AX, [L_ERROR]
						ADD				AX, [DELTA_Y]
						MOV				[L_ERROR], AX
						ADD				[INC_CTR], 1
						JMP				DR_C5
CASE_5C:		SUB				[X_POS], 1					;ERROR >= 0
						ADD				[Y_POS], 1
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			LINE_SEG
						MOV				AX, [L_ERROR]
						ADD				AX, [DELTA_X]
						ADD				AX, [DELTA_Y]
						MOV				[L_ERROR], AX
						ADD				[INC_CTR], 1
						JMP				DR_C5
CASE_6:			MOV				AX, [DELTA_Y]				;ABS(DX) < DY
						MOV				[END_CNT], AX
;
						MOV				BX, 1								;ADD IN CORRECTION FACTOR FOR
						SUB				BX, [DELTA_X]				;SMOOTHING
						JNZ				C_CASE6							;CORR = DY/(DX+1)
						JMP				DR_C6
C_CASE6:		MOV				AX, [DELTA_Y]
						MOV				DX, 0
						DIV				BX
						MOV				[L_ERROR], AX			;INIT ERROR WITH CORR. FACT,
;
DR_C6:			MOV				AX, [END_CNT]				;TEST INCREMENT COUNTER
						SUB				AX, [INC_CTR]
						JNS				DR_C6C
						JMP				EXIT_DL
DR_C6C:			TEST			[L_ERROR], 8000H		;TEST FOR ERROR < 0
						JNS				CASE_6C
						SUB				[X_POS], 1					;ERROR < 0
						ADD				[Y_POS], 1
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			LINE_SEG
						MOV				AX, [L_ERROR]
						ADD				AX, [DELTA_X]
						ADD				AX, [DELTA Y]
						MOV				[L_ERROR], AX
						ADD				[INC_CTR], 1
						JMP				DR_C6
CASE_6C:		ADD				[Y_POS], 1					;ERROR >= 0
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			LINE_SEG
						MOV				AX, [L_ERROR]
						ADD				AX, [DELTA_X]
						MOV				[L_ERROR], AX
						ADD				[INC_CTR], 1
						JMP				DR_C6
EXIT_DL:		POP				DS									;PREPARE TO EXIT PROCEDURE BY
						POP				AX									;RESTORING REGISTERS AND THEN
						POP				BX									;REMOVE INPUT PARAMETERS
						POP				BX									;FROM STACK
						POP				BX
						POP				BX
						PUSH			AX
						RET
END PROC DRAWW_LINE;
;******************************************************************************
;******************************************************************************
;PROCEDURE LINE_SEG ACCEPTS AS INPUT AN X AND Y POSITION AND CONVERTS
;THE POSITION INTO DISPLAYABLE PIXEL DATA
PROC LINE_SEG;
						MOV				[SEGMENT_E], ES			;SAVE SEG E STATUS
						MOV				ES, [COL_PL_ADDR]		;ENABLE SELECTED COLOR
						POP				[RET_LS]						;SAVE RETURN ADDRESS
						CALL			ADJ_SL							;CONVERT Y POS. TO DISPLAYABLE S.L.
						CALL			REL_VID_ADDR				;USE X & Y TO CALC REL . BYTE ADDR.
						POP				BX									;BX REGISTER HOLDS REL. BYTE ADDR.
						MOV				AX, [X_POS]					;MOV X POSITION TO AX REGISTER AMD
						AND				AX, 7								;CALCULATE X BIT POSITION WITHIN A
						JNZ				XBIT1								;BYTE FOR DISPLAY PURPOSES
						MOV				DL, 80H
						MOV				CL, 7FH
						JMP				OUT_LINE
XBITl:			SUB				AL, 1
						JNZ				XBIT2
						MOV				DL, 40H
						MOV				CL, 0BFH
						JMP				OUT_LINE
XBIT2:			SUB				AL, 1
						JNZ				XBIT3
						MOV				DL, 20H
						MOV				CL, 0DFH
						JMP				OUT_LINE
XBIT3:			SUB				AL, 1
						JNZ				XBIT4
						MOV				DL, 10H
						MOV				CL, 0EFH
						JMP				OUT_LINE
XBIT4:			SUB				AL, 1
						JNZ				XBIT5
						MOV				DL, 8
						MOV				CL, 0F7H
						JMP				OUT_LINE
XBIT5:			SUB				AL, 1
						JNZ				XBIT6
						MOV				DL, 4
						MOV				CL, 0FBH
						JMP				OUT_LINE
XBIT6:			SUB				AL, 1
						JNZ				XBIT7
						MOV				DL, 2
						MOV				CL, 0FDH
						JMP				OUT_LINE
XBIT7:			MOV				DL, 1
						MOV				CL, 0FEH
OUT_LINE:		CMP				[COL_MIX], 1				;TEST IF MIXING ENABLED
						JNS				LSC_MIX
						MOV				AX, 0C000H					;CLEAR SELECTED LOCATION IN ALL
						MOV				ES, AX							;COLOR PLANES IF NO MIXING
						SEG				ES
						AND				[BX], CL
						MOV				AX, 0D000H
						MOV				ES, AX
						SEG				ES
						AND				[BX], CL
						MOV				AX, 0E000H
						MOV				ES, AX
						SEG				ES
						AND				[BX], CL
LSC_MIX:		MOV				AX, [COL_PL1]
						MOV				ES, AX
						SEG				ES									;SELECT E SEGMENT FOR ADDRESSING OF
						OR				[BX], DL						;VIDEO OUTPUT THEN OUTPUT A BYTE
						MOV				AX, [COL_PL2]
						MOV				ES, AX
						SEG				ES
						OR				[BX], DL
						MOV				AX, [COL_PL3]
						MOV				ES, AX
						SEG				ES
						OR				[BX], DL
						PUSH			[RET_LS]						;RESTORE RETURN ADDRESS
						MOV				ES, [SEGMENT_E]			;RESTORE SEG E
						RET
END PROC LINE_SEG;
;******************************************************************************
;******************************************************************************
;PROCEDURE CIRCLE INPUTS X & Y COORDINATES OF THE CIRCLE CENTER
;AND A RADIUS VALUE. IT THEN DRAWS A CIRCLE
PROC CIRCLE;
						MOV				BP, SP
						MOV				AX, [BP+6]
						MOV				[X_CTR], AX					;GET X CENTER COORDINATE OFF STACK
						MOV				AX, [BP+4]
						MOV				[Y_CTR], AX					;GET Y CENTER COORDINATE OFF STACK
						MOV				DX, [BP+2]
						MOV				[Y_REL], DX					;GET RADIUS VALUE AND SET
						MOV				[X REL], 0					;INITIAL VALUES FOR X AND Y COORD.
						MOV				CL, 1
						SHL				DX, CL
						MOV				AX, 3
						SUB				AX, DX
						MOV				[P_VAL], AX
CIRC_LP:		MOV				AX, [Y_REL]					;TEST IF FINISHED DRAVJING CIRCLE
						SUB				AX, [X_REL]
						JNS				DR_CIRC
						POP				AX
						POP				BX									;REMOVE INPUT PARAMETERS FROM STACK
						POP				BX
						POP				BX
						PUSH			AX
						RET														;EXIT SUBROUTINE
;
;POINTS ON CIRCLE ARE PLOTTED IN GROUPS OF 8 WITH THE Y COORDINATE
;SCALED BY 1/2 TO COMPENSATE FOR X:Y RATIO IN THE DISPLAY
DR_CIRC:		MOV				AX, [X_CTR]					;CALCULATE POINT 1
						MOV				DX, [X_REL]
						ADD				AX, DX
						MOV				[X_POS], AX
						PUSH			AX
						MOV				AX, [Y_REL]
						MOV				CL, 1
						SHR				AX, CL
						ADD				AX, [Y_CTR]
						PUSH			AX
						CALL			ADJ_SL
						POP				[Y_POS]
						PUSH			[Y_POS]
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						CALL			CIR_PIXEL						;PLOT (X_CENTER+X, Y_CENTER+Y)
						MOV				AX, [X_CTR]					;CALCULATE POINT 2
						MOV				DX, [X_REL]
						SUB				AX, DX
						MOV				[X_POS], AX
						PUSH			AX
						PUSH			[Y_POS]
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						CALL			CIR_PIXEL						;PLOT (X_CENTER-X, Y_CENTER+Y)
						PUSH			[X_POS]							;CALCULATE POINT 3
						MOV				BX, [Y_REL]
						MOV				CL, 1
						SHR				BX, CL
						MOV				AX, [Y_CTR]
						SUB				AX, BX
						PUSH			AX
						CALL			ADJ_SL
						POP				[Y_POS]
						PUSH			[Y_POS]
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						CALL			CIR_PIXEL						;PLOT (X_CENTER-X, Y_CENTER-Y)
						MOV				AX, [X_CTR]					;CALCULATE POINT 4
						MOV				DX, [X_REL]
						ADD				AX, DX
						MOV				[X_POS], AX
						PUSH			AX
						PUSH			[Y_POS]
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						CALL			CIR_PIXEL						;PLOT (X_CENTER+X, Y_CENTER-Y)
						MOV				AX, [X_CTR]					;CALCULATE POINT 5
						MOV				DX, [Y_REL]
						ADD				AX, DX
						MOV				[X_POS], AX
						PUSH			AX
						MOV				AX, [X_REL]
						MOV				CL, 1
						SHR				AX, CL
						ADD				AX, [Y_CTR]
						PUSH			AX
						CALL			ADJ_SL
						POP				[Y_POS]
						PUSH			[Y_POS]
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						CALL			CIR_PIXEL						;PLOT (X_CENTER+Y, Y_CENTER+X)
						MOV				AX, [X_CTR]					;CALCULATE POINT 6
						MOV				DX, [Y_REL]
						SUB				AX, DX
						MOV				[X_POS], AX
						PUSH			AX
						PUSH			[Y_POS]
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						CALL			CIR_PIXEL						;PLOT (X_CENTER-Y, Y_CENTER+X;
						PUSH			[X_POS]							;CALCULATE POINT 7
						MOV				BX, [X_REL]
						MOV				CL, 1
						SHR				BX, CL
						MOV				AX, [Y_CTR]
						SUB				AX, BX
						PUSH			AX
						CALL			ADJ_SL
						POP				[Y_POS]
						PUSH			[Y_POS]
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						CALL			CIR_PIXEL						;PLOT (X_CENTER-Y, Y_CENTER-X)
						MOV				AX, [X_CTR]					;CALCULATE POINT 8
						MOV				DX, [Y_REL]
						ADD				AX, DX
						MOV				[X_POS], AX
						PUSH			AX
						PUSH			[Y_POS]
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						CALL			CIR_PIXEL						;PLOT (X_CENTER+Y, Y_CENTER-X)
;
						TEST			[P_VAL], 8000H			;TEST P FOR NEGATIVE VALUE
						JNS				P_DECY
						MOV				CL, 2								;P := P + (4 * X) + 6
						MOV				AX, [X_REL]
						SHL				AX, CL
						ADD				AX, 6
						ADD				[P_VAL], AX
						ADD				[X_REL], 1					;INCREMENT X COUNT
						JMP				CIRC_LP
P_DECY:			MOV				CL, 2								;P := P + 4 * (X - Y) + 10
						MOV				AX, [X_REL]
						SUB				AX, [Y_REL]
						SHL				AX, CL
						ADD				AX, 10
						ADD				[P_VAL], AX
						SUB				[Y_REL], 1					;DECREMENT Y COUNT
						ADD				[X REL], 1					;INCREMENT X COUNT
						JMP				CIRC_LP
END PROC CIRCLE;
;******************************************************************************
;******************************************************************************
;PROCEDURE CIR_PIXEL ACCEPTS AS INPUT A RELATIVE BYTE ADDRESS AND AN
;X COORDINATE POSITION AND SETS THE CORRESPONDING PIXEL
PROC CIR_PIXEL;
						MOV				[SEGMENT_E], ES			;SAVE SEG E STATUS
						POP				[RET_CPE]						;SAVE RETURN ADDRESS
						POP				DX									;GET X POSITION
						POP				BX									;GET RELATIVE BYTE ADDRESS
						AND				DX, 7
						JNZ				CPBIT1
						MOV				AL, 80H
						MOV				CL, 7FH
						JMP				CPIX_ON
CPBIT1:			SUB				DL, 1
						JNZ				CPBIT2
						MOV				AL, 40H
						MOV				CL, 0BFH
						JMP				CPIX_ON
CPBIT2:			SUB				DL, 1
						JNZ				CPBIT3
						MOV				AL, 20H
						MOV				CL, 0DFH
						JMP				CPIX_ON
CPBIT3:			SUB				DL, 1
						JNZ				CPBIT4
						MOV				AL, 10H
						MOV				CL, 0EFH
						JMP				CPIX_ON
CPBIT4:			SUB				DL, 1
						JNZ				CPBIT5
						MOV				AL, 8
						MOV				CL, 0F7H
						JMP				CPIX_ON
CPBIT5:			SUB				DL, 1
						JNZ				CPBIT6
						MOV				AL, 4
						MOV				CL, 0FBH
						JMP				CPIX_ON
CPBIT6:			SUB				DL, 1
						JNZ				CPBIT7
						MOV				AL, 2
						MOV				CL, 0FDH
						JMP				CPIX_ON
CPBIT7:			MOV				AL, 1
						MOV				CL, 0FEH
CPIX_ON:		MOV				DX, 0C000H					;CLEAR ALL COLOR PLANES AT SELECTED
						MOV				ES, DX							;PIXEL LOCATION BEFORE SETTING
						SEG				ES									;PIXEL TO DESIRED COLOR
						AND				[BX], CL
						MOV				DX, 0D000H
						MOV				ES, DX
						SEG				ES
						AND				[BX], CL
						MOV				DX, 0E000H
						MOV				ES, DX
						SEG				ES
						AND				[BX], CL
						MOV				DX, [COL_PL1]				;SET PIXEL TO DESIRED COLOR
						MOV				ES, DX
						SEG				ES
						OR				[BX], AL
						MOV				DX, [COL_PL2]
						MOV				ES, DX
						SEG				ES
						OR				[BX], AL
						MOV				DX, [COL_PL3]
						MOV				ES, DX
						SEG				ES
						OR				[BX], AL
						PUSH			[RET_CPE]
						MOV				ES, [SEGMENT_E]			;RESTORE SEG E
						RET
END PROC CIR_PIXEL
;******************************************************************************
;******************************************************************************
;PROCEDURE SET_PIXEL ACCEPTS AS INPUT AN (X,Y) COORDINATE AND SETS THE
;CORRESPONDING PIXEL TO THE SYSTEM COLOR
PROC SET_PIXEL;
						MOV				BP, SP
						MOV				[SEGMENT E], ES			;SAVE ES STATUS
						POP				[RET_SPE]						;SAVE RETURN ADDRESS
						MOV				AX, [BP+4]					;GET X POSITION
						MOV				[X_POS], AX
						CALL			ADJ_SL
						CALL			REL_VID_ADDR
						POP				BX									;GET RELATIVE BYTE ADDRESS
						MOV				DX, [X_POS]
						AND				DX, 7								;MAKE A BIT MASK
						JNZ				PBIT1
						MOV				AL, 80H
						MOV				CL, 7FH
						JMP				PIX_ON
PBIT1:			SUB				DL, 1
						JNZ				PBIT2
						MOV				AL, 40H
						MOV				CL, 0BFH
						JMP				PIX_ON
PBIT2:			SUB				DL, 1
						JNZ				PBIT3
						MOV				AL, 20H
						MOV				CL, 0DFH
						JMP				PIX_ON
PBIT3:			SUB				DL, 1
						JNZ				PBIT4
						MOV				AL, 10H
						MOV				CL, 0EFH
						JMP				PIX_ON
PBIT4:			SUB				DL, 1
						JNZ				PBIT5
						MOV				AL, 8
						MOV				CL, 0F7H
						JMP				PIX_ON
PBIT5:			SUB				DL, 1
						JNZ				PBIT6
						MOV				AL, 4
						MOV				CL, 0FBH
						JMP				PIX_ON
PBIT6:			SUB				DL, 1
						JNZ				PBIT7
						MOV				AL, 2
						MOV				CL, 0FDH
						JHP				PIX ON
PBIT7:			MOV				AL, 1
						MOV				CL, 0FEH
PIX_ON:			MOV				DX, 0C000H					;CLEAR ALL COLOR PLANES AT SELECTED
						MOV				ES, DX							;PIXEL LOCATION BEFORE SETTING
						SEG				ES									;PIXEL TO NEW COLOR
						AND				[BX], CL
						MOV				DX, 0D000H
						MOV				ES, DX
						SEG				ES
						AND				[BX], CL
						MOV				DX, 0E000H
						MOV				ES, DX
						SEG				ES
						AND				[BX], CL
						MOV				DX, [COL_PL1]				;SET PIXEL TO DESIRED COLOR
						MOV				ES, DX
						SEG				ES
						OR				[BX], AL
						MOV				DX, [COL_PL2]
						MOV				ES, DX
						SEG				ES
						OR				[BX], AL
						MOV				DX, [COL_PL3]
						MOV				ES, DX
						SEG				ES
						OR				[BX], AL
						PUSH			[RET_SPE]						;RESTORE RETURN ADDRESS
						MOV				ES, [SEGMENT_E]			;RESTORE SEGMENT E
						RET
END PROC SET_PIXEL;
;******************************************************************************
;******************************************************************************
;PROCEDURE RESET_PIXEL ACCEPTS AS INPUT AN (X,Y) COORDINATE AND RESETS
;THE CORRESPONDING PIXEL BY WRITING "0" TO ALL COLOR PLANES
PROC RESET_PIXEL;
						MOV				BP, SP
						MOV				[SEGMENT E], ES			;SAVE ES STATUS
						POP				[RET_RPE]						;SAVE RETURN ADDRESS
						MOV				AX, [BP+4]					;GET X POSITION
						MOV				[X_POS], AX
						CALL			ADJ_SL
						CALL			REL_VID_ADDR
						POP				BX									;GET RELATIVE BYTE ADDRESS
						MOV				DX, [X_POS]
						AND				DX, 7								;MAKE A BIT MASK
						JNZ				RBIT1
						MOV				AL, 7FH
						JMP				PIX_OFF
RBIT1:			SUB				DL, 1
						JNZ				RBIT2
						MOV				AL, 0BFH
						JMP				PIX_OFF
RBIT2:			SUB				DL, 1
						JNZ				RBIT3
						MOV				AL, 0DFH
						JMP				PIX_OFF
RBIT3:			SUB				DL, 1
						JNZ				RBIT4
						MOV				AL, 0EFH
						JMP				PIX_OFF
RBIT4:			SUB				DL, 1
						JNZ				RBIT5
						MOV				AL, 0F7H
						JMP				PIX_OFF
RBIT5:			SUB				DL, 1
						JNZ				RBIT6
						MOV				AL, 0FBH
						JMP				PIX_OFF
RBIT6:			SUB				DL, 1
						JNZ				RBIT7
						MOV				AL, 0FDH
						JMP				PIX_OFF
RBIT7:			MOV				AL, 0FEH
PIX_OFF:		MOV				DX, 0C000H
						MOV				ES, DX
						SEG				ES
						AND				[BX], AL
						MOV				DX, 0D000H
						MOV				ES, DX
						SEG				ES
						AND				[BX], AL
						MOV				DX, 0E000H
						MOV				ES, DX
						SEG				ES
						AND				[BX], AL
						PUSH			[RET_RPE]						;RESTORE RETURN ADDRESS
						MOV				ES, [SEGMENT_E]			;RESTORE SEGMENT E
						RET
END PROC RESET_PIXEL
;******************************************************************************
;******************************************************************************
;PROCEDURE INQUIRE_COLOR IS USED TO INTERFACE WITH HIGHER LEVEL ADA
;PROGRAMS IN ORDER TO HANDLE I/O PARAMETER PASSING
PROC INQUIRE_COLOR;
						MOV				BP, SP
						PUSH			BP
						PUSH			[BP+6]							;PUSH X POSITION
						PUSH			[BP+4]							;PUSH Y POSITION
						CALL			INQ_COLOR						;GET PIXEL COLOR
						POP				AX									;COLOR VAL RETURNED
						POP				BP
						MOV				BX, [BP+2]
						MOV				[BX], AX						;RETURN PIXEL COLOR
						RET
END PROC INQUIRE_COLOR;
;******************************************************************************
;******************************************************************************
;PROCEDURE INQ_COLOR ACCEPTS X & Y COORDINATES AS AN INPUT AND
;RETURNS THE PIXEL COLOR CODE OF THAT LOCATION
PROC INQ_COLOR;
						MOV				BP, SP
						MOV				AX, [BP+4]
						MOV				[X_POS], AX
						POP				[RET_IC]						;SAVE RETURN ADDRESS
						CALL			ADJ_SL
						CALL			REL_VID_ADDR
						POP				BX
						PUSH			[X_POS]
						CALL			X_MASK
						POP				CX									;READ MASK
						PUSH			ES									;SAVE ES STATUS
						MOV				AX, 0C000H
						MOV				ES, AX
						SEG				ES
						MOV				DL, [BX]						;READ DATA IN BLUE BIT PLANE
						AND				DL, CL							;TEST IF BIT SET
						JNZ				B1
						JMP				NO_B
B1:					MOV				AX, 0D000H
						MOV				ES, AX
						SEG				ES
						MOV				DL, [BX]						;READ DATA IN RED BIT PLANE
						AND				DL, CL							;TEST IF BIT SET
						JNZ				B2
						JMP				B_NO_R
B2:					MOV				AX, 0E000H					;RED IS SET, TEST GREEN
						MOV				ES, AX
						SEG				ES
						MOV				DL, [BX]						;READ DATA IN GREEN BIT PLANE
						AND				DL, CL							;TEST IF BIT IS SET
						JNZ				B3
						JMP				BR_NO_G
B3:					MOV				AX, 0								;COLOR IS WHITE
						JMP				EXIT_IC
BR_NO_G:		MOV				AX, 2								;COLOR IS MAGENTA
						JMP				EXIT_IC
B_NO_R:			MOV				AX, 0E000H					;BLUE IS SET, RED IS NOT, TEST GREEN
						MOV				ES, AX
						SEG				ES
						MOV				DL, [BX]						;READ DATA IN GREEN BIT PLANE
						AND				DL, CL
						JNZ				B4
						JMP				B_NO_RG
B4:					MOV				AX, 1								;COLOR IS CYAN
						JMP				EXIT_IC
B_NO_RG:		MOV				AX, 3								;COLOR IS BLUE
						JMP				EXIT_IC
NO_B:				MOV				AX, 0D000H					;NO BLUE, TEST RED
						MOV				ES, AX
						SEG				ES
						MOV				DL, [BX]						;READ DATA IN RED BIT PLANE
						AND				DL, CL
						JNZ				B5									;RED IS SET, NO BLUE, TEST GREEN
						JMP				NO_BR
B5:					MOV				AX, 0E000H
						MOV				ES, AX
						SEG				ES
						MOV				DL, [BX]						;READ DATA IN GREEN BIT PLANE
						AND				DL, CL
						JNZ				B6
						JMP				R_NO_BG
B6:					MOV				AX, 4								;COLOR IS YELLOW
						JMP				EXIT_IC
R_NO_BG:		MOV				AX, 6								;COLOR IS RED
						JMP				EXIT_IC
NO_BR:			MOV				AX, 0E000H					;NO BLUE, NO RED, TEST GREEN
						MOV				ES, AX
						SEG				ES
						MOV				DL, [BX]						;READ DATA IN GREEN BIT PLANE
						AND				DL, CL
						JNZ				B7
						JMP				NO_RGB
B7:					MOV				AX, 5								;COLOR IS GREEN
						JMP				EXIT_IC
NO_RGB:			MOV				AX, 7								;COLOR IS BLACK
EXIT_IC:		POP				ES									;RESTORE ES
						PUSH			AX
						PUSH			[RET_IC]						;RESTORE RETURN ADDRESS
						RET
END PROC INQ_COLOR;
;******************************************************************************
;******************************************************************************
;PROCEDURE X_MASK ACCEPTS AN X COORDINATE POSITION AS INPUT
;AND RETURNS A BIT MASK BASED ON THE X COORDINATE
PROC X_MASK;
						POP				DX									;SAVE RETURN ADDRESS
						POP 			AX									;GET X POSITION
						AND 			AX, 7
						JNZ				MBIT1
						MOV				AX, 80H
						JMP				EXIT_XM
MBIT1:			SUB				AX, 1
						JNZ				MBIT2
						MOV				AX, 40H
						JMP				EXIT_XM
MBIT2:			SUB				AX, 1
						JNZ				MBIT3
						MOV				AX, 20H
						JMP				EXIT_XM
MBIT3:			SUB				AX, 1
						JNZ				MBIT4
						MOV				AX, 10H
						JMP				EXIT_XM
MBIT4:			SUB				AX, 1
						JNZ				MBIT5
						MOV				AX, 8
						JMP				EXIT_XM
MBIT5:			SUB				AX, 1
						JNZ				MBIT6
						MOV				AX, 4
						JMP				EXIT_XM
MBIT6:			SUB				AX, 1
						JNZ				MBIT7
						MOV				AX, 2
						JMP				EXIT_XM
MBIT7:			MOV				AX, 1
EXIT_XM:		PUSH			AX									;RETURN X MASK
						PUSH			DX									;RESTORE RETURN ADDRESS
						RET
END PROC X_MASK;
;******************************************************************************
;******************************************************************************
;PROCEDURE BOUNDARY_FILL ACCEPTS AS INPUT X AND Y COORDINATES, A FILL
;COLOR, AMD A BOUNDARY COLOR AND PERFORMS A SCREEN FILL WITH THE
;FILL COLOR UP TO THE SPECIFIED BOUNDARY
PROC BOUNDARY_FILL;
						POP				[RET_FILL]
						POP				[B_COLOR]
						POP				[F_COLOR]
						MOV				[SEGMENT_FE], ES
						MOV				AX, [COL_PL1]
						MOV				[SAV_COL1_STAT], AX
						MOV				AX, [COL_PL2]
						MOV				[SAV COL2_STAT], AX
						MOV				AX, [COL_PL3]
						MOV				[SAV_COL3_STAT], AX
						CALL			B_FILL
						PUSH			[RET_FILL]
						MOV				ES, [SEGMENT_FE]
						MOV				AX, [SAV COL1_STAT]
						MOV				[COL_PL1], AX
						MOV				AX, [SAV_COL2_STAT]
						MOV				[COL_PL2], AX
						MOV				AX, [SAV_COL3_STAT]
						MOV				[COL_PL3], AX
						RET
END PROC BOUNDARY_FILL;
;******************************************************************************
;******************************************************************************
;PROCEDURE R_FILL IS THE RECURSIVE PART OF THE BOUNDARY FILL PROCEDURE.
;IT IS USED TO AVOID UNNECESSARY PASSING OF THE COLOR PARAMETERS WHICH
;DO NOT CHANGE ON SUCCESSIVE RECURRSIVE CALLS.
PROC B_FILL;
						POP				DX									;SAVE RETURN ADDRESS
						MOV				CX, [X_POS]
						MOV				BX, [Y_POS]
						POP				[Y_POS]							;GET NEXT Y POSITION OFF STACK
						POP				[X_POS]							;GET NEXT X POSITION OFF STACK
						PUSH			DX
						PUSH			CX
						PUSH			BX
						PUSH			[X_POS]							;SAVE PRESENT X POSITION
						PUSH			[Y_POS]							;SAVE PRESENT Y POSITION
						CALL			INQ_COLOR
						POP				AX
						MOV				[P_COLOR], AX				;COMPARE COLOR AT PRESENT LOCATION
						CMP				AX, [B_COLOR]				;WITH BOUNDARY COLOR
						JNZ				TEST_FC
						JMP				EXIT_F
TEST_FC:		MOV				AX, [P_COLOR]				;COMPARE COLOR AT PRESENT LOCATION
						CMP				AX, [F_COLOR]				;WITH FILL COLOR
						JNZ				F_PIX
						JMP				EXIT_F
F_PIX:			PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			ADJ_SL
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						PUSH			[F_COLOR]
						CALL			COLOR
						CALL			CIR_PIXEL						;SET LOCATION (X,Y) TO FILL COLOR
						MOV				AX, [X_POS]
						ADD				AX, 1
						PUSH			AX
						PUSH			[Y_POS]
						CALL			B_FILL							;CALL B_FILL PASSING (X+1,Y)
						MOV				AX, [X_POS]
						SUB				AX, 1
						PUSH			AX
						PUSH			[Y_POS]
						CALL			B_FILL							;CALL B_FILL PASSING (X-1,Y)
						MOV				AX, [Y_POS]
						ADD				AX, 1
						PUSH			[X_POS]
						PUSH			AX
						CALL			B_FILL							;CALL B_FILL PASSING (X,Y+1)
						MOV				AX, [Y_POS]
						SUB				AX, 1
						PUSH			[X_POS]
						PUSH			AX
						CALL			B_FILL							;CALL B_FILL PASSING (X,Y-1)
EXIT_F:			POP				[Y_POS]							;RESTORE POSITION (X,Y)
						POP				[X POS]
						RET
END PROC B_FILL;
;******************************************************************************
;******************************************************************************
;PROCEDURE AREA_FILL ACCEPTS AS INPUT AN (X,Y) POSITION AND A
;FILL COLOR. IT FILLS AN AREA WHOSE BOUNDARY IS DETERMINED BY THE
;PRESENT COLOR OF THE INPUT (X,Y) POSITION.
PROC AREA_FILL;
						POP				[RET_AFILL]					;SAVE RETURN ADDRESS
						MOV				[SEGMENT_FE], ES
						MOV				AX, [COL_PL1]
						MOV				[SAV_COL1_STAT], AX
						MOV				AX, [COL_PL2]
						MOV				[SAV_COL2_STAT], AX
						MOV				AX, [COL_PL3]
						MOV				[SAV_COL3_STAT], AX
						POP				[F_COLOR]						;GET FILL COLOR OFF OF STACK
						POP				[Y_POS]
						POP				[X_POS]
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			INQ_COLOR						;GET COLOR OF INPUT POSITION
						POP				[B_COLOR]						;SAVE REFERENCE COLOR
						PUSH			[X_POS]
						PUSH			[Y_FOS]
						CALL			A_FILL							;CALL RECURSIVE FILL PROCEDURE
						PUSH			[RET_AFILL]					;RESTORE RETURN ADDRESS
						MOV				ES, [SEGMENT_FE]
						MOV				AX, [SAV_COL1_STAT]
						MOV				[COL_PL1], AX
						MOV				AX, [SAV_COL2_STAT]
						MOV				[COL_PL2], AX
						MOV				AX, [SAV_COL3_STAT]
						MOV				[COL_PL3], AX
						RET
END PROC AREA_FILL;
;******************************************************************************
;******************************************************************************
;PROCEDURE A_FILL IS THE RECURSIVE PART OF THE AREA FILL PROCEDURE.
;IT IS USED TO AVOID UNNECESSARY PASSING OF THE COLOR PARAMETERS WHICH
;DO NOT CHANGE ON SUCCESSIVE RECURRSIVE CALLS.
PROC A_FILL;
						POP				DX									;SAVE RETURN ADDRESS
						MOV				CX, [X_POS]
						MOV				BX, [Y_POS]
						POP				[Y_POS]							;GET NEXT Y POSITION OFF STACK
						POP				[X_POS]							;GET NEXT X POSITION OFF STACK
						PUSH			DX
						PUSH			CX
						PUSH			BX
						PUSH			[X_POS]							;SAVE PRESENT X POSITION
						PUSH			[Y_POS]							;SAVE PRESENT Y POSITION
						CALL			INQ_COLOR
						POP				AX
						MOV				[P_COLOR], AX				;COMPARE COLOR AT PRESENT LOCATION
						CMP				AX, [B_COLOR]				;WITH AREA COLOR
						JNZ				EXIT_AF
						PUSH			[X_POS]
						PUSH			[Y_POS]
						CALL			ADJ_SL
						CALL			REL_VID_ADDR
						PUSH			[X_POS]
						PUSH			[F_COLOR]
						CALL			COLOR
						CALL			CIR_PIXEL						;SET LOCATION (X,Y) TO FILL COLOR
						MOV				AX, [X_POS]
						ADD				AX, 1
						PUSH			AX
						PUSH			[Y_POS]
						CALL			A_FILL							;CALL A_FILL PASSING (X+1,Y)
						MOV				AX, [X_POS]
						SUB				AX, 1
						PUSH			AX
						PUSH			[Y_POS]
						CALL			A_FILL							;CALL A_FILL PASSING (X-1,Y)
						MOV				AX, [Y_POS]
						ADD				AX, 1
						PUSH			[X_POS]
						PUSH			AX
						CALL			A_FILL							;CALL A_FILL PASSING (X,Y+1)
						MOV				AX, [Y_POS]
						SUB				AX, 1
						PUSH			[X_POS]
						PUSH			AX
						CALL			A_FILL							;CALL A_FILL PASSING (X,Y-1)
EXIT_AF:		POP				[Y_POS]
						POP				[X_POS]
						RET
END PROC A_FILL;
;******************************************************************************
;******************************************************************************
MAIN:
END ADAGRAPH;
