//
//  JHGeneticAlgorithm.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/10/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHNeuralNetwork.h"

@interface JHGeneticAlgorithm : NSObject

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

- (void)epoch;
- (void)setCoach:(id <JHNeuralNetworkCoach>)coach;

@end
