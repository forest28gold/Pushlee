//
//  HomeBanner.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/4/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeBanner : NSObject

@property (nonatomic, retain) NSString      *strId;
@property (nonatomic, retain) NSString      *strBannerDesc;
@property (nonatomic, retain) NSString      *strImageUrl;
@property (nonatomic, retain) NSString      *strLinkUrl;
@property (nonatomic, retain) NSNumber      *nTypeOfLink;
@property (nonatomic, retain) NSString      *strDealId;
@property (nonatomic, retain) NSString      *strStationId;
@property (nonatomic, retain) NSString      *strInternalPage;
@property (nonatomic, retain) NSString      *strUUID;

- (id)initWithParseObject:(PFObject *)object;

@end
