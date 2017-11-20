//
//  AppDelegate.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/2/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <sqlite3.h>
#import <MFSideMenu.h>
#import <AFNetworking.h>
#import <ASIHTTPRequest.h>
#import <SVProgressHUD.h>

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

extern UserInfo                                     *g_myInfo;
extern UITabBarController                           *g_tabController;
extern MFSideMenuContainerViewController            *g_sideMenuController;
extern NSMutableArray                               *g_aryRewards;
extern NSMutableArray                               *g_aryFavoriteStations;
extern BOOL                                         g_isReachability;
extern BOOL                                         g_isGotMyLocation;

typedef enum{
    
    invited_friends = 0
    , reward_shares
    , deal_redemptions
    , deal_shares
    , deal_likes
    , first_visit
    
} MilestoneType;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate, UITabBarControllerDelegate, UIAlertViewDelegate>
{
    CLLocationManager           *m_mgrLocation;
    CBCentralManager            *m_mgrBluetooth;
    
    sqlite3                    	*database;
    
    NSMutableDictionary         *m_dicRewardCriteria;
    NSMutableDictionary         *m_dicRewardAvailable;
    
    int                         _beacon_count;
    NSMutableArray          	*_beacon_pushs;
    NSMutableArray          	*_station_beacons;
    
    BOOL                        isGetLocation;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) MFSideMenuContainerViewController *mainVC;

@property (nonatomic, retain) NSMutableArray                    *m_aryRedeemDealIDs;
@property (nonatomic, retain) NSMutableArray                    *m_aryViewedDealIDs;

@property (nonatomic, retain) NSString                          *m_strSharing;
@property (nonatomic, retain) NSString                          *m_strSharingForTwitter;

// for beacon
@property (strong, nonatomic) CLBeaconRegion *_beaconRegion;
@property (strong, nonatomic) CLLocationManager *m_locationManager;

// for beacon visited
@property (strong, nonatomic) NSDate            *_visitEnter;
@property (strong, nonatomic) NSDate            *_visitExit;
@property (strong, nonatomic) NSString          *_station_id;
@property (strong, nonatomic) NSString          *_deal_id_pushed;
@property (strong, nonatomic) NSMutableArray    *_deals_viewed;
@property (strong, nonatomic) NSMutableArray    *_redeemedDealWithID;
@property (strong, nonatomic) NSMutableArray    *_phoneHardware;
@property (strong, nonatomic) NSString          *_beaconUDID;
@property (strong, nonatomic) NSNumber          *_beaconMajor;
@property (strong, nonatomic) NSNumber          *_beaconMinor;

//SQLite
- (sqlite3_stmt *)getStatement:(NSString *)SQLStrValue;
- (BOOL)InsUpdateDelData:(NSString*)SqlStr;

- (void)saveRewardAvailableWithMilestoneType:(MilestoneType)milestonetype StationID:(NSString*)stationId;

@end
