//
//  GameScene.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright (c) 2016 Chance Hudson. All rights reserved.
//

#import "GameScene.h"
#import "JHActorNode.h"
#import "JHGameNode.h"

@interface GameScene ()

@property (nonatomic, strong) JHGameNode *gameNode;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    self.gameNode = [[JHGameNode alloc] initWithSize:(Vec2){20,20} tileSize:CGSizeMake(20, 20)];
    [self addChild:self.gameNode];
}

-(void)mouseDown:(NSEvent *)theEvent {
     /* Called when a mouse click occurs */
   
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
