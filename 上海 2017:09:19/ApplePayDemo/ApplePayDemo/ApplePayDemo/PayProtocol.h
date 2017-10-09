//
//  PayProtocol.h
//  ApplePayDemo
//
//  Created by Zhi Zhuang on 2017/7/25.
//  Copyright © 2017年 Zhi Zhuang. All rights reserved.
//

#ifndef PayProtocol_h
#define PayProtocol_h

#define ToServerLog(fmt, ...) NSLog((@"[PURCHASE] %s  %d uuidxxxxx" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@protocol PayProtocol <NSObject>

-(void)purchase:(NSString*) productID withCallback:(void (^)(Boolean isSuccess, NSError * error))callback;

@end

#endif /* PayProtocol_h */
