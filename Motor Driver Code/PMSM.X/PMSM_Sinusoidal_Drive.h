/*
 * File: PMSM_Sinusoidal_Drive.h
 *
 * Code generated for Simulink model 'PMSM_Sinusoidal_Drive'.
 *
 * Model version                  : 1.59
 * Simulink Coder version         : 8.1 (R2011b) 08-Jul-2011
 * TLC version                    : 8.1 (Jul  9 2011)
 * C/C++ source code generated on : Wed Jul 17 14:39:42 2013
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: Microchip->dsPIC
 * Code generation objective: Execution efficiency
 * Validation result: Not run
 */

#ifndef RTW_HEADER_PMSM_Sinusoidal_Drive_h_
#define RTW_HEADER_PMSM_Sinusoidal_Drive_h_
#ifndef PMSM_Sinusoidal_Drive_COMMON_INCLUDES_
# define PMSM_Sinusoidal_Drive_COMMON_INCLUDES_
#include <stddef.h>
#include <math.h>
#include <string.h>
#include "rtwtypes.h"
#endif                                 /* PMSM_Sinusoidal_Drive_COMMON_INCLUDES_ */

#include "PMSM_Sinusoidal_Drive_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((rtm)->errorStatus = (val))
#endif

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  real32_T T3;                         /* '<Root>/Data Store Memory1' */
  real32_T Sector;                     /* '<Root>/Data Store Memory10' */
  real32_T T1;                         /* '<Root>/Data Store Memory7' */
  real32_T T2;                         /* '<Root>/Data Store Memory8' */
} D_Work_PMSM_Sinusoidal_Drive;

/* Parameters (auto storage) */
struct Parameters_PMSM_Sinusoidal_Driv_ {
  real32_T Gain_Gain[6];               /* Computed Parameter: Gain_Gain
                                        * Referenced by: '<S2>/Gain'
                                        */
  real32_T DataStoreMemory_InitialValue;/* Computed Parameter: DataStoreMemory_InitialValue
                                         * Referenced by: '<Root>/Data Store Memory'
                                         */
  real32_T DataStoreMemory1_InitialValue;/* Computed Parameter: DataStoreMemory1_InitialValue
                                          * Referenced by: '<Root>/Data Store Memory1'
                                          */
  real32_T DataStoreMemory10_InitialValue;/* Computed Parameter: DataStoreMemory10_InitialValue
                                           * Referenced by: '<Root>/Data Store Memory10'
                                           */
  real32_T DataStoreMemory11_InitialValue;/* Computed Parameter: DataStoreMemory11_InitialValue
                                           * Referenced by: '<Root>/Data Store Memory11'
                                           */
  real32_T DataStoreMemory7_InitialValue;/* Computed Parameter: DataStoreMemory7_InitialValue
                                          * Referenced by: '<Root>/Data Store Memory7'
                                          */
  real32_T DataStoreMemory8_InitialValue;/* Computed Parameter: DataStoreMemory8_InitialValue
                                          * Referenced by: '<Root>/Data Store Memory8'
                                          */
  real32_T DataStoreMemory9_InitialValue;/* Computed Parameter: DataStoreMemory9_InitialValue
                                          * Referenced by: '<Root>/Data Store Memory9'
                                          */
};

/* Real-time Model Data Structure */
struct RT_MODEL_PMSM_Sinusoidal_Drive {
  const char_T * volatile errorStatus;
};

/* Block parameters (auto storage) */
extern Parameters_PMSM_Sinusoidal_Driv PMSM_Sinusoidal_Drive_P;

/* Block states (auto storage) */
extern D_Work_PMSM_Sinusoidal_Drive PMSM_Sinusoidal_Drive_DWork;

/*
 * Exported States
 *
 * Note: Exported states are block states with an exported global
 * storage class designation.  Code generation will declare the memory for these
 * states and exports their symbols.
 *
 */
extern real32_T commandedAngle;        /* '<Root>/Data Store Memory' */
extern real32_T torqueInput;           /* '<Root>/Data Store Memory11' */
extern real32_T fieldWeakening;        /* '<Root>/Data Store Memory9' */

/* Model entry point functions */
extern void PMSM_Sinusoidal_Drive_initialize(void);
extern void PMSM_Sinusoidal_Drive_step(void);
extern void PMSM_Sinusoidal_Drive_terminate(void);

/* Real-time Model object */
extern struct RT_MODEL_PMSM_Sinusoidal_Drive *const PMSM_Sinusoidal_Drive_M;

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
 * '<Root>' : 'PMSM_Sinusoidal_Drive'
 * '<S1>'   : 'PMSM_Sinusoidal_Drive/Duty Cycles'
 * '<S2>'   : 'PMSM_Sinusoidal_Drive/alphabeta-to-abc'
 * '<S3>'   : 'PMSM_Sinusoidal_Drive/cstheta'
 * '<S4>'   : 'PMSM_Sinusoidal_Drive/dq-to-alphabeta'
 * '<S5>'   : 'PMSM_Sinusoidal_Drive/dq-to-alphabeta/vector mixer'
 */
#endif                                 /* RTW_HEADER_PMSM_Sinusoidal_Drive_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
