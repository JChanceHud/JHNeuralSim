//
//  JHNeuralNetwork.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JHNeuralNetwork;

@protocol JHNeuralNetworkCoach <NSObject>

- (void)network:(JHNeuralNetwork*)network generatedOutput:(NSArray <NSNumber *> *)output stepNumber:(NSInteger)stepNumber;
- (NSArray <NSNumber *>*)inputForNetwork:(JHNeuralNetwork*)network stepNumber:(NSInteger)stepNumber;

@end

@interface JHNeuralNetwork : NSObject <NSCopying>

- (instancetype)initWithLayerStructure:(NSArray <NSNumber *> *)layerStructure;
//                           weights:(NSArray <NSNumber *> *)weights;

- (instancetype)initWithLayerStructure:(NSArray<NSNumber *> *)layerStructure
                               weights:(NSArray <NSNumber*> *)weights;

@property (nonatomic, readwrite) NSMutableArray <NSNumber *> *weights;

@property (nonatomic, weak) id <JHNeuralNetworkCoach> coach;
- (void)calculateFitness;
- (void)finishCalculatingFitness;
@property (nonatomic, assign) double fitness;

@property (nonatomic, assign) double mutationRate;
@property (nonatomic, assign) double maxMutation;
@property (nonatomic, assign) double crossoverRate;

- (NSArray <JHNeuralNetwork *>*)mateWith:(id)network;

@end

@interface JHNeuronLayer : NSObject

- (instancetype)initInitialLayerWithNeuronCount:(NSUInteger)neuronCount;
- (instancetype)initWithInputCount:(NSUInteger)inputCount
                       neuronCount:(NSUInteger)neuronCount;
- (NSArray <NSNumber *> *)outputsForInputs:(NSArray <NSNumber *> *)inputs;
@property (nonatomic, readwrite) NSArray <NSNumber *> *weights;
@property (nonatomic, readonly) NSUInteger inputCount;

@property (nonatomic, readonly) BOOL initialLayer;

@end

@interface JHNeuron : NSObject

- (instancetype)initWithInputCount:(NSUInteger)inputCount;
- (double)sigmoidValue:(NSArray <NSNumber *> *)inputs;

@property (nonatomic, strong) NSMutableArray <NSNumber *> *weights;

@end
