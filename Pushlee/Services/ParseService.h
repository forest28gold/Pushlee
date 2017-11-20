//
//  ParseService.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/3/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

#import "UserInfo.h"
#import "DealSurvey.h"
#import "Friend.h"
#import "RewardItem.h"
#import "HomeBanner.h"
#import "HotDeal.h"
#import "Station.h"
#import "Deal.h"
#import "Receipt.h"

typedef enum : NSInteger
{
    LIKE_DEAL = 0,
    UNLIKE_DEAL = 1,
    NO_DEAL = 2
}GEL_LIKE_DEAL_TYPE;

@interface ParseService : NSObject

+ (id)sharedInstance;

- (void)loginWithUserName:(NSString *)strUserName
                 Password:(NSString *)strPassword
                   Result:(void (^)(NSString *))onResult;

- (void)loginWithFacebookPermission:(NSArray *)aryPermissions
                             Result:(void (^)(NSString *))onResult;

- (void)requestPasswordWithUserName:(NSString *)strUserName
                             Result:(void (^)(NSString *))onResult;

- (void)signUpWithUserInfo:(UserInfo *)userInfo
                    Result:(void (^)(NSString *))onResult;

- (void)updateUserLocationWithLat:(float)latitude
                             Long:(float)longitude;

- (void)getDealSurveyWithUserId:(NSString *)userId
                         Result:(void (^)(NSArray *, NSString *))onResult;

- (void)saveUserDealSurveys:(NSArray *)aryDealSurveys
                 WithUserId:(NSString *)userId
                     Result:(void (^)(NSString *))onResult;

- (void)saveInvitedFriends:(NSArray *)aryFriends
                     Steps:(NSString *)step
                WithUserId:(NSString *)userId
                    Result:(void (^)(NSString *))onResult;

- (void)getNewInstallReward:(void (^)(NSDictionary *))onResult;

- (void)getFeaturedSection:(void (^)(NSArray *, NSString *))onResult;

- (void)getHotDealsWithLatitude:(float)fLat
                      Longitude:(float)fLong
                         Result:(void (^)(NSArray *, NSString *))onResult;

- (void)getTopDealsWithLimit:(NSInteger)nLimit
                      Result:(void (^)(NSArray *, NSString *))onResult;

- (void)saveSliderClickedWithUUID:(NSString *)uuid;
- (void)saveSliderViewedWithUUID:(NSString *)uuid;

- (void)searchStationsWithinMiles:(NSInteger)nMiles
                           Result:(void (^)(NSArray *, NSString *))onResult;

- (void)sendSuggestionStation:(NSString *)city
                        State:(NSString *)state
                      Station:(NSString *)station
                       Result:(void (^)(NSString *))onResult;

- (void)uploadProfileImageFile:(UIImage *)image
                        Result:(void (^)(NSString *))onResult
                    Persent:(void (^)(int))onPersent;

- (void)updateProfileWithFirstName:(NSString *)firstName
                          LastName:(NSString *)lastName
                               Age:(NSString *)age
                            Gender:(NSString *)gender
                            Result:(void (^)(NSString *))onResult;

- (void)getFirstStationInfo:(NSString *)stationId
                     Result:(void (^)(Station *))onResult;


- (void)saveViewedDeals:(Deal *)viewedDeal
            withStation:(Station *)viewedStation;

- (void)getLikeDealWithUserId:(NSString *)userId
                    StationId:(NSString *)stationId
                       DealId:(NSString *)dealId
                       Result:(void (^)(GEL_LIKE_DEAL_TYPE))onResult;

- (void)saveRedeemDealWithStation:(Station *)objStation
                             Deal:(Deal *)objDeal
                           Result:(void (^)(NSString *))onResult;

- (void)updateRedeemDealWithStationId:(NSString *)stationId
                               DealId:(NSString *)dealId
                                 Like:(BOOL)isLike
                               Result:(void (^)(NSString *))onResult;

- (void)getStationAndDealWithStationId:(NSString *)stationId
                                DealId:(NSString *)dealId
                                Result:(void (^)(Station *, Deal *))onResult;

- (void)getStationAndDealsWithStationId:(NSString *)stationId
                                Station:(void (^)(Station *))onStation
                                  Deals:(void (^)(NSArray *))onDeals;

- (void)getStations:(RewardItem *)itemReward
             Result:(void (^)(NSArray *))onResult;

- (void)getAllStations:(void (^)(NSArray *))onResult;

- (void)recordRewardStateToParseWithStationID:(NSString *)stationID
                                         Slug:(NSString *)slug
                                        State:(NSString *)state
                                       DealID:(NSString *)dealID;

- (void)getCustomReward:(void (^)(RewardItem *))onResult;

- (void)getNearestStationWithCouponOfFavoriteStations:(NSArray *)aryStations
                                               Result:(void (^)(Station *, NSString *))onResult;

- (void)getCouponDealWithStationId:(Station *)couponStation
                            Result:(void (^)(Deal *, NSString *))onResult;

- (NSArray *)getFavoriteStations;

- (void)saveFavoriteStationsWithStations:(NSArray *)aryFavoriteStations
                                  Result:(void (^)(NSString *))onResult;

- (void)getReceiptInfoWithCode:(NSNumber *)nCodeNumber
                        Result:(void (^)(Receipt *, NSString *))onResult;
@end
