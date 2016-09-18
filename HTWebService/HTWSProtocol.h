//
//  HTWSProtocol.h
//  Pods
//
//  Created by Pan on 16/6/23.
//
//

#import <Foundation/Foundation.h>
#import "HTWSEnum.h"

/**
 *  网络配置协议，包含了和服务器对接相关的配置信息。
 *  使用 HTWebService 前，应当先遵循并实现这个协议，然后对 HTWebService 进行注册。
 */
@protocol HTWSConfig <NSObject>

@required
/**
 *  服务器的 Schema。 一般为 `http://` 或 `https://`
 *  @return 服务器的 Schema
 */
- (nonnull NSString *)baseServerSchema;

/**
 *  各个环境下对应的服务器地址, 例如：172.17.17.11
 *  @param environment 服务器环境，目前有 DEV , QA， DIS 三个环境。
 *  @return 各个环境下对应的服务器地址
 *  @see HTWSEnvironment
 */
- (nonnull NSString *)baseServerAddressForEnvironment:(HTWSEnvironment)environment;

@optional
/**
 *  请求超时时间
 *  @return 请求超时时间
 */
- (double)timeoutInterval;
@end

/**
 *  服务器返回的 JSON 格式映射对象。 一般来说，服务器会按照某种格式返回 JSON 数据。
 *
 *  在标准的数据格式下，不需要配置这个类， HTWebService 会 自动采用 HTStandardResponse 来解析返回的数据，并处理相对应的业务失败的情况。
 *
 *  当服务器返回的 JSON 格式无法采用标准格式时，让一个对象遵循并实现此协议，然后在 HTWebService 中注册。
 *
 *  你最好为遵循该协议的对象设计一个数据结构以存储返回的 JSON ，并在 -initWithJSON 中存储它。
 *
 *  @see HTStandardResponse
 */
@protocol HTWSResponse <NSObject>

/**
 *  创建并返回一个 实现了 HTWSResponse 协议的对象
 *  @param JSON 服务端返回的完整 JSON 信息。
 *  @return 一个实现了 HTWSResponse 协议的对象
 */
- (nonnull instancetype)initWithJSON:(nonnull NSDictionary *)JSON;

/**
 *  通过服务器返回的数据判断业务是否成功。
 *  @return 业务成功则返回 YES ,否则返回 NO.
 */
- (BOOL)isBusinessSuccess;

/**
 @abstract 框架是否应该自动处理某种非业务成功的情况。
 @discussion HTWebService 会首先调用 -isBusinessSuccess 询问业务是否成功。如果成功，则不会触发此函数。
            
 如果业务失败，则会触发此函数，询问是否需要由 HTWebService 进行处理。某些情况下需要由实现此协议的对象来处理的，则返回 NO ，来接管处理权。

 例如，Token 失效，是需要重新获取Token 的，则在此函数中返回 NO, 并进行相对于的处理。
 @return 如果由 HTWebService 进行默认处理则返回 YES。 否则返回 NO。
 @see HTStandardResponse
 */
- (BOOL)shouldHandleBusinessFailure;

/**
 *  业务失败时返回的信息。HTWebService 的默认业务失败处理会进行HDU提示，需要显示相关信息。例如 “登录失败”。
 *
 *  @return 返回 nil 则界面上不会显示 HDU 气泡。
 */
- (nullable NSString *)messageWhenBusinessFailure;

@end
