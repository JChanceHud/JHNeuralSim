//
//  JHGeneticAlgorithm.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/10/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHNeuralNetwork.h"

@class JHGeneticAlgorithm;
@class BFTask;

@protocol JHGeneticAlgorithmObserver <NSObject>

- (void)geneticAlgorithmWillBeginBreeding:(JHGeneticAlgorithm*)algorithm;
- (void)geneticAlgorithmDidFinishedBreeding:(JHGeneticAlgorithm*)algorithm;

@end

@interface JHGeneticAlgorithm : NSObject <NSCoding>

- (instancetype)initWithGenomes:(NSArray <JHNeuralNetwork *> *)genomes
                   mutationRate:(double)mutationRate
                  crossoverRate:(double)crossoverRate
                    maxMutation:(double)maxMutation;

- (instancetype)initWithLayerStructure:(NSArray <NSNumber*>*)structure
                        generationSize:(NSInteger)generationSize
                          mutationRate:(double)mutationRate
                         crossoverRate:(double)crossoverRate
                           maxMutation:(double)maxMutation;

@property (nonatomic, readonly) NSUInteger currentGeneration;
@property (nonatomic, readonly) double averageFitness;

@property (nonatomic, weak) id <JHGeneticAlgorithmObserver> observer;

@property (nonatomic, readonly) BOOL hasCalculatedFitnessesForGeneration;
- (void)calculateFitnesses;
- (void)epoch;
- (void)setCoach:(id <JHNeuralNetworkCoach>)coach;

- (BFTask*)saveToFile:(NSString*)file;

@end
