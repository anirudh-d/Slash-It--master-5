//
//  EnvironmentScreenViewController.m
//  Screen
//
//  Created by iceking on 3/8/14.
//  Copyright (c) 2014 iceking. All rights reserved.
//

#import "EnvironmentScreenViewController.h"
#import "HomeScreenViewController.h"
#import "LevelScreenViewController.h"
#import "SettingScreenViewController.h"

@interface EnvironmentScreenViewController ()

@end

@implementation EnvironmentScreenViewController


- (IBAction)settingbutton:(id)sender {
    SettingScreenViewController *settingScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingScreenViewController"];
    
    [self.navigationController pushViewController:settingScreenViewController animated:YES];

}
- (IBAction)spacebutton:(id)sender {
    /*
    LevelScreenViewController *levelScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LevelScreenViewController"];
    levelScreenViewController.environmentName= @"space";
    [self.navigationController pushViewController:levelScreenViewController animated:YES];
     */
    
}

- (IBAction)waterbutton:(id)sender {
    LevelScreenViewController *levelScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LevelScreenViewController"];
    levelScreenViewController.environmentName= @"water";
    [self.navigationController pushViewController:levelScreenViewController animated:YES];
    
    
}

- (IBAction)earthbutton:(id)sender {
    LevelScreenViewController *levelScreenViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LevelScreenViewController"];
    levelScreenViewController.environmentName= @"earth";
    
    [self.navigationController pushViewController:levelScreenViewController animated:YES];
    
    
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
- (void)viewDidLoad{
    [super viewDidLoad];
    UIImage *backgroundImage = [UIImage imageNamed:@"background.jpg"];
    UIImageView *backgroundImageView=[[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view insertSubview:backgroundImageView atIndex:0];
    backgroundImageView.image=backgroundImage;
	// Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
