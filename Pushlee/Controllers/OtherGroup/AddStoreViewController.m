//
//  AddStoreViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/8/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "AddStoreViewController.h"
#import "StationSelectViewController.h"

@interface AddStoreViewController ()

@end

@implementation AddStoreViewController

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

- (IBAction)onClickBtnAddStores:(id)sender {
    StationSelectViewController *stationSelectVC = (StationSelectViewController *)[self.storyboard instantiateViewControllerWithIdentifier:STATION_SELECT_VIEW_CONTROLLER];
    stationSelectVC.m_rewardNo = -1;
    [self.navigationController pushViewController:stationSelectVC animated:YES];
}

@end
