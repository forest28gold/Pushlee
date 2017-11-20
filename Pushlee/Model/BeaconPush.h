//
//  BeaconPush.h
//  Pushlee
//
//  Created by AppsCreationTech on 2014-06-30.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconPush : NSObject

@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSDate *lastTime;

@end
