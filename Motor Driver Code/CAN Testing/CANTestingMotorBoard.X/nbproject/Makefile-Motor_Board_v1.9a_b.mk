#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-Motor_Board_v1.9a_b.mk)" "nbproject/Makefile-local-Motor_Board_v1.9a_b.mk"
include nbproject/Makefile-local-Motor_Board_v1.9a_b.mk
endif
endif

# Environment
MKDIR=mkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=Motor_Board_v1.9a_b
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=elf
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/CANTestingMotorBoard.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/CANTestingMotorBoard.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED="../festival src/dcf.c" "../festival src/emcy.c" "../festival src/lifegrd.c" "../festival src/lss.c" "../festival src/nmtMaster.c" "../festival src/nmtSlave.c" "../festival src/objacces.c" "../festival src/pdo.c" "../festival src/sdo.c" "../festival src/states.c" "../festival src/symbols.c" "../festival src/sync.c" "../festival src/timer.c" ../drivers/dspic33e/can_dspic33e.c ../drivers/dspic33e/timer_dspic.c ../src/ecan1drv.c ../src/traps.c ../src/ecan1_config.c ../src/main.c ../src/superball_circularbuffer.c ../src/motor_objdict.c

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/_ext/379909333/dcf.o ${OBJECTDIR}/_ext/379909333/emcy.o ${OBJECTDIR}/_ext/379909333/lifegrd.o ${OBJECTDIR}/_ext/379909333/lss.o ${OBJECTDIR}/_ext/379909333/nmtMaster.o ${OBJECTDIR}/_ext/379909333/nmtSlave.o ${OBJECTDIR}/_ext/379909333/objacces.o ${OBJECTDIR}/_ext/379909333/pdo.o ${OBJECTDIR}/_ext/379909333/sdo.o ${OBJECTDIR}/_ext/379909333/states.o ${OBJECTDIR}/_ext/379909333/symbols.o ${OBJECTDIR}/_ext/379909333/sync.o ${OBJECTDIR}/_ext/379909333/timer.o ${OBJECTDIR}/_ext/872612413/can_dspic33e.o ${OBJECTDIR}/_ext/872612413/timer_dspic.o ${OBJECTDIR}/_ext/1360937237/ecan1drv.o ${OBJECTDIR}/_ext/1360937237/traps.o ${OBJECTDIR}/_ext/1360937237/ecan1_config.o ${OBJECTDIR}/_ext/1360937237/main.o ${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o ${OBJECTDIR}/_ext/1360937237/motor_objdict.o
POSSIBLE_DEPFILES=${OBJECTDIR}/_ext/379909333/dcf.o.d ${OBJECTDIR}/_ext/379909333/emcy.o.d ${OBJECTDIR}/_ext/379909333/lifegrd.o.d ${OBJECTDIR}/_ext/379909333/lss.o.d ${OBJECTDIR}/_ext/379909333/nmtMaster.o.d ${OBJECTDIR}/_ext/379909333/nmtSlave.o.d ${OBJECTDIR}/_ext/379909333/objacces.o.d ${OBJECTDIR}/_ext/379909333/pdo.o.d ${OBJECTDIR}/_ext/379909333/sdo.o.d ${OBJECTDIR}/_ext/379909333/states.o.d ${OBJECTDIR}/_ext/379909333/symbols.o.d ${OBJECTDIR}/_ext/379909333/sync.o.d ${OBJECTDIR}/_ext/379909333/timer.o.d ${OBJECTDIR}/_ext/872612413/can_dspic33e.o.d ${OBJECTDIR}/_ext/872612413/timer_dspic.o.d ${OBJECTDIR}/_ext/1360937237/ecan1drv.o.d ${OBJECTDIR}/_ext/1360937237/traps.o.d ${OBJECTDIR}/_ext/1360937237/ecan1_config.o.d ${OBJECTDIR}/_ext/1360937237/main.o.d ${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o.d ${OBJECTDIR}/_ext/1360937237/motor_objdict.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/_ext/379909333/dcf.o ${OBJECTDIR}/_ext/379909333/emcy.o ${OBJECTDIR}/_ext/379909333/lifegrd.o ${OBJECTDIR}/_ext/379909333/lss.o ${OBJECTDIR}/_ext/379909333/nmtMaster.o ${OBJECTDIR}/_ext/379909333/nmtSlave.o ${OBJECTDIR}/_ext/379909333/objacces.o ${OBJECTDIR}/_ext/379909333/pdo.o ${OBJECTDIR}/_ext/379909333/sdo.o ${OBJECTDIR}/_ext/379909333/states.o ${OBJECTDIR}/_ext/379909333/symbols.o ${OBJECTDIR}/_ext/379909333/sync.o ${OBJECTDIR}/_ext/379909333/timer.o ${OBJECTDIR}/_ext/872612413/can_dspic33e.o ${OBJECTDIR}/_ext/872612413/timer_dspic.o ${OBJECTDIR}/_ext/1360937237/ecan1drv.o ${OBJECTDIR}/_ext/1360937237/traps.o ${OBJECTDIR}/_ext/1360937237/ecan1_config.o ${OBJECTDIR}/_ext/1360937237/main.o ${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o ${OBJECTDIR}/_ext/1360937237/motor_objdict.o

# Source Files
SOURCEFILES=../festival src/dcf.c ../festival src/emcy.c ../festival src/lifegrd.c ../festival src/lss.c ../festival src/nmtMaster.c ../festival src/nmtSlave.c ../festival src/objacces.c ../festival src/pdo.c ../festival src/sdo.c ../festival src/states.c ../festival src/symbols.c ../festival src/sync.c ../festival src/timer.c ../drivers/dspic33e/can_dspic33e.c ../drivers/dspic33e/timer_dspic.c ../src/ecan1drv.c ../src/traps.c ../src/ecan1_config.c ../src/main.c ../src/superball_circularbuffer.c ../src/motor_objdict.c


CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
	${MAKE}  -f nbproject/Makefile-Motor_Board_v1.9a_b.mk dist/${CND_CONF}/${IMAGE_TYPE}/CANTestingMotorBoard.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=33EP256MU806
MP_LINKER_FILE_OPTION=,--script=p33EP256MU806.gld
# ------------------------------------------------------------------------------------
# Rules for buildStep: compile
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/_ext/379909333/dcf.o: ../festival\ src/dcf.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/dcf.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/dcf.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/dcf.c"  -o ${OBJECTDIR}/_ext/379909333/dcf.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/dcf.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/dcf.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/emcy.o: ../festival\ src/emcy.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/emcy.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/emcy.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/emcy.c"  -o ${OBJECTDIR}/_ext/379909333/emcy.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/emcy.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/emcy.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/lifegrd.o: ../festival\ src/lifegrd.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/lifegrd.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/lifegrd.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/lifegrd.c"  -o ${OBJECTDIR}/_ext/379909333/lifegrd.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/lifegrd.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/lifegrd.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/lss.o: ../festival\ src/lss.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/lss.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/lss.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/lss.c"  -o ${OBJECTDIR}/_ext/379909333/lss.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/lss.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/lss.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/nmtMaster.o: ../festival\ src/nmtMaster.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/nmtMaster.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/nmtMaster.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/nmtMaster.c"  -o ${OBJECTDIR}/_ext/379909333/nmtMaster.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/nmtMaster.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/nmtMaster.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/nmtSlave.o: ../festival\ src/nmtSlave.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/nmtSlave.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/nmtSlave.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/nmtSlave.c"  -o ${OBJECTDIR}/_ext/379909333/nmtSlave.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/nmtSlave.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/nmtSlave.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/objacces.o: ../festival\ src/objacces.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/objacces.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/objacces.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/objacces.c"  -o ${OBJECTDIR}/_ext/379909333/objacces.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/objacces.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/objacces.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/pdo.o: ../festival\ src/pdo.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/pdo.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/pdo.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/pdo.c"  -o ${OBJECTDIR}/_ext/379909333/pdo.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/pdo.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/pdo.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/sdo.o: ../festival\ src/sdo.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/sdo.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/sdo.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/sdo.c"  -o ${OBJECTDIR}/_ext/379909333/sdo.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/sdo.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/sdo.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/states.o: ../festival\ src/states.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/states.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/states.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/states.c"  -o ${OBJECTDIR}/_ext/379909333/states.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/states.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/states.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/symbols.o: ../festival\ src/symbols.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/symbols.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/symbols.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/symbols.c"  -o ${OBJECTDIR}/_ext/379909333/symbols.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/symbols.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/symbols.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/sync.o: ../festival\ src/sync.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/sync.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/sync.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/sync.c"  -o ${OBJECTDIR}/_ext/379909333/sync.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/sync.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/sync.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/timer.o: ../festival\ src/timer.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/timer.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/timer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/timer.c"  -o ${OBJECTDIR}/_ext/379909333/timer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/timer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/timer.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/872612413/can_dspic33e.o: ../drivers/dspic33e/can_dspic33e.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/872612413 
	@${RM} ${OBJECTDIR}/_ext/872612413/can_dspic33e.o.d 
	@${RM} ${OBJECTDIR}/_ext/872612413/can_dspic33e.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../drivers/dspic33e/can_dspic33e.c  -o ${OBJECTDIR}/_ext/872612413/can_dspic33e.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/872612413/can_dspic33e.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/872612413/can_dspic33e.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/872612413/timer_dspic.o: ../drivers/dspic33e/timer_dspic.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/872612413 
	@${RM} ${OBJECTDIR}/_ext/872612413/timer_dspic.o.d 
	@${RM} ${OBJECTDIR}/_ext/872612413/timer_dspic.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../drivers/dspic33e/timer_dspic.c  -o ${OBJECTDIR}/_ext/872612413/timer_dspic.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/872612413/timer_dspic.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/872612413/timer_dspic.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/ecan1drv.o: ../src/ecan1drv.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/ecan1drv.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/ecan1drv.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/ecan1drv.c  -o ${OBJECTDIR}/_ext/1360937237/ecan1drv.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/ecan1drv.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/ecan1drv.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/traps.o: ../src/traps.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/traps.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/traps.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/traps.c  -o ${OBJECTDIR}/_ext/1360937237/traps.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/traps.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/traps.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/ecan1_config.o: ../src/ecan1_config.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/ecan1_config.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/ecan1_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/ecan1_config.c  -o ${OBJECTDIR}/_ext/1360937237/ecan1_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/ecan1_config.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/ecan1_config.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/main.o: ../src/main.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/main.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/main.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/main.c  -o ${OBJECTDIR}/_ext/1360937237/main.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/main.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/main.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o: ../src/superball_circularbuffer.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/superball_circularbuffer.c  -o ${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/motor_objdict.o: ../src/motor_objdict.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/motor_objdict.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/motor_objdict.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/motor_objdict.c  -o ${OBJECTDIR}/_ext/1360937237/motor_objdict.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/motor_objdict.o.d"      -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1    -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/motor_objdict.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
else
${OBJECTDIR}/_ext/379909333/dcf.o: ../festival\ src/dcf.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/dcf.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/dcf.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/dcf.c"  -o ${OBJECTDIR}/_ext/379909333/dcf.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/dcf.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/dcf.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/emcy.o: ../festival\ src/emcy.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/emcy.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/emcy.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/emcy.c"  -o ${OBJECTDIR}/_ext/379909333/emcy.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/emcy.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/emcy.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/lifegrd.o: ../festival\ src/lifegrd.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/lifegrd.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/lifegrd.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/lifegrd.c"  -o ${OBJECTDIR}/_ext/379909333/lifegrd.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/lifegrd.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/lifegrd.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/lss.o: ../festival\ src/lss.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/lss.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/lss.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/lss.c"  -o ${OBJECTDIR}/_ext/379909333/lss.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/lss.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/lss.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/nmtMaster.o: ../festival\ src/nmtMaster.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/nmtMaster.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/nmtMaster.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/nmtMaster.c"  -o ${OBJECTDIR}/_ext/379909333/nmtMaster.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/nmtMaster.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/nmtMaster.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/nmtSlave.o: ../festival\ src/nmtSlave.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/nmtSlave.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/nmtSlave.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/nmtSlave.c"  -o ${OBJECTDIR}/_ext/379909333/nmtSlave.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/nmtSlave.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/nmtSlave.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/objacces.o: ../festival\ src/objacces.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/objacces.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/objacces.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/objacces.c"  -o ${OBJECTDIR}/_ext/379909333/objacces.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/objacces.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/objacces.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/pdo.o: ../festival\ src/pdo.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/pdo.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/pdo.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/pdo.c"  -o ${OBJECTDIR}/_ext/379909333/pdo.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/pdo.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/pdo.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/sdo.o: ../festival\ src/sdo.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/sdo.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/sdo.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/sdo.c"  -o ${OBJECTDIR}/_ext/379909333/sdo.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/sdo.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/sdo.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/states.o: ../festival\ src/states.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/states.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/states.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/states.c"  -o ${OBJECTDIR}/_ext/379909333/states.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/states.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/states.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/symbols.o: ../festival\ src/symbols.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/symbols.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/symbols.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/symbols.c"  -o ${OBJECTDIR}/_ext/379909333/symbols.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/symbols.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/symbols.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/sync.o: ../festival\ src/sync.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/sync.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/sync.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/sync.c"  -o ${OBJECTDIR}/_ext/379909333/sync.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/sync.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/sync.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/379909333/timer.o: ../festival\ src/timer.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/379909333 
	@${RM} ${OBJECTDIR}/_ext/379909333/timer.o.d 
	@${RM} ${OBJECTDIR}/_ext/379909333/timer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  "../festival src/timer.c"  -o ${OBJECTDIR}/_ext/379909333/timer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/379909333/timer.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/379909333/timer.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/872612413/can_dspic33e.o: ../drivers/dspic33e/can_dspic33e.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/872612413 
	@${RM} ${OBJECTDIR}/_ext/872612413/can_dspic33e.o.d 
	@${RM} ${OBJECTDIR}/_ext/872612413/can_dspic33e.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../drivers/dspic33e/can_dspic33e.c  -o ${OBJECTDIR}/_ext/872612413/can_dspic33e.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/872612413/can_dspic33e.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/872612413/can_dspic33e.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/872612413/timer_dspic.o: ../drivers/dspic33e/timer_dspic.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/872612413 
	@${RM} ${OBJECTDIR}/_ext/872612413/timer_dspic.o.d 
	@${RM} ${OBJECTDIR}/_ext/872612413/timer_dspic.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../drivers/dspic33e/timer_dspic.c  -o ${OBJECTDIR}/_ext/872612413/timer_dspic.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/872612413/timer_dspic.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/872612413/timer_dspic.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/ecan1drv.o: ../src/ecan1drv.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/ecan1drv.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/ecan1drv.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/ecan1drv.c  -o ${OBJECTDIR}/_ext/1360937237/ecan1drv.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/ecan1drv.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/ecan1drv.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/traps.o: ../src/traps.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/traps.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/traps.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/traps.c  -o ${OBJECTDIR}/_ext/1360937237/traps.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/traps.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/traps.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/ecan1_config.o: ../src/ecan1_config.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/ecan1_config.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/ecan1_config.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/ecan1_config.c  -o ${OBJECTDIR}/_ext/1360937237/ecan1_config.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/ecan1_config.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/ecan1_config.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/main.o: ../src/main.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/main.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/main.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/main.c  -o ${OBJECTDIR}/_ext/1360937237/main.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/main.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/main.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o: ../src/superball_circularbuffer.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/superball_circularbuffer.c  -o ${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/superball_circularbuffer.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/_ext/1360937237/motor_objdict.o: ../src/motor_objdict.c  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR}/_ext/1360937237 
	@${RM} ${OBJECTDIR}/_ext/1360937237/motor_objdict.o.d 
	@${RM} ${OBJECTDIR}/_ext/1360937237/motor_objdict.o 
	${MP_CC} $(MP_EXTRA_CC_PRE)  ../src/motor_objdict.c  -o ${OBJECTDIR}/_ext/1360937237/motor_objdict.o  -c -mcpu=$(MP_PROCESSOR_OPTION)  -MMD -MF "${OBJECTDIR}/_ext/1360937237/motor_objdict.o.d"        -g -omf=elf -O1 -I"../src" -msmart-io=1 -Wall -msfr-warn=off
	@${FIXDEPS} "${OBJECTDIR}/_ext/1360937237/motor_objdict.o.d" $(SILENT)  -rsi ${MP_CC_DIR}../ 
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemblePreproc
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
dist/${CND_CONF}/${IMAGE_TYPE}/CANTestingMotorBoard.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o dist/${CND_CONF}/${IMAGE_TYPE}/CANTestingMotorBoard.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}      -mcpu=$(MP_PROCESSOR_OPTION)        -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -omf=elf -Wl,--local-stack,--defsym=__MPLAB_BUILD=1,--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--isr,--no-gc-sections,--fill-upper=0,--stackguard=16,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem$(MP_EXTRA_LD_POST) 
	
else
dist/${CND_CONF}/${IMAGE_TYPE}/CANTestingMotorBoard.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -o dist/${CND_CONF}/${IMAGE_TYPE}/CANTestingMotorBoard.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}      -mcpu=$(MP_PROCESSOR_OPTION)        -omf=elf -Wl,--local-stack,--defsym=__MPLAB_BUILD=1,$(MP_LINKER_FILE_OPTION),--stack=16,--check-sections,--data-init,--pack-data,--handles,--isr,--no-gc-sections,--fill-upper=0,--stackguard=16,--no-force-link,--smart-io,-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--report-mem$(MP_EXTRA_LD_POST) 
	${MP_CC_DIR}/xc16-bin2hex dist/${CND_CONF}/${IMAGE_TYPE}/CANTestingMotorBoard.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX} -a  -omf=elf  
	
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/Motor_Board_v1.9a_b
	${RM} -r dist/Motor_Board_v1.9a_b

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(shell "${PATH_TO_IDE_BIN}"mplabwildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
