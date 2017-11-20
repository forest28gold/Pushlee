//
//  ReceiptWinnerViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/20/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "ReceiptWinnerViewController.h"
#import "ScratchViewController.h"

@interface ReceiptWinnerViewController ()

@end

@implementation ReceiptWinnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    g_tabController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    g_tabController.tabBar.hidden = NO;
}


- (IBAction)onClickBtnViewLater:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onClickBtnGetReward:(id)sender {
    UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"Card expires in 10 minutes"
                                                   message:@"Are you sure you want to reveal your prize now? You will have 10 minutes to redeem your prize before it expires."
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Ok", nil];
    [view show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
        return;

    ScratchViewController* scratchVC = [self.storyboard instantiateViewControllerWithIdentifier:SCRATCH_VIEW_CONTROLLER];
    scratchVC.m_rewardNo = (int)g_aryRewards.count - 1;
    [g_tabController setSelectedIndex:2];
    [[g_tabController viewControllers][2] pushViewController:scratchVC animated:YES];
}

@end
