//
//  MainTabBarController.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/4/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController<UITableViewDelegate>
{
    PKPass      *m_savedPass;
}

@end
