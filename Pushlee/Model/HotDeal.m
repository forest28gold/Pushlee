//
//  HotDeal.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/5/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "HotDeal.h"

@implementation HotDeal

@synthesize strDealId;
@synthesize strDealName;
@synthesize strDealCity;
@synthesize strDealStreet;
@synthesize strImageUrl;
@synthesize strStationId;
@synthesize strDealType;

- (id)init
{
    self = [super init];
    if(self)
    {
        strDealId = @"";
        strDealName = @"";
        strDealCity = @"";
        strDealStreet = @"";
        strImageUrl = @"";
        strStationId = @"";
        strDealType = @"";
    }
    
    return self;
}

- (id)initWithParseObject:(PFObject *)objDeal
{
    HotDeal *hotDeal = [[HotDeal alloc] init];
    
    hotDeal.strDealId = [objDeal objectForKey:@"dealID"];
    hotDeal.strDealName = [objDeal objectForKey:@"deal_name"];
    hotDeal.strDealCity = [objDeal objectForKey:@"city"];
    hotDeal.strDealStreet = [objDeal objectForKey:@"street"];
    hotDeal.strImageUrl = [objDeal objectForKey:@"deal_image"];
    hotDeal.strStationId = [objDeal objectForKey:@"stationID"];
    hotDeal.strDealType = [objDeal objectForKey:@"deal_type"];
    
    return hotDeal;
}

@end
