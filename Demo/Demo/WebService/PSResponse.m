//
//  PSResponse.m
//  Demo
//
//  Created by Pan on 2016/10/13.
//  Copyright © 2016年 shengpan. All rights reserved.
//

#import "PSResponse.h"

@implementation PSResponse

// 实现初始化方法，框架会自动调用
- (nonnull instancetype)initWithJSON:(nonnull NSDictionary *)JSON
{
    self = [super init];
    if (self)
    {
        // 属性值和最外层的 JSON 的 key 意义对应赋值
        self.code = [[JSON objectForKey:@"code"] integerValue];
        self.data = [JSON objectForKey:@"object"];
        self.message = [JSON objectForKey:@"messgae"];
    }
    return self;
}

- (BOOL)isBusinessSuccess
{
    // 告诉框架，什么算业务成功。
    return self.code == ResponseCodeSuccess;
}

- (BOOL)shouldHandleBusinessFailure
{
    // 我打算自己处理Token 过期的情况
    if (self.code == ResponseCodeTokenOverdue)
    {
        // 做一些 Token 过期的处理
        // ...
        // ...
        // 一个比较好的实践是将需要自己处理的错误转发出去，由一个专门的对象来处理这个错误
        
        return NO; // 告诉网络框架，不要帮我处理这种情况下的错误。
    }
    else
    {
         // 除了 Token 过期，其他错误我都不关心，让框架统一处理。
        return YES;
    }
}

- (nullable NSString *)messageWhenBusinessFailure
{
    // 告诉框架，默认处理错误，需要显示给用户的提示是什么。如果不要显示任何信息，则直接 return nil
    return self.message;
}

@end
