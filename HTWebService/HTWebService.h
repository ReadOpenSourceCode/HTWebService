//
//  HTWebservice.h
//  HTStandard
//
//  Created by Pan on 15/9/22.
//  Copyright (c) 2015年 Insigma Hengtian Software Co.,Ltd  All rights reserved.
//

#import <AFNetWorking/AFNetworking.h>
#import "HTStandardResponse.h"
#import "HTWSFailureEntity.h"
#import "HTWSProtocol.h"


@class HTStandardResponse;

UIKIT_EXTERN NSNotificationName _Nonnull const HTWebServiceNeedShowTipsNofitification;

/**
 *  网络层请求类型定义，分别对应 RESTful 的六种请求。
 */
typedef NS_ENUM(NSInteger, HTHTTPMethod) {
    /** GET 请求 */
    HTHTTPMethodGET,
    /** POST 请求 */
    HTHTTPMethodPOST,
    /** PUT 请求 */
    HTHTTPMethodPUT,
    /** PATCH 请求 */
    HTHTTPMethodPATCH,
    /** DELETE 请求 */
    HTHTTPMethodDELETE,
    /** HEAD 请求 */
    HTHTTPMethodHEAD,
};

/**
 *  网络层核心类，负责 RESTful 请求、Json -> Model 映射，分离业务和请求等。
 */
@interface HTWebService<T: id<HTWSResponse>> : AFHTTPSessionManager

/** 业务成功的回调Block*/
typedef void (^HTBusinessSuccessBlock)(_Nonnull T response);

/** 业务失败的回调Block*/
typedef void (^HTBusinessFailureBlock)(T _Nonnull failureRespone);

/** 请求失败的回调Block*/
typedef void (^HTRequestFailureBlock)(HTWSFailureEntity *_Nonnull failureEntity);

/** 不管业务成功失败总是会执行的Block*/
typedef void (^HTAlwaysExecuteBlock)();

/**
 *  该类的配置对象
 */
@property (nonatomic, strong, readonly, nonnull) id<HTWSConfig> config;

/**
 *  该类的返回数据数据结构对象
 */
@property (nonatomic, strong, readonly, nonnull) T responseStructure;

/**
 *  创建并返回一个 `HTWebService` 对象
 *  @param configuration 必传参数，实现了 HTWSConfig 的配置对象。
 *  @param response      可选参数，实现了 HTWSResponse 的返回 JSON 结构表示对象。如果传nil，则会采用HTStandardResponse
 *  @return HTWebService
 */
- (nonnull instancetype)initWithConfig:(nonnull id<HTWSConfig>)configuration
                     responseStructure:(nullable T)response NS_DESIGNATED_INITIALIZER;

/**
 *  为请求头添加信息
 *  @param value 值
 *  @param field 键
 */
- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(nonnull NSString *)field;

#pragma mark - Core Method

- (void)requestEasilyWithMethod:(HTHTTPMethod)method
                           path:(nonnull NSString *)subPath
                     parameters:(nullable id)parameters
                businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
                        finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;

- (void)requestSilentlyWithMethod:(HTHTTPMethod)method
                             path:(nonnull NSString *)subPath
                       parameters:(nullable id)parameters
                  businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
                          finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;

/**
 *  自行选择 HTTP Method 进行请求
 *  @param method             HTTP Method
 *  @param subPath            API地址
 *  @param parameters         参数
 *  @param bizSuccessBlock    业务成功执行此block  NONULL
 *  @param bizFailureBlock    业务失败执行此block
 *  @param reqFailureBlock    请求失败执行此block
 *  @param alwaysExecuteBlock 如果非nil 则不论请求成功或者失败，都会执行
 */
- (void)requestWithHTTPMethod:(HTHTTPMethod)method
                         path:(nonnull NSString *)subPath
                   parameters:(nullable id)parameters
              businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
              businessFailure:(nullable HTBusinessFailureBlock)bizFailureBlock
               requestFailure:(nullable HTRequestFailureBlock)reqFailureBlock
                      finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;

@end

@interface HTWebService (Convience)

/**
 *  简化版GET请求，只处理业务成功的状态。其他状态默认展现一下提示窗口。
 *
 *  @param subPath            API地址
 *  @param parameters         参数
 *  @param bizSuccessBlock    业务成功执行此block NONULL
 *  @param alwaysExecuteBlock 如果非nil 则不论请求成功或者失败，都会执行
 */
- (void)getEasilyWithPath:(nonnull NSString *)subPath
               parameters:(nullable id)parameters
          businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
                  finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;


/**
 *  简化版POST请求，只处理业务成功的状态。其他状态默认展现一下提示窗口。
 *
 *  @param subPath            API地址
 *  @param parameters         参数
 *  @param bizSuccessBlock    业务成功执行此block NONULL
 *  @param alwaysExecuteBlock 如果非nil 则不论请求成功或者失败，都会执行
 */
- (void)postEasilyWithPath:(nonnull NSString *)subPath
                parameters:(nullable id)parameters
           businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
                   finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;


/**
 *  静默的GET请求，只处理业务成功的状态。其他状态不进行任何提示
 *
 *  @param subPath            API地址
 *  @param parameters         参数
 *  @param bizSuccessBlock    业务成功执行此block NONULL
 *  @param alwaysExecuteBlock 如果非nil 则不论请求成功或者失败，都会执行
 */
- (void)getSilentlyWithPath:(nonnull NSString *)subPath
                 parameters:(nullable id)parameters
            businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
                    finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;


/**
 *  静默的POST请求，只处理业务成功的状态。其他状态不进行任何提示
 *
 *  @param subPath            API地址
 *  @param parameters         参数
 *  @param bizSuccessBlock    业务成功执行此block NONULL
 *  @param alwaysExecuteBlock 如果非nil 则不论请求成功或者失败，都会执行
 */
- (void)postSilentlyWithPath:(nonnull NSString *)subPath
                  parameters:(nullable id)parameters
             businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
                     finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;

/**
 *  GET 请求
 *
 *  @param subPath            API地址
 *  @param parameters         参数
 *  @param bizSuccessBlock    业务成功执行此block NONULL
 *  @param bizFailureBlock    业务失败执行此block
 *  @param reqFailureBlock    请求失败执行此block
 *  @param alwaysExecuteBlock 如果非nil 则不论请求成功或者失败，都会执行
 */
- (void)getWithPath:(nonnull NSString *)subPath
         parameters:(nullable id)parameters
    businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
    businessFailure:(nullable HTBusinessFailureBlock)bizFailureBlock
     requestFailure:(nullable HTRequestFailureBlock)reqFailureBlock
            finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;

/**
 *  POST 请求
 *
 *  @param subPath            API地址
 *  @param parameters         参数
 *  @param bizSuccessBlock    业务成功执行此block  NONULL
 *  @param bizFailureBlock    业务失败执行此block
 *  @param reqFailureBlock    请求失败执行此block
 *  @param alwaysExecuteBlock 如果非nil 则不论请求成功或者失败，都会执行
 */
- (void)postWithPath:(nonnull NSString *)subPath
          parameters:(nullable id)parameters
     businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
     businessFailure:(nullable HTBusinessFailureBlock)bizFailureBlock
      requestFailure:(nullable HTRequestFailureBlock)reqFailureBlock
             finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;

@end
