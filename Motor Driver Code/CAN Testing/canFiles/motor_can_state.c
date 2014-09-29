/* 
 * File:   motor_can_state.c
 * Author: jonathan
 *
 * Created on September 4, 2014, 10:23 AM
 */

#include <xc.h>

void reset_board()
{
    asm ("RESET");
    while(1);
}

