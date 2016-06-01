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

- (void)network:(JHNeuralNetwork*)network generatedOutput:(double*)output stepNumber:(NSInteger)stepNumber;
- (double*)inputForNetwork:(JHNeuralNetwork*)network stepNumber:(NSInteger)stepNumber;

@end

@interface JHNeuralNetwork : NSObject <NSCopying, NSCoding>

- (instancetype)initWithLayerStructure:(NSArray <NSNumber *> *)layerStructure;
//                           weights:(NSArray <NSNumber *> *)weights;

- (instancetype)initWithLayerStructure:(NSArray<NSNumber *> *)layerStructure
                               weights:(double*)weights;
- (instancetype)initWithData:(NSData*)data;

@property (nonatomic, readonly) NSMutableArray <NSNumber *> *weights;

@property (nonatomic, weak) id <JHNeuralNetworkCoach> coach;
- (void)calculateFitness;
- (void)finishCalculatingFitness;
@property (nonatomic, assign) double fitness;

@property (nonatomic, assign) double mutationRate;
@property (nonatomic, assign) double maxMutation;
@property (nonatomic, assign) double crossoverRate;

@property (nonatomic, assign) double minStepTime;

- (NSArray <JHNeuralNetwork *>*)mateWith:(id)network;

@end

@interface JHNeuronLayer : NSObject

- (instancetype)initInitialLayerWithNeuronCount:(NSUInteger)neuronCount weightPtr:(double*)ptr offset:(int)offset;
- (instancetype)initWithInputCount:(NSUInteger)inputCount
                       neuronCount:(NSUInteger)neuronCount
                         weightPtr:(double*)ptr
                            offset:(int)offset;
- (double*)outputsForInputs:(double*)inputs;
@property (nonatomic, readonly) NSUInteger inputCount;
@property (nonatomic, readonly) NSUInteger neuronCount;
@property (nonatomic, readonly) NSUInteger weightCount;

@property (nonatomic, readonly) BOOL initialLayer;

@end

@interface JHNeuron : NSObject

- (instancetype)initWithInputCount:(NSUInteger)inputCount weightPtr:(double*)ptr offset:(int)offset;
- (double)singleSigmoidValue:(double)input;

@property (nonatomic, readonly) NSUInteger weightCount;

@end
