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
#import <Bolts/Bolts.h>

dispatch_queue_t geneticQueue() {
    static dispatch_queue_t _geneticQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _geneticQueue = dispatch_queue_create("com.JHNeuralSim.JHGeneticAlgorithm", DISPATCH_QUEUE_SERIAL);
    });
    return _geneticQueue;
}

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.genomes = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"genomes"]];
        self.currentGeneration = [aDecoder decodeIntegerForKey:@"currentGeneration"];
        self.mutationRate = [aDecoder decodeDoubleForKey:@"mutationRate"];
        self.crossoverRate = [aDecoder decodeDoubleForKey:@"crossoverRate"];
        self.maxMutation = [aDecoder decodeDoubleForKey:@"maxMutation"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.genomes forKey:@"genomes"];
    [aCoder encodeInteger:self.currentGeneration forKey:@"currentGeneration"];
    [aCoder encodeDouble:self.mutationRate forKey:@"mutationRate"];
    [aCoder encodeDouble:self.crossoverRate forKey:@"crossoverRate"];
    [aCoder encodeDouble:self.maxMutation forKey:@"maxMutation"];
}

- (BFTask*)saveToFile:(NSString*)file {
    return [[BFTask taskWithResult:nil] continueWithExecutor:[BFExecutor executorWithDispatchQueue:geneticQueue()] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return @([NSKeyedArchiver archiveRootObject:self toFile:file]);
    }];
}

- (void)setCoach:(id <JHNeuralNetworkCoach>)coach {
    for (JHNeuralNetwork *network in self.genomes) {
        network.coach = coach;
    }
}

- (BFTask*)calculateFitnesses {
    return [[BFTask taskWithResult:nil] continueWithExecutor:[BFExecutor executorWithDispatchQueue:geneticQueue()] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        for (JHNeuralNetwork *network in self.genomes) {
            [network calculateFitness];
        }
        _hasCalculatedFitnessesForGeneration = YES;
        return self;
    }];
}

- (BFTask*)epoch {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.observer geneticAlgorithmWillBeginBreeding:self];
    });
    return [[BFTask taskWithResult:nil] continueWithExecutor:[BFExecutor executorWithDispatchQueue:geneticQueue()] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        _averageFitness = [self totalFitness] / (double)self.genomes.count;
        [self sortGenomes];
        NSMutableArray *bestGenomes = [NSMutableArray new];
        int countToInsert = 2;
        int topGenomeCount = 3;
        if (topGenomeCount > self.genomes.count) {
            topGenomeCount = (int)self.genomes.count;
        }
        for (int x = (int)self.genomes.count-1; x > self.genomes.count - 1 - topGenomeCount; --x) {
            for (int y = 0; y < countToInsert; y++) {
                [bestGenomes addObject:self.genomes[x]];
            }
        }
        
        int insertedCount = (int)bestGenomes.count;
        [self.genomes addObjectsFromArray:bestGenomes];
        [self sortGenomes];
        [self.genomes removeObjectsInRange:NSMakeRange(0, insertedCount)];
        NSMutableArray *newGenomes = [NSMutableArray new];
        while (newGenomes.count < self.genomes.count) {
            JHNeuralNetwork *mom = [self semirandomGenomeExcluding:nil];
            JHNeuralNetwork *dad = [self semirandomGenomeExcluding:mom];
            
            NSArray <JHNeuralNetwork*> *children = [mom mateWith:dad];
            [newGenomes addObjectsFromArray:children];
            if (newGenomes.count > self.genomes.count) {
                [newGenomes removeLastObject];
            }
        }
        self.genomes = newGenomes;
        self.currentGeneration++;
        _hasCalculatedFitnessesForGeneration = NO;
        [self sortGenomes];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.observer geneticAlgorithmDidFinishedBreeding:self];
        });
        return self;
    }];
}

- (JHNeuralNetwork*)semirandomGenomeExcluding:(id)g {
    double randFitness = randDecimal() * [self totalFitness];
    double fitnessSoFar = 0;
    for (int x = 0; x < self.genomes.count; x++ ) {
        JHNeuralNetwork *genome = self.genomes[x];
        fitnessSoFar += genome.fitness;
        if (fitnessSoFar >= randFitness && genome != g) {
            return genome;
        } else if (fitnessSoFar >= randFitness && x == self.genomes.count-1) {
            return self.genomes[x-1];
        }
    }
    id genome = g;
    while (genome == g) {
        genome = self.genomes[(int)floor(randDecimal()*self.genomes.count)];
    }
    return genome;
}

- (double)totalFitness {
    double total = 0;
    for (JHNeuralNetwork *genome in self.genomes) {
        total += genome.fitness;
    }
    return total;
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

