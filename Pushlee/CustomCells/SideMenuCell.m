//
//  SideMenuCell.m
//  PAH Antibiotic
//
//  Created by AppsCreationTech  on 21/02/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "SideMenuCell.h"

@implementation SideMenuCell

@synthesize m_imgIcon;
@synthesize m_lblText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
