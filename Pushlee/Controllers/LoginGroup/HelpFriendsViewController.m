//
//  HelpFriendsViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-26.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "HelpFriendsViewController.h"

@interface HelpFriendsViewController ()

@end

@implementation HelpFriendsViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)onClickNoThanks:(id)sender {
    if([self presentingViewController] != nil){
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        [UIView transitionWithView:[appDelegate window]
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^(void) {
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            [[appDelegate window] setRootViewController:g_sideMenuController];
                            [UIView setAnimationsEnabled:oldState];
                        }
                        completion:nil];

    }
}

@end
