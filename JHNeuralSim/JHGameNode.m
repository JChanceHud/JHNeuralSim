//
//  JHGameNode.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHGameNode.h"
#import "JHTileNode.h"

@implementation JHGameNode

- (instancetype)initWithSize:(Vec2)size tileSize:(CGSize)tileSize {
    if ((self = [super init])) {
        self.tiles = [NSMutableArray new];
        for (int x = 0; x < size.x; x++) {
            [self.tiles addObject:[NSMutableArray new]];
            for (int y = 0; y < size.y; y++) {
                JHTileNode *tile = [JHTileNode tileWithType:(x%2?JHTileTypeDirt:JHTileTypeGrass)];
                tile.tilePosition = (Vec2){x,y};
                tile.tileSize = tileSize;
                [self.tiles[x] addObject:tile];
                [self addChild:self.tiles[x][y]];
            }
        }
        self.actors = [NSMutableArray new];
        self.tileSize = tileSize;
    }
    return self;
}

- (void)setTileSize:(CGSize)tileSize {
    _tileSize = tileSize;
    CGFloat currentX = self.tileSize.width/2.0f;
    for (NSMutableArray *a in self.tiles) {
        CGFloat currentY = (-self.size.height/2.0f) + self.tileSize.height/2.0f;
        for (JHTileNode *tile in a) {
            tile.position = CGPointMake(currentX, currentY);
            tile.size = self.tileSize;
            currentY += self.tileSize.height;
        }
        currentX += self.tileSize.width;
    }
}

@end
