//
//  Deal.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/5/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "Deal.h"

@implementation Deal

@synthesize          strDealId;
@synthesize          strDealDesc;
@synthesize          strDealType;
@synthesize          strDealName;
@synthesize          nDealPrice;
@synthesize          strProductId;
@synthesize          strProductImageUrl;

- (id)init
{
    self = [super init];
    if(self)
    {
        strDealId = @"";
        strDealName = @"";
        strDealType = @"";
        strDealDesc = @"";
        strProductId = @"";
        nDealPrice = [NSNumber numberWithInt:0];
        strProductImageUrl = @"";
    }
    
    return self;
}

- (id)initWithParseObject:(PFObject *)objDeal
{
    Deal *deal = [[Deal alloc] init];
    
    deal.strDealId = objDeal.objectId;
    deal.strDealName = [objDeal objectForKey:@"name"];
    deal.strDealType = [objDeal objectForKey:@"deal_type"];
    deal.strDealDesc = [objDeal objectForKey:@"Description"];
    deal.nDealPrice = [objDeal objectForKey:@"price"];
    deal.strProductImageUrl = [objDeal objectForKey:@"productID"];
    deal.strProductImageUrl = [objDeal objectForKey:@"product_image"];
    
    return deal;
}

@end
