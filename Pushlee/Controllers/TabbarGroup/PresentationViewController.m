//
//  PresentationViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 9/29/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "PresentationViewController.h"
#import "ScratchViewController.h"
#import "StationSelectViewController.h"
#import "ScratchCollectionCell.h"
#import "UIImageView+AFNetworking.h"

@interface PresentationViewController ()

@end

@implementation PresentationViewController

@synthesize disCounter;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self setBarButton];
    
  	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGotReward:) name:NOTIFICATION_GOT_REWARD object:nil];
}

-(void)onGotReward:(NSNotificationCenter *)notification
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self.m_tblRewards reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(disCount:) userInfo:nil repeats:YES];
	[self.m_tblRewards reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [m_timer invalidate];
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

#pragma UICollectionViewController

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	
	return g_aryRewards.count;
	
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	
	ScratchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScratchCollectionCell" forIndexPath:indexPath];
	
	[cell.lblScratchInfo setHidden:YES];
	[cell.lblTime setHidden:YES];
	
	RewardItem* item = [[RewardItem alloc] initWithDictionary:g_aryRewards[indexPath.row]];
    [cell.imgScratch setImage:[UIImage imageNamed:[NSString stringWithFormat:@"scratch_%d", item.coverImageID]]];
    cell.lblScratchOff.text = @"Scratch off!";
    cell.lblScratchState.text = @"Click here to reveal!";
	
	if(item.scratched){
		long now =[[NSDate date] timeIntervalSince1970]; ;
		long elipseTime = (item.newBaseTime + 600) - now ;
		
		[cell.lblScratchOff setText:item.title];
		[cell.lblScratchState setText:@"Redeem now before it's gone!"];
		[cell.lblScratchInfo setText:[NSString stringWithFormat:@"%@ %@", item.stationName, item.stationInfo]];
		[cell.lblScratchInfo setHidden:NO];
		[cell.lblTime setHidden:NO];
		[cell.lblTime setText:[NSString stringWithFormat:@"%02d:%02d", (int)elipseTime / 60, (int)elipseTime % 60]];
        [cell.imgScratch setImageWithURL:[NSURL URLWithString:item.imageUrl]];
	}
	
	cell.layer.cornerRadius = 5.f;
	cell.layer.borderWidth = 1.5f;
	cell.layer.borderColor = [[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:.05f] CGColor];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	
	RewardItem* item = [[RewardItem alloc] initWithDictionary:g_aryRewards[indexPath.row]];
	
	if(item.scratched == NO && !item.newInstalled){
		UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"Card expires in 10 minutes"
                                                       message:@"Are you sure you want to reveal your prize now? You will have 10 minutes to redeem your prize before it expires."
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Ok", nil];
		[view setTag:indexPath.row];
		[view show];
		return;
        
	}else if(item.newInstalled){
		StationSelectViewController* stationsVC = [self.storyboard instantiateViewControllerWithIdentifier:STATION_SELECT_VIEW_CONTROLLER];
		stationsVC.m_rewardNo = (int)indexPath.row;
		[self.navigationController pushViewController:stationsVC animated:YES];
	}else{
		ScratchViewController* scratchVC = [self.storyboard instantiateViewControllerWithIdentifier:SCRATCH_VIEW_CONTROLLER];
		scratchVC.m_rewardNo = (int)indexPath.row;
		[self.navigationController pushViewController:scratchVC animated:YES];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)    return;
	
	ScratchViewController* scratchVC = [self.storyboard instantiateViewControllerWithIdentifier:SCRATCH_VIEW_CONTROLLER];
	scratchVC.m_rewardNo = (int)alertView.tag;
	[self.navigationController pushViewController:scratchVC animated:YES];
}

- (void)disCount:(id)sender{
	
	BOOL flag = NO;

	for(int i = 0; i < g_aryRewards.count; i ++){
		
		RewardItem* item = [[RewardItem alloc] initWithDictionary:[g_aryRewards objectAtIndex:i]];

		long now = [[NSDate date] timeIntervalSince1970]; ;
		long elipseTime = (item.newBaseTime + 600) - now ;
		
		if(item.scratched){
			
			if(elipseTime <= 0){
			
				flag = YES;
				[g_aryRewards removeObjectAtIndex:i];
				
				[[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				break;
			}
			
			ScratchCollectionCell* cell = (ScratchCollectionCell *)[self.m_tblRewards cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			
			[cell.lblTime setText:[NSString stringWithFormat:@"%02d:%02d", (int)elipseTime / 60, (int)elipseTime % 60]];
			
			[g_aryRewards replaceObjectAtIndex:i withObject:item.dictionary];
			[[NSUserDefaults standardUserDefaults] setObject:g_aryRewards forKey:DEFAULT_REWARD_LIST];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}		
	}
	
	if(flag)
		[self.m_tblRewards reloadData];
	
}

- (IBAction)onClickBtnHeader:(id)sender {
	UIViewController *getMoreVC = [self.storyboard instantiateViewControllerWithIdentifier:GET_MORE_REWARD_VIEW_CONTROLLER];
	[self presentViewController:getMoreVC animated:YES completion:nil];
}

@end
