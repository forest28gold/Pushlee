//
//  SignUpViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-22.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize m_txtEmail;
@synthesize m_txtAge;
@synthesize m_lblError;
@synthesize m_txtFirstName;
@synthesize m_txtGender;
@synthesize m_txtLastName;
@synthesize m_txtPassword;
@synthesize m_txtZipCode;

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

    genderPicker = [[UIPickerView alloc] init];
    genderPicker.delegate = self;
    m_txtGender.delegate = self;
    
    UIColor *color = [UIColor grayColor];
    m_txtFirstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name"
                                                                           attributes:@{
                                                                                        NSForegroundColorAttributeName: color
                                                                                        }];
    m_txtLastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name"
                                                                          attributes:@{
                                                                                       NSForegroundColorAttributeName: color
                                                                                       }];
    m_txtGender.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Gender"
                                                                        attributes:@{
                                                                                     NSForegroundColorAttributeName: color
                                                                                     }];
    [m_txtGender setInputView:genderPicker];
    m_txtAge.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Age"
                                                                     attributes:@{
                                                                                  NSForegroundColorAttributeName: color
                                                                                  }];
    m_txtZipCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Zip Code"
                                                                         attributes:@{
                                                                                      NSForegroundColorAttributeName: color
                                                                                      }];
    m_txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email"
                                                                       attributes:@{
                                                                                    NSForegroundColorAttributeName: color
                                                                                    }];
    m_txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password"
                                                                          attributes:@{
                                                                                       NSForegroundColorAttributeName: color
                                                                                       }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (IBAction)onClickStartSaving:(id)sender {
    m_lblError.hidden = YES;
    
    if (m_txtFirstName.text.length < 1) {
        [m_lblError setText:@"Please, input your first name"];
        m_lblError.hidden = NO;
        return;
    }
    
    if (m_txtLastName.text.length < 1) {
        [m_lblError setText:@"Please, input your last name"];
        m_lblError.hidden = NO;
        return;
    }
    
    if (m_txtGender.text.length < 1) {
        [m_lblError setText:@"Please, input your gender"];
        m_lblError.hidden = NO;
        return;
    }
    
    if (m_txtAge.text.length < 1) {
        [m_lblError setText:@"Please, input your age"];
        m_lblError.hidden = NO;
        return;
    }
    
    if (m_txtZipCode.text.length < 1) {
        [m_lblError setText:@"Please, input your zip code"];
        m_lblError.hidden = NO;
        return;
    }
    
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
    
    UserInfo *userInfo = [[UserInfo alloc] initWithFirstName:m_txtFirstName.text
                                                    LastName:m_txtLastName.text
                                                UserPassword:m_txtPassword.text
                                                   UserEmail:m_txtEmail.text
                                                  UserGender:m_txtGender.text
                                                     UserAge:m_txtAge.text
                                                 UserZipCode:m_txtZipCode.text];
    
    [SVProgressHUD showWithStatus:@"Signing Up..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] signUpWithUserInfo:userInfo
                                               Result:^(NSString *strError) {
                                                   if(strError == nil)
                                                   {
                                                       [SVProgressHUD dismiss];
                                                       [self processAppTransition];
                                                   }
                                                   else
                                                       [SVProgressHUD showErrorWithStatus:strError];
                                               }];
}

- (void)processAppTransition
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_LOGGED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_DEAL_SURVEY]) {
        UINavigationController *ctrl = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:DEAL_SURVEY_NAVIGATION_CONTROLLER];
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
                            [[appDelegate window] setRootViewController:[appDelegate mainVC]];
                            [UIView setAnimationsEnabled:oldState];
                        }
                        completion:nil];
    }
    
}

- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Gender Picker
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    switch (row) {
        case 0:
            title = @"Male";
            break;
            
        case 1:
            title = @"Female";
            break;
            
        default:
            break;
    }
    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            [m_txtGender setText:@"Male"];
            break;
            
        case 1:
            [m_txtGender setText:@"Female"];
            break;
            
        default:
            break;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(textField == m_txtGender
       && [textField.text isEqualToString:@""])
        textField.text = [genderPicker selectedRowInComponent:0] == 0 ? @"Male" : @"Female";
    
}

@end
