//
//  StationSelectViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 9/30/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "StationSelectViewController.h"
#import "ScratchViewController.h"
#import "StationTableCell.h"

@interface StationSelectViewController ()

@end

@implementation StationSelectViewController

@synthesize m_tblStations;
@synthesize m_rewardNo;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBarButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [g_tabController.tabBar setHidden:YES];
    self.navigationController.navigationBarHidden = NO;
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    if(m_rewardNo < 0)
    {
        [[ParseService sharedInstance] getAllStations:^(NSArray *aryStations) {
            [SVProgressHUD dismiss];
            m_aryStations = aryStations;           
            [m_tblStations reloadData];
        }];
    }
    else
    {
        m_rewardItem = [[RewardItem alloc] initWithDictionary:g_aryRewards[m_rewardNo]];
        
        [[ParseService sharedInstance] getStations:m_rewardItem
                                            Result:^(NSArray *aryStations) {
                                                [SVProgressHUD dismiss];
                                                m_aryStations = aryStations;
                                                [m_tblStations reloadData];
                                            }];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [g_tabController.tabBar setHidden:NO];
}

- (void)setBarButton {
    
    [self.navigationItem setTitle:@"Select Station!"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"common_bkBar"] forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"Roboto-Light" size:20],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    if(m_rewardNo < 0)
    {
        UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0.0f, 6, 40.0f, 30.0f)];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0]];
        [backButton addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backButtonItem;
        
        UIButton *addButton = [[UIButton alloc] initWithFrame: CGRectMake(280.0f, 6, 40.0f, 30.0f)];
        [addButton setTitle:@"Save" forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0]];
        [addButton addTarget:self action:@selector(saveStores) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *addStoreButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        self.navigationItem.rightBarButtonItem = addStoreButtonItem;
    }
    else
    {
        self.navigationItem.hidesBackButton = YES;
        UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0.0f, 6, 40.0f, 30.0f)];
        [backButton setTitle:@"Back" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0]];
        [backButton addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
}

-(void)popBack
{
    if(m_rewardNo == -1)    //from home
        [self.navigationController popToRootViewControllerAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)saveStores
{
    [[ParseService sharedInstance] saveFavoriteStationsWithStations:g_aryFavoriteStations
                                                             Result:^(NSString *strError) {
                                                                 if(strError)
                                                                     NSLog(@"%@", strError);
                                                             }];
    
    if(m_rewardNo == -1)    //from home
    {
        [SVProgressHUD showWithStatus:@"Saving..." maskType:SVProgressHUDMaskTypeGradient];
        [[ParseService sharedInstance] getNearestStationWithCouponOfFavoriteStations:g_aryFavoriteStations
                                                                              Result:^(Station *station, NSString *strError) {
                                                                                  [SVProgressHUD dismiss];
                                                                                  if(strError == nil)
                                                                                  {
                                                                                      m_couponStation = station;
                                                                                      [[[UIAlertView alloc] initWithTitle:@"Pushlee"
                                                                                                                  message:@"Pushlee supports some coupon. Do you allow to get this?"
                                                                                                                 delegate:self
                                                                                                        cancelButtonTitle:@"No"
                                                                                                        otherButtonTitles:@"Yes", nil] show];
                                                                                  }
                                                                                  else
                                                                                  {
                                                                                      NSLog(@"%@", strError);
                                                                                      [self popBack];
                                                                                  }
                                                                              }];
    }
    else    //from left menu
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma UITableViewDatasource
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_aryStations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StationTableCell";
    StationTableCell *cell = (StationTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Station *station = [m_aryStations objectAtIndex:indexPath.row];
    
    cell.lblStationName.text = station.strStationName;
    cell.lblStationLocation.text = [NSString stringWithFormat:@"%@ %@", station.strStationStreet, [station.strSearchCity capitalizedString]];
    cell.lblStationDistance.text = [NSString stringWithFormat:@"%.2f Mi", station.getDistanceFromMe];
    
    if(m_rewardNo < 0)
    {
        if([g_aryFavoriteStations containsObject:station.strStationId])
        {
            [cell.btnStationSpinner setSelected:YES];
        }
        else
        {
            [cell.btnStationSpinner setSelected:NO];
        }
    }
    else
        [cell.btnStationSpinner setSelected:NO];
    
    [cell.btnStationSpinner setTag:indexPath.row + 100];
    [cell.btnStationSpinner addTarget:self action:@selector(onChangeSwitch:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)onChangeSwitch:(UIButton *)sender
{
    if(m_rewardNo < 0)
    {
        Station *station = [m_aryStations objectAtIndex:sender.tag - 100];
        [sender setSelected:!sender.selected];
        
        if(sender.selected)
        {
            if(g_aryFavoriteStations.count < FAVORITE_STORE_MAXIMUM)
            {
                [g_aryFavoriteStations addObject:station.strStationId];
            }
            else
            {
                sender.selected = NO;
                [[[UIAlertView alloc] initWithTitle:@"Alert"
                                            message:@"Sorry, You can't save 10 more favorite stores"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil, nil] show];
            }
        }
        else
        {
            [g_aryFavoriteStations removeObject:station.strStationId];
        }
    }
    else
    {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"Card expires in 10 minutes"
                                                       message:@"Are you sure you want to reveal your prize now? You will have 10 minutes to redeem your prize before it expires."
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Ok", nil];
        view.tag = 100;
        m_btnSelected = sender;
        [view show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1)
    {
        if(alertView.tag == 100)
        {
            Station* station = m_aryStations[m_btnSelected.tag - 100];
            m_rewardItem.stationId = station.strStationId;
            m_rewardItem.newInstalled = NO;
            m_rewardItem.stationName = station.strStationName;
            m_rewardItem.stationInfo = [NSString stringWithFormat:@"%@, %@, %@", station.strStationStreet ,station.strStationCity, station.strStationState];
            m_rewardItem.stationCity = station.strStationCity;
            
            g_aryRewards[m_rewardNo] = m_rewardItem.dictionary;
            [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
            
            [[ParseService sharedInstance] recordRewardStateToParseWithStationID:m_rewardItem.stationId
                                                                            Slug:@"new-install"
                                                                           State:@"off"
                                                                          DealID:@""];
            
            ScratchViewController* scratchVC = [self.storyboard instantiateViewControllerWithIdentifier:SCRATCH_VIEW_CONTROLLER];
            scratchVC.m_rewardNo = self.m_rewardNo;
            
            [self.navigationController pushViewController:scratchVC animated:YES];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Getting Coupon..." maskType:SVProgressHUDMaskTypeGradient];
            [[ParseService sharedInstance] getCouponDealWithStationId:m_couponStation
                                                               Result:^(Deal *deal, NSString *strError) {
                                                                   if(strError == nil)
                                                                   {
                                                                       [[WebService sharedInstance] getPKPassFromServerWithSation:m_couponStation
                                                                                                                             Deal:deal
                                                                                                                        Completed:^(PKPass *objPass) {
                                                                                                                            [SVProgressHUD dismiss];
                                                                                                                            m_pkPass = objPass;
                                                                                                                            PKAddPassesViewController *pkAddVC = [[PKAddPassesViewController alloc] initWithPass:objPass];
                                                                                                                            pkAddVC.delegate = self;
                                                                                                                            [self presentViewController:pkAddVC animated:YES completion:nil];                                                                                                                            
                                                                                                                        }
                                                                                                                           Failed:^(NSString *strError) {
                                                                                                                               [SVProgressHUD showErrorWithStatus:strError];
                                                                                                                           }];
                                                                   }
                                                                   else
                                                                   {
                                                                       [SVProgressHUD showErrorWithStatus:strError];
                                                                   }
                                                               }];
        }
    } else
    {
        if(alertView.tag == 100)
            [m_btnSelected setSelected:NO];
        else
            [self popBack];
    }
}

#pragma PKAddPassesViewControllerDelegate
-(void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller
{
    PKPassLibrary *pkLibrary = [[PKPassLibrary alloc] init];
    if([pkLibrary containsPass:m_pkPass])   //click add
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_GOT_PASSBOOK];
    
    [controller dismissViewControllerAnimated:YES completion:^{
        [self popBack];
    }];
}

@end
