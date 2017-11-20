//
//  InviteFriendsViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-24.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteFriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSMutableArray *m_aryFriends;
    int m_nSelCount;
}

@property (strong, nonatomic) IBOutlet UITableView *m_tblFriends;
@property (strong, nonatomic) IBOutlet UIButton *m_btnSelect;

- (IBAction)onClickClose:(id)sender;
- (IBAction)onClickSend:(id)sender;
- (IBAction)onClickSelect:(id)sender;

@end
