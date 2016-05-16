//
//  JHConstants.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#ifndef JHConstants_h
#define JHConstants_h

typedef struct Vec2 {
    int x;
    int y;
} Vec2;

typedef struct Vec4 {
    int x;
    int y;
    int width;
    int height;
} Vec4;

double randDecimal();
double randSignedDecimal();

double sigmoid(double input);

#endif /* JHConstants_h */
