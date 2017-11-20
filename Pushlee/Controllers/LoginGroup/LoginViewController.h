//
//  LoginViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-21.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITextField *m_txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *m_txtPassword;
@property (strong, nonatomic) IBOutlet UILabel *m_lblError;
@property (strong, nonatomic) IBOutlet UIView *m_viewForgotPwd;

- (IBAction)onClickBtnLogin:(id)sender;
- (IBAction)onClickFBLogin:(id)sender;

@end
