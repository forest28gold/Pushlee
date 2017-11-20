//
//  HomeBanner.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/4/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "HomeBanner.h"

@implementation HomeBanner

@synthesize      strId;
@synthesize      strBannerDesc;
@synthesize      strImageUrl;
@synthesize      strLinkUrl;
@synthesize      nTypeOfLink;
@synthesize      strDealId;
@synthesize      strStationId;
@synthesize      strInternalPage;
@synthesize      strUUID;

- (id)init
{
    self = [super init];
    
    if(self){
        
        strId = @"";
        strBannerDesc = @"";
        strImageUrl = @"";
        strLinkUrl = @"";
        nTypeOfLink = [NSNumber numberWithInt:0];
        strDealId = @"";
        strStationId = @"";
        strInternalPage = @"";
        strUUID = @"";
    }
    
    return self;
}

- (id)initWithParseObject:(PFObject *)object
{
    HomeBanner *homeBanner = [[HomeBanner alloc] init];
    
    homeBanner.strId = object.objectId;
    homeBanner.strBannerDesc = [object objectForKey:@"text"];
    homeBanner.strImageUrl = [object objectForKey:@"image2"];
    homeBanner.strLinkUrl = [object objectForKey:@"link"];
    homeBanner.nTypeOfLink = [object objectForKey:@"typeOfLink"];
    homeBanner.strDealId = [object objectForKey:@"dealID"];
    homeBanner.strStationId = [object objectForKey:@"stationID"];
    homeBanner.strInternalPage = [object objectForKey:@"internalPage"];
    homeBanner.strUUID = [object objectForKey:@"uuid"];
    
    return homeBanner;
}

@end
