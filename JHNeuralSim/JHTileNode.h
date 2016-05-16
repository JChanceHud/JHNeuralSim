//
//  JHTileNode.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JHSpriteNode.h"
#import "JHGameBoard.h"

@interface JHTileNode : JHSpriteNode

+ (instancetype)tileWithType:(JHGameBoardTileType)type;
@property (nonatomic, assign) JHGameBoardTileType tileType;

@end
