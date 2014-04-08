//
//  ScoreScreenViewController.m
//  Screen
//
//  Created by iceking on 3/8/14.
//  Copyright (c) 2014 iceking. All rights reserved.
//

#import "ScoreScreenViewController.h"
#import "EnvironmentScreenViewController.h"
#import "SettingScreenViewController.h"
#import "HomeScreenViewController.h"
#import "ViewController.h"
#import "GameCenterScreenViewController.h"

@interface ScoreScreenViewController ()

@end

@implementation ScoreScreenViewController



- (IBAction)settingbutton:(id)sender {
    
    SettingScreenViewController *settingScreenViewController = [[SettingScreenViewController alloc] init];
    settingScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingScreenViewController"];
    
    [self presentViewController:settingScreenViewController animated:YES completion:Nil];
}
- (IBAction)gamecenterbutton:(id)sender {
    GameCenterScreenViewController *gameCenterScreenViewController = [[GameCenterScreenViewController alloc] init];
    gameCenterScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameCenterScreenViewController"];
    
    [self presentViewController:gameCenterScreenViewController animated:YES completion:Nil];
}
- (IBAction)homebutton:(id)sender {
    HomeScreenViewController *homeScreenViewController = [[HomeScreenViewController alloc] init];
    homeScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeScreenViewController"];
    
    [self presentViewController:homeScreenViewController animated:YES completion:Nil];
}
- (IBAction)resumegamebutton:(id)sender {
    ViewController *viewController = [[ViewController alloc] init];
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    
    [self presentViewController:viewController animated:YES completion:Nil];
    
}
- (IBAction)environmentbutton:(id)sender {
    
    
    EnvironmentScreenViewController *environmentScreenViewController = [[EnvironmentScreenViewController alloc] init];
    environmentScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EnvironmentScreenViewController"];
    
    [self presentViewController:environmentScreenViewController animated:YES completion:Nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *backgroundImage = [UIImage imageNamed:@"background.jpg"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view insertSubview:backgroundImageView atIndex:0];
    backgroundImageView.image=backgroundImage;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
