//
//  PayManager.m
//  ApplePayDemo
//
//  Created by Zhi Zhuang on 2017/7/25.
//  Copyright © 2017年 Zhi Zhuang. All rights reserved.
//
//
//  1.对于项目初期，提升复费率 或是不想和苹果 分成的 可以做个开关（服务器端配置） 是否开启微信／支付宝 ，不过有风险，不抓到的 严重的 会被下架，很伤的
//
//  2.丢单，大部分是因为 [[SKPaymentQueue defaultQueue] finishTransaction: transaction] 时机不对 。
//
//  3.预防 “通过拦截发假票据的欺骗行为” ，一定要把transaction.transactionReceipt 放到服务器做校验
//
//  4.黑信用卡 以及 小额消费即“36技术” 通过 iOS 端上传uuid（虚拟设备号）， 服务器根据 uuid，客户端ip ，账号信用 ，支付币种 ，每日（周／月）交易次数限制 等综合 预防。抓到一个立马封号！
//
//  5. 外币支付， 通过币种校验，服务器设立币种白名单，只对那些稳定的货币 开放支付
//
//  综上：如果你们app 用户量还小， 3-5 你不用考虑了。等你们规模起来了 再去考虑这些。另外，就是 支付log，支付log，支付log，一定要传服务器，方便跟踪分析！

#import "PayManager.h"
#import "AlipayService.h"
#import "WechatPayService.h"
#import "ApplePayService.h"
#import <UIKit/UIKit.h>

#define ToWeak(var, weakVar) __weak __typeof(&*var) weakVar = var

@interface PayManager ()

@property(nonatomic,copy) void(^payBack)(Boolean  ,NSError*);
@property(nonatomic,strong) dispatch_semaphore_t  semaphore;

@end

@implementation PayManager{
    
    AlipayService       * alipay;
    WechatPayService    * wechat;
    ApplePayService     * apple;
    id<PayProtocol>       currentPay;
}

+ (void)load
{
    __block id observer =
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIApplicationDidFinishLaunchingNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification *note) {
         PAY;//初始化 ApplePayService ， addTransactionObserver
         [[NSNotificationCenter defaultCenter] removeObserver:observer];
     }];
}

+(instancetype)instance{
    static PayManager * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!_instance){
            _instance = [[PayManager alloc] init];
        }
    });
    return _instance;
}

-(instancetype)init{
    if (self = [super init]) {
        self.semaphore = dispatch_semaphore_create(1);
        currentPay = self.apple;
        NSLog(@"do yours");
    }
    return self;
}

-(void)purchase:(NSString*) productID payType:(PayType) payType withCallback:(void (^)(Boolean isSuccess ,NSError * error))callback
{
    ToServerLog(@"purchase %@",productID);
    //加锁
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.payBack = callback;
        switch (payType) {
            case PayApple:
                currentPay = self.apple;
                break;
            case PayAlipay:
                currentPay = self.alipay;
                break;
            case PayWechat:
                currentPay = self.wechat;
                break;
            default:
                break;
        }
        [self creatServerOrder:productID];
    });

}

-(void)creatServerOrder:(NSString*) productID
{
    ToServerLog(@"creatServerOrder %@",productID);
    //-----------send server-------------
    //
    //      向自己服务器发送创建订单请求 (整个订单流程都要uuid传给服务器)
    //
    //-----------from server-------------
    
    ToServerLog(@"creatOrder %@ success",productID);
    
    //  假设 money 是余额
    int money = 0;
    
    //假设订单 价格10元
    if (money > 10) {
        
        ToServerLog(@"use 余额 %@",productID);
        //-----------send server-------------
        //
        //      确认使用余额购买该订单
        //
        //-----------from server-------------
        //解锁
        dispatch_semaphore_signal(self.semaphore);
    }else{
        
        ToServerLog(@"假设使用App Store购买  %@",productID);
        ToWeak(self,weakSelf);
        [currentPay purchase:productID withCallback:^(Boolean isSuccess, NSError *error) {
            //解锁
            dispatch_semaphore_signal(weakSelf.semaphore);
            
            ToServerLog(@"购买结果  %@",productID);
            
            if(weakSelf.payBack){
                weakSelf.payBack(isSuccess,error);
            }
        }];
    }

}

-(AlipayService*)    alipay{
    return  alipay?:[[AlipayService alloc]init];
}

-(WechatPayService*) wechat{
    return  wechat?:[[WechatPayService alloc]init];
}

-(ApplePayService*)  apple{
    return  apple?:[[ApplePayService alloc]init];
}
@end
