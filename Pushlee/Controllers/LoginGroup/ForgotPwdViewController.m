//
//  ForgotPwdViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-24.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "ForgotPwdViewController.h"

@interface ForgotPwdViewController ()

@end

@implementation ForgotPwdViewController

@synthesize m_txtEmail;
@synthesize m_lblError;

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
    m_txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address"
                                                                       attributes:@{
                                                                                    NSForegroundColorAttributeName:[UIColor grayColor]
                                                                                    }];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)onClickSendPwdReset:(id)sender {
	m_lblError.hidden = YES;
	
	if (m_txtEmail.text.length < 1) {
		[m_lblError setText:@"Please, input your email"];
		m_lblError.hidden = NO;
		return;
	}
	
    [SVProgressHUD showWithStatus:@"Sending..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] requestPasswordWithUserName:m_txtEmail.text
                                                        Result:^(NSString *strError) {
                                                            if(strError == nil)
                                                                [SVProgressHUD showSuccessWithStatus:@"Your password sent to your email"];
                                                            else
                                                                [SVProgressHUD showErrorWithStatus:strError];
                                                        }];
	
}

- (IBAction)onClickBtnBack:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
