//
//  RedeemViewController.m
//  Pushlee
//
//  Created by AppsCreationTech  on 09/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#define __ NSLog(@"----%s -------->%d", __PRETTY_FUNCTION__, __LINE__)

#import "RedeemViewController.h"
#import "BarcodeViewController.h"
#import "UIImageView+AFNetworking.h"

@interface RedeemViewController ()

@end

@implementation RedeemViewController

@synthesize m_objDeal;
@synthesize m_objStation;

@synthesize m_lblDealTitle;
@synthesize m_lblDealDesc;
@synthesize m_lblDealPrice;
@synthesize m_lblDealSubTitle;
@synthesize m_lblDealSubTitleCity;
@synthesize m_btnDisLike;
@synthesize m_btnLike;
@synthesize m_imgDealImage;

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
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivePassBook:) name:@"PassBookNoti" object:nil];
	// Do any additional setup after loading the view from its nib.
}

//- (void)onReceivePassBook:(NSNotification *)notification
//{
//	PKAddPassesViewController *addController = [[notification userInfo] objectForKey:@"PKVC"];
//	[self presentViewController:addController animated:YES completion:nil];
//}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:YES];
	
    [[appDelegate m_aryViewedDealIDs] addObject:m_objDeal.strDealId];
    [[ParseService sharedInstance] saveViewedDeals:m_objDeal withStation:m_objStation];
	
	[m_imgDealImage setImageWithURL:[NSURL URLWithString:m_objDeal.strProductImageUrl]];
    [m_lblDealTitle setText:m_objDeal.strDealName];
	[m_lblDealPrice setText:[NSString stringWithFormat:@"Price: $ %.2f", [m_objDeal.nDealPrice floatValue]]];
	[m_lblDealDesc setText:m_objDeal.strDealDesc];
	[m_lblDealSubTitle setText:m_objStation.strStationName];
	[m_lblDealSubTitleCity setText:[NSString stringWithFormat:@"%@, %@, %@",
                                    m_objStation.strStationStreet,
                                    m_objStation.strStationCity,
                                    m_objStation.strStationState]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self likeDeals];
}

- (void)popBack {
	
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)likeDeals {
	
	NSLog(@"%@", [NSUserDefaults standardUserDefaults]);
	
    [[ParseService sharedInstance] getLikeDealWithUserId:g_myInfo.strUserId
                                               StationId:m_objStation.strStationId
                                                  DealId:m_objDeal.strDealId
                                                  Result:^(GEL_LIKE_DEAL_TYPE dealType) {
                                                      if(dealType == NO_DEAL)
                                                      {
                                                          [m_btnLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnLike"] forState:UIControlStateNormal];
                                                          [m_btnDisLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnUnlike"] forState:UIControlStateNormal];
                                                          
                                                          [m_btnLike setUserInteractionEnabled:YES];
                                                          [m_btnDisLike setUserInteractionEnabled:YES];
                                                      }
                                                      else
                                                      {
                                                          if(dealType == LIKE_DEAL)
                                                          {
                                                              [m_btnLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnFillLike"] forState:UIControlStateNormal];
                                                              [m_btnDisLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnUnlike"] forState:UIControlStateNormal];
                                                              
                                                              [m_btnLike setUserInteractionEnabled:NO];
                                                              [m_btnDisLike setUserInteractionEnabled:YES];
                                                          }
                                                          else
                                                          {
                                                              [m_btnLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnLike"] forState:UIControlStateNormal];
                                                              [m_btnDisLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnFillUnlike"] forState:UIControlStateNormal];
                                                              
                                                              [m_btnLike setUserInteractionEnabled:YES];
                                                              [m_btnDisLike setUserInteractionEnabled:NO];
                                                          }
                                                      }
                                                  }];
}

- (void)setBarButton {
    
    [self.navigationItem setTitle:@"Pushlee"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"common_bkBar"] forBarMetrics:UIBarMetricsDefault];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"Roboto-Light" size:20],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
	UIButton *menueButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 6, 30.0f, 30.0f)];
	[menueButton setBackgroundImage:[UIImage imageNamed:@"common_iconDisableMenu.png"] forState:UIControlStateNormal];
	[menueButton setBackgroundImage:[UIImage imageNamed:@"common_iconEnableMenu.png"] forState:UIControlStateSelected];
	[menueButton addTarget:self action:@selector(onLeftMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *menueButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menueButton];
	self.navigationItem.leftBarButtonItem = menueButtonItem;
	
	UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(260.0f, 6, 60.0f, 30.0f)];
	[backButton setTitle:@"Back" forState:UIControlStateNormal];
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[backButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0]];
	[backButton addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	self.navigationItem.rightBarButtonItem = backButtonItem;
}

-(void)onLeftMenuClicked:(id)sender{
	
	[self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark - IBActions

- (IBAction)btnRedeemClicked:(id)sender {
	
	// Barcode Generate
    if (g_isReachability == NO)
		[self showAlertViewWithMessage:@"No Internet Connection Available"];
	else {
        
        [[appDelegate m_aryRedeemDealIDs] addObject:m_objDeal.strDealId];
        
        [self updateRedeemDB];
	}
}

- (void)updateRedeemDB {
	
    [SVProgressHUD showWithStatus:@"Please wait..."
                         maskType:SVProgressHUDMaskTypeGradient];

    [[ParseService sharedInstance] saveRedeemDealWithStation:m_objStation
                                                        Deal:m_objDeal
                                                      Result:^(NSString *strError) {
                                                          if(strError == nil)
                                                          {
                                                              [SVProgressHUD dismiss];
                                                              [appDelegate saveRewardAvailableWithMilestoneType:deal_likes StationID:m_objStation.strStationId];
                                                              [self updateRedeemedDealDB];
                                                          }
                                                          else
                                                          {
                                                              [SVProgressHUD showErrorWithStatus:strError];
                                                          }
                                                          [self performSelectorOnMainThread:@selector(onGoToBarcodeViewController) withObject:nil waitUntilDone:NO];
                                                      }];
}

- (void)updateRedeemedDealDB {
    // Handling DB
    BOOL isUpdateStats = NO;
    sqlite3_stmt * ReturnStatement1;
    NSString *stringQuery1 = [NSString stringWithFormat:@"SELECT * FROM Stats"];
    ReturnStatement1 = [appDelegate getStatement:stringQuery1];
    while(sqlite3_step(ReturnStatement1) == SQLITE_ROW)
    {
        NSString *stnId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement1, 0)];
        NSString *redeemCount = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement1, 2)];
        
        if ([stnId isEqualToString:g_myInfo.strUserId]) {
            //Update
            isUpdateStats = YES;
            
            int redeemDeals = [redeemCount intValue];
            redeemDeals = redeemDeals + 1;
            NSString *strQuery = [NSString stringWithFormat:@"UPDATE Stats SET RedeemedDeals='%@' WHERE UserId='%@'",[NSString stringWithFormat:@"%d",redeemDeals],stnId];
            NSString *SqlStr = [NSString stringWithString:strQuery];
            [appDelegate InsUpdateDelData:SqlStr];
            break;
        }
    }
    
    if (isUpdateStats == NO) {
        //Insert
        int totalDeals = 0;
        int RedeemedDeals = 1;
        NSString *strQuery = [NSString stringWithFormat:@"INSERT INTO Stats(UserId,TotalDeals,RedeemedDeals) values('%@','%@','%@')", g_myInfo.strUserId, [NSString stringWithFormat:@"%d",totalDeals], [NSString stringWithFormat:@"%d", RedeemedDeals]];
        NSString *SqlStr = [NSString stringWithString:strQuery];
        [appDelegate InsUpdateDelData:SqlStr];
    }
}

- (void)onGoToBarcodeViewController
{
    BarcodeViewController *barcodeVC = [self.storyboard instantiateViewControllerWithIdentifier:BARCORD_VIEW_CONTROLLER];
    barcodeVC.m_objDeal = m_objDeal;
    barcodeVC.m_objStation = m_objStation;
    [self.navigationController pushViewController:barcodeVC animated:YES];
}

- (IBAction)btnThumbUpClicked:(id)sender {
	
	[m_btnLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnFillLike"] forState:UIControlStateNormal];
	[m_btnDisLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnUnlike"] forState:UIControlStateNormal];
    [self saveLikeAction:YES];
	
	[m_btnLike setUserInteractionEnabled:NO];
	[m_btnDisLike setUserInteractionEnabled:YES];
}

- (IBAction)btnThumbDownClicked:(id)sender {
	
	[m_btnDisLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnFillUnlike"] forState:UIControlStateNormal];
	[m_btnLike setBackgroundImage:[UIImage imageNamed:@"redeem_btnLike"] forState:UIControlStateNormal];
    [self saveLikeAction:NO];
	
	[m_btnLike setUserInteractionEnabled:YES];
	[m_btnDisLike setUserInteractionEnabled:NO];
}

- (IBAction)btnShareDealClicked:(id)sender {
	
	[self.menuContainerViewController toggleRightSideMenuCompletion:^{

        [appDelegate setM_strSharing:[NSString stringWithFormat:@"Check out this sweet deal! %@, %@ at %@, %@. Thanks Pushlee, I love your app! ",
                                      [m_lblDealTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                                      [m_lblDealDesc.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                                      [m_lblDealSubTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                                      [m_lblDealSubTitleCity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        
        [appDelegate setM_strSharingForTwitter:[NSString stringWithFormat:@"Check out this sweet deal! %@. Thanks Pushlee, I love your app! ",
                                                [m_lblDealTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
	}];
}

- (void)saveLikeAction:(BOOL)isLike {
	
	[SVProgressHUD showWithStatus:@"Saving..." maskType:SVProgressHUDMaskTypeGradient];
	
    [[ParseService sharedInstance] updateRedeemDealWithStationId:m_objStation.strStationId
                                                          DealId:m_objDeal.strDealId
                                                            Like:isLike
                                                          Result:^(NSString *strError) {
                                                              if(strError == nil)
                                                              {
                                                                  [SVProgressHUD dismiss];
                                                                  if(isLike)
                                                                      	[appDelegate saveRewardAvailableWithMilestoneType:deal_likes StationID:m_objStation.strStationId];
                                                              }
                                                              else
                                                                  [SVProgressHUD showErrorWithStatus:strError];
                                                          }];
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

@end

