/* 
 * File:   init_motor_control.c
 * Author: jonathan
 *
 * Created on September 27, 2014, 5:52 PM
 */

#include "init_motor_control.h"
#include "../../PMSMx/PMSM.h"
#include <uart.h>

#define SPOOL_RADIUS_MM 30
#define MASK 0x00FFF000

extern float TRIG_DATA[];

/**

 */

uint32_t getBitsFromForce(int32_t torque)
{
	int32_t offSet = 8423700;
	int32_t modifier1 = -12172;
	int32_t modifier2 = -1494;

	return((modifier2 * torque * torque) + (modifier1 * torque) + offSet);
}

// This function is wrong !!!! DO NOT USE
// TODO: Find a fix for this funtion....

//int32_t getForceFromBits(int32_t bits)
//{
//		int64_t offSet = 53412668448;
//		int32_t modifier = -60;
//		int32_t torque;
//
//		torque = ((modifier * bits) + offSet); // [N-mm]
//
//		return(torque / SPOOL_RADIUS_MM);
//}

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

	static uint8_t loop = 0;
	static uint16_t counter = 0;
	float value;

	static int32_t To = 1 * 1000; // Tension Offset
	int32_t K = 150 * 2 * 1000; //1000000; // Length Gain Value
	int32_t B = 100 * 2 * 1000; //100000; // Velocity Gain Value
	static int32_t Lo; // Length Offset, currently 2*pi*30 [mm]
	static int32_t Vo; // Velocity Offset
	int32_t l; // Length in mm
	int32_t v; // Velocity in mm/s
	int32_t T; // Calculated Tension in [kg-mm/s^2]
	static uint8_t flag = 0;

	l = length;
	v = velocity;

	if (flag == 0) {
		Lo = l + 0;
		Vo = v + 100;
		flag = 1;
	}

	T = To + (K * (l - Lo)) + (B * (Vo - v));
	T = T * SPOOL_RADIUS_MM / 1000; // To get convert [kg-mm/s^2] to [kg-mm/s^2]-mm

	size = sprintf((char *) out, "Length: %i\r\n", l);
	DMA0_UART2_Transfer(size, (uint8_t *) out);

	//	loop++;
	//	if (loop > 1) {
	//		counter++;
	//		if (counter > 2048) {
	//			counter = 0;
	//		}
	//		loop = 0;
	//	}
	//	value = TRIG_DATA[counter]*(178056) + 8368128;
	//
	//	terrible_P_motor_controller((uint32_t) value);

	terrible_P_motor_controller(T / 1000); // Divide by 1000 to get real Newtons-meters
}

void terrible_P_motor_controller(uint32_t force)
{
	/**
	 * This is a gain to convert the sensor bits to a position in rads
	 * It is not a rigorously dervived value..... O.o
	 */
	float pGain = 50000 * 1.6;
	float iGain = 0; //0.000000011*200;
	float dGain = 0.000000938 * 1.25 * 1.8; //-0.00001;
	float forceSum;
	static float integratorSum;
	static float derivativeSum;
	static float lastError = 0;
	float total;

	forceSum = (float) ((getBitsFromForce(force) - Strain_Gauge1) & MASK); //(getBitsFromForce(force)

	integratorSum += forceSum;

	derivativeSum = forceSum - lastError;
	lastError = forceSum;

	total = (forceSum / pGain) + (iGain * integratorSum) + (derivativeSum * dGain);
	//	total = (forceSum / pGain);

	SpeedControlStep(-1 * total);
}
