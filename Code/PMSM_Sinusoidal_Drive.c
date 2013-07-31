/*
 * File: PMSM_Sinusoidal_Drive.c
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

#include "PMSM_Sinusoidal_Drive.h"
#include "PMSM_Sinusoidal_Drive_private.h"

/* Exported block states */
real32_T commandedAngle;               /* '<Root>/Data Store Memory' */
real32_T torqueInput;                  /* '<Root>/Data Store Memory11' */
real32_T fieldWeakening;               /* '<Root>/Data Store Memory9' */

/* Block states (auto storage) */
D_Work_PMSM_Sinusoidal_Drive PMSM_Sinusoidal_Drive_DWork;

/* Real-time model */
RT_MODEL_PMSM_Sinusoidal_Drive PMSM_Sinusoidal_Drive_M_;
RT_MODEL_PMSM_Sinusoidal_Drive *const PMSM_Sinusoidal_Drive_M =
  &PMSM_Sinusoidal_Drive_M_;

/* Model step function */
void PMSM_Sinusoidal_Drive_step(void)
{
  real32_T T;
  real32_T cosOut;
  real32_T rtb_Gain[3];
  int16_T i;
  real32_T unnamed_idx;

  /* Trigonometry: '<S3>/Trigonometric Function' incorporates:
   *  DataStoreRead: '<Root>/Data Store Read'
   */
  T = (real32_T)sin(commandedAngle);
  cosOut = (real32_T)cos(commandedAngle);

  /* SignalConversion: '<S2>/TmpSignal ConversionAtGainInport1' incorporates:
   *  DataStoreRead: '<Root>/Data Store Read1'
   *  DataStoreRead: '<Root>/Data Store Read2'
   *  Product: '<S5>/AxBx'
   *  Product: '<S5>/AxBy'
   *  Product: '<S5>/AyBx'
   *  Product: '<S5>/AyBy'
   *  Sum: '<S5>/sumx'
   *  Sum: '<S5>/sumy'
   *  Trigonometry: '<S3>/Trigonometric Function'
   */
  unnamed_idx = fieldWeakening * cosOut - torqueInput * T;
  T = torqueInput * cosOut + fieldWeakening * T;

  /* Gain: '<S2>/Gain' */
  for (i = 0; i < 3; i++) {
    rtb_Gain[i] = PMSM_Sinusoidal_Drive_P.Gain_Gain[i + 3] * T +
      PMSM_Sinusoidal_Drive_P.Gain_Gain[i] * unnamed_idx;
  }

  /* End of Gain: '<S2>/Gain' */

  /* MATLAB Function: '<Root>/Duty Cycles' */
  /* MATLAB Function 'Duty Cycles': '<S1>:1' */
  /* '<S1>:1:5' */
  if (rtb_Gain[0] >= 0.0F) {
    /* '<S1>:1:7' */
    if (rtb_Gain[1] >= 0.0F) {
      /* '<S1>:1:8' */
      /* Sector 3, 0 - 60 Degrees */
      /* '<S1>:1:13' */
      T = rtb_Gain[1] * 100.0F;

      /* DataStoreWrite: '<Root>/Data Store Write7' */
      /* '<S1>:1:14' */
      /* '<S1>:1:16' */
      /* '<S1>:1:17' */
      /* '<S1>:1:19' */
      PMSM_Sinusoidal_Drive_DWork.T2 = 0.0F;

      /* DataStoreWrite: '<Root>/Data Store Write6' */
      /* '<S1>:1:20' */
      PMSM_Sinusoidal_Drive_DWork.T3 = T;

      /* DataStoreWrite: '<Root>/Data Store Write3' */
      /* '<S1>:1:21' */
      PMSM_Sinusoidal_Drive_DWork.T1 = rtb_Gain[0] * 100.0F + T;

      /* DataStoreWrite: '<Root>/Data Store Write8' */
      /* '<S1>:1:22' */
      PMSM_Sinusoidal_Drive_DWork.Sector = 3.0F;
    } else if (rtb_Gain[2] >= 0.0F) {
      /* '<S1>:1:24' */
      /* Sector 5, 120 - 180 Degrees */
      /* '<S1>:1:29' */
      T = rtb_Gain[0] * 100.0F;

      /* DataStoreWrite: '<Root>/Data Store Write7' */
      /* '<S1>:1:30' */
      /* '<S1>:1:32' */
      /* '<S1>:1:33' */
      /* '<S1>:1:35' */
      PMSM_Sinusoidal_Drive_DWork.T2 = rtb_Gain[2] * 100.0F + T;

      /* DataStoreWrite: '<Root>/Data Store Write6' */
      /* '<S1>:1:36' */
      PMSM_Sinusoidal_Drive_DWork.T3 = 0.0F;

      /* DataStoreWrite: '<Root>/Data Store Write3' */
      /* '<S1>:1:37' */
      PMSM_Sinusoidal_Drive_DWork.T1 = T;

      /* DataStoreWrite: '<Root>/Data Store Write8' */
      /* '<S1>:1:38' */
      PMSM_Sinusoidal_Drive_DWork.Sector = 5.0F;
    } else {
      /* Sector 1, 60 - 120 Degrees */
      /* '<S1>:1:41' */
      /* '<S1>:1:42' */
      /* '<S1>:1:44' */
      T = -rtb_Gain[1] * 100.0F;

      /* DataStoreWrite: '<Root>/Data Store Write7' */
      /* '<S1>:1:45' */
      /* '<S1>:1:47' */
      /* '<S1>:1:48' */
      /* '<S1>:1:50' */
      PMSM_Sinusoidal_Drive_DWork.T2 = T;

      /* DataStoreWrite: '<Root>/Data Store Write6' */
      /* '<S1>:1:51' */
      PMSM_Sinusoidal_Drive_DWork.T3 = 0.0F;

      /* DataStoreWrite: '<Root>/Data Store Write3' */
      /* '<S1>:1:52' */
      PMSM_Sinusoidal_Drive_DWork.T1 = -rtb_Gain[2] * 100.0F + T;

      /* DataStoreWrite: '<Root>/Data Store Write8' */
      /* '<S1>:1:53' */
      PMSM_Sinusoidal_Drive_DWork.Sector = 1.0F;
    }
  } else if (rtb_Gain[1] >= 0.0F) {
    /* '<S1>:1:57' */
    if (rtb_Gain[2] >= 0.0F) {
      /* '<S1>:1:58' */
      /* Sector 6, 240 - 300 Degrees */
      /* '<S1>:1:63' */
      T = rtb_Gain[2] * 100.0F;

      /* DataStoreWrite: '<Root>/Data Store Write7' */
      /* '<S1>:1:64' */
      /* '<S1>:1:66' */
      /* '<S1>:1:67' */
      /* '<S1>:1:69' */
      PMSM_Sinusoidal_Drive_DWork.T2 = T;

      /* DataStoreWrite: '<Root>/Data Store Write6' */
      /* '<S1>:1:70' */
      PMSM_Sinusoidal_Drive_DWork.T3 = rtb_Gain[1] * 100.0F + T;

      /* DataStoreWrite: '<Root>/Data Store Write3' */
      /* '<S1>:1:71' */
      PMSM_Sinusoidal_Drive_DWork.T1 = 0.0F;

      /* DataStoreWrite: '<Root>/Data Store Write8' */
      /* '<S1>:1:72' */
      PMSM_Sinusoidal_Drive_DWork.Sector = 6.0F;
    } else {
      /* Sector 2, 300 - 0 Degrees */
      /* '<S1>:1:75' */
      /* '<S1>:1:76' */
      /* '<S1>:1:78' */
      T = -rtb_Gain[2] * 100.0F;

      /* DataStoreWrite: '<Root>/Data Store Write7' */
      /* '<S1>:1:79' */
      /* '<S1>:1:81' */
      /* '<S1>:1:82' */
      /* '<S1>:1:84' */
      PMSM_Sinusoidal_Drive_DWork.T2 = 0.0F;

      /* DataStoreWrite: '<Root>/Data Store Write6' */
      /* '<S1>:1:85' */
      PMSM_Sinusoidal_Drive_DWork.T3 = -rtb_Gain[0] * 100.0F + T;

      /* DataStoreWrite: '<Root>/Data Store Write3' */
      /* '<S1>:1:86' */
      PMSM_Sinusoidal_Drive_DWork.T1 = T;

      /* DataStoreWrite: '<Root>/Data Store Write8' */
      /* '<S1>:1:87' */
      PMSM_Sinusoidal_Drive_DWork.Sector = 2.0F;
    }
  } else {
    /* Sector 4, 180 - 240 Degrees */
    /* '<S1>:1:91' */
    /* '<S1>:1:92' */
    /* '<S1>:1:94' */
    T = -rtb_Gain[0] * 100.0F;

    /* DataStoreWrite: '<Root>/Data Store Write7' */
    /* '<S1>:1:95' */
    /* '<S1>:1:97' */
    /* '<S1>:1:98' */
    /* '<S1>:1:100' */
    PMSM_Sinusoidal_Drive_DWork.T2 = -rtb_Gain[1] * 100.0F + T;

    /* DataStoreWrite: '<Root>/Data Store Write6' */
    /* '<S1>:1:101' */
    PMSM_Sinusoidal_Drive_DWork.T3 = T;

    /* DataStoreWrite: '<Root>/Data Store Write3' */
    /* '<S1>:1:102' */
    PMSM_Sinusoidal_Drive_DWork.T1 = 0.0F;

    /* DataStoreWrite: '<Root>/Data Store Write8' */
    /* '<S1>:1:103' */
    PMSM_Sinusoidal_Drive_DWork.Sector = 4.0F;
  }

  /* End of MATLAB Function: '<Root>/Duty Cycles' */
}

/* Model initialize function */
void PMSM_Sinusoidal_Drive_initialize(void)
{
  /* Registration code */

  /* initialize error status */
  rtmSetErrorStatus(PMSM_Sinusoidal_Drive_M, (NULL));

  /* states (dwork) */
  (void) memset((void *)&PMSM_Sinusoidal_Drive_DWork, 0,
                sizeof(D_Work_PMSM_Sinusoidal_Drive));

  /* exported global states */
  commandedAngle = 0.0F;
  torqueInput = 0.0F;
  fieldWeakening = 0.0F;

  /* Start for DataStoreMemory: '<Root>/Data Store Memory' */
  commandedAngle = PMSM_Sinusoidal_Drive_P.DataStoreMemory_InitialValue;

  /* Start for DataStoreMemory: '<Root>/Data Store Memory1' */
  PMSM_Sinusoidal_Drive_DWork.T3 =
    PMSM_Sinusoidal_Drive_P.DataStoreMemory1_InitialValue;

  /* Start for DataStoreMemory: '<Root>/Data Store Memory10' */
  PMSM_Sinusoidal_Drive_DWork.Sector =
    PMSM_Sinusoidal_Drive_P.DataStoreMemory10_InitialValue;

  /* Start for DataStoreMemory: '<Root>/Data Store Memory11' */
  torqueInput = PMSM_Sinusoidal_Drive_P.DataStoreMemory11_InitialValue;

  /* Start for DataStoreMemory: '<Root>/Data Store Memory7' */
  PMSM_Sinusoidal_Drive_DWork.T1 =
    PMSM_Sinusoidal_Drive_P.DataStoreMemory7_InitialValue;

  /* Start for DataStoreMemory: '<Root>/Data Store Memory8' */
  PMSM_Sinusoidal_Drive_DWork.T2 =
    PMSM_Sinusoidal_Drive_P.DataStoreMemory8_InitialValue;

  /* Start for DataStoreMemory: '<Root>/Data Store Memory9' */
  fieldWeakening = PMSM_Sinusoidal_Drive_P.DataStoreMemory9_InitialValue;
}

/* Model terminate function */
void PMSM_Sinusoidal_Drive_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
