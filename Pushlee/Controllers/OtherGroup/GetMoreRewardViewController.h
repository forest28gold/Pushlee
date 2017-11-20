//
//  GetMoreRewardViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 10/22/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetMoreRewardViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *m_sclGuide;
@property (weak, nonatomic) IBOutlet UILabel *pushlee_header;
- (IBAction)onClickBtnNavigation:(id)sender;
- (IBAction)onClickBtnBack:(id)sender;
@end
