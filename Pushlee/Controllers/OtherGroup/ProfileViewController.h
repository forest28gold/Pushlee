//
//  ProfileViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-26.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController <UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIPickerView            *genderPicker;
    BOOL                    bSetProfileImg;
}

@property (strong, nonatomic) IBOutlet UIImageView *m_imgProfile;
@property (strong, nonatomic) IBOutlet UITextField *m_txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *m_txtLastName;
@property (strong, nonatomic) IBOutlet UITextField *m_txtGender;
@property (strong, nonatomic) IBOutlet UITextField *m_txtAge;


- (IBAction)onClickAddProfileImage:(id)sender;
- (IBAction)onClickSave:(id)sender;

@end
