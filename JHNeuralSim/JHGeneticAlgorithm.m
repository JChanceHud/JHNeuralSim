//
//  JHGeneticAlgorithm.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/10/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHGeneticAlgorithm.h"
#import "JHConstants.h"
#import "JHNeuralNetwork.h"

@interface JHGeneticAlgorithm ()

@property (nonatomic, assign) NSUInteger currentGeneration;

@property (nonatomic, strong) NSMutableArray <JHNeuralNetwork*> *genomes;
@property (nonatomic, assign) double mutationRate;
@property (nonatomic, assign) double crossoverRate;
@property (nonatomic, assign) double maxMutation;

@end

@implementation JHGeneticAlgorithm

- (instancetype)initWithLayerStructure:(NSArray <NSNumber*>*)structure
                        generationSize:(NSInteger)generationSize
                          mutationRate:(double)mutationRate
                         crossoverRate:(double)crossoverRate
                           maxMutation:(double)maxMutation {
    if ((self = [super init])) {
        self.genomes = [NSMutableArray new];
        for (int x = 0; x < generationSize; x++) {
            JHNeuralNetwork *network = [[JHNeuralNetwork alloc] initWithLayerStructure:structure];
            network.mutationRate = mutationRate;
            network.crossoverRate = crossoverRate;
            network.maxMutation = maxMutation;
            [self.genomes addObject:network];
        }
        self.mutationRate = mutationRate;
        self.crossoverRate = crossoverRate;
        self.maxMutation = maxMutation;
    }
    return self;
}

- (instancetype)initWithGenomes:(NSArray <JHNeuralNetwork *> *)genomes
                   mutationRate:(double)mutationRate
                  crossoverRate:(double)crossoverRate
                    maxMutation:(double)maxMutation {
    if ((self = [super init])) {
        self.genomes = [NSMutableArray arrayWithArray:genomes];
        self.mutationRate = mutationRate;
        self.crossoverRate = crossoverRate;
        self.maxMutation = maxMutation;
    }
    return self;
}

- (void)setCoach:(id <JHNeuralNetworkCoach>)coach {
    for (JHNeuralNetwork *network in self.genomes) {
        network.coach = coach;
    }
}

- (void)epoch {
    for (JHNeuralNetwork *network in self.genomes) {
        [network calculateFitness];
    }
    NSLog(@"Average fitness: %f", [self averageFitness]);
    NSLog(@"Breeding....");
    [self sortGenomes];
    NSMutableArray *bestGenomes = [NSMutableArray new];
    int countToInsert = 2;
    int topGenomeCount = 3;
    if (topGenomeCount > self.genomes.count) {
        topGenomeCount = (int)self.genomes.count;
    }
    for (int x = (int)self.genomes.count-1; x > self.genomes.count - 1 - topGenomeCount; --x) {
        for (int y = 0; y < countToInsert; y++) {
            [bestGenomes addObject:[self.genomes[x] copy]];
        }
    }
    
    int insertedCount = (int)bestGenomes.count;
    [self.genomes addObjectsFromArray:bestGenomes];
    [self sortGenomes];
    [self.genomes removeObjectsInRange:NSMakeRange(0, insertedCount)];
    NSMutableArray *newGenomes = [NSMutableArray new];
    while (newGenomes.count < self.genomes.count) {
        JHNeuralNetwork *mom = [self semirandomGenome];
        JHNeuralNetwork *dad = [self semirandomGenome];
        
        NSArray <JHNeuralNetwork*> *children = [mom mateWith:dad];
        [newGenomes addObjectsFromArray:children];
        if (newGenomes.count > self.genomes.count) {
            [newGenomes removeLastObject];
        }
    }
    self.genomes = newGenomes;
    self.currentGeneration++;
}

- (JHNeuralNetwork*)semirandomGenome {
    double randFitness = randDecimal() * [self totalFitness];
    double fitnessSoFar = 0;
    for (JHNeuralNetwork *genome in self.genomes) {
        fitnessSoFar += genome.fitness;
        if (fitnessSoFar >= randFitness) {
            return genome;
        }
    }
    return self.genomes[(int)floor(randDecimal()*self.genomes.count)];
}

- (double)totalFitness {
    double total = 0;
    for (JHNeuralNetwork *genome in self.genomes) {
        total += genome.fitness;
    }
    return total;
}

- (double)averageFitness {
    return [self totalFitness] / (double)self.genomes.count;
}

- (void)sortGenomes {
    [self.genomes sortUsingComparator:^NSComparisonResult(JHNeuralNetwork *obj1, JHNeuralNetwork *obj2) {
        if (obj1.fitness < obj2.fitness) {
            return NSOrderedAscending;
        } else if (obj1.fitness > obj2.fitness) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

@end

