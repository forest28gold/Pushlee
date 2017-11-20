//
//  BarcodeViewController.m
//  Pushlee
//
//  Created by AppsCreationTech  on 04/06/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "BarcodeViewController.h"
#import "UIImageView+AFNetworking.h"
#import <RSBarcodes.h>

@interface BarcodeViewController ()

@end

@implementation BarcodeViewController

@synthesize m_objDeal;
@synthesize m_objStation;

@synthesize m_imgDealBarcode;
@synthesize m_imgDealImage;
@synthesize m_lblDealSubLocation;
@synthesize m_lblDealSubTitle;
@synthesize m_lblDealTitle;
@synthesize m_lblBarcode;

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

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	[m_imgDealImage setImageWithURL:[NSURL URLWithString:m_objDeal.strProductImageUrl]];
	[m_lblDealTitle setText:m_objDeal.strDealName];
	[m_lblDealSubTitle setText:m_objStation.strStationName];
    [m_lblDealSubLocation setText:[NSString stringWithFormat:@"%@, %@, %@",
                                    m_objStation.strStationStreet,
                                    m_objStation.strStationCity,
                                    m_objStation.strStationState]];
	
	[self showBarcode];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)showBarcode  {
	NSString *productId = [m_objDeal.strProductId stringByReplacingOccurrencesOfString:@" " withString:@""];
	if (productId.length > 0) {
		[m_lblBarcode setText:productId];
		
		m_imgDealBarcode.image = [CodeGen genCodeWithContents:productId machineReadableCodeObjectType:AVMetadataObjectTypeCode39Code];
	}
	else {
		[m_imgDealBarcode setImage:[UIImage imageNamed:@"barcode_imgDefault"]];
		m_lblBarcode.text = @"";
	}
}

- (IBAction)btnShareDealClicked:(id)sender {
    
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        
        [appDelegate setM_strSharing:[NSString stringWithFormat:@"Check out this sweet deal! %@ at %@, %@. Thanks Pushlee, I love your app! ",
                                      [m_lblDealTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                                      [m_lblDealSubTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                                      [m_lblDealSubLocation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        
        [appDelegate setM_strSharingForTwitter:[NSString stringWithFormat:@"Check out this sweet deal! %@. Thanks Pushlee, I love your app! ",
                                                [m_lblDealTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
    }];
}

#pragma mark - UINavigation Button

- (void)setBarButton {
    
    [self.navigationItem setTitle:@"Pushlee"];
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
    
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(260.0f, 6, 60.0f, 30.0f)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Light" size:17.0]];
    [backButton addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = backButtonItem;
}

- (void)popBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onLeftMenuClicked:(id)sender{
	
	[self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

@end
