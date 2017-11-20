//
//  GetMoreRewardViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 10/22/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "AppDelegate.h"
#import "GetMoreRewardViewController.h"
#import "InviteFriendsViewController.h"
@interface GetMoreRewardViewController ()

@end

@implementation GetMoreRewardViewController

@synthesize m_sclGuide;
@synthesize pushlee_header;
#define GUIDE_COUNT     5

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for(int nIndex = 0; nIndex < GUIDE_COUNT; nIndex++)
    {
        UIView *viewGuide = [self.view viewWithTag:nIndex + 10];
        [viewGuide setFrame:CGRectMake(nIndex * m_sclGuide.frame.size.width, 0, m_sclGuide.frame.size.width, m_sclGuide.frame.size.height)];
    }
    
    [m_sclGuide setContentSize:CGSizeMake(m_sclGuide.frame.size.width * GUIDE_COUNT, m_sclGuide.frame.size.height)];
    [[self pushlee_header] setFont:[UIFont fontWithName:@"Roboto-Light" size:20.f]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    g_tabController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
   g_tabController.tabBar.hidden = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickBtnNavigation:(id)sender {
    
    UIButton *btnSelect = (UIButton *)sender;
    UIView *viewParent = [btnSelect superview];
    
    switch (viewParent.tag) {
        case 10:
        case 11:
        { //Find Station, Find Deal

            [self dismissViewControllerAnimated:NO completion:^{
                g_tabController.selectedIndex = 3;
                g_tabController.tabBar.hidden = NO;
            }];
        
            break;
        }
        case 12:{ //Redeem Deal
            
            [self dismissViewControllerAnimated:NO completion:^{
                g_tabController.selectedIndex = 1;
                g_tabController.tabBar.hidden = NO;
            }];

            break;
        }
        case 13:{ //Invite Friends
            
            UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:INVITE_FRIENDS_VIEW_CONTROLLER];
            [self presentViewController:vc animated:YES completion:nil];
            
            break;
        }
        case 14:{ //Share
            
            [self.presentingViewController.menuContainerViewController toggleRightSideMenuCompletion:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
            break;
        }
        default:
            break;
    }
}

- (IBAction)onClickBtnBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        g_tabController.tabBar.hidden = NO;
    }];
}

@end
