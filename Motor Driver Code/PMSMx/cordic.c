
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

#include "cordic.h"

/******************************************************************************/

float angle_shift(float alpha, float beta)

/******************************************************************************/
/*
  Purpose:

    ANGLE_SHIFT shifts angle ALPHA to lie between BETA and BETA+2PI.

  Discussion:

    The input angle ALPHA is shifted by multiples of 2 * PI to lie
    between BETA and BETA+2*PI.

    The resulting angle GAMMA has all the same trigonometric function
    values as ALPHA.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 January 2012

  Author:

    John Burkardt

  Parameters:

    Input, float ALPHA, the angle to be shifted.

    Input, float BETA, defines the lower endpoint of
    the angle range.

    Output, float ANGLE_SHIFT, the shifted angle.
 */
{
	float gamma;
	float pi = 3.141592653589793;

	if (alpha < beta) {
		gamma = beta - fmod(beta - alpha, 2.0 * pi) + 2.0 * pi;
	} else {
		gamma = beta + fmod(alpha - beta, 2.0 * pi);
	}

	return gamma;
}

/******************************************************************************/

float arccos_cordic(float t, int n)

/******************************************************************************/
/*
  Purpose:

    ARCCOS_CORDIC returns the arccosine of an angle using the CORDIC method.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 January 2012

  Author:

    John Burkardt

  Reference:

    Jean-Michel Muller,
    Elementary Functions: Algorithms and Implementation,
    Second Edition,
    Birkhaeuser, 2006,
    ISBN13: 978-0-8176-4372-0,
    LC: QA331.M866.

  Parameters:

    Input, float T, the cosine of an angle.  -1 <= T <= 1.

    Input, int N, the number of iterations to take.
    A value of 10 is low.  Good accuracy is achieved with 20 or more
    iterations.

    Output, float ARCCOS_CORDIC, an angle whose cosine is T.

  Local Parameters:

    Local, float ANGLES(60) = arctan ( (1/2)^(0:59) );
 */
{
#define ANGLES_LENGTH 60

	float angle;
	float angles[ANGLES_LENGTH] = {
		7.8539816339744830962E-01,
		4.6364760900080611621E-01,
		2.4497866312686415417E-01,
		1.2435499454676143503E-01,
		6.2418809995957348474E-02,
		3.1239833430268276254E-02,
		1.5623728620476830803E-02,
		7.8123410601011112965E-03,
		3.9062301319669718276E-03,
		1.9531225164788186851E-03,
		9.7656218955931943040E-04,
		4.8828121119489827547E-04,
		2.4414062014936176402E-04,
		1.2207031189367020424E-04,
		6.1035156174208775022E-05,
		3.0517578115526096862E-05,
		1.5258789061315762107E-05,
		7.6293945311019702634E-06,
		3.8146972656064962829E-06,
		1.9073486328101870354E-06,
		9.5367431640596087942E-07,
		4.7683715820308885993E-07,
		2.3841857910155798249E-07,
		1.1920928955078068531E-07,
		5.9604644775390554414E-08,
		2.9802322387695303677E-08,
		1.4901161193847655147E-08,
		7.4505805969238279871E-09,
		3.7252902984619140453E-09,
		1.8626451492309570291E-09,
		9.3132257461547851536E-10,
		4.6566128730773925778E-10,
		2.3283064365386962890E-10,
		1.1641532182693481445E-10,
		5.8207660913467407226E-11,
		2.9103830456733703613E-11,
		1.4551915228366851807E-11,
		7.2759576141834259033E-12,
		3.6379788070917129517E-12,
		1.8189894035458564758E-12,
		9.0949470177292823792E-13,
		4.5474735088646411896E-13,
		2.2737367544323205948E-13,
		1.1368683772161602974E-13,
		5.6843418860808014870E-14,
		2.8421709430404007435E-14,
		1.4210854715202003717E-14,
		7.1054273576010018587E-15,
		3.5527136788005009294E-15,
		1.7763568394002504647E-15,
		8.8817841970012523234E-16,
		4.4408920985006261617E-16,
		2.2204460492503130808E-16,
		1.1102230246251565404E-16,
		5.5511151231257827021E-17,
		2.7755575615628913511E-17,
		1.3877787807814456755E-17,
		6.9388939039072283776E-18,
		3.4694469519536141888E-18,
		1.7347234759768070944E-18
	};
	int i;
	int j;
	float poweroftwo;
	float sigma;
	float sign_z2;
	float theta;
	float x1;
	float x2;
	float y1;
	float y2;

	if (1.0 < fabs(t)) {
		fprintf(stderr, "\n");
		fprintf(stderr, "ARCCOS_CORDIC - Fatal error!\n");
		fprintf(stderr, "  1.0 < |T|.\n");
		exit(1);
	}

	theta = 0.0;
	x1 = 1.0;
	y1 = 0.0;
	poweroftwo = 1.0;

	for (j = 1; j <= n; j++) {
		if (y1 < 0.0) {
			sign_z2 = -1.0;
		} else {
			sign_z2 = +1.0;
		}

		if (t <= x1) {
			sigma = +sign_z2;
		} else {
			sigma = -sign_z2;
		}

		if (j <= ANGLES_LENGTH) {
			angle = angles[j - 1];
		} else {
			angle = angle / 2.0;
		}

		for (i = 1; i <= 2; i++) {
			x2 = x1 - sigma * poweroftwo * y1;
			y2 = sigma * poweroftwo * x1 + y1;

			x1 = x2;
			y1 = y2;
		}

		theta = theta + 2.0 * sigma * angle;

		t = t + t * poweroftwo * poweroftwo;

		poweroftwo = poweroftwo / 2.0;
	}

	return theta;
#undef ANGLES_LENGTH
}

/******************************************************************************/

void arccos_values(int *n_data, float *x, float *fx)

/******************************************************************************/
/*
  Purpose:

    ARCCOS_VALUES returns some values of the arc cosine function.

  Discussion:

    In Mathematica, the function can be evaluated by:

      ArcCos[x]

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    12 June 2007

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output, float *FX, the value of the function.
 */
{
#define N_MAX 12

	static float fx_vec[N_MAX] = {
		1.6709637479564564156,
		1.5707963267948966192,
		1.4706289056333368229,
		1.3694384060045658278,
		1.2661036727794991113,
		1.1592794807274085998,
		1.0471975511965977462,
		0.92729521800161223243,
		0.79539883018414355549,
		0.64350110879328438680,
		0.45102681179626243254,
		0.00000000000000000000
	};

	static float x_vec[N_MAX] = {
		-0.1,
		0.0,
		0.1,
		0.2,
		0.3,
		0.4,
		0.5,
		0.6,
		0.7,
		0.8,
		0.9,
		1.0
	};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*fx = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*fx = fx_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

float arcsin_cordic(float t, int n)

/******************************************************************************/
/*
  Purpose:

    ARCSIN_CORDIC returns the arcsine of an angle using the CORDIC method.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 January 2012

  Author:

    John Burkardt

  Reference:

    Jean-Michel Muller,
    Elementary Functions: Algorithms and Implementation,
    Second Edition,
    Birkhaeuser, 2006,
    ISBN13: 978-0-8176-4372-0,
    LC: QA331.M866.

  Parameters:

    Input, float T, the sine of an angle.  -1 <= T <= 1.

    Input, int N, the number of iterations to take.
    A value of 10 is low.  Good accuracy is achieved with 20 or more
    iterations.

    Output, float ARCSIN_CORDIC, an angle whose sine is T.

  Local Parameters:

    Local, float ANGLES(60) = arctan ( (1/2)^(0:59) );
 */
{
#define ANGLES_LENGTH 60

	float angle;
	float angles[ANGLES_LENGTH] = {
		7.8539816339744830962E-01,
		4.6364760900080611621E-01,
		2.4497866312686415417E-01,
		1.2435499454676143503E-01,
		6.2418809995957348474E-02,
		3.1239833430268276254E-02,
		1.5623728620476830803E-02,
		7.8123410601011112965E-03,
		3.9062301319669718276E-03,
		1.9531225164788186851E-03,
		9.7656218955931943040E-04,
		4.8828121119489827547E-04,
		2.4414062014936176402E-04,
		1.2207031189367020424E-04,
		6.1035156174208775022E-05,
		3.0517578115526096862E-05,
		1.5258789061315762107E-05,
		7.6293945311019702634E-06,
		3.8146972656064962829E-06,
		1.9073486328101870354E-06,
		9.5367431640596087942E-07,
		4.7683715820308885993E-07,
		2.3841857910155798249E-07,
		1.1920928955078068531E-07,
		5.9604644775390554414E-08,
		2.9802322387695303677E-08,
		1.4901161193847655147E-08,
		7.4505805969238279871E-09,
		3.7252902984619140453E-09,
		1.8626451492309570291E-09,
		9.3132257461547851536E-10,
		4.6566128730773925778E-10,
		2.3283064365386962890E-10,
		1.1641532182693481445E-10,
		5.8207660913467407226E-11,
		2.9103830456733703613E-11,
		1.4551915228366851807E-11,
		7.2759576141834259033E-12,
		3.6379788070917129517E-12,
		1.8189894035458564758E-12,
		9.0949470177292823792E-13,
		4.5474735088646411896E-13,
		2.2737367544323205948E-13,
		1.1368683772161602974E-13,
		5.6843418860808014870E-14,
		2.8421709430404007435E-14,
		1.4210854715202003717E-14,
		7.1054273576010018587E-15,
		3.5527136788005009294E-15,
		1.7763568394002504647E-15,
		8.8817841970012523234E-16,
		4.4408920985006261617E-16,
		2.2204460492503130808E-16,
		1.1102230246251565404E-16,
		5.5511151231257827021E-17,
		2.7755575615628913511E-17,
		1.3877787807814456755E-17,
		6.9388939039072283776E-18,
		3.4694469519536141888E-18,
		1.7347234759768070944E-18
	};
	int i;
	int j;
	float poweroftwo;
	float sigma;
	float sign_z1;
	float theta;
	float x1;
	float x2;
	float y1;
	float y2;

	if (1.0 < fabs(t)) {
		fprintf(stderr, "\n");
		fprintf(stderr, "ARCSIN_CORDIC - Fatal error!\n");
		fprintf(stderr, "  1.0 < |T|.\n");
		exit(1);
	}

	theta = 0.0;
	x1 = 1.0;
	y1 = 0.0;
	poweroftwo = 1.0;

	for (j = 1; j <= n; j++) {
		if (x1 < 0.0) {
			sign_z1 = -1.0;
		} else {
			sign_z1 = +1.0;
		}

		if (y1 <= t) {
			sigma = +sign_z1;
		} else {
			sigma = -sign_z1;
		}

		if (j <= ANGLES_LENGTH) {
			angle = angles[j - 1];
		} else {
			angle = angle / 2.0;
		}

		for (i = 1; i <= 2; i++) {
			x2 = x1 - sigma * poweroftwo * y1;
			y2 = sigma * poweroftwo * x1 + y1;

			x1 = x2;
			y1 = y2;
		}

		theta = theta + 2.0 * sigma * angle;

		t = t + t * poweroftwo * poweroftwo;

		poweroftwo = poweroftwo / 2.0;
	}

	return theta;
#undef ANGLES_LENGTH
}

/******************************************************************************/

void arcsin_values(int *n_data, float *x, float *fx)

/******************************************************************************/
/*
  Purpose:

    ARCSIN_VALUES returns some values of the arc sine function.

  Discussion:

    In Mathematica, the function can be evaluated by:

      ArcSin[x]

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    12 June 2007

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output, float *FX, the value of the function.
 */
{
#define N_MAX 12

	static float fx_vec[N_MAX] = {
		-0.10016742116155979635,
		0.00000000000000000000,
		0.10016742116155979635,
		0.20135792079033079146,
		0.30469265401539750797,
		0.41151684606748801938,
		0.52359877559829887308,
		0.64350110879328438680,
		0.77539749661075306374,
		0.92729521800161223243,
		1.1197695149986341867,
		1.5707963267948966192
	};

	static float x_vec[N_MAX] = {
		-0.1,
		0.0,
		0.1,
		0.2,
		0.3,
		0.4,
		0.5,
		0.6,
		0.7,
		0.8,
		0.9,
		1.0
	};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*fx = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*fx = fx_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

float arctan_cordic(float x, float y, int n)

/******************************************************************************/
/*
  Purpose:

    ARCTAN_CORDIC returns the arctangent of an angle using the CORDIC method.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    15 June 2007

  Author:

    John Burkardt

  Reference:

    Jean-Michel Muller,
    Elementary Functions: Algorithms and Implementation,
    Second Edition,
    Birkhaeuser, 2006,
    ISBN13: 978-0-8176-4372-0,
    LC: QA331.M866.

  Parameters:

    Input, float X, Y, define the tangent of an angle as Y/X.

    Input, int N, the number of iterations to take.
    A value of 10 is low.  Good accuracy is achieved with 20 or more
    iterations.

    Output, float ARCTAN_CORDIC, the angle whose tangent is Y/X.

  Local Parameters:

    Local, float ANGLES(60) = arctan ( (1/2)^(0:59) );
 */
{
#define ANGLES_LENGTH 60

	float angle;
	float angles[ANGLES_LENGTH] = {
		7.8539816339744830962E-01,
		4.6364760900080611621E-01,
		2.4497866312686415417E-01,
		1.2435499454676143503E-01,
		6.2418809995957348474E-02,
		3.1239833430268276254E-02,
		1.5623728620476830803E-02,
		7.8123410601011112965E-03,
		3.9062301319669718276E-03,
		1.9531225164788186851E-03,
		9.7656218955931943040E-04,
		4.8828121119489827547E-04,
		2.4414062014936176402E-04,
		1.2207031189367020424E-04,
		6.1035156174208775022E-05,
		3.0517578115526096862E-05,
		1.5258789061315762107E-05,
		7.6293945311019702634E-06,
		3.8146972656064962829E-06,
		1.9073486328101870354E-06,
		9.5367431640596087942E-07,
		4.7683715820308885993E-07,
		2.3841857910155798249E-07,
		1.1920928955078068531E-07,
		5.9604644775390554414E-08,
		2.9802322387695303677E-08,
		1.4901161193847655147E-08,
		7.4505805969238279871E-09,
		3.7252902984619140453E-09,
		1.8626451492309570291E-09,
		9.3132257461547851536E-10,
		4.6566128730773925778E-10,
		2.3283064365386962890E-10,
		1.1641532182693481445E-10,
		5.8207660913467407226E-11,
		2.9103830456733703613E-11,
		1.4551915228366851807E-11,
		7.2759576141834259033E-12,
		3.6379788070917129517E-12,
		1.8189894035458564758E-12,
		9.0949470177292823792E-13,
		4.5474735088646411896E-13,
		2.2737367544323205948E-13,
		1.1368683772161602974E-13,
		5.6843418860808014870E-14,
		2.8421709430404007435E-14,
		1.4210854715202003717E-14,
		7.1054273576010018587E-15,
		3.5527136788005009294E-15,
		1.7763568394002504647E-15,
		8.8817841970012523234E-16,
		4.4408920985006261617E-16,
		2.2204460492503130808E-16,
		1.1102230246251565404E-16,
		5.5511151231257827021E-17,
		2.7755575615628913511E-17,
		1.3877787807814456755E-17,
		6.9388939039072283776E-18,
		3.4694469519536141888E-18,
		1.7347234759768070944E-18
	};
	int j;
	float poweroftwo;
	float sigma;
	float sign_factor;
	float theta;
	float x1;
	float x2;
	float y1;
	float y2;

	x1 = x;
	y1 = y;
	/*
	  Account for signs.
	 */
	if (x1 < 0.0 && y1 < 0.0) {
		x1 = -x1;
		y1 = -y1;
	}

	if (x1 < 0.0) {
		x1 = -x1;
		sign_factor = -1.0;
	} else if (y1 < 0.0) {
		y1 = -y1;
		sign_factor = -1.0;
	} else {
		sign_factor = +1.0;
	}

	theta = 0.0;
	poweroftwo = 1.0;

	for (j = 1; j <= n; j++) {
		if (y1 <= 0.0) {
			sigma = +1.0;
		} else {
			sigma = -1.0;
		}

		if (j <= ANGLES_LENGTH) {
			angle = angles[j - 1];
		} else {
			angle = angle / 2.0;
		}

		x2 = x1 - sigma * poweroftwo * y1;
		y2 = sigma * poweroftwo * x1 + y1;
		theta = theta - sigma * angle;

		x1 = x2;
		y1 = y2;

		poweroftwo = poweroftwo / 2.0;
	}

	theta = sign_factor * theta;

	return theta;
#undef ANGLES_LENGTH
}

/******************************************************************************/

void arctan_values(int *n_data, float *x, float *f)

/******************************************************************************/
/*
  Purpose:

    ARCTAN_VALUES returns some values of the arc tangent function.

  Discussion:

    In Mathematica, the function can be evaluated by:

      ArcTan[x]

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    12 June 2007

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output, float *F, the value of the function.
 */
{
#define N_MAX 11

	static float f_vec[N_MAX] = {
		0.00000000000000000000,
		0.24497866312686415417,
		0.32175055439664219340,
		0.46364760900080611621,
		0.78539816339744830962,
		1.1071487177940905030,
		1.2490457723982544258,
		1.3258176636680324651,
		1.3734007669450158609,
		1.4711276743037345919,
		1.5208379310729538578
	};

	static float x_vec[N_MAX] = {
		0.00000000000000000000,
		0.25000000000000000000,
		0.33333333333333333333,
		0.50000000000000000000,
		1.0000000000000000000,
		2.0000000000000000000,
		3.0000000000000000000,
		4.0000000000000000000,
		5.0000000000000000000,
		10.000000000000000000,
		20.000000000000000000
	};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*f = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*f = f_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

float cbrt_cordic(float x, int n)

/******************************************************************************/
/*
  Purpose:

    CBRT_CORDIC returns the cube root of a value using the CORDIC method.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 January 2012

  Author:

    John Burkardt

  Parameters:

    Input, float X, the number whose cube root is desired.

    Input, int N, the number of iterations to take.
    This is essentially the number of binary digits of accuracy, and
    might go as high as 53.

    Output, float CBRT_CORDIC, the approximate cube root of X.
 */
{
	int i;
	float poweroftwo;
	float x_mag;
	float y;

	x_mag = fabs(x);

	if (x_mag == 0.0) {
		y = 0.0;
		return y;
	}

	if (x_mag == 1.0) {
		y = x;
		return y;
	}

	poweroftwo = 1.0;

	if (x_mag < 1.0) {
		while (x_mag <= poweroftwo * poweroftwo * poweroftwo) {
			poweroftwo = poweroftwo / 2.0;
		}
		y = poweroftwo;
	} else if (1.0 < x_mag) {
		while (poweroftwo * poweroftwo * poweroftwo <= x_mag) {
			poweroftwo = 2.0 * poweroftwo;
		}
		y = poweroftwo / 2.0;
	}

	for (i = 1; i <= n; i++) {
		poweroftwo = poweroftwo / 2.0;
		if ((y + poweroftwo) * (y + poweroftwo)* (y + poweroftwo) <= x_mag) {
			y = y + poweroftwo;
		}
	}

	if (x < 0.0) {
		y = -y;
	}

	return y;
}

/******************************************************************************/

void cbrt_values(int *n_data, float *x, float *fx)

/******************************************************************************/
/*
  Purpose:

    CBRT_VALUES returns some values of the cube root function.

  Discussion:

    CBRT(X) = real number Y such that Y * Y * Y = X.

    In Mathematica, the function can be evaluated by:

      Sign[x] * ( Abs[x] )^(1/3)

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    22 June 2007

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output float FX, the value of the function.
 */
{
#define N_MAX 14

	static float fx_vec[N_MAX] = {
		0.0000000000000000E+00,
		-0.0020082988563383484484E+00,
		0.44814047465571647087E+00,
		-0.46415888336127788924E+00,
		0.73680629972807732116E+00,
		-1.0000000000000000000E+00,
		1.2599210498948731648E+00,
		-1.4422495703074083823E+00,
		1.4645918875615232630E+00,
		-2.6684016487219448673E+00,
		3.0723168256858472933E+00,
		-4.1408177494228532500E+00,
		4.5947008922070398061E+00,
		-497.93385921817447440E+00
	};

	static float x_vec[N_MAX] = {
		0.0000000000000000E+00,
		-0.8100000073710001E-08,
		0.9000000000000000E-01,
		-0.1000000000000000E+00,
		0.4000000000000000E+00,
		-0.1000000000000000E+01,
		0.2000000000000000E+01,
		-0.3000000000000000E+01,
		0.3141592653589793E+01,
		-0.1900000000000000E+02,
		0.2900000000000000E+02,
		-0.7100000000000000E+02,
		0.9700000000000000E+02,
		-0.1234567890000000E+09
	};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*fx = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*fx = fx_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

void cos_values(int *n_data, float *x, float *fx)

/******************************************************************************/
/*
  Purpose:

    COS_VALUES returns some values of the cosine function.

  Discussion:

    In Mathematica, the function can be evaluated by:

      Cos[x]

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    12 June 2007

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output, float *FX, the value of the function.
 */
{
#define N_MAX 13

	static float fx_vec[N_MAX] = {
		1.0000000000000000000,
		0.96592582628906828675,
		0.87758256189037271612,
		0.86602540378443864676,
		0.70710678118654752440,
		0.54030230586813971740,
		0.50000000000000000000,
		0.00000000000000000000,
		-0.41614683654714238700,
		-0.98999249660044545727,
		-1.0000000000000000000,
		-0.65364362086361191464,
		0.28366218546322626447
	};

	static float x_vec[N_MAX] = {
		0.0000000000000000000,
		0.26179938779914943654,
		0.50000000000000000000,
		0.52359877559829887308,
		0.78539816339744830962,
		1.0000000000000000000,
		1.0471975511965977462,
		1.5707963267948966192,
		2.0000000000000000000,
		3.0000000000000000000,
		3.1415926535897932385,
		4.0000000000000000000,
		5.0000000000000000000
	};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*fx = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*fx = fx_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

void cossin_cordic(float beta, int n, float *c, float *s)

/******************************************************************************/
/*
  Purpose:

    COSSIN_CORDIC returns the sine and cosine of an angle by the CORDIC method.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 January 2012

  Author:

    Based on MATLAB code in a Wikipedia article.
    C++ version by John Burkardt

  Parameters:

    Input, float BETA, the angle (in radians).

    Input, int N, the number of iterations to take.
    A value of 10 is low.  Good accuracy is achieved with 20 or more
    iterations.

    Output, float *C, *S, the cosine and sine of the angle.

  Local Parameters:

    Local, float ANGLES(60) = arctan ( (1/2)^(0:59) );

    Local, float KPROD(33).  KPROD(j) = product ( 0 <= i <= j ) K(i)
    where K(i) = 1 / sqrt ( 1 + (1/2)^(2i) ).
 */
{
#define ANGLES_LENGTH 60
#define KPROD_LENGTH 33

	float angle;
	float angles[ANGLES_LENGTH] = {
		7.8539816339744830962E-01,
		4.6364760900080611621E-01,
		2.4497866312686415417E-01,
		1.2435499454676143503E-01,
		6.2418809995957348474E-02,
		3.1239833430268276254E-02,
		1.5623728620476830803E-02,
		7.8123410601011112965E-03,
		3.9062301319669718276E-03,
		1.9531225164788186851E-03,
		9.7656218955931943040E-04,
		4.8828121119489827547E-04,
		2.4414062014936176402E-04,
		1.2207031189367020424E-04,
		6.1035156174208775022E-05,
		3.0517578115526096862E-05,
		1.5258789061315762107E-05,
		7.6293945311019702634E-06,
		3.8146972656064962829E-06,
		1.9073486328101870354E-06,
		9.5367431640596087942E-07,
		4.7683715820308885993E-07,
		2.3841857910155798249E-07,
		1.1920928955078068531E-07,
		5.9604644775390554414E-08,
		2.9802322387695303677E-08,
		1.4901161193847655147E-08,
		7.4505805969238279871E-09,
		3.7252902984619140453E-09,
		1.8626451492309570291E-09,
		9.3132257461547851536E-10,
		4.6566128730773925778E-10,
		2.3283064365386962890E-10,
		1.1641532182693481445E-10,
		5.8207660913467407226E-11,
		2.9103830456733703613E-11,
		1.4551915228366851807E-11,
		7.2759576141834259033E-12,
		3.6379788070917129517E-12,
		1.8189894035458564758E-12,
		9.0949470177292823792E-13,
		4.5474735088646411896E-13,
		2.2737367544323205948E-13,
		1.1368683772161602974E-13,
		5.6843418860808014870E-14,
		2.8421709430404007435E-14,
		1.4210854715202003717E-14,
		7.1054273576010018587E-15,
		3.5527136788005009294E-15,
		1.7763568394002504647E-15,
		8.8817841970012523234E-16,
		4.4408920985006261617E-16,
		2.2204460492503130808E-16,
		1.1102230246251565404E-16,
		5.5511151231257827021E-17,
		2.7755575615628913511E-17,
		1.3877787807814456755E-17,
		6.9388939039072283776E-18,
		3.4694469519536141888E-18,
		1.7347234759768070944E-18
	};
	float c2;
	float factor;
	int j;
	float kprod[KPROD_LENGTH] = {
		0.70710678118654752440,
		0.63245553203367586640,
		0.61357199107789634961,
		0.60883391251775242102,
		0.60764825625616820093,
		0.60735177014129595905,
		0.60727764409352599905,
		0.60725911229889273006,
		0.60725447933256232972,
		0.60725332108987516334,
		0.60725303152913433540,
		0.60725295913894481363,
		0.60725294104139716351,
		0.60725293651701023413,
		0.60725293538591350073,
		0.60725293510313931731,
		0.60725293503244577146,
		0.60725293501477238499,
		0.60725293501035403837,
		0.60725293500924945172,
		0.60725293500897330506,
		0.60725293500890426839,
		0.60725293500888700922,
		0.60725293500888269443,
		0.60725293500888161574,
		0.60725293500888134606,
		0.60725293500888127864,
		0.60725293500888126179,
		0.60725293500888125757,
		0.60725293500888125652,
		0.60725293500888125626,
		0.60725293500888125619,
		0.60725293500888125617
	};
	float pi = 3.141592653589793;
	float poweroftwo;
	float s2;
	float sigma;
	float sign_factor;
	float theta;
	/*
	  Shift angle to interval [-pi,pi].
	 */
	theta = angle_shift(beta, -pi);
	/*
	  Shift angle to interval [-pi/2,pi/2] and account for signs.
	 */
	if (theta < -0.5 * pi) {
		theta = theta + pi;
		sign_factor = -1.0;
	} else if (0.5 * pi < theta) {
		theta = theta - pi;
		sign_factor = -1.0;
	} else {
		sign_factor = +1.0;
	}
	/*
	  Initialize loop variables:
	 */
	*c = 1.0;
	*s = 0.0;

	poweroftwo = 1.0;
	angle = angles[0];
	/*
	  Iterations
	 */
	for (j = 1; j <= n; j++) {
		if (theta < 0.0) {
			sigma = -1.0;
		} else {
			sigma = 1.0;
		}

		factor = sigma * poweroftwo;

		c2 = *c - factor * *s;
		s2 = factor * *c + *s;

		*c = c2;
		*s = s2;
		/*
		  Update the remaining angle.
		 */
		theta = theta - sigma * angle;

		poweroftwo = poweroftwo / 2.0;
		/*
		  Update the angle from table, or eventually by just dividing by two.
		 */
		if (ANGLES_LENGTH < j + 1) {
			angle = angle / 2.0;
		} else {
			angle = angles[j];
		}
	}
	/*
	  Adjust length of output vector to be [cos(beta), sin(beta)]

	  KPROD is essentially constant after a certain point, so if N is
	  large, just take the last available value.
	 */
	if (0 < n) {
		*c = *c * kprod [ i4_min(n, KPROD_LENGTH) - 1 ];
		*s = *s * kprod [ i4_min(n, KPROD_LENGTH) - 1 ];
	}
	/*
	  Adjust for possible sign change because angle was originally
	  not in quadrant 1 or 4.
	 */
	*c = sign_factor * *c;
	*s = sign_factor * *s;

	return;
#undef ANGLES_LENGTH
#undef KPROD_LENGTH
}

/******************************************************************************/

float exp_cordic(float x, int n)

/******************************************************************************/
/*
  Purpose:

    EXP_CORDIC evaluates the exponential function using the CORDIC method.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 January 2012

  Author:

    John Burkardt

  Reference:

    Frederick Ruckdeschel,
    BASIC Scientific Subroutines,
    Volume II,
    McGraw-Hill, 1980,
    ISBN: 0-07-054202-3,
    LC: QA76.95.R82.

  Parameters:

    Input, float X, the argument.

    Input, int N, the number of steps to take.

    Output, float FX, the exponential of X.

  Local Parameters:

    Local, float A(1:25) = exp ( (1/2)^(1:25) );
 */
{
#define A_LENGTH 25

	float a[A_LENGTH] = {
		1.648721270700128,
		1.284025416687742,
		1.133148453066826,
		1.064494458917859,
		1.031743407499103,
		1.015747708586686,
		1.007843097206488,
		1.003913889338348,
		1.001955033591003,
		1.000977039492417,
		1.000488400478694,
		1.000244170429748,
		1.000122077763384,
		1.000061037018933,
		1.000030518043791,
		1.0000152589054785,
		1.0000076294236351,
		1.0000038147045416,
		1.0000019073504518,
		1.0000009536747712,
		1.0000004768372719,
		1.0000002384186075,
		1.0000001192092967,
		1.0000000596046466,
		1.0000000298023228
	};
	float ai;
	float e = 2.718281828459045;
	float fx;
	int i;
	float poweroftwo;
	float *w;
	int x_int;
	float z;

	x_int = (int) (floor(x));
	/*
	  Determine the weights.
	 */
	poweroftwo = 0.5;
	z = x - (float) (x_int);

	w = (float *) malloc(n * sizeof( float));

	for (i = 0; i < n; i++) {
		w[i] = 0.0;
		if (poweroftwo < z) {
			w[i] = 1.0;
			;
			z = z - poweroftwo;
		}
		poweroftwo = poweroftwo / 2.0;
	}
	/*
	  Calculate products.
	 */
	fx = 1.0;

	for (i = 0; i < n; i++) {
		if (i < A_LENGTH) {
			ai = a[i];
		} else {
			ai = 1.0 + (ai - 1.0) / 2.0;
		}

		if (0.0 < w[i]) {
			fx = fx * ai;
		}
	}
	/*
	  Perform residual multiplication.
	 */
	fx = fx
		* (1.0 + z
		* (1.0 + z / 2.0
		* (1.0 + z / 3.0
		* (1.0 + z / 4.0))));
	/*
	  Account for factor EXP(X_INT).
	 */
	if (x_int < 0) {
		for (i = 1; i <= -x_int; i++) {
			fx = fx / e;
		}
	} else {
		for (i = 1; i <= x_int; i++) {
			fx = fx * e;
		}
	}

	free(w);

	return fx;
#undef A_LENGTH
}

/******************************************************************************/

void exp_values(int *n_data, float *x, float *fx)

/******************************************************************************/
/*
  Purpose:

    EXP_VALUES returns some values of the exponential function.

  Discussion:

    In Mathematica, the function can be evaluated by:

      Exp[x]

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    11 March 2008

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output, float *FX, the value of the function.
 */
{
#define N_MAX 24

	static float fx_vec[N_MAX] = {
		0.000045399929762484851536E+00,
		0.0067379469990854670966E+00,
		0.36787944117144232160E+00,
		1.0000000000000000000E+00,
		1.0000000100000000500E+00,
		1.0001000050001666708E+00,
		1.0010005001667083417E+00,
		1.0100501670841680575E+00,
		1.1051709180756476248E+00,
		1.2214027581601698339E+00,
		1.3498588075760031040E+00,
		1.4918246976412703178E+00,
		1.6487212707001281468E+00,
		1.8221188003905089749E+00,
		2.0137527074704765216E+00,
		2.2255409284924676046E+00,
		2.4596031111569496638E+00,
		2.7182818284590452354E+00,
		7.3890560989306502272E+00,
		23.140692632779269006E+00,
		148.41315910257660342E+00,
		22026.465794806716517E+00,
		4.8516519540979027797E+08,
		2.3538526683701998541E+17
	};

	static float x_vec[N_MAX] = {
		-10.0E+00,
		-5.0E+00,
		-1.0E+00,
		0.0E+00,
		0.00000001E+00,
		0.0001E+00,
		0.001E+00,
		0.01E+00,
		0.1E+00,
		0.2E+00,
		0.3E+00,
		0.4E+00,
		0.5E+00,
		0.6E+00,
		0.7E+00,
		0.8E+00,
		0.9E+00,
		1.0E+00,
		2.0E+00,
		3.1415926535897932385E+00,
		5.0E+00,
		10.0E+00,
		20.0E+00,
		40.0E+00};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*fx = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*fx = fx_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

int i4_huge(void)

/******************************************************************************/
/*
  Purpose:

    I4_HUGE returns a "huge" I4.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    16 May 2003

  Author:

    John Burkardt

  Parameters:

    Output, int I4_HUGE, a "huge" I4.
 */
{
	return 0;
}

/******************************************************************************/

int i4_min(int i1, int i2)

/******************************************************************************/
/*
  Purpose:

    I4_MIN returns the minimum of two I4's.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    13 October 1998

  Author:

    John Burkardt

  Parameters:

    Input, int I1, I2, two integers to be compared.

    Output, int I4_MIN, the smaller of I1 and I2.
 */
{
	int value;

	if (i1 < i2) {
		value = i1;
	} else {
		value = i2;
	}
	return value;
}

/******************************************************************************/

float ln_cordic(float x, int n)

/******************************************************************************/
/*
  Purpose:

    LN_CORDIC evaluates the natural logarithm using the CORDIC method.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 January 2012

  Author:

    John Burkardt

  Reference:

    Frederick Ruckdeschel,
    BASIC Scientific Subroutines,
    Volume II,
    McGraw-Hill, 1980,
    ISBN: 0-07-054202-3,
    LC: QA76.95.R82.

  Parameters:

    Input, float X, the argument.

    Input, int N, the number of steps to take.

    Output, float FX, the natural logarithm of X.

  Local Parameters:

    Local, float A(1:25) = exp ( (1/2)^(1:25) );
 */
{
#define A_LENGTH 25

	float a[A_LENGTH] = {
		1.648721270700128,
		1.284025416687742,
		1.133148453066826,
		1.064494458917859,
		1.031743407499103,
		1.015747708586686,
		1.007843097206488,
		1.003913889338348,
		1.001955033591003,
		1.000977039492417,
		1.000488400478694,
		1.000244170429748,
		1.000122077763384,
		1.000061037018933,
		1.000030518043791,
		1.0000152589054785,
		1.0000076294236351,
		1.0000038147045416,
		1.0000019073504518,
		1.0000009536747712,
		1.0000004768372719,
		1.0000002384186075,
		1.0000001192092967,
		1.0000000596046466,
		1.0000000298023228
	};
	float ai;
	float e = 2.718281828459045;
	float fx;
	int i;
	int k;
	float poweroftwo;
	float *w;

	if (x <= 0.0) {
		fprintf(stderr, "\n");
		fprintf(stderr, "LN_CORDIC - Fatal error!\n");
		fprintf(stderr, "  Input argument X <= 0.0\n");
		exit(1);
	}

	k = 0;

	while (e <= x) {
		k = k + 1;
		x = x / e;
	}

	while (x < 1.0) {
		k = k - 1;
		x = x * e;
	}
	/*
	  Determine the weights.
	 */
	w = (float *) malloc(n * sizeof( float));

	for (i = 0; i < n; i++) {
		w[i] = 0.0;

		if (i < A_LENGTH) {
			ai = a[i];
		} else {
			ai = 1.0 + (ai - 1.0) / 2.0;
		}

		if (ai < x) {
			w[i] = 1.0;
			x = x / ai;
		}
	}

	x = x - 1.0;

	x = x
		* (1.0 - (x / 2.0)
		* (1.0 + (x / 3.0)
		* (1.0 - x / 4.0)));
	/*
	  Assemble
	 */
	poweroftwo = 0.5;

	for (i = 0; i < n; i++) {
		x = x + w[i] * poweroftwo;
		poweroftwo = poweroftwo / 2.0;
	}

	fx = x + (float) (k);

	free(w);

	return fx;
#undef A_LENGTH
}

/******************************************************************************/

void ln_values(int *n_data, float *x, float *fx)

/******************************************************************************/
/*
  Purpose:

    LN_VALUES returns some values of the natural logarithm function.

  Discussion:

    In Mathematica, the function can be evaluated by:

      Log[x]

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 June 2007

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output, float *FX, the value of the function.
 */
{
#define N_MAX 20

	static float fx_vec[N_MAX] = {
		-11.512925464970228420E+00,
		-4.6051701859880913680E+00,
		-2.3025850929940456840E+00,
		-1.6094379124341003746E+00,
		-1.2039728043259359926E+00,
		-0.91629073187415506518E+00,
		-0.69314718055994530942E+00,
		-0.51082562376599068321E+00,
		-0.35667494393873237891E+00,
		-0.22314355131420975577E+00,
		-0.10536051565782630123E+00,
		0.00000000000000000000E+00,
		0.69314718055994530942E+00,
		1.0986122886681096914E+00,
		1.1447298858494001741E+00,
		1.6094379124341003746E+00,
		2.3025850929940456840E+00,
		2.9957322735539909934E+00,
		4.6051701859880913680E+00,
		18.631401766168018033E+00
	};

	static float x_vec[N_MAX] = {
		1.0E-05,
		1.0E-02,
		0.1E+00,
		0.2E+00,
		0.3E+00,
		0.4E+00,
		0.5E+00,
		0.6E+00,
		0.7E+00,
		0.8E+00,
		0.9E+00,
		1.0E+00,
		2.0E+00,
		3.0E+00,
		3.1415926535897932385E+00,
		5.0E+00,
		10.0E+00,
		20.0E+00,
		100.0E+00,
		123456789.0E+00
	};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*fx = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*fx = fx_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

float r8_uniform_01(int *seed)

/******************************************************************************/
/*
  Purpose:

    R8_UNIFORM_01 returns a unit pseudorandom R8.

  Discussion:

    This routine implements the recursion

      seed = 16807 * seed mod ( 2^31 - 1 )
      r8_uniform_01 = seed / ( 2^31 - 1 )

    The integer arithmetic never requires more than 32 bits,
    including a sign bit.

    If the initial seed is 12345, then the first three computations are

      Input     Output      R8_UNIFORM_01
      SEED      SEED

	 12345   207482415  0.096616
     207482415  1790989824  0.833995
    1790989824  2035175616  0.947702

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    11 August 2004

  Author:

    John Burkardt

  Reference:

    Paul Bratley, Bennett Fox, Linus Schrage,
    A Guide to Simulation,
    Springer Verlag, pages 201-202, 1983.

    Pierre L'Ecuyer,
    Random Number Generation,
    in Handbook of Simulation
    edited by Jerry Banks,
    Wiley Interscience, page 95, 1998.

    Bennett Fox,
    Algorithm 647:
    Implementation and Relative Efficiency of Quasirandom
    Sequence Generators,
    ACM Transactions on Mathematical Software,
    Volume 12, Number 4, pages 362-376, 1986.

    Peter Lewis, Allen Goodman, James Miller,
    A Pseudo-Random Number Generator for the System/360,
    IBM Systems Journal,
    Volume 8, pages 136-143, 1969.

  Parameters:

    Input/output, int *SEED, the "seed" value.  Normally, this
    value should not be 0.  On output, SEED has been updated.

    Output, float R8_UNIFORM_01, a new pseudorandom variate,
    strictly between 0 and 1.
 */
{
	int k;
	float r;

	if (*seed == 0) {
		fprintf(stderr, "\n");
		fprintf(stderr, "R8_UNIFORM_01 - Fatal error!\n");
		fprintf(stderr, "  Input value of SEED = 0.\n");
		exit(1);
	}

	k = *seed / 127773;

	*seed = 16807 * (*seed - k * 127773) - k * 2836;

	if (*seed < 0) {
		*seed = *seed + i4_huge();
	}
	/*
	  Although SEED can be represented exactly as a 32 bit integer,
	  it generally cannot be represented exactly as a 32 bit real number!
	 */
	r = (float) (*seed) * 4.656612875E-10;

	return r;
}

/******************************************************************************/

void sin_values(int *n_data, float *x, float *fx)

/******************************************************************************/
/*
  Purpose:

    SIN_VALUES returns some values of the sine function.

  Discussion:

    In Mathematica, the function can be evaluated by:

      Sin[x]

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    12 June 2007

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output, float *FX, the value of the function.
 */
{
#define N_MAX 13

	static float fx_vec[N_MAX] = {
		0.00000000000000000000,
		0.25881904510252076235,
		0.47942553860420300027,
		0.50000000000000000000,
		0.70710678118654752440,
		0.84147098480789650665,
		0.86602540378443864676,
		1.00000000000000000000,
		0.90929742682568169540,
		0.14112000805986722210,
		0.00000000000000000000,
		-0.75680249530792825137,
		-0.95892427466313846889
	};

	static float x_vec[N_MAX] = {
		0.0000000000000000000,
		0.26179938779914943654,
		0.50000000000000000000,
		0.52359877559829887308,
		0.78539816339744830962,
		1.0000000000000000000,
		1.0471975511965977462,
		1.5707963267948966192,
		2.0000000000000000000,
		3.0000000000000000000,
		3.1415926535897932385,
		4.0000000000000000000,
		5.0000000000000000000
	};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*fx = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*fx = fx_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

float sqrt_cordic(float x, int n)

/******************************************************************************/
/*
  Purpose:

    SQRT_CORDIC returns the square root of a value using the CORDIC method.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 January 2012

  Author:

    John Burkardt

  Parameters:

    Input, float X, the number whose square root is desired.

    Input, int N, the number of iterations to take.
    This is essentially the number of binary digits of accuracy, and
    might go as high as 53.

    Output, float SQRT_CORDIC, the approximate square root of X.
 */
{
	int i;
	float poweroftwo;
	float y;

	if (x < 0.0) {
		fprintf(stderr, "\n");
		fprintf(stderr, "SQRT_CORDIC - Fatal error!\n");
		fprintf(stderr, "  X < 0.\n");
		exit(1);
	}

	if (x == 0.0) {
		y = 0.0;
		return y;
	}

	if (x == 1.0) {
		y = 1.0;
		return y;
	}

	poweroftwo = 1.0;

	if (x < 1.0) {
		while (x <= poweroftwo * poweroftwo) {
			poweroftwo = poweroftwo / 2.0;
		}
		y = poweroftwo;
	} else if (1.0 < x) {
		while (poweroftwo * poweroftwo <= x) {
			poweroftwo = 2.0 * poweroftwo;
		}
		y = poweroftwo / 2.0;
	}

	for (i = 1; i <= n; i++) {
		poweroftwo = poweroftwo / 2.0;
		if ((y + poweroftwo) * (y + poweroftwo) <= x) {
			y = y + poweroftwo;
		}
	}

	return y;
}

/******************************************************************************/

void sqrt_values(int *n_data, float *x, float *fx)

/******************************************************************************/
/*
  Purpose:

    SQRT_VALUES returns some values of the square root function.

  Discussion:

    SQRT(X) = positive real number Y such that Y * Y = X.

    In Mathematica, the function can be evaluated by:

      Sqrt[x]

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    29 August 2004

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output float FX, the value of the function.
 */
{
#define N_MAX 14

	static float fx_vec[N_MAX] = {
		0.0000000000000000E+00,
		0.9000000040950000E-04,
		0.3000000000000000E+00,
		0.3162277660168379E+00,
		0.6324555320336759E+00,
		0.1000000000000000E+01,
		0.1414213562373095E+01,
		0.1732050807568877E+01,
		0.1772453850905516E+01,
		0.4358898943540674E+01,
		0.5385164807134504E+01,
		0.8426149773176359E+01,
		0.9848857801796105E+01,
		0.1111111106055556E+05
	};

	static float x_vec[N_MAX] = {
		0.0000000000000000E+00,
		0.8100000073710001E-08,
		0.9000000000000000E-01,
		0.1000000000000000E+00,
		0.4000000000000000E+00,
		0.1000000000000000E+01,
		0.2000000000000000E+01,
		0.3000000000000000E+01,
		0.3141592653589793E+01,
		0.1900000000000000E+02,
		0.2900000000000000E+02,
		0.7100000000000000E+02,
		0.9700000000000000E+02,
		0.1234567890000000E+09
	};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*fx = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*fx = fx_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

float tan_cordic(float beta, int n)

/******************************************************************************/
/*
  Purpose:

    TAN_CORDIC returns the tangent of an angle using the CORDIC method.

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    19 January 2012

  Author:

    Based on MATLAB code in a Wikipedia article.
    C++ version by John Burkardt

  Parameters:

    Input, float BETA, the angle (in radians).

    Input, int N, the number of iterations to take.
    A value of 10 is low.  Good accuracy is achieved with 20 or more
    iterations.

    Output, float TAN_CORDIC, the tangent of the angle.

  Local Parameters:

    Local, float ANGLES(60) = arctan ( (1/2)^(0:59) );
 */
{
#define ANGLES_LENGTH 60

	float angle;
	float angles[ANGLES_LENGTH] = {
		7.8539816339744830962E-01,
		4.6364760900080611621E-01,
		2.4497866312686415417E-01,
		1.2435499454676143503E-01,
		6.2418809995957348474E-02,
		3.1239833430268276254E-02,
		1.5623728620476830803E-02,
		7.8123410601011112965E-03,
		3.9062301319669718276E-03,
		1.9531225164788186851E-03,
		9.7656218955931943040E-04,
		4.8828121119489827547E-04,
		2.4414062014936176402E-04,
		1.2207031189367020424E-04,
		6.1035156174208775022E-05,
		3.0517578115526096862E-05,
		1.5258789061315762107E-05,
		7.6293945311019702634E-06,
		3.8146972656064962829E-06,
		1.9073486328101870354E-06,
		9.5367431640596087942E-07,
		4.7683715820308885993E-07,
		2.3841857910155798249E-07,
		1.1920928955078068531E-07,
		5.9604644775390554414E-08,
		2.9802322387695303677E-08,
		1.4901161193847655147E-08,
		7.4505805969238279871E-09,
		3.7252902984619140453E-09,
		1.8626451492309570291E-09,
		9.3132257461547851536E-10,
		4.6566128730773925778E-10,
		2.3283064365386962890E-10,
		1.1641532182693481445E-10,
		5.8207660913467407226E-11,
		2.9103830456733703613E-11,
		1.4551915228366851807E-11,
		7.2759576141834259033E-12,
		3.6379788070917129517E-12,
		1.8189894035458564758E-12,
		9.0949470177292823792E-13,
		4.5474735088646411896E-13,
		2.2737367544323205948E-13,
		1.1368683772161602974E-13,
		5.6843418860808014870E-14,
		2.8421709430404007435E-14,
		1.4210854715202003717E-14,
		7.1054273576010018587E-15,
		3.5527136788005009294E-15,
		1.7763568394002504647E-15,
		8.8817841970012523234E-16,
		4.4408920985006261617E-16,
		2.2204460492503130808E-16,
		1.1102230246251565404E-16,
		5.5511151231257827021E-17,
		2.7755575615628913511E-17,
		1.3877787807814456755E-17,
		6.9388939039072283776E-18,
		3.4694469519536141888E-18,
		1.7347234759768070944E-18
	};
	float c;
	float c2;
	float factor;
	int j;
	float pi = 3.141592653589793;
	float poweroftwo;
	float s;
	float s2;
	float sigma;
	float t;
	float theta;
	/*
	  Shift angle to interval [-pi,pi].
	 */
	theta = angle_shift(beta, -pi);
	/*
	  Shift angle to interval [-pi/2,pi/2].
	 */
	if (theta < -0.5 * pi) {
		theta = theta + pi;
	} else if (0.5 * pi < theta) {
		theta = theta - pi;
	}

	c = 1.0;
	s = 0.0;

	poweroftwo = 1.0;
	angle = angles[0];

	for (j = 1; j <= n; j++) {
		if (theta < 0.0) {
			sigma = -1.0;
		} else {
			sigma = 1.0;
		}

		factor = sigma * poweroftwo;

		c2 = c - factor * s;
		s2 = factor * c + s;

		c = c2;
		s = s2;
		/*
		  Update the remaining angle.
		 */
		theta = theta - sigma * angle;

		poweroftwo = poweroftwo / 2.0;
		/*
		  Update the angle from table, or eventually by just dividing by two.
		 */
		if (ANGLES_LENGTH < j + 1) {
			angle = angle / 2.0;
		} else {
			angle = angles[j];
		}
	}

	t = s / c;

	return t;
#undef ANGLES_LENGTH
}

/******************************************************************************/

void tan_values(int *n_data, float *x, float *fx)

/******************************************************************************/
/*
  Purpose:

    TAN_VALUES returns some values of the tangent function.

  Discussion:

    In Mathematica, the function can be evaluated by:

      Tan[x]

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    12 June 2007

  Author:

    John Burkardt

  Reference:

    Milton Abramowitz, Irene Stegun,
    Handbook of Mathematical Functions,
    National Bureau of Standards, 1964,
    ISBN: 0-486-61272-4,
    LC: QA47.A34.

    Stephen Wolfram,
    The Mathematica Book,
    Fourth Edition,
    Cambridge University Press, 1999,
    ISBN: 0-521-64314-7,
    LC: QA76.95.W65.

  Parameters:

    Input/output, int *N_DATA.  The user sets N_DATA to 0 before the
    first call.  On each call, the routine increments N_DATA by 1, and
    returns the corresponding data; when there is no more data, the
    output value of N_DATA will be 0 again.

    Output, float *X, the argument of the function.

    Output, float *FX, the value of the function.
 */
{
#define N_MAX 15

	static float fx_vec[N_MAX] = {
		0.00000000000000000000,
		0.26794919243112270647,
		0.54630248984379051326,
		0.57735026918962576451,
		1.0000000000000000000,
		1.5574077246549022305,
		1.7320508075688772935,
		3.7320508075688772935,
		7.5957541127251504405,
		15.257051688265539110,
		-2.1850398632615189916,
		-0.14254654307427780530,
		0.0000000000000000000,
		1.1578212823495775831,
		-3.3805150062465856370
	};

	static float x_vec[N_MAX] = {
		0.00000000000000000000,
		0.26179938779914943654,
		0.50000000000000000000,
		0.52359877559829887308,
		0.78539816339744830962,
		1.0000000000000000000,
		1.0471975511965977462,
		1.3089969389957471827,
		1.4398966328953219010,
		1.5053464798451092601,
		2.0000000000000000000,
		3.0000000000000000000,
		3.1415926535897932385,
		4.0000000000000000000,
		5.0000000000000000000
	};

	if (*n_data < 0) {
		*n_data = 0;
	}

	*n_data = *n_data + 1;

	if (N_MAX < *n_data) {
		*n_data = 0;
		*x = 0.0;
		*fx = 0.0;
	} else {
		*x = x_vec[*n_data - 1];
		*fx = fx_vec[*n_data - 1];
	}

	return;
#undef N_MAX
}

/******************************************************************************/

void timestamp(void)

/******************************************************************************/
/*
  Purpose:

    TIMESTAMP prints the current YMDHMS date as a time stamp.

  Example:

    31 May 2001 09:45:54 AM

  Licensing:

    This code is distributed under the GNU LGPL license.

  Modified:

    24 September 2003

  Author:

    John Burkardt

  Parameters:

    None
 */
{
#define TIME_SIZE 40

	return;
#undef TIME_SIZE
}