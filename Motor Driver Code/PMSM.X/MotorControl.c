#include "MotorControl.h"
#include <dsp.h>
#define SQRT_3 1.73205080756887729352744634150587236694

typedef struct {
	commAngle;
} FOCInfo;

/*
 * PID Structs for dsp PID functionality.
 *
 *                                       ----   Proportional
 *                                      |    |  Output
 *                             ---------| Kp |-----------------
 *                            |         |    |                 |
 *                            |          ----                  |
 *   Reference                |                               ---
 *   Input      ---           |     --------------  Integral | + | Control   -------
 *     --------| + |  Control |    |      Ki      | Output   |   | Output   |       |
 *             |   |----------|----| ------------ |----------|+  |----------| Plant |--
 *        -----| - |Difference|    |  1 - Z^(-1)  |          |   |          |       |  |
 *       |      ---  (error)  |     --------------           | + |           -------   |
 *       |                    |                               ---                      |
 *       | Measured           |   -------------------  Deriv   |                       |
 *       | Outut              |  |                   | Output  |                       |
 *       |                     --| Kd * (1 - Z^(-1)) |---------                        |
 *       |                       |                   |                                 |
 *       |                        -------------------                                  |
 *       |                                                                             |
 *       |                                                                             |
 *        -----------------------------------------------------------------------------
 *
 *
 *	Scaling factors/transformations need to be implemented to adapt sensor input and output
 *	commands from ADC and QEI speed estimation to fixed-point Q15 that the dsp engine can
 *	work with.
 */
tPID iqPID;
tPID idPID;
tPID omegaPID;

/*
 * Note! on the dsPIC33EPxxxMU810 ymemory starts at 0x9000 which is in EDS.
 * (Expanded Data Space)
 */
fractional iqabcCoefficient[3] __attribute__((space(xmemory)));
fractional idabcCoefficient[3] __attribute__((space(xmemory)));
fractional omegaabcCoefficient[3] __attribute__((space(xmemory)));

fractional iqControlHistory[3] __attribute__((eds, space(ymemory)));
fractional idControlHistory[3] __attribute__((eds, space(ymemory)));
fractional omegaControlHistory[3] __attribute__((eds, space(ymemory)));

float *trig360;

void DSPInit(void)
{
	iqPID.abcCoefficients = iqabcCoefficient;
	idPID.abcCoefficients = idabcCoefficient;
	omegaPID.abcCoefficients = omegaabcCoefficient;

	iqPID.controlHistory = iqControlHistory;
	idPID.controlHistory = idControlHistory;
	omegaPID.controlHistory = omegaControlHistory;

	PIDInit(&iqPID);
	PIDInit(&idPID);
	PIDInit(&omegaPID);

	DSPTuningsInit();
}

void DSPTuningsInit(void)
{
	fractional PID_Iq[3];
	fractional PID_Id[3];
	fractional PID_Omega[3];

	//TODO: Give a better interface to tuning parameters
	PID_Iq[0] = Q15(.5); //P = .5
	PID_Iq[1] = Q15(.2); //I = .2
	PID_Iq[2] = Q15(0); //D = 0

	PID_Id[0] = Q15(.5); //P = .5
	PID_Id[1] = Q15(.2); //I = .2
	PID_Id[2] = Q15(0); //D = 0

	PID_Omega[0] = Q15(.5); //P = .5
	PID_Omega[1] = Q15(.2); //I = .2
	PID_Omega[2] = Q15(0); //D = 0

	PIDCoeffCalc(PID_Iq, &iqPID);
	PIDCoeffCalc(PID_Id, &idPID);
	PIDCoeffCalc(PID_Omega, &omegaPID);
}

//This should be implemented as a function which allows changes in control
//policies on the fly.

void DSPChangeTunings(void)
{

}

void FOC_Step(void)
{
	/*
	 * if(first step) :
	 *
	 * Do initialization...
	 *
	 * Make a switch statement here which switches control policies...?
	 */


	//Read sensor values





	//Clarke transform
	//Position and speed estimation
	//Park Transform



	/***********************************************************************/
	omegaPID.controlReference = 0; //control reference is speed commanded
	omegaPID.measuredOutput = 0; //measured output is speed input from speed estimator

	PID(&omegaPID);

	/***********************************************************************/
	//control reference is the control output of the omega PI controller
	iqPID.controlReference = omegaPID.controlOutput;
	iqPID.measuredOutput = 0; //measured output is the iq output of the park transform

	PID(&iqPID); //control output is Vq which will go into the inverse park transform.

	/***********************************************************************/
	iqPID.controlReference = 0; //Call function which checks weakening table.
	iqPID.measuredOutput = 0; //measured output is the id output of the park transform

	PID(&iqPID); //control output is Vq which will go into the inverse park transform.

	/***********************************************************************/

	//Call inverse park transform

	//SVM

	//UPDATE PWMs
}

void ClarkeTransform(float ia, float ib, float* ialpha, float* iBeta)
{
	ialpha = ia;
	iBeta = (1 / SQRT_3)ia + (2 / SQRT_3)ib;
}

void ParkTransform(float ialpha, float iBeta, float theta, float* iq, float* id)
{
	//Update this with a lookup table implementation or cordic!  Wow!
	id = ialpha * cosine(theta) + iBeta * sine(theta);
	iq = (-1) * ialpha * sine(theta) + iBeta * cosine(theta);
}

void InvParkTransform(float ialpha, float iBeta, float theta, float* iq, float* id)
{
	//Update this with a lookup table implementation or cordic!  Wow!
	id = ialpha * cosine(theta) - iBeta * sine(theta);
	iq = ialpha * sine(theta) + iBeta * cosine(theta);
}

uint8_t placeholder = 1;

void Position_Speed_Estimation(void)
{
	if (placeholder) {
		//If we want to do sliding mode controller (SMC) compensated
		//descritized motor model based speed and postion estimation
		//do it here.
	} else {
		//if we want to use the encoder we drop into here and handle
		//speed and position estimation here.  (Default for now).

		//Check QEI peripheral here to determine current angle and
		//compare timers to determine omega.
	}
}

/**
 * @brief Allocates memory for sine lookup table and fills it.
 * @todo Make this a 60 degree table and change cosine and sine functions
 *	 to handle building sine/cosine from it.
 */
void Trig_Init(void)
{
	uint8_t i;
	trig360 = calloc(2048, sizeof(float));
	for (i = 0; i < 2048; i++) {
		trig360[i] = sin((i * 0.17578125) * (PI / 180));
	}
}

/**
 * @brief Returns cosine of angle from a lookup table.
 *	  Angle is (theta in degrees)/0.17578125.
 * @param angle Value from 0 to 2048 representing 0 and 360 degrees.
 * @return The floating point value of cosine.
 */
float cosine(float angle)
{
	if(angle >= 0 && angle < 1536 ) {
		return(trig360[angle + 512]);
	} else {
		return(trig360[angle - 1536]);
	}
}

/**
 * @brief Returns sine of angle from a lookup table.
 *	  Angle is (theta in degrees)/0.17578125.
 * @param angle Value from 0 to 2048 representing 0 and 360 degrees.
 * @return The floating point value of sine.
 */
float sine(float angle)
{
	return(trig360[angle]);
}