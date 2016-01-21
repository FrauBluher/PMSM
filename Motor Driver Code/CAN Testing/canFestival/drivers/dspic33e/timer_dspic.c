/*
This file is part of CanFestival, a library implementing CanOpen Stack.

Copyright (C): Edouard TISSERANT and Francis DUPIN
AVR Port: Andreas GLAUSER and Peter CHRISTEN

See COPYING file for copyrights details.

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

// AVR implementation of the  CANopen timer driver, uses Timer 3 (16 bit)

// Includes for the Canfestival driver
#include "../../include/dspic33e/applicfg.h"
#include "../../include/timer.h"
#include "../../include/dspic33e/can_dspic33e.h"
#include "../../../../../Power_Board/power_led.h"
#include <timer.h>
#include <xc.h>

#define TIMER23CONFIG (T2_ON & T2_GATE_OFF & T2_PS_1_8 & T2_32BIT_MODE_ON & T2_SOURCE_INT)
#define MAXTIME 0xFFFFFFFF
#define TIMERESET 0x0

/************************** Module variables **********************************/
// Store the last timer value to calculate the elapsed time
static TIMEVAL last_time_set = TIMEVAL_MAX;
volatile uint8_t can_flag;

void initTimer(void)
/******************************************************************************
Initializes the timer, turn on the interrupt and put the interrupt time to zero
INPUT	void
OUTPUT	void
 ******************************************************************************/ {
    OpenTimer23(TIMER23CONFIG, TIMERESET);
    ConfigIntTimer23(T3_INT_PRIOR_5 & T3_INT_ON);
    T2CONbits.TSIDL = 0;
    can_flag = 1;
}

void setTimer(TIMEVAL value)
/******************************************************************************
Set the timer for the next alarm.
INPUT	value TIMEVAL (unsigned long)
OUTPUT	void
 ******************************************************************************/ {
    uint32_t tmp = (ReadTimer23() + value);
    OpenTimer23(TIMER23CONFIG, tmp);
    ConfigIntTimer23(T3_INT_PRIOR_5 & T3_INT_ON);
}

inline TIMEVAL getElapsedTime(void)
/******************************************************************************
Return the elapsed time to tell the Stack how much time is spent since last call.
INPUT	void
OUTPUT	value TIMEVAL (unsigned long) the elapsed time
 * NOTE: this is the time SINCE timeDispatch was called (don't reset it when setTimer is called!).
 * So it's just used as the time difference between the interrupt and the actual timeDispatch call.
 * TODO: is it worth implementing this, or is the time delay small enough?
 ******************************************************************************/ {
    uint32_t timer = ReadTimer23();

    if (timer > last_time_set) // In case the timer value is higher than the last time.
        return (timer - last_time_set); // Calculate the time difference
    else if (timer < last_time_set)
        return (last_time_set - timer); // Calculate the time difference
    else
        return TIMEVAL_MAX;
}

void __attribute__((__interrupt__, no_auto_psv)) _T3Interrupt(void) {
    can_flag = 1;
    last_time_set = ReadTimer23();
    ConfigIntTimer23(T3_INT_PRIOR_5 & T3_INT_ON);
}




