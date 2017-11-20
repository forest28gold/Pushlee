//
//  Receipt.h
//  Pushlee
//
//  Created by AppsCreationTech on 12/23/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Receipt : NSObject

@property (nonatomic, retain) NSString  *strReceiptId;
@property (nonatomic, retain) NSString  *strRewardName;
@property (nonatomic, retain) NSString  *strRewardDescription;
@property (nonatomic, retain) NSString  *strRewardBarcode;
@property (nonatomic, retain) NSString  *strRewardImageUrl;
@property (nonatomic, retain) NSNumber  *nProbability;
@property (nonatomic, retain) NSNumber  *nRedemptions;

@property (nonatomic, retain) Station   *objReceiptStation;

- (id)initWithPFObject:(PFObject *)objPFReceipt;

@end
