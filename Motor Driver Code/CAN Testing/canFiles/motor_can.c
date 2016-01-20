/*
 * File:   motor_can.c
 * Author: jonathan
 *
 * Created on September 3, 2014, 5:34 PM
 */


#include <xc.h>
#include "motor_can_state.h"

#include "can_dspic33e_motor.h"

#include "motor_can.h"
#ifdef CONF72
#include "motor_objdict_72.h"
#else
#include "motor_objdict_2.h"
#endif
#include "../../PMSMx/PMSMBoard.h"
#include "../../PMSMx/CircularBuffer.h"

can_data can_state;
extern CO_Data Motor_Board_Data;
static Message rec_m;

// Test Parameters for CANOpen
UNS32 PDO1_COBID = 0x0181;
UNS32 PDO2_COBID = 0x0281;
UNS32 sizeU32 = sizeof (UNS32);
UNS32 SINC_cicle = 0;
UNS8 data_type = 0;

static void can_reset(CO_Data* d);
static void can_enable_heartbeat(uint16_t time);
static void can_enable_slave_heartbeat(UNS8 nodeId, uint16_t time);
static void ConfigureSlaveNode(CO_Data* d, unsigned char nodeId);

#include <ecan.h>

return_value_t can_motor_init() {
    TRISFbits.TRISF4 = 1;
    TRISFbits.TRISF5 = 0;
    can_state.init_return = RET_OK;
    if (!canMotorInit(1000)) {
        //fail
        can_state.init_return = RET_ERROR;
        return can_state.init_return;
    }
    initTimer();

    //initialize CanFestival
    //reset callback
    Motor_Board_Data.NMT_Slave_Node_Reset_Callback = can_reset;

#ifdef CONF72
    setNodeId(&Motor_Board_Data, 0x72);
#else
    setNodeId(&Motor_Board_Data, 0x02);
#endif
    can_state.is_master = 0;
    setState(&Motor_Board_Data, Initialisation); // Init the state

    PDOInit(&Motor_Board_Data);

    return can_state.init_return;
}

uint8_t can_process() {
    uint8_t res = 0;
    if (can_state.init_return != RET_OK) {
        return 0;
    }
    while (canReceive(&rec_m)) {
        canDispatch(&Motor_Board_Data, &rec_m); //send packet to CanFestival
        res = 1;
    }

    switch (getState(&Motor_Board_Data)) {
        case Initialisation:
//            LED2 = 0;
//            LED3 = 0;
            break;
        case Pre_operational:
//            LED2 = 1;
//            LED3 = 0;
            break;
        case Operational:
//            LED2 = 0;
//            LED3 = 1;
            break;
        default:
//            LED2 = 1;
//            LED3 = 1;
            break;

    };

    return res;
}

void can_reset_node(uint8_t nodeId) {
    masterSendNMTstateChange(&Motor_Board_Data, nodeId, NMT_Reset_Node);
}

void can_start_node(uint8_t nodeId) {
    masterSendNMTstateChange(&Motor_Board_Data, nodeId, NMT_Start_Node);
}

static void _can_post_SlaveStateChange(CO_Data* d, UNS8 nodeId, e_nodeState newNodeState) {
    if (nodeId == 0x01) {
        //TODO: You can handle state changes of other nodes here.
    }
}

static void ConfigureSlaveNode(CO_Data* d, UNS8 nodeId) {
    setState(d, Operational);
    //    d->post_SlaveStateChange = _can_post_SlaveStateChange;
    //    can_start_node(nodeId);
    //    can_enable_slave_heartbeat(nodeId, 33);

}

static void CheckSDOAndContinue(CO_Data* d, UNS8 nodeId) {
    UNS32 abortCode;
    if (getWriteResultNetworkDict(d, nodeId, &abortCode) != SDO_FINISHED)

        /* Finalise last SDO transfer with this node */
        closeSDOtransfer(&Motor_Board_Data, nodeId, SDO_CLIENT);

    ConfigureSlaveNode(d, nodeId);
}

void masterInitTest() {

}

void slaveInitTest() {

}

void can_sync() {
    sendSYNC(&Motor_Board_Data);
}

static void can_reset(CO_Data* d) {
    reset_board();
}

static UNS32 OnHeartbeatProducerUpdate(CO_Data* d, const indextable * unused_indextable, UNS8 unused_bSubindex) {
    heartbeatStop(d);
    heartbeatInit(d);
    return 0;
}

static void can_enable_heartbeat(uint16_t time) {
    // checkAccess needs to be set to 1
    UNS16 Timer_Data[1] = {time};
    UNS32 s = sizeof (UNS16);
    writeLocalDict(&Motor_Board_Data, // CO_Data* for this uC
            0x1017, // Index
            0x00, // Sub-Index
            Timer_Data, // void * SourceData Location
            &s, // UNS8 * Size of Data
            1); // UNS8 checkAccess
}

static void can_enable_slave_heartbeat(UNS8 nodeId, uint16_t time) {
    /* Sample Code
    UNS32 data = 0x50;
    UNS8 size;
    UNS32 abortCode;
    writeNetworkDict(0, 0x05, 0x1016, 1, size, &data) // write the data index 1016 subindex 1 of node 5
    while (getWriteResultNetworkDict (0, 0x05, &abortCode) == SDO_DOWNLOAD_IN_PROGRESS);
     */
    UNS16 Timer_Data[1] = {time};
    UNS32 s = sizeof (UNS16);
    UNS32 abortCode;
    abortCode = writeNetworkDict(&Motor_Board_Data, // CO_Data* for this uC
            nodeId, // Node Id
            0x1017, // Index
            0x00, // Sub-Index
            s, // UNS8 * Size of Data
            0, // Data type
            Timer_Data, // void * SourceData Location
            0); // UNS8 useBlockData
}

void can_time_dispatch() {
    if (can_flag) {
        can_flag = 0;
        TimeDispatch();
    }
}

void can_push_state() {
    UNS32 data_[] = {};
    UNS32 s = 0;
    static uint8_t state = 0;

    switch (state++) {
        case 0:
            //            s = sizeof(UNS32);
            //            writeLocalDict(&Motor_Board_Data,   // CO_Data* for this uC
            //            0x2001,                // Index
            //            0x00,                  // Sub-Index]
            //            data_loadcell[0],                // void * SourceData Location
            //            &s,                    // UNS8 * Size of Data
            //            1);                    // UNS8 checkAccess
            //            break;
            //        case 1:
            //        case 2:
            //        case 3:
        default:
            state = 0;
            break;
    };
}
