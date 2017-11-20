//
//  AppDelegate.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/2/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "AppDelegate.h"
#import <UbertestersSDK/Ubertesters.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "LeftMenuTableViewController.h"
#import "RightMenuTableViewController.h"
#import "MapViewController.h"

#import "RedeemViewController.h"
#import "BeaconPush.h"

UserInfo                                    *g_myInfo;
UITabBarController                          *g_tabController;
MFSideMenuContainerViewController           *g_sideMenuController;
NSMutableArray                              *g_aryRewards;
BOOL                                        g_isReachability;
BOOL                                        g_isGotMyLocation;

@implementation AppDelegate

@synthesize m_aryRedeemDealIDs;
@synthesize m_aryViewedDealIDs;

@synthesize m_strSharing;
@synthesize m_strSharingForTwitter;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //Local Database
    [self copyDatabaseIfNeeded];
    [self generateDB];
    
    //Initialize Ubertesters
    [[Ubertesters shared] initialize];

    //Customise SVProgressHUD
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:247.f/255.f green:247.f/255.f blue:247.f/255.f alpha:1.f]];
    [SVProgressHUD setFont:[UIFont fontWithName:@"Roboto-Light" size:18.0f]];
    
    //Initialize Parse.com
    [Parse setApplicationId:PARSE_APPLICATION_ID
                  clientKey:PARSE_CLIENT_KEY];
    
    [PFFacebookUtils initializeFacebook];
    
#ifdef __IPHONE_8_0
    //Right, that is the point
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                         |UIRemoteNotificationTypeSound
                                                                                         |UIRemoteNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#else
    //register to receive notifications
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#endif
    
    //Initialize Location Manager
    m_mgrLocation = [[CLLocationManager alloc] init];
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER)
    {
        // Use one or the other, not both. Depending on what you put in info.plist
        [m_mgrLocation requestWhenInUseAuthorization];
    }
#endif
    m_mgrLocation.desiredAccuracy = kCLLocationAccuracyBest;
    m_mgrLocation.delegate = self;
    [self updateUserLocation];
    [NSTimer scheduledTimerWithTimeInterval:LOCATION_UPDATE_INTERVAL
                                     target:self
                                   selector:@selector(updateUserLocation)
                                   userInfo:nil
                                    repeats:YES];

    // Notification
    NSDictionary *notificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload != nil) {
        [self handleCustomNotifications:notificationPayload withStatus:YES];
    }
    
    g_myInfo = [[UserInfo alloc] init];
    [g_myInfo addInfoWithPFUser:[PFUser currentUser]];

    [self initRewards];
    [self initRewardsCriteria];
    [self initRewardsAvailable];
    [self checkBlutooth];
    [self initBeacon];
    
    g_isGotMyLocation = NO;
    
    m_aryRedeemDealIDs = [[NSMutableArray alloc] init];
    m_aryViewedDealIDs = [[NSMutableArray alloc] init];

    //Decide the first screen
    [self setFirstScreen];
        
    return YES;
}

- (void)initRewards
{
    NSArray* temp = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_REWARD_LIST];
    if(temp == nil){
        g_aryRewards = [[NSMutableArray alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else
        g_aryRewards = [NSMutableArray arrayWithArray:temp];
}

- (void)initRewardsCriteria
{
    m_dicRewardCriteria = [[NSMutableDictionary alloc] init];
    
    PFQuery* query = [PFQuery queryWithClassName:@"rewardsAvailable"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(objects != nil && error == nil){
            
            for(NSDictionary* dict in objects)
                [m_dicRewardCriteria setObject:dict[@"amount"] forKey:dict[@"slug"]];
        }
    }];
}

- (void)initRewardsAvailable
{
    NSDictionary* temp = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_REWARD_AVAILABLE];
    
    if(temp == nil){
        
        m_dicRewardAvailable = [[NSMutableDictionary alloc] init];
        [m_dicRewardAvailable setObject:[NSNumber numberWithInt:0]          forKey:@"invited-friends"];
        [m_dicRewardAvailable setObject:[[NSMutableArray alloc] init]       forKey:@"reward-shares"];
        [m_dicRewardAvailable setObject:[[NSMutableArray alloc] init]       forKey:@"deal-redemptions"];
        [m_dicRewardAvailable setObject:[[NSMutableArray alloc] init]       forKey:@"deal-shares"];
        [m_dicRewardAvailable setObject:[[NSMutableArray alloc] init]       forKey:@"deal-likes"];
        [m_dicRewardAvailable setObject:[[NSMutableArray alloc] init]       forKey:@"first-visit"];
        
        [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else
        m_dicRewardAvailable = [NSMutableDictionary dictionaryWithDictionary:temp];
}

- (void)checkBlutooth
{
    if(!m_mgrBluetooth) {
        m_mgrBluetooth = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    [self centralManagerDidUpdateState:m_mgrBluetooth];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(m_mgrBluetooth.state)
    {
        case CBCentralManagerStateResetting:
            stateString = @"The connection with the system service was momentarily lost, update imminent.";
            break;
            
        case CBCentralManagerStateUnsupported:
            stateString = @"The platform doesn't support Bluetooth Low Energy.";
            break;
            
        case CBCentralManagerStateUnauthorized:
            stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
            
        case CBCentralManagerStatePoweredOff:
            stateString = @"Bluetooth is currently powered off.";
            break;
            
        case CBCentralManagerStatePoweredOn:
            stateString = @"Bluetooth is currently powered on and available to use.";
            break;
            
        default:
            stateString = @"State unknown, update imminent.";
            break;
    }
    
    NSLog(@"Bluetooth Status : %@", stateString);
}


- (void)updateUserLocation
{
    isGetLocation = YES;
    [m_mgrLocation startUpdatingLocation];
}

#pragma CLLocationDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    CLLocation *newLocation = locations.lastObject;
    if(newLocation)
    {
        if(g_myInfo.fUserLatitude == newLocation.coordinate.latitude && g_myInfo.fUserLongitude == newLocation.coordinate.longitude)
            return;
        
        g_myInfo.fUserLatitude = newLocation.coordinate.latitude;
        g_myInfo.fUserLongitude = newLocation.coordinate.longitude;
        g_isGotMyLocation = YES;
        
        if(isGetLocation)
        {
            isGetLocation = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOT_LOCATION object:nil];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    g_isGotMyLocation = NO;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* strDeviceToken = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    g_myInfo.strDeviceToken = strDeviceToken;
    
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    g_myInfo.strUserInstallationId = currentInstallation.installationId;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSLog(@"%@", url);
    
    if([[url absoluteString] hasPrefix:@"mobilepushlee"]){
        
        NSString* payload = [[url absoluteString] substringFromIndex:16];
        
        NSString* header = [payload componentsSeparatedByString:@"/"][0];
        
        if([header isEqualToString:@"main"]){
            [g_tabController setSelectedIndex:0];
        } else if([header isEqualToString:@"dealprofile"]){

            LeftMenuTableViewController* leftMenu = (LeftMenuTableViewController*) g_sideMenuController.leftMenuViewController;
            [leftMenu showDealSurvey];
            
        } else if([header isEqualToString:@"dealpage"]){
            
            NSArray* array = [payload componentsSeparatedByString:@"/"];
            NSString* stationId = array[1];
            NSString* dealId = array[2];
            
            [[ParseService sharedInstance] getStationAndDealWithStationId:stationId
                                                                   DealId:dealId Result:^(Station *station, Deal *deal) {
                                                                       if(station != nil && deal != nil)
                                                                       {
                                                                           RedeemViewController *redeemVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:REDEEM_VIEW_CONTROLLER];
                                                                           redeemVC.m_objStation = station;
                                                                           redeemVC.m_objDeal = deal;
                                                                           [g_tabController setSelectedIndex:0];
                                                                           [[g_tabController.viewControllers objectAtIndex:0] pushViewController:redeemVC animated:YES];
                                                                       }
                                                                   }];
            
        } else if([header isEqualToString:@"station"]){
            
            NSArray* array = [payload componentsSeparatedByString:@"/"];
            NSString* stationId = [array objectAtIndex:1];
            [[NSUserDefaults standardUserDefaults] setValue:stationId forKey:DEFAULT_LAST_VISITED_STATION];
            [g_tabController setSelectedIndex:1];
            [[[g_tabController viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:YES];
            
            
        } else if([header isEqualToString:@"stationsearch"]){
            
            [g_tabController setSelectedIndex:3];
            [[[g_tabController viewControllers] objectAtIndex:3] popToRootViewControllerAnimated:YES];
            
        } else if([header isEqualToString:@"stationsuggest"]){
            
            [g_tabController setSelectedIndex:3];
            [[[g_tabController viewControllers] objectAtIndex:3] popToRootViewControllerAnimated:YES];
            MapViewController *mapVC = [((UINavigationController *)[g_tabController.viewControllers objectAtIndex:3]).viewControllers objectAtIndex:0];
            [mapVC onRightMenuClicked:nil];
            
        } else if([header isEqualToString:@"presenttab"]){
            
            [g_tabController setSelectedIndex:2];
            [[g_tabController.viewControllers objectAtIndex:2] popToRootViewControllerAnimated:NO];
            
        } else if([header isEqualToString:@"profile"]){
            
            LeftMenuTableViewController* leftMenu = (LeftMenuTableViewController*)g_sideMenuController.leftMenuViewController;
            [leftMenu pushYourProfile];
            
        } else if([header isEqualToString:@"invite"]){
            
            LeftMenuTableViewController* leftMenu = (LeftMenuTableViewController*)g_sideMenuController.leftMenuViewController;
            [leftMenu inviteYourFriend];
            
        } else if([header isEqualToString:@"walkthrough"]){
            
            LeftMenuTableViewController* leftMenu = (LeftMenuTableViewController*)g_sideMenuController.leftMenuViewController;
            [leftMenu gotoWalkThrough];
            
        }
        
        NSLog(@"%@", payload);
        
        return YES;
    }
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    g_myInfo.strDeviceToken = @"00";
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handleCustomNotifications:userInfo withStatus:NO];
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    [self checkReachability];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        [[ParseService sharedInstance] getCustomReward:^(RewardItem *item) {
            if(item != nil)
            {
                for(int nIndex = 0; nIndex < currentInstallation.badge; nIndex++)
                {
                    item.coverImageID = arc4random() % 7;
                    [g_aryRewards addObject:item.dictionary];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[ParseService sharedInstance] recordRewardStateToParseWithStationID:item.stationId
                                                                                    Slug:@"custom-reward"
                                                                                   State:@"off"
                                                                                  DealID:@""];
                }
                
                currentInstallation.badge = 0;
                [currentInstallation saveEventually];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOT_REWARD object:nil];
                [g_tabController setSelectedIndex:2];
            }
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setFirstScreen
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *leftVC = [storyboard instantiateViewControllerWithIdentifier:LEFT_MENU_VIEW_CONTROLLER];
    UIViewController *rightVC = [storyboard instantiateViewControllerWithIdentifier:RIGHT_MENU_VIEW_CONTROLLER];
    
    g_tabController = [storyboard instantiateViewControllerWithIdentifier:UITABBAR_CONTROLLER];
    g_tabController.delegate = self;
    g_sideMenuController = [MFSideMenuContainerViewController containerWithCenterViewController:g_tabController
                                                                         leftMenuViewController:leftVC
                                                                        rightMenuViewController:rightVC];
    [g_sideMenuController.shadow setEnabled:YES];
    [g_sideMenuController.shadow setRadius:10.f];
    [g_sideMenuController.shadow setColor:[UIColor whiteColor]];
    [g_sideMenuController.shadow setOpacity:0.7f];
    
    // select first screen
    if (![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_FIRST_RUN])
    {
        UINavigationController *ctrl = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:WALKTHROUGH_NAVIGATION_CONTROLLER];
        [self.window setRootViewController:ctrl];
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_USER_LOGGED])
        {
            [self.window setRootViewController:g_sideMenuController];
        }
        else
        {
            UINavigationController *ctrl = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:LOGIN_NAVIGATION_CONTROLLER];
            [self.window setRootViewController:ctrl];
        }
    }

}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSUInteger tabitem = tabBarController.selectedIndex;
    [[tabBarController.viewControllers objectAtIndex:tabitem] popToRootViewControllerAnimated:YES];
}

- (void)checkReachability
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.google.com"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                g_isReachability = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                g_isReachability = NO;
                break;
        }
    }];
    
    [manager.reachabilityManager startMonitoring];
}

#pragma mark local database Mehods

- (void) copyDatabaseIfNeeded {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    if(!success) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Stations.sqlite"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (void) generateDB
{
    NSString *dbFilePath = [self getDBPath];
    sqlite3_open([dbFilePath UTF8String], &database);
}

- (NSString *) getDBPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"Stations.sqlite"];
}

- (sqlite3_stmt *) getStatement:(NSString *) SQLStrValue
{
    if([SQLStrValue isEqualToString:@""])
        return nil;
    
    sqlite3_stmt * OperationStatement;
    sqlite3_stmt * ReturnStatement = nil;
    
    const char *sql = [SQLStrValue cStringUsingEncoding: NSUTF8StringEncoding];
    
    if (sqlite3_prepare_v2(database, sql, -1, &OperationStatement, NULL) == SQLITE_OK)
    {
        ReturnStatement = OperationStatement;
    }
    return ReturnStatement;
}

-(BOOL)InsUpdateDelData:(NSString*)SqlStr
{
    if([SqlStr isEqual:@""])
        return NO;
    
    BOOL RetrunValue;
    RetrunValue = NO;
    const char *sql = [SqlStr cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, sql, -1, &stmt, nil) == SQLITE_OK)
        RetrunValue = YES;
    
    if(RetrunValue == YES)
    {
        if(sqlite3_step(stmt) != SQLITE_DONE) {
            
        }
        sqlite3_finalize(stmt);
    }
    return RetrunValue;
}

- (void)savingInLocalDB:(NSString *)stationId WithName:(NSString *)stationName andAddress:(NSString *)stationAddress {
    
    // Handling DB
    BOOL isUpdate = NO;
    sqlite3_stmt * ReturnStatement;

    NSString *stringQuery = [NSString stringWithFormat:@"SELECT StationId,Count FROM Pushlee"];
    ReturnStatement = [self getStatement:stringQuery];
    while(sqlite3_step(ReturnStatement) == SQLITE_ROW)
    {
        NSString *stnId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement, 0)];
        NSString *stnCount = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement, 1)];
        if ([stnId isEqualToString:stationId]) {
            //Update
            isUpdate = YES;
            
            int count = [stnCount intValue];
            count = count + 1;
            NSString *strQuery = [NSString stringWithFormat:@"UPDATE Pushlee SET Count='%@' WHERE StationId='%@'",[NSString stringWithFormat:@"%d",count],stnId];
            NSString *SqlStr = [NSString stringWithString:strQuery];
            [self InsUpdateDelData:SqlStr];
            break;
        }
    }
    
    if (isUpdate == NO) {
        //Insert
        int count = 1;
        NSString *strQuery = [NSString stringWithFormat:@"INSERT INTO Pushlee(StationId,StationName,StationAddress,Count) values('%@','%@','%@','%@')",stationId,stationName,stationAddress,[NSString stringWithFormat:@"%d",count]];
        NSString *SqlStr = [NSString stringWithString:strQuery];
        [self InsUpdateDelData:SqlStr];
    }
    
    // Handling DB
    BOOL isUpdateStats = NO;
    NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"UDID"];
    sqlite3_stmt * ReturnStatement1;
    NSString *stringQuery1 = [NSString stringWithFormat:@"SELECT * FROM Stats"];
    ReturnStatement1=[self getStatement:stringQuery1];
    while(sqlite3_step(ReturnStatement1) == SQLITE_ROW)
    {
        NSString *stnId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement1, 0)];
        NSString *dealCount = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement1, 1)];
        
        if ([stnId isEqualToString:userId]) {
            //Update
            isUpdateStats = YES;
            
            int totalDeals = [dealCount intValue];
            totalDeals = totalDeals + 1;
            NSString *strQuery = [NSString stringWithFormat:@"UPDATE Stats SET TotalDeals='%@' WHERE UserId='%@'",[NSString stringWithFormat:@"%d",totalDeals],stnId];
            NSString *SqlStr = [NSString stringWithString:strQuery];
            [self InsUpdateDelData:SqlStr];
            break;
        }
    }
    
    if (isUpdateStats == NO) {
        //Insert
        int totalDeals = 1;
        int RedeemedDeals = 0;
        NSString *strQuery = [NSString stringWithFormat:@"INSERT INTO Stats(UserId,TotalDeals,RedeemedDeals) values('%@','%@','%@')",userId,[NSString stringWithFormat:@"%d",totalDeals],[NSString stringWithFormat:@"%d",RedeemedDeals]];
        NSString *SqlStr = [NSString stringWithString:strQuery];
        [self InsUpdateDelData:SqlStr];
    }
}

- (void)handleCustomNotifications:(NSDictionary *)dic withStatus:(BOOL)isLaunch
{
    if([dic[@"data"] isKindOfClass:[NSDictionary class]] && [dic[@"data"][@"data"] isEqualToString:@"reward"])
    {
        NSString* rewardId = dic[@"data"][@"id"];
        if([rewardId isEqualToString:@""])
            return;
        
        [[ParseService sharedInstance] getCustomReward:^(RewardItem *item) {
            
            if(item != nil)
            {
                [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[ParseService sharedInstance] recordRewardStateToParseWithStationID:item.stationId
                                                                                Slug:@"custom-reward"
                                                                               State:@"off"
                                                                              DealID:@""];

                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOT_REWARD object:nil];
                [g_tabController setSelectedIndex:2];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                currentInstallation.badge = 0;
                [currentInstallation saveEventually];
            }
        }];

        return;
        
    }else if([dic[@"data"] isKindOfClass:[NSDictionary class]] && [dic[@"data"][@"data"] isEqualToString:@"message"]){
        return;
    }
    else
    {
        NSString *dealId = [[[[[[dic valueForKey:@"data"] componentsSeparatedByString:@","] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *stationId = [[[[[[dic valueForKey:@"data"] componentsSeparatedByString:@","] objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if(dealId == nil || stationId == nil){
            [[[UIAlertView alloc] initWithTitle:@"Pushlee"
                                        message:@"There is an internet connection error."
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil, nil] show];
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:dealId forKey:DEFAULT_DEAL_ID];
        [[NSUserDefaults standardUserDefaults] setValue:stationId forKey:DEFAULT_STATION_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // for beacon visited
        self._deal_id_pushed = dealId;
        
        [[ParseService sharedInstance] getStationAndDealWithStationId:stationId
                                                               DealId:dealId Result:^(Station *station, Deal *deal) {
                                                                   if(station != nil && deal != nil)
                                                                   {
                                                                       RedeemViewController *redeemVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:REDEEM_VIEW_CONTROLLER];
                                                                       redeemVC.m_objStation = station;
                                                                       redeemVC.m_objDeal = deal;
                                                                       [g_tabController setSelectedIndex:0];
                                                                       [[g_tabController.viewControllers objectAtIndex:0] pushViewController:redeemVC animated:YES];
                                                                   }
                                                                   
                                                                   if (isLaunch == NO) {
                                                                       [self savingInLocalDB:stationId
                                                                                    WithName:station.strStationName
                                                                                  andAddress:[NSString stringWithFormat:@"%@,%@",
                                                                                              station.strStationCity,
                                                                                              station.strStationState]];
                                                                   }

                                                               }];
        
        
        NSDictionary *tempDic = [dic valueForKey:@"aps"];
        id alert = [tempDic objectForKey:@"alert"];
        NSString *dealName = [[[[[alert componentsSeparatedByString:@","] objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [[NSUserDefaults standardUserDefaults] setValue:dealName forKey:DEFAULT_LAST_DEAL];
    }
}

#pragma mark - Beacon Part
- (void)initBeacon {
    
    _beacon_count = 0;
    
    NSString* lastUpdateID = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_LAST_UPDATE_ID];
    PFQuery* updateBeaconInApp = [PFQuery queryWithClassName:@"updateBeaconInApp"];
    [updateBeaconInApp orderByDescending:@"createdAt"];
    PFObject* updatedObject = [updateBeaconInApp getFirstObject];
    
    if(KEY_LAST_UPDATE_ID == nil || ![updatedObject.objectId isEqualToString:lastUpdateID]){
        
        while ([self downloadBeaconList] == -1) {
            
            NSLog(@"%@", @"Error occurred during quering to parse.");
            
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:updatedObject.objectId forKey:KEY_LAST_UPDATE_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    NSArray* objects = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_BEACON_LIST];
    
    self.m_locationManager = [[CLLocationManager alloc] init];
    [self.m_locationManager setDelegate:self];
    
    for (int i = 0; i < objects.count; i ++) {
        NSDictionary *obj = [objects objectAtIndex:i];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[obj objectForKey:@"uuid"]];
        if (uuid == nil) {
            continue;
        }
        
        CLLocationManager* manager = [[CLLocationManager alloc] init];
        
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[obj objectForKey:@"uuid"]];
        
        beaconRegion.notifyEntryStateOnDisplay = YES;
        beaconRegion.notifyOnEntry = YES;
        beaconRegion.notifyOnExit = YES;
        
        [manager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
        [manager startRangingBeaconsInRegion:beaconRegion];
        [manager startMonitoringForRegion:beaconRegion];
        
        [manager setDelegate:self];
        
        [_station_beacons addObject:manager];
        
    }
    NSLog(@"finished initializing beacon");
}

- (int) downloadBeaconList{
    
    PFQuery *beacons = [PFQuery queryWithClassName:@"Beacons"];
    NSArray* beaconList = [beacons findObjects];
    NSMutableArray* aryBeacons = [[NSMutableArray alloc] init];
    
    if(beaconList != nil){
        for(int i = 0; i < beaconList.count; i ++)
            [aryBeacons addObject:
             
             @{@"uuid"   :   [beaconList[i] objectForKey:@"udid"]
               , @"major"  :   [beaconList[i] objectForKey:@"major"]
               , @"minor"  :   [beaconList[i] objectForKey:@"minor"]}
             
             ];
        
        [[NSUserDefaults standardUserDefaults] setObject:aryBeacons forKey:KEY_BEACON_LIST];
        return 0;
    }
    
    return -1;
}

- (void)startMonitoring{
    
    static int beaconIndex = 2;
    CLBeaconRegion *beaconRegion =
    [_station_beacons objectAtIndex:beaconIndex];
    
    [self.m_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [self.m_locationManager startRangingBeaconsInRegion:beaconRegion];
    [self.m_locationManager startMonitoringForRegion:beaconRegion];
    
    beaconIndex += 1;
    beaconIndex %= _station_beacons.count;
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region{
    
    [self.m_locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion*)region{
    
    [self.m_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    
}

-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region {
    //in case beacon minor 5 call cloud function newBeacon5
    //in other case call cloud function hello3
    //every case must keep time step with 1 hour.
    
    if (_beacon_count != beacons.count) {
        _beacon_count = (int)beacons.count;
        
        if (beacons.count > 0) {
            for (int i = 0; i < beacons.count; i ++) {
                CLBeacon *beacon = [beacons objectAtIndex:i];
                
                if(beacon.minor.intValue == 5){
                    if(beacon.accuracy > 0.f && beacon.accuracy < 2.f ){
                        BeaconPush * push;
                        NSDate *current = [NSDate date];
                        BOOL exist = false;
                        
                        for (int i = 0; i < _beacon_pushs.count; i ++) {
                            push = [_beacon_pushs objectAtIndex:i];
                            
                            if ([push.uuid isEqualToString:beacon.proximityUUID.UUIDString]) {
                                exist = true;
                                double interval = [current timeIntervalSinceDate:push.lastTime];
                                if (interval < 3600.0f) {
                                    return;
                                }
                            }
                        }
                        
                        if(exist){
                            [push setValue:current forKey:@"lastTime"];
                            [_beacon_pushs setObject:push atIndexedSubscript:i];
                        }else{
                            push = [[BeaconPush alloc] init];
                            push.uuid = beacon.proximityUUID.UUIDString;
                            push.lastTime = current;
                            [_beacon_pushs addObject:push];
                        }

                        NSDictionary *cloudDic = [[NSDictionary alloc] initWithObjectsAndKeys:[PFInstallation currentInstallation].installationId, @"installationId", [beacon.proximityUUID.UUIDString lowercaseString], @"uuid",[NSNumber numberWithInt:beacon.major.intValue],@"major",[NSNumber numberWithInt:beacon.minor.intValue] ,@"minor",nil];

                        [PFCloud callFunctionInBackground:@"newBeacon" withParameters:cloudDic target:self selector:@selector(cloudResponse:)];
                    }
                }else{
                    PFQuery *normal = [PFQuery queryWithClassName:@"Beacons"];
                    [normal whereKey:@"udid" equalTo:beacon.proximityUUID.UUIDString];
                    
                    PFQuery *lower = [PFQuery queryWithClassName:@"Beacons"];
                    [lower whereKey:@"udid" equalTo:[beacon.proximityUUID.UUIDString lowercaseString]];
                    
                    PFQuery *query = [PFQuery orQueryWithSubqueries:@[normal,lower]];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if (!error && objects.count > 0) {
                            
                            PFQuery *query1 = [PFQuery queryWithClassName:@"Stations"];
                            [query1 whereKey:@"major" equalTo:beacon.major];
                            
                            [query1 findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                                if (!error && results.count > 0) {
                                    BOOL exsit = false;
                                    PFObject *obj1 = [results objectAtIndex:0];
                                    
                                    NSString *installationID = [PFInstallation currentInstallation].installationId;
                                    NSString *stationID = obj1.objectId;
                                    NSString *minorValue = [NSString stringWithFormat:@"%d", beacon.minor.intValue];
                                    
                                    [self initBeaconAnalytics:beacon forStation:stationID];
                                    // check beacon push time interval
                                    NSDate *current = [NSDate date];
                                    BeaconPush *push;
                                    
                                    for (int i = 0; i < _beacon_pushs.count; i ++) {
                                        push = [_beacon_pushs objectAtIndex:i];
                                        
                                        if ([push.uuid isEqualToString:beacon.proximityUUID.UUIDString]) {
                                            exsit = true;
                                            double interval = [current timeIntervalSinceDate:push.lastTime];
                                    
                                            if (interval < 3600.0f) {
                                                return;
                                            }
                                        }
                                    }
                                    
                                    if(exsit){
                                        [push setValue:current forKey:@"lastTime"];
                                        [_beacon_pushs setObject:push atIndexedSubscript:i];
                                    }else{
                                        push = [[BeaconPush alloc] init];
                                        push.uuid = beacon.proximityUUID.UUIDString;
                                        push.lastTime = current;
                                        [_beacon_pushs addObject:push];
                                    }
                                    
                                    NSDictionary *cloudDic = [[NSDictionary alloc] initWithObjectsAndKeys:installationID,@"objectID",stationID,@"StationID",minorValue,@"minorValue", nil];
                                    [PFCloud callFunctionInBackground:@"hello3" withParameters:cloudDic target:self selector:@selector(cloudResponse:)];
                                }
                            }];
                        }
                    }];
                }
            }
        } else {
            [self saveBeaconAnalytics];
        }
    }
}

- (void)cloudResponse:(id)sender
{
    NSLog(@"Cloud Response");
}

- (void)initBeaconAnalytics:(CLBeacon*)beacon forStation:(NSString*)stationID {
    self._visitEnter = [NSDate date];
    self._station_id = stationID;
    self._deal_id_pushed = @"";
    self._deals_viewed = [[NSMutableArray alloc] init];
    self._redeemedDealWithID = [[NSMutableArray alloc] init];
    self._beaconUDID = beacon.proximityUUID.UUIDString;
    self._beaconMajor = beacon.major;
    self._beaconMinor = beacon.minor;
    
    [self getPhoneHardware];
}

- (void)getPhoneHardware {
    self._phoneHardware = [[NSMutableArray alloc] init];
    [self._phoneHardware addObject:[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];
    [self._phoneHardware addObject:[UIDevice currentDevice].model];
    [self._phoneHardware addObject:[UIDevice currentDevice].identifierForVendor.UUIDString];
}

- (void)saveBeaconAnalytics {
    if (self._visitEnter != nil) {
        self._visitExit = [NSDate date];
        
        PFObject *obj = [PFObject objectWithClassName:@"beaconVisited"];
        [obj setObject:self._visitEnter forKey:@"visitEnter"];
        [obj setObject:self._visitExit forKey:@"visitExit"];
        [obj setObject:[PFInstallation currentInstallation].installationId forKey:@"installation_id"];
        [obj setObject:self._station_id forKey:@"station_id"];
        [obj setObject:self._deal_id_pushed forKey:@"deal_id_pushed"];
        [obj setObject:self._deals_viewed forKey:@"deals_viewed"];
        [obj setObject:self._redeemedDealWithID forKey:@"redeemedDealWithID"];
        [obj setObject:self._phoneHardware forKey:@"phoneHardware"];
        [obj setObject:self._beaconUDID forKey:@"beaconUDID"];
        [obj setObject:self._beaconMajor forKey:@"beaconMajor"];
        [obj setObject:self._beaconMinor forKey:@"beaconMinor"];
        obj[@"email"] = [PFUser currentUser][@"email"] != nil ? [PFUser currentUser][@"email"] : @"";
        [obj setObject:@"ios" forKey:@"platform"];
        
        [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            self._visitEnter = nil;
            [self._deals_viewed removeAllObjects]; self._deals_viewed = nil;
            [self._redeemedDealWithID removeAllObjects]; self._redeemedDealWithID = nil;
            [self._phoneHardware removeAllObjects]; self._phoneHardware = nil;
        }];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if(state == CLRegionStateInside)
    {
        
        [self.m_locationManager startMonitoringForRegion:region];
        [self.m_locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
    }
    else if(state == CLRegionStateOutside)
    {
        
        notification.alertBody = [NSString stringWithFormat:@"You are outside region %@", region.identifier];
    }
    else
    {
        return;
    }
}

#pragma Reward create part
- (void)saveRewardAvailableWithMilestoneType:(MilestoneType)milestonetype StationID:(NSString*)stationId{
    
    BOOL flag = NO;
    
    NSArray* keys = @[@"invited-friends", @"reward-shares", @"deal-redemptions", @"deal-shares", @"deal-likes", @"first-visit"];
    NSString* key = keys[milestonetype];
    
    if(stationId.length != 0){
        PFQuery* query = [PFQuery queryWithClassName:@"rewards"];
        [query whereKey:@"stations" equalTo:stationId];
        NSArray* results = [query findObjects];
        if(results.count == 0)
            return;
    }
    
    switch(milestonetype){
            
        case invited_friends:{
            
            int invited_friends_count = [m_dicRewardAvailable[key] intValue] + 1;
            if(invited_friends_count == [m_dicRewardCriteria[key] intValue] ) {
                invited_friends_count = 0;
                flag = YES;
            }
            
            [m_dicRewardAvailable setObject:[NSNumber numberWithInt:invited_friends_count] forKey:key];
            
        }
            break;
            
        case reward_shares:{
            
            BOOL isExists = NO;
            NSMutableArray* reward_shares_count = [[NSMutableArray alloc] initWithArray:m_dicRewardAvailable[key]];
            
            for(int i = 0; i < reward_shares_count.count; i ++){
                
                NSMutableArray* cell = [[NSMutableArray alloc] initWithArray:reward_shares_count[i]];
                if([cell[0] isEqualToString:stationId]){
                    
                    int sharecount = [cell[1] intValue] + 1;
                    if(sharecount == [m_dicRewardCriteria[key] intValue]){
                        sharecount = 0;
                        flag = YES;
                        
                    }
                    [cell replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:sharecount]];
                    
                    [reward_shares_count replaceObjectAtIndex:i withObject:cell];
                    
                    [m_dicRewardAvailable setObject:reward_shares_count forKey:key];
                    [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    isExists = YES;
                    
                }
                
            }
            
            if(!isExists){
                
                NSMutableArray* cell = [[NSMutableArray alloc] initWithArray:@[stationId, [NSNumber numberWithInt:1]]];
                [reward_shares_count addObject:cell];
                [m_dicRewardAvailable setObject:reward_shares_count forKey:key];
                [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            
        }
            break;
            
        case deal_redemptions:{ // frist deal redemption will give new reward
            
            BOOL isExists = NO;
            NSMutableArray* deal_redemptions_count = [[NSMutableArray alloc] initWithArray:m_dicRewardAvailable[key]];
            
            for(int i = 0; i < deal_redemptions_count.count; i ++){
                
                NSMutableArray* cell = [[NSMutableArray alloc] initWithArray:deal_redemptions_count[i]];
                if([cell[0] isEqualToString:stationId]){
                    
                    int redeemcount = [cell[1] intValue] + 1;
                    if(redeemcount == [m_dicRewardCriteria[key] intValue]){
                        redeemcount = 0;
                        flag = YES;
                        
                    }
                    [cell replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:redeemcount]];
                    
                    [deal_redemptions_count replaceObjectAtIndex:i withObject:cell];
                    
                    [m_dicRewardAvailable setObject:deal_redemptions_count forKey:key];
                    [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    isExists = YES;
                    
                }
                
            }
            
            if(!isExists){
                flag = YES; //for first deal redemption by RDH 2014 -11 -25
                NSMutableArray* cell = [[NSMutableArray alloc] initWithArray:@[stationId, [NSNumber numberWithInt:1]]];
                [deal_redemptions_count addObject:cell];
                [m_dicRewardAvailable setObject:deal_redemptions_count forKey:key];
                [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            
        }
            break;
            
        case deal_shares:{
            
            BOOL isExists = NO;
            NSMutableArray* deal_shares_count = [[NSMutableArray alloc] initWithArray:m_dicRewardAvailable[key]];
            
            for(int i = 0; i < deal_shares_count.count; i ++){
                
                NSMutableArray* cell = [[NSMutableArray alloc] initWithArray:deal_shares_count[i]];
                if([cell[0] isEqualToString:stationId]){
                    
                    int sharecount = [cell[1] intValue] + 1;
                    if(sharecount == [m_dicRewardCriteria[key] intValue]){
                        
                        sharecount = 0;
                        flag = YES;
                        
                    }
                    
                    [cell replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:sharecount]];
                    
                    [deal_shares_count replaceObjectAtIndex:i withObject:cell];
                    
                    [m_dicRewardAvailable setObject:deal_shares_count forKey:key];
                    [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    isExists = YES;
                    
                }
                
            }
            
            if(!isExists){
                
                NSMutableArray* cell = [[NSMutableArray alloc] initWithArray:@[stationId, [NSNumber numberWithInt:1]]];
                [deal_shares_count addObject:cell];
                [m_dicRewardAvailable setObject:deal_shares_count forKey:key];
                [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            
        }
            break;
            
        case deal_likes:{
            
            BOOL isExists = NO;
            NSMutableArray* deal_likes_count = [[NSMutableArray alloc] initWithArray:m_dicRewardAvailable[key]];
            
            for(int i = 0; i < deal_likes_count.count; i ++){
                
                NSMutableArray* cell = [[NSMutableArray alloc] initWithArray:deal_likes_count[i]];
                if([cell[0] isEqualToString:stationId]){
                    
                    int likescount = [cell[1] intValue] + 1;
                    if(likescount == [m_dicRewardCriteria[key] intValue]){
                        
                        likescount = 0;
                        flag = YES;
                        
                    }
                    
                    
                    [cell replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:likescount]];
                    
                    [deal_likes_count replaceObjectAtIndex:i withObject:cell];
                    
                    [m_dicRewardAvailable setObject:deal_likes_count forKey:key];
                    [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    isExists = YES;
                    
                }
                
            }
            
            if(!isExists){
                flag = YES; // for first deal liking by RDH 2014 -11- 25
                NSMutableArray* cell = [[NSMutableArray alloc] initWithArray:@[stationId, [NSNumber numberWithInt:1]]];
                [m_dicRewardAvailable setObject:deal_likes_count forKey:key];
                [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [deal_likes_count addObject:cell];
                
            }            
        }
            break;
            
        case first_visit:{
            
            NSMutableArray* visited_stations = [[NSMutableArray alloc] initWithArray:m_dicRewardAvailable[key]];
            
            if(![visited_stations containsObject:stationId]){
                
                flag = YES;
                [visited_stations addObject:stationId];
                
                [m_dicRewardAvailable setObject:visited_stations forKey:key];
                [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            
        }
            break;
            
        default:{
            
        }
            
    }
    
    if(flag){
        ///////////////// make reward ////////////////////
        
        PFQuery* query = [PFQuery queryWithClassName:@"rewards"];
        [query whereKeyDoesNotExist:@"deleted"];
        [query whereKey:@"slug" equalTo:key];
        [query whereKey:@"stations" equalTo:stationId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if(objects != nil  && [objects count] != 0 && error == nil){
                
                NSString * stationName;
                for(int i = 0; i < objects.count; i ++){
                    
                    PFObject* reward = objects[i];
                    RewardItem* item = [[RewardItem alloc] initWithEmptyObject];
                    item.rewardId = reward.objectId;
                    item.scratched = NO;
                    item.title = reward[@"title"];
                    item.description_ = reward[@"description"];
                    item.imageUrl = reward[@"imageURL"];
                    item.barcode = [reward[@"barcode"] stringValue];
                    item.obj_stations = reward[@"stations"];
                    item.newInstalled = NO;
                    item.coverImageID = arc4random() % 7;
                    item.stationId = stationId;
                    item.strSlug = key;
                    PFQuery* query = [PFQuery queryWithClassName:@"Stations"];
                    [query whereKey:@"objectId" equalTo:stationId];
                    PFObject* station = [query getFirstObject];
                    item.stationInfo = [NSString stringWithFormat:@"%@, %@, %@ ", station[@"street"], station[@"City"], station[@"State"]];
                    item.stationName = station[@"name"];
                    stationName = item.stationName;
                    
                    NSLog(@"%@", [item dictionary]);
                    
                    [g_aryRewards addObject:[item dictionary]];
                    
                    [[ParseService sharedInstance] recordRewardStateToParseWithStationID:stationId
                                                                                    Slug:item.strSlug
                                                                                   State:@"off"
                                                                                  DealID:@""];
                }
                
                NSLog(@"%@station name:", stationName);
                
                [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString* message;
                
                switch (milestonetype) {
                        
                    case invited_friends:
                        message = [NSString stringWithFormat:@"Thank you for liking %@'s deals! Scratch to see what you won at %@.", stationName, stationName];
                        break;
                        
                    case reward_shares:
                        message = [NSString stringWithFormat:@"You got a reward! Thank you for sharing your rewards at %@! Here is another reward for sharing. Scratch to see what you won at %@. Keep on sharing!", stationName, stationName];
                        break;
                        
                    case deal_redemptions:
                        message = [NSString stringWithFormat:@"You got a reward! Thank you for redeeming %@'s deals! Scratch to see what you won at %@.", stationName, stationName];
                        break;
                        
                    case deal_shares:
                        message = [NSString stringWithFormat:@"Thank you for sharing your %@'s deals! Here's a reward for doing so! Scratch to see what you won at %@. Keep on sharing!", stationName, stationName];
                        break;
                        
                    case deal_likes:
                        message = [NSString stringWithFormat:@"Thank you for liking %@'s deals! Scratch to see what you won at %@.", stationName, stationName];
                        break;
                        
                    case first_visit:
                        message = @"Welcome to our deals page! We have a special reward just for you.";
                        break;
                        
                    default:
                        break;
                }
                
                [[[UIAlertView alloc] initWithTitle:@"Congrats!"
                                            message:message
                                           delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"Get Reward", nil] show];
            }
        }];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:m_dicRewardAvailable forKey:DEFAULT_REWARD_AVAILABLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [g_tabController setSelectedIndex:2];
    }
}

@end
