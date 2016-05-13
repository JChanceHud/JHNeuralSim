//
//  AppDelegate.h
//  JHNeuralSim
//

//  Copyright (c) 2016 Chance Hudson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import "JHGame.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, JHGameObserver>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet SKView *skView;

- (void)gameEpochPassed:(JHGame *)game;

@end
