//
//  WalkthroughViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-25.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalkthroughViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *m_sclMain;
@property (weak, nonatomic) IBOutlet UIButton *m_btnStart;

- (IBAction)onClickBtnStart:(id)sender;

@end
