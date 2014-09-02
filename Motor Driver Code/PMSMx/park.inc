; /**********************************************************************
; *                                                                     *
; *                        Software License Agreement                   *
; *                                                                     *
; *    The software supplied herewith by Microchip Technology           *
; *    Incorporated (the "Company") for its dsPIC controller            *
; *    is intended and supplied to you, the Company's customer,         *
; *    for use solely and exclusively on Microchip dsPIC                *
; *    products. The software is owned by the Company and/or its        *
; *    supplier, and is protected under applicable copyright laws. All  *
; *    rights are reserved. Any use in violation of the foregoing       *
; *    restrictions may subject the user to criminal sanctions under    *
; *    applicable laws, as well as to civil liability for the breach of *
; *    the terms and conditions of this license.                        *
; *                                                                     *
; *    THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION.  NO           *
; *    WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING,    *
; *    BUT NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND    *
; *    FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE     *
; *    COMPANY SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL,  *
; *    INCIDENTAL OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.  *
; *                                                                     *
; ***********************************************************************
; *                                                                     *
; *    Filename:       park.inc                                         *
; *    Date:           10/01/08                                         *
; *                                                                     *
; *    Tools used:     MPLAB IDE -> 8.14                                *
; *                    C30 -> 3.10                                      *
; *    Linker File:    p33EP512MU810.gld                                 *
; *                                                                     *
; **********************************************************************/
;;------------------  ASM30 API for Park Clarke routines ---------------------
; ParkParm stucture:

; typedef struct {
;    short   qAngle;
;    short   qCos;
;    short   qSin;
;    short   qIa;
;    short   qIb;
;    short   qIalpha;
;    short   qIbeta;
;    short   qId;
;    short   qIq;
;    short   qVd;
;    short   qVq;
;    short   qValpha;
;    short   qVbeta;
;    short   qV1;
;    short   qV2;
;    short   qV3;
;    } tParkParm;

; Note that pairs qCos,qSin, qIa,qIb, etc must remain consecutive

          .equ Park_qAngle,0       ; qAngle
          .equ Park_qSin,2         ; qSin
          .equ Park_qCos,4         ; qCos
          .equ Park_qIa,6          ; qIa
          .equ Park_qIb,8          ; qIb
          .equ Park_qIalpha,10     ; qIalpha
          .equ Park_qIbeta,12      ; qIbeta
          .equ Park_qId,14         ; qId
          .equ Park_qIq,16         ; qIq
          .equ Park_qVd,18         ; qVd
          .equ Park_qVq,20         ; qVq
          .equ Park_qValpha,22     ; qValpha
          .equ Park_qVbeta,24      ; qVbeta
          .equ Park_qV1,26         ; qV1
          .equ Park_qV2,28         ; qV2
          .equ Park_qV3,30         ; qV3

          .extern _ParkParm
