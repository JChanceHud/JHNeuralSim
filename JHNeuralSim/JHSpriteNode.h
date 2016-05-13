//
//  JHSpriteNode.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JHConstants.h"

@interface JHSpriteNode : SKSpriteNode

@property (nonatomic, assign) CGSize tileSize;
@property (nonatomic, assign) Vec2 tilePosition;

@end
