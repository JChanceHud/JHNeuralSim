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

@interface JHGame ()

@property (assign) BOOL simulating;
@property (assign) int currentBestScore;

@end

@implementation JHGame

- (instancetype)init {
    if ((self = [super init])) {
        _board = [[JHGameBoard alloc] initWithWidth:50 height:50];
        [self resetBoard];
        _evolver = [[JHGeneticAlgorithm alloc] initWithLayerStructure:@[@2500, @3000, @1] generationSize:10 mutationRate:0.2 crossoverRate:0.7 maxMutation:0.2];
        [_evolver setCoach:self];
    }
    return self;
}

- (void)resetBoard {
    [self.board setAllTiles:JHGameBoardTileTypeGrass];
    int playerX = arc4random() % self.board.boardWidth;
    int playerY = arc4random() % self.board.boardHeight;
    [self.board setTile:JHGameBoardTileTypePlayer atX:playerX Y:playerY];
    
    int cakeX = arc4random() % self.board.boardWidth;
    int cakeY = arc4random() % self.board.boardHeight;
    [self.board setTile:JHGameBoardTileTypeCake atX:cakeX Y:cakeY];
    self.currentBestScore = abs(playerX - cakeX) + abs(playerY - cakeY);
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
    NSInteger moveValue = MIN(MAX(0,floor(output[0]/0.25)), 3);
    Vec2 player = [self currentPlayerIndexPath];
    Vec2 oldPlayer = player;
    Vec2 cake = [self currentCakeIndexPath];
    switch (moveValue) {
        case 0:
            player.x = MAX(0, player.x-1);
            break;
        case 1:
            player.y = MAX(0, player.y-1);
            break;
        case 2:
            player.x = MIN(self.board.boardWidth-1, player.x+1);
            break;
        case 3:
            player.y = MIN(self.board.boardHeight-1, player.y+1);
        default:
            break;
    }
    if ((cake.x == player.x && cake.y == player.y) || stepNumber > 500) {
        network.fitness = (double)self.currentBestScore / (double)stepNumber;
        NSLog(@"%f", network.fitness);
        [network finishCalculatingFitness];
        [self resetBoard];
    }
    if (oldPlayer.x == player.x && oldPlayer.y == player.y) {
        network.fitness = 0;
        [network finishCalculatingFitness];
        NSLog(@"%f", network.fitness);
        [self resetBoard];
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
