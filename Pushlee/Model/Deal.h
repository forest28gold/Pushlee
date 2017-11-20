//
//  Deal.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/5/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Deal : NSObject

@property (nonatomic, retain) NSString          *strDealId;
@property (nonatomic, retain) NSString          *strDealDesc;
@property (nonatomic, retain) NSString          *strDealType;
@property (nonatomic, retain) NSString          *strDealName;
@property (nonatomic, retain) NSNumber          *nDealPrice;
@property (nonatomic, retain) NSString          *strProductId;
@property (nonatomic, retain) NSString          *strProductImageUrl;

- (id)initWithParseObject:(PFObject *)objDeal;

@end
