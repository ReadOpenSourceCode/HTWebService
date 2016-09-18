//
//  HTWSFailureEntity.h
//  HTStandard
//
//  Created by Pan on 15/9/22.
//  Copyright (c) 2015年 Insigma Hengtian Software Co.,Ltd  All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  请求失败时返回的数据
 */
@interface HTWSFailureEntity : NSObject

@property (strong, nonatomic) NSURLSessionDataTask *task; /*返回的数据*/
@property (strong, nonatomic) NSError *error;             /*错误信息*/

@end
