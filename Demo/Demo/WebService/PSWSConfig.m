//
//  PSWSConfig.m
//  Demo
//
//  Created by Pan on 2016/10/13.
//  Copyright © 2016年 shengpan. All rights reserved.
//

#import "PSWSConfig.h"

NSString *const AddressDev = @"news-at.zhihu.com/";
NSString *const AddressQA = @"news-at.zhihu.com/";
NSString *const AddressDIS = @"news-at.zhihu.com/";

@implementation PSWSConfig

// 告诉框架是 http 还是 https ？
- (nonnull NSString *)baseServerSchema;
{
    return @"http://";
}

// 告诉框架，什么环境下为我选择什么地址
- (nonnull NSString *)baseServerAddressForEnvironment:(HTWSEnvironment)environment;
{
    switch (environment)
    {
        case HTWSEnvironmentDEV: return AddressDev;
        case HTWSEnvironmentQA: return AddressQA;
        case HTWSEnvironmentDIS: return AddressDIS;
    }
}

// 网络请求的超时时间
- (double)timeoutInterval
{
    return 30;
}

@end
