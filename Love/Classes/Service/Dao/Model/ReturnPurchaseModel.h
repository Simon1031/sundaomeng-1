//
//  ReturnPurchaseModel.h
//  Love
//
//  Created by use on 14-12-26.
//  Copyright (c) 2014年 HaiTao. All rights reserved.
//
//退货
#import <Foundation/Foundation.h>

@interface ReturnPurchaseModel : NSObject
- (instancetype)initWithAttributtes:(NSDictionary *)attributes;

+ (void)getReturnPurchaseDataCode:(NSString *)code
                            intro:(NSString *)intro
                           reason:(NSString *)reason
                            money:(NSString *)money
                            image:(NSString *)img
                            block:(void(^)(int code, NSString *msg))block;
@end
