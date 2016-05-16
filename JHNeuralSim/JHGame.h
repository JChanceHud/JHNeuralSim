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

@end

@interface JHGame : NSObject <JHNeuralNetworkCoach>

@property (nonatomic, readonly) JHGameBoard *board;
@property (nonatomic, readonly) JHGeneticAlgorithm *evolver;

@property (nonatomic, weak) id <JHGameObserver> observer;

- (void)beginSimulating;
- (BFTask*)stopSimulating;

- (void)simulateNetwork:(JHNeuralNetwork*)network;

@end
