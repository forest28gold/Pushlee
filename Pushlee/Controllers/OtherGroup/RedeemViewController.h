//
//  RedeemViewController.h
//  Pushlee
//
//  Created by AppsCreationTech  on 09/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"
#import "Deal.h"

@interface RedeemViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *m_lblDealTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDealSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDealSubTitleCity;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgDealImage;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDealDesc;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDealPrice;

@property (weak, nonatomic) IBOutlet UIButton *m_btnLike;
@property (weak, nonatomic) IBOutlet UIButton *m_btnDisLike;

@property (nonatomic,retain) Station        *m_objStation;
@property (nonatomic,retain) Deal           *m_objDeal;

- (IBAction)btnRedeemClicked:(id)sender;
- (IBAction)btnThumbUpClicked:(id)sender;
- (IBAction)btnThumbDownClicked:(id)sender;
- (IBAction)btnShareDealClicked:(id)sender;

@end
