//
//  HTWebservice.m
//  HTStandard
//
//  Created by Pan on 15/9/22.
//  Copyright (c) 2015年 Insigma Hengtian Software Co.,Ltd  All rights reserved.
//

#import "HTWebservice.h"
#import "Reachability.h"

#ifdef DEBUG
#define HTLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__);
#else
#define HTLog(...)
#endif

#define HT_IS_NULL(string) (!string || [string isEqual:@""] || [string isEqual:[NSNull null]])

NSNotificationName const HTWebServiceNeedShowTipsNofitification = @"HTWebServiceNeedShowTipsNofitification";

const double DefaultTimeoutInterval = 30;

@interface HTWebService ()

@property (nonatomic, strong, readwrite) id<HTWSConfig> config;
@property (nonatomic, strong, readwrite) id<HTWSResponse> responseStructure;

@end

@implementation HTWebService

- (instancetype)initWithConfig:(nonnull id<HTWSConfig>)configuration
             responseStructure:(nullable id<HTWSResponse>)response;
{
    // 检查传进来的参数是否真的实现了协议中的方法
    [HTWebService checkConfig:configuration];
    if (response)
    {
        [HTWebService checkResponseExample:response];
    }
    // 提取初始化所需的 baseUrl
    NSURL *baseURL = [HTWebService baseURLFromConfig:configuration];
    self = [super initWithBaseURL:baseURL
             sessionConfiguration:nil];
    if (self)
    {
        _config = configuration;
        _responseStructure = response;
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
        
        if ([_config respondsToSelector:@selector(timeoutInterval)])
        {
            self.requestSerializer.timeoutInterval = [_config timeoutInterval];
        }
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)url
           sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration
{
    NSAssert(NO, @"请勿在 HTWebservice 中直接调用 -initWithBaseURL:sessionConfiguration 方法");
    id<HTWSConfig> fakeConfig;
    return [self initWithConfig:fakeConfig
              responseStructure:nil];
}


#pragma mark - Public

- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(nonnull NSString *)field;
{
    [self.requestSerializer setValue:value forHTTPHeaderField:field];
}

- (void)requestEasilyWithMethod:(HTHTTPMethod)method
                           path:(nonnull NSString *)subPath
                     parameters:(nullable id)parameters
                businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
                        finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;
{
    [self requestWithHTTPMethod:method
                           path:subPath
                     parameters:parameters
                businessSuccess:bizSuccessBlock
                businessFailure:nil
                 requestFailure:nil
                        finally:alwaysExecuteBlock];
}

- (void)requestSilentlyWithMethod:(HTHTTPMethod)method
                             path:(nonnull NSString *)subPath
                       parameters:(nullable id)parameters
                  businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
                          finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;
{
    [self requestWithHTTPMethod:method
                           path:subPath
                     parameters:parameters
                businessSuccess:bizSuccessBlock
                businessFailure:^(id<HTWSResponse> failureRespone) {}
                 requestFailure:^(HTWSFailureEntity *failureEntity) {}
                        finally:alwaysExecuteBlock];
}


- (void)requestWithHTTPMethod:(HTHTTPMethod)method
                         path:(nonnull NSString *)subPath
                   parameters:(nullable id)parameters
              businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
              businessFailure:(nullable HTBusinessFailureBlock)bizFailureBlock
               requestFailure:(nullable HTRequestFailureBlock)reqFailureBlock
                      finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock
{
    if (![self isReachable])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HTWebServiceNeedShowTipsNofitification object:@"没有连接网络"];
        return;
    }
    [self logRequestWithHTTPMethod:method parameter:parameters path:subPath];
    
    switch (method) {
        case HTHTTPMethodGET:
        {
            [self GET:subPath
           parameters:parameters
             progress:^(NSProgress * _Nonnull downloadProgress) {
                 HTLog(@"%@ receive progress: %@", subPath, downloadProgress.localizedAdditionalDescription);
             }
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  [self logResponse:responseObject path:subPath];
                  [self handleSuccessWithOperation:task
                                          response:responseObject
                                   businessSuccess:bizSuccessBlock
                                   businessFailure:bizFailureBlock
                                           finally:alwaysExecuteBlock];
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  [self logError:error path:subPath];
                  [self handleFailureWithOperation:task
                                             error:error
                                    requestFailure:reqFailureBlock
                                           finally:alwaysExecuteBlock];
              }];
            break;
        }
        case HTHTTPMethodPOST:
        {
            [self POST:subPath
            parameters:parameters
              progress:^(NSProgress * _Nonnull uploadProgress) {
                  HTLog(@"%@ update progress: %@", subPath, uploadProgress.localizedAdditionalDescription);
              }
               success:^(NSURLSessionDataTask *task, id responseObject) {
                   [self logResponse:responseObject path:subPath];
                   [self handleSuccessWithOperation:task
                                           response:responseObject
                                    businessSuccess:bizSuccessBlock
                                    businessFailure:bizFailureBlock
                                            finally:alwaysExecuteBlock];
               }
               failure:^(NSURLSessionDataTask *task, NSError *error) {
                   [self logError:error path:subPath];
                   [self handleFailureWithOperation:task
                                              error:error
                                     requestFailure:reqFailureBlock
                                            finally:alwaysExecuteBlock];
               }];
            break;
        }
        case HTHTTPMethodPUT:
        {
            [self PUT:subPath
           parameters:parameters
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  [self logResponse:responseObject path:subPath];
                  [self handleSuccessWithOperation:task
                                          response:responseObject
                                   businessSuccess:bizSuccessBlock
                                   businessFailure:bizFailureBlock
                                           finally:alwaysExecuteBlock];
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  [self logError:error path:subPath];
                  [self handleFailureWithOperation:task
                                             error:error
                                    requestFailure:reqFailureBlock
                                           finally:alwaysExecuteBlock];
              }];
            break;
        }
        case HTHTTPMethodHEAD:
        {
            [self HEAD:subPath
            parameters:parameters
               success:^(NSURLSessionDataTask * _Nonnull task) {
                   [self handleSuccessWithOperation:task
                                           response:nil
                                    businessSuccess:bizSuccessBlock
                                    businessFailure:bizFailureBlock
                                            finally:alwaysExecuteBlock];
               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   [self logError:error path:subPath];
                   [self handleFailureWithOperation:task
                                              error:error
                                     requestFailure:reqFailureBlock
                                            finally:alwaysExecuteBlock];
               }];
            break;
        }
        case HTHTTPMethodPATCH:
        {
            [self PATCH:subPath
             parameters:parameters
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self logResponse:responseObject path:subPath];
                    [self handleSuccessWithOperation:task
                                            response:responseObject
                                     businessSuccess:bizSuccessBlock
                                     businessFailure:bizFailureBlock
                                             finally:alwaysExecuteBlock];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self logError:error path:subPath];
                    [self handleFailureWithOperation:task
                                               error:error
                                      requestFailure:reqFailureBlock
                                             finally:alwaysExecuteBlock];
                }];
            break;
        }
        case HTHTTPMethodDELETE:
        {
            [self DELETE:subPath
              parameters:parameters
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     [self handleSuccessWithOperation:task
                                             response:responseObject
                                      businessSuccess:bizSuccessBlock
                                      businessFailure:bizFailureBlock
                                              finally:alwaysExecuteBlock];
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     [self logError:error path:subPath];
                     [self handleFailureWithOperation:task
                                                error:error
                                       requestFailure:reqFailureBlock
                                              finally:alwaysExecuteBlock];
                 }];
            break;
        }
    }
}


#pragma mark - Private

- (void)handleSuccessWithOperation:(NSURLSessionDataTask *)task
                          response:(id)responseObject
                   businessSuccess:(HTBusinessSuccessBlock)bizSuccessBlock
                   businessFailure:(HTBusinessFailureBlock)bizFailureBlock
                           finally:(HTAlwaysExecuteBlock)alwaysExecuteBlock

{
    // 如果用户配置过Response的格式，就采用用户配置过的格式，否者采用默认的格式
    Class JSONClass = self.responseStructure ? self.responseStructure.class : HTStandardResponse.class;
    id<HTWSResponse> response = [[JSONClass alloc] initWithJSON:responseObject];
    
    //请求成功了，如果业务也成功，直接执行业务成功Block
    if ([response isBusinessSuccess])
    {
        NSAssert(bizSuccessBlock, ([NSString stringWithFormat:@"%@,%@", [[task currentRequest].URL relativeString], @"业务成功回调Block不能为nil！"]));
        bizSuccessBlock(response);
    }
    else
    {
        // 业务失败了，先看看是不是特殊的业务失败比如Token失效之类的;
        if ([response shouldHandleBusinessFailure])
        {
            if (bizFailureBlock)
            {
                bizFailureBlock(response);
            }
            else
            {
                //通用业务失败处理
                [[NSNotificationCenter defaultCenter] postNotificationName:HTWebServiceNeedShowTipsNofitification object:[response messageWhenBusinessFailure]];
            }
        }
    }
    
    if (alwaysExecuteBlock)
    {
        alwaysExecuteBlock();
    }
}

- (void)handleFailureWithOperation:(NSURLSessionDataTask *)task
                             error:(NSError *)error
                    requestFailure:(HTRequestFailureBlock)reqFailureBlock
                           finally:(HTAlwaysExecuteBlock)alwaysExecuteBlock
{
    if (reqFailureBlock)
    {
        HTWSFailureEntity *entity = [[HTWSFailureEntity alloc] init];
        entity.error = error;
        entity.task = task;
        reqFailureBlock(entity);
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HTWebServiceNeedShowTipsNofitification object:nil];
    }
    
    if (alwaysExecuteBlock)
    {
        alwaysExecuteBlock();
    }
}

- (void)logRequestWithHTTPMethod:(HTHTTPMethod)method
                       parameter:(id)parameters
                            path:(NSString *)subPath
{
    NSString *loggedMethod;
    switch (method) {
        case HTHTTPMethodGET: {
            loggedMethod = @"GET";
            break;
        }
        case HTHTTPMethodPOST: {
            loggedMethod = @"POST";
            break;
        }
        case HTHTTPMethodPUT: {
            loggedMethod = @"PUT";
            break;
        }
        case HTHTTPMethodPATCH: {
            loggedMethod = @"PATCH";
            break;
        }
        case HTHTTPMethodDELETE: {
            loggedMethod = @"DELETE";
            break;
        }
        case HTHTTPMethodHEAD: {
            loggedMethod = @"HEAD";
            break;
        }
    }

    HTLog(@"%@ DATA: %@ \n To Path: %@ \n", loggedMethod, [HTWebService replaceUnicode:[parameters description]], [[NSURL URLWithString:subPath relativeToURL:self.baseURL] absoluteString]);
}


- (void)logResponse:(id)receive
               path:(NSString *)subPath
{
    HTLog(@"Received: %@ \n From Path %@", [HTWebService replaceUnicode:[receive description]], [[NSURL URLWithString:subPath relativeToURL:self.baseURL] absoluteString]);
}

- (void)logError:(NSError *)error
            path:(NSString *)subPath
{
    HTLog(@"WebService Error: %@ With Path %@", error.localizedDescription, [[NSURL URLWithString:subPath relativeToURL:self.baseURL] absoluteString]);
}

- (BOOL)isReachable
{
    BOOL isReachable = self.reachabilityManager.reachable;
    if (!isReachable)
    {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        if (networkStatus != NotReachable)
        {
            isReachable = YES;
        }
        else
        {
            isReachable = NO;
        }
    }
    return isReachable;
}


+ (NSURL *)baseURLFromConfig:(id<HTWSConfig>)config
{
#if DEBUG
    HTWSEnvironment type = HTWSEnvironmentDEV;
#else
    HTWSEnvironment type = HTWSEnvironmentDIS;
#endif
    NSString *baseUrlString = [NSString stringWithFormat:@"%@%@",
                               [config baseServerSchema],
                               [config baseServerAddressForEnvironment:type]];
    return [NSURL URLWithString:baseUrlString];
}

/**
 *  NSString值为Unicode格式的字符串编码(如\\u7E8C)转换成中文
 *
 *  @param unicodeStr unicode字符串
 *
 *  @return
 */
+ (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    if (!HT_IS_NULL(unicodeStr))
    {
        NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
        NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
        NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
        NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
        return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
    }
    else
    {
        return nil;
    }
}

+ (void)checkConfig:(id<HTWSConfig>)config
{
    NSAssert([config respondsToSelector:@selector(baseServerSchema)], @"注册的 config 尚未实现 baseServerSchema 方法！");
    NSAssert([config respondsToSelector:@selector(baseServerAddressForEnvironment:)], @"注册的 config 尚未实现 -baseServerAddressForEnvironment: 方法！");
}

+ (void)checkResponseExample:(id<HTWSResponse>)example
{
    NSAssert([example respondsToSelector:@selector(initWithJSON:)], @"注册的 example 尚未实现 -initWithJSON: 方法！");
    NSAssert([example respondsToSelector:@selector(isBusinessSuccess)], @"注册的 example 尚未实现 -isBusinessSuccess: 方法！");
    NSAssert([example respondsToSelector:@selector(shouldHandleBusinessFailure)], @"注册的 example 尚未实现 -shouldHandleBusinessFailure: 方法！");
    NSAssert([example respondsToSelector:@selector(messageWhenBusinessFailure)], @"注册的 example 尚未实现 -messageWhenBusinessFailure: 方法！");
}

@end

@implementation HTWebService (Convience)

- (void)getEasilyWithPath:(NSString *)subPath
               parameters:(id)parameters
          businessSuccess:(HTBusinessSuccessBlock)bizSuccessBlock
                  finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock
{
    [self requestEasilyWithMethod:HTHTTPMethodGET
                             path:subPath
                       parameters:parameters
                  businessSuccess:bizSuccessBlock
                          finally:alwaysExecuteBlock];
}

- (void)postEasilyWithPath:(NSString *)subPath
                parameters:(id)parameters
           businessSuccess:(HTBusinessSuccessBlock)bizSuccessBlock
                   finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock
{
    [self requestEasilyWithMethod:HTHTTPMethodPOST
                             path:subPath
                       parameters:parameters
                  businessSuccess:bizSuccessBlock
                          finally:alwaysExecuteBlock];
}

- (void)getSilentlyWithPath:(NSString *)subPath
                 parameters:(id)parameters
            businessSuccess:(HTBusinessSuccessBlock)bizSuccessBlock
                    finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock
{
    [self requestSilentlyWithMethod:HTHTTPMethodGET
                               path:subPath
                         parameters:parameters
                    businessSuccess:bizSuccessBlock
                            finally:alwaysExecuteBlock];
}

- (void)postSilentlyWithPath:(NSString *)subPath
                  parameters:(id)parameters
             businessSuccess:(HTBusinessSuccessBlock)bizSuccessBlock
                     finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock
{
    [self requestSilentlyWithMethod:HTHTTPMethodPOST
                               path:subPath
                         parameters:parameters
                    businessSuccess:bizSuccessBlock
                            finally:alwaysExecuteBlock];
}

- (void)postWithPath:(NSString *)subPath
          parameters:(id)parameters
     businessSuccess:(HTBusinessSuccessBlock)bizSuccessBlock
     businessFailure:(HTBusinessFailureBlock)bizFailureBlock
      requestFailure:(HTRequestFailureBlock)reqFailureBlock
             finally:(HTAlwaysExecuteBlock)alwaysExecuteBlock;
{
    [self requestWithHTTPMethod:HTHTTPMethodPOST
                           path:subPath
                     parameters:parameters
                businessSuccess:bizSuccessBlock
                businessFailure:bizFailureBlock
                 requestFailure:reqFailureBlock
                        finally:alwaysExecuteBlock];
}

- (void)getWithPath:(NSString *)subPath
         parameters:(id)parameters
    businessSuccess:(HTBusinessSuccessBlock)bizSuccessBlock
    businessFailure:(HTBusinessFailureBlock)bizFailureBlock
     requestFailure:(HTRequestFailureBlock)reqFailureBlock
            finally:(HTAlwaysExecuteBlock)alwaysExecuteBlock
{
    [self requestWithHTTPMethod:HTHTTPMethodGET
                           path:subPath
                     parameters:parameters
                businessSuccess:bizSuccessBlock
                businessFailure:bizFailureBlock
                 requestFailure:reqFailureBlock
                        finally:alwaysExecuteBlock];
    
}

@end

