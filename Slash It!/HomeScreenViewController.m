//
//  HomeScreenViewController.m
//  Screen
//
//  Created by iceking on 3/8/14.
//  Copyright (c) 2014 iceking. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "EnvironmentScreenViewController.h"
#import "SettingScreenViewController.h"
#import "GameCenterScreenViewController.h"

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController


- (IBAction)gamecenter:(id)sender {
    
    GameCenterScreenViewController *gameCenterScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameCenterScreenViewController"];
    [self.navigationController pushViewController:gameCenterScreenViewController animated:NO];
}

- (IBAction)settingbutton:(id)sender {
    
    SettingScreenViewController *settingScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingScreenViewController"];
    [self.navigationController pushViewController:settingScreenViewController animated:NO];
}


- (IBAction)playbutton:(id)sender {
    
    EnvironmentScreenViewController *environmentScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EnvironmentScreenViewController"];
    [self.navigationController pushViewController:environmentScreenViewController animated:NO];
    
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
