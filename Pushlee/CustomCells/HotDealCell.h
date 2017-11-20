//
//  HotDealCell.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/5/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotDealCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgDeal;
@property (weak, nonatomic) IBOutlet UILabel *strDealName;
@property (weak, nonatomic) IBOutlet UILabel *strDealLocation;

@end
