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
 * File: FOC_FromScratch.h
 *
 * Real-Time Workshop code generated for Simulink model FOC_FromScratch.
 *
 * Model version                        : 1.213
 * Real-Time Workshop file version      : 8.7 (R2014b) 08-Sep-2014
 * Real-Time Workshop file generated on : Wed Apr 08 16:05:15 2015
 * TLC version                          : 8.7 (Aug  5 2014)
 * C source code generated on           : Wed Apr 08 16:05:15 2015
 */

#ifndef RTW_HEADER_FOC_FromScratch_h_
#define RTW_HEADER_FOC_FromScratch_h_
#include <string.h>
#include <stddef.h>
#ifndef FOC_FromScratch_COMMON_INCLUDES_
# define FOC_FromScratch_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "motor_control.h"
#include "mc_math.h"
#include "mc_typeshims.h"
#endif                                 /* FOC_FromScratch_COMMON_INCLUDES_ */

#include "FOC_FromScratch_types.h"
#define FCY                            7.0E+7

/* Include for pic 33E */
#include <p33Exxxx.h>
#include <libpic30.h>                  /* For possible use with C function Call block (delay_ms or delay_us functions might be used by few peripherals) */
#include <libq.h>                      /* For possible use with C function Call block */

/* Macros for accessing real-time model data structure */
#ifndef rtmGetStopRequested
# define rtmGetStopRequested(rtm)      ((void*) 0)
#endif

/* Block signals (auto storage) */
typedef struct {
  int16_T Gain;                        /* '<Root>/Gain' */
} B_FOC_FromScratch_T;

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  mchp_MC_PISTATE_T codegeneration_work1;/* '<S16>/codegeneration' */
  mchp_MC_PISTATE_T codegeneration_work1_g;/* '<S15>/codegeneration' */
  int32_T thetaCommanded;              /* '<Root>/Data Store Memory2' */
  uint16_T DC1;                        /* '<Root>/Data Store Memory3' */
  uint16_T DC2;                        /* '<Root>/Data Store Memory4' */
  uint16_T DC3;                        /* '<Root>/Data Store Memory5' */
  int16_T dCommanded;                  /* '<Root>/Data Store Memory' */
  int16_T qCommanded;                  /* '<Root>/Data Store Memory1' */
} DW_FOC_FromScratch_T;

/* Constant parameters (auto storage) */
typedef struct {
  /* Computed Parameter: Gain_Gain
   * Referenced by: '<S4>/Gain'
   */
  int16_T Gain_Gain[6];
} ConstP_FOC_FromScratch_T;

/* Block signals (auto storage) */
extern B_FOC_FromScratch_T FOC_FromScratch_B;

/* Block states (auto storage) */
extern DW_FOC_FromScratch_T FOC_FromScratch_DW;

/* Constant parameters (auto storage) */
extern const ConstP_FOC_FromScratch_T FOC_FromScratch_ConstP;

/* Model entry point functions */
extern void FOC_FromScratch_initialize(void);
extern void FOC_FromScratch_step(void);

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'FOC_FromScratch'
 * '<S1>'   : 'FOC_FromScratch/SVM and scaling'
 * '<S2>'   : 'FOC_FromScratch/Sincos:table-interp'
 * '<S3>'   : 'FOC_FromScratch/Subsystem'
 * '<S4>'   : 'FOC_FromScratch/alphabeta-to-abc'
 * '<S5>'   : 'FOC_FromScratch/dq-to-alphabeta1'
 * '<S6>'   : 'FOC_FromScratch/SVM and scaling/SVM Boost'
 * '<S7>'   : 'FOC_FromScratch/Sincos:table-interp/envctrl1'
 * '<S8>'   : 'FOC_FromScratch/Sincos:table-interp/simulation'
 * '<S9>'   : 'FOC_FromScratch/Sincos:table-interp/simulation/Sector and offset'
 * '<S10>'  : 'FOC_FromScratch/Sincos:table-interp/simulation/evaluate linear polynomial'
 * '<S11>'  : 'FOC_FromScratch/Sincos:table-interp/simulation/Sector and offset/Extract Bits'
 * '<S12>'  : 'FOC_FromScratch/Sincos:table-interp/simulation/Sector and offset/Extract Bits1'
 * '<S13>'  : 'FOC_FromScratch/Subsystem/currentcontrolers'
 * '<S14>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem'
 * '<S15>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup'
 * '<S16>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup1'
 * '<S17>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup/envctrl1'
 * '<S18>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup/simulation'
 * '<S19>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup/simulation/PI-antiwindup-v0'
 * '<S20>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup/simulation/PI-antiwindup-v0/Extract Bits1'
 * '<S21>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup/simulation/PI-antiwindup-v0/Saturation Dynamic'
 * '<S22>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup1/envctrl1'
 * '<S23>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup1/simulation'
 * '<S24>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup1/simulation/PI-antiwindup-v0'
 * '<S25>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup1/simulation/PI-antiwindup-v0/Extract Bits1'
 * '<S26>'  : 'FOC_FromScratch/Subsystem/currentcontrolers/Subsystem/PI-antiwindup1/simulation/PI-antiwindup-v0/Saturation Dynamic'
 * '<S27>'  : 'FOC_FromScratch/dq-to-alphabeta1/vector mixer'
 */
#endif                                 /* RTW_HEADER_FOC_FromScratch_h_ */

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
