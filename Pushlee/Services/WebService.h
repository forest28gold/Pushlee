//
//  WebService.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/3/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>
#import <Parse/Parse.h>
#import "Station.h"
#import "Deal.h"

@interface WebService : NSObject

+ (id)sharedInstance;

- (void)getPKPassFromServerWithSation:(Station *)station
                                 Deal:(Deal *)deal
                            Completed:(void (^)(PKPass *))onCompleted
                               Failed:(void (^)(NSString *))onFailed;

- (NSString *)getShortURL:(NSString *)strLongUrl;

@end
