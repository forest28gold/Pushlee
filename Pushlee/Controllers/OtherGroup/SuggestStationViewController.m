//
//  SuggestStationViewController.m
//  Pushlee
//
//  Created by AppsCreationTech  on 06/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "SuggestStationViewController.h"

@interface SuggestStationViewController ()

@end

@implementation SuggestStationViewController

@synthesize m_txtStationCity;
@synthesize m_txtStationName;
@synthesize m_txtStationState;

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
    
    [self setBarButton];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [m_txtStationState setText:@""];
    [m_txtStationCity setText:@""];
    [m_txtStationName setText:@""];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setBarButton {
    
    [self.navigationItem setTitle:@"Pushlee"];
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


#pragma mark - Show AlertView

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - IBActions

- (IBAction)onClickBtnSuggest:(id)sender {
    NSString *strCity = [[m_txtStationCity.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *strState = [[m_txtStationState.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *strName = [[m_txtStationName.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (g_isReachability == NO){
        [self showAlertViewWithMessage:@"No Internet Connection Available"];
    }
    else {
        if (strCity.length > 0 && strState.length > 0 && strName.length > 0)
        {
            [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
            
            [[ParseService sharedInstance] sendSuggestionStation:strCity
                                                           State:strState
                                                         Station:strName
                                                          Result:^(NSString *strError) {
                                                              if(strError == nil)
                                                              {
                                                                  [SVProgressHUD dismiss];
                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you"
                                                                                                                  message:@"Your suggestion has been received. Thank you!"
                                                                                                                 delegate:self
                                                                                                        cancelButtonTitle:@"OK"
                                                                                                        otherButtonTitles:nil, nil];
                                                                  [alert show];
                                                              }
                                                              else
                                                              {
                                                                  [SVProgressHUD showErrorWithStatus:strError];
                                                              }
                                                          }];
        }
        else {
            [self showAlertViewWithMessage:@"Please enter all values"];
        }
    }
}

@end

