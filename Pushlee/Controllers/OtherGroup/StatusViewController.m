//
//  StatusViewController.m
//  Pushlee
//
//  Created by AppsCreationTech  on 06/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "StatusViewController.h"
#import "SuggestStationViewController.h"
#import "AppDelegate.h"

@interface StatusViewController ()

@end

@implementation StatusViewController

@synthesize m_lblCityName;
@synthesize m_lblRedeemDeals;
@synthesize m_lblStationName;
@synthesize m_lblTotalDeals;

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
    
    sqlite3_stmt * ReturnStatement;
    NSString *stringQuery = [NSString stringWithFormat:@"SELECT * FROM Pushlee WHERE Count=(Select MAX(Count) FROM Pushlee Group By Count)"];
    ReturnStatement = [appDelegate getStatement:stringQuery];
    while(sqlite3_step(ReturnStatement) == SQLITE_ROW)
    {
        NSString *stnName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement, 1)];
        NSString *stnAddress = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement, 2)];

        [m_lblStationName setText:stnName];
        [m_lblCityName setText:stnAddress];
        
        break;
    }
    
    sqlite3_stmt * ReturnStatement1;
    NSString *stringQuery1 = [NSString stringWithFormat:@"SELECT * FROM Stats"];
    ReturnStatement1=[appDelegate getStatement:stringQuery1];
    while(sqlite3_step(ReturnStatement1) == SQLITE_ROW)
    {
        NSString *stnId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement1, 0)];
        NSString *dealCount = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement1, 1)];
        NSString *redeemCount = [NSString stringWithUTF8String:(char *)sqlite3_column_text(ReturnStatement1, 2)];
        
        if ([stnId isEqualToString:g_myInfo.strUserId]) {
            [m_lblTotalDeals setText:dealCount];
            [m_lblRedeemDeals setText:redeemCount];
            break;
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigations

- (void)setBarButton {
    
    [self.navigationItem setTitle:@"Stats"];
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
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame: CGRectMake(260.0f, 6, 30.0f, 30.0f)];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"common_iconDisableShare.png"] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"common_iconEnableShare.png"] forState:UIControlStateSelected];
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

#pragma mark - Show AlertView

- (void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end
