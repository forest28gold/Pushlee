//
//  ProfileViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-26.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize m_imgProfile;
@synthesize m_txtAge;
@synthesize m_txtFirstName;
@synthesize m_txtGender;
@synthesize m_txtLastName;

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

    bSetProfileImg = NO;
    
    [self setBarButton];

    m_imgProfile.layer.masksToBounds = m_imgProfile.frame.size.width / 2;
    m_imgProfile.layer.cornerRadius = m_imgProfile.frame.size.width / 2;
    m_imgProfile.layer.borderColor = [UIColor darkGrayColor].CGColor;
    m_imgProfile.layer.borderWidth = 2.0f;
    
    [self loadProfile];
    [self initGenderPicker];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)loadProfile {  
    m_txtFirstName.text = g_myInfo.strUserFirstName;
    m_txtLastName.text = g_myInfo.strUserLastName;
    m_txtGender.text = g_myInfo.strUserGender;
    m_txtAge.text = [NSString stringWithFormat:@"%d", [g_myInfo.nUserAge intValue]];
    [m_imgProfile setImageWithURL:[NSURL URLWithString:g_myInfo.strUserPhotoUrl]];
}

- (void)initGenderPicker {
    genderPicker = [[UIPickerView alloc] init];
    genderPicker.delegate = self;
    
    [m_txtGender setInputView:genderPicker];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"Male";
    }
    
    return @"Female";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row == 0) {
        [m_txtGender setText:@"Male"];
    } else {
        [m_txtGender setText:@"Female"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBarButton {
    [self.navigationItem setTitle:@"Profile"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"common_bkBar"] forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"Roboto-Light" size:20],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    UIButton *menueButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 6, 30.0f, 30.0f)];
    [menueButton setBackgroundImage:[UIImage imageNamed:@"common_iconDisableMenu"] forState:UIControlStateNormal];
    [menueButton setBackgroundImage:[UIImage imageNamed:@"common_iconEnableMenu"] forState:UIControlStateSelected];
    [menueButton addTarget:self action:@selector(onLeftMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menueButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menueButton];
    self.navigationItem.leftBarButtonItem = menueButtonItem;
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame: CGRectMake(260.0f, 6, 30.0f, 30.0f)];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"common_iconDisableShare"] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"common_iconEnableShare"] forState:UIControlStateSelected];
    [shareButton addTarget:self action:@selector(onRightMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    self.navigationItem.rightBarButtonItem = shareButtonItem;
}

-(void)onRightMenuClicked:(id)sender{
    
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

-(void)onLeftMenuClicked:(id)sender{
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
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

- (IBAction)onClickAddProfileImage:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    if (image != nil) {
        bSetProfileImg = YES;
        [m_imgProfile setImage:image];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)onClickSave:(id)sender {

    [SVProgressHUD showWithStatus:@"Saving..." maskType:SVProgressHUDMaskTypeGradient];
    
    if (bSetProfileImg) {
        [[ParseService sharedInstance] uploadProfileImageFile:m_imgProfile.image
                                                       Result:^(NSString *strError) {
                                                           if(strError == nil)
                                                           {
                                                               [SVProgressHUD showWithStatus:@"Saving..."];
                                                               [[ParseService sharedInstance] updateProfileWithFirstName:m_txtFirstName.text
                                                                                                                LastName:m_txtLastName.text
                                                                                                                     Age:m_txtAge.text
                                                                                                                  Gender:m_txtGender.text
                                                                                                                  Result:^(NSString *strError) {
                                                                                                                      if(strError == nil)
                                                                                                                      {
                                                                                                                          [SVProgressHUD dismiss];
                                                                                                                          [self showProfileUpdatedMessage];
                                                                                                                          [self performSelectorOnMainThread:@selector(popUpViewController) withObject:nil waitUntilDone:NO];
                                                                                                                      }
                                                                                                                      else
                                                                                                                      {
                                                                                                                          [SVProgressHUD showErrorWithStatus:strError];
                                                                                                                          [self showProfileFailedMessage];
                                                                                                                      }
                                                                                                                  }];
                                                           }
                                                           else
                                                           {
                                                               [SVProgressHUD showErrorWithStatus:strError];
                                                           }
                                                       }
                                                      Persent:^(int nPercent) {
                                                          [SVProgressHUD showProgress:(float)nPercent / 100.f status:@"Uploading..." maskType:SVProgressHUDMaskTypeGradient];
                                                      }];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"Saving..."];
        [[ParseService sharedInstance] updateProfileWithFirstName:m_txtFirstName.text
                                                         LastName:m_txtLastName.text
                                                              Age:m_txtAge.text
                                                           Gender:m_txtGender.text
                                                           Result:^(NSString *strError) {
                                                               if(strError == nil)
                                                               {
                                                                   [SVProgressHUD dismiss];
                                                                   [self showProfileUpdatedMessage];
                                                                   [self performSelectorOnMainThread:@selector(popUpViewController) withObject:nil waitUntilDone:NO];
                                                               }
                                                               else
                                                               {
                                                                   [SVProgressHUD showErrorWithStatus:strError];
                                                                   [self showProfileFailedMessage];
                                                               }
                                                           }];
    }
}

- (void)popUpViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showProfileUpdatedMessage
{
    [[[UIAlertView alloc] initWithTitle:@""
                                message:@"Saved"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

- (void)showProfileFailedMessage
{
    [[[UIAlertView alloc] initWithTitle:@"Oops!"
                                message:@"Saving Failed"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

-(BOOL) prefersStatusBarHidden
{
    return NO;
}

@end
