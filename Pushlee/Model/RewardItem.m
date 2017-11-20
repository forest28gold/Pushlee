//
//  RewardItem.m
//  Pushlee
//
//  Created by AppsCreationTech on 9/30/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "RewardItem.h"

@implementation RewardItem

-(id)initWithEmptyObject{
	
	self = [super init];
	
	if(self){
		
		self.rewardId = @"";
		self.stationId = @"";
		self.str_station = [[NSArray alloc] init];
		self.imageUrl= @"";
		self.title = @"";
		self.description_ = @"";
		self.barcode = @"";
		self.coverImageID = 0;
		self.sub_desc = @"";
		self.scratched = NO; //default is false(still not scratched)
		self.obj_stations = [[NSArray alloc] init];
		self.newInstalled = YES;
		self.baseTime = 600;
		self.redeemed = NO;  // if redeemed will show in present permanently.;
		self.stationInfo = @"";
		self.stationName = @"";
		self.stationCity = @"";
		self.disabledAt = [[NSArray alloc] init];
		self.strSlug = @"";
		self.newBaseTime = 0;
	}
	
	return self;
	
}

-(id)initWithDictionary:(NSMutableDictionary*)dict{
	
	self = [super init];
	
	if(self){
		
		self.m_dictionary = dict;
		
		self.rewardId = dict[@"rewardId"];
		self.stationId = dict[@"stationId"];
		self.str_station = dict[@"str_station"];
		self.imageUrl = dict[@"imageUrl"];
		self.title = dict[@"title"];
		self.description_ = dict[@"description_"];
		self.barcode = dict[@"barcode"];
		self.coverImageID = [dict[@"coverImageID"] intValue];
		self.sub_desc = dict[@"sub_desc"];
		self.scratched = [dict[@"scratched"] boolValue];
		self.obj_stations = dict[@"obj_stations"];
		self.newInstalled = [dict[@"newInstalled"] boolValue];
		self.baseTime = [dict[@"baseTime"] longValue];
		self.redeemed = [dict[@"redeemed"] boolValue];
		self.stationInfo = dict[@"stationInfo"];
		self.stationName = dict[@"stationName"];
		self.disabledAt = dict[@"disabledAt"];
		self.strSlug = dict[@"strSlug"];
		self.stationCity =dict[@"stationCity"];
		self.newBaseTime = [dict[@"newBaseTime"] longValue];
		
	}
	
	return self;
	
}

- (NSDictionary*)dictionary{
	
	self.m_dictionary = [[NSMutableDictionary alloc] init];
	
	self.m_dictionary[@"rewardId"]    =   self.rewardId;
	self.m_dictionary[@"stationId"]   =   self.stationId;
	self.m_dictionary[@"str_station"] =   self.str_station;
	self.m_dictionary[@"imageUrl"]    =   self.imageUrl;
	self.m_dictionary[@"title"]       =   self.title;
	self.m_dictionary[@"description_"]=   self.description_;
	self.m_dictionary[@"barcode"]     =   self.barcode == nil ? @"" : self.barcode;
	self.m_dictionary[@"coverImageID"]=   [NSNumber numberWithInt:self.coverImageID];
	self.m_dictionary[@"sub_desc"]    =   self.sub_desc;
	self.m_dictionary[@"scratched"]   =   [NSNumber numberWithBool:self.scratched];
	self.m_dictionary[@"obj_stations"]=   self.obj_stations;
	self.m_dictionary[@"newInstalled"]=   [NSNumber numberWithBool:self.newInstalled];
	self.m_dictionary[@"baseTime"]    =   [NSNumber numberWithLong:self.baseTime];
	self.m_dictionary[@"redeemed"]    =   [NSNumber numberWithBool:self.redeemed];
	self.m_dictionary[@"stationInfo"] =   self.stationInfo;
	self.m_dictionary[@"stationName"] =   self.stationName;
	self.m_dictionary[@"disabledAt"]  =   self.disabledAt;
	self.m_dictionary[@"strSlug"]  =   self.strSlug;
	self.m_dictionary[@"stationCity"]  =   self.stationCity;
	self.m_dictionary[@"newBaseTime"] = [NSNumber numberWithLong:self.newBaseTime];
	
	return self.m_dictionary;	
}

@end
