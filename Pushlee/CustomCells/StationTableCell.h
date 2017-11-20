//
//  StationTableCell.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/6/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblStationName;
@property (strong, nonatomic) IBOutlet UILabel *lblStationLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblStationDistance;
@property (strong, nonatomic) IBOutlet UIButton *btnStationSpinner;

@end
