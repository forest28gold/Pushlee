//
//  InviteFriendsViewController.m
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-24.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import <AddressBook/AddressBook.h>
#import "Friend.h"
#import "InviteCell.h"

@interface InviteFriendsViewController ()

@end

@implementation InviteFriendsViewController

@synthesize m_tblFriends;
@synthesize m_btnSelect;

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

    [self getFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)getFriends {
    
    m_aryFriends = [[NSMutableArray alloc] init];
    m_nSelCount = 0;

    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {

            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
            
            for (int i = 0; i < numberOfPeople; i ++) {
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                ABMultiValueRef emailAddress = ABRecordCopyValue(person, kABPersonEmailProperty);
                if (ABMultiValueGetCount(emailAddress) > 0) {
                    Friend *friend = [[Friend alloc] init];

                    NSString *fname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                    if (fname == NULL) {
                        fname = @"";
                    }
                    
                    NSString *lname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                    if (lname == NULL) {
                        lname = @"";
                    }
                        
                    NSString *name = [NSString stringWithFormat:@"%@ %@", fname, lname];
                    friend.strName = name;
                    friend.strEmail = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emailAddress, 0);
                    friend.selected = YES;
             
                    [m_aryFriends addObject:friend];
                }
            }
            	
            [self.m_tblFriends performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    });    
}

- (IBAction)onClickClose:(id)sender
{
    if([self presentingViewController] == nil){
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)onClickSend:(id)sender
{
    BOOL flag = NO;
    
    Friend *friend;
    for (int i = 0; i < m_aryFriends.count; i ++) {
        friend = [m_aryFriends objectAtIndex:i];
        if (friend.selected) {
            flag = YES;
            break;
        }
    }
    
    if (!flag) {
        [self onClickClose:nil];
    }
    
    [self saveInvitedFriends];
    [self sendEmailToFriends];
}

- (void)sendEmailToFriends {
    NSString *username = [[NSString stringWithFormat:@"%@ %@", g_myInfo.strUserFirstName, g_myInfo.strUserLastName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([username isEqualToString:@""])
        username = @"Your Friend";
    
    Friend *friend;
    
    for (int i = 0; i < m_aryFriends.count; i ++) {
        friend = [m_aryFriends objectAtIndex:i];
        if (friend.selected) {
            NSDictionary *cloudDic = @{
                                       @"email":friend.strEmail,
                                       @"username":username
                                       };
            [PFCloud callFunctionInBackground:@"sendEmailToInvitedUsers" withParameters:cloudDic target:self selector:@selector(cloudResponse:)];
        }
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Wahoo!"
                                message:@"The email has been sent"
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

- (void)cloudResponse:(id)sender {
    NSLog(@"Cloud Response");
}

- (void)saveInvitedFriends {
    NSString *step = @"inApp";
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_INIT_STATION]) {
        step = @"initial";
    }
    
    [SVProgressHUD showWithStatus:@"Sending..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] saveInvitedFriends:m_aryFriends
                                                Steps:step
                                           WithUserId:g_myInfo.strUserId
                                               Result:^(NSString *strError) {
                                                   [SVProgressHUD dismiss];
                                                   [appDelegate saveRewardAvailableWithMilestoneType:invited_friends StationID:@""];
                                               }];
}

- (IBAction)onClickSelect:(id)sender {
    if ([m_btnSelect.currentTitle isEqualToString:@"Unselect All"]) {

        for (int i = 0; i < m_aryFriends.count; i ++) {
            Friend *friend = [m_aryFriends objectAtIndex:i];
            friend.selected = false;
        }
        
        m_nSelCount = -(int)m_aryFriends.count;
        
        [m_btnSelect setTitle:@"Select All" forState:UIControlStateNormal];
    } else {
        Friend *friend;
        
        for (int i = 0; i < m_aryFriends.count; i ++) {
            friend = [m_aryFriends objectAtIndex:i];
            friend.selected = true;
        }
        
        m_nSelCount = 0;

        [m_btnSelect setTitle:@"Unselect All" forState:UIControlStateNormal];
    }

    [m_tblFriends reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return m_aryFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InviteCell* cell = (InviteCell* )[tableView dequeueReusableCellWithIdentifier:@"InviteCell"];

    [cell.m_btnCheck setTag:100 + indexPath.row];
    [cell.m_btnCheck addTarget:self action:@selector(onClickCheckBox:) forControlEvents:UIControlEventTouchUpInside];
    
    Friend *friend = [m_aryFriends objectAtIndex:indexPath.row];
    if (friend.selected) {
        [cell.m_btnCheck setBackgroundImage:[UIImage imageNamed:@"common_chkSelected"] forState:UIControlStateNormal];
    } else {
        [cell.m_btnCheck setBackgroundImage:[UIImage imageNamed:@"common_chkUnSelected"] forState:UIControlStateNormal];
    }

    [cell.m_lblName setText:friend.strName];
    [cell.m_lblEmail setText:friend.strEmail];

    return cell;
}

- (void) onClickCheckBox:(UIButton *)sender {
    
    Friend *friend = [m_aryFriends objectAtIndex:(int)sender.tag - 100];
    
    if (friend.selected) {
        friend.selected = NO;
        [sender setBackgroundImage:[UIImage imageNamed:@"common_chkUnSelected"] forState:UIControlStateNormal];
        
        m_nSelCount --;
        [m_btnSelect setTitle:@"Select All" forState:UIControlStateNormal];
    } else {
        friend.selected = YES;
        [sender setBackgroundImage:[UIImage imageNamed:@"common_chkSelected"] forState:UIControlStateNormal];
        
        m_nSelCount ++;
        if (m_nSelCount == 0) {
            [m_btnSelect setTitle:@"Unselect All" forState:UIControlStateNormal];
        }
    }
}

#pragma UIAlertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if([self presentingViewController] != nil){
		
		[self dismissViewControllerAnimated:YES completion:nil];
		
	} else {
		[UIView transitionWithView:[appDelegate window]
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^(void) {
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            [[appDelegate window] setRootViewController:g_sideMenuController];
                            [UIView setAnimationsEnabled:oldState];
                        }
                        completion:nil];
	}
}

@end
