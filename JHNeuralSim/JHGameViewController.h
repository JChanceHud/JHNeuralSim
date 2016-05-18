//
//  JHGameViewController.h
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/17/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import "JHGame.h"
#import "JHGeneticAlgorithm.h"

@interface JHGameViewController : NSViewController <JHGameObserver, JHGeneticAlgorithmObserver>

@end
