//
//  LeftMenuTableViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 7/19/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "RightMenuTableViewController.h"
#import "SideMenuCell.h"
#import <Social/Social.h>
#import "BarcodeViewController.h"
#import "RedeemViewController.h"
#import "NSString+XOR.h"
#import "ScratchViewController.h"

@interface RightMenuTableViewController ()

@end

@implementation RightMenuTableViewController

@synthesize m_rightMenuItems;

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"red-strip"] forBarMetrics:UIBarMetricsDefault];
    
    m_rightMenuItems = @[
                         @{@"imagename" : @"rightmenu_btnUser.png",       @"title" : @"Text Message"},
                         @{@"imagename" : @"rightmenu_btnFacebook.png",   @"title" : @"Facebook"},
                         @{@"imagename" : @"rightmenu_btnEmail.png",      @"title" : @"Email"},
                         @{@"imagename" : @"rightmenu_btnTwitter.png",    @"title" : @"Twitter"},
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 55.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * view = [UIView new];
    [view setBackgroundColor:[UIColor grayColor]];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return m_rightMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"SideMenuCell";
    SideMenuCell *cell = (SideMenuCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.m_lblText.text = [[m_rightMenuItems objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.m_imgIcon.image = [UIImage imageNamed:[[m_rightMenuItems objectAtIndex:indexPath.row] objectForKey:@"imagename"]];
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
            [self shareOnMessage];
            break;
        case 1:
            [self shareOnFacebook];
            break;
        case 2:
            [self shareOnEmail];
            break;
        case 3:
            [self shareOnTwitter];
            break;
    }
}

# pragma mark - Sharing Delegates

- (NSString*) getMessage:(int)index{
    
    NSString* email = g_myInfo.strUserEmail;
    int v = 1;
    if(email == nil){
        email = @"noemail@pushlee.com";
        v = 2;
    }
    
    NSString* share_link = [[NSString stringWithFormat:@"http://share.pushlee.com?from=%@&type=%@&v=%@"
                             , [email stringByEncodingWithCipher:@"k"]
                             , [@"deal" stringByEncodingWithCipher:@"k"]
                             , [[NSString stringWithFormat:@"%d", v] stringByEncodingWithCipher:@"k"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    NSString *sharingEvent;
    int selectedIndex = (int)g_tabController.selectedIndex;
    NSArray* viewControllers = [[g_tabController.viewControllers objectAtIndex:selectedIndex] viewControllers];
    
    if(selectedIndex == 1
       && ([viewControllers[viewControllers.count - 1] isKindOfClass:[RedeemViewController class]]
           || [viewControllers[viewControllers.count - 1] isKindOfClass:[BarcodeViewController class]])){
           
           sharingEvent = [appDelegate m_strSharing];
           if(sharingEvent != nil && ![sharingEvent isEqualToString:@""]){
               switch(index){
                       
                   case 1://facebook
                       
                       sharingEvent = [sharingEvent stringByReplacingOccurrencesOfString: @ "Thanks Pushlee" withString: @ "Thanks @PushleeApp"];
                       break;
                       
                   case 3://twitter
                       sharingEvent = [appDelegate m_strSharingForTwitter];
                       sharingEvent = [sharingEvent stringByReplacingOccurrencesOfString: @ "Thanks Pushlee" withString: @ "Thanks @GetPushlee"];
                       break;
               }
               
               return [sharingEvent stringByAppendingString:[@"Get it here: " stringByAppendingString:[[WebService sharedInstance] getShortURL:share_link]]];
           }
           
       }
    
    if(selectedIndex == 2 && [viewControllers[viewControllers.count - 1] isKindOfClass:[ScratchViewController class]]){
        
        ScratchViewController* vc = (ScratchViewController*)viewControllers[viewControllers.count - 1];
        //0: message 1: facebook 2: email 3: twitter
        switch(index){
                
            case 0:
            case 2:
                sharingEvent = [NSString stringWithFormat:@"Hey! I just won %@ at %@ in %@! You can win great rewards also to redeem them at participating Pushlee Gas Stations. Download Pushlee today to get rewarded!\n", vc.m_rewardItem.title, vc.m_rewardItem.stationName, vc.m_rewardItem.stationCity];
                break;
                
            case 1:
                sharingEvent = @"Hey! I just won a reward on @PushleeApp! #Download Pushlee today to get rewarded!\n";
                break;
                
            case 3:
                sharingEvent = @"Hey! I just won a reward on @GetPushlee! #Download Pushlee today to get rewarded!\n";
                break;
                
            default:
                sharingEvent = @"Check out Pushlee, a new app that saves you money at gas stations! It’s pretty awesome.\n";
                break;
                
        }
        
        return [sharingEvent stringByAppendingString:[@"Get it here: " stringByAppendingString:[[WebService sharedInstance] getShortURL:share_link]]];
        
    }
    
    switch(index){
            
        case 0:
            sharingEvent = @"Check out Pushlee, a new app that saves you money at gas stations! It’s pretty awesome. ";
            break;
            
        case 1:
            sharingEvent = @"Check out @PushleeApp, a new app that saves you money at gas stations! It’s pretty awesome. ";
            break;
            
        case 2:
            sharingEvent = @"Check out Pushlee, a new app that saves you money at gas stations! It’s pretty awesome. ";
            break;
            
        case 3:
            sharingEvent = @"Check out @GetPushlee, a new app that saves you money at gas stations! It’s pretty awesome. ";
            break;
            
        default:
            sharingEvent = @"Check out Pushlee, a new app that saves you money at gas stations! It’s pretty awesome. ";
            break;
            
    }
    
    return [sharingEvent stringByAppendingString:[@"Get it here: " stringByAppendingString:[[WebService sharedInstance] getShortURL:share_link]]];
}

- (void)shareOnTwitter {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [composeViewController setInitialText:[self getMessage:3]];
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
            UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:g_tabController.selectedIndex];
            
            if(g_tabController.selectedIndex == 2
               && (nav.viewControllers.count == 2 || nav.viewControllers.count == 3)){
                UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:2];
                ScratchViewController* scratchVC = (ScratchViewController *)nav.viewControllers[nav.viewControllers.count - 1];
                [appDelegate saveRewardAvailableWithMilestoneType:reward_shares StationID:scratchVC.m_rewardItem.stationId];
            }
            else if(g_tabController.selectedIndex == 1
                    && nav.viewControllers.count == 2){
                UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:1];
                RedeemViewController* redeemVC = (RedeemViewController *)nav.viewControllers[nav.viewControllers.count - 1];
                [appDelegate saveRewardAvailableWithMilestoneType:deal_shares StationID:redeemVC.m_objStation.strStationId];
            }
            
        }];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
    else
    {
        [self showAlertViewWithMessage:@"Sorry, You need to signin on settings"];
    }
}

- (void)shareOnFacebook {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [composeViewController setInitialText:[self getMessage:1]];
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            [self dismissViewControllerAnimated:YES completion:nil];
            
            UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:g_tabController.selectedIndex];
            
            if(g_tabController.selectedIndex == 2
               && (nav.viewControllers.count == 2 || nav.viewControllers.count == 3)){
                UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:2];
                ScratchViewController* scratchVC = (ScratchViewController *)nav.viewControllers[nav.viewControllers.count - 1];
                [appDelegate saveRewardAvailableWithMilestoneType:reward_shares StationID:scratchVC.m_rewardItem.stationId];
            }
            else if(g_tabController.selectedIndex == 1
                    && nav.viewControllers.count == 2){
                UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:1];
                RedeemViewController* redeemVC = (RedeemViewController*)nav.viewControllers[nav.viewControllers.count - 1];
                [appDelegate saveRewardAvailableWithMilestoneType:deal_shares StationID:redeemVC.m_objStation.strStationId];
            }
            
        }];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
    else
    {
        [self showAlertViewWithMessage:@"Sorry, You need to signin on settings"];
    }
}

- (void)shareOnMessage {
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *mesgInstance = [[MFMessageComposeViewController alloc] init];
        mesgInstance.body = [self getMessage:0];
        mesgInstance.messageComposeDelegate = self;
        [self presentViewController:mesgInstance animated:YES completion:nil];
    } else {
        [self showAlertViewWithMessage:@"Sorry, Your phone cannot send messages."];
    }
    
}

- (void)shareOnEmail {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Pushlee"];
        [controller setMessageBody:[self getMessage:2] isHTML:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        [self showAlertViewWithMessage:@"Sorry, You Phone has not Configured Mail"];
    }
}

#pragma mark Send Email

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            if(g_tabController.selectedIndex == 2){
                UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:2];
                ScratchViewController* scratchVC = (ScratchViewController *)nav.viewControllers[nav.viewControllers.count - 1];
                [appDelegate saveRewardAvailableWithMilestoneType:reward_shares StationID:scratchVC.m_rewardItem.stationId];
            }
            else if(g_tabController.selectedIndex == 1){
                UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:1];
                RedeemViewController* redeemVC = (RedeemViewController *)nav.viewControllers[nav.viewControllers.count - 1];
                [appDelegate saveRewardAvailableWithMilestoneType:deal_shares StationID:redeemVC.m_objStation.strStationId];
            }
            break;
        case MFMailComposeResultFailed: {
            [self showAlertViewWithMessage:@"You Phone has not Configured Mail"];
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Send Message

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
            if(g_tabController.selectedIndex == 2){
                UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:2];
                ScratchViewController* scratchVC = (ScratchViewController *)nav.viewControllers[nav.viewControllers.count - 1];
                [appDelegate saveRewardAvailableWithMilestoneType:reward_shares StationID:scratchVC.m_rewardItem.stationId];
            }
            else if(g_tabController.selectedIndex == 1){
                UINavigationController* nav = [g_tabController.viewControllers objectAtIndex:1];
                RedeemViewController* redeemVC = (RedeemViewController *)nav.viewControllers[nav.viewControllers.count - 1];
                [appDelegate saveRewardAvailableWithMilestoneType:deal_shares StationID:redeemVC.m_objStation.strStationId];
            }
            break;
        case MessageComposeResultFailed: {
            [self showAlertViewWithMessage:@"Message Not Sent"];
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Show AlertView

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end
