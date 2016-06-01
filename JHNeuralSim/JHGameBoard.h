//
//  JHGameBoard.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/12/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHConstants.h"

//const NSInteger JHGameBoardTileTypeUnknown = 0;
//const NSInteger JHGameBoardTileTypeGrass = 50;
//const NSInteger JHGameBoardTileTypeWall = 100;
//
typedef enum : NSInteger {
    JHGameBoardTileTypeUnknown = 0,
    JHGameBoardTileTypeGrass = 50,
    JHGameBoardTileTypePlayer,
    JHGameBoardTileTypeCake,
    JHGameBoardTileTypeWall = 100,
    TILE_TYPE_COUNT
} JHGameBoardTileType;

@interface JHGameBoard : NSObject

@property (nonatomic, readonly) int boardWidth;
@property (nonatomic, readonly) int boardHeight;

- (instancetype)initWithWidth:(int)width height:(int)height;

- (NSArray <NSIndexPath*> *)indexPathsForTile:(JHGameBoardTileType)tile;
- (void)setTile:(JHGameBoardTileType)tile atX:(int)x Y:(int)y;
- (void)setBorderTile:(JHGameBoardTileType)tile;
- (void)setAllTiles:(JHGameBoardTileType)tileType;
- (void)swapTileAtPosition:(Vec2)a withTile:(Vec2)b;
- (void)randomize;
- (JHGameBoardTileType)tileAtX:(int)x Y:(int)y;

- (NSArray <NSNumber*> *)data;
- (double*)dataRelativeToX:(int)x Y:(int)y outputLength:(int)length;

- (int**)board;
- (void)setBoard:(int**)board;

@end
