//
//  JHGame.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/12/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHGame.h"

dispatch_queue_t gameQueue() {
    static dispatch_queue_t _gameQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gameQueue = dispatch_queue_create("com.JHNeuralSim.JHGame", DISPATCH_QUEUE_SERIAL);
    });
    return _gameQueue;
}

@interface JHGame () {
    Vec2 *_visitedTiles;
}

@property (assign) BOOL simulating;
@property (assign) int currentBestScore;

@end

@implementation JHGame

- (instancetype)init {
    if ((self = [super init])) {
        _visitedTiles = calloc(100, sizeof(Vec2));
        _board = [[JHGameBoard alloc] initWithWidth:50 height:50];
        [self resetBoard];
        _evolver = [[JHGeneticAlgorithm alloc] initWithLayerStructure:@[@2500, @3000, @3000, @3000, @3] generationSize:10 mutationRate:0.2 crossoverRate:0.7 maxMutation:0.2];
        [_evolver setCoach:self];
    }
    return self;
}

- (void)resetBoard {
    [self.board setAllTiles:JHGameBoardTileTypeGrass];
    int playerX = (arc4random() % (self.board.boardWidth-2)) + 1;
    int playerY = (arc4random() % (self.board.boardHeight-2)) + 1;
    [self.board setTile:JHGameBoardTileTypePlayer atX:25 Y:25];
    [self.board setBorderTile:JHGameBoardTileTypeWall];
    
    for (int x = 0; x < 50; x++) {
        int cakeX = arc4random() % self.board.boardWidth;
        int cakeY = arc4random() % self.board.boardHeight;
        [self.board setTile:JHGameBoardTileTypeCake atX:cakeX Y:cakeY];
    }
    for (int x = 0; x< 100; x++) {
        _visitedTiles[x] = (Vec2){.x = 25,.y = 25};
    }
//    self.currentBestScore = abs(playerX - cakeX) + abs(playerY - cakeY);
}

- (Vec2)currentPlayerIndexPath {
    Vec2 v;
    NSIndexPath *indexPath = [self.board indexPathsForTile:JHGameBoardTileTypePlayer].firstObject;
    v.x = (int)[indexPath indexAtPosition:0];
    v.y = (int)[indexPath indexAtPosition:1];
    return v;
}

- (Vec2)currentCakeIndexPath {
    Vec2 v;
    NSIndexPath *indexPath = [self.board indexPathsForTile:JHGameBoardTileTypeCake].firstObject;
    v.x = (int)[indexPath indexAtPosition:0];
    v.y = (int)[indexPath indexAtPosition:1];
    return v;
}

- (void)network:(JHNeuralNetwork *)network generatedOutput:(double*)output stepNumber:(NSInteger)stepNumber {
    Vec2 moveDirection;
    moveDirection.x = output[0]>0.5?1:-1;
    moveDirection.y = output[1]>0.5?1:-1;
    if (output[2] > 0.5) {
        moveDirection.x = 0;
    } else {
        moveDirection.y = 0;
    }
    Vec2 player = [self currentPlayerIndexPath];
    Vec2 oldPlayer = player;
    player.x += moveDirection.x;
    player.x = MIN(MAX(0, player.x), self.board.boardWidth-1);
    player.y += moveDirection.y;
    player.y = MIN(MAX(0, player.y), self.board.boardHeight-1);
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.observer gameBoardUpdated:self];
    });
    BOOL visited = NO;
    for (int x = 0; x < stepNumber; x++) {
        if (_visitedTiles[x].x == player.x && _visitedTiles[x].y == player.y) {
            visited = YES;
            break;
        }
    }
    if ( ! visited) {
        network.fitness += 15;
    }
    _visitedTiles[stepNumber] = player;
    if ([self.board tileAtX:player.x Y:player.y] == JHGameBoardTileTypeWall) {
        network.fitness -= 200;
        network.fitness = MAX(network.fitness,0);
        [network finishCalculatingFitness];
        NSLog(@"Fitness: %f", network.fitness);
        [self resetBoard];
        return;
    } else if ([self.board tileAtX:player.x Y:player.y] == JHGameBoardTileTypeCake) {
        [self.board setTile:JHGameBoardTileTypeGrass atX:player.x Y:player.y];
        network.fitness += 100;
    }
    if (stepNumber >= 99) {
        NSLog(@"Fitness: %f", network.fitness);
        [network finishCalculatingFitness];
        [self resetBoard];
        return;
    }
    [self.board swapTileAtPosition:oldPlayer withTile:player];
}

- (double*)inputForNetwork:(JHNeuralNetwork *)network stepNumber:(NSInteger)stepNumber {
    Vec2 player = [self currentPlayerIndexPath];
    return [self.board dataRelativeToX:player.x Y:player.y];
}

- (void)beginSimulating {
    if (self.simulating) {
        return;
    }
    self.simulating = YES;
    [self _beginSimulating];
}

- (void)_beginSimulating {
    if ( ! self.simulating) {
        return;
    }
    [[[BFTask taskWithResult:nil] continueWithExecutor:[BFExecutor executorWithDispatchQueue:gameQueue()] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        if ( ! self.simulating) {
            return nil;
        }
        [self.evolver epoch];
        return nil;
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        [self.observer gameEpochPassed:self];
        [self _beginSimulating];
        return nil;
    }];
}

- (BFTask*)stopSimulating {
    return [[BFTask taskWithResult:nil] continueWithExecutor:[BFExecutor executorWithDispatchQueue:gameQueue()] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        self.simulating = NO;
        return @(self.simulating);
    }];
}

- (void)simulateNetwork:(JHNeuralNetwork*)network {
    
}

@end
