//
//  Friend.h
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-24.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject

@property (strong, nonatomic) NSString *strName;
@property (strong, nonatomic) NSString *strEmail;
@property (readwrite, nonatomic) BOOL selected;

@end
