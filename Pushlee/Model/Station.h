//
//  Station.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/5/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Station : NSObject

@property (nonatomic, retain) NSString          *strStationId;
@property (nonatomic, retain) NSString          *strStationName;
@property (nonatomic, retain) NSString          *strStationCountry;
@property (nonatomic, retain) NSString          *strStationState;
@property (nonatomic, retain) NSString          *strStationCity;
@property (nonatomic, retain) NSString          *strStationStreet;
@property (nonatomic, retain) NSString          *strStationZip;
@property (nonatomic, retain) NSString          *strSearchName;
@property (nonatomic, retain) NSString          *strSearchCity;
@property (nonatomic, retain) NSString          *strSearchState;
@property (nonatomic, readwrite) float          fStationLatitude;
@property (nonatomic, readwrite) float          fStationLongitude;

//for coupon
@property (nonatomic, retain) NSDate            *dateCouponStart;
@property (nonatomic, retain) NSDate            *dateCouponEnd;
@property (nonatomic, retain) NSString          *strCouponDealId;

- (id)initWithParseObject:(PFObject *)objStation;
- (id)initWithDictionary:(NSDictionary *)dicStation;

- (NSDictionary *)dictionary;

- (float)getDistanceFromMe;

@end
