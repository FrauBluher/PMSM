/*--------------------------------------------------------------
 *   MPLAB Blockset v3.35 for Microchip dsPIC chip family.     *
 *   Generate .c and .h files from Simulink model              *
 *   and compile to .elf, .hex and .cof file that can be       *
 *   flashed into the microcontroller                          *
 *                                                             *
 *      The Microchip name PIC, dsPIC, and MPLAB are           *
 *      registered trademarks of Microchip Technology Inc.     *
 *      MATLAB, Simulink, and Real-Time Workshop are           *
 *      registered trademarks of The MathWorks, Inc.           *
 *                                                             *
 *  Blockset authors: L.Kerhuel, U.Kumar                       *
 *  Product Page:  http://www.microchip.com/SimulinkBlocks     *
 *          Forum: http://www.microchip.com/forums/f192.aspx   *
 *          Wiki:  http://microchip.wikidot.com/simulink:start *
 *--------------------------------------------------------------
 *
 * File: FOC_FromScratch.c
 *
 * Real-Time Workshop code generated for Simulink model FOC_FromScratch.
 *
 * Model version                        : 1.213
 * Real-Time Workshop file version      : 8.7 (R2014b) 08-Sep-2014
 * Real-Time Workshop file generated on : Wed Apr 08 16:05:15 2015
 * TLC version                          : 8.7 (Aug  5 2014)
 * C source code generated on           : Wed Apr 08 16:05:15 2015
 */

#include "FOC_FromScratch.h"
#include "FOC_FromScratch_private.h"

/* Block signals (auto storage) */
B_FOC_FromScratch_T FOC_FromScratch_B;

/* Block states (auto storage) */
DW_FOC_FromScratch_T FOC_FromScratch_DW;
void mul_wide_s32(int32_T in0, int32_T in1, uint32_T *ptrOutBitsHi, uint32_T
                  *ptrOutBitsLo)
{
  uint32_T absIn0;
  uint32_T absIn1;
  uint32_T in0Lo;
  uint32_T in0Hi;
  uint32_T in1Hi;
  uint32_T productHiLo;
  uint32_T productLoHi;
  absIn0 = (uint32_T)(in0 < 0L ? -in0 : in0);
  absIn1 = (uint32_T)(in1 < 0L ? -in1 : in1);
  in0Hi = absIn0 >> 16UL;
  in0Lo = absIn0 & 65535UL;
  in1Hi = absIn1 >> 16UL;
  absIn0 = absIn1 & 65535UL;
  productHiLo = in0Hi * absIn0;
  productLoHi = in0Lo * in1Hi;
  absIn0 *= in0Lo;
  absIn1 = 0UL;
  in0Lo = (productLoHi << 16UL) + absIn0;
  if (in0Lo < absIn0) {
    absIn1 = 1UL;
  }

  absIn0 = in0Lo;
  in0Lo += productHiLo << 16UL;
  if (in0Lo < absIn0) {
    absIn1++;
  }

  absIn0 = (((productLoHi >> 16UL) + (productHiLo >> 16UL)) + in0Hi * in1Hi) +
    absIn1;
  if (!((in0 == 0L) || ((in1 == 0L) || ((in0 > 0L) == (in1 > 0L))))) {
    absIn0 = ~absIn0;
    in0Lo = ~in0Lo;
    in0Lo++;
    if (in0Lo == 0UL) {
      absIn0++;
    }
  }

  *ptrOutBitsHi = absIn0;
  *ptrOutBitsLo = in0Lo;
}

int32_T mul_s32_s32_s32_sr26(int32_T a, int32_T b)
{
  uint32_T u32_chi;
  uint32_T u32_clo;
  mul_wide_s32(a, b, &u32_chi, &u32_clo);
  u32_clo = u32_chi << 6UL | u32_clo >> 26UL;
  return (int32_T)u32_clo;
}

int32_T mul_s32_s32_s32_sr29(int32_T a, int32_T b)
{
  uint32_T u32_chi;
  uint32_T u32_clo;
  mul_wide_s32(a, b, &u32_chi, &u32_clo);
  u32_clo = u32_chi << 3UL | u32_clo >> 29UL;
  return (int32_T)u32_clo;
}

/* Model step function */
void FOC_FromScratch_step(void)
{
  /* local block i/o variables */
  int16_T rtb_TmpSignalConversionAtGainIn[2];
  int32_T maxV;
  int32_T rtb_Gain8[3];
  int32_T rtb_Gain5;
  int16_T i;
  int16_T tmp;
  uint16_T u0;
  uint16_T u0_0;
  uint16_T u0_1;

  /* Gain: '<Root>/Gain' incorporates:
   *  DataStoreRead: '<Root>/Data Store Read1'
   */
  FOC_FromScratch_B.Gain = (int16_T)FOC_FromScratch_DW.thetaCommanded << 4;

  /* M-S-Function: '<S2>/codegeneration' */
  /* sine and cosine: '<Root>/Sincos:table-interp' */
  MC_CalculateSineCosine_InlineC_Ram((int16_t)FOC_FromScratch_B.Gain,
    (MC_SINCOS_T *)&rtb_TmpSignalConversionAtGainIn[0]);

  /* Product: '<S27>/AyBx' */
  i = rtb_TmpSignalConversionAtGainIn[0];

  /* Product: '<S27>/AxBy' */
  tmp = rtb_TmpSignalConversionAtGainIn[1];

  /* Sum: '<S27>/sumx' incorporates:
   *  DataStoreRead: '<Root>/Data Store Read'
   *  DataStoreRead: '<Root>/Data Store Read2'
   *  Product: '<S27>/AxBx'
   *  Product: '<S27>/AyBy'
   */
  rtb_Gain5 = (int32_T)FOC_FromScratch_DW.dCommanded *
    rtb_TmpSignalConversionAtGainIn[0];
  maxV = (int32_T)FOC_FromScratch_DW.qCommanded *
    rtb_TmpSignalConversionAtGainIn[1];

  /* SignalConversion: '<S4>/TmpSignal ConversionAtGainInport1' incorporates:
   *  Product: '<S27>/AxBx'
   *  Product: '<S27>/AyBy'
   *  Sum: '<S27>/sumx'
   */
  rtb_TmpSignalConversionAtGainIn[0] = (int16_T)(((rtb_Gain5 < 0L ? MAX_int16_T :
    0) + rtb_Gain5) >> 15) - (int16_T)(((maxV < 0L ? MAX_int16_T : 0) + maxV) >>
    15);

  /* Sum: '<S27>/sumy' incorporates:
   *  DataStoreRead: '<Root>/Data Store Read'
   *  DataStoreRead: '<Root>/Data Store Read2'
   *  Product: '<S27>/AxBy'
   *  Product: '<S27>/AyBx'
   */
  rtb_Gain5 = (int32_T)FOC_FromScratch_DW.qCommanded * i;
  maxV = (int32_T)FOC_FromScratch_DW.dCommanded * tmp;

  /* SignalConversion: '<S4>/TmpSignal ConversionAtGainInport1' incorporates:
   *  Product: '<S27>/AxBy'
   *  Product: '<S27>/AyBx'
   *  Sum: '<S27>/sumy'
   */
  rtb_TmpSignalConversionAtGainIn[1L] = (int16_T)(((rtb_Gain5 < 0L ? MAX_int16_T
    : 0) + rtb_Gain5) >> 15) + (int16_T)(((maxV < 0L ? MAX_int16_T : 0) + maxV) >>
    15);

  /* Gain: '<S4>/Gain' */
  for (i = 0; i < 3; i++) {
    rtb_Gain8[i] = (int32_T)FOC_FromScratch_ConstP.Gain_Gain[i + 3] *
      rtb_TmpSignalConversionAtGainIn[1] + (int32_T)
      FOC_FromScratch_ConstP.Gain_Gain[i] * rtb_TmpSignalConversionAtGainIn[0];
  }

  /* End of Gain: '<S4>/Gain' */

  /* MinMax: '<S6>/MinMax1' */
  rtb_Gain5 = rtb_Gain8[0];
  if (!(rtb_Gain8[0] <= rtb_Gain8[1L])) {
    rtb_Gain5 = rtb_Gain8[1L];
  }

  if (!(rtb_Gain5 <= rtb_Gain8[2L])) {
    rtb_Gain5 = rtb_Gain8[2L];
  }

  /* MinMax: '<S6>/MinMax2' */
  maxV = rtb_Gain8[0];
  if (!(rtb_Gain8[0] >= rtb_Gain8[1L])) {
    maxV = rtb_Gain8[1L];
  }

  if (!(maxV >= rtb_Gain8[2L])) {
    maxV = rtb_Gain8[2L];
  }

  /* Gain: '<S6>/Gain5' incorporates:
   *  MinMax: '<S6>/MinMax1'
   *  MinMax: '<S6>/MinMax2'
   *  Sum: '<S6>/Add'
   */
  rtb_Gain5 = (rtb_Gain5 + maxV) >> 1;

  /* Sum: '<S1>/Sum3' incorporates:
   *  Constant: '<S1>/Constant1'
   *  Gain: '<S1>/Gain1'
   *  Gain: '<S6>/Gain8'
   *  Sum: '<S6>/Add1'
   */
  u0_1 = (uint16_T)((int16_T)mul_s32_s32_s32_sr26(75L, mul_s32_s32_s32_sr29
    (619925131L, rtb_Gain8[0] - rtb_Gain5)) + 600);
  u0_0 = (uint16_T)((int16_T)mul_s32_s32_s32_sr26(75L, mul_s32_s32_s32_sr29
    (619925131L, rtb_Gain8[1] - rtb_Gain5)) + 600);
  u0 = (uint16_T)((int16_T)mul_s32_s32_s32_sr26(75L, mul_s32_s32_s32_sr29
    (619925131L, rtb_Gain8[2] - rtb_Gain5)) + 600);

  /* Saturate: '<S1>/Saturation1' */
  if (u0_1 > 1200U) {
    /* DataStoreWrite: '<Root>/Data Store Write' */
    FOC_FromScratch_DW.DC1 = 1200U;
  } else if (u0_1 < 100U) {
    /* DataStoreWrite: '<Root>/Data Store Write' */
    FOC_FromScratch_DW.DC1 = 100U;
  } else {
    /* DataStoreWrite: '<Root>/Data Store Write' */
    FOC_FromScratch_DW.DC1 = u0_1;
  }

  if (u0_0 > 1200U) {
    /* DataStoreWrite: '<Root>/Data Store Write1' */
    FOC_FromScratch_DW.DC2 = 1200U;
  } else if (u0_0 < 100U) {
    /* DataStoreWrite: '<Root>/Data Store Write1' */
    FOC_FromScratch_DW.DC2 = 100U;
  } else {
    /* DataStoreWrite: '<Root>/Data Store Write1' */
    FOC_FromScratch_DW.DC2 = u0_0;
  }

  if (u0 > 1200U) {
    /* DataStoreWrite: '<Root>/Data Store Write2' */
    FOC_FromScratch_DW.DC3 = 1200U;
  } else if (u0 < 100U) {
    /* DataStoreWrite: '<Root>/Data Store Write2' */
    FOC_FromScratch_DW.DC3 = 100U;
  } else {
    /* DataStoreWrite: '<Root>/Data Store Write2' */
    FOC_FromScratch_DW.DC3 = u0;
  }

  /* End of Saturate: '<S1>/Saturation1' */
}

/* Model initialize function */
void FOC_FromScratch_initialize(void)
{
  /* Registration code */

  /* block I/O */
  (void) memset(((void *) &FOC_FromScratch_B), 0,
                sizeof(B_FOC_FromScratch_T));

  /* states (dwork) */
  (void) memset((void *)&FOC_FromScratch_DW, 0,
                sizeof(DW_FOC_FromScratch_T));

  /* S-Function "Microchip MASTER" initialization Block: <Root>/ESC MCU board */

  /* InitializeConditions for Enabled SubSystem: '<S13>/Subsystem' */

  /* PI controller with antiwindup: '<S14>/PI-antiwindup1' */
  (&FOC_FromScratch_DW.codegeneration_work1)->kp = 410;
  (&FOC_FromScratch_DW.codegeneration_work1)->ki = 3;
  (&FOC_FromScratch_DW.codegeneration_work1)->kc = 24576;
  (&FOC_FromScratch_DW.codegeneration_work1)->outMax = 31130;
  (&FOC_FromScratch_DW.codegeneration_work1)->outMin = (-31130);
  (&FOC_FromScratch_DW.codegeneration_work1)->integrator = 0;

  /* PI controller with antiwindup: '<S14>/PI-antiwindup' */
  (&FOC_FromScratch_DW.codegeneration_work1_g)->kp = 410;
  (&FOC_FromScratch_DW.codegeneration_work1_g)->ki = 3;
  (&FOC_FromScratch_DW.codegeneration_work1_g)->kc = 24576;
  (&FOC_FromScratch_DW.codegeneration_work1_g)->outMax = 31130;
  (&FOC_FromScratch_DW.codegeneration_work1_g)->outMin = (-31130);
  (&FOC_FromScratch_DW.codegeneration_work1_g)->integrator = 0;

  /* End of InitializeConditions for SubSystem: '<S13>/Subsystem' */
}

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
