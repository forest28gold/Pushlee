//
//  BarcodeViewController.h
//  Pushlee
//
//  Created by AppsCreationTech  on 04/06/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarcodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *m_lblDealTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDealSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDealSubLocation;
@property (weak, nonatomic) IBOutlet UILabel *m_lblBarcode;

@property (weak, nonatomic) IBOutlet UIImageView *m_imgDealImage;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgDealBarcode;

@property (nonatomic,retain) Deal       *m_objDeal;
@property (nonatomic,retain) Station    *m_objStation;

- (IBAction)btnShareDealClicked:(id)sender;

@end
