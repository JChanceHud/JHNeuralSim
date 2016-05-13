//
//  JHSpriteNode.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHSpriteNode.h"

@implementation JHSpriteNode

- (void)setTilePosition:(Vec2)tilePosition {
    _tilePosition = tilePosition;
    self.position = CGPointMake((self.tileSize.width/2.0f)+tilePosition.x*self.tileSize.width,
                                (self.tileSize.height/2.0f)+tilePosition.y*self.tileSize.height);
}

- (void)setTileSize:(CGSize)tileSize {
    _tileSize = tileSize;
    self.size = tileSize;
    [self setTilePosition:_tilePosition];
}

@end
