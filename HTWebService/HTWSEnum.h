//
//  HTWSEnum.h
//  Pods
//
//  Created by Pan on 16/6/23.
//
//

#ifndef HTWSEnum_h
#define HTWSEnum_h

/**
 *  运行环境枚举，表明APP是运行在哪个环境下的。（连接的是哪个环境下的服务器）
 */
typedef NS_ENUM(NSInteger, HTWSEnvironment) {
    /** 开发环境*/
    HTWSEnvironmentDEV = 0,
    /** 测试环境*/
    HTWSEnvironmentQA = 1,
    /** 发布环境*/
    HTWSEnvironmentDIS = 2,
};

#endif /* HTWSEnum_h */
