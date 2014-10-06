/* 
 * File:   motor_can_state.h
 * Author: jonathan
 *
 * Created on September 4, 2014, 10:04 AM
 */

#ifndef MOTOR_CAN_STATE_H
#define	MOTOR_CAN_STATE_H
#include<stdint.h>

#ifdef	__cplusplus
extern "C" {
#endif

#define bool uint8_t

typedef enum
    {
        RET_OK = 0,
        RET_ERROR = 1,
        RET_UNKNOWN = 127
    }
return_value_t;

typedef struct {
    return_value_t          init_return;
    char                    is_master;
    int volatile            state;
    volatile bool           timer_flag;
} can_data;


#ifdef	__cplusplus
}
#endif

#endif	/* MOTOR_CAN_STATE_H */

