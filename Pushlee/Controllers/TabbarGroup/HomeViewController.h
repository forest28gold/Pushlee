//
//  HomeViewController.h
//  Pushlee
//
//  Created by AppsCreationTech  on 06/05/2014.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UIAlertViewDelegate, UICollectionViewDelegate, UIScrollViewDelegate>
{
    NSArray                 *m_aryBanners;
    NSMutableArray          *m_aryHotDeals;
    
    BOOL                    isSearchAroundStation;
}

@property (strong, nonatomic) IBOutlet UICollectionView *m_collectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *m_pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *m_srlContainer;

@property (weak, nonatomic) IBOutlet UIView *m_viewAddCard;
@property (weak, nonatomic) IBOutlet UIView *m_viewDeals;
@property (weak, nonatomic) IBOutlet UIView *m_viewStationSuggetion;
@property (weak, nonatomic) IBOutlet UIButton *m_btnLastestDeal;

- (IBAction)onClickSuggest:(id)sender;
- (IBAction)onClickBtnAddCard:(id)sender;
- (IBAction)onClickLastDeal:(id)sender;

@end
