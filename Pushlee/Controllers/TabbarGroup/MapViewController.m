//
//  MapViewController.m
//  Pushlee
//
//  Created by AppsCreationTech  on 06/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "MapViewController.h"
#import "StationTableCell.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize m_imgStationCityLine;
@synthesize m_imgStationNameLine;
@synthesize m_imgStationStateLine;
@synthesize m_lblNoNearStations;
@synthesize m_lblNoStation;
@synthesize m_lblStationCity;
@synthesize m_lblStationName;
@synthesize m_lblStationState;
@synthesize m_tblStations;
@synthesize m_viewSearch;

@synthesize mapSegmentControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setBarButton];

    [mapSegmentControl setTintColor:[UIColor clearColor]];
    [mapSegmentControl setSelectedSegmentIndex:0];
    [self segmentSwitch:mapSegmentControl];
    [mapSegmentControl setImage:[[UIImage imageNamed:@"search_swtLeftEnable"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
    [mapSegmentControl setImage:[[UIImage imageNamed:@"search_swtRightDisable"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];

    [m_lblStationName setText:@""];
    [m_lblStationCity setText:@""];
    [m_lblStationState setText:@""];
    
    [self initStatesPicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - States Picker
- (void)initStatesPicker {
    m_pickerState = [[UIPickerView alloc] init];
    m_pickerState.delegate = self;
    
    [m_lblStationState setInputView:m_pickerState];
    [[ParseService sharedInstance] getAllStations:^(NSArray *aryStations) {
        m_aryAllStations = aryStations;
        
        NSMutableArray *aryAllStates = [[NSMutableArray alloc] init];
        for(int nIndex = 0; nIndex < m_aryAllStations.count; nIndex++)
        {
            Station *station = [m_aryAllStations objectAtIndex:nIndex];
            [aryAllStates addObject:station.strStationState];
        }
        
        m_aryStateNames = [[[NSSet setWithArray:aryAllStates] allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return m_aryStateNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [m_aryStateNames objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [m_lblStationState setText:[m_aryStateNames objectAtIndex:row]];
}

#pragma mark - UIBarButtons

- (void)setBarButton {
    
    [self.navigationItem setTitle:@"Search"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"common_bkBar"] forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"Roboto-Light" size:20],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    NSDictionary *textAttribute = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Roboto-Light" size:18], NSFontAttributeName, nil];
    [mapSegmentControl setTitleTextAttributes:textAttribute forState:UIControlStateNormal];
    [mapSegmentControl setTitleTextAttributes:textAttribute forState:UIControlStateSelected];
    
    UIButton *menueButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 6, 30.0f, 30.0f)];
    [menueButton setBackgroundImage:[UIImage imageNamed:@"common_iconDisableMenu"] forState:UIControlStateNormal];
    [menueButton setBackgroundImage:[UIImage imageNamed:@"common_iconEnableMenu"] forState:UIControlStateSelected];
    [menueButton addTarget:self action:@selector(onLeftMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menueButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menueButton];
    self.navigationItem.leftBarButtonItem = menueButtonItem;
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame: CGRectMake(200.0f, 6, 90.0f, 30.0f)];
    [shareButton setTitle:@"Suggest" forState:UIControlStateNormal];
    [shareButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0]];
    [shareButton addTarget:self action:@selector(onRightMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    self.navigationItem.rightBarButtonItem = shareButtonItem;
}


-(void)onRightMenuClicked:(id)sender{
  
    UIViewController* suggestVC = [self.storyboard instantiateViewControllerWithIdentifier:SUGGESTION_VIEW_CONTROLLER];
    [self.navigationController pushViewController:suggestVC animated:YES];
    
}

-(void)onLeftMenuClicked:(id)sender{
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark - UIBarButton Items

- (IBAction)btnSearchClicked:(id)sender {
    
    [m_lblStationName resignFirstResponder];
    [m_lblStationCity resignFirstResponder];
    [m_lblStationState resignFirstResponder];
    
    NSString *trimmedName = [[m_lblStationName.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedCity = [[m_lblStationCity.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedState = [[m_lblStationState.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [m_lblNoStation setHidden:YES];
    
    if (trimmedName.length < 1 && trimmedCity.length < 1 && trimmedState.length < 1) {
        [self showAlertViewWithMessage:@"Please fill in at least one field to search for stations with great deals!"];
        return;
    }
   
    m_aryStations = [[NSMutableArray alloc] init];
    NSArray *aryTempStations = [NSArray arrayWithArray:m_aryAllStations];
    if(trimmedName.length > 0)
    {
        for(int nIndex = 0; nIndex < aryTempStations.count; nIndex++)
        {
            Station *station = [aryTempStations objectAtIndex:nIndex];
            if ([station.strSearchName rangeOfString:trimmedName options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [m_aryStations addObject:station];
            }
        }
        
        aryTempStations = [NSArray arrayWithArray:m_aryStations];
    }
    
    if(trimmedCity.length > 0)
    {
        [m_aryStations removeAllObjects];
        for(int nIndex = 0; nIndex < aryTempStations.count; nIndex++)
        {
            Station *station = [aryTempStations objectAtIndex:nIndex];
            if ([station.strSearchState isEqualToString:trimmedCity])
            {
                [m_aryStations addObject:station];
            }
        }
        
        aryTempStations = [NSArray arrayWithArray:m_aryStations];
    }
    
    if(trimmedState.length > 0)
    {
        [m_aryStations removeAllObjects];
        for(int nIndex = 0; nIndex < aryTempStations.count; nIndex++)
        {
            Station *station = [aryTempStations objectAtIndex:nIndex];
            if ([station.strSearchState isEqualToString:trimmedState])
            {
                [m_aryStations addObject:station];
            }
        }
        
        aryTempStations = [NSArray arrayWithArray:m_aryStations];
    }
    
    if(m_aryStations.count == 0)
    {
        [m_lblNoStation setHidden:NO];
    }
    else
    {
        [m_lblNoStation setHidden:YES];
        [m_viewSearch setHidden:YES];
        [m_tblStations setHidden:NO];
        [m_tblStations reloadData];
    }
}

#pragma mark UISegment Control

- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //toggle the correct view to be visible
        NSLog(@"Map Clicked");
        [m_tblStations setHidden:NO];
        [m_viewSearch setHidden:YES];
        [m_lblNoNearStations setHidden:YES];
        
        [mapSegmentControl setImage:[[UIImage imageNamed:@"search_swtLeftEnable"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [mapSegmentControl setImage:[[UIImage imageNamed:@"search_swtRightDisable"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
        
        [self getNearStations];
    }
    else{
        NSLog(@"Search Clicked");

        [m_tblStations setHidden:YES];
        [m_viewSearch setHidden:NO];
        [m_lblNoNearStations setHidden:YES];
        [m_lblNoStation setHidden:YES];
        
        [mapSegmentControl setImage:[[UIImage imageNamed:@"search_swtLeftDisable"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [mapSegmentControl setImage:[[UIImage imageNamed:@"search_swtRightEnable"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
    }
}

#pragma mark - UITextField Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        [m_imgStationNameLine setImage:[UIImage imageNamed:@"search_imgSelectedLine"]];
        [m_imgStationCityLine setImage:[UIImage imageNamed:@"search_imgUnselectedLine"]];
        [m_imgStationStateLine setImage:[UIImage imageNamed:@"search_imgUnselectedLine"]];
    } else if (textField.tag == 1) {
        [m_imgStationNameLine setImage:[UIImage imageNamed:@"search_imgUnselectedLine"]];
        [m_imgStationCityLine setImage:[UIImage imageNamed:@"search_imgSelectedLine"]];
        [m_imgStationStateLine setImage:[UIImage imageNamed:@"search_imgUnselectedLine"]];
    }
    else {
        [m_imgStationNameLine setImage:[UIImage imageNamed:@"search_imgUnselectedLine"]];
        [m_imgStationCityLine setImage:[UIImage imageNamed:@"search_imgUnselectedLine"]];
        [m_imgStationStateLine setImage:[UIImage imageNamed:@"search_imgSelectedLine"]];
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        [m_imgStationNameLine setImage:[UIImage imageNamed:@"search_imgUnselectedLine"]];
    } else if (textField.tag == 1) {
        [m_imgStationCityLine setImage:[UIImage imageNamed:@"search_imgUnselectedLine"]];
    }
    else {
        [m_imgStationStateLine setImage:[UIImage imageNamed:@"search_imgUnselectedLine"]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}

-(void) getNearStations
{
    if(g_isGotMyLocation == NO)
    {
        [m_lblNoNearStations setHidden:NO];
        [m_tblStations setHidden:YES];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeGradient];
    
    [[ParseService sharedInstance] searchStationsWithinMiles:100
                                                      Result:^(NSArray *aryStations, NSString *strError) {
                                                          [SVProgressHUD dismiss];
                                                          if(strError == nil && aryStations.count > 0)
                                                          {
                                                              m_aryStations = [NSMutableArray arrayWithArray:aryStations];
                                                              [m_tblStations reloadData];
                                                          }
                                                          else
                                                          {
                                                              [m_tblStations setHidden:YES];
                                                              [m_lblNoNearStations setHidden:NO];
                                                          }
                                                      }];
}

#pragma mark - Show AlertView

- (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_aryStations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StationTableCell";
    StationTableCell *cell = (StationTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Station *station = [m_aryStations objectAtIndex:indexPath.row];
    
    cell.lblStationName.text = station.strStationName;
    cell.lblStationLocation.text = [NSString stringWithFormat:@"%@ %@", station.strStationStreet, [station.strStationCity capitalizedString]];
    cell.lblStationDistance.text = [NSString stringWithFormat:@"%.2f Mi", station.getDistanceFromMe];
    [cell.btnStationSpinner setHidden:YES];
    
    return cell;    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    Station *station = [m_aryStations objectAtIndex:indexPath.row];
   
    [[NSUserDefaults standardUserDefaults] setValue:station.strStationId forKey:DEFAULT_LAST_VISITED_STATION];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULT_LAST_VISITED_DEAL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tabBarController setSelectedIndex:1];
    [[[self.tabBarController viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:YES];
}

@end
