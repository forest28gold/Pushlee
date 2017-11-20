//
//  SuggestStationViewController.h
//  Pushlee
//
//  Created by AppsCreationTech  on 06/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuggestStationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *m_txtStationName;
@property (weak, nonatomic) IBOutlet UITextField *m_txtStationCity;
@property (weak, nonatomic) IBOutlet UITextField *m_txtStationState;


- (IBAction)onClickBtnSuggest:(id)sender;

@end
