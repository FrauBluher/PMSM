/* 
 * File:   init_motor_control.h
 * Author: jonathan
 *
 * Created on September 27, 2014, 5:55 PM
 */

#ifndef INIT_MOTOR_CONTROL_H
#define	INIT_MOTOR_CONTROL_H

#include "motor_can.h"

static float total;


#ifdef	__cplusplus
extern "C" {
#endif

    /**
     * This controller uses the basic impedance equation of
     * T = To + K(l-lo) + B(v-vo)
     *
     * This Function calls terrible_P_motor_controller
     * @param length
     * @param velocity
     *
     */
    void impedance_controller(int32_t length, int32_t velocity);

    /**
     *
     * @param force in [N]
     * @return A converted value for strain gauge bits
     */
    float getBitsFromForce(float torque);

    /**
     *
     * @param bits
     * @return a force value in [N]
     */
    int32_t getForceFromBits(int32_t bits);

    void terrible_P_motor_controller(float bitForce);


#ifdef	__cplusplus
}
#endif

#endif	/* INIT_MOTOR_CONTROL_H */

