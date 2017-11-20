

#import "DealsViewController.h"
#import "HotDealCell.h"
#import "UIImageView+AFNetworking.h"
#import "RedeemViewController.h"

@interface DealsViewController ()

@end

@implementation DealsViewController

@synthesize m_lblNoDeal;
@synthesize m_lblStationAddress;
@synthesize m_btnFindDeal;
@synthesize m_lblStationName;
@synthesize m_cltDeals;

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
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:YES];
	
	[m_lblStationName setText:@""];
	[m_lblStationAddress setText:@""];
	
	if([[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_LAST_VISITED_DEAL] != nil) {
		NSDate* last = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_LAST_VISITED_DEAL];
		
		double delta = [[NSDate date] timeIntervalSinceDate:last];
		if(delta > 3600){
			
			[[NSUserDefaults standardUserDefaults] setObject:nil forKey:DEFAULT_LAST_VISITED_STATION];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
		}
	}
    
    m_aryDeals = @[];
    [m_cltDeals reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (g_isReachability == NO)
        [self showAlertViewWithMessage:@"No Internet Connection Available"];
    else
        [self getParseData];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:DEFAULT_LAST_VISITED_DEAL];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UIBarButtons

- (void)setBarButton {
    [self.navigationItem setTitle:@"Deals"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"common_bkBar"] forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"Roboto-Light" size:20],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
	UIButton *menueButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 6, 30.0f, 30.0f)];
	[menueButton setBackgroundImage:[UIImage imageNamed:@"common_iconDisableMenu"] forState:UIControlStateNormal];
	[menueButton setBackgroundImage:[UIImage imageNamed:@"common_iconEnableMenu"] forState:UIControlStateSelected];
	[menueButton addTarget:self action:@selector(onLeftMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *menueButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menueButton];
	self.navigationItem.leftBarButtonItem = menueButtonItem;
	
	UIButton *shareButton = [[UIButton alloc] initWithFrame: CGRectMake(260.0f, 6, 30.0f, 30.0f)];
	[shareButton setBackgroundImage:[UIImage imageNamed:@"common_iconDisableShare"] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:@"common_iconEnableShare"] forState:UIControlStateSelected];
	[shareButton addTarget:self action:@selector(onRightMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
	self.navigationItem.rightBarButtonItem = shareButtonItem;
}


-(void)onRightMenuClicked:(id)sender{
	
	[self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

-(void)onLeftMenuClicked:(id)sender{
	
	[self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark - UICollectionView Delegates

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	return [m_aryDeals count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    HotDealCell *cell = (HotDealCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HotDealCell" forIndexPath:indexPath];
    
    Deal *deal = [m_aryDeals objectAtIndex:indexPath.row];
    [cell.imgDeal setImageWithURL:[NSURL URLWithString:deal.strProductImageUrl]];
    cell.strDealName.text = deal.strDealName;
    cell.strDealLocation.text = [NSString stringWithFormat:@"$%.2f - %@", [deal.nDealPrice floatValue], deal.strDealDesc];
    
    [cell.strDealName setFont:[UIFont fontWithName:@"Roboto-Light" size:17.f]];
    [cell.strDealLocation setFont:[UIFont fontWithName:@"Roboto-Light" size:12.f]];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	if(g_isReachability == NO)
		[self showAlertViewWithMessage:@"No Internet Connection Available"];
	else {	
        RedeemViewController *redeemVC = [self.storyboard instantiateViewControllerWithIdentifier:REDEEM_VIEW_CONTROLLER];
        redeemVC.m_objStation = m_objStation;
        redeemVC.m_objDeal = [m_aryDeals objectAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:redeemVC animated:YES];
    }
}

#pragma mark - Parse Data

- (void)getParseData {
	[m_lblNoDeal setHidden:YES];
	[m_btnFindDeal setHidden:YES];
		
	NSString *strStationId = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_LAST_VISITED_STATION];
	if(strStationId != nil)
		[appDelegate saveRewardAvailableWithMilestoneType:first_visit StationID:strStationId]; //TODO for visit first reward

	if (strStationId != nil && strStationId.length > 0) {
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeGradient];
        
        [[ParseService sharedInstance] getStationAndDealsWithStationId:strStationId
                                                               Station:^(Station *station) {
                                                                   if(station == nil)
                                                                   {
                                                                       [SVProgressHUD dismiss];
                                                                       
                                                                       [m_lblNoDeal setHidden:NO];
                                                                       [m_btnFindDeal setHidden:NO];
                                                                       
                                                                       [self.view bringSubviewToFront:m_btnFindDeal];
                                                                   }
                                                                   else
                                                                   {
                                                                       m_objStation = station;
                                                                       m_lblStationName.text = station.strStationName;
                                                                       m_lblStationAddress.text = [NSString stringWithFormat:@"%@\n%@, %@",
                                                                                                   station.strStationStreet,
                                                                                                   station.strStationCity,
                                                                                                   station.strStationState];
                                                                   }
                                                               } Deals:^(NSArray *aryDeals) {
                                                                   [SVProgressHUD dismiss];
                                                                   m_aryDeals = [NSArray arrayWithArray:aryDeals];
                                                                   [m_cltDeals reloadData];
                                                               }];
    }
    else
    {
        [m_lblNoDeal setHidden:NO];
        [m_btnFindDeal setHidden:NO];
        
        [self.view bringSubviewToFront:m_btnFindDeal];
    }
}

#pragma mark - UIAlertView

- (void)showAlertWithText:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
	[alert show];
}

#pragma mark - Show AlertView

- (void)showAlertViewWithMessage:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
	[alert show];
}

- (IBAction)onClickFindDeals:(id)sender {
	[g_tabController setSelectedIndex:3];
}

@end

