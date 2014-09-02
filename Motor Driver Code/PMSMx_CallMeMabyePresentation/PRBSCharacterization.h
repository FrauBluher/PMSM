/* 
 * File:   PRBSCharacterization.h
 * Author: pavlo
 *
 * Created on August 1, 2014, 9:24 AM
 */

#ifndef PRBSCHARACTERIZATION_H
#define	PRBSCHARACTERIZATION_H

typedef struct {
    uint16_t hallCount;
    uint16_t lastHallCount;
    uint16_t currentSpeed;
    uint16_t lastHallState;
} BasicMotorControlInfo;

enum {
    CW,
    CCW
};

void CharacterizeStep(void);

#endif	/* PRBSCHARACTERIZATION_H */

