//
//  JHNeuralNetwork.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHNeuralNetwork.h"
#import "JHConstants.h"

#import <Accelerate/Accelerate.h>

@interface JHNeuralNetwork () {
    double *_inputBuffer;
    double *_weights;
}

@property (nonatomic, assign) NSUInteger inputCount;
@property (nonatomic, assign) NSUInteger outputCount;
@property (nonatomic, assign) NSUInteger weightCount;

@property (nonatomic, strong) NSMutableArray <JHNeuronLayer *> *layers;

@property (nonatomic, assign) BOOL calculatingFitness;

@end

@implementation JHNeuralNetwork

- (instancetype)initWithLayerStructure:(NSArray <NSNumber *> *)layerStructure {
    if ((self = [super init])) {
        int weightCount = 0;
        for (int x = 0; x < layerStructure.count; x++) {
            if (x == 0) {
                weightCount += layerStructure[x].integerValue * 2; // account for the bias
            } else {
                weightCount += (layerStructure[x-1].integerValue + 1 /* the bias */) * layerStructure[x].integerValue;
            }
        }
        self.weightCount = weightCount;
        _weights = calloc(weightCount, sizeof(double));
        self.inputCount = layerStructure.firstObject.integerValue;
        _inputBuffer = calloc(self.inputCount+1, sizeof(double));
        _inputBuffer[self.inputCount] = -1.0;
        self.outputCount = layerStructure.lastObject.integerValue;
        self.layers = [NSMutableArray new];
        int offset = 0;
        for (int x = 0; x < layerStructure.count; x++) {
            JHNeuronLayer *layer;
            if (x == 0) {
                layer = [[JHNeuronLayer alloc] initInitialLayerWithNeuronCount:layerStructure[x].unsignedIntegerValue weightPtr:_weights offset:offset];
            } else {
                layer = [[JHNeuronLayer alloc] initWithInputCount:layerStructure[x-1].unsignedIntegerValue neuronCount:layerStructure[x].unsignedIntegerValue weightPtr:_weights offset:offset];
            }
            [self.layers addObject:layer];
            offset += layer.weightCount;
        }
    }
    return self;
}

- (instancetype)initWithLayerStructure:(NSArray<NSNumber *> *)layerStructure
                               weights:(double*)weights {
    if ((self = [self initWithLayerStructure:layerStructure])) {
        cblas_dcopy((int)self.weightCount, weights, 1, _weights, 1);
    }
    return self;
}

- (instancetype)initWithData:(NSData*)data {
    NSDictionary *dataDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSArray *layerStructure = [dataDict objectForKey:@"layerStructure"];
    NSData *weights = [dataDict objectForKey:@"weightData"];
    if ( ! layerStructure || ! weights) {
        NSLog(@"Invalid data provided");
        return nil;
    }
    if ((self = [self initWithLayerStructure:layerStructure weights:(double*)weights.bytes])) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSArray *layerStructure = [aDecoder decodeObjectForKey:@"layerStructure"];
    double *bytes = (double*)[(NSData*)[aDecoder decodeObjectForKey:@"weightData"] bytes];
    if ((self = [self initWithLayerStructure:layerStructure weights:bytes])) {
        self.mutationRate = [aDecoder decodeDoubleForKey:@"mutationRate"];
        self.crossoverRate = [aDecoder decodeDoubleForKey:@"crossoverRate"];
        self.maxMutation = [aDecoder decodeDoubleForKey:@"maxMutation"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSMutableArray *layerStructure = [NSMutableArray new];
    for (JHNeuronLayer *layer in self.layers) {
        [layerStructure addObject:@(layer.neuronCount)];
    }
    [aCoder encodeObject:layerStructure forKey:@"layerStructure"];
    NSData *weightData = [[NSData alloc] initWithBytes:_weights length:(self.weightCount * sizeof(double))];
    [aCoder encodeObject:weightData forKey:@"weightData"];
    [aCoder encodeDouble:self.mutationRate forKey:@"mutationRate"];
    [aCoder encodeDouble:self.crossoverRate forKey:@"crossoverRate"];
    [aCoder encodeDouble:self.maxMutation forKey:@"maxMutation"];
}

- (double*)processInputs:(double*)inputs {
    double *lastOutput = inputs;
    for (int x = 0; x < self.layers.count; x++) {
        lastOutput = [self.layers[x] outputsForInputs:lastOutput];
    }
    return lastOutput;
}

- (NSArray <NSNumber *> *)weights {
    NSMutableArray *weights = [NSMutableArray new];
    for (int x = 0; x < weights.count; x++) {
        [weights addObject:@(_weights[x])];
    }
    return weights;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    NSMutableArray *layerStructure = [NSMutableArray new];
    for (JHNeuronLayer *layer in self.layers) {
        [layerStructure addObject:@(layer.neuronCount)];
    }
    JHNeuralNetwork *network = [[JHNeuralNetwork alloc] initWithLayerStructure:layerStructure weights:_weights];
    network.coach = self.coach;
    network.mutationRate = self.mutationRate;
    network.maxMutation = self.maxMutation;
    network.crossoverRate = self.crossoverRate;
    network.minStepTime = self.minStepTime;
    return network;
}

- (void)mutate {
    double *mutationValues = calloc(self.weightCount, sizeof(double));
    for (int x = 0; x < self.weightCount; x++) {
        if (randDecimal() > self.mutationRate) continue;
        mutationValues[x] = randSignedDecimal()*self.maxMutation;
    }
    cblas_daxpy((int)self.weightCount, 1.0, mutationValues, 1, _weights, 1);
    free(mutationValues);
}

- (NSArray <JHNeuralNetwork *>*)mateWith:(JHNeuralNetwork *)network {
    if (randDecimal() > self.crossoverRate) {
        return @[[self copy], [network copy]];
    }
    JHNeuralNetwork *child1 = [self copy];
    JHNeuralNetwork *child2 = [network copy];
    
    double *child1Weights = child1->_weights;
    double *child2Weights = child2->_weights;
    
    double *networkWeights = network->_weights;
    
    int crossoverPoint = floor(randDecimal() * (self.weights.count-1));
    cblas_dcopy(crossoverPoint, networkWeights, 1, child1Weights, 1);
    cblas_dcopy(crossoverPoint, _weights, 1, child2Weights, 1);
    cblas_dcopy((int)self.weightCount-crossoverPoint, &networkWeights[crossoverPoint], 1, &child2Weights[crossoverPoint], 1);
    cblas_dcopy((int)self.weightCount-crossoverPoint, &_weights[crossoverPoint], 1, &child1Weights[crossoverPoint], 1);
//    for (int x = 0; x < crossoverPoint; x++) {
//        child1Weights[x] = networkWeights[x];
//        child2Weights[x] = _weights[x];
//    }
//    for (int x = crossoverPoint; x < self.weightCount; x++) {
//        child2Weights[x] = networkWeights[x];
//        child1Weights[x] = _weights[x];
//    }
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
        cblas_dcopy((int)self.inputCount, currentInput, 1, _inputBuffer, 1);
        [self.coach network:self generatedOutput:[self processInputs:_inputBuffer] stepNumber:stepNumber];
        stepNumber++;
        currentInput = [self.coach inputForNetwork:self stepNumber:stepNumber];
    }
}


- (void)dealloc {
    free(_weights);
    free(_inputBuffer);
}

@end

@interface JHNeuronLayer () {
    double *_weights;
    double *_outputSpace;
}

@property (nonatomic, assign) NSUInteger inputCount;
@property (nonatomic, strong) NSMutableArray <JHNeuron *> *neurons;

@end

@implementation JHNeuronLayer : NSObject

- (instancetype)initInitialLayerWithNeuronCount:(NSUInteger)neuronCount weightPtr:(double*)ptr offset:(int)offset {
    if ((self = [super init])) {
        _weights = &ptr[offset];
        self.inputCount = neuronCount;
        self.neurons = [NSMutableArray new];
        for (int x = 0; x < neuronCount; x++) {
            JHNeuron *neuron = [[JHNeuron alloc] initWithInputCount:1 weightPtr:ptr offset:offset];
            [self.neurons addObject:neuron];
            offset += neuron.weightCount;
        }
        _initialLayer = YES;
        _outputSpace = calloc(neuronCount, sizeof(double));
    }
    return self;
}

- (instancetype)initWithInputCount:(NSUInteger)inputCount
                       neuronCount:(NSUInteger)neuronCount
                         weightPtr:(double*)ptr
                            offset:(int)offset {
    if ((self = [super init])) {
        _weights = &ptr[offset];
        self.inputCount = inputCount;
        self.neurons = [NSMutableArray new];
        for (int x = 0; x < neuronCount; x++) {
            JHNeuron *neuron = [[JHNeuron alloc] initWithInputCount:inputCount weightPtr:ptr offset:offset];
            [self.neurons addObject:neuron];
            offset += neuron.weightCount;
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
        cblas_dgemv(CblasRowMajor, CblasNoTrans, (int)self.neuronCount, (int)self.neurons.firstObject.weightCount, 1.0, _weights, (int)self.neurons.firstObject.weightCount, inputs, 1, 0.0, _outputSpace, 1);
        for (int x = 0; x < self.neuronCount; x++) {
            _outputSpace[x] = sigmoid(_outputSpace[x]);
        }
    }
    return _outputSpace;
}

- (NSUInteger)weightCount {
    NSUInteger count = 0;
    for (JHNeuron *neuron in self.neurons) {
        count += neuron.weightCount;
    }
    return count;
}
    
- (NSUInteger)neuronCount {
    return self.neurons.count;
}

- (void)dealloc {
    free(_outputSpace);
}

@end

@interface JHNeuron () {
    double *_weights;
    double *_outputSpace;
}

@property (nonatomic, assign) NSUInteger inputCount;

@end

@implementation JHNeuron : NSObject

- (instancetype)initWithInputCount:(NSUInteger)inputCount weightPtr:(double*)ptr offset:(int)offset {
    if ((self = [super init])) {
        self.inputCount = inputCount;
        _weights = &ptr[offset];
        for (int x = 0; x < inputCount+1; x++) {
            _weights[x] = randSignedDecimal();
        }
        _outputSpace = calloc(inputCount+1, sizeof(double));
    }
    return self;
}

- (NSUInteger)weightCount {
    return self.inputCount+1;
}

- (double)bias {
    return _weights[_inputCount];
}

- (double)singleActivationValue:(double)input {
    double activation = 0;
    activation += input * _weights[0];
    //add ni the biad
    activation += -1.0*_weights[self.inputCount];
    return activation;
}

- (double)singleSigmoidValue:(double)input {
    return (1.0/
            (1.0 + exp(-1.0 * ([self singleActivationValue:input]/1.0))));
}

- (void)dealloc {
    free(_outputSpace);
}

@end
