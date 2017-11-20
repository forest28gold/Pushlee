//
//  LoginViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-21.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize m_txtEmail;
@synthesize m_txtPassword;
@synthesize m_lblError;
@synthesize m_viewForgotPwd;

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
    
    m_txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address"
                                                                       attributes:@{
                                                                                    NSForegroundColorAttributeName:[UIColor grayColor]
                                                                                    }];
    m_txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password"
                                                                          attributes:@{
                                                                                       NSForegroundColorAttributeName:[UIColor grayColor]
                                                                                       }];
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (IBAction)onClickBtnLogin:(id)sender {
    m_lblError.hidden = YES;
    m_viewForgotPwd.hidden = YES;

    if (m_txtEmail.text.length < 1) {
        [m_lblError setText:@"Please, input your email"];
        m_lblError.hidden = NO;
        return;
    }
    
    if (m_txtPassword.text.length < 1) {
        [m_lblError setText:@"Please, input your password"];
        m_lblError.hidden = NO;
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Logging In..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] loginWithUserName:m_txtEmail.text
                                            Password:m_txtPassword.text
                                              Result:^(NSString *strError) {
                                                  if(strError == nil)
                                                  {
                                                      [SVProgressHUD dismiss];
                                                      [self processAppTransition];
                                                  }
                                                  else
                                                  {
                                                      [SVProgressHUD showErrorWithStatus:strError];
                                                      m_viewForgotPwd.hidden = NO;
                                                  }
                                              }];
}

- (IBAction)onClickFBLogin:(id)sender {

    NSArray *aryPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    [SVProgressHUD showWithStatus:@"Logging In..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] loginWithFacebookPermission:aryPermissions
                                                        Result:^(NSString *strError) {
                                                            if(strError == nil)
                                                            {
                                                                [SVProgressHUD dismiss];
                                                                [self processAppTransition];
                                                            }
                                                            else
                                                            {
                                                                [SVProgressHUD showErrorWithStatus:strError];
                                                            }
                                                        }];
}

- (void)processAppTransition
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_LOGGED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_DEAL_SURVEY]) {
        UINavigationController *ctrl = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:DEAL_SURVEY_NAVIGATION_CONTROLLER];
        [UIView transitionWithView:[appDelegate window]
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^(void){
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            [[appDelegate window] setRootViewController:ctrl];
                            [UIView setAnimationsEnabled:oldState];
                        }
                            completion:nil];
    } else {
        [UIView transitionWithView:[appDelegate window]
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^(void){
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            [[appDelegate window] setRootViewController:g_sideMenuController];
                            [UIView setAnimationsEnabled:oldState];
                        }
                        completion:nil];
    }

}

@end




