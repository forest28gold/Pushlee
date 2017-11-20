//
//  ForgotPwdViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-24.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPwdViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *m_txtEmail;
@property (strong, nonatomic) IBOutlet UILabel *m_lblError;

- (IBAction)onClickSendPwdReset:(id)sender;
- (IBAction)onClickBtnBack:(id)sender;

@end
