//
//  LeftMenuTableViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 7/19/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface RightMenuTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic,  retain) NSArray* m_rightMenuItems;

@end
