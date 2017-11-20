//
//  Receipt.m
//  Pushlee
//
//  Created by AppsCreationTech on 12/23/14.
//  Copyright (c) 2014 AppsCreationTech. All rights reserved.
//

#import "Receipt.h"

@implementation Receipt

@synthesize     strReceiptId;
@synthesize     strRewardName;
@synthesize     strRewardDescription;
@synthesize     strRewardBarcode;
@synthesize     strRewardImageUrl;
@synthesize     nProbability;
@synthesize     nRedemptions;

@synthesize     objReceiptStation;


- (id)init
{
    self = [super init];
    if(self)
    {
        strReceiptId = @"";
        strRewardName = @"";
        strRewardDescription = @"";
        strRewardBarcode = @"";
        strRewardImageUrl = @"";
        objReceiptStation = [[Station alloc] init];
    }
    
    return self;
}

- (id)initWithPFObject:(PFObject *)objPFReceipt
{
    Receipt *receipt = [[Receipt alloc] init];
    
    receipt.strReceiptId = objPFReceipt.objectId;
    receipt.strRewardName = objPFReceipt[@"reward_name"];
    receipt.strRewardDescription = objPFReceipt[@"reward_description"];
    receipt.strRewardBarcode = [NSString stringWithFormat:@"%d", [objPFReceipt[@"reward_barcode"] intValue]];
    receipt.strRewardImageUrl = objPFReceipt[@"reward_image_url"];
    receipt.nRedemptions = objPFReceipt[@"redemptions"];
    
    return receipt;
}

@end
