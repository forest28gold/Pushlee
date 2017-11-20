//
//  MainTabBarController.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/4/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "MainTabBarController.h"

NSMutableArray      *g_aryFavoriteStations;

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocation) name:NOTIFICATION_GOT_LOCATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPassBookInfo];
}

- (void)getPassBookInfo
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DEFAULT_GOT_PASSBOOK];
    if([PKPassLibrary isPassLibraryAvailable])
    {
        PKPassLibrary *pkLibrary = [[PKPassLibrary alloc] init];
        NSArray *aryPKPasses = [pkLibrary passes];
        
        for(PKPass *pass in aryPKPasses)
        {
            NSLog(@"%@", pass.userInfo);
            if([pass.passTypeIdentifier isEqualToString:PASS_BOOK_IDENTIFIER]
               && [pass.serialNumber isEqualToString:PASS_BOOK_SERIALNUMBER])
            {
                m_savedPass = pass;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_GOT_PASSBOOK];
                break;
            }
        }
    }
    
    g_aryFavoriteStations = [NSMutableArray arrayWithArray:[[ParseService sharedInstance] getFavoriteStations]];
}

- (void)updateLocation
{
    [[ParseService sharedInstance] updateUserLocationWithLat:g_myInfo.fUserLatitude
                                                        Long:g_myInfo.fUserLongitude];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_GOT_PASSBOOK])
    {
        NSString *strLastStationId = [m_savedPass.userInfo objectForKey:@"stationId"];
        [[ParseService sharedInstance] getNearestStationWithCouponOfFavoriteStations:g_aryFavoriteStations
                                                                              Result:^(Station *station, NSString *strError) {
                                                                                  if(strError == nil)
                                                                                  {
                                                                                      if([station.strStationId isEqualToString:strLastStationId])
                                                                                      {
                                                                                          NSLog(@"No Update the Nearest Station");
                                                                                      }
                                                                                      else
                                                                                      {
                                                                                          [self getNewPassWithStation:station];
                                                                                      }
                                                                                  }
                                                                                  else
                                                                                      NSLog(@"%@", strError);
                                                                              }];
    }
}

- (void)getNewPassWithStation:(Station *)station
{
    [[ParseService sharedInstance] getCouponDealWithStationId:station
                                                       Result:^(Deal *deal, NSString *strError) {
                                                           if(strError == nil)
                                                           {
                                                               [[WebService sharedInstance] getPKPassFromServerWithSation:station
                                                                                                                     Deal:deal
                                                                                                                Completed:^(PKPass *objPass) {
                                                                                                                    PKPassLibrary *pkLibrary = [[PKPassLibrary alloc] init];
                                                                                                                    if([pkLibrary replacePassWithPass:objPass])
                                                                                                                        NSLog(@"Update PassBook Successfully!");
                                                                                                                    else
                                                                                                                        NSLog(@"Added new PassBook");
                                                                                                                }
                                                                                                                   Failed:^(NSString *strError) {
                                                                                                                       NSLog(@"%@", strError);
                                                                                                                   }];
                                                           }
                                                           else
                                                           {
                                                               NSLog(@"%@", strError);
                                                           }
                                                       }];
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

- (void)awakeFromNib
{
    NSArray *aryImageNames = @[@"tap_iconDisableHome", @"tap_iconDisableDeal", @"tap_iconDisableReward", @"tap_iconDisableMap"];
    NSArray *arySelectedImageNames = @[@"tap_iconEnableHome", @"tap_iconEnableDeal", @"tap_iconEnableReward", @"tap_iconEnableMap"];
    
    for(int nIndex = 0; nIndex < self.tabBar.items.count; nIndex++)
    {
        UITabBarItem *item = [self.tabBar.items objectAtIndex:nIndex];
        item.image = [[UIImage imageNamed:[aryImageNames objectAtIndex:nIndex]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [[UIImage imageNamed:[arySelectedImageNames objectAtIndex:nIndex]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0);
    }
}

@end
