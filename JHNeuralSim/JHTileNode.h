//
//  JHTileNode.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JHSpriteNode.h"

typedef enum JHTileType {
    JHTileTypeGrass,
    JHTileTypeDirt
} JHTileType;

@interface JHTileNode : JHSpriteNode

+ (instancetype)tileWithType:(JHTileType)type;
@property (nonatomic, assign) JHTileType tileType;

@end
