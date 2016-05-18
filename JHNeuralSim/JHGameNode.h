//
//  JHGameNode.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JHConstants.h"
#import "JHGame.h"

@interface JHGameNode : SKSpriteNode

- (instancetype)initWithSize:(Vec2)size tileSize:(CGSize)tileSize;

@property (nonatomic, strong) NSMutableArray <NSMutableArray *> *tiles;
@property (nonatomic, assign) CGSize tileSize;
@property (nonatomic, strong) NSMutableArray *actors;

- (void)gameBoardUpdated:(JHGame*)game;

@end
