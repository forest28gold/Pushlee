//
//  HomeViewController.m
//  Pushlee
//
//  Created by AppsCreationTech  on 06/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#define __      NSLog(@"----->%s ---------->%d", __PRETTY_FUNCTION__, __LINE__)

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "HomeBannerView.h"
#import "UIImageView+AFNetworking.h"
#import "HotDealCell.h"
#import "RedeemViewController.h"
#import "MapViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize m_collectionView;
@synthesize m_srlContainer;
@synthesize m_pageControl;
@synthesize m_viewAddCard;
@synthesize m_btnLastestDeal;
@synthesize m_viewDeals;
@synthesize m_viewStationSuggetion;

#define ALERT_FIND_DEAL             101
#define ALERT_NO_DEAL               102
#define ALERT_SCRATCH_CARD          103
#define ALERT_NEW_REWARD            104
#define ALERT_PASS_BOOK             105

#define ADD_CARD_VIEW_HEIGHT        50
#define DEALS_VIEW_HEIGHT           244

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
        
    if(g_isGotMyLocation)
    {
        [self getTopDeals];
    }
    else
    {
        [self getHotDeals];
    }
    
    if([g_myInfo isNewUser])
    {
        [[ParseService sharedInstance] getNewInstallReward:^(NSDictionary *dicRewardItem)
        {
            if(dicRewardItem == nil)
            {
                NSLog(@"Error getting new install reward");
            }
            else
            {
                g_aryRewards = [NSMutableArray arrayWithObject:dicRewardItem];
                [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
        
        [self performSelector:@selector(showNewInstallRewardAlert) withObject:nil afterDelay:20];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"common_bkBar"] forBarMetrics:UIBarMetricsDefault];
    
    [self setBarButton];
    
    [SVProgressHUD showWithStatus:@"Getting Banner..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] getFeaturedSection:^(NSArray *aryBanners, NSString *strError) {
        
        if(strError == nil)
        {
            [SVProgressHUD dismiss];
            m_aryBanners = aryBanners;
            
            [m_pageControl setNumberOfPages:m_aryBanners.count];
            
            for(int i = 0; i < m_aryBanners.count; i ++)
            {
                HomeBanner *objBanner = [m_aryBanners objectAtIndex:i];
                
                HomeBannerView *viewBanner = [[[NSBundle mainBundle] loadNibNamed:@"HomeBannerView" owner:self options:nil] objectAtIndex:0];
                [viewBanner.m_imgBack setImageWithURL:[NSURL URLWithString:objBanner.strImageUrl]];
                [viewBanner.m_lblDesc setText:objBanner.strBannerDesc];

                [viewBanner setTag:i];
                
                UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickBanner:)];
                [viewBanner addGestureRecognizer:tap];
                
                [viewBanner setFrame:CGRectMake(m_srlContainer.frame.size.width * i,
                                                0,
                                                m_srlContainer.frame.size.width,
                                                m_srlContainer.frame.size.height)];
                [m_srlContainer addSubview:viewBanner];
            }
            [m_srlContainer setContentSize:CGSizeMake(m_srlContainer.frame.size.width * m_aryBanners.count, m_srlContainer.frame.size.height)];
        }
        else
            [SVProgressHUD showErrorWithStatus:strError];
    }];
    
    isSearchAroundStation = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchStations) name:NOTIFICATION_GOT_LOCATION object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}

#pragma mark - UINavigation Button

- (void)setBarButton {
    
    [self.navigationItem setTitle:@"Pushlee"];
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

- (void)getHotDeals
{
    [[ParseService sharedInstance] getHotDealsWithLatitude:g_myInfo.fUserLatitude
                                                 Longitude:g_myInfo.fUserLongitude
                                                    Result:^(NSArray *aryHotDeals, NSString *strError) {
                                                        if(strError == nil)
                                                        {
                                                            m_aryHotDeals = [NSMutableArray arrayWithArray:aryHotDeals];
                                                            [m_collectionView reloadData];
                                                            [m_viewStationSuggetion setHidden:YES];
                                                        }
                                                        else
                                                        {
                                                            [m_aryHotDeals removeAllObjects];
                                                            [m_collectionView reloadData];
                                                            [m_viewStationSuggetion setHidden:NO];
                                                            
                                                        }
                                                    }];
}

- (void)getTopDeals
{
    [[ParseService sharedInstance] getTopDealsWithLimit:6
                                                 Result:^(NSArray *aryTopDeals, NSString *strError) {
                                                     if(strError == nil)
                                                     {
                                                         m_aryHotDeals = [NSMutableArray arrayWithArray:aryTopDeals];
                                                         [m_collectionView reloadData];
                                                         [m_viewStationSuggetion setHidden:YES];
                                                     }
                                                     else
                                                     {
                                                         [m_aryHotDeals removeAllObjects];
                                                         [m_collectionView reloadData];
                                                         [m_viewStationSuggetion setHidden:NO];
                                                         
                                                     }
                                                 }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    [self getInviteDeal];
    [self getInviteInviteReward];
    [self checkPassbookStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    NSString* dealId = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_DEAL_ID];
    NSString* stationId = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_STATION_ID];
    NSString *latestDeal = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_LAST_DEAL];
    
    if(dealId != nil && stationId != nil && latestDeal.length > 0)
    {
        m_btnLastestDeal.hidden = NO;
        [m_btnLastestDeal setTitle:latestDeal forState:UIControlStateNormal];
    } else {
        m_btnLastestDeal.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)checkPassbookStatus
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_GOT_PASSBOOK])
    {
        [self.m_viewAddCard setHidden:YES];
        [self.m_viewDeals setFrame:CGRectMake(0,
                                              self.m_viewAddCard.frame.origin.y,
                                              self.view.frame.size.width,
                                              DEALS_VIEW_HEIGHT + ADD_CARD_VIEW_HEIGHT)];
    }
    else
    {
        [self.m_viewAddCard setHidden:NO];
        [self.m_viewDeals setFrame:CGRectMake(0,
                                              self.m_viewAddCard.frame.origin.y + self.m_viewAddCard.frame.size.height,
                                              self.view.frame.size.width,
                                              DEALS_VIEW_HEIGHT)];
    }

}

- (void)searchStations
{
    if(isSearchAroundStation)
        return;
    
    isSearchAroundStation = YES;
    [[ParseService sharedInstance] searchStationsWithinMiles:100
                                                      Result:^(NSArray *aryStations, NSString *strError) {
                                                          
                                                          if (strError == nil)
                                                          {
                                                              if(aryStations.count > 0)
                                                              {
                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pushlee"
                                                                                                                  message:@"Hey! We found stations near you!"
                                                                                                                 delegate:self
                                                                                                        cancelButtonTitle:@"No thanks"
                                                                                                        otherButtonTitles:@"View them",nil];
                                                                  alert.tag = ALERT_FIND_DEAL;
                                                                  [alert show];
                                                              }
                                                              else
                                                              {
                                                                  if (![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_INIT_STATION]) {
                                                                      NSString *name = [NSString stringWithFormat:@"%@ %@", g_myInfo.strUserFirstName, g_myInfo.strUserLastName];
                                                                      NSDictionary *cloudDic = @{
                                                                                                 @"email":g_myInfo.strUserEmail,
                                                                                                 @"name":name
                                                                                                 };
                                                                      [PFCloud callFunctionInBackground:@"sendEmailToInitialUserNoStations" withParameters:cloudDic target:self selector:@selector(cloudResponse:)];
                                                                  }
                                                                  
                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                                                  message:@"We're sorry, but we are unable to locate any deals near you.\nSuggest a station to us!"
                                                                                                                 delegate:self
                                                                                                        cancelButtonTitle:@"No thanks"
                                                                                                        otherButtonTitles:@"Suggest!",nil];
                                                                  alert.tag = ALERT_NO_DEAL;
                                                                  [alert show];
                                                              }
                                                              
                                                              [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_INIT_STATION];
                                                              [[NSUserDefaults standardUserDefaults] synchronize];
                                                          }
                                                      }];
}

- (void)cloudResponse:(id)sender {
    
    NSLog(@"Response");
    
}

#pragma mark-UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex != 1) return;
    
    if (alertView.tag == ALERT_FIND_DEAL) {
        [g_tabController setSelectedIndex:3];
    }
    else if (alertView.tag == ALERT_NO_DEAL) {
        UIViewController *suggestionVC = [self.storyboard instantiateViewControllerWithIdentifier:SUGGESTION_VIEW_CONTROLLER];
        [self.navigationController pushViewController:suggestionVC animated:YES];
        
    }
    else if (alertView.tag == ALERT_SCRATCH_CARD) {
        [g_tabController setSelectedIndex:2];
    }
    
    else if (alertView.tag == ALERT_NEW_REWARD) {
        [g_tabController setSelectedIndex:2];
    }
    else if (alertView.tag == ALERT_PASS_BOOK)
    {
        UIViewController *addStoreVC = [self.storyboard instantiateViewControllerWithIdentifier:ADD_STORE_VIEW_CONTROLLER];
        [self.navigationController pushViewController:addStoreVC animated:YES];
    }
}



- (IBAction)onClickLastDeal:(id)sender
{
    NSString* dealId = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_DEAL_ID];
    NSString* stationId = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_STATION_ID];
    
    if(dealId == nil || stationId == nil){
        
        [[[UIAlertView alloc] initWithTitle:@"Pushlee"
                                    message:@"There is an error on internal storage."
                                   delegate:nil cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
        return;
        
    }
    
    [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] getStationAndDealWithStationId:stationId
                                                           DealId:dealId
                                                           Result:^(Station *station, Deal *deal) {
                                                               if(station != nil && deal != nil)
                                                               {
                                                                   [SVProgressHUD dismiss];
                                                                   RedeemViewController *redeemVC = [self.storyboard instantiateViewControllerWithIdentifier:REDEEM_VIEW_CONTROLLER];
                                                                   redeemVC.m_objDeal = deal;
                                                                   redeemVC.m_objStation = station;
                                                                   [self.navigationController pushViewController:redeemVC animated:YES];
                                                               }
                                                               else
                                                               {
                                                                   [SVProgressHUD showErrorWithStatus:@"There is an error on internet connection."];
                                                               }
                                                           }];
}

- (void)onRightMenuClicked:(id)sender{
    
    [self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

- (void)onLeftMenuClicked:(id)sender{
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark - Set Date

- (IBAction)onClickSuggest:(id)sender {
    UIViewController *suggestionVC = [self.storyboard instantiateViewControllerWithIdentifier:SUGGESTION_VIEW_CONTROLLER];
    [self.navigationController pushViewController:suggestionVC animated:YES];
}

- (IBAction)onClickBtnAddCard:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passbook"
                                                    message:@"Would you like to add your Pushlee Card to your Passbook?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Continue", nil];
    [alert setTag:ALERT_PASS_BOOK];
    [alert show];
}

#pragma mark - CollectionView Delegates
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return 1;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return CGSizeMake(150, 200);
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [m_aryHotDeals count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HotDealCell* cell = (HotDealCell *)[m_collectionView dequeueReusableCellWithReuseIdentifier:@"HotDealCell"
                                                                             forIndexPath:indexPath];
    
    [cell setSelected:NO];
    HotDeal *objHotDeal = [m_aryHotDeals objectAtIndex:indexPath.row];
    
    [cell.imgDeal setImageWithURL:[NSURL URLWithString:objHotDeal.strImageUrl]];
    [cell.strDealName setText:objHotDeal.strDealName];
    [cell.strDealLocation setText:[NSString stringWithFormat:@"%@, %@", objHotDeal.strDealStreet, objHotDeal.strDealCity]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [SVProgressHUD showWithStatus:@"Please Wait..."];
    
    HotDeal *objHotDeal = [m_aryHotDeals objectAtIndex:indexPath.row];
    
    [[ParseService sharedInstance] getStationAndDealWithStationId:objHotDeal.strStationId
                                                           DealId:objHotDeal.strDealId
                                                           Result:^(Station *station, Deal *deal) {
                                                               if (station !=nil && deal != nil)
                                                               {
                                                                   [SVProgressHUD dismiss];
                                                                   
                                                                   RedeemViewController *redeemVC = [self.storyboard instantiateViewControllerWithIdentifier:REDEEM_VIEW_CONTROLLER];
                                                                   redeemVC.m_objDeal = deal;
                                                                   redeemVC.m_objStation = station;
                                                                   [g_tabController setSelectedIndex:1];
                                                                   [[g_tabController.viewControllers objectAtIndex:1] popToRootViewControllerAnimated:NO];
                                                                   [[g_tabController.viewControllers objectAtIndex:1] pushViewController:redeemVC animated:YES];
                                                               }
                                                               else
                                                               {
                                                                   [SVProgressHUD showErrorWithStatus:@"Sorry, It's invalid deal"];
                                                               }
                                                           }];
}

#pragma UIScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int newIndex = scrollView.contentOffset.x / m_srlContainer.frame.size.width;
    if(m_pageControl.currentPage == newIndex)
        return;
    
    [m_pageControl setCurrentPage:newIndex];
    
    HomeBanner *objBanner = m_aryBanners[m_pageControl.currentPage];
    NSLog(@"%@", objBanner);
    
    [[ParseService sharedInstance] saveSliderViewedWithUUID:objBanner.strUUID];
}

-(void)onClickBanner:(UITapGestureRecognizer *)sender
{
    HomeBanner *objBanner = m_aryBanners[sender.view.tag];
    [[ParseService sharedInstance] saveSliderClickedWithUUID:objBanner.strUUID];
    
    switch([objBanner.nTypeOfLink intValue]){
            
        case 1:{        // external page
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:objBanner.strLinkUrl]];
            break;
        }
        case 2:{        // dealID and StaionID
            
            NSString *dealId = objBanner.strDealId;
            NSString *stationId = objBanner.strStationId;
            
            if(dealId == nil || stationId == nil){
                
                [[[UIAlertView alloc] initWithTitle:@"Pushlee"
                                            message:@"There is an internet connection error."
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil, nil] show];
                return;
            }
            
            [SVProgressHUD showWithStatus:@"Please Wait..." maskType:SVProgressHUDMaskTypeGradient];
            [[ParseService sharedInstance] getStationAndDealWithStationId:stationId
                                                                   DealId:dealId
                                                                   Result:^(Station *station, Deal *deal) {
                                                                       if (station != nil && deal != nil) {
                                                                           [SVProgressHUD dismiss];
                                                                           RedeemViewController *redeemVC = [self.storyboard instantiateViewControllerWithIdentifier:REDEEM_VIEW_CONTROLLER];
                                                                           redeemVC.m_objStation = station;
                                                                           redeemVC.m_objDeal = deal;
                                                                           [self.navigationController pushViewController:redeemVC animated:YES];
                                                                       }
                                                                       else
                                                                           [SVProgressHUD showErrorWithStatus:@"There is an internet connection error."];

                                                                   }];
            break;
        }
        case 3:{        // Internal Redirection
            
            NSString* internalPage = objBanner.strInternalPage;
            
            if([internalPage isEqual:@"stationList"])
            {
                [g_tabController setSelectedIndex:3];
            }
            else if([internalPage isEqual:@"dealProfile"])
            {
                UIViewController *dealsVC = [self.storyboard instantiateViewControllerWithIdentifier:DEAL_SURVEY_VIEW_CONTROLLER];
                [self presentViewController:dealsVC animated:YES completion:nil];
            }
            else if([internalPage isEqual:@"inviteFriends"])
            {
                UIViewController *inviteFriendVC = [self.storyboard instantiateViewControllerWithIdentifier:INVITE_FRIENDS_VIEW_CONTROLLER];
                [self presentViewController:inviteFriendVC animated:YES completion:nil];
            }
            else if([internalPage isEqual:@"yourStats"])
            {
                UIViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:STATUS_VIEW_CONTROLLER];
                [self.navigationController pushViewController:ctrl animated:YES];
            }
            else if([internalPage isEqual:@"walkThrough"])
            {
                UIViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:WALKTHROUGH_VIEW_CONTROLLER];
                [self presentViewController:ctrl animated:YES completion:nil];
            }
            else if([internalPage isEqual:@"yourProfile"])
            {
                UIViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
                [self.navigationController pushViewController:profileVC animated:YES];
            }
            else if([internalPage isEqual:@"searchStations"])
            {
                UINavigationController *mapNC = (UINavigationController *)[g_tabController.viewControllers objectAtIndex:3];
                MapViewController *mapVC = [mapNC.viewControllers objectAtIndex:0];
                [mapVC.mapSegmentControl setSelectedSegmentIndex:1];
                [mapVC segmentSwitch:mapVC.mapSegmentControl];
                [g_tabController setSelectedIndex:3];
            }
            else if([internalPage isEqual:@"suggestStation"])
            {
                UINavigationController *mapNC = (UINavigationController *)[g_tabController.viewControllers objectAtIndex:3];
                MapViewController *mapVC = [mapNC.viewControllers objectAtIndex:0];
                [mapVC onRightMenuClicked:nil];
                [g_tabController setSelectedIndex:3];
            }
            break;
        }
        default:
            break;
    }
}

- (void)showNewInstallRewardAlert{
    
    UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"You have a new scratch card!"
                                                   message:@"Thanks for installing Pushlee. We have a special reward just for you! Click Ok to see your reward!"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Ok", nil];
    [view setTag:ALERT_SCRATCH_CARD];
    [view show];
    
}

-(void)getInviteInviteReward
{
    PFUser *user = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"InviteFriend"];
    [query whereKey:@"invitedEmail" equalTo:user.email];
    [query whereKeyExists:@"email"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object_in, NSError *error) {
        if (nil != object_in) {
            PFQuery * query_one = [PFQuery queryWithClassName:@"InviteFriend"];
            [query whereKey:@"invitedEmail" equalTo:object_in[@"email"]];
            
            PFQuery * query_two = [PFQuery queryWithClassName:@"InviteFriend"];
            [query whereKey:@"email" equalTo:object_in[@"invitedEmail"]];
            
            PFQuery *query = [PFQuery orQueryWithSubqueries:@[query_one, query_two]];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object_invite, NSError *error) {
                if(error == nil && object_invite !=nil){
                    [object_in delete];
                    
                    PFQuery* query_ = [PFQuery queryWithClassName:@"rewards"];
                    [query_ whereKey:@"slug" equalTo:@"invite-friend"];
                    
                    [query_ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if(objects !=nil && error == nil){
                            
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
                                item.newInstalled = YES;
                                item.coverImageID = arc4random() % 7;
                                item.disabledAt = reward[@"disabledAt"] != nil ? reward[@"disabledAt"] : [[NSArray alloc] init];
                                item.strSlug = reward[@"slug"];
                                
                                [g_aryRewards addObject:item.dictionary];
                            }
                            
                            [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"New reward!"
                                                                            message:@"You invited a friend, they signed up for Pushlee and then they invited you to Pushlee! Enjoy this reward. Thank you!"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Cancel"
                                                                  otherButtonTitles:@"Ok", nil];
                            alert.tag = ALERT_NEW_REWARD;
                            [alert show];
                            
                        }
                        
                    }];
                }
            }];
        } else {
            
        }
    }];
}

- (void)getInviteDeal{
    
    PFInstallation* installation = [PFInstallation currentInstallation];
    
    PFQuery* query = [PFQuery queryWithClassName:@"givingReward"];
    [query whereKey:@"installationId" equalTo:installation.installationId];
    [query whereKey:@"signed" equalTo:[NSNumber numberWithBool:YES]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        if(objects.count != 0 && error == nil){
            
            for(int i = 0; i < objects.count; i ++){
                
                PFObject* obj = objects[i];
                
                if([obj[@"friendEmail"] isEqualToString:[PFUser currentUser][@"email"]])
                    continue;
                PFQuery* query = [PFQuery queryWithClassName:@"InviteFriend"];
                [query whereKey:@"userid" equalTo:installation.objectId];
                [query whereKey:@"invitedEmail" equalTo:obj[@"friendEmail"]];
                
                NSArray* results = [query findObjects];
                for(PFObject* cell in results){
                    [cell delete];
                }
                
                [obj delete];
                
                PFQuery* query_ = [PFQuery queryWithClassName:@"rewards"];
                [query_ whereKey:@"slug" equalTo:@"invite-friend"];
                
                [query_ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if(objects != nil && error == nil){
                        
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
                            item.newInstalled = YES;
                            item.coverImageID = arc4random() % 7;
                            item.disabledAt = reward[@"disabledAt"] != nil ? reward[@"disabledAt"] : [[NSArray alloc] init];
                            item.strSlug = reward[@"slug"];
                            
                            [g_aryRewards addObject:item.dictionary];
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"New reward!"
                                                                        message:@"You invited a friend and they signed up for Pushlee! Enjoy this reward, thank you!"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:@"Ok", nil];
                        alert.tag = ALERT_NEW_REWARD;
                        [alert show];
                        
                    }
                    
                }];
                
            }
            
        }
    }];
}

-(BOOL) prefersStatusBarHidden
{
    return NO;
}

@end
