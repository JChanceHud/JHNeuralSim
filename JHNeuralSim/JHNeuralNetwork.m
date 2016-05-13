//
//  JHNeuralNetwork.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHNeuralNetwork.h"
#import "JHConstants.h"

@interface JHNeuralNetwork ()

@property (nonatomic, assign) NSUInteger inputCount;
@property (nonatomic, assign) NSUInteger outputCount;

@property (nonatomic, strong) NSMutableArray <JHNeuronLayer *> *layers;

@property (nonatomic, assign) BOOL calculatingFitness;

@end

@implementation JHNeuralNetwork

- (instancetype)initWithLayerStructure:(NSArray <NSNumber *> *)layerStructure {
//                           weights:(NSArray <NSNumber *> *)weights {
    if ((self = [super init])) {
        self.inputCount = layerStructure.firstObject.integerValue;
        self.outputCount = layerStructure.lastObject.integerValue;
        self.layers = [NSMutableArray new];
        for (int x = 0; x < layerStructure.count; x++) {
            if (x == 0) {
                [self.layers addObject:[[JHNeuronLayer alloc] initInitialLayerWithNeuronCount:layerStructure[x].unsignedIntegerValue]];
            } else {
                [self.layers addObject:[[JHNeuronLayer alloc] initWithInputCount:layerStructure[x-1].unsignedIntegerValue neuronCount:layerStructure[x].unsignedIntegerValue]];
            }
        }
    }
    return self;
}

- (instancetype)initWithLayerStructure:(NSArray<NSNumber *> *)layerStructure
                               weights:(NSArray <NSNumber*> *)weights {
    if ((self = [self initWithLayerStructure:layerStructure])) {
        self.weights = [weights mutableCopy];
    }
    return self;
}

- (double*)processInputs:(double*)inputs {
    double *lastOutput = inputs;
    for (int x = 0; x < self.layers.count; x++) {
        lastOutput = [self.layers[x] outputsForInputs:inputs];
    }
    return lastOutput;
}

- (void)setWeights:(NSArray<NSNumber *> *)weights {
    id copiedWeights = [[NSMutableArray alloc] initWithArray:weights copyItems:YES];
    for (JHNeuronLayer *layer in self.layers) {
        [layer setWeights:copiedWeights];
    }
}

- (NSArray <NSNumber *> *)weights {
    NSMutableArray *weights = [NSMutableArray new];
    for (JHNeuronLayer *layer in self.layers) {
        [weights addObjectsFromArray:layer.weights];
    }
    return weights;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    NSMutableArray *layerStructure = [NSMutableArray new];
    for (JHNeuronLayer *layer in self.layers) {
        [layerStructure addObject:@(layer.inputCount)];
    }
    JHNeuralNetwork *network = [[JHNeuralNetwork alloc] initWithLayerStructure:layerStructure weights:self.weights];
    network.coach = self.coach;
    network.mutationRate = self.mutationRate;
    network.maxMutation = self.maxMutation;
    network.crossoverRate = self.crossoverRate;
    return network;
}

- (void)mutate {
    NSMutableArray *weights = self.weights;
    for (int x = 0; x < self.weights.count; x++) {
        if (randDecimal() > self.mutationRate) continue;
        NSNumber *newWeight = @(((randDecimal()*2)-1)*self.maxMutation + self.weights[x].doubleValue);
        [weights replaceObjectAtIndex:x withObject:newWeight];
    }
    [self setWeights:weights];
}

- (NSArray <JHNeuralNetwork *>*)mateWith:(JHNeuralNetwork *)network {
    if (randDecimal() > self.crossoverRate) {
        return @[[self copy], [network copy]];
    }
    JHNeuralNetwork *child1 = [self copy];
    JHNeuralNetwork *child2 = [network copy];
    
    NSMutableArray *child1Weights = child1.weights;
    NSMutableArray *child2Weights = child2.weights;
    
    NSMutableArray *networkWeights = network.weights;
    NSMutableArray *selfWeights = self.weights;
    
    int crossoverPoint = floor(randDecimal() * (self.weights.count-1));
    for (int x = 0; x < crossoverPoint; x++) {
        [child1Weights replaceObjectAtIndex:x withObject:networkWeights[x]];
        [child2Weights replaceObjectAtIndex:x withObject:selfWeights[x]];
    }
    for (int x = 0; x < crossoverPoint; x++) {
        [child1Weights replaceObjectAtIndex:x withObject:networkWeights[x]];
        [child2Weights replaceObjectAtIndex:x withObject:selfWeights[x]];
    }
    [child1 mutate];
    [child2 mutate];
    return @[child1, child2];
}

- (void)finishCalculatingFitness {
    self.calculatingFitness = NO;
}

- (void)calculateFitness {
    self.calculatingFitness = YES;
    NSInteger stepNumber = 0;
    double *currentInput = [self.coach inputForNetwork:self stepNumber:stepNumber];
    while (currentInput && self.calculatingFitness) {
        [self.coach network:self generatedOutput:[self processInputs:currentInput] stepNumber:stepNumber];
        stepNumber++;
        currentInput = [self.coach inputForNetwork:self stepNumber:stepNumber];
    }
}

@end

@interface JHNeuronLayer () {
    double *_outputSpace;
}

@property (nonatomic, assign) NSUInteger inputCount;
@property (nonatomic, strong) NSMutableArray <JHNeuron *> *neurons;

@end

@implementation JHNeuronLayer : NSObject

- (instancetype)initInitialLayerWithNeuronCount:(NSUInteger)neuronCount {
    if ((self = [super init])) {
        self.inputCount = neuronCount;
        self.neurons = [NSMutableArray new];
        for (int x = 0; x < neuronCount; x++) {
            [self.neurons addObject:[[JHNeuron alloc] initWithInputCount:1]];
        }
        _initialLayer = YES;
        _outputSpace = calloc(neuronCount, sizeof(double));
    }
    return self;
}

- (instancetype)initWithInputCount:(NSUInteger)inputCount
                       neuronCount:(NSUInteger)neuronCount {
    if ((self = [super init])) {
        self.inputCount = inputCount;
        self.neurons = [NSMutableArray new];
        for (int x = 0; x < neuronCount; x++) {
            [self.neurons addObject:[[JHNeuron alloc] initWithInputCount:inputCount]];
        }
        _outputSpace = calloc(neuronCount, sizeof(double));
    }
    return self;
}

- (double*)outputsForInputs:(double*)inputs {
    if (_initialLayer) {
        for (int x = 0; x < self.neurons.count; x++) {
            _outputSpace[x] = [self.neurons[x] singleSigmoidValue:inputs[x]];
        }
    } else {
        for (int x = 0; x < self.neurons.count; x++) {
            _outputSpace[x] = [self.neurons[x] sigmoidValue:inputs];
        }
    }
    return _outputSpace;
}

- (void)setWeights:(NSMutableArray<NSNumber *> *)weights {
    for (JHNeuron *neuron in self.neurons) {
        [neuron setWeights:weights];
    }
}

- (NSArray <NSNumber *> *)weights {
    NSMutableArray *weights = [NSMutableArray new];
    for (JHNeuron *neuron in self.neurons) {
        [weights addObjectsFromArray:neuron.weights];
    }
    return weights;
}

- (void)dealloc {
    free(_outputSpace);
}

@end

@interface JHNeuron () {
    double *_outputSpace;
}

@property (nonatomic, assign) NSUInteger inputCount;

@end

@implementation JHNeuron : NSObject

- (instancetype)initWithInputCount:(NSUInteger)inputCount {
    if ((self = [super init])) {
        self.inputCount = inputCount;
        _weights = [NSMutableArray new];
        for (int x = 0; x < inputCount+1; x++) {
            [self.weights addObject:@(randDecimal())];
        }
        _outputSpace = calloc(inputCount+1, sizeof(double));
    }
    return self;
}

- (void)setWeights:(NSMutableArray<NSNumber *> *)weights {
    NSAssert(_inputCount == weights.count, @"Invalid number of weights");
    NSIndexSet *targetIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.inputCount)];
    _weights = [NSMutableArray arrayWithArray:[weights objectsAtIndexes:targetIndexes]];
    [weights removeObjectsAtIndexes:targetIndexes];
}

- (double)bias {
    return self.weights.lastObject.doubleValue;
}

- (double)activationValue:(double*)inputs {
    double activation = 0;
    for (int x = 0; x < self.inputCount; x++) {
        activation += inputs[x] * self.weights[x].doubleValue;
    }
    //add ni the biad
    activation += -1.0*self.weights.lastObject.doubleValue;
    return activation;
}

- (double)singleActivationValue:(double)input {
    double activation = 0;
    activation += input * self.weights.firstObject.doubleValue;
    //add ni the biad
    activation += -1.0*self.weights.lastObject.doubleValue;
    return activation;
}

- (double)singleSigmoidValue:(double)input {
    return (1.0/
            (1.0 + exp(-1.0 * ([self singleActivationValue:input]/1.0))));
}

- (double)sigmoidValue:(double*)inputs {
    return (1.0/
            (1.0 + exp(-1.0 * ([self activationValue:inputs]/1.0))));
}

- (void)dealloc {
    free(_outputSpace);
}

@end
