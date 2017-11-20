//
//  Station.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/5/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "Station.h"

@implementation Station

@synthesize strStationId;
@synthesize strStationName;
@synthesize strStationCountry;
@synthesize strStationState;
@synthesize strStationCity;
@synthesize strStationStreet;
@synthesize strStationZip;
@synthesize strSearchCity;
@synthesize strSearchName;
@synthesize strSearchState;
@synthesize fStationLatitude;
@synthesize fStationLongitude;

@synthesize dateCouponEnd;
@synthesize dateCouponStart;
@synthesize strCouponDealId;

- (id)init
{
    self = [super init];
    if(self)
    {
        strStationId = @"";
        strStationName = @"";
        strStationCountry = @"";
        strStationState = @"";
        strStationCity = @"";
        strStationStreet = @"";
        strStationZip = @"";
        strSearchName = @"";
        strSearchCity = @"";
        strSearchState = @"";
        fStationLatitude = 0.f;
        fStationLongitude = 0.f;
        
        //for coupon
        dateCouponStart = [NSDate date];
        dateCouponEnd = [NSDate date];
        strCouponDealId = @"";
    }
    
    return self;
}

- (id)initWithParseObject:(PFObject *)objStation
{
    Station *station = [[Station alloc] init];
    
    station.strStationId = objStation.objectId;
    station.strStationName = [objStation objectForKey:@"name"];
    station.strStationCountry = [objStation objectForKey:@"country"];
    station.strStationState = [objStation objectForKey:@"State"];
    station.strStationCity = [objStation objectForKey:@"City"];
    station.strStationStreet = [objStation objectForKey:@"street"];
    station.strStationZip = [objStation objectForKey:@"Zip"];
    station.strSearchCity = [objStation objectForKey:@"search_city"];
    station.strSearchName = [objStation objectForKey:@"search_name"];
    station.strSearchState = [objStation objectForKey:@"search_state"];
    
    PFGeoPoint* point = [objStation objectForKey:@"station_loc"];
    station.fStationLatitude = point.latitude;
    station.fStationLongitude = point.longitude;
    
    return station;
}

- (id)initWithDictionary:(NSDictionary *)dicStation
{
    Station *station = [[Station alloc] init];
    
    station.strStationId = [dicStation objectForKey:@"id"];
    station.strStationName = [dicStation objectForKey:@"name"];
    station.strStationCountry = [dicStation objectForKey:@"country"];
    station.strStationState = [dicStation objectForKey:@"State"];
    station.strStationCity = [dicStation objectForKey:@"City"];
    station.strStationStreet = [dicStation objectForKey:@"street"];
    station.strStationZip = [dicStation objectForKey:@"Zip"];
    station.strSearchCity = [dicStation objectForKey:@"search_city"];
    station.strSearchName = [dicStation objectForKey:@"search_name"];
    station.strSearchState = [dicStation objectForKey:@"search_state"];
    station.fStationLatitude = [[dicStation objectForKey:@"latitude"] floatValue];
    station.fStationLongitude = [[dicStation objectForKey:@"longitude"] floatValue];
    
    return station;
}

- (NSDictionary *)dictionary
{
    return @{
             @"id":strStationId,
             @"name":strStationName,
             @"country":strStationCountry,
             @"State":strStationState,
             @"City":strStationCity,
             @"street":strStationStreet,
             @"Zip":strStationZip,
             @"search_city":strSearchCity,
             @"search_name":strSearchName,
             @"search_state":strSearchState,
             @"latitude":[NSNumber numberWithFloat:fStationLatitude],
             @"longitude":[NSNumber numberWithFloat:fStationLongitude]
             };
}

- (float)getDistanceFromMe
{
    CLLocation* start = [[CLLocation alloc] initWithLatitude:WORK_STORE_LATITUDE longitude:WORK_STORE_LONGITUDE];
    return [start distanceFromLocation:[[CLLocation alloc] initWithLatitude:fStationLatitude
                                                                  longitude:fStationLongitude]] / 1609.344f;
    
}

@end
