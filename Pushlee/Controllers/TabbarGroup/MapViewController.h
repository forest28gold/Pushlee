//
//  MapViewController.h
//  Pushlee
//
//  Created by AppsCreationTech  on 06/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray                 *m_aryAllStations;
    NSMutableArray          *m_aryStations;
    NSArray                 *m_aryStateNames;
    UIPickerView            *m_pickerState;
}

@property (strong, nonatomic) IBOutlet UIView *m_viewSearch;
@property (strong, nonatomic) IBOutlet UITextField *m_lblStationName;
@property (strong, nonatomic) IBOutlet UIImageView *m_imgStationNameLine;
@property (strong, nonatomic) IBOutlet UITextField *m_lblStationCity;
@property (strong, nonatomic) IBOutlet UIImageView *m_imgStationCityLine;
@property (strong, nonatomic) IBOutlet UITextField *m_lblStationState;
@property (strong, nonatomic) IBOutlet UIImageView *m_imgStationStateLine;
@property (strong, nonatomic) IBOutlet UILabel *m_lblNoStation;

@property (strong, nonatomic) IBOutlet UITableView *m_tblStations;
@property (strong, nonatomic) IBOutlet UILabel *m_lblNoNearStations;

@property (nonatomic, retain) IBOutlet UISegmentedControl     *mapSegmentControl;

- (IBAction)btnSearchClicked:(id)sender;
- (IBAction)segmentSwitch:(id)sender;
- (void)onRightMenuClicked:(id)sender;

@end
