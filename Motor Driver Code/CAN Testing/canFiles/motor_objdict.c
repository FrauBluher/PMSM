
/* File generated by gen_cfile.py. Should not be modified. */

#include "motor_objdict.h"

/**************************************************************************/
/* Declaration of mapped variables                                        */
/**************************************************************************/
INTEGER32 Strain_Gauge1 = 0x0;		/* Mapped at index 0x2001, subindex 0x00 */
UNS32 Strain_Gauge2 = 0x0;		/* Mapped at index 0x2002, subindex 0x00 */
UNS32 Strain_Gauge3 = 0x0;		/* Mapped at index 0x2003, subindex 0x00 */
UNS32 Strain_Gauge4 = 0x0;		/* Mapped at index 0x2004, subindex 0x00 */
UNS32 Target_Tension = 0x0;		/* Mapped at index 0x3000, subindex 0x00 */
INTEGER32 Actual_Position = 0x0;		/* Mapped at index 0x3001, subindex 0x00 */
INTEGER32 Actual_Velocity = 0x0;		/* Mapped at index 0x3002, subindex 0x00 */
INTEGER32 Target_Position = 0x0;		/* Mapped at index 0x3003, subindex 0x00 */
INTEGER32 Target_Velocity = 0x0;		/* Mapped at index 0x3004, subindex 0x00 */
INTEGER32 Commanded_Current = 0x0;		/* Mapped at index 0x3005, subindex 0x00 */
UNS8 Voltage_24V = 0x0;		/* Mapped at index 0x4000, subindex 0x00 */

/**************************************************************************/
/* Declaration of value range types                                       */
/**************************************************************************/

#define valueRange_EMC 0x9F /* Type for index 0x1003 subindex 0x00 (only set of value 0 is possible) */
UNS32 Motor_Board_valueRangeTest (UNS8 typeValue, void * value)
{
  switch (typeValue) {
    case valueRange_EMC:
      if (*(UNS8*)value != (UNS8)0) return OD_VALUE_RANGE_EXCEEDED;
      break;
  }
  return 0;
}

/**************************************************************************/
/* The node id                                                            */
/**************************************************************************/
/* node_id default value.*/
UNS8 Motor_Board_bDeviceNodeId = 0x00;

/**************************************************************************/
/* Array of message processing information */

const UNS8 Motor_Board_iam_a_slave = 1;

TIMER_HANDLE Motor_Board_heartBeatTimers[1];

/*
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

                               OBJECT DICTIONARY

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
*/

/* index 0x1000 :   Device Type. */
                    UNS32 Motor_Board_obj1000 = 0x0;	/* 0 */
                    subindex Motor_Board_Index1000[] = 
                     {
                       { RO, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1000 }
                     };

/* index 0x1001 :   Error Register. */
                    UNS8 Motor_Board_obj1001 = 0x0;	/* 0 */
                    subindex Motor_Board_Index1001[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1001 }
                     };

/* index 0x1003 :   Pre-defined Error Field */
                    UNS8 Motor_Board_highestSubIndex_obj1003 = 0; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1003[] = 
                    {
                      0x0	/* 0 */
                    };
                    ODCallback_t Motor_Board_Index1003_callbacks[] = 
                     {
                       NULL,
                       NULL,
                     };
                    subindex Motor_Board_Index1003[] = 
                     {
                       { RW, valueRange_EMC, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1003 },
                       { RO, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1003[0] }
                     };

/* index 0x1005 :   SYNC COB ID */
                    UNS32 Motor_Board_obj1005 = 0x0;   /* 0 */

/* index 0x1006 :   Communication / Cycle Period */
                    UNS32 Motor_Board_obj1006 = 0x0;   /* 0 */

/* index 0x100C :   Guard Time */ 
                    UNS16 Motor_Board_obj100C = 0x0;   /* 0 */

/* index 0x100D :   Life Time Factor */ 
                    UNS8 Motor_Board_obj100D = 0x0;   /* 0 */

/* index 0x1014 :   Emergency COB ID */
                    UNS32 Motor_Board_obj1014 = 0x80 + 0x00;   /* 128 + NodeID */

/* index 0x1016 :   Consumer Heartbeat Time */
                    UNS8 Motor_Board_highestSubIndex_obj1016 = 0;
                    UNS32 Motor_Board_obj1016[]={0};

/* index 0x1017 :   Producer Heartbeat Time. */
                    UNS16 Motor_Board_obj1017 = 0xA;	/* 10 */
                    ODCallback_t Motor_Board_Index1017_callbacks[] = 
                     {
                       NULL,
                     };
                    subindex Motor_Board_Index1017[] = 
                     {
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1017 }
                     };

/* index 0x1018 :   Identity. */
                    UNS8 Motor_Board_highestSubIndex_obj1018 = 4; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1018_Vendor_ID = 0x0;	/* 0 */
                    UNS32 Motor_Board_obj1018_Product_Code = 0x0;	/* 0 */
                    UNS32 Motor_Board_obj1018_Revision_Number = 0x0;	/* 0 */
                    UNS32 Motor_Board_obj1018_Serial_Number = 0x0;	/* 0 */
                    subindex Motor_Board_Index1018[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1018 },
                       { RO, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1018_Vendor_ID },
                       { RO, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1018_Product_Code },
                       { RO, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1018_Revision_Number },
                       { RO, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1018_Serial_Number }
                     };

/* index 0x1200 :   Server SDO Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1200 = 2; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1200_COB_ID_Client_to_Server_Receive_SDO = 0x602;	/* 1538 */
                    UNS32 Motor_Board_obj1200_COB_ID_Server_to_Client_Transmit_SDO = 0x582;	/* 1410 */
                    subindex Motor_Board_Index1200[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1200 },
                       { RO, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1200_COB_ID_Client_to_Server_Receive_SDO },
                       { RO, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1200_COB_ID_Server_to_Client_Transmit_SDO }
                     };

/* index 0x1280 :   Client SDO 1 Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1280 = 3; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1280_COB_ID_Client_to_Server_Transmit_SDO = 0x601;	/* 1537 */
                    UNS32 Motor_Board_obj1280_COB_ID_Server_to_Client_Receive_SDO = 0x581;	/* 1409 */
                    UNS8 Motor_Board_obj1280_Node_ID_of_the_SDO_Server = 0x1;	/* 1 */
                    subindex Motor_Board_Index1280[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1280 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1280_COB_ID_Client_to_Server_Transmit_SDO },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1280_COB_ID_Server_to_Client_Receive_SDO },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1280_Node_ID_of_the_SDO_Server }
                     };

/* index 0x1400 :   Receive PDO 1 Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1400 = 6; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1400_COB_ID_used_by_PDO = 0x181;	/* 385 */
                    UNS8 Motor_Board_obj1400_Transmission_Type = 0xFF;	/* 255 */
                    UNS16 Motor_Board_obj1400_Inhibit_Time = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1400_Compatibility_Entry = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1400_Event_Timer = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1400_SYNC_start_value = 0x0;	/* 0 */
                    subindex Motor_Board_Index1400[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1400 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1400_COB_ID_used_by_PDO },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1400_Transmission_Type },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1400_Inhibit_Time },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1400_Compatibility_Entry },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1400_Event_Timer },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1400_SYNC_start_value }
                     };

/* index 0x1401 :   Receive PDO 2 Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1401 = 6; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1401_COB_ID_used_by_PDO = 0x281;	/* 641 */
                    UNS8 Motor_Board_obj1401_Transmission_Type = 0xFF;	/* 255 */
                    UNS16 Motor_Board_obj1401_Inhibit_Time = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1401_Compatibility_Entry = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1401_Event_Timer = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1401_SYNC_start_value = 0x0;	/* 0 */
                    subindex Motor_Board_Index1401[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1401 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1401_COB_ID_used_by_PDO },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1401_Transmission_Type },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1401_Inhibit_Time },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1401_Compatibility_Entry },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1401_Event_Timer },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1401_SYNC_start_value }
                     };

/* index 0x1402 :   Receive PDO 3 Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1402 = 6; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1402_COB_ID_used_by_PDO = 0x381;	/* 897 */
                    UNS8 Motor_Board_obj1402_Transmission_Type = 0xFF;	/* 255 */
                    UNS16 Motor_Board_obj1402_Inhibit_Time = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1402_Compatibility_Entry = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1402_Event_Timer = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1402_SYNC_start_value = 0x0;	/* 0 */
                    subindex Motor_Board_Index1402[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1402 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1402_COB_ID_used_by_PDO },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1402_Transmission_Type },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1402_Inhibit_Time },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1402_Compatibility_Entry },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1402_Event_Timer },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1402_SYNC_start_value }
                     };

/* index 0x1403 :   Receive PDO 4 Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1403 = 6; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1403_COB_ID_used_by_PDO = 0x481;	/* 1153 */
                    UNS8 Motor_Board_obj1403_Transmission_Type = 0xFF;	/* 255 */
                    UNS16 Motor_Board_obj1403_Inhibit_Time = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1403_Compatibility_Entry = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1403_Event_Timer = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1403_SYNC_start_value = 0x0;	/* 0 */
                    subindex Motor_Board_Index1403[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1403 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1403_COB_ID_used_by_PDO },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1403_Transmission_Type },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1403_Inhibit_Time },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1403_Compatibility_Entry },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1403_Event_Timer },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1403_SYNC_start_value }
                     };

/* index 0x1600 :   Receive PDO 1 Mapping. */
                    UNS8 Motor_Board_highestSubIndex_obj1600 = 2; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1600[] = 
                    {
                      0x20010020,	/* 536936480 */
                      0x20020020	/* 537002016 */
                    };
                    subindex Motor_Board_Index1600[] = 
                     {
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1600 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1600[0] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1600[1] }
                     };

/* index 0x1601 :   Receive PDO 2 Mapping. */
                    UNS8 Motor_Board_highestSubIndex_obj1601 = 2; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1601[] = 
                    {
                      0x20030020,	/* 537067552 */
                      0x20040020	/* 537133088 */
                    };
                    subindex Motor_Board_Index1601[] = 
                     {
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1601 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1601[0] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1601[1] }
                     };

/* index 0x1602 :   Receive PDO 3 Mapping. */
                    UNS8 Motor_Board_highestSubIndex_obj1602 = 2; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1602[] = 
                    {
                      0x30030020,	/* 805503008 */
                      0x30040020	/* 805568544 */
                    };
                    ODCallback_t Motor_Board_Index1602_callbacks[] = 
                     {
                       NULL,
                       NULL,
                       NULL,
                     };
                    subindex Motor_Board_Index1602[] = 
                     {
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1602 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1602[0] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1602[1] }
                     };

/* index 0x1603 :   Receive PDO 4 Mapping. */
                    UNS8 Motor_Board_highestSubIndex_obj1603 = 2; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1603[] = 
                    {
                      0x30000020,	/* 805306400 */
                      0x0	/* 0 */
                    };
                    subindex Motor_Board_Index1603[] = 
                     {
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1603 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1603[0] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1603[1] }
                     };

/* index 0x1800 :   Transmit PDO 1 Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1800 = 6; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1800_COB_ID_used_by_PDO = 0x182;	/* 386 */
                    UNS8 Motor_Board_obj1800_Transmission_Type = 0xFF;	/* 255 */
                    UNS16 Motor_Board_obj1800_Inhibit_Time = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1800_Compatibility_Entry = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1800_Event_Timer = 0xA;	/* 10 */
                    UNS8 Motor_Board_obj1800_SYNC_start_value = 0x0;	/* 0 */
                    ODCallback_t Motor_Board_Index1800_callbacks[] = 
                     {
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                     };
                    subindex Motor_Board_Index1800[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1800 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1800_COB_ID_used_by_PDO },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1800_Transmission_Type },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1800_Inhibit_Time },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1800_Compatibility_Entry },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1800_Event_Timer },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1800_SYNC_start_value }
                     };

/* index 0x1801 :   Transmit PDO 2 Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1801 = 6; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1801_COB_ID_used_by_PDO = 0x282;	/* 642 */
                    UNS8 Motor_Board_obj1801_Transmission_Type = 0xFF;	/* 255 */
                    UNS16 Motor_Board_obj1801_Inhibit_Time = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1801_Compatibility_Entry = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1801_Event_Timer = 0x1;	/* 1 */
                    UNS8 Motor_Board_obj1801_SYNC_start_value = 0x0;	/* 0 */
                    ODCallback_t Motor_Board_Index1801_callbacks[] = 
                     {
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                     };
                    subindex Motor_Board_Index1801[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1801 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1801_COB_ID_used_by_PDO },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1801_Transmission_Type },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1801_Inhibit_Time },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1801_Compatibility_Entry },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1801_Event_Timer },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1801_SYNC_start_value }
                     };

/* index 0x1802 :   Transmit PDO 3 Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1802 = 6; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1802_COB_ID_used_by_PDO = 0x380;	/* 896 */
                    UNS8 Motor_Board_obj1802_Transmission_Type = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1802_Inhibit_Time = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1802_Compatibility_Entry = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1802_Event_Timer = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1802_SYNC_start_value = 0x0;	/* 0 */
                    ODCallback_t Motor_Board_Index1802_callbacks[] = 
                     {
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                     };
                    subindex Motor_Board_Index1802[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1802 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1802_COB_ID_used_by_PDO },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1802_Transmission_Type },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1802_Inhibit_Time },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1802_Compatibility_Entry },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1802_Event_Timer },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1802_SYNC_start_value }
                     };

/* index 0x1803 :   Transmit PDO 4 Parameter. */
                    UNS8 Motor_Board_highestSubIndex_obj1803 = 6; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1803_COB_ID_used_by_PDO = 0x480;	/* 1152 */
                    UNS8 Motor_Board_obj1803_Transmission_Type = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1803_Inhibit_Time = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1803_Compatibility_Entry = 0x0;	/* 0 */
                    UNS16 Motor_Board_obj1803_Event_Timer = 0x0;	/* 0 */
                    UNS8 Motor_Board_obj1803_SYNC_start_value = 0x0;	/* 0 */
                    ODCallback_t Motor_Board_Index1803_callbacks[] = 
                     {
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                     };
                    subindex Motor_Board_Index1803[] = 
                     {
                       { RO, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1803 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1803_COB_ID_used_by_PDO },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1803_Transmission_Type },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1803_Inhibit_Time },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1803_Compatibility_Entry },
                       { RW, uint16, sizeof (UNS16), (void*)&Motor_Board_obj1803_Event_Timer },
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_obj1803_SYNC_start_value }
                     };

/* index 0x1A00 :   Transmit PDO 1 Mapping. */
                    UNS8 Motor_Board_highestSubIndex_obj1A00 = 2; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1A00[] = 
                    {
                      0x30010020,	/* 805371936 */
                      0x30020020	/* 805437472 */
                    };
                    subindex Motor_Board_Index1A00[] = 
                     {
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1A00 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A00[0] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A00[1] }
                     };

/* index 0x1A01 :   Transmit PDO 2 Mapping. */
                    UNS8 Motor_Board_highestSubIndex_obj1A01 = 1; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1A01[] = 
                    {
                      0x30050020	/* 805634080 */
                    };
                    subindex Motor_Board_Index1A01[] = 
                     {
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1A01 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A01[0] }
                     };

/* index 0x1A02 :   Transmit PDO 3 Mapping. */
                    UNS8 Motor_Board_highestSubIndex_obj1A02 = 8; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1A02[] = 
                    {
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0	/* 0 */
                    };
                    subindex Motor_Board_Index1A02[] = 
                     {
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1A02 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A02[0] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A02[1] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A02[2] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A02[3] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A02[4] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A02[5] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A02[6] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A02[7] }
                     };

/* index 0x1A03 :   Transmit PDO 4 Mapping. */
                    UNS8 Motor_Board_highestSubIndex_obj1A03 = 8; /* number of subindex - 1*/
                    UNS32 Motor_Board_obj1A03[] = 
                    {
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0,	/* 0 */
                      0x0	/* 0 */
                    };
                    subindex Motor_Board_Index1A03[] = 
                     {
                       { RW, uint8, sizeof (UNS8), (void*)&Motor_Board_highestSubIndex_obj1A03 },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A03[0] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A03[1] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A03[2] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A03[3] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A03[4] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A03[5] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A03[6] },
                       { RW, uint32, sizeof (UNS32), (void*)&Motor_Board_obj1A03[7] }
                     };

/* index 0x2001 :   Mapped variable Strain_Gauge1 */
                    subindex Motor_Board_Index2001[] = 
                     {
                       { RW, int32, sizeof (INTEGER32), (void*)&Strain_Gauge1 }
                     };

/* index 0x2002 :   Mapped variable Strain_Gauge2 */
                    subindex Motor_Board_Index2002[] = 
                     {
                       { RW, uint32, sizeof (UNS32), (void*)&Strain_Gauge2 }
                     };

/* index 0x2003 :   Mapped variable Strain_Gauge3 */
                    subindex Motor_Board_Index2003[] = 
                     {
                       { RW, uint32, sizeof (UNS32), (void*)&Strain_Gauge3 }
                     };

/* index 0x2004 :   Mapped variable Strain_Gauge4 */
                    subindex Motor_Board_Index2004[] = 
                     {
                       { RW, uint32, sizeof (UNS32), (void*)&Strain_Gauge4 }
                     };

/* index 0x3000 :   Mapped variable Target_Tension */
                    subindex Motor_Board_Index3000[] = 
                     {
                       { RW, uint32, sizeof (UNS32), (void*)&Target_Tension }
                     };

/* index 0x3001 :   Mapped variable Actual_Position */
                    subindex Motor_Board_Index3001[] = 
                     {
                       { RW, int32, sizeof (INTEGER32), (void*)&Actual_Position }
                     };

/* index 0x3002 :   Mapped variable Actual_Velocity */
                    subindex Motor_Board_Index3002[] = 
                     {
                       { RW, int32, sizeof (INTEGER32), (void*)&Actual_Velocity }
                     };

/* index 0x3003 :   Mapped variable Target_Position */
                    subindex Motor_Board_Index3003[] = 
                     {
                       { RW, int32, sizeof (INTEGER32), (void*)&Target_Position }
                     };

/* index 0x3004 :   Mapped variable Target_Velocity */
                    subindex Motor_Board_Index3004[] = 
                     {
                       { RW, int32, sizeof (INTEGER32), (void*)&Target_Velocity }
                     };

/* index 0x3005 :   Mapped variable Commanded_Current */
                    subindex Motor_Board_Index3005[] = 
                     {
                       { RW, int32, sizeof (INTEGER32), (void*)&Commanded_Current }
                     };

/* index 0x4000 :   Mapped variable Voltage_24V */
                    subindex Motor_Board_Index4000[] = 
                     {
                       { RW, uint8, sizeof (UNS8), (void*)&Voltage_24V }
                     };

/**************************************************************************/
/* Declaration of pointed variables                                       */
/**************************************************************************/

const indextable Motor_Board_objdict[] = 
{
  { (subindex*)Motor_Board_Index1000,sizeof(Motor_Board_Index1000)/sizeof(Motor_Board_Index1000[0]), 0x1000},
  { (subindex*)Motor_Board_Index1001,sizeof(Motor_Board_Index1001)/sizeof(Motor_Board_Index1001[0]), 0x1001},
  { (subindex*)Motor_Board_Index1017,sizeof(Motor_Board_Index1017)/sizeof(Motor_Board_Index1017[0]), 0x1017},
  { (subindex*)Motor_Board_Index1018,sizeof(Motor_Board_Index1018)/sizeof(Motor_Board_Index1018[0]), 0x1018},
  { (subindex*)Motor_Board_Index1200,sizeof(Motor_Board_Index1200)/sizeof(Motor_Board_Index1200[0]), 0x1200},
  { (subindex*)Motor_Board_Index1280,sizeof(Motor_Board_Index1280)/sizeof(Motor_Board_Index1280[0]), 0x1280},
  { (subindex*)Motor_Board_Index1400,sizeof(Motor_Board_Index1400)/sizeof(Motor_Board_Index1400[0]), 0x1400},
  { (subindex*)Motor_Board_Index1401,sizeof(Motor_Board_Index1401)/sizeof(Motor_Board_Index1401[0]), 0x1401},
  { (subindex*)Motor_Board_Index1402,sizeof(Motor_Board_Index1402)/sizeof(Motor_Board_Index1402[0]), 0x1402},
  { (subindex*)Motor_Board_Index1403,sizeof(Motor_Board_Index1403)/sizeof(Motor_Board_Index1403[0]), 0x1403},
  { (subindex*)Motor_Board_Index1600,sizeof(Motor_Board_Index1600)/sizeof(Motor_Board_Index1600[0]), 0x1600},
  { (subindex*)Motor_Board_Index1601,sizeof(Motor_Board_Index1601)/sizeof(Motor_Board_Index1601[0]), 0x1601},
  { (subindex*)Motor_Board_Index1602,sizeof(Motor_Board_Index1602)/sizeof(Motor_Board_Index1602[0]), 0x1602},
  { (subindex*)Motor_Board_Index1603,sizeof(Motor_Board_Index1603)/sizeof(Motor_Board_Index1603[0]), 0x1603},
  { (subindex*)Motor_Board_Index1800,sizeof(Motor_Board_Index1800)/sizeof(Motor_Board_Index1800[0]), 0x1800},
  { (subindex*)Motor_Board_Index1801,sizeof(Motor_Board_Index1801)/sizeof(Motor_Board_Index1801[0]), 0x1801},
  { (subindex*)Motor_Board_Index1802,sizeof(Motor_Board_Index1802)/sizeof(Motor_Board_Index1802[0]), 0x1802},
  { (subindex*)Motor_Board_Index1803,sizeof(Motor_Board_Index1803)/sizeof(Motor_Board_Index1803[0]), 0x1803},
  { (subindex*)Motor_Board_Index1A00,sizeof(Motor_Board_Index1A00)/sizeof(Motor_Board_Index1A00[0]), 0x1A00},
  { (subindex*)Motor_Board_Index1A01,sizeof(Motor_Board_Index1A01)/sizeof(Motor_Board_Index1A01[0]), 0x1A01},
  { (subindex*)Motor_Board_Index1A02,sizeof(Motor_Board_Index1A02)/sizeof(Motor_Board_Index1A02[0]), 0x1A02},
  { (subindex*)Motor_Board_Index1A03,sizeof(Motor_Board_Index1A03)/sizeof(Motor_Board_Index1A03[0]), 0x1A03},
  { (subindex*)Motor_Board_Index2001,sizeof(Motor_Board_Index2001)/sizeof(Motor_Board_Index2001[0]), 0x2001},
  { (subindex*)Motor_Board_Index2002,sizeof(Motor_Board_Index2002)/sizeof(Motor_Board_Index2002[0]), 0x2002},
  { (subindex*)Motor_Board_Index2003,sizeof(Motor_Board_Index2003)/sizeof(Motor_Board_Index2003[0]), 0x2003},
  { (subindex*)Motor_Board_Index2004,sizeof(Motor_Board_Index2004)/sizeof(Motor_Board_Index2004[0]), 0x2004},
  { (subindex*)Motor_Board_Index3000,sizeof(Motor_Board_Index3000)/sizeof(Motor_Board_Index3000[0]), 0x3000},
  { (subindex*)Motor_Board_Index3001,sizeof(Motor_Board_Index3001)/sizeof(Motor_Board_Index3001[0]), 0x3001},
  { (subindex*)Motor_Board_Index3002,sizeof(Motor_Board_Index3002)/sizeof(Motor_Board_Index3002[0]), 0x3002},
  { (subindex*)Motor_Board_Index3003,sizeof(Motor_Board_Index3003)/sizeof(Motor_Board_Index3003[0]), 0x3003},
  { (subindex*)Motor_Board_Index3004,sizeof(Motor_Board_Index3004)/sizeof(Motor_Board_Index3004[0]), 0x3004},
  { (subindex*)Motor_Board_Index3005,sizeof(Motor_Board_Index3005)/sizeof(Motor_Board_Index3005[0]), 0x3005},
  { (subindex*)Motor_Board_Index4000,sizeof(Motor_Board_Index4000)/sizeof(Motor_Board_Index4000[0]), 0x4000},
};

const indextable * Motor_Board_scanIndexOD (UNS16 wIndex, UNS32 * errorCode, ODCallback_t **callbacks)
{
	int i;
	*callbacks = NULL;
	switch(wIndex){
		case 0x1000: i = 0;break;
		case 0x1001: i = 1;break;
		case 0x1017: i = 2;*callbacks = Motor_Board_Index1017_callbacks; break;
		case 0x1018: i = 3;break;
		case 0x1200: i = 4;break;
		case 0x1280: i = 5;break;
		case 0x1400: i = 6;break;
		case 0x1401: i = 7;break;
		case 0x1402: i = 8;break;
		case 0x1403: i = 9;break;
		case 0x1600: i = 10;break;
		case 0x1601: i = 11;break;
		case 0x1602: i = 12;*callbacks = Motor_Board_Index1602_callbacks; break;
		case 0x1603: i = 13;break;
		case 0x1800: i = 14;*callbacks = Motor_Board_Index1800_callbacks; break;
		case 0x1801: i = 15;*callbacks = Motor_Board_Index1801_callbacks; break;
		case 0x1802: i = 16;*callbacks = Motor_Board_Index1802_callbacks; break;
		case 0x1803: i = 17;*callbacks = Motor_Board_Index1803_callbacks; break;
		case 0x1A00: i = 18;break;
		case 0x1A01: i = 19;break;
		case 0x1A02: i = 20;break;
		case 0x1A03: i = 21;break;
		case 0x2001: i = 22;break;
		case 0x2002: i = 23;break;
		case 0x2003: i = 24;break;
		case 0x2004: i = 25;break;
		case 0x3000: i = 26;break;
		case 0x3001: i = 27;break;
		case 0x3002: i = 28;break;
		case 0x3003: i = 29;break;
		case 0x3004: i = 30;break;
		case 0x3005: i = 31;break;
		case 0x4000: i = 32;break;
		default:
			*errorCode = OD_NO_SUCH_OBJECT;
			return NULL;
	}
	*errorCode = OD_SUCCESSFUL;
	return &Motor_Board_objdict[i];
}

/* 
 * To count at which received SYNC a PDO must be sent.
 * Even if no pdoTransmit are defined, at least one entry is computed
 * for compilations issues.
 */
s_PDO_status Motor_Board_PDO_status[4] = {s_PDO_status_Initializer,s_PDO_status_Initializer,s_PDO_status_Initializer,s_PDO_status_Initializer};

const quick_index Motor_Board_firstIndex = {
  4, /* SDO_SVR */
  5, /* SDO_CLT */
  6, /* PDO_RCV */
  10, /* PDO_RCV_MAP */
  14, /* PDO_TRS */
  18 /* PDO_TRS_MAP */
};

const quick_index Motor_Board_lastIndex = {
  4, /* SDO_SVR */
  5, /* SDO_CLT */
  9, /* PDO_RCV */
  13, /* PDO_RCV_MAP */
  17, /* PDO_TRS */
  21 /* PDO_TRS_MAP */
};

const UNS16 Motor_Board_ObjdictSize = sizeof(Motor_Board_objdict)/sizeof(Motor_Board_objdict[0]); 

CO_Data Motor_Board_Data = CANOPEN_NODE_DATA_INITIALIZER(Motor_Board);

