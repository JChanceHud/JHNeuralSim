//
//  JHGameBoard.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/12/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHGameBoard.h"

@interface JHGameBoard () {
    int **_board;
    double *_dataBuffer;
}

@end

@implementation JHGameBoard

- (instancetype)initWithWidth:(int)width height:(int)height {
    if ((self = [super init])) {
        _board = calloc(width, sizeof(int*));
        for (int x = 0; x < width; x++) {
            _board[x] = calloc(height, sizeof(int));
        }
        _boardWidth = width;
        _boardHeight = height;
        _dataBuffer = calloc(width*height, sizeof(double));
        [self randomize];
    }
    return self;
}

- (NSArray <NSIndexPath*> *)indexPathsForTile:(JHGameBoardTileType)tile {
    NSMutableArray *paths = [NSMutableArray new];
    for (int x = 0; x < self.boardWidth; x++) {
        for (int y = 0; y < self.boardHeight; y++) {
            if (_board[x][y] == tile) {
                [paths addObject:[[NSIndexPath indexPathWithIndex:x] indexPathByAddingIndex:y]];
            }
        }
    }
    return paths;
}

- (JHGameBoardTileType)tileAtX:(int)x Y:(int)y {
    return _board[x][y];
}

- (void)swapTileAtPosition:(Vec2)a withTile:(Vec2)b {
    int tile = _board[a.x][a.y];
    int tile2 = _board[b.x][b.y];
    _board[a.x][a.y] = tile2;
    _board[b.x][b.y] = tile;
}

- (void)setTile:(JHGameBoardTileType)tile atX:(int)x Y:(int)y {
    NSParameterAssert(x >= 0 && x < self.boardWidth);
    NSParameterAssert(y >= 0 && y < self.boardHeight);
    _board[x][y] = tile;
}

- (void)setBorderTile:(JHGameBoardTileType)tile {
    int x = 1;
    int y = 0;
    int xDelta = 1;
    int yDelta = 0;
    while (x != 0 || y != 0) {
        _board[x][y] = tile;
        if (x == self.boardWidth-1 && y == 0) {
            xDelta = 0;
            yDelta = 1;
        } else if (y == self.boardHeight-1 && x == self.boardWidth-1) {
            xDelta = -1;
            yDelta = 0;
        } else if (y == self.boardHeight-1 && x == 0) {
            yDelta = -1;
            xDelta = 0;
        }
        x += xDelta;
        y += yDelta;
    }
}

- (void)setAllTiles:(JHGameBoardTileType)tileType {
    for (int x = 0; x < self.boardWidth; x++) {
        for (int y = 0; y < self.boardHeight; y++) {
            _board[x][y] = tileType;
        }
    }
}

- (void)randomize {
    for (int x = 0; x < self.boardWidth; x++) {
        for (int y = 0; y < self.boardHeight; y++) {
            _board[x][y] = (int)(arc4random() % TILE_TYPE_COUNT);
        }
    }
}

- (NSArray <NSNumber*> *)data {
    NSMutableArray *arr = [NSMutableArray new];
    for (int x = 0; x < self.boardWidth; x++) {
        for (int y = 0; y < self.boardHeight; y++) {
            [arr addObject:@(_board[x][y])];
        }
    }
    return arr;
}

- (double*)dataRelativeToX:(int)x Y:(int)y outputLength:(int)length {
    int index = 0;
    _dataBuffer[index] = _board[x][y];
    index++;
    int currentX = x;
    int currentY = y;
    int currentDistance = 0;
    int currentDirection = 0;
    // 0 = right, 1 = down, 2 = left, 3 = up
    while (1) {
        if (currentDistance > 25 || index > self.boardHeight*self.boardWidth || index >= length) {
            break;
        }
        if (currentX == x && currentY <= y) {
            currentDistance++;
            currentY--;
        }
        if ((currentX >= 0 && currentX < self.boardWidth) && (currentY >= 0 && currentY < self.boardHeight)) {
            _dataBuffer[index] = _board[currentX][currentY];
            index++;
        } else {
            _dataBuffer[index] = JHGameBoardTileTypeUnknown;
            index++;
        }
        if (abs(currentX - x) >= currentDistance && abs(currentY - y) >= currentDistance) {
            currentDirection = (currentDirection + 1) % 4;
        }
        currentX += currentDirection==0?1:0 + currentDirection==2?-1:0;
        currentY += currentDirection==1?1:0 + currentDirection==3?-1:0;
    }
    return _dataBuffer;
}

- (void)dealloc {
    for (int x = 0; x < self.boardHeight; x++) {
        free(_board[x]);
    }
    free(_board);
    free(_dataBuffer);
}

@end
