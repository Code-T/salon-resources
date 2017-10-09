//
//  ApplePayService.m
//  ApplePayDemo
//
//  Created by Zhi Zhuang on 2017/7/25.
//  Copyright © 2017年 Zhi Zhuang. All rights reserved.
//

#import "ApplePayService.h"
#import <StoreKit/StoreKit.h>

@interface ApplePayService()<SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic,copy) void (^callBack)(Boolean isSuccess, NSError * error);
@end

@implementation ApplePayService

-(instancetype)init{
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void)purchase:(NSString*) productID withCallback:(void (^)(Boolean isSuccess, NSError * error))callback {
    self.callBack = callback;
    
    if ([SKPaymentQueue canMakePayments]) {
        //Purchase tracking, iap canMakePayments
        NSSet *set = [NSSet setWithObjects:productID, nil];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
        ToServerLog(@"canMakePayments YES:%@",productID);  //常有发生
    } else {
        ToServerLog(@"canMakePayments NO:%@",productID);  //常有发生
        if(self.callBack) self.callBack(NO,[NSError new]);//告知用户是用户自己禁止了支付
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        ToServerLog(@"Product id invalid");  //常有发生
        if(self.callBack) self.callBack(NO,[NSError new]);
        return;
    }
    SKProduct *product = [myProduct objectAtIndex:0];

    //-----------send server-------------
    //
    //      校验币种
    //
    //-----------from server-------------
    //
    
    ToServerLog(@"Product start:%@",product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)requestDidFinish:(SKRequest *)request{
    ToServerLog(@"Product request finish");
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    ToServerLog(@"Product request failed :%@",error.localizedDescription);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing: // 0
                break;
            case SKPaymentTransactionStatePurchased:  // 1
                //订阅特殊处理
                if(transaction.originalTransaction){
                    //如果是自动续费的订单originalTransaction会有内容
                    [self completeTransaction:transaction];
                }else{
                    //普通购买，以及 第一次购买 自动订阅
                    [self completeTransaction:transaction];
                }
                break;
            case SKPaymentTransactionStateFailed:     // 2
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:   // 3  当某些订阅需求需要恢复功能时候，调用 restoreCompletedTransactions 方法 触发；
                [self restoreTransaction:transaction];
                break;
            default:
                
                break;
        }
        
        if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            ToServerLog(@"paymentQueue updatedTransactions failed :%@",transaction);
        }else{
            ToServerLog(@"paymentQueue updatedTransactions  :%ldd",(long)transaction.transactionState);
        }
    }
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {

    NSString * productIdentifier = transaction.payment.productIdentifier;
    NSString * receiptBase64 = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];

    ToServerLog(@"completeTransaction %@ ,%@",productIdentifier ,receiptBase64);
    //-----------send server-------------
    //
    //      向自己服务器发送 订单receipt  ,验证订单有效性  (3-5次重连接机制)
    //
    //-----------from server-------------
    //  假设 code 和 error 是服务器返回
    
    int       code = 200; // 200订单有效   201订单已校验  202 订单无效     404 服务器无法连接  2022 网络异常
    NSError * error = [NSError new];

    if (code == 200 || code == 201 || code == 202 )
    {
        ToServerLog(@"completeTransaction %@ success",productIdentifier);
        if(self.callBack) self.callBack(YES,nil);
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];//这个 finishTransaction 一定要放在等到服务器响应后。不然会有几率丢单
    }else{//404 服务器无法连接  2022 网络异常
        
        //有些人方案是把未成功的订单 productIdentifier receipt 等写到本地，下次启动时候 或是有网时候 触发 重新请求服务器
        //但是我不推荐这种做法
        if(self.callBack) self.callBack(NO,error);
    }
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    ToServerLog(@"restoreTransaction %@ ",transaction.payment.productIdentifier);
    //判断逻辑，省略一些
    [self completeTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSString *errorMsg = @"";
        if(transaction.error.code == SKErrorUnknown) {
            errorMsg = @"SKErrorUnknown";
        }else if(transaction.error.code == SKErrorClientInvalid) {
            errorMsg = @"SKErrorClientInvalid";
        }else if(transaction.error.code == SKErrorPaymentInvalid) {
            errorMsg = @"SKErrorPaymentInvalid";
        }else if(transaction.error.code == SKErrorPaymentNotAllowed) {
            errorMsg = @"SKErrorPaymentNotAllowed";
        }else if(transaction.error.code == SKErrorStoreProductNotAvailable){
            errorMsg = @"SKErrorStoreProductNotAvailable";
        }else if(transaction.error.code == SKErrorCloudServicePermissionDenied){
            errorMsg = @"SKErrorCloudServicePermissionDenied";
        }else if(transaction.error.code == SKErrorCloudServiceNetworkConnectionFailed){
            errorMsg = @"SKErrorCloudServiceNetworkConnectionFailed";
        }else{
            errorMsg = [NSString stringWithFormat:@"UnknowError, errorCode:%ld", transaction.error.code];
        }
        errorMsg = [NSString stringWithFormat:@"%@, errorUserInfo:%@", errorMsg, transaction.error.userInfo];
        
        //增加了当错误码 为 -2时候用户取消行为， 归类为用户取消。
        if(transaction.error.code == -2){
            ToServerLog(@"failedTransaction user cancel: %ld",transaction.error.code);
        }else{
            ToServerLog(@"failedTransaction other error: %@",errorMsg);
        }
    } else {
        ToServerLog(@"failedTransaction user cancel %ld",transaction.error.code);
    }
    if(self.callBack) self.callBack(NO,[NSError new]);
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)dealloc
{
    //要移除侦听，否则在Unity 3D 游戏会出现Crash
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
