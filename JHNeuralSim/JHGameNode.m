//
//  JHGameNode.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHGameNode.h"
#import "JHTileNode.h"
#import "JHGameBoard.h"

@interface JHGameNode ()

@property (nonatomic, strong) JHGame *game;

@end

@implementation JHGameNode

- (instancetype)initWithSize:(Vec2)size tileSize:(CGSize)tileSize {
    if ((self = [super init])) {
        self.tiles = [NSMutableArray new];
        for (int x = 0; x < size.x; x++) {
            [self.tiles addObject:[NSMutableArray new]];
            for (int y = 0; y < size.y; y++) {
                JHTileNode *tile = [JHTileNode tileWithType:JHGameBoardTileTypeGrass];
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

- (void)gameEpochPassed:(JHGame*)game {
    NSLog(@"Game epoch passed: %li", game.evolver.currentGeneration);
}

- (void)gameBoardUpdated:(JHGame*)game {
    for (int x = 0; x < game.board.boardWidth; x++) {
        for (int y = 0; y < game.board.boardHeight; y++) {
            [self.tiles[x][y] setTileType:[game.board tileAtX:x Y:y]];
            if ([game visitedTileAtX:x Y:y]) {
                [self.tiles[x][y] setTileType:JHGameBoardTileTypeCake];
            }
        }
    }
}

@end
