//
//  StationSelectViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 9/30/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, PKAddPassesViewControllerDelegate>
{
    NSArray             *m_aryStations;
    UIButton            *m_btnSelected;
    
    RewardItem          *m_rewardItem;
    Station             *m_couponStation;
    PKPass              *m_pkPass;
}

@property (nonatomic, readwrite) int m_rewardNo;

@property (weak, nonatomic) IBOutlet UITableView *m_tblStations;

@end
