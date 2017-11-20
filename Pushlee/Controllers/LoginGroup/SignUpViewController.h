//
//  SignUpViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-22.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    UIPickerView *genderPicker;
}

@property (strong, nonatomic) IBOutlet UITextField *m_txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *m_txtLastName;
@property (strong, nonatomic) IBOutlet UITextField *m_txtGender;
@property (strong, nonatomic) IBOutlet UITextField *m_txtAge;
@property (strong, nonatomic) IBOutlet UITextField *m_txtZipCode;
@property (strong, nonatomic) IBOutlet UITextField *m_txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *m_txtPassword;
@property (strong, nonatomic) IBOutlet UILabel *m_lblError;

- (IBAction)onClickStartSaving:(id)sender;
- (IBAction)onClickBack:(id)sender;

@end
