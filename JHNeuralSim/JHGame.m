//
//  JHGame.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/12/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHGame.h"

@interface JHGame () {
    int **_visitedTiles;
}

@property (strong) JHGameBoard *board;

@property (assign) BOOL simulating;
@property (assign) int currentBestScore;
@property (assign) Vec2 playerPosition;
@property (assign) Vec2 lastPosition;
@property (assign) Vec2 *initialPlayerPositions;
@property (strong) NSMutableArray *initialBoards;
@property (assign) int currentInitialPlayerPosition;
@property (assign) NSUInteger lastStepCount;

@end

@implementation JHGame

- (instancetype)init {
    return [self initWithGeneticAlgorithm:nil];
}

- (instancetype)initWithGeneticAlgorithm:(JHGeneticAlgorithm*)algorithm {
    if ((self = [super init])) {
        _minStepTime = 0.02;
        _boardSize = (Vec2){.x = 50, .y = 50};
        _initialPlayerPositions = calloc(10, sizeof(Vec2));
        _initialBoards = [NSMutableArray new];
        _visitedTiles = calloc(_boardSize.x, sizeof(int*));
        for (int x = 0; x < _boardSize.x; x++ ) {
            _visitedTiles[x] = calloc(_boardSize.y, sizeof(int));
        }
        _board = [[JHGameBoard alloc] initWithWidth:_boardSize.x height:_boardSize.y];
        _evolver = algorithm;
        if ( ! _evolver) {
            _evolver = [[JHGeneticAlgorithm alloc] initWithLayerStructure:@[@9, @170, @1] generationSize:30 mutationRate:0.15 crossoverRate:0.8 maxMutation:0.2];
        }
        [_evolver setCoach:self];
    }
    return self;
}

- (BOOL)visitedTileAtX:(int)x Y:(int)y {
    return _visitedTiles[x][y] != 0;
}

- (void)resetBoard {
    self.lastPosition = (Vec2){.x=-1,.y=-1};
    _playerPosition.x = _initialPlayerPositions[_currentInitialPlayerPosition].x;
    _playerPosition.y = _initialPlayerPositions[_currentInitialPlayerPosition].y;
    self.board = self.initialBoards[_currentInitialPlayerPosition];
    for (int x = 0; x < self.boardSize.x; x++) {
        memset(_visitedTiles[x], 0, self.boardSize.y*sizeof(int));
    }
}

- (JHGameBoard*)generateBoard {
    JHGameBoard *board = [[JHGameBoard alloc] initWithWidth:50 height:50];
    [board setAllTiles:JHGameBoardTileTypeUnknown];
    [board setBorderTile:JHGameBoardTileTypeWall];
    for (int x = 1; x < board.boardWidth-1; x++) {
        for (int y = 1; y < board.boardHeight-1; y++) {
            if (randDecimal() < 0.2f) {
                [board setTile:JHGameBoardTileTypeWall atX:x Y:y];
            }
        }
    }
    return board;
}

- (Vec2)currentCakeIndexPath {
    Vec2 v;
    NSIndexPath *indexPath = [self.board indexPathsForTile:JHGameBoardTileTypeCake].firstObject;
    v.x = (int)[indexPath indexAtPosition:0];
    v.y = (int)[indexPath indexAtPosition:1];
    return v;
}

- (void)network:(JHNeuralNetwork *)network generatedOutput:(double*)output stepNumber:(NSInteger)stepNumber {
    __block BOOL canContinue = NO;
    if (self.minStepTime == 0.0) {
        canContinue = YES;
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.minStepTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            canContinue = YES;
        });
    }
    double sum = output[0];
    Vec2 moveDirection = (Vec2){.x=0,.y=0};
    if (sum < 0.25) {
        moveDirection.x = -1;
    } else if (sum >= 0.25 && sum < 0.5) {
        moveDirection.y = 1;
    } else if (sum >= 0.5 && sum < 0.75) {
        moveDirection.x = 1;
    } else {
        moveDirection.y = -1;
    }
    Vec2 player = self.playerPosition;
    player.x += moveDirection.x;
    player.x = MIN(MAX(0, player.x), self.board.boardWidth-1);
    player.y += moveDirection.y;
    player.y = MIN(MAX(0, player.y), self.board.boardHeight-1);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.observer gameBoardUpdated:self];
    });
    if ([self.board tileAtX:player.x Y:player.y] == JHGameBoardTileTypeWall) {
        self.currentInitialPlayerPosition++;
        self.lastStepCount = stepNumber;
        if (self.currentInitialPlayerPosition == 10) {
            self.lastStepCount = 0;
            self.currentInitialPlayerPosition = 0;
            network.fitness = MAX(network.fitness,0);
            [network finishCalculatingFitness];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.observer game:self calculatedFitnessForNetwork:network];
            });
        }
        [self resetBoard];
        while (!canContinue){}
        return;
    } else if (_visitedTiles[player.x][player.y] == 0) {
        network.fitness += 1;
    }
    if ((self.lastPosition.x == player.x && self.lastPosition.y == player.y) || _visitedTiles[player.x][player.y] > 10) {
        self.currentInitialPlayerPosition++;
        self.lastStepCount = stepNumber;
        if (self.currentInitialPlayerPosition == 10) {
            self.lastStepCount = 0;
            self.currentInitialPlayerPosition = 0;
            network.fitness = MAX(network.fitness,0);
            [network finishCalculatingFitness];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.observer game:self calculatedFitnessForNetwork:network];
            });
        }
        [self resetBoard];
        while (!canContinue){}
        return;
    }
    self.lastPosition = self.playerPosition;
    self.playerPosition = player;
    _visitedTiles[player.x][player.y]++;
    while (!canContinue){}
}

- (double*)inputForNetwork:(JHNeuralNetwork *)network stepNumber:(NSInteger)stepNumber {
    return [self.board dataRelativeToX:self.playerPosition.x Y:self.playerPosition.y outputLength:9];
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
    [[[[BFTask taskWithResult:nil] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        [self.initialBoards removeAllObjects];
        for (int x = 0; x < 10; x++) {
            JHGameBoard *b = [self generateBoard];
            [self.initialBoards addObject:b];
            Vec2 p;
            do {
                p = (Vec2){.x = arc4random_uniform(b.boardWidth-1)+1, .y = arc4random_uniform(b.boardWidth-1)+1};
            } while ([b tileAtX:p.x Y:p.y] == JHGameBoardTileTypeWall);
            _initialPlayerPositions[x].x = p.x;
            _initialPlayerPositions[x].y = p.y;
        }
        self.currentInitialPlayerPosition = 0;
        [self resetBoard];
        if ( ! [self.evolver hasCalculatedFitnessesForGeneration]) {
            return [self.evolver calculateFitnesses];
        } else {
            return nil;
        }
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        if ( ! self.simulating) {
            return nil;
        }
        return [self.evolver epoch];
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        [self.observer gameEpochPassed:self];
        [self _beginSimulating];
        return nil;
    }];
}

- (BFTask*)stopSimulating {
    return [[BFTask taskWithResult:nil] continueWithExecutor:[BFExecutor executorWithDispatchQueue:geneticQueue()] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        self.simulating = NO;
        return @(self.simulating);
    }];
}

- (void)simulateNetwork:(JHNeuralNetwork*)network {
    
}

@end
