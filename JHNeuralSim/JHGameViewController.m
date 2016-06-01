//
//  JHGameViewController.m
//  JHNeuralSim
//
//  Created by Chance Hudson on 5/17/16.
//  Copyright © 2016 Chance Hudson. All rights reserved.
//

#import "JHGameViewController.h"
#import "GameScene.h"
#import "JHGameNode.h"
#import <Bolts/Bolts.h>

@interface JHGameViewController ()

@property (assign) IBOutlet SKView *skView;
@property (nonatomic, strong) IBOutlet NSTextField *titleField;
@property (nonatomic, strong) IBOutlet NSTextView *textView;
@property (nonatomic, strong) IBOutlet NSTextField *activityField;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *activityIndicator;
@property (nonatomic, strong) IBOutlet NSButton *saveButton;
@property (nonatomic, strong) IBOutlet NSButton *pauseButton;
@property (nonatomic, strong) IBOutlet NSButton *drawCheckbox;
@property (nonatomic, strong) IBOutlet NSTextField *minStepTimeField;

@property (nonatomic, strong) JHGame *game;
@property (nonatomic, strong) JHGameNode *gameNode;

- (IBAction)pause:(NSButton*)sender;
- (IBAction)save:(id)sender;

@end

@implementation JHGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];

    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = SKSceneScaleModeAspectFit;

    [self.skView presentScene:scene];

    /* Sprite Kit applies additional optimizations to improve rendering performance */
    self.skView.ignoresSiblingOrder = YES;
    
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    
    JHGeneticAlgorithm *a = [self loadGeneticAlgorithm];
    self.game = [[JHGame alloc] initWithGeneticAlgorithm:a];
    self.game.observer = self;
    self.game.evolver.observer = self;
    [self.game beginSimulating];
    
    self.gameNode = [[JHGameNode alloc] initWithSize:(Vec2){50,50} tileSize:CGSizeMake(15, 15)];
    [scene addChild:self.gameNode];
}

- (JHGeneticAlgorithm*)loadGeneticAlgorithm {
    return nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"NeuralNetworks"] stringByAppendingPathComponent:@"SavedGenetics"];
    BOOL directory;
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory] || ! directory) {
        return nil;
    }
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    int x = 0;
    while ([files containsObject:[NSString stringWithFormat:@"%i", x]]) {
        x++;
    }
    x--;
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", x]];
    NSString *filePath = [path stringByAppendingPathComponent:@"GeneticData"];
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

- (void)addStringToTextView:(NSString*)string {
    if (self.drawCheckbox.state == NSOnState) {
        [self.textView setString:[NSString stringWithFormat:@"%@\n%@", self.textView.string, string]];
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.string.length, 0)];
    }
}

- (void)game:(JHGame *)game calculatedFitnessForNetwork:(JHNeuralNetwork *)network {
    [self addStringToTextView:[NSString stringWithFormat:@"Fitness: %.1f", network.fitness]];
}

- (void)geneticAlgorithmWillBeginBreeding:(JHGeneticAlgorithm *)algorithm {
    self.activityField.hidden = NO;
    [self.activityIndicator startAnimation:nil];
    [self addStringToTextView:[NSString stringWithFormat:@"Average fitness: %.1f", algorithm.averageFitness]];
    [self addStringToTextView:[NSString stringWithFormat:@"Breeding..."]];
}

- (void)geneticAlgorithmDidFinishedBreeding:(JHGeneticAlgorithm *)algorithm {
    self.activityField.hidden = YES;
    [self.activityIndicator stopAnimation:nil];
    [self.titleField setStringValue:[NSString stringWithFormat:@"Generation %lu", (unsigned long)algorithm.currentGeneration]];
}

- (void)gameEpochPassed:(JHGame *)game {
}

- (void)gameBoardUpdated:(JHGame *)game {
    if (self.drawCheckbox.state == NSOnState) {
        [self.gameNode gameBoardUpdated:game];
    }
}

- (IBAction)drawChanged:(NSButton*)sender {
    if (sender.state == NSOffState) {
        self.game.minStepTime = 0.0;
    } else {
        self.game.minStepTime = self.minStepTimeField.stringValue.doubleValue;
    }
}

- (IBAction)minStepTimeChanged:(NSTextField*)sender {
    if (self.drawCheckbox.state == NSOnState) {
        [self.game setMinStepTime:[sender.stringValue doubleValue]];
    }
}

- (void)pause:(NSButton *)sender {
    BOOL paused = ! [sender.title isEqualToString:@"Pause"];
    if ( ! paused) {
        sender.title = @"Pausing...";
        sender.enabled = NO;
        [self.activityIndicator startAnimation:nil];
        [[self.game stopSimulating] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
            sender.title = @"Resume";
            [self.activityIndicator stopAnimation:nil];
            sender.enabled = YES;
            self.saveButton.enabled = YES;
            return nil;
        }];
    } else {
        self.saveButton.enabled = NO;
        sender.title = @"Pause";
        [self.game beginSimulating];
    }
}

- (void)save:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"NeuralNetworks"] stringByAppendingPathComponent:@"SavedGenetics"];
    NSError *error;
    BOOL directory;
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory] || ! directory) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    int x = 0;
    while ([files containsObject:[NSString stringWithFormat:@"%i", x]]) {
        x++;
    }
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", x]];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    [self.activityIndicator startAnimation:nil];
    self.saveButton.enabled = NO;
    self.pauseButton.enabled = NO;
    [[self.game.evolver saveToFile:[path stringByAppendingPathComponent:@"GeneticData"]] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        [self.activityIndicator stopAnimation:nil];
        self.pauseButton.enabled = YES;
        self.saveButton.enabled = YES;
        return nil;
    }];
}

@end
