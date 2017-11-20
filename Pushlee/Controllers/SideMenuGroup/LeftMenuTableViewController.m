//
//  LeftMenuTableViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 7/19/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "LeftMenuTableViewController.h"
#import "SideMenuCell.h"
#import "StationSelectViewController.h"

@interface LeftMenuTableViewController ()

@end

@implementation LeftMenuTableViewController

@synthesize m_leftMenuItems;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setScrollEnabled:NO];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"common_bkBar"] forBarMetrics:UIBarMetricsDefault];
    
    m_leftMenuItems = @[
                        @{@"imagename" : @"leftmenu_btnInvite.png",             @"title" : @"Invite Your Friends"},
//                      @{@"imagename" : @"leftmenu_btnInviteFB.png",  @"title" : @"Invite Fasebook Friends"},
                        @{@"imagename" : @"leftmenu_btnWalkThrough.png",        @"title" : @"Walkthrough"},
                        @{@"imagename" : @"leftmenu_btnDealProfile.png",        @"title" : @"Deal Profile"},
                        @{@"imagename" : @"leftmenu_btnFavoriteStation.png",    @"title" : @"Favorite Stations"},
                        @{@"imagename" : @"leftmenu_btnReceipt.png",            @"title" : @"Pushlee Receipts"},
                        @{@"imagename" : @"leftmenu_btnYourStats.png",          @"title" : @"Your Stats"},
                        @{@"imagename" : @"leftmenu_btnYourProfile.png",        @"title" : @"Your Profile"},
                        @{@"imagename" : @"leftmenu_btnLogout.png",             @"title" : @"Logout"}
                       ];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 51.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * view = [UIView new];
    [view setBackgroundColor:[UIColor grayColor]];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return m_leftMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIdentifier = @"SideMenuCell";
    SideMenuCell *cell = (SideMenuCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.m_lblText.text = [[m_leftMenuItems objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.m_imgIcon.image = [UIImage imageNamed:[[m_leftMenuItems objectAtIndex:indexPath.row] objectForKey:@"imagename"]];
    cell.backgroundColor = [UIColor grayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01f;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
  
    UIView * view = [UIView new];
    [view setBackgroundColor:[UIColor grayColor]];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch(indexPath.row){
            
        case 0:
            [self inviteYourFriend];
            break;

//        case 1:
//            [self inviteFBFriend];
//            break;
//
        case 1://2
            [self gotoWalkThrough];
            break;
            
        case 2://3
            [self showDealSurvey];
            break;
            
        case 3:
            [self showFavoriteStations];
            break;
            
        case 4:
            [self showPushleeReceipts];
            break;
            
        case 5://4
            [self pushStats];
            break;
            
        case 6://5
            [self pushYourProfile];
            break;
            
        case 7://6
            [self logout];
            break;
            
        default:
            break;
            
    }
    
}

- (void)inviteYourFriend
{
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:INVITE_FRIENDS_VIEW_CONTROLLER];
    [self presentViewController:vc animated:YES completion:^{
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }];
}

- (void)inviteFBFriend
{
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
    NSDictionary *parameters = @{@"to":@""};
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:FBSession.activeSession
                                                  message:@"Please Use Pushlee"
                                                    title:@"Invite Friends"
                                               parameters:parameters
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
     {
         if(error)
         {
             NSLog(@"Some errorr: %@", [error description]);
             UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Invitiation Sending Failed" message:@"Unable to send inviation at this Moment, please make sure your are connected with internet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alrt show];
             //[alrt release];
         }
         else
         {
             if (![resultURL query])
             {
                 return;
             }
             
             NSDictionary *params = [self parseURLParams:[resultURL query]];
             NSMutableArray *recipientIDs = [[NSMutableArray alloc] init];
             for (NSString *paramKey in params)
             {
                 if ([paramKey hasPrefix:@"to["])
                 {
                     [recipientIDs addObject:[params objectForKey:paramKey]];
                 }
             }
             if ([params objectForKey:@"request"])
             {
                 NSLog(@"Request ID: %@", [params objectForKey:@"request"]);
             }
             if ([recipientIDs count] > 0)
             {
                 UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                message:[NSString stringWithFormat:@"%lu Invitation(s) sent successfuly!", (unsigned long)recipientIDs.count]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                 [alrt show];
             }
             
         }
     }friendCache:nil];
    
}

- (NSDictionary *)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        
        [params setObject:[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                   forKey:[[kv objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return params;
}

-(void)gotoWalkThrough{

    UIViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:WALKTHROUGH_VIEW_CONTROLLER];
    [self presentViewController:ctrl animated:YES completion:^{
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }];

}

-(void)showDealSurvey{
    
    UIViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:DEAL_SURVEY_VIEW_CONTROLLER];
    [self presentViewController:ctrl animated:YES completion:^{
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }];
}

- (void)showFavoriteStations
{
    StationSelectViewController *ctrl = (StationSelectViewController *)[self.storyboard instantiateViewControllerWithIdentifier:STATION_SELECT_VIEW_CONTROLLER];
    ctrl.m_rewardNo = -2;
    [[g_tabController.viewControllers objectAtIndex:g_tabController.selectedIndex] pushViewController:ctrl animated:YES];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void)showPushleeReceipts
{
    UINavigationController *receiptVC = [self.storyboard instantiateViewControllerWithIdentifier:RECEIPT_VIEW_CONTROLLER];
    [[g_tabController.viewControllers objectAtIndex:g_tabController.selectedIndex] pushViewController:receiptVC animated:YES];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

-(void)pushStats{

    UIViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:STATUS_VIEW_CONTROLLER];
    [[g_tabController.viewControllers objectAtIndex:g_tabController.selectedIndex] pushViewController:ctrl animated:YES];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

-(void)pushYourProfile{
    
    UINavigationController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
    [[g_tabController.viewControllers objectAtIndex:g_tabController.selectedIndex] pushViewController:ctrl animated:YES];
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

-(void)logout{
    
    [PFUser logOut];
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    // When user log out then we must keep user-deal-survey as true
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_DEAL_SURVEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UINavigationController *ctrl = (UINavigationController*)[self.storyboard instantiateViewControllerWithIdentifier:LOGIN_NAVIGATION_CONTROLLER];
    [UIView transitionWithView:[appDelegate window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^(void) {
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[appDelegate window] setRootViewController:ctrl];
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:nil];
   [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

@end

