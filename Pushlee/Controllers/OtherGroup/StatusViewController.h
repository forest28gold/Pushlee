//
//  StatusViewController.h
//  Pushlee
//
//  Created by AppsCreationTech  on 06/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SuggestStationViewController;

@interface StatusViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *m_lblTotalDeals;
@property (weak, nonatomic) IBOutlet UILabel *m_lblRedeemDeals;
@property (weak, nonatomic) IBOutlet UILabel *m_lblCityName;
@property (weak, nonatomic) IBOutlet UILabel *m_lblStationName;

@end
