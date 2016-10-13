# HTWebService

[![Build Status][status]][travis]
[![docs][docs]][CocoaPods]
[![Pod Version][version]][CocoaPods]
[![License][license]][CocoaPods]
[![Platform][platform]][CocoaPods]
![SwiftCompatible][SwiftCompatible]

An network layer framework help you handle JSON to Object mapping, business status judgement etc.

--- 

## 简介
 
HTWebService 是一套基于 AFNetworking 3.x 的网络层封装，通过分离业务状态和请求状态并提供错误的默认处理，令使用者不需要关注错误情况而集中精力在业务开发上。意在简化网络请求相关的重复工作。

## 目标

- [x] RESTful 方法全支持
- [x] 分离业务状态和请求状态
- [x] 运用轻量级泛型提供返回对象的类型检查
- [x] Request & Response JSON 日志
- [ ] Response 内层数据 JSON 转 Model

## 通过 CocoaPods 安装

在你的 `podfile` 中加入:

```ruby
pod 'HTWebService'
```

然后命令行输入命令:

```bash
$ pod install
```

## 开始使用

#### 一、初始化配置

首先需要告诉框架服务器的地址和接口返回数据的格式。

创建两个类，分别实现 `HTWSProtocol` 中的 `HTWSConfig` 协议 和 `HTWSResponse` 协议。这两个协议分别用于配置框架以及描述接口返回数据格式。详细配置见 Demo 中的 `PSWSConfig` 和 `PSResponse` 实现。

#### 二、使用

调用👇的初始化方法初始化获取一个 webservice 实例。 如果你的 App 需要向不同服务器请求，你可以生成多个配置，初始化多个 webservice 实例。

```
/**
 *  创建并返回一个 `HTWebService` 对象
 *  @param configuration 必传参数，实现了 HTWSConfig 的配置对象。
 *  @param response      可选参数，实现了 HTWSResponse 的返回 JSON 结构表示对象。如果传nil，则会采用HTStandardResponse
 *  @return HTWebService
 */
- (nonnull instancetype)initWithConfig:(nonnull id<HTWSConfig>)configuration
                     responseStructure:(nullable T)response NS_DESIGNATED_INITIALIZER;
```

简单地填入 url, 请求方式和请求参数，框架便会自动帮你处理好一切。

```
    [self.webService requestEasilyWithMethod:HTHTTPMethodGET
                                        path:@"api/4/section/2"
                                  parameters:nil
                             businessSuccess:^(PSResponse * _Nonnull response) {
                                 // 做业务成功之后想做的事情
                             } finally:^{
                                 // 做网络请求结束之后想做的事情
                             }];

```


## 最后

这是一个 HT 打头的组件，它出生的时候是这个名字。出于纪念意义，就保留这个名字吧。有兴趣的看官可以看看这个组件的[由来](https://github.com/DeveloperPans/HTWebService/blob/master/Insprition.md)。


[CocoaPods]: http://cocoapods.org/pods/HTWebService

[travis]: (https://travis-ci.org/DeveloperPans/HTWebService)

[docs]: https://img.shields.io/cocoapods/metrics/doc-percent/HTWebService.svg

[version]: https://img.shields.io/cocoapods/v/HTWebService.svg?style=flat

[status]: https://travis-ci.org/DeveloperPans/HTWebService.svg?branch=master

[license]: https://img.shields.io/cocoapods/l/HTWebService.svg?style=flat

[platform]: https://img.shields.io/cocoapods/p/HTWebService.svg?style=flat

[SwiftCompatible]: https://img.shields.io/badge/Swift-compatible-orange.svg

[logo]: https://raw.githubusercontent.com/DeveloperPans/HTWebService/master/logo.png

[blog]: http://shengpan.net

