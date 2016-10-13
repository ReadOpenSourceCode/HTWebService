//
//  PSResponse.h
//  Demo
//
//  Created by Pan on 2016/10/13.
//  Copyright © 2016年 shengpan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTWSProtocol.h"

typedef NS_ENUM(NSUInteger, ResponseCode) {
    ResponseCodeSuccess = 0,
    ResponseCodeFailure = 1,
    ResponseCodeTokenOverdue = 2,
};

// 定义 JSON 最外层的格式
@interface PSResponse : NSObject<HTWSResponse>

@property (nonatomic, assign) ResponseCode code;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSString *message;

@end
