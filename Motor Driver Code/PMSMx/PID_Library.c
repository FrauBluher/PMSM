
/*working variables*/
unsigned long lastTime;
float Input, Output, Setpoint;
float ITerm, lastInput;
float kp, ki, kd;
int SampleTime = 1000; //1 sec
float outMin, outMax;

void Compute()
{
	int timeChange = 1;
	if (timeChange >= SampleTime) {
		/*Compute all the working error variables*/
		float error = Setpoint - Input;
		ITerm += (ki * error);
		if (ITerm > outMax) ITerm = outMax;
		else if (ITerm < outMin) ITerm = outMin;
		float dInput = (Input - lastInput);

		/*Compute PID Output*/
		Output = kp * error + ITerm - kd * dInput;
		if (Output > outMax) Output = outMax;
		else if (Output < outMin) Output = outMin;

		/*Remember some variables for next time*/
		lastInput = Input;
	}
}

void SetTunings(float Kp, float Ki, float Kd)
{
	float SampleTimeInSec = ((float) SampleTime) / 1000;
	kp = Kp;
	ki = Ki * SampleTimeInSec;
	kd = Kd / SampleTimeInSec;
}

void SetSampleTime(int NewSampleTime)
{
	if (NewSampleTime > 0) {
		float ratio = (float) NewSampleTime
			/ (float) SampleTime;
		ki *= ratio;
		kd /= ratio;
		SampleTime = (unsigned long) NewSampleTime;
	}
}

void SetOutputLimits(float Min, float Max)
{
	if (Min > Max) return;
	outMin = Min;
	outMax = Max;

	if (Output > outMax) Output = outMax;
	else if (Output < outMin) Output = outMin;

	if (ITerm > outMax) ITerm = outMax;
	else if (ITerm < outMin) ITerm = outMin;
}

void Initialize()
{
	lastInput = Input;
	ITerm = Output;
	if (ITerm > outMax) ITerm = outMax;
	else if (ITerm < outMin) ITerm = outMin;
}