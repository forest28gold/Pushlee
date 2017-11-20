//
//  WalkthroughViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-25.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "WalkthroughViewController.h"

#define WALK_THROUGH_COUNT      8

@interface WalkthroughViewController ()

@end

@implementation WalkthroughViewController

@synthesize m_sclMain;
@synthesize m_btnStart;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    int width = m_sclMain.frame.size.width;
    int posX = 0;
    CGRect frame = m_sclMain.frame;
    
    for (int nIndex = 0; nIndex < WALK_THROUGH_COUNT; nIndex ++, posX += width) {
        NSString *imgName = [NSString stringWithFormat:@"screen_%d", nIndex + 1];
        frame.origin.x = posX;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
        [imgView setImage:[UIImage imageNamed:imgName]];
        [m_sclMain insertSubview:imgView belowSubview:m_btnStart];
    }
    
    posX -= width;
    [m_btnStart setFrame:CGRectMake(posX + 93, 467, 152, 40)];
    
    m_sclMain.contentSize = CGSizeMake(width * WALK_THROUGH_COUNT, frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (IBAction)onClickBtnStart:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_FIRST_RUN])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_FIRST_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UINavigationController *ctrl = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:LOGIN_NAVIGATION_CONTROLLER];
        [UIView transitionWithView:[appDelegate window]
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^(void)
                        {
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            [[appDelegate window] setRootViewController:ctrl];
                            [UIView setAnimationsEnabled:oldState];
                        }
                        completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end


