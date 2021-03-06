//
//  JHGame.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/12/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHGameBoard.h"
#import "JHNeuralNetwork.h"
#import "JHGeneticAlgorithm.h"
#import <Bolts/Bolts.h>
#import "JHConstants.h"

@class JHGame;

@protocol JHGameObserver <NSObject>

- (void)gameEpochPassed:(JHGame*)game;
- (void)gameBoardUpdated:(JHGame*)game;
- (void)game:(JHGame*)game calculatedFitnessForNetwork:(JHNeuralNetwork*)network;

@end

@interface JHGame : NSObject <JHNeuralNetworkCoach>

- (instancetype)initWithGeneticAlgorithm:(JHGeneticAlgorithm*)algorithm;

@property (readonly) Vec2 boardSize;
@property (readonly) JHGameBoard *board;
@property (nonatomic, readonly) JHGeneticAlgorithm *evolver;

@property (assign) double minStepTime;

@property (nonatomic, weak) id <JHGameObserver> observer;

- (BOOL)visitedTileAtX:(int)x Y:(int)y;

- (void)beginSimulating;
- (BFTask*)stopSimulating;

- (void)simulateNetwork:(JHNeuralNetwork*)network;

@end
