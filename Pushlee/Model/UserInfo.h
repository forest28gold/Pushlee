//
//  UserInfo.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/3/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, retain) NSString          *strUserId;
@property (nonatomic, retain) NSString          *strUserFirstName;
@property (nonatomic, retain) NSString          *strUserLastName;
@property (nonatomic, retain) NSString          *strUserEmail;
@property (nonatomic, retain) NSString          *strUserPassword;
@property (nonatomic, retain) NSString          *strUserGender;
@property (nonatomic, retain) NSNumber          *nUserAge;
@property (nonatomic, retain) NSString          *strUserZipCode;
@property (nonatomic, readwrite) float          fUserLatitude;
@property (nonatomic, readwrite) float          fUserLongitude;
@property (nonatomic, retain) NSString          *strDeviceToken;
@property (nonatomic, retain) NSString          *strUserPhotoUrl;
@property (nonatomic, retain) NSString          *strUserInstallationId;

- (void)addInfoWithPFUser:(PFUser *)user;
- (id)initWithFirstName:(NSString *)firstName
               LastName:(NSString *)lastName
           UserPassword:(NSString *)userPassword
              UserEmail:(NSString *)userEmail
             UserGender:(NSString *)userGender
                UserAge:(NSString *)userAge
            UserZipCode:(NSString *)userZipCode;

- (BOOL)isNewUser;

@end
