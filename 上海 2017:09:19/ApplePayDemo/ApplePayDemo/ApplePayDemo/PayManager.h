//
//  PayManager.h
//  ApplePayDemo
//
//  Created by Zhi Zhuang on 2017/7/25.
//  Copyright © 2017年 Zhi Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#define PAY [PayManager instance];

typedef NS_ENUM(NSInteger, PayType) {
    PayApple,
    PayAlipay,
    PayWechat,
};

@interface PayManager : NSObject

+(instancetype)instance;

-(void)purchase:(NSString*) productID payType:(PayType) payType withCallback:(void (^)(Boolean isSuccess, NSError * error))callback;

@end
