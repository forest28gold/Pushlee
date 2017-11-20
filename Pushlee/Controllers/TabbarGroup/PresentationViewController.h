//
//  PresentationViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 9/29/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresentationViewController : UIViewController
{
	NSTimer * m_timer;
}

@property (weak, nonatomic) IBOutlet UICollectionView *m_tblRewards;

@property (nonatomic, retain) NSTimer* disCounter;

- (IBAction)onClickBtnHeader:(id)sender;

@end
