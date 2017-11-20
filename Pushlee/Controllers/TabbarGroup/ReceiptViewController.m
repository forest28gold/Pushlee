//
//  ReceiptViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/20/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "ReceiptViewController.h"

@interface ReceiptViewController ()

@end

@implementation ReceiptViewController

#define EMPTY_TEXT_COLOR        [UIColor colorWithRed:128.f / 255.f green:210.f / 255.f blue:212.f / 255.f alpha:1.f]
#define FOCUS_TEXT_COLOR        [UIColor colorWithRed:113.f / 255.f green:191.f / 255.f blue:184.f / 255.f alpha:1.f]
#define HAVE_TEXT_COLOR         [UIColor colorWithRed:102.f / 255.f green:172.f / 255.f blue:166.f / 255.f alpha:1.f]

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setBarButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_FIRST_RECEIPT])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_FIRST_RECEIPT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIViewController *receiptIntroVC = [self.storyboard instantiateViewControllerWithIdentifier:RECEIPT_INTRO_VIEW_CONTROLLER];
        [self presentViewController:receiptIntroVC animated:YES completion:nil];
    }
    else
        [self clearReceiptCode];
}

- (void)clearReceiptCode
{
    for(int nIndex = 10; nIndex < 16; nIndex++)
    {
        UITextField *txtNum = (UITextField *)[self.view viewWithTag:nIndex];
        txtNum.text = @"";
        txtNum.backgroundColor = EMPTY_TEXT_COLOR;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - UIBarButtons

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
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame: CGRectMake(260.0f, 6, 60.0f, 30.0f)];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0]];
    [submitButton addTarget:self action:@selector(onBtnClickSubmit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *submitButtonItem = [[UIBarButtonItem alloc] initWithCustomView:submitButton];
    self.navigationItem.rightBarButtonItem = submitButtonItem;
}

- (void)onLeftMenuClicked:(id)sender
{
    for (int nIndex = 10; nIndex < 16; nIndex++)
    {
        UITextField *txtNum = (UITextField *)[self.view viewWithTag:nIndex];
        [txtNum resignFirstResponder];
    }
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (void)onBtnClickSubmit:(id)sender
{
    if([self validateCode])
    {
        [SVProgressHUD showWithStatus:@"Checking..." maskType:SVProgressHUDMaskTypeGradient];
        [[ParseService sharedInstance] getReceiptInfoWithCode:nCode
                                                       Result:^(Receipt *objReceipt, NSString *strError) {
                                                           if(strError == nil)
                                                           {
                                                               [SVProgressHUD dismiss];
                                                               if([self checkReceiptLimit:objReceipt.nRedemptions.integerValue])
                                                               {
                                                                   int nRandom = arc4random() % 100;
                                                                   NSLog(@"Random probability: %d", nRandom);
                                                                   if(nRandom > objReceipt.nProbability.integerValue)
                                                                   {
                                                                       UIViewController *loserVC = [self.storyboard instantiateViewControllerWithIdentifier:RECEIPT_LOSER_VIEW_CONTROLLER];
                                                                       [self.navigationController pushViewController:loserVC animated:YES];
                                                                   }
                                                                   else
                                                                   {
                                                                       
                                                                       RewardItem* item = [[RewardItem alloc] initWithEmptyObject];
                                                                       item.scratched = NO;
                                                                       item.title = objReceipt.strRewardName;
                                                                       item.description_ = objReceipt.strRewardDescription;
                                                                       item.imageUrl = objReceipt.strRewardImageUrl;
                                                                       item.barcode = objReceipt.strRewardBarcode;
                                                                       item.newInstalled = NO;
                                                                       item.coverImageID = arc4random() % 7;
                                                                       item.stationId = objReceipt.objReceiptStation.strStationId;
                                                                       
                                                                       item.stationInfo = [NSString stringWithFormat:@"%@, %@, %@ ",
                                                                                           objReceipt.objReceiptStation.strStationStreet,
                                                                                           objReceipt.objReceiptStation.strStationCity,
                                                                                           objReceipt.objReceiptStation.strSearchState];
                                                                       
                                                                       item.stationName = objReceipt.objReceiptStation.strStationName;
                                                                       
                                                                       [g_aryRewards addObject:[item dictionary]];
                                                                       
                                                                       [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
                                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                                       
                                                                       UIViewController *winnerVC = [self.storyboard instantiateViewControllerWithIdentifier:RECEIPT_WINNER_VIEW_CONTROLLER];
                                                                       [self.navigationController pushViewController:winnerVC animated:YES];
                                                                   }
                                                               }
                                                               else
                                                               {
                                                                   [self showMessageWithText:@"Entry limit exceeded. Please try again later."];
                                                               }
                                                           }
                                                           else
                                                           {
                                                               [SVProgressHUD showErrorWithStatus:strError];
                                                           }
                                                       }];
    }
}

- (BOOL)checkReceiptLimit:(NSInteger)maxCount
{
    BOOL bRet;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_RECEIPT_TIME] != nil) {
        NSDate* last = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_RECEIPT_TIME];
        
        double delta = [[NSDate date] timeIntervalSinceDate:last];
        if(delta > 3600){
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULT_RECEIPT_TIME];
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:DEFAULT_RECEIPT_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            bRet = YES;
        }
        else
        {
            NSInteger nReceiptCount = [[NSUserDefaults standardUserDefaults] integerForKey:DEFAULT_RECEIPT_COUNT] + 1;
            if(nReceiptCount > maxCount)
            {
                bRet = NO;
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setInteger:nReceiptCount forKey:DEFAULT_RECEIPT_COUNT];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                bRet = YES;
            }
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULT_RECEIPT_TIME];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:DEFAULT_RECEIPT_COUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        bRet = YES;
    }
    
    //    bRet = YES;
    return bRet;
}

- (BOOL)validateCode
{
    int nTmpNumber = 0;
    
    for(int nIndex = 10; nIndex < 16; nIndex++)
    {
        UITextField *txtNum = (UITextField *)[self.view viewWithTag:nIndex];
        if(txtNum.text.length == 0)
        {
            [self showMessageWithText:@"Please fill out all numbers"];
            return NO;
        }
        
        nTmpNumber = nTmpNumber * 10 + [txtNum.text intValue];
    }
    
    nCode = [NSNumber numberWithInt:nTmpNumber];
    
    return YES;
}

- (void)showMessageWithText:(NSString *)strMessage
{
    [[[UIAlertView alloc] initWithTitle:@"Alert"
                                message:strMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    [[textField valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSInteger nTextTag = textField.tag;
    
    BOOL bRet = YES;
    if(newLength > 0)
    {
        
        textField.text = string;
        textField.backgroundColor = HAVE_TEXT_COLOR;
        if(nTextTag < 15)
        {
            UITextField *txtNextNum = (UITextField *)[self.view viewWithTag:nTextTag + 1];
            if(txtNextNum.text.length == 0)
            {
                [txtNextNum becomeFirstResponder];
            }
            else
            {
                [textField resignFirstResponder];
            }
        }
        else
            [textField resignFirstResponder];
        
        bRet = NO;
    }
    else
    {
        textField.backgroundColor = EMPTY_TEXT_COLOR;
        bRet = YES;
    }
    
    return bRet;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    for(int nIndex = 10; nIndex < 16; nIndex++)
    {
        UITextField *txtNum = (UITextField *)[self.view viewWithTag:nIndex];
        
        if(txtNum.text.length == 0)
            txtNum.backgroundColor = EMPTY_TEXT_COLOR;
        else
            txtNum.backgroundColor = HAVE_TEXT_COLOR;
    }
    
    textField.backgroundColor = FOCUS_TEXT_COLOR;
}

@end
