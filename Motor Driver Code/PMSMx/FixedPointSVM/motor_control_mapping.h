/*******************************************************************************
  Motor Control Library Interface Header File

  File Name:
    motor_control_mapping.h

  Summary:
    Library function name mapping file.

  Description:
    This header file defines a simple function name for each of the library 
    function and maps it, by default, to the prototype of one of the implementation 
    variants.
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

#ifndef _MOTOR_CONTROL_MAPPING_H_    // Guards against multiple inclusion
#define _MOTOR_CONTROL_MAPPING_H_


// *****************************************************************************

#ifdef MC_CONFIG_CALCULATESINECOSINE_ASSEMBLY_RAM
#define MC_CalculateSineCosine MC_CalculateSineCosine_Assembly_Ram
#elif defined(MC_CONFIG_CALCULATESINECOSINE_ASSEMBLY_FLASH)
#define MC_CalculateSineCosine MC_CalculateSineCosine_Assembly_Flash
#elif defined(MC_CONFIG_CALCULATESINECOSINE_INLINEC_RAM)
#define MC_CalculateSineCosine MC_CalculateSineCosine_InlineC_Ram
#elif defined(MC_CONFIG_CALCULATESINECOSINE_INLINEC_FLASH)
#define MC_CalculateSineCosine MC_CalculateSineCosine_InlineC_Flash
#else
#define MC_CalculateSineCosine MC_CalculateSineCosine_Assembly_Ram
#endif

// *****************************************************************************

#ifdef MC_CONFIG_TRANSFORMPARKINVERSE_ASSEMBLY
#define MC_TransformParkInverse MC_TransformParkInverse_Assembly
#elif defined(MC_CONFIG_TRANSFORMPARKINVERSE_INLINEC)
#define MC_TransformParkInverse MC_TransformParkInverse_InlineC
#else
#define MC_TransformParkInverse MC_TransformParkInverse_Assembly
#endif

// *****************************************************************************

#ifdef MC_CONFIG_TRANSFORMCLARKEINVERSELEGACY_ASSEMBLY
#define MC_TransformClarkeInverse MC_TransformClarkeInverseSwappedInput_Assembly
#elif defined(MC_CONFIG_TRANSFORMCLARKEINVERSELEGACY_INLINEC)
#define MC_TransformClarkeInverse MC_TransformClarkeInverseSwappedInput_InlineC
#else
#define MC_TransformClarkeInverse MC_TransformClarkeInverseSwappedInput_Assembly
#endif

// *****************************************************************************

#ifdef MC_CONFIG_CALCULATESPACEVECTORLEGACY_ASSEMBLY
#define MC_CalculateSpaceVector MC_CalculateSpaceVectorPhaseShifted_Assembly
#elif defined(MC_CONFIG_CALCULATESPACEVECTORLEGACY_INLINEC)
#define MC_CalculateSpaceVector MC_CalculateSpaceVectorPhaseShifted_InlineC
#else
#define MC_CalculateSpaceVector MC_CalculateSpaceVectorPhaseShifted_Assembly
#endif

// *****************************************************************************

#ifdef MC_CONFIG_TRANSFORMCLARKE_ASSEMBLY
#define MC_TransformClarke MC_TransformClarke_Assembly
#elif defined(MC_CONFIG_TRANSFORMCLARKE_INLINEC)
#define MC_TransformClarke MC_TransformClarke_InlineC
#else
#define MC_TransformClarke MC_TransformClarke_Assembly
#endif

// *****************************************************************************

#ifdef MC_CONFIG_TRANSFORMPARK_ASSEMBLY
#define MC_TransformPark MC_TransformPark_Assembly
#elif defined(MC_CONFIG_TRANSFORMPARK_INLINEC)
#define MC_TransformPark MC_TransformPark_InlineC
#else
#define MC_TransformPark MC_TransformPark_Assembly
#endif

// *****************************************************************************

#ifdef MC_CONFIG_CONTROLLERPIUPDATE_ASSEMBLY
#define MC_ControllerPIUpdate MC_ControllerPIUpdate_Assembly
#elif defined(MC_CONFIG_CONTROLLERPIUPDATE_INLINEC)
#define MC_ControllerPIUpdate MC_ControllerPIUpdate_InlineC
#else
#define MC_ControllerPIUpdate MC_ControllerPIUpdate_Assembly
#endif

// *****************************************************************************


#endif // _MOTOR_CONTROL_MAPPING_H_

// DOM-IGNORE-END
