/*******************************************************************************
  Motor Control library inline definitions header file

  Company:
    Microchip Technology Inc.

  File Name:
    motor_control_inline_dspic.h

  Summary:
    This header file hosts inline definitions of certain library functions included 
    in the Motor Control library.

  Description:
    This header file hosts inline definitions of certain library functions included 
    in the Motor Control library. This header file is automatically included when the
    library interfaces header file is included in the project.
*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2013 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
*******************************************************************************/
// DOM-IGNORE-END

#ifndef _MOTOR_CONTROL_INLINE_DSPIC
#define _MOTOR_CONTROL_INLINE_DSPIC

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************
/*  This section lists the other files that are included in this file.
*/
#include <xc.h>
#include <stdint.h>

#ifdef __cplusplus  // Provide C++ Compatability
    extern "C" {
#endif

#define MC_ONEBYSQ3 0x49E7 // 1/sqrt(3) in 1.15 format
#define MC_SQ3OV2 0x6ED9   // sqrt(3)/2 in 1.15 format
volatile register int a_Reg asm("A");
volatile register int b_Reg asm("B");

#ifdef __dsPIC33F__
__psv__ extern uint16_t mcSineTableInFlash[] __attribute__((space(psv)));
#elif __dsPIC33E__
__eds__ extern uint16_t mcSineTableInFlash[] __attribute__((space(psv)));
#else
#error The selected device is not compatible with the Motor Control library!
#endif
extern uint16_t mcSineTableInRam[];

// *****************************************************************************
// *****************************************************************************
// Section: Inline function definitions
// *****************************************************************************
// *****************************************************************************
/*  This section lists inline implementation of the library functions.
*/

static inline uint16_t MC_TransformPark_InlineC(MC_ALPHABETA_T *alphabeta, MC_SINCOS_T *sincos, MC_DQ_T *dq)
{
    uint16_t mcCorconSave = CORCON;
    CORCON = 0x00E2;

    /* Id =  Ialpha*cos(Angle) + Ibeta*sin(Angle) */
    a_Reg = __builtin_mpy(alphabeta->alpha, sincos->cos,0,0,0,0,0,0);
    a_Reg = __builtin_mac(a_Reg, alphabeta->beta, sincos->sin,0,0,0,0,0,0,0,0);
    dq->d = __builtin_sacr(a_Reg,0);

    /* Iq = - Ialpha*sin(Angle) + Ibeta*cos(Angle) */
    a_Reg = __builtin_mpy(alphabeta->beta, sincos->cos,0,0,0,0,0,0);
    a_Reg = __builtin_msc(a_Reg, alphabeta->alpha, sincos->sin,0,0,0,0,0,0,0,0);
    dq->q = __builtin_sacr(a_Reg,0);

    CORCON = mcCorconSave;
    return (1);
}


static inline uint16_t MC_ControllerPIUpdate_InlineC(int16_t in_Ref, int16_t in_Meas, MC_PISTATE_T *state, int16_t *out)
{
    int16_t error;
    uint32_t temp_dword;
    uint16_t temp_word;
    int16_t out_Buffer;
    int16_t output;

    uint16_t mcCorconSave = CORCON;
    CORCON = 0x00E2;

    /* Calculate error */
    a_Reg = __builtin_lac(in_Ref,0);
    b_Reg = __builtin_lac(in_Meas,0);
    a_Reg = __builtin_subab(a_Reg,b_Reg);
    error = __builtin_sacr(a_Reg,0);

    /* Read state->integrator into B */
    temp_dword = 0xFFFF0000 & state->integrator;
    temp_dword = temp_dword >> 16;
    temp_word = (uint16_t)temp_dword;
    b_Reg = __builtin_lac(temp_word,0);
    asm volatile ("" : "+w"(b_Reg):); // Prevent optimization from re-ordering/ignoring this sequence of operations
    temp_word = (uint16_t)(0xFFFF & state->integrator);
    ACCBL = temp_word;

    /* Calculate (Kp * error * 2^4), store in A and out_Buffer */
    a_Reg = __builtin_mpy(error, state->kp,0,0,0,0,0,0);
    a_Reg = __builtin_sftac(a_Reg,-4);
    a_Reg = __builtin_addab(a_Reg,b_Reg);
    out_Buffer = __builtin_sacr(a_Reg,0);

    /* Limit the output */
    if(out_Buffer > state->outMax)
    {
        output = state->outMax;
    }
    else if(out_Buffer < state->outMin)
    {
        output = state->outMin;
    }
    else
    {
        output = out_Buffer;
    }
    *out = output;    

    /* Calculate (error * Ki) and store in A */
    a_Reg = __builtin_mpy(error, state->ki,0,0,0,0,0,0);

    /* Calculate (excess * Kc), subtract from (error * Ki) and store in A */
    error = out_Buffer - output;
    a_Reg = __builtin_msc(a_Reg, error, state->kc,0,0,0,0,0,0,0,0);

    /* Add (error * Ki)-(excess * Kc) to the integrator value in B */
    a_Reg = __builtin_addab(a_Reg,b_Reg);
    asm volatile ("" : "+w"(a_Reg):); // Prevent optimization from re-ordering/ignoring this sequence of operations

    /* Store the integrator result */
    state->integrator = ACCAH;
    state->integrator = state->integrator << 16;
    state->integrator |= ACCAL;

    CORCON = mcCorconSave;
    return (1);
}


static inline uint16_t MC_TransformClarke_InlineC(MC_ABC_T *abc, MC_ALPHABETA_T *alphabeta)
{
    uint16_t mcCorconSave = CORCON;
    CORCON = 0x00E2;

    /* alpha = a */
    alphabeta->alpha = abc->a;

    /* beta = a*MC_ONEBYSQ3 + 2*b*MC_ONEBYSQ3 */
    a_Reg = __builtin_mpy(abc->a, MC_ONEBYSQ3,0,0,0,0,0,0);
    a_Reg = __builtin_mac(a_Reg, MC_ONEBYSQ3, abc->b,0,0,0,0,0,0,0,0);
    a_Reg = __builtin_mac(a_Reg, MC_ONEBYSQ3, abc->b,0,0,0,0,0,0,0,0);
    alphabeta->beta = __builtin_sacr(a_Reg,0);

    CORCON = mcCorconSave;
    return(1);
}


static inline uint16_t MC_TransformParkInverse_InlineC(MC_DQ_T *dq, MC_SINCOS_T *sincos, MC_ALPHABETA_T *alphabeta)
{
    uint16_t mcCorconSave = CORCON;
    CORCON = 0x00E2;

    /* alphabeta->alpha = (dq->d * sincos->cos) - (dq->q * sincos->sin) */
    a_Reg = __builtin_mpy(dq->d, sincos->cos,0,0,0,0,0,0);
    a_Reg = __builtin_msc(a_Reg, dq->q, sincos->sin,0,0,0,0,0,0,0,0);
    alphabeta->alpha = __builtin_sacr(a_Reg,0);

    /* alphabeta->beta = (dq->d * sincos->sin) + (dq->q * sincos->cos) */
    a_Reg = __builtin_mpy(dq->d, sincos->sin,0,0,0,0,0,0);
    a_Reg = __builtin_mac(a_Reg, dq->q, sincos->cos,0,0,0,0,0,0,0,0);
    alphabeta->beta = __builtin_sacr(a_Reg,0);

    CORCON = mcCorconSave;
    return(1);
}


static inline uint16_t MC_TransformClarkeInverseSwappedInput_InlineC(MC_ALPHABETA_T *alphabeta, MC_ABC_T *abc)
{
    uint16_t mcCorconSave = CORCON;
    CORCON = 0x00E2;

    /* a = beta */
    abc->a = alphabeta->beta;

    /* b = (-beta/2) + (Sqrt(3)/2)*alpha */
    a_Reg = __builtin_clr();
    a_Reg = __builtin_msc(a_Reg, alphabeta->beta, 0x4000,0,0,0,0,0,0,0,0);
    a_Reg = __builtin_mac(a_Reg, alphabeta->alpha, MC_SQ3OV2,0,0,0,0,0,0,0,0);
    abc->b = __builtin_sacr(a_Reg,0);

    /* c = (-beta/2) - (Sqrt(3)/2)*alpha */
    a_Reg = __builtin_clr();
    a_Reg = __builtin_msc(a_Reg, alphabeta->beta, 0x4000,0,0,0,0,0,0,0,0);
    a_Reg = __builtin_msc(a_Reg, alphabeta->alpha, MC_SQ3OV2,0,0,0,0,0,0,0,0);
    abc->c = __builtin_sacr(a_Reg,0);

    CORCON = mcCorconSave;
    return(1);
}


static inline uint16_t MC_CalculateSpaceVectorPhaseShifted_InlineC(MC_ABC_T *abc, uint16_t period, MC_DUTYCYCLEOUT_T *pdcout)
{
    int16_t T1, T2, Ta, Tb, Tc;
    
    uint16_t mcCorconSave = CORCON;
    CORCON = 0x00E2;

    if (abc->a >= 0)
    {
        // (xx1)
        if (abc->b >= 0)
        {
            // (x11)
            // Must be Sector 3 since Sector 7 not allowed
            // Sector 3: (0,1,1)  0-60 degrees
            T1 = abc->a;
            T2 = abc->b;
                /* T1 = period * T1 */
                a_Reg = __builtin_mulus(period, T1);
                T1 = __builtin_sacr(a_Reg,0);
                /* T2 = period * T2 */
                a_Reg = __builtin_mulus(period, T2);
                T2 = __builtin_sacr(a_Reg,0);
                Tc = period-T1-T2;
                Tc = Tc >> 1;
                Tb = Tc + T1;
                Ta = Tb + T2;
            pdcout->dutycycle1 = Ta;
            pdcout->dutycycle2 = Tb;
            pdcout->dutycycle3 = Tc;
        }
        else
        {
            // (x01)
            if (abc->c >= 0)
            {
                // Sector 5: (1,0,1)  120-180 degrees
                T1 = abc->c;
                T2 = abc->a;
                    /* T1 = period * T1 */
                    a_Reg = __builtin_mulus(period, T1);
                    T1 = __builtin_sacr(a_Reg,0);
                    /* T2 = period * T2 */
                    a_Reg = __builtin_mulus(period, T2);
                    T2 = __builtin_sacr(a_Reg,0);
                    Tc = period-T1-T2;
                    Tc = Tc >> 1;
                    Tb = Tc + T1;
                    Ta = Tb + T2;
                pdcout->dutycycle1 = Tc;
                pdcout->dutycycle2 = Ta;
                pdcout->dutycycle3 = Tb;
            }
            else
            {
                // Sector 1: (0,0,1)  60-120 degrees
                T1 = -abc->c;
                T2 = -abc->b;
                    /* T1 = period * T1 */
                    a_Reg = __builtin_mulus(period, T1);
                    T1 = __builtin_sacr(a_Reg,0);
                    /* T2 = period * T2 */
                    a_Reg = __builtin_mulus(period, T2);
                    T2 = __builtin_sacr(a_Reg,0);
                    Tc = period-T1-T2;
                    Tc = Tc >> 1;
                    Tb = Tc + T1;
                    Ta = Tb + T2;
                pdcout->dutycycle1 = Tb;
                pdcout->dutycycle2 = Ta;
                pdcout->dutycycle3 = Tc;
            }
        }
    }
    else
    {
        // (xx0)
        if (abc->b >= 0)
        {
            // (x10)
            if (abc->c >= 0)
            {
                // Sector 6: (1,1,0)  240-300 degrees
                T1 = abc->b;
                T2 = abc->c;
                    /* T1 = period * T1 */
                    a_Reg = __builtin_mulus(period, T1);
                    T1 = __builtin_sacr(a_Reg,0);
                    /* T2 = period * T2 */
                    a_Reg = __builtin_mulus(period, T2);
                    T2 = __builtin_sacr(a_Reg,0);
                    Tc = period-T1-T2;
                    Tc = Tc >> 1;
                    Tb = Tc + T1;
                    Ta = Tb + T2;
                pdcout->dutycycle1 = Tb;
                pdcout->dutycycle2 = Tc;
                pdcout->dutycycle3 = Ta;
            }
            else
            {
                // Sector 2: (0,1,0)  300-0 degrees
                T1 = -abc->a;
                T2 = -abc->c;
                    /* T1 = period * T1 */
                    a_Reg = __builtin_mulus(period, T1);
                    T1 = __builtin_sacr(a_Reg,0);
                    /* T2 = period * T2 */
                    a_Reg = __builtin_mulus(period, T2);
                    T2 = __builtin_sacr(a_Reg,0);
                    Tc = period-T1-T2;
                    Tc = Tc >> 1;
                    Tb = Tc + T1;
                    Ta = Tb + T2;
                pdcout->dutycycle1 = Ta;
                pdcout->dutycycle2 = Tc;
                pdcout->dutycycle3 = Tb;
            }
        }
        else
        {
            // (x00)
            // Must be Sector 4 since Sector 0 not allowed
            // Sector 4: (1,0,0)  180-240 degrees
            T1 = -abc->b;
            T2 = -abc->a;
                /* T1 = period * T1 */
                a_Reg = __builtin_mulus(period, T1);
                T1 = __builtin_sacr(a_Reg,0);
                /* T2 = period * T2 */
                a_Reg = __builtin_mulus(period, T2);
                T2 = __builtin_sacr(a_Reg,0);
                Tc = period-T1-T2;
                Tc = Tc >> 1;
                Tb = Tc + T1;
                Ta = Tb + T2;
            pdcout->dutycycle1 = Tc;
            pdcout->dutycycle2 = Tb;
            pdcout->dutycycle3 = Ta;
        }
    }

    CORCON = mcCorconSave;
    return(1);
}


static inline uint16_t MC_CalculateSineCosine_InlineC_Ram(int16_t angle, MC_SINCOS_T *sincos)
{
    uint16_t remainder, index, y0, y1, delta, return_value;
    uint32_t result;

    return_value = 0;
    
    /* Index = (Angle*128)/65536 */
    result = __builtin_muluu(128,angle);
    index = (result & 0xFFFF0000)>>16;
    remainder = (uint16_t) result & 0xFFFF;

    /* Check if interpolation is required or not */
    if(remainder == 0)
    {
        /* No interpolation required, use index only */
        sincos->sin = mcSineTableInRam[index];
        index = index+32;
        if (index > 127)
        {
            index = index - 128;
        }    
        sincos->cos = mcSineTableInRam[index];
        return_value = 1;
    }
    else
    {
        /* Interpolation required. Determine the delta between indexed value
         * and the next value from the mcSineTableInRam and scale the remainder 
         * with delta to get the linear interpolated value. */

        y0 = mcSineTableInRam[index];
        index = index+1;
        if (index > 127)
        {
            index = index - 128;
        }
        y1 = mcSineTableInRam[index];
        delta = y1 - y0;
        result = __builtin_mulus(remainder,delta);
        sincos->sin = y0 + ((result & 0xFFFF0000)>>16);

        /* Increment by 32 for cosine index. Increment by 31 here
         * since index has already been incremented once. */
        index = index+31;
        if (index > 127)
        {
            index = index - 128;
        }
        
        y0 = mcSineTableInRam[index];
        index = index+1;
        if (index > 127)
        {
            index = index - 128;
        }
        y1 = mcSineTableInRam[index];
        delta = y1 - y0;
        result = __builtin_mulus(remainder,delta);
        sincos->cos = y0 + ((result & 0xFFFF0000)>>16);
        return_value = 2;
    }
    return(return_value);
}


#ifdef __cplusplus  // Provide C++ Compatibility
    }
#endif

#endif // _MOTOR_CONTROL_INLINE_DSPIC

/* EOF */


