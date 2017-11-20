//
//  HotDeal.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/5/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotDeal : NSObject

@property (nonatomic, retain) NSString      *strImageUrl;
@property (nonatomic, retain) NSString      *strDealName;
@property (nonatomic, retain) NSString      *strDealCity;
@property (nonatomic, retain) NSString      *strDealStreet;
@property (nonatomic, retain) NSString      *strStationId;
@property (nonatomic, retain) NSString      *strDealId;
@property (nonatomic, retain) NSString      *strDealType;

- (id)initWithParseObject:(PFObject *)objDeal;

@end
