//
//  UserInfo.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/3/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

@synthesize             strUserId;
@synthesize             strUserFirstName;
@synthesize             strUserLastName;
@synthesize             strUserEmail;
@synthesize             strUserPassword;
@synthesize             strUserGender;
@synthesize             nUserAge;
@synthesize             strUserZipCode;
@synthesize             fUserLatitude;
@synthesize             fUserLongitude;
@synthesize             strDeviceToken;
@synthesize             strUserPhotoUrl;
@synthesize             strUserInstallationId;

- (id)init
{
    self = [super init];
    if(self)
    {
        strUserId = @"";
        strUserFirstName = @"";
        strUserLastName = @"";
        strUserEmail = @"";
        strUserPassword = @"";
        strUserGender = @"Male";
        nUserAge = [[NSNumber alloc] init];
        strUserZipCode = @"";
        fUserLongitude = WORK_STORE_LONGITUDE;
        fUserLatitude = WORK_STORE_LATITUDE;
        strDeviceToken = @"";
        strUserPhotoUrl = @"";
        strUserInstallationId = @"";
    }
    
    return self;
}

- (void)addInfoWithPFUser:(PFUser *)user
{
    strUserId = user.objectId;
    strUserFirstName = [user objectForKey:@"firstName"] == nil ? @"" : [user objectForKey:@"firstName"];
    strUserLastName = [user objectForKey:@"lastName"] == nil ? @"" : [user objectForKey:@"lastName"];
    strUserEmail = user.email;
    strUserGender = [user objectForKey:@"gender"];
    nUserAge = [user objectForKey:@"age"];
    strUserZipCode = [user objectForKey:@"zip"];
    strUserPhotoUrl = [user objectForKey:@"image2"];
}

- (id)initWithFirstName:(NSString *)firstName
               LastName:(NSString *)lastName
           UserPassword:(NSString *)userPassword
              UserEmail:(NSString *)userEmail
             UserGender:(NSString *)userGender
                UserAge:(NSString *)userAge
            UserZipCode:(NSString *)userZipCode
{
    UserInfo *userInfo = [[UserInfo alloc] init];
    
    userInfo.strUserFirstName = firstName;
    userInfo.strUserLastName = lastName;
    userInfo.strUserPassword = userPassword;
    userInfo.strUserEmail = userEmail;
    userInfo.strUserGender = userGender;
    userInfo.nUserAge = [NSNumber numberWithInt:[userAge intValue]];
    userInfo.strUserZipCode = userZipCode;
    userInfo.strUserInstallationId = [[PFInstallation currentInstallation] installationId];
    
    return userInfo;
}

- (BOOL)isNewUser
{
    return [PFUser currentUser].isNew;
}

@end
