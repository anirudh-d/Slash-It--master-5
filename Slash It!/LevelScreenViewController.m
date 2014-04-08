//
//  LevelScreenViewController.m
//  Screen
//
//  Created by iceking on 3/8/14.
//  Copyright (c) 2014 iceking. All rights reserved.
//

#import "LevelScreenViewController.h"
#import "EnvironmentScreenViewController.h"
#import "GameCenterScreenViewController.h"
#import "SettingScreenViewController.h"
#import "ViewController.h"

@interface LevelScreenViewController ()

@end

@implementation LevelScreenViewController

-(void)initWithEnvironmentName:(NSString *)env{

    self.environmentName = env;
}
- (IBAction)level1button:(id)sender {
    ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    viewController.levelName= @"level1";
    viewController.environmentName = self.environmentName;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)level2Button:(id)sender {
    /*
    ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    viewController.levelName= @"level2";
    viewController.environmentName = self.environmentName;
    [self.navigationController pushViewController:viewController animated:YES];
    */
}

- (IBAction)level3Button:(id)sender {
    /*
    ViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    viewController.levelName= @"level3";
    viewController.environmentName = self.environmentName;
    [self.navigationController pushViewController:viewController animated:YES];
    */
}

- (IBAction)Backbutton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
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
