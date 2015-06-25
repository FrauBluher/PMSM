/*******************************************************************************
  Motor Control Library Interface Header File

  File Name:
    motor_control.h

  Summary:
    This header file lists all the interfaces used by the Motor Control library.

  Description:
    This header file lists the type defines for structures used by the Motor 
    Control library. Library function definitions are also listed along with
    information regarding the arguments of each library function. This header file
    also includes another header file that hosts inline definitions of certain
    library functions.
*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
Copyright (c) 2013 released Microchip Technology Inc. All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND,
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
/*******************************************************************************
Note:
* Some parts of this header file are protected by #ifdef __XC16__. These protections
  are provided to accomodate non-XC16 compilers to work with this header file.
  Similarly, sections of the header file related to the MATLAB-based compiler are
  protected by #ifdef __MATLAB_MEX__ protections.
* Some of the function declarations have a MC_ATTRB prefix. This prefix has been
  provided as a placeholder for adding attributes for supporting future versions
  of the compiler.
*******************************************************************************/
// DOM-IGNORE-END

#ifndef _MOTOR_CONTROL_H_    // Guards against multiple inclusion
#define _MOTOR_CONTROL_H_

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stdint.h>
#ifdef __XC16__  // See comments at the top of this header file
#include <xc.h>
#endif // __XC16__
#include "motor_control_mapping.h"

#if __XC16_VERSION__ > 1011     // Place-holder function attribute prefix
#define MC_ATTRB
#else
#define MC_ATTRB 
#endif

#ifdef __cplusplus  // Provide C++ Compatability
    extern "C" {
#endif

#ifdef __MATLAB_MEX__ // See comments at the top of this header file
#define inline
#endif // __MATLAB_MEX




// *****************************************************************************
// *****************************************************************************
// Section: Data Types
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Alpha-Beta reference frame data type

  Description:
    This structure will host parameters related to Alpha-Beta reference frame.
*/
typedef struct
{
    // Alpha component
    int16_t alpha;
    
    // Beta component
    int16_t beta;
} MC_ALPHABETA_T;

// *****************************************************************************
/* Sine-Cosine data type

  Description:
    This structure will host parameters related to Sine and Cosine components of the motor angle.
*/
typedef struct
{
    // Cosine component
    int16_t cos;
    
    // Sine component
    int16_t sin;
} MC_SINCOS_T;

// *****************************************************************************
/* D-Q reference frame data type

  Description:
    This structure will host parameters related to D-Q reference frame.
*/
typedef struct
{
    // D-axis component
    int16_t d;
    
    // Q-axis component
    int16_t q;
} MC_DQ_T;

// *****************************************************************************
/* Duty-cycle data type

  Description:
    This structure will host parameters related to PWM module Duty Cycle values.
*/
typedef struct
{
    // Duty cycle for phase #1
    uint16_t dutycycle1;
    
    // Duty cycle for phase #2
    uint16_t dutycycle2;
    
    // Duty cycle for phase #3
    uint16_t dutycycle3;
} MC_DUTYCYCLEOUT_T;

// *****************************************************************************
/* ABC reference frame data type

  Description:
    This structure will host parameters related to ABC reference frame.
*/
typedef struct
{
    // Phase A component 
    int16_t a;
    
    // Phase B component
    int16_t b;
    
    // Phase C component
    int16_t c;
} MC_ABC_T;

// *****************************************************************************
/* PI Controller State data type

  Description:
    This structure will host parameters related to the PI Controller state.
*/
typedef struct
{
    // Integrator sum
    int32_t integrator;
    
    // Proportional gain co-efficient term
    int16_t kp;
    
    // Integral gain co-efficient term
    int16_t ki;
    
    // Excess gain co-efficient term
    int16_t kc;

    // Maximum output limit
    int16_t outMax;
    
    // Minimum output limit
    int16_t outMin;
} MC_PISTATE_T;

// *****************************************************************************
/* PI Controller Input data type

  Summary:
    PI Controller input type define

  Description:
    This structure will host parameters related to the PI Controller input. PI
    controller state is a part of the PI Controller input.
*/
typedef struct
{
    // PI state as input parameter to the PI controller
    MC_PISTATE_T piState;
    
    // Input reference to the PI controller
    int16_t inReference;
    
    // Input measured value
    int16_t inMeasure;
} MC_PIPARMIN_T;

// *****************************************************************************
/* PI Controller Output data type

  Description:
    This structure will host parameters related to the PI Controller output.
*/
typedef struct
{
    int16_t out;        // Output of the PI controller
} MC_PIPARMOUT_T;




// *****************************************************************************
// *****************************************************************************
// Section: Interface Routines
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    uint16_t MC_CalculateSineCosine_Assembly_Ram(int16_t angle, MC_SINCOS_T *pSinCos)

  Summary:    
    This function calculates the Sine and Cosine values for a specified angle input.
    
  Description:
    This function calculates the Sine and Cosine values for specified angle input using 
    linear interpolation on a sine table of 128 words. This routine works the same for 
    both integer input and 1.15 scaling input.

  Precondition:
    None.

  Parameters:
    angle           - Input - This parameter is the input angle which will be used to calculate 
                      the Sine and Cosine components.
    pSinCos         - Output - This parameter is a pointer to a MC_SINCOS_T type structure to
                      which the Sine and Cosine components of the angle are written.

  Returns:
    Unsigned integer value '1' for direct look up and '2' for interpolation.

  Example:
    <code>
    uint16_t temp;
    int16_t angle;
    MC_SINCOS_T mcSinCos;
    temp = MC_CalculateSineCosine_Assembly_Ram(angle, &mcSinCos);    
    </code>  
    
  Remarks:
    For integer scaling the Angle is scaled such that 0 <= Angle < 2*pi corresponds
    to 0 <= Ang < 0xFFFF. The resulting Sine and Cosine values are returned scaled to
    -32769 -> 32767 i.e. (0x8000 -> 0x7FFF).
    For 1.15 scaling the Angle is scaled such that -pi <= Angle < pi corresponds to
    -1 -> 0.9999 i.e. (0x8000 <= Ang < 0x7FFF). The resulting Sine and Cosine values are
    returned scaled to -1 -> 0.9999 i.e. (0x8000 -> 0x7FFF).   
 *******************************************************************************/ 
uint16_t MC_ATTRB MC_CalculateSineCosine_Assembly_Ram(int16_t angle,
                                                      MC_SINCOS_T *pSinCos);


/*******************************************************************************
  Function:
    static inline uint16_t MC_CalculateSineCosine_InlineC_Ram(int16_t angle, MC_SINCOS_T *pSinCos)

  Summary:
    This function calculates the Sine and Cosine values for a specified angle input.

  Description:
    This function calculates the Sine and Cosine values for specified angle input using 
    linear interpolation on a sine table of 128 words. This routine works the same for 
    both integer input and 1.15 scaling input.

    Inline keyword has been added to the function declaration so that, when appropriate,
    the compiler may inline the function call, thus eliminating the function call overhead.
    Static keyword has been added to the function declaration so that, if all calls
    to the function are integrated into the caller and when the function's address 
    is never used, then the function's own assembler code is never referenced and 
    unless specified in the command-line option, the compiler will not actually output
    assembler code for the function.

  Precondition:
    None.

  Parameters:
    angle           - Input - This parameter is the input angle which will be used to calculate
                      the Sine and Cosine components.
    pSinCos         - Output - This parameter is a pointer to a MC_SINCOS_T type structure to
                      which the Sine and Cosine components of the angle are written.

  Returns:
    Unsigned integer value '1' for direct look up and '2' for interpolation.

  Example:
    <code>
    uint16_t temp;
    int16_t angle;
    MC_SINCOS_T mcSinCos;
    temp = MC_CalculateSineCosine_InlineC_Ram(angle, &mcSinCos);
    </code>

  Remarks:
    This function uses the sine-table included within the library archive file. Hence,
    the library archive file must be included in the application project for this function
    to link correctly.
    
    For integer scaling the Angle is scaled such that 0 <= Angle < 2*pi corresponds
    to 0 <= Ang < 0xFFFF. The resulting Sine and Cosine values are returned scaled to
    -32769 -> 32767 i.e. (0x8000 -> 0x7FFF).
    For 1.15 scaling the Angle is scaled such that -pi <= Angle < pi corresponds to
    -1 -> 0.9999 i.e. (0x8000 <= Ang < 0x7FFF). The resulting Sine and Cosine values are
    returned scaled to -1 -> 0.9999 i.e. (0x8000 -> 0x7FFF).    
 *******************************************************************************/
static inline uint16_t MC_ATTRB MC_CalculateSineCosine_InlineC_Ram(int16_t angle,
                                                                   MC_SINCOS_T *pSinCos);


/*******************************************************************************
  Function:
    uint16_t MC_TransformParkInverse_Assembly(MC_DQ_T *pDQ, MC_SINCOS_T *pSinCos, MC_ALPHABETA_T *pAlphaBeta)

  Summary:
    This function calculates the inverse Park transformation.

  Description:
    This function calculates the inverse Park transform on a pair of stationary reference frame inputs.
    Inverse park transformation is performed as described by the equation:
    <code>
    alpha = d*cos - q*sin
    beta = d*sin + q*cos
    </code>

  Precondition:
    None.

  Parameters:
    pDQ             - Input - This parameter is a pointer to a MC_DQ_T type structure.
    pSinCos         - Input - This parameter is a pointer to a MC_SINCOS_T type structure.
    pAlphaBeta      - Output - This parameter is a pointer to a MC_ALPHABETA_T type structure.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_DQ_T mcVDQ;    
    MC_SINCOS_T mcSinCos;    
    MC_ALPHABETA_T mcVAlphaBeta;   
    temp = MC_TransformParkInverse_Assembly(&mcVDQ, &mcSinCos, &mcVAlphaBeta);
    </code>

  Remarks:
    This routine requires inputs in the 1.15 format.
*******************************************************************************/
uint16_t MC_ATTRB MC_TransformParkInverse_Assembly(MC_DQ_T *pDQ,
                                                              MC_SINCOS_T *pSinCos,
                                                              MC_ALPHABETA_T *pAlphaBeta);


/*******************************************************************************
  Function:
    static inline uint16_t MC_TransformParkInverse_InlineC(MC_DQ_T *pDQ, MC_SINCOS_T *pSinCos, MC_ALPHABETA_T *pAlphaBeta)

  Summary:
    This function calculates the inverse Park transformation.

  Description:
    This function calculates the inverse Park transform on a pair of stationary reference frame inputs.
    Inverse park transformation is performed as described by the equation:
    <code>
    alpha = d*cos - q*sin
    beta = d*sin + q*cos
    </code>

    Inline keyword has been added to the function declaration so that, when appropriate,
    the compiler may inline the function call, thus eliminating the function call overhead.
    Static keyword has been added to the function declaration so that, if all calls
    to the function are integrated into the caller and when the function's address 
    is never used, then the function's own assembler code is never referenced and 
    unless specified in the command-line option, the compiler will not actually output
    assembler code for the function.

  Precondition:
    None.

  Parameters:
    pDQ             - Input - This parameter is a pointer to a MC_DQ_T type structure.
    pSinCos         - Input - This parameter is a pointer to a MC_SINCOS_T type structure.
    pAlphaBeta      - Output - This parameter is a pointer to a MC_ALPHABETA_T type structure.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_DQ_T mcVDQ;
    MC_SINCOS_T mcSinCos;
    MC_ALPHABETA_T mcVAlphaBeta;
    temp = MC_TransformParkInverse_InlineC(&mcVDQ, &mcSinCos, &mcVAlphaBeta);
    </code>

  Remarks:
    This routine requires inputs in the 1.15 format.
*******************************************************************************/
static inline uint16_t MC_ATTRB MC_TransformParkInverse_InlineC(MC_DQ_T *pDQ,
                                                                MC_SINCOS_T *pSinCos,
                                                                MC_ALPHABETA_T *pAlphaBeta);


/*******************************************************************************
  Function:
    uint16_t MC_TransformClarkeInverseSwappedInput_Assembly(MC_ALPHABETA_T *pAlphaBeta, MC_ABC_T *pABC)

  Summary:
    This function calculates the scaled reference vectors using inputs in an alpha-beta reference frame.

  Description:
    This function calculates the scaled reference vectors in an a-b-c reference frame using
    inputs from an alpha-beta reference frame, as described by the equation: 
    <code>
    a = beta
    b = -beta/2 + (sqrt(3)/2) * alpha
    c = -beta/2 - (sqrt(3)/2) * alpha
    </code>
    
    This is a modified variant of the inverse Clarke transformation where alpha & beta are
    swapped compared to the normal inverse Clarke transformation. This function is designed
    to work with the CalculateSpaceVectorPhaseShifted() in order to simplify the calculation of
    three-phase duty cycle values from a given set of inputs in the alpha-beta reference frame.

  Precondition:
    None.

  Parameters:
    pAlphaBeta      - Input - This parameter is a pointer to a MC_ALPHABETA_T type structure.
    pABC            - Output - This parameter is a pointer to a MC_ABC_T type structure.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_ALPHABETA_T mcVAlphaBeta;    
    MC_ABC_T mcVabc;
    temp = MC_TransformClarkeInverseSwappedInput_Assembly(&mcVAlphaBeta, &mcVabc);
    </code>

  Remarks:
    This routine requires inputs in the 1.15 format.
*******************************************************************************/
uint16_t MC_ATTRB MC_TransformClarkeInverseSwappedInput_Assembly(MC_ALPHABETA_T *pAlphaBeta,
                                                                 MC_ABC_T *pABC);


/*******************************************************************************
  Function:
    static inline uint16_t MC_TransformClarkeInverseSwappedInput_InlineC(MC_ALPHABETA_T *pAlphaBeta, MC_ABC_T *pABC)

  Summary:
    This function calculates the scaled reference vectors using inputs in an alpha-beta reference frame.

  Description:
    This function calculates the scaled reference vectors in an a-b-c reference frame using
    inputs from an alpha-beta reference frame, as described by the equation: 
    <code>
    a = beta
    b = -beta/2 + (sqrt(3)/2) * alpha
    c = -beta/2 - (sqrt(3)/2) * alpha
    </code>
    
    This is a modified variant of the inverse Clarke transformation where alpha & beta are
    swapped compared to the normal inverse Clarke transformation. This function is designed
    to work with the CalculateSpaceVectorPhaseShifted() in order to simplify the calculation of
    three-phase duty cycle values from a given set of inputs in the alpha-beta reference frame.

    Inline keyword has been added to the function declaration so that, when appropriate,
    the compiler may inline the function call, thus eliminating the function call overhead.
    Static keyword has been added to the function declaration so that, if all calls
    to the function are integrated into the caller and when the function's address
    is never used, then the function's own assembler code is never referenced and
    unless specified in the command-line option, the compiler will not actually output
    assembler code for the function.

  Precondition:
    None.

  Parameters:
    pAlphaBeta      - Input - This parameter is a pointer to a MC_ALPHABETA_T type structure.
    pABC            - Output - This parameter is a pointer to a MC_ABC_T type structure.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_ALPHABETA_T mcVAlphaBeta;
    MC_ABC_T mcVabc;
    temp = MC_TransformClarkeInverseSwappedInput_InlineC(&mcVAlphaBeta, &mcVabc);
    </code>

  Remarks:
    This routine requires inputs in the 1.15 format.
*******************************************************************************/
static inline uint16_t MC_ATTRB MC_TransformClarkeInverseSwappedInput_InlineC(MC_ALPHABETA_T *pAlphaBeta,
                                                                              MC_ABC_T *pABC);


/*******************************************************************************
  Function:
    uint16_t MC_CalculateSpaceVectorPhaseShifted_Assembly(MC_ABC_T *pABC, uint16_t iPwmPeriod, MC_DUTYCYCLEOUT_T *pDutyCycleOut)

  Summary:
    This function calculates the duty cycle values based on the three scaled
    reference vectors in the a-b-c reference frame and the PWM period value.

  Description:
    This function calculates the duty cycle values based on the three scaled reference
    vectors in the a-b-c reference frame and the PWM period value. 

    This function is designed to work with the TransformClarkeInverseSwappedInput() 
    in order to simplify the calculation of three-phase duty cycle values from a given 
    set of inputs in the alpha-beta reference frame.
    This function uses a reference axis that is phase shifted by 30 degrees relative
    to the standard Space Vector Modulation reference axis. This phase-shifted reference
    axis is accomodated by using reference vector inputs from a modified version of
    the inverse Clarke transform which swaps the alpha-beta values at its input.

  Precondition:
    None.

  Parameters:
    pABC            - Input - This parameter is a pointer to a MC_ABC_T type structure.
    iPwmPeriod      - Input - This parameter is an unsigned integer value of the PWM period.
    pDutyCycleOut   - Output - This parameter is a pointer to a MC_DUTYCYCLEOUT_T type structure.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_ABC_T mcVabc;
    uint16_t iPwmPeriod;
    MC_DUTYCYCLEOUT_T mcDutyCycleOut;
    temp = MC_CalculateSpaceVectorPhaseShifted_Assembly(&mcVabc, iPwmPeriod, &mcDutyCycleOut);
    </code>

  Remarks:
    This routine requires inputs in the 1.15 format.
*******************************************************************************/
uint16_t MC_ATTRB MC_CalculateSpaceVectorPhaseShifted_Assembly(MC_ABC_T *pABC,
                                                               uint16_t iPwmPeriod,
                                                               MC_DUTYCYCLEOUT_T *pDutyCycleOut);


/*******************************************************************************
  Function:
    static inline uint16_t MC_CalculateSpaceVectorPhaseShifted_InlineC(MC_ABC_T *pABC, uint16_t iPwmPeriod, MC_DUTYCYCLEOUT_T *pDutyCycleOut)

  Summary:
    This function calculates the duty cycle values based on the three scaled
    reference vectors in the a-b-c reference frame and the PWM period value.

  Description:
    This function calculates the duty cycle values based on the three scaled reference
    vectors in the a-b-c reference frame and the PWM period value.

    This function is designed to work with the TransformClarkeInverseSwappedInput()
    in order to simplify the calculation of three-phase duty cycle values from a given
    set of inputs in the alpha-beta reference frame.
    This function uses a reference axis that is phase shifted by 30 degrees relative
    to the standard Space Vector Modulation reference axis. This phase-shifted reference
    axis is accomodated by using reference vector inputs from a modified version of
    the inverse Clarke transform which swaps the alpha-beta values at its input.

    Inline keyword has been added to the function declaration so that, when appropriate,
    the compiler may inline the function call, thus eliminating the function call overhead.
    Static keyword has been added to the function declaration so that, if all calls
    to the function are integrated into the caller and when the function's address
    is never used, then the function's own assembler code is never referenced and
    unless specified in the command-line option, the compiler will not actually output
    assembler code for the function.

  Precondition:
    None.

  Parameters:
    pABC            - Input - This parameter is a pointer to a MC_ABC_T type structure.
    iPwmPeriod      - Input - This parameter is an unsigned integer value of the PWM period.
    pDutyCycleOut   - Output - This parameter is a pointer to a MC_DUTYCYCLEOUT_T type structure.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_ABC_T mcVabc;
    uint16_t iPwmPeriod;
    MC_DUTYCYCLEOUT_T mcDutyCycleOut;
    temp = MC_CalculateSpaceVectorPhaseShifted_InlineC(&mcVabc, iPwmPeriod, &mcDutyCycleOut);
    </code>

  Remarks:
    This routine requires inputs in the 1.15 format.
*******************************************************************************/
static inline uint16_t MC_ATTRB MC_CalculateSpaceVectorPhaseShifted_InlineC(MC_ABC_T *pABC,
                                                                            uint16_t iPwmPeriod,
                                                                            MC_DUTYCYCLEOUT_T *pDutyCycleOut);

/*******************************************************************************
  Function:
    uint16_t MC_TransformClarke_Assembly(MC_ABC_T *pABC, MC_ALPHABETA_T *pAlphaBeta)

  Summary:
    This function calculates the Clarke transformation.

  Description:
    This function transforms inputs in an a-b-c reference frame to an alpha-beta
    reference frame using the equation:
    <code>
    alpha = a
    beta = a*(1/sqrt(3)) + 2*b*(1/sqrt(3))
    </code>

  Precondition:
    None.

  Parameters:
    pABC            - Input - This parameter is a pointer to a MC_ABC_T type structure.
    pAlphaBeta      - Output - This parameter is a pointer to a MC_ALPHABETA_T type structure.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_ABC_T mcIabc;
    MC_ALPHABETA_T mcIAlphaBeta;    
    temp = MC_TransformClarke_Assembly(&mcIabc, &mcIAlphaBeta);
    </code>  
    
  Remarks:
   This routine requires inputs in the 1.15 format.
*******************************************************************************/
uint16_t MC_ATTRB MC_TransformClarke_Assembly(MC_ABC_T *pABC,
                                              MC_ALPHABETA_T *pAlphaBeta);


/*******************************************************************************
  Function:
    static inline uint16_t MC_TransformClarke_InlineC(MC_ABC_T *pABC, MC_ALPHABETA_T *pAlphaBeta)

  Summary:
    This function calculates the Clarke transformation.

  Description:
    This function transforms inputs in an a-b-c reference frame to an alpha-beta
    reference frame using the equation:
    <code>
    alpha = a
    beta = a*(1/sqrt(3)) + 2*b*(1/sqrt(3))
    </code>

    Inline keyword has been added to the function declaration so that, when appropriate,
    the compiler may inline the function call, thus eliminating the function call overhead.
    Static keyword has been added to the function declaration so that, if all calls
    to the function are integrated into the caller and when the function's address
    is never used, then the function's own assembler code is never referenced and
    unless specified in the command-line option, the compiler will not actually output
    assembler code for the function.

  Precondition:
    None.

  Parameters:
    pABC            - Input - This parameter is a pointer to a MC_ABC_T type structure.
    pAlphaBeta      - Output - This parameter is a pointer to a MC_ALPHABETA_T type structure.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_ABC_T mcIabc;
    MC_ALPHABETA_T mcIAlphaBeta;
    temp = MC_TransformClarke_InlineC(&mcIabc, &mcIAlphaBeta);
    </code>

  Remarks:
    This routine requires inputs in the 1.15 format.
*******************************************************************************/
static inline uint16_t MC_ATTRB MC_TransformClarke_InlineC(MC_ABC_T *pABC,
                                                           MC_ALPHABETA_T *pAlphaBeta);


/*******************************************************************************
  Function:
    uint16_t MC_TransformPark_Assembly(MC_ALPHABETA_T *pAlphaBeta, MC_SINCOS_T *pSinCos, MC_DQ_T *pDQ)

  Summary:
    This function calculates the Park transformation.

  Description:
    This function transforms inputs in an alpha-beta reference frame to a stationary
    d-q reference frame using the equation:
    <code>
    d = alpha*cos + beta*sin
    q = -alpha*sin + beta*cos
    </code>

  Precondition:
    None.

  Parameters:
    pAlphaBeta      - Input - This parameter is a pointer to a MC_ALPHABETA_T type structure.
    pSinCos         - Input - This parameter is a pointer to a MC_SINCOS_T type structure.
    pDQ             - Output - This parameter is a pointer to a MC_DQ_T type structure.
    
  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_ALPHABETA_T mcIAlphaBeta;
    MC_SINCOS_T mcSinCos;
    MC_DQ_T mcIDQ;
    temp = MC_TransformPark_Assembly(&mcIAlphaBeta, &mcSinCos, &mcIDQ);
    </code>  
    
  Remarks:
    This routine requires inputs in the 1.15 format.
*******************************************************************************/
uint16_t MC_ATTRB MC_TransformPark_Assembly(MC_ALPHABETA_T *pAlphaBeta,
                                            MC_SINCOS_T *pSinCos,
                                            MC_DQ_T *pDQ);


/*******************************************************************************
  Function:
    static inline uint16_t MC_TransformPark_InlineC(MC_ALPHABETA_T *pAlphaBeta, MC_SINCOS_T *pSinCos, MC_DQ_T *pDQ)

  Summary:
    This function calculates the Park transformation.

  Description:
    This function transforms inputs in an alpha-beta reference frame to a stationary
    d-q reference frame using the equation:
    <code>
    d = alpha*cos + beta*sin
    q = -alpha*sin + beta*cos
    </code>

    Inline keyword has been added to the function declaration so that, when appropriate,
    the compiler may inline the function call, thus eliminating the function call overhead.
    Static keyword has been added to the function declaration so that, if all calls
    to the function are integrated into the caller and when the function's address
    is never used, then the function's own assembler code is never referenced and
    unless specified in the command-line option, the compiler will not actually output
    assembler code for the function.

  Precondition:
    None.

  Parameters:
    pAlphaBeta      - Input - This parameter is a pointer to a MC_ALPHABETA_T type structure.
    pSinCos         - Input - This parameter is a pointer to a MC_SINCOS_T type structure.
    pDQ             - Output - This parameter is a pointer to a MC_DQ_T type structure.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_ALPHABETA_T mcIAlphaBeta;
    MC_SINCOS_T mcSinCos;
    MC_DQ_T mcIDQ;
    temp = MC_TransformPark_InlineC(&mcIAlphaBeta, &mcSinCos, &mcIDQ);
    </code>

  Remarks:
    This routine requires inputs in the 1.15 format.
*******************************************************************************/
static inline uint16_t MC_ATTRB MC_TransformPark_InlineC(MC_ALPHABETA_T *pAlphaBeta,
                                                         MC_SINCOS_T *pSinCos,
                                                         MC_DQ_T *pDQ);


/*******************************************************************************
  Function:
    uint16_t MC_ControllerPIUpdate_Assembly(int16_t inReference, int16_t inMeasure, MC_PISTATE_T *pPIState, int16_t *pPIParmOutput)
                                        
  Summary:
    This function calculates the PI correction.

  Description:
    This function calculates a PI correction output from a given measured input and a reference.
    The equation for PI output is:
    <code>
    out = Kp*(inReference-inMeasure) + Ki*Integral[inReference-inMeasure, dt] - Kc*Excess
    </code>
    Where,
    out = Fractional 1.15 output, is limited to between outMax and outMin.
    Kp = Proportional gain co-efficient term
    Ki = Integral gain co-efficient term
    Kc = Excess gain co-efficient term
    Excess = Excess error after "out" is limited to between outMax and outMin.
    This implementation includes an anti-windup term to limit the integral windup.

  Precondition:
    None.

  Parameters:
    inReference     - Input - This parameter is a 1.15 fractional format reference input.
    inMeasure       - Input - This parameter is a 1.15 fractional format measured input.
    pPIState        - Input/Output - This paramater is a pointer to a MC_PISTATE_T type structure.
    pPIParmOutput   - Output - This paramater is a pointer to a signed integer type variable.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_PIPARMIN_T mcPIParmInput;
    MC_PIPARMOUT_T mcPIParmOutput;
    temp = MC_ControllerPIUpdate_Assembly(mcPIParmInput.inReference, mcPIParmInput.inMeasure, &mcPIParmInput.piState, &mcPIParmOutput.out);
    </code>  
    
  Remarks:
    This routine requires inputs in the 1.15 format, except for Kp which is in 1.11 format.
    The constant Kp is scaled so it can be represented in 1.15 format by adjusting the constant 
    by a power of 2.
*******************************************************************************/
uint16_t MC_ATTRB MC_ControllerPIUpdate_Assembly(int16_t inReference,
                                                 int16_t inMeasure,
                                                 MC_PISTATE_T *pPIState,
                                                 int16_t *pPIParmOutput);


/*******************************************************************************
  Function:
    static inline uint16_t MC_ControllerPIUpdate_InlineC(int16_t inReference, int16_t inMeasure, MC_PISTATE_T *pPIState, int16_t *pPIParmOutput)

  Summary:
    This function calculates the PI correction.

  Description:
    This function calculates a PI correction output from a given measured input and a reference.
    The equation for PI output is:
    <code>
    out = Kp*(inReference-inMeasure) + Ki*Integral[inReference-inMeasure, dt] - Kc*Excess
    </code>
    Where,
    out = Fractional 1.15 output, is limited to between outMax and outMin.
    Kp = Proportional gain co-efficient term
    Ki = Integral gain co-efficient term
    Kc = Excess gain co-efficient term
    Excess = Excess error after "out" is limited to between outMax and outMin.
    This implementation includes an anti-windup term to limit the integral windup.

    Inline keyword has been added to the function declaration so that, when appropriate,
    the compiler may inline the function call, thus eliminating the function call overhead.
    Static keyword has been added to the function declaration so that, if all calls
    to the function are integrated into the caller and when the function's address
    is never used, then the function's own assembler code is never referenced and
    unless specified in the command-line option, the compiler will not actually output
    assembler code for the function.

  Precondition:
    None.

  Parameters:
    inReference     - Input - This parameter is a 1.15 fractional format reference input.
    inMeasure       - Input - This parameter is a 1.15 fractional format measured input.
    pPIState        - Input/Output - This paramater is a pointer to a MC_PISTATE_T type structure.
    pPIParmOutput   - Output - This paramater is a pointer to a signed integer type variable.

  Returns:
    Unsigned integer value '1'.

  Example:
    <code>
    MC_PIPARMIN_T mcPIParmInput;
    MC_PIPARMOUT_T mcPIParmOutput;
    temp = MC_ControllerPIUpdate_InlineC(mcPIParmInput.inReference, mcPIParmInput.inMeasure, &mcPIParmInput.piState, &mcPIParmOutput.out);
    </code>

  Remarks:
    This routine requires inputs in the 1.15 format, except for Kp which is in 1.11 format.
    The constant Kp is scaled so it can be represented in 1.15 format by adjusting the constant 
    by a power of 2.
*******************************************************************************/
static inline uint16_t MC_ATTRB MC_ControllerPIUpdate_InlineC(int16_t inReference,
                                                              int16_t inMeasure,
                                                              MC_PISTATE_T *pPIState,
                                                              int16_t *pPIParmOutput);


#ifdef __XC16__   // See comments at the top of this header file
#include "./motor_control_inline_dspic.h"
#endif // __XC16__

#ifdef __cplusplus  // Provide C++ Compatibility
    }
#endif
#endif // _MOTOR_CONTROL_H


/* EOF */


