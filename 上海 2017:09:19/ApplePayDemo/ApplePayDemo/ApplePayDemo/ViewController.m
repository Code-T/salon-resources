//
//  ViewController.m
//  ApplePayDemo
//
//  Created by Zhi Zhuang on 2017/7/25.
//  Copyright © 2017年 Zhi Zhuang. All rights reserved.
//

#import "ViewController.h"
#import "PayManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[PayManager instance] purchase:@"com.qiye.product00001" payType:PayApple withCallback:^(Boolean isSuccess, NSError *error) {
        NSLog(@"do deal");
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
