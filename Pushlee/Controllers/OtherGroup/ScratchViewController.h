//
//  ScratchViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 9/30/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDScratchImageView.h"

@interface ScratchViewController : UIViewController <MDScratchImageViewDelegate, UIAlertViewDelegate>
{
	NSTimer *m_timer;
}

@property (nonatomic, retain) RewardItem* m_rewardItem;
@property (nonatomic, readwrite) int m_rewardNo;

@property (nonatomic, readwrite) BOOL flag;
@property (nonatomic, readwrite) long currentRewardBaseTime;

@property (weak, nonatomic) IBOutlet UILabel *m_lblRewardTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblStationName;
@property (weak, nonatomic) IBOutlet UILabel *m_lblRewardDescription;
@property (weak, nonatomic) IBOutlet UILabel *m_lblBarcode;
@property (weak, nonatomic) IBOutlet UILabel *m_lblStationAddress;

@property (weak, nonatomic) IBOutlet UIImageView *m_imgRewardUrl;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgBarcode;

- (IBAction)onClickShare:(id)sender;

@end
