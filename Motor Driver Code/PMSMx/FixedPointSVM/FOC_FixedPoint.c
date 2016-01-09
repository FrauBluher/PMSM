
#include "FOC_FromScratch.h"
#include "FOC_FixedPoint.h"
#include <libq.h>
#include "../PMSMBoard.h"
#include "rtwtypes.h"

extern DW_FOC_FromScratch_T FOC_FromScratch_DW;

void FOC_Init(void) {
	FOC_FromScratch_initialize();
}

void FOC_Update_Commutation(_Q15 torque, int32_t rotorPosition)
{
	FOC_FromScratch_DW.dCommanded = 0;
	FOC_FromScratch_DW.qCommanded = (int16_T) torque;
	FOC_FromScratch_DW.thetaCommanded = (int32_T) rotorPosition * 2;
	
	FOC_FromScratch_step();

	GH_A_DC = FOC_FromScratch_DW.DC1 - 30;//25;
	GH_B_DC = FOC_FromScratch_DW.DC2 - 30;//25;
	GH_C_DC = FOC_FromScratch_DW.DC3 - 30;//25;
}