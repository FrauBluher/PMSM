/* 
 * File:   FOC_FixedPoint.h
 * Author: pavlo
 *
 * Created on April 8, 2015, 9:27 AM
 */

#ifndef FOC_FIXEDPOINT_H
#define	FOC_FIXEDPOINT_H

#include <libq.h>

void FOC_Init(void);

void FOC_Update_Commutation(_Q15 torque, int32_t rotorPosition);

#endif	/* FOC_FIXEDPOINT_H */

