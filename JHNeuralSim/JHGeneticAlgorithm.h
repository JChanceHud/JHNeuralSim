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

dispatch_queue_t geneticQueue();

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

@property (readonly) NSUInteger currentGeneration;
@property (readonly) double averageFitness;

@property (weak) id <JHGeneticAlgorithmObserver> observer;

@property (readonly) BOOL hasCalculatedFitnessesForGeneration;
- (BFTask*)calculateFitnesses;
- (BFTask*)epoch;
- (void)setCoach:(id <JHNeuralNetworkCoach>)coach;

- (BFTask*)saveToFile:(NSString*)file;

@end
