//
//  ViewController.m
//  Slash It!
//
//  Created by Savan on 3/14/14.
//  Copyright (c) 2014 Savan Rupani. All rights reserved.
//

#import "ViewController.h"
#import "EnvironmentScreenViewController.h"
#import "SettingScreenViewController.h"
#import "HomeScreenViewController.h"
#import "ViewController.h"
#import "GameCenterScreenViewController.h"
#import "LevelScreenViewController.h"
#import "Audio.h"


@implementation ViewController{
    UIImage *backgroundImage;
    UIImageView *backgroundImageView;
}


int status = 0;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    
    // Create and configure the scene.
    _scene = [GameScene sceneWithSize:skView.bounds.size];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
    _scene.levelName = self.levelName;
    _scene.environmentName = self.environmentName;
    [_scene draw];
    // Present the scene.
    [skView presentScene:_scene];
    [[Audio sharedInstance] playBackgroundMusic:@"background.mp3"];
    
    __weak ViewController *weakSelf = self;
    _scene.goBackToLevel = ^(){
        [weakSelf goBacktoLevel];
    };
    
    _scene.restartLevel = ^(){
        [weakSelf restartLevel];
    };
    
    _scene.changeScore = ^(float score){
        [weakSelf changeScoreLbl:score];
    };
    
    
    
    
    [_lbl1 setText:@"Win: "];
    [_lbl2 setText:@"Cur: "];
    [_lbl1 setTextColor:[UIColor redColor]];
    [_lbl2 setTextColor:[UIColor redColor]];
    [_winScoreLbl setTextColor:[UIColor redColor]];
    [_currentScorelbl setTextColor:[UIColor redColor]];
    
    
    
        NSString *plistLevel = [[NSBundle mainBundle] pathForResource:@"Level-score" ofType:@"plist"];
        
        NSDictionary *environmentDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistLevel];
        NSDictionary *levelDictionary = [[NSDictionary alloc] initWithDictionary:[environmentDictionary objectForKey:self.environmentName]];
        
        _winningScore = [[levelDictionary objectForKey:@"level1"] intValue];
        
    _scene.winningScore = _winningScore;
    [_winScoreLbl setText:[NSString stringWithFormat:@"%d",_winningScore]];
    [_currentScorelbl setText:@"100"];
    
}


/*
 In response to a swipe gesture, show the image view appropriately then move the image view in the direction of the swipe as it fades out.
 */


- (IBAction)resumebutton:(id)sender {
    
    [backgroundImageView removeFromSuperview];
    if (status == 1) {
        _scene.paused = NO;
        status = 0;
        self.homebutton.hidden = YES;
        self.resumebutton.hidden = YES;
        self.environmentbutton.hidden = YES;
        self.settingbutton.hidden = YES;
        self.gamecenterbutton.hidden = YES;
        self.pausebutton.hidden = NO;
        
        [[Audio sharedInstance] playBackgroundMusic:@"background.mp3"];
        
    }
}

- (IBAction)environmentbutton:(id)sender{
    
    status = 0;
    EnvironmentScreenViewController *environmentScreenViewController = [[EnvironmentScreenViewController alloc] init];
    environmentScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EnvironmentScreenViewController"];
    
    [self presentViewController:environmentScreenViewController animated:YES completion:Nil];
}

- (IBAction)homebutton:(id)sender {
    status = 0;
    HomeScreenViewController *homeScreenViewController = [[HomeScreenViewController alloc] init];
    homeScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeScreenViewController"];
    
    [self presentViewController:homeScreenViewController animated:YES completion:Nil];
}


- (IBAction)settingbutton:(id)sender {
    /*
    status = 0;
    SettingScreenViewController *settingScreenViewController = [[SettingScreenViewController alloc] init];
    settingScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingScreenViewController"];
    
    [self presentViewController:settingScreenViewController animated:YES completion:Nil];
     */
}

- (IBAction)gamecenterbutton:(id)sender {
    /*
    status = 0;
    GameCenterScreenViewController *gameCenterScreenViewController = [[GameCenterScreenViewController alloc] init];
    gameCenterScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameCenterScreenViewController"];
    
    [self presentViewController:gameCenterScreenViewController animated:YES completion:Nil];
     */
}



- (IBAction)pausebutton:(id)sender {
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Game Menu" message:@"What would you like to do?" delegate:self cancelButtonTitle:@"Resume level" otherButtonTitles:@"Restart", nil, nil];
    [alertView addButtonWithTitle:@"Levels"];
    [[Audio sharedInstance] pauseBackgroundMusic];
    
    [alertView show];
    _scene.paused = YES;
    
    
    /*
    backgroundImage = [UIImage imageNamed:@"background.jpg"];
    backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:backgroundImageView atIndex:0];
    backgroundImageView.image = backgroundImage;
    if (status == 0) {
        scene.paused = YES;
        status = 1;
        self.homebutton.hidden = NO;
        self.resumebutton.hidden = NO;
        self.environmentbutton.hidden = NO;
        self.settingbutton.hidden = NO;
        self.gamecenterbutton.hidden = NO;
        self.pausebutton.hidden = YES;
        [[Audio sharedInstance] pauseBackgroundMusic];
        
        
    }
    */
    //SKView *spriteView = (SKView *) self.view;
    //SKScene *currentScene = [spriteView scene];
    
    /*
     [newScene.userData setObject:[currentScene.userData objectForKey:@"score"] forKey:@"score"];
     [spriteView presentScene:newScene];
     */
}


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //NSLog(@"Got something %@ , %d",[alertView buttonTitleAtIndex:buttonIndex], buttonIndex);
    _scene.paused = NO;
    [[Audio sharedInstance] pauseBackgroundMusic];
    
    if (buttonIndex == 2) {
        /*  Level */
        [self.navigationController popViewControllerAnimated:YES];

    }else if(buttonIndex == 1){
        /* Restart */
        [_scene removeFromParent];
        [self viewDidLoad];
    }else if(buttonIndex == 0){
        
        /* Resume */
        [[Audio sharedInstance] playBackgroundMusic:@"background.mp3"];
        
    }else{
        
    }
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)goBacktoLevel{
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)restartLevel{
    [_scene removeFromParent];
    [self viewDidLoad];
}

-(void)changeScoreLbl:(float)scr{
    [_currentScorelbl setText:[NSString stringWithFormat:@"%d",(int)scr]];
}

@end
