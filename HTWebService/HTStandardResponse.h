//
//  HTStandardResponse.h
//  HTStandard
//
//  Created by Pan on 15/9/22.
//  Copyright (c) 2015年 Insigma Hengtian Software Co.,Ltd  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTWSEnum.h"
#import "HTWSProtocol.h"


UIKIT_EXTERN NSNotificationName _Nonnull const HTStandardResponseTokenOverdueNofitification;

/**
 *  业务状态枚举，表示后台返回的code所代表的状态
 */
typedef NS_ENUM(NSInteger, HTResponseCode) {
    /**
     *  业务成功
     */
    HTResponseCodeSuccess = 0,
    /**
     *  业务失败
     */
    HTResponseCodeFailure = 1,
    /**
     *  Token过期
     */
    HTResponseCodeTokenOverdue = 2,
};


/**
   标准化的 HTResponse 格式。 如果使用者没有定义 Response 格式，则采用标准化的 Response 格式。
 
   标准化的 HTResponse 设计如下:
 
   1. 将 HTTP 状态和业务状态分离。无论业务成功与否，只要请求成功，返回 HTTP CODE 为 200 。同时从返回数据中判断业务状态。
 
   2. 定义接口的返回JSON格式如下：
 
        {
            code:##, // 业务状态码，含义见下方
            data:{}, // 业务数据，泛型，可以是字典，数组，字符串，数字，布尔值
            message:"", // 业务失败时需要展示给用户的信息，例如 "密码错误，还有2次输入机会"
        }
 
    业务状态码的含义如下:
 
        0 业务成功
        1 业务失败
        2 Token过期（如果采用了类似 OAuth 的授权验证，并且将 Token 也视为业务范围）
 */
@interface HTStandardResponse : NSObject <HTWSResponse>

/**
 *   业务状态码
 */
@property (assign, nonatomic) HTResponseCode code;

/**
 *   提示信息
 */
@property (strong, nonatomic, nullable) NSString *message;

/**
 *   业务数据
 */
@property (strong, nonatomic, nullable) id data;

@end

