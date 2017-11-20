//
//  LeftMenuTableViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 7/19/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuTableViewController : UITableViewController


@property (nonatomic, retain) NSArray* m_leftMenuItems;

- (void)inviteYourFriend;
- (void)inviteFBFriend;
- (void)gotoWalkThrough;
- (void)showDealSurvey;
- (void)pushStats;
- (void)pushYourProfile;
- (void)logout;

@end
