//
//  DealSurveyViewController.h
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-26.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealSurveyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *m_aryDealSurveys;
    NSArray        *m_aryDealNames;
    
    BOOL           m_bOther;
    BOOL           m_bAddedNew;
}

@property (weak, nonatomic) IBOutlet UITableView *m_tblDeals;
@property (strong, nonatomic) IBOutlet UIButton *m_btnBack;

- (IBAction)onClickBack:(id)sender;
- (IBAction)onClickOkay:(id)sender;
- (IBAction)onClickOtherDealAdd:(id)sender;


@end
