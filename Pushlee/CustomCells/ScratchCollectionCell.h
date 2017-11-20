//
//  ScratchCollectionCell.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/6/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScratchCollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgScratch;
@property (strong, nonatomic) IBOutlet UILabel *lblScratchOff;
@property (strong, nonatomic) IBOutlet UILabel *lblScratchInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblScratchState;
@end
