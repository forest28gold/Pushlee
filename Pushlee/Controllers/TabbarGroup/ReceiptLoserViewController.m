//
//  ReceiptLoserViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/20/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "ReceiptLoserViewController.h"

@interface ReceiptLoserViewController ()

@end

@implementation ReceiptLoserViewController

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

- (IBAction)onClickBtnGoHome:(id)sender {
    if(g_tabController.selectedIndex == 0)
    {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
        [g_tabController setSelectedIndex:0];
}

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


@end
