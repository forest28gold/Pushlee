//
//  WebService.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/3/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "WebService.h"

@implementation WebService

WebService *sharedWebObj = nil;
AFHTTPRequestOperationManager *manager;

+ (id)sharedInstance{
    
    if(!sharedWebObj)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            sharedWebObj = [[self alloc] init];
            manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", @"text/plain", @"application/vnd.apple.pkpass",  nil];
        });
    }
    
    return sharedWebObj;
}

- (void)getPKPassFromServerWithSation:(Station *)station
                                 Deal:(Deal *)deal
                            Completed:(void (^)(PKPass *))onCompleted
                               Failed:(void (^)(NSString *))onFailed
{
    NSString *barCode;
    if(deal.strProductId.length == 0)
        barCode = @"33333";
    else
        barCode = deal.strProductId;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
    NSString *strCouponStartDate = [dateFormatter stringFromDate:station.dateCouponStart];
    NSString *strCouponEndDate = [dateFormatter stringFromDate:station.dateCouponEnd];
    
    NSDictionary *dicParam = @{
                               @"stationId": station.strStationId,
                               @"stationName": station.strStationName,
                               @"dealName": deal.strDealName,
                               @"dealPrice": deal.nDealPrice,
                               @"description": deal.strDealDesc,
                               @"startDate": strCouponStartDate,
                               @"endDate": strCouponEndDate,
                               @"dealBarcode": barCode,
                               @"lat": [NSNumber numberWithFloat:station.fStationLatitude],
                               @"long": [NSNumber numberWithFloat:station.fStationLongitude],
                               @"stationAdd": station.strStationStreet
                               };
	
    [manager POST:PASS_BOOK_SERVER
       parameters:dicParam
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSError* error = nil;
              PKPass *objPass = [[PKPass alloc] initWithData:operation.responseData
                                                       error:&error];
              
              if(error == nil)
                  onCompleted(objPass);
              else
                  onFailed(error.description);
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              onFailed(error.description);
          }];
}

- (NSString *)getShortURL:(NSString *)strLongUrl
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1/url"]];
    [request setRequestHeaders:[NSMutableDictionary dictionaryWithDictionary:@{@"Content-Type" : @"application/json"}]];
    NSString* requestBody = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}", strLongUrl];
    [request setPostBody:[NSMutableData dataWithData:[requestBody dataUsingEncoding:NSUTF8StringEncoding]]];
    
    [request setRequestMethod:@"POST"];
    [request startSynchronous];
    
    NSString* shortURL = @"www.pushlee.com";
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSError* e;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                             options: NSJSONReadingMutableContainers
                                                               error: &e];
        shortURL = JSON[@"id"];
    }
    
    return shortURL;
}


@end
