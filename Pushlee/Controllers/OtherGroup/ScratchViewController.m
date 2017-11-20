//
//  ScratchViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 9/30/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "ScratchViewController.h"
#import "UIImageView+AFNetworking.h"
#import <RSBarcodes.h>

@interface ScratchViewController ()

@end

@implementation ScratchViewController

@synthesize flag;
@synthesize m_rewardItem;
@synthesize m_rewardNo;
@synthesize currentRewardBaseTime;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self setBarButton];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void) checkDismissScratch:(NSTimer *) timer {
	
    m_rewardItem = [[RewardItem alloc] initWithDictionary:[g_aryRewards objectAtIndex:m_rewardNo]];
	if (m_rewardItem.baseTime == 1) {//TODO avoid access null instance
		
		[timer invalidate];
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Scratch card expired!"
                                                            message:@"This scratch card has expired. Keep on using Pushlee to earn great rewards!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
		[alertView show];
	}
}

- (void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
	
	m_rewardItem = [[RewardItem alloc] initWithDictionary:[g_aryRewards objectAtIndex:m_rewardNo]];
	currentRewardBaseTime = m_rewardItem.baseTime;
	m_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkDismissScratch:) userInfo:nil repeats:YES];

	[self.m_lblStationName setText:m_rewardItem.stationName]; // 2014-11-26 by yakun
	
	if(!m_rewardItem.scratched){
		
		m_rewardItem.newBaseTime = [[NSDate date] timeIntervalSince1970];
		g_aryRewards[m_rewardNo] = m_rewardItem.dictionary;
		[[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
		
        UIImage *bluredImage = [UIImage imageNamed:@"scratch_imgOverlay"];
        CGRect frame = self.view.frame;
        frame.origin.y -= 64.f;
        
        MDScratchImageView *scratchView = [[MDScratchImageView alloc] initWithFrame:frame];
		scratchView.delegate = self;
		scratchView.image = bluredImage;
        [self.view addSubview:scratchView];
		flag = NO;
	}

	
	[self.m_lblRewardTitle setText:self.m_rewardItem.title];
	[self.m_lblRewardDescription setText:self.m_rewardItem.description_];
	[self.m_lblStationAddress setText:self.m_rewardItem.stationInfo];
    [self.m_imgRewardUrl setImageWithURL:[NSURL URLWithString:m_rewardItem.imageUrl]];
		
	if(m_rewardItem.barcode.length != 0)
    {
        self.m_imgBarcode.image = [CodeGen genCodeWithContents:m_rewardItem.barcode machineReadableCodeObjectType:AVMetadataObjectTypeCode39Code];
    }
    else {
       [self.m_imgBarcode setImage:[UIImage imageNamed:@"barcode_imgDefault"]];
       self.m_lblBarcode.text = @"";
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self popBack];
}

- (void)viewWillDisappear:(BOOL)animated{
	
	[super viewWillDisappear:animated];

	self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
	
	[m_timer invalidate];
	m_timer = nil;
}

- (void)setBarButton {
	
	[self.navigationItem setTitle:@"Pushlee Rewards"];
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

-(void)popBack{
	
	m_rewardItem.scratched = YES;
	g_aryRewards[m_rewardNo] = m_rewardItem.dictionary;
    [[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
	
	[self.navigationController popToRootViewControllerAnimated:YES];
	
}

-(void)onLeftMenuClicked:(id)sender{
	
	[self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (void)mdScratchImageView:(MDScratchImageView *)scratchImageView didChangeMaskingProgress:(CGFloat)maskingProgress{

    if(flag)
		return;
	
	if(maskingProgress >= 0.4f){
		
		flag = YES;
		
		[scratchImageView setUserInteractionEnabled:NO];
		[UIView animateWithDuration:3.f animations:^{
			[scratchImageView setAlpha:0.f];
		} completion:^(BOOL finished) {
            [scratchImageView removeFromSuperview];
			m_rewardItem.scratched = YES;
			g_aryRewards[m_rewardNo] = m_rewardItem.dictionary;
			[[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
			
            [[ParseService sharedInstance] recordRewardStateToParseWithStationID:m_rewardItem.stationId
                                                                            Slug:m_rewardItem.strSlug
                                                                           State:@"on"
                                                                          DealID:@""];
		}];
    }
}

- (IBAction)onClickShare:(id)sender {
	[self.menuContainerViewController toggleRightSideMenuCompletion:nil];
}

@end
