//
//  RewardItem.h
//  Pushlee
//
//  Created by AppsCreationTech on 9/30/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RewardItem : NSObject

@property (nonatomic, retain) NSString*     rewardId;
@property (nonatomic, retain) NSString*     stationId;
@property (nonatomic, retain) NSArray*      str_station;
@property (nonatomic, retain) NSString*     imageUrl;
@property (nonatomic, retain) NSString*     title;
@property (nonatomic, retain) NSString*     description_;
@property (nonatomic, retain) NSString*     barcode;
@property (nonatomic, readwrite) int        coverImageID;
@property (nonatomic, retain) NSString*     sub_desc;
@property (nonatomic, readwrite) BOOL       scratched; //default is false(still not scratched)
@property (nonatomic, retain) NSArray*      obj_stations;
@property (nonatomic, readwrite) BOOL       newInstalled;
@property (nonatomic, readwrite) long       baseTime;
@property (nonatomic, readwrite) BOOL       redeemed;  // if redeemed will show in present permanently.;
@property (nonatomic, retain) NSString*     stationInfo;
@property (nonatomic, retain) NSString*     stationName;
@property (nonatomic, retain) NSString*     stationCity;
@property (nonatomic, retain) NSArray*      disabledAt;
@property (nonatomic, readwrite) long       newBaseTime;


//Add 2014-10-22 by JHpassion
@property (nonatomic, retain) NSString*     strSlug;
@property (nonatomic, retain) NSMutableDictionary* m_dictionary;

- (id)initWithEmptyObject;
- (id)initWithDictionary:(NSMutableDictionary*)dict;
- (NSMutableDictionary*)dictionary;

@end
