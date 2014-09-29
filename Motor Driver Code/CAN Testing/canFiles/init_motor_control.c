/* 
 * File:   init_motor_control.c
 * Author: jonathan
 *
 * Created on September 27, 2014, 5:52 PM
 */

#include "init_motor_control.h"
#include "../../PMSMx/PMSM.h"
#include <math.h>

#define SPOOL_RADIUS_MM 30

/**
x[bits] = -9.4331y[kg] + 8.4259*10^6		(1)
x - 8.4259*10^6 = -9.4331y
(1/-9.4331)x + 94690.721 = y
-0.106x[bits] + 94690.721 = y[kg]		(2)
---------------------------------------------
N == kg*m/s^2
kg*gravity == N
moment_arm*kg*gravity == torque[N-m]
gravity = 9.81[m/s^2]
moment_arm = 57.5[mm]
57.5*[kg]*9.81 = torque[N-mm]
564.075*[kg] = torque[N-mm]			
0.564075*[kg] = torque[N-m]			(3)
[kg] = (1/0.564075)torque[N-m]
[kg] = 1.773*torque[N-m]			(4)
---------------------------------------------
(2) + (3):
0.564075*(-0.106x[bits] + 94690.721) = y[N-m]
-0.0598x[bits] + 94690.721 = y[N-m]
-59.8x[bits] + 94690721 = 1000y[N-m] // getForceFromBits
1000[N-mm] = [N-m]
-59.8x[bits] + 94690721 = y[N-mm]
(1) + (4):
x[bits] = -9.4331*1.773y[N-mm] + 8.4259*10^6
x[bits] = -16.725y[N-mm] + 8.4259*10^6 // getBitsFromForce
 */

int32_t getBitsFromForce(int32_t force)
{
	int32_t offSet = 8425900;
	int32_t modifier = -17;
	int32_t torque;

	torque = force*SPOOL_RADIUS_MM; // [N-mm]

	return((modifier * torque) + offSet);
}

int32_t getForceFromBits(int32_t bits)
{
	int32_t offSet = 94690721;
	int32_t modifier = -60;
	int32_t torque;

	torque = ((modifier * bits) + offSet); // [N-mm]

	return(torque / SPOOL_RADIUS_MM);
}

void impedance_controller(int32_t length, int32_t velocity)
{
	/**
	 * This controller uses the basic impedance equation of
	 * T = To + K(l-Lo) + B(v-Vo)
	 *
	 * NOTE: All length units are in mm so T == [kg-(mm/s^2)], v == [mm/s^2], l == [mm]
	 *
	 * @param length
	 * @param velocity
	 * @return uint32_t setTension
	 */

	static uint16_t size;
	static uint8_t out[56];

	const int32_t To = 100000; // Tension Offset
	const int32_t K = 1000; // Length Gain Value
	const int32_t B = 100; // Velocity Gain Value
	const int32_t Lo = 188; // Length Offset, currently 2*pi*30 [mm]
	const int32_t Vo = 0; // Velocity Offset
	int32_t l; // Length in mm
	int32_t v; // Velocity in mm/s
	int32_t T; // Calculated Tension in [kg-mm/s^2]

	l = length;
	v = velocity;

	T = To + (K * (Lo - l)) + (B * (Vo - v));

	terrible_P_motor_controller(getBitsFromForce(T / 1000)); // Divide by 1000 to get real Newtons
	size = sprintf((char *) out, "Rotor Offset: %li\r\n", getBitsFromForce(T / 1000));
	DMA0_UART2_Transfer(size, (uint8_t *) out);
}

void terrible_P_motor_controller(uint32_t bitForce)
{
	/**
	 * This is a gain to convert the sensor bits to a position in rads
	 * It is not a rigorously dervived value..... O.o
	 */
	//	int32_T pGain = 100000;
	int32_t deltaBitForce;
	static int32_t commandedPosition = 0;

	if (Strain_Gauge1 > 0) {
		if (bitForce < 8323072) {
			if (bitForce > (Strain_Gauge1 & 0xFF0000)) {
				deltaBitForce = -30;
			} else if (bitForce < (Strain_Gauge1 & 0xFF0000)) {
				deltaBitForce = 30;
			} else {
				deltaBitForce = 0;
			}
		}
	}

	commandedPosition += deltaBitForce;
	SetPosition((float) (commandedPosition));
}
