//
//  AppDelegate.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/8/16.
//  Copyright (c) 2016 Chance Hudson. All rights reserved.
//

#import "AppDelegate.h"
#import "GameScene.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];

    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    /* Sprite Kit applies additional optimizations to improve rendering performance */
    self.skView.ignoresSiblingOrder = YES;
    
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    
    JHGame *game = [JHGame new];
    game.observer = self;
    [game beginSimulating];
}

- (void)gameEpochPassed:(JHGame *)game {
    NSLog(@"Game epoch passed: %li", game.evolver.currentGeneration);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
