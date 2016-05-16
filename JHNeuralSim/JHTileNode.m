//
//  JHTileNode.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHTileNode.h"

@implementation JHTileNode

+ (instancetype)tileWithType:(JHGameBoardTileType)type {
    JHTileNode *n = [self new];
    n.tileType = type;
    return n;
}

- (void)setTileType:(JHGameBoardTileType)tileType {
    _tileType = tileType;
    if (tileType == JHGameBoardTileTypeGrass) {
        self.color = [NSColor greenColor];
    } else if (tileType == JHGameBoardTileTypePlayer) {
        self.color = [NSColor whiteColor];
    } else if (tileType == JHGameBoardTileTypeCake) {
        self.color = [NSColor redColor];
    } else {
        self.color = [NSColor blackColor];
    }
}

@end
