//
//  StationTableCell.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/6/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "StationTableCell.h"

@implementation StationTableCell

@synthesize btnStationSpinner;

- (void)awakeFromNib {
    // Initialization code
    
    [btnStationSpinner setImage:[UIImage imageNamed:@"img_unCheckedSpinner"] forState:UIControlStateNormal];
    [btnStationSpinner setImage:[UIImage imageNamed:@"img_checkedSpinner"] forState:UIControlStateSelected];    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
