//
//  DealSurveyViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-26.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "DealSurveyViewController.h"
#import "DealSurvey.h"
#import "DealSurveyCell.h"

@interface DealSurveyViewController ()

@end

@implementation DealSurveyViewController

@synthesize m_tblDeals;
@synthesize m_btnBack;

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
	// Do any additional setup after loading the view.
	
    m_bOther = NO;
    m_bAddedNew = NO;
    
    m_aryDealNames = @[@"Breakfast Deal",
                       @"Breakfast Pizza Deal",
                       @"Candy Deal",
                       @"Car Wash Deal",
                       @"Chip Deal",
                       @"Doughnut Deal",
                       @"Energy Drink Deal",
                       @"Gum Deal",
                       @"Hardware",
                       @"Pizza Deal",
                       @"Pop Deal",
                       @"Roller Grill Deal"];
    
    m_aryDealSurveys = [[NSMutableArray alloc] init];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_DEAL_SURVEY])
        m_btnBack.hidden = YES;
    else
        m_btnBack.hidden = NO;
    
	[self getDealSurveys];
}

- (void)getDealSurveys
{
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
	
    [[ParseService sharedInstance] getDealSurveyWithUserId:g_myInfo.strUserId
                                                    Result:^(NSArray *aryDeals, NSString *strError) {
                                                        if(strError == nil)
                                                        {
                                                            [SVProgressHUD dismiss];
                                                            for(int nIndex = 0; nIndex < m_aryDealNames.count; nIndex++)
                                                            {
                                                                NSString *strDealName = [m_aryDealNames objectAtIndex:nIndex];
                                                                DealSurvey *dealSurvey = [[DealSurvey alloc] init];
                                                                dealSurvey.strDealName = strDealName;
                                                                
                                                                if([aryDeals containsObject:strDealName] || aryDeals.count == 0)
                                                                {
                                                                    dealSurvey.selected = YES;
                                                                }
                                                                else
                                                                    dealSurvey.selected = NO;
                                                                
                                                                [m_aryDealSurveys addObject:dealSurvey];                                                                    
                                                            }
                                                            
                                                            DealSurvey *otherDeal = [[DealSurvey alloc] init];
                                                            otherDeal.strDealName = @"Other";
                                                            otherDeal.selected = NO;
                                                            
                                                            [m_aryDealSurveys addObject:otherDeal];
                                                            
                                                            [m_tblDeals reloadData];
                                                        }
                                                        else
                                                        {
                                                            [SVProgressHUD showErrorWithStatus:strError];
                                                        }
                                                    }];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return m_aryDealSurveys.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row < m_aryDealSurveys.count)
    {
        DealSurveyCell* cell = (DealSurveyCell *)[tableView dequeueReusableCellWithIdentifier:@"DealSurveyCell" forIndexPath:indexPath];
        
        DealSurvey *dealSurvey = [m_aryDealSurveys objectAtIndex:indexPath.row];
        cell.lblDealName.text = dealSurvey.strDealName;
        
        if (dealSurvey.selected){
            [cell.btnSpinner setBackgroundImage:[UIImage imageNamed:@"img_checkedSpinner"] forState:UIControlStateNormal];
        } else {
            [cell.btnSpinner setBackgroundImage:[UIImage imageNamed:@"img_unCheckedSpinner"] forState:UIControlStateNormal];
        }
        [cell.btnSpinner setTag:indexPath.row + 100];
        [cell.btnSpinner addTarget:self action:@selector(onSelectDeal:) forControlEvents:UIControlEventTouchUpInside];
		
		return cell;
	}
	else if (indexPath.row == m_aryDealSurveys.count)
    {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherInputCell"];
		
        UITextField *txtOther = (UITextField *)[cell viewWithTag:200];
		UIButton *btnAdd = (UIButton *)[cell viewWithTag:11];
		
		if (m_bOther) {
			[txtOther setHidden:NO];
			[btnAdd setHidden:NO];
		} else {
			[txtOther setHidden:YES];
			[btnAdd setHidden:YES];
		}
		
		cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
		
		return cell;
	}
	else
    {
        static NSString *CellIdentifier = @"DealButtonCell";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);

        return cell;
    }
}

- (void)onSelectDeal:(UIButton *)sender
{
    DealSurvey *dealSurvey = [m_aryDealSurveys objectAtIndex:sender.tag - 100];
		
	if (dealSurvey.selected)
    {
		dealSurvey.selected = NO;
		[sender setBackgroundImage:[UIImage imageNamed:@"img_unCheckedSpinner"] forState:UIControlStateNormal];
	} else {
		dealSurvey.selected = YES;
		[sender setBackgroundImage:[UIImage imageNamed:@"img_checkedSpinner"] forState:UIControlStateNormal];
	}
    
    if([dealSurvey.strDealName isEqualToString:@"Other"])
        m_bOther = dealSurvey.selected;
    
    [m_tblDeals reloadData];
}

- (void)onClickGood:(id)sender
{
    [SVProgressHUD showWithStatus:@"Saving..." maskType:SVProgressHUDMaskTypeGradient];
    
    [[ParseService sharedInstance] saveUserDealSurveys:m_aryDealSurveys
                                            WithUserId:g_myInfo.strUserId
                                                Result:^(NSString *strError) {
                                                    if(strError == nil)
                                                    {
                                                        [SVProgressHUD dismiss];
                                                        if(![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_DEAL_SURVEY])
                                                        {
                                                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_DEAL_SURVEY];
                                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                                            
                                                            UIViewController *helpFriendsVC = [self.storyboard instantiateViewControllerWithIdentifier:HELP_FRIENDS_VIEW_CONTROLLER];
                                                            [self.navigationController pushViewController:helpFriendsVC animated:YES];
                                                        }
                                                        else
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                    }
                                                    else
                                                    {
                                                        [SVProgressHUD showErrorWithStatus:strError];
                                                    }
                                                }];
}

- (IBAction)onClickBack:(id)sender {
	if(m_bAddedNew)
		[self onClickGood:sender];
	else
		[self dismissViewControllerAnimated:YES completion:nil];	
}

- (IBAction)onClickOkay:(id)sender {
	[self onClickGood:sender];
}

- (IBAction)onClickOtherDealAdd:(id)sender {
    UITextField *txtOther = (UITextField *)[self.view viewWithTag:200];
    if([txtOther.text isEqualToString:@""])
        return;
    
    DealSurvey *dealSurvey = [[DealSurvey alloc] init];
    dealSurvey.strDealName = txtOther.text;
    dealSurvey.selected = YES;
    [m_aryDealSurveys insertObject:dealSurvey atIndex:m_aryDealSurveys.count - 1];
    
    [txtOther setText:@""];
    m_bAddedNew = YES;
    
    [m_tblDeals reloadData];
}

@end
