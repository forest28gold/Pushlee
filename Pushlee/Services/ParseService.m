//
//  ParseService.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/3/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "ParseService.h"

@implementation ParseService

ParseService *sharedParseObj = nil;

+ (id)sharedInstance{
    
    if(!sharedParseObj)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            sharedParseObj = [[self alloc] init];
        });
    }
    
    return sharedParseObj;
}

- (void)loginWithUserName:(NSString *)strUserName
                 Password:(NSString *)strPassword
                   Result:(void (^)(NSString *))onResult
{
    [PFUser logInWithUsernameInBackground:strUserName
                                 password:strPassword
                                    block:^(PFUser *user, NSError *error) {
                                        if(error == nil)
                                        {
                                            [user setObject:g_myInfo.strUserInstallationId forKey:@"installationID"];
                                            [user setObject:[NSNumber numberWithBool:YES] forKey:@"mobile"];
                                            [user saveInBackground];
                                            [g_myInfo addInfoWithPFUser:user];
                                            
                                            onResult(nil);
                                        }
                                        else
                                            onResult([error.userInfo objectForKey:@"error"]);
                                    }];
}

- (void)loginWithFacebookPermission:(NSArray *)aryPermissions
                             Result:(void (^)(NSString *))onResult
{
    [PFFacebookUtils logInWithPermissions:aryPermissions
                                    block:^(PFUser *user, NSError *error) {
                                        if(error == nil && user != nil)
                                        {
                                            if(user.isNew)
                                            {
                                                FBRequest *request = [FBRequest requestForMe];
                                                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                    if (!error)
                                                    {
                                                        NSDictionary *data = (NSDictionary*)result;
                                                        NSString *fid = [data objectForKey:@"id"];
                                                        
                                                        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fid];
                                                        UIImage* myImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                                                        NSData *imageData = UIImagePNGRepresentation(myImage);
                                                        PFFile *imgFile = [PFFile fileWithName:@"profile.png" data:imageData];
                                                        [imgFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                            if (!error) {
                                                                [user setObject:[data objectForKey:@"first_name"] forKey:@"firstName"];
                                                                [user setObject:[data objectForKey:@"last_name"] forKey:@"lastName"];
                                                                [user setObject:[data objectForKey:@"gender"] forKey:@"gender"];
                                                                [user setObject:imgFile forKey:@"profileImage"];
                                                                [user setObject:imgFile.url forKey:@"image2"];
                                                                [user setEmail:[data objectForKey:@"email"] != nil ? [data objectForKey:@"email"] : @""];
                                                                [user setObject:g_myInfo.strUserInstallationId forKey:@"installationID"];
                                                                [user setObject:[NSNumber numberWithBool:YES] forKey:@"mobile"];
                                                                
                                                                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                                                                    if(error == nil)
                                                                    {
                                                                        [g_myInfo addInfoWithPFUser:user];
                                                                        onResult(nil);
                                                                    }
                                                                    else    //user save error
                                                                        onResult([error.userInfo objectForKey:@"error"]);
                                                                }];
                                                            }
                                                            else    //image save error
                                                                onResult([error.userInfo objectForKey:@"error"]);
                                                        }];
                                                    }
                                                    else    //facebook request error
                                                        onResult([error.userInfo objectForKey:@"error"]);
                                                }];
                                            }
                                            else    //is not new user
                                            {
                                                [user setObject:g_myInfo.strUserInstallationId forKey:@"installationID"];
                                                [user setObject:[NSNumber numberWithBool:YES] forKey:@"mobile"];
                                                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                                                    if(error == nil)
                                                    {
                                                        [g_myInfo addInfoWithPFUser:user];
                                                        onResult(nil);
                                                    }
                                                    else    //user save error
                                                        onResult([error.userInfo objectForKey:@"error"]);
                                                }];
                                            }
                                        }
                                        else    //facebook login error
                                            onResult(@"Failed to Facebook login");
                                    }];
}

- (void)requestPasswordWithUserName:(NSString *)strUserName
                             Result:(void (^)(NSString *))onResult
{
    [PFUser requestPasswordResetForEmailInBackground:strUserName
                                               block:^(BOOL succeeded, NSError *error) {
                                                   if(error == nil)
                                                       onResult(nil);
                                                   else
                                                       onResult([error.userInfo objectForKey:@"error"]);
                                               }];
}

- (void)signUpWithUserInfo:(UserInfo *)userInfo
                    Result:(void (^)(NSString *))onResult
{
    PFUser *user = [PFUser new];
    
    [user setObject:userInfo.strUserFirstName forKey:@"firstName"];
    [user setObject:userInfo.strUserLastName forKey:@"lastName"];
    user.email = userInfo.strUserEmail;
    user.username = userInfo.strUserEmail;
    user.password = userInfo.strUserPassword;
    [user setObject:userInfo.strUserGender forKey:@"gender"];
    [user setObject:userInfo.nUserAge forKey:@"age"];
    [user setObject:userInfo.strUserZipCode forKey:@"zip"];
    [user setObject:userInfo.strUserInstallationId forKey:@"installationID"];
    [user setObject:[NSNumber numberWithBool:YES] forKey:@"mobile"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error == nil)
        {
            [g_myInfo addInfoWithPFUser:user];
            onResult(nil);
        }
        else
            onResult([error.userInfo objectForKey:@"error"]);
    }];
}

- (void)getDealSurveyWithUserId:(NSString *)userId
                         Result:(void (^)(NSArray *, NSString *))onResult
{
    PFQuery *query = [PFQuery queryWithClassName:@"DealSurvey"];
    [query whereKey:@"userid" equalTo:userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(error == nil)
        {
            if(objects.count == 0)
                onResult([[NSArray alloc] init], nil);
            else
                onResult([[objects objectAtIndex:0] objectForKey:@"categories"], nil);
        }
        else
        {
            onResult(nil, [error.userInfo objectForKey:@"error"]);
        }
    }];
}

- (void)saveUserDealSurveys:(NSArray *)aryDealSurveys
                 WithUserId:(NSString *)userId
                     Result:(void (^)(NSString *))onResult
{
    PFQuery *query = [PFQuery queryWithClassName:@"DealSurvey"];
    [query whereKey:@"userid" equalTo:userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error == nil)
        {
            PFObject *objDealSurvey;
            if(objects.count == 0)
            {
                objDealSurvey = [[PFObject alloc] initWithClassName:@"DealSurvey"];
            }
            else
            {
                objDealSurvey = [objects objectAtIndex:0];
            }
            
            NSMutableArray *aryDealNames = [[NSMutableArray alloc] init];
            for(int nIndex = 0; nIndex < aryDealSurveys.count; nIndex++)
            {
                DealSurvey *dealSurvey = [aryDealSurveys objectAtIndex:nIndex];
                if(dealSurvey.selected)
                    [aryDealNames addObject:dealSurvey.strDealName];
            }
            
            [objDealSurvey setObject:userId forKey:@"userid"];
            [objDealSurvey setObject:aryDealNames forKey:@"categories"];
            [objDealSurvey setObject:g_myInfo.strUserEmail forKey:@"email"];
            [objDealSurvey saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error == nil)
                    onResult(nil);
                else
                    onResult([error.userInfo objectForKey:@"error"]);
            }];
        }
        else
            onResult([error.userInfo objectForKey:@"error"]);
    }];
}

- (void)saveInvitedFriends:(NSArray *)aryFriends
                     Steps:(NSString *)step
                WithUserId:(NSString *)userId
                    Result:(void (^)(NSString *))onResult;
{
    for(int nIndex = 0; nIndex < aryFriends.count; nIndex++)
    {
        Friend *friend = [aryFriends objectAtIndex:nIndex];
        if(!friend.selected)
            continue;
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"email" equalTo:friend.strEmail];
        NSArray *aryUsers = [query findObjects];
        
        PFObject *object = [PFObject objectWithClassName:@"InviteFriend"];
        
        [object setObject:userId forKey:@"userid"];
        [object setObject:g_myInfo.strUserEmail forKey:@"email"];
        [object setObject:friend.strEmail forKey:@"invitedEmail"];
        [object setObject:friend.strName forKey:@"invitedName"];
        [object setObject:@"ios" forKey:@"platform"];
        [object setObject:step forKey:@"step"];
        
        if(aryUsers.count == 0)
        {
            [object setObject:[NSNumber numberWithBool:NO] forKey:@"signed"];
        }else{
            [object setObject:[NSNumber numberWithBool:YES] forKey:@"signed"];
        }
        
        [object saveInBackground];
    }
    
    onResult(nil);
}

- (void)getNewInstallReward:(void (^)(NSDictionary *))onResult
{
    PFQuery* query = [PFQuery queryWithClassName:@"newInstallationReward"];
    [query whereKey:@"slug" equalTo:@"new-install"];
    [query setLimit:1];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(object != nil && error == nil){
            
            RewardItem* item = [[RewardItem alloc] initWithEmptyObject];
            
            item.rewardId = object.objectId;
            item.disabledAt = [object objectForKey:@"disabledAt"];
            item.obj_stations = [object objectForKey:@"disabledAt"];
            item.imageUrl = [object objectForKey:@"imageURL"];
            item.barcode = [NSString stringWithFormat:@"%d", [[object objectForKey:@"barcode"] intValue]];
            item.title = [object objectForKey:@"title"];
            item.description_ = [object objectForKey:@"description"];
            item.strSlug = @"new-install";
            item.newInstalled = YES;
            
            onResult([item dictionary]);
        }
        else
            onResult(nil);
    }];
}

- (void)getCustomReward:(void (^)(RewardItem *))onResult
{
    PFQuery* query = [PFQuery queryWithClassName:@"rewards"];
    [query whereKey:@"slug" equalTo:@"custom-reward"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *reward, NSError *error){
        if(reward != nil && error == nil)
        {
            RewardItem* item = [[RewardItem alloc] initWithEmptyObject];
            item.rewardId = reward.objectId;
            item.scratched = NO;
            item.title = reward[@"title"];
            item.description_ = reward[@"description"];
            item.imageUrl = reward[@"imageURL"];
            item.barcode = [reward[@"barcode"] stringValue];
            item.obj_stations = reward[@"stations"];
            item.newInstalled = YES;
            item.coverImageID = arc4random() % 7;
            item.disabledAt = reward[@"disabledAt"] != nil ? reward[@"disabledAt"] : [[NSArray alloc] init];
            item.strSlug = reward[@"slug"];
            
            onResult(item);
        }
        else
            onResult(nil);
    }];
    
}

- (void)getFeaturedSection:(void (^)(NSArray *, NSString *))onResult
{
    PFQuery* query = [PFQuery queryWithClassName:@"featuredSection"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(error == nil)
         {
             if(objects.count == 0)
                 onResult(nil, @"We have no featured section.");
             else
             {
                 NSMutableArray *aryHomeBanners = [[NSMutableArray alloc] init];
                 for(int nIndex = 0; nIndex < objects.count; nIndex++)
                 {
                     HomeBanner *homeBanner = [[HomeBanner alloc] initWithParseObject:[objects objectAtIndex:nIndex]];
                     
                     [aryHomeBanners addObject:homeBanner];
                 }
                 onResult(aryHomeBanners, nil);
             }
         }
         else
             onResult(nil, [error.userInfo objectForKey:@"error"]);
     }];
}

- (void)getHotDealsWithLatitude:(float)fLat
                      Longitude:(float)fLong
                         Result:(void (^)(NSArray *, NSString *))onResult
{
    PFQuery* query = [PFQuery queryWithClassName:@"hotDealsnear"];
    
    [query whereKey:@"stationLocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:fLat longitude:fLong] withinMiles:100.f];
    
    [query  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(error == nil)
         {
             if(objects.count == 0)
                 onResult(nil, @"We have no hotdeals near you");
             else
             {
                 NSMutableArray *aryHotDeals = [[NSMutableArray alloc] init];
                 NSMutableArray *aryDealTypes = [[NSMutableArray alloc] init];
                 
                 for(int nIndex = 0; nIndex < objects.count; nIndex++)
                 {
                     HotDeal *objHotDeal = [[HotDeal alloc] initWithParseObject:[objects objectAtIndex:nIndex]];
                     
                     if([aryDealTypes containsObject:objHotDeal.strDealType])
                         continue;
                     
                     [aryDealTypes addObject:objHotDeal.strDealType];
                     [aryHotDeals addObject:objHotDeal];
                 }
                 
                 onResult(aryHotDeals, nil);
             }
         }
         else
             onResult(nil, [error.userInfo objectForKey:@"error"]);
     }];
}

- (void)getTopDealsWithLimit:(NSInteger)nLimit
                      Result:(void (^)(NSArray *, NSString *))onResult
{
    PFQuery* query = [PFQuery queryWithClassName:@"hotDealsnear"];
    
    [query addDescendingOrder:@"total"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if(error == nil)
         {
             if(objects.count == 0)
                 onResult(nil, @"We have no hotdeals near you");
             else
             {
                 NSMutableArray *aryHotDeals = [[NSMutableArray alloc] init];
                 NSMutableArray *aryDealTypes = [[NSMutableArray alloc] init];
                 
                 for(int nIndex = 0; nIndex < objects.count; nIndex++)
                 {
                     HotDeal *objHotDeal = [[HotDeal alloc] initWithParseObject:[objects objectAtIndex:nIndex]];
                     if([aryDealTypes containsObject:objHotDeal.strDealType])
                         continue;
                     
                     [aryDealTypes addObject:objHotDeal.strDealType];
                     [aryHotDeals addObject:objHotDeal];
                     if(aryHotDeals.count == nLimit)
                         break;
                 }
                 
                 onResult(aryHotDeals, nil);
             }
         }
         else
             onResult(nil, [error.userInfo objectForKey:@"error"]);
     }];
}

- (void)saveSliderClickedWithUUID:(NSString *)uuid
{
    PFObject* featuredSliderClicked = [PFObject objectWithClassName:@"featuredSliderClicked"];
    [featuredSliderClicked setObject:uuid forKey:@"uuid"];
    [featuredSliderClicked setObject:g_myInfo.strUserEmail forKey:@"email"];
    [featuredSliderClicked saveInBackground];
}

- (void)saveSliderViewedWithUUID:(NSString *)uuid
{
    PFObject* featuredSliderViewed = [PFObject objectWithClassName:@"featuredSectionViewed"];
    [featuredSliderViewed setObject:uuid forKey:@"uuid"];
    [featuredSliderViewed setObject:g_myInfo.strUserId forKey:@"user"];
    [featuredSliderViewed setObject:[PFGeoPoint geoPointWithLatitude:g_myInfo.fUserLatitude longitude:g_myInfo.fUserLongitude] forKey:@"location"];
    [featuredSliderViewed setObject:g_myInfo.strUserEmail forKey:@"email"];
    [featuredSliderViewed saveInBackground];
}

- (void)searchStationsWithinMiles:(NSInteger)nMiles
                           Result:(void (^)(NSArray *, NSString *))onResult
{
    PFQuery *locationQuery = [PFQuery queryWithClassName:@"Stations"];
    [locationQuery whereKey:@"station_loc"
               nearGeoPoint:[PFGeoPoint geoPointWithLatitude:g_myInfo.fUserLatitude longitude:g_myInfo.fUserLongitude]
                withinMiles:100];
    
    [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *locArray, NSError *error)
     {
         if(error == nil)
         {
             NSMutableArray *aryStations = [[NSMutableArray alloc] init];
             for(int nIndex = 0; nIndex < locArray.count; nIndex++)
             {
                 Station *station = [[Station alloc] initWithParseObject:[locArray objectAtIndex:nIndex]];
                 [aryStations addObject:station];
             }
             onResult(aryStations, nil);
         }
         else
             onResult(nil, [error.userInfo objectForKey:@"error"]);
     }];
}

- (void)sendSuggestionStation:(NSString *)city
                        State:(NSString *)state
                      Station:(NSString *)station
                       Result:(void (^)(NSString *))onResult
{
    PFObject *objSuggest = [PFObject objectWithClassName:@"SuggestedStation"];
    [objSuggest setObject:city forKey:@"city"];
    [objSuggest setObject:state forKey:@"state"];
    [objSuggest setObject:station forKey:@"station"];
    [objSuggest setObject:g_myInfo.strUserId forKey:@"user_id"];
    [objSuggest setObject:g_myInfo.strUserEmail forKey:@"email"];
    
    [objSuggest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error == nil)
            onResult(nil);
        else
            onResult([error.userInfo objectForKey:@"error"]);
    }];
}

- (void)uploadProfileImageFile:(UIImage *)image
                        Result:(void (^)(NSString *))onResult
                       Persent:(void (^)(int))onPersent;
{
    PFFile *imgFile = [PFFile fileWithName:@"profile.png" data:UIImagePNGRepresentation(image)];
    [imgFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error == nil)
        {
            PFUser *user = [PFUser currentUser];
            [user setObject:imgFile forKey:@"image"];
            [user setObject:imgFile.url forKey:@"image2"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error == nil)
                    onResult(nil);
                else
                    onResult([error.userInfo objectForKeyedSubscript:@"error"]);
            }];
        }
        else
            onResult([error.userInfo objectForKeyedSubscript:@"error"]);
        
    }
                         progressBlock:^(int percentDone) {
                             onPersent(percentDone);
                         }];
    
}

- (void)updateUserLocationWithLat:(float)latitude
                             Long:(float)longitude
{
    PFUser *user = [PFUser currentUser];
    PFGeoPoint *geoLocation = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    
    [user setObject:geoLocation forKey:@"location"];
    [user saveInBackground];
}

- (void)updateProfileWithFirstName:(NSString *)firstName
                          LastName:(NSString *)lastName
                               Age:(NSString *)age
                            Gender:(NSString *)gender
                            Result:(void (^)(NSString *))onResult
{
    PFUser *user = [PFUser currentUser];
    [user setObject:firstName forKey:@"firstName"];
    [user setObject:lastName forKey:@"lastName"];
    [user setObject:[NSNumber numberWithInt:[age intValue]] forKey:@"age"];
    [user setObject:gender forKey:@"gender"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error == nil)
        {
            [g_myInfo addInfoWithPFUser:user];
            onResult(nil);
        }
        else
            onResult([error.userInfo objectForKeyedSubscript:@"error"]);
    }];
}

- (void)getFirstStationInfo:(NSString *)stationId
                     Result:(void (^)(Station *))onResult
{
    PFQuery *stationQuery = [PFQuery queryWithClassName:@"Stations"];
    [stationQuery getObjectInBackgroundWithId:stationId block:^(PFObject *object, NSError *error) {
        if(error == nil)
        {
            Station *station = [[Station alloc] initWithParseObject:object];
            onResult(station);
        }
        else
            onResult(nil);
    }];
}

- (void)saveViewedDeals:(Deal *)viewedDeal withStation:(Station *)viewedStation;
{
    PFObject *viewedIndiDeals = [PFObject objectWithClassName:@"viewedIndiDeals"];
    
    [viewedIndiDeals setObject:g_myInfo.strUserEmail forKey:@"email"];
    [viewedIndiDeals setObject:g_myInfo.strUserInstallationId forKey:@"installationid"];
    [viewedIndiDeals setObject:viewedDeal.strDealId forKey:@"dealID"];
    [viewedIndiDeals setObject:[PFGeoPoint geoPointWithLatitude:g_myInfo.fUserLatitude longitude:g_myInfo.fUserLongitude] forKey:@"location"];
    [viewedIndiDeals setObject:g_myInfo.strUserId forKey:@"user_id"];
    [viewedIndiDeals setObject:viewedStation.strStationId forKey:@"station_id"];
    
    [viewedIndiDeals saveInBackground];
}

- (void)getLikeDealWithUserId:(NSString *)userId
                    StationId:(NSString *)stationId
                       DealId:(NSString *)dealId
                       Result:(void (^)(GEL_LIKE_DEAL_TYPE))onResult;
{
    PFQuery *dealsQuery = [PFQuery queryWithClassName:@"LikeDeals"];
    [dealsQuery whereKey:@"deal_id" equalTo:dealId];
    [dealsQuery whereKey:@"station_id" equalTo:stationId];
    [dealsQuery whereKey:@"user_id" equalTo:userId];
    [dealsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *likes, NSError *error) {
        if(error == nil)
        {
            if(likes == nil)
                onResult(NO_DEAL);
            else
            {
                if([[likes valueForKey:@"like"] boolValue])
                    onResult(LIKE_DEAL);
                else
                    onResult(UNLIKE_DEAL);
            }
        }
        else
            onResult(NO_DEAL);
    }];
}

- (void)saveRedeemDealWithStation:(Station *)objStation
                             Deal:(Deal *)objDeal
                           Result:(void (^)(NSString *))onResult;
{
    PFObject *redeemQuery = [PFObject objectWithClassName:@"redeemed_deals"];
    [redeemQuery setObject:objDeal.strDealId forKey:@"deal_id"];
    [redeemQuery setObject:objStation.strStationId forKey:@"station_id"];
    [redeemQuery setObject:g_myInfo.strUserId forKey:@"user_id"];
    [redeemQuery setObject:[NSString stringWithFormat:@"%.2f", [objDeal.nDealPrice floatValue]] forKey:@"price"];
    [redeemQuery setObject:[PFGeoPoint geoPointWithLatitude:g_myInfo.fUserLatitude longitude:g_myInfo.fUserLongitude] forKey:@"Location"];
    [redeemQuery setObject:g_myInfo.strUserEmail forKey:@"email"];
    
    [redeemQuery saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error == nil)
            onResult(nil);
        else
            onResult([error.userInfo objectForKeyedSubscript:@"error"]);
    }];
}

- (void)updateRedeemDealWithStationId:(NSString *)stationId
                               DealId:(NSString *)dealId
                                 Like:(BOOL)isLike
                               Result:(void (^)(NSString *))onResult
{
    PFQuery *likeQuery = [PFQuery queryWithClassName:@"LikeDeals"];
    [likeQuery whereKey:@"deal_id" equalTo:dealId];
    [likeQuery whereKey:@"station_id" equalTo:stationId];
    [likeQuery whereKey:@"user_id" equalTo:g_myInfo.strUserId];
    [likeQuery getFirstObjectInBackgroundWithBlock:^(PFObject *likes, NSError *error) {
        if(likes == nil)
        {
            PFObject *objLikeDeal = [PFObject objectWithClassName:@"LikeDeals"];
            [objLikeDeal setObject:dealId forKey:@"deal_id"];
            [objLikeDeal setObject:stationId forKey:@"station_id"];
            [objLikeDeal setObject:g_myInfo.strUserId forKey:@"user_id"];
            [objLikeDeal setObject:g_myInfo.strUserEmail forKey:@"email"];
            [objLikeDeal setObject:[NSNumber numberWithBool:isLike] forKey:@"like"];
            
            [objLikeDeal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error == nil)
                    onResult(nil);
                else
                    onResult([error.userInfo objectForKeyedSubscript:@"error"]);
            }];
        }
        else
        {
            [likes setObject:[NSNumber numberWithBool:isLike] forKey:@"like"];
            [likes saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error == nil)
                    onResult(nil);
                else
                    onResult([error.userInfo objectForKeyedSubscript:@"error"]);
            }];
        }
        
    }];
}

- (void)getStationAndDealWithStationId:(NSString *)stationId
                                DealId:(NSString *)dealId
                                Result:(void (^)(Station *, Deal *))onResult
{
    PFQuery *stationQuery = [PFQuery queryWithClassName:@"Stations"];
    [stationQuery whereKey:@"objectId" equalTo:stationId];
    [stationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *objStation, NSError *error) {
        Station *station = objStation == nil ? nil : [[Station alloc] initWithParseObject:objStation];
        
        PFQuery *dealsQuery = [PFQuery queryWithClassName:@"Deals"];
        [dealsQuery whereKey:@"objectId" equalTo:dealId];
        [dealsQuery getFirstObjectInBackgroundWithBlock:^(PFObject *objDeal, NSError *error) {
            Deal *deal = objDeal == nil ? nil : [[Deal alloc] initWithParseObject:objDeal];
            
            onResult(station, deal);
        }];
    }];
}

- (void)getStationAndDealsWithStationId:(NSString *)stationId
                                Station:(void (^)(Station *))onStation
                                  Deals:(void (^)(NSArray *))onDeals
{
    PFQuery *stationQuery = [PFQuery queryWithClassName:@"Stations"];
    [stationQuery whereKey:@"objectId" equalTo:stationId];
    [stationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *objStation, NSError *error) {
        if(objStation == nil || error != nil)
        {
            onStation(nil);
        }
        else
        {
            Station *station = [[Station alloc] initWithParseObject:objStation];
            onStation(station);
            
            PFQuery *dealIdQuery = [PFQuery queryWithClassName:@"dealstation"];
            [dealIdQuery whereKey:@"station" equalTo:stationId];
            [dealIdQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error == nil && objects.count > 0)
                {
                    NSMutableArray *aryDealIDs = [[NSMutableArray alloc] init];
                    for (PFObject *object in objects) {
                        [aryDealIDs addObject:object[@"deal"]];
                    }
                    PFQuery *dealsQuery = [PFQuery queryWithClassName:@"Deals"];
                    [dealsQuery whereKey:@"objectId" containedIn:aryDealIDs];
                    [dealsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (error == nil) {
                            NSMutableArray *aryDeals = [[NSMutableArray alloc] init];
                            for (PFObject *object in objects)
                            {
                                Deal *deal = [[Deal alloc] initWithParseObject:object];
                                [aryDeals addObject:deal];
                            }
                            
                            onDeals(aryDeals);
                        }
                        else
                        {
                            onDeals([[NSArray alloc] init]);
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)getStations:(RewardItem *)itemReward
             Result:(void (^)(NSArray *))onResult;
{
    PFQuery *query = [PFQuery queryWithClassName:@"Stations"];
    //    [query whereKey:@"country" equalTo:@"United States"];
    if(itemReward.newInstalled)
        [query whereKey:@"objectId" notContainedIn:itemReward.disabledAt];
    else
        [query whereKey:@"objectId" containedIn:itemReward.str_station];
    
    [query whereKey:@"station_loc"
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:WORK_STORE_LATITUDE longitude:WORK_STORE_LONGITUDE]
        withinMiles:200000.f];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error == nil && objects.count > 0)
        {
            NSMutableArray *aryStations = [[NSMutableArray alloc] init];
            for(int nIndex = 0; nIndex < aryStations.count; nIndex++)
            {
                Station *station = [[Station alloc] initWithParseObject:[objects objectAtIndex:nIndex]];
                [aryStations addObject:station];
            }
            onResult(aryStations);
        }
        else
            onResult([[NSArray alloc] init]);
    }];
}

- (void)getAllStations:(void (^)(NSArray *))onResult
{
    PFQuery *query = [PFQuery queryWithClassName:@"Stations"];
    //    [query whereKey:@"country" equalTo:@"United States"];
    [query whereKey:@"station_loc"
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:g_myInfo.fUserLatitude longitude:g_myInfo.fUserLongitude]
        withinMiles:200000.f];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && objects != nil) {
            NSMutableArray *aryStations = [[NSMutableArray alloc] init];
            for(int nIndex = 0; nIndex < objects.count; nIndex++)
            {
                Station *station = [[Station alloc] initWithParseObject:[objects objectAtIndex:nIndex]];
                [aryStations addObject:station];
            }
            onResult(aryStations);
        }
        else
            onResult([[NSArray alloc] init]);
    }];
}

- (void)recordRewardStateToParseWithStationID:(NSString *)stationID
                                         Slug:(NSString *)slug
                                        State:(NSString *)state
                                       DealID:(NSString *)dealID
{
    PFObject *rewardAnalitics = [PFObject objectWithClassName:@"rewardAnalytics"];
    PFUser *user = [PFUser currentUser];
    if(user == nil)
        return;
    
    rewardAnalitics[@"userId"] = user.objectId;
    rewardAnalitics[@"stationId"] = stationID;
    rewardAnalitics[@"slug"] = slug;
    rewardAnalitics[@"state"] = state;//on: scratched off: received
    rewardAnalitics[@"dealId"] = dealID;
    
    [rewardAnalitics saveInBackground];
}

- (void)getNearestStationWithCouponOfFavoriteStations:(NSArray *)aryStations
                                               Result:(void (^)(Station *, NSString *))onResult;
{
    PFQuery *query = [PFQuery queryWithClassName:@"coupon"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objCoupons, NSError *error) {
        if(error == nil && objCoupons.count > 0)
        {
            NSMutableArray *aryCouponFavorites = [[NSMutableArray alloc] init];
            for(int nIndex = 0; nIndex < objCoupons.count; nIndex++)
            {
                PFObject *objCoupon = [objCoupons objectAtIndex:nIndex];
                if([aryStations containsObject:[objCoupon objectForKey:@"stationId"]])
                {
                    [aryCouponFavorites addObject:[objCoupon objectForKey:@"stationId"]];
                }
            }
            
            if(aryCouponFavorites.count > 0)
            {
                PFQuery *stationQuery = [PFQuery queryWithClassName:@"Stations"];
                [stationQuery whereKey:@"objectId" containedIn:aryCouponFavorites];
                [stationQuery whereKey:@"station_loc"
                          nearGeoPoint:[PFGeoPoint geoPointWithLatitude:g_myInfo.fUserLatitude longitude:g_myInfo.fUserLongitude]
                           withinMiles:200000.f];
                [stationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *nearestObj, NSError *error) {
                    if(error == nil && nearestObj != nil)
                    {
                        Station *nearestStation = [[Station alloc] initWithParseObject:nearestObj];
                        for(int nIndex = 0; nIndex < objCoupons.count; nIndex++)
                        {
                            PFObject *objCoupon = [objCoupons objectAtIndex:nIndex];
                            if([nearestStation.strStationId isEqualToString:[objCoupon objectForKey:@"stationId"]])
                            {
                                nearestStation.dateCouponStart = [objCoupon objectForKey:@"startDate"];
                                nearestStation.dateCouponEnd = [objCoupon objectForKey:@"endDate"];
                                nearestStation.strCouponDealId = [objCoupon objectForKey:@"dealId"];
                                break;
                            }
                        }
                        onResult(nearestStation, nil);
                    }
                    else
                        onResult(nil, @"Sorry, your favorite stations have no coupon.");
                }];
            }
            else
                onResult(nil, @"Sorry, your favorite stations have no coupon.");
        }
        else
            onResult(nil, @"Sorry, we have no coupon yet.");
    }];
}

- (void)getCouponDealWithStationId:(Station *)couponStation
                            Result:(void (^)(Deal *, NSString *))onResult
{
    PFQuery *dealQuery = [PFQuery queryWithClassName:@"Deals"];
    [dealQuery whereKey:@"objectId" equalTo:couponStation.strCouponDealId];
    [dealQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(error == nil && object != nil)
        {
            Deal *deal = [[Deal alloc] initWithParseObject:object];
            onResult(deal, nil);
        }
        else
            onResult(nil, [error.userInfo objectForKeyedSubscript:@"error"]);
    }];
}

- (NSArray *)getFavoriteStations
{
    PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"FavoriteStations"];
    [favoriteQuery whereKey:@"userId" equalTo:g_myInfo.strUserId];
    PFObject *favoriteObject = [favoriteQuery getFirstObject];
    
    if(favoriteObject == nil)
        return [[NSArray alloc] init];
    else
        return [favoriteObject objectForKey:@"stations"];
}

- (void)saveFavoriteStationsWithStations:(NSArray *)aryFavoriteStations
                                  Result:(void (^)(NSString *))onResult
{
    PFQuery *favoriteQuery = [PFQuery queryWithClassName:@"FavoriteStations"];
    [favoriteQuery whereKey:@"userId" equalTo:g_myInfo.strUserId];
    [favoriteQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if(object == nil)
        {
            object = [PFObject objectWithClassName:@"FavoriteStations"];
        }
        
        [object setObject:g_myInfo.strUserId forKey:@"userId"];
        [object setObject:aryFavoriteStations forKey:@"stations"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error == nil)
                onResult(nil);
            else
                onResult([error.userInfo objectForKeyedSubscript:@"error"]);
        }];
        
    }];
}

- (void)getReceiptInfoWithCode:(NSNumber *)nCodeNumber
                        Result:(void (^)(Receipt *, NSString *))onResult
{
    PFQuery *stationQuery = [PFQuery queryWithClassName:@"Stations"];
    [stationQuery whereKey:@"receipt_code" equalTo:nCodeNumber];
    [stationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error && object)
        {
            Station *objStation = [[Station alloc] initWithParseObject:object];
            
            PFQuery *receiptQuery = [PFQuery queryWithClassName:@"Receipts"];
            [receiptQuery whereKey:@"stations" containedIn:@[objStation.strStationId]];
            [receiptQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error && object)
                {
                    Receipt *receipt = [[Receipt alloc] initWithPFObject:object];
                    
                    receipt.objReceiptStation = objStation;
                    NSArray *aryStations = object[@"stations"];
                    NSArray *aryProbabilities = object[@"probabilities"];
                    for(int nIndex = 0; nIndex < aryStations.count; nIndex++)
                    {
                        if([aryStations[nIndex] isEqualToString:objStation.strStationId])
                        {
                            receipt.nProbability = aryProbabilities[nIndex];
                            break;
                        }
                    }
                                        
                    onResult(receipt, nil);
                }
                else
                {
                    onResult(nil, @"Sorry, We didn't find the code you entered");
                }
            }];
        }
        else
        {
            onResult(nil, @"Sorry, We didn't find the code you entered");
        }
    }];
}

@end
