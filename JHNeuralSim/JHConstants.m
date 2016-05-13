//
//  JHConstants.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/10/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHConstants.h"

#define ARC4RANDOM_MAX      0x100000000
double randDecimal() {
    return ((double)arc4random() / ARC4RANDOM_MAX);
}

