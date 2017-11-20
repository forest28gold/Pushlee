//
//  DealsViewController.h
//  Pushlee
//
//  Created by AppsCreationTech  on 06/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSArray                 *m_aryDeals;
    
    Station                 *m_objStation;
}

@property (weak, nonatomic) IBOutlet UILabel *m_lblStationName;
@property (weak, nonatomic) IBOutlet UILabel *m_lblStationAddress;
@property (weak, nonatomic) IBOutlet UILabel *m_lblNoDeal;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFindDeal;
@property (weak, nonatomic) IBOutlet UICollectionView *m_cltDeals;

- (IBAction)onClickFindDeals:(id)sender;

@end

