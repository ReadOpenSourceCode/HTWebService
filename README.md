# HTWebService
An network layer framework help you handle JSON to Object mapping, business status judgement etc.

# 由来

当我作为实习生刚进入公司的时候，所见到网络层的代码是这样的:

```objc
// 项目 A 中的网络层封装
@interface WebService : AFHTTPSessionManager

- (void)postRequest:(NSString *)path
         parameters:(NSDictionary *)parameters
              token:(NSString *)token
            isLogin:(BOOL)isLogin
            success:(void (^)(id JSON))success
            failure:(void (^)(NSError *error, id JSON))failure;
```

还有这样的:

```objc
// 项目 B 中的网络层封装
- (void)getWithPath:(NSString *)path
         parameters:(id)parameters
    isShowIndicator:(BOOL) isShowIndicator
             parent:(UIView *) parentView
          labelText:(NSString *)labelText
            success:(void (^)(ZDResponseEntity *))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
```

当时乍看之下没有什么不妥（毕竟实习生），但当上手用上这些 API 时，第一感觉是感觉效率非常地低下。因为每发起一个网络请求，就要做这些事情：

1. 判断网络可达性并决定是否要提示用户
2. JSON 转 Model （手动）
* 根据 Response 来判断业务状态（成功，失败等）
* 做成功状态下所需要做的事
* 做失败状态下所需要做的事（通常只需要提示一下用户服务器返回的错误信息)
* 处理请求失败状态下所需要做的事。

每一个接口都需要写这一大坨，浪费了多少时间和精力在重复代码上！

于是开始思考如何才能让写网络层代码不那么痛苦。先是把一些显而易见的重复工作（例如 `1`）放到了网络层里面，然后发现了 MJExtension、Mantle 等工具又简化了 `2`。接下来就卡在如何将判断业务状态这块重复工作给做了。

判断业务状态这块工作，有相同的地方，也有不同的地方。相同在每个请求都逃避不了类似下面的判断语句

```objc
if ([JSON isKindOfClass:[NSDictionary class]]) {
    int status = [[JSON objectForKey:WS_STATUS] intValue];
    if (status == ResponseStatusSuccess) {
        // 做业务成功状态下的事情
    } else if (status == ResponseStatusFailed) {
        // 做业务失败状态下的事情
    }
```

但在每个请求业务成功状态下所要做的事情却完全不同，而业务失败状态下需要做的事情大致相同 -- 大多数需要将后台返回的错误信息提示给用户，少部分需要做一些业务逻辑操作。

由于当时经验尚浅，对此束手无策。后经我的 Mentor [@Leon](https://github.com/leonhoo) 点拨才顿悟。他说:

> 把判断的事情放到网络层里面去做，把判断之后要做的事情开出口子来给外面做。

于是就有了 HTWebService 接口的雏形。

```
- (void)getWithPath:(nonnull NSString *)subPath
         parameters:(nullable id)parameters
    businessSuccess:(nonnull HTBusinessSuccessBlock)bizSuccessBlock
    businessFailure:(nullable HTBusinessFailureBlock)bizFailureBlock
     requestFailure:(nullable HTRequestFailureBlock)reqFailureBlock
            finally:(nullable HTAlwaysExecuteBlock)alwaysExecuteBlock;
```

### 演进

有了雏形之后，就开始了演进。首先是为了方便项目之间的复用，把 BaseURL 给抽到了 Plist 文件中，让 WebService 初始化的时候去文件中读取。这样当新的项目需要 copy 这份代码（嗯，当时还不能称为框架，因为耦合性还很严重，严重依赖接口返回的数据格式。）到其他项目中时，只需要修改plist 文件中的 `BaseURL` 就好用了。为了更加方便，后来还在公司内部搭建了私有的 CocoaPods ，这样 WebService 就可以更舒服地导入了。

就这样，这套框架 1.0 版本的理念 -- Drop-in 已经慢慢有雏形了。当时的目标是，希望除了 plist 以外不需要做任何修改，扔进项目就能用。然而却没有想到一些高耦合的东西已经暗藏其中了-- 这也是导致后来 2.0 版本 Break Change 和 3.0 版本 理念从 Drop-in 转变到灵活可配置的主要原因。

> 要灵活，还是要无学习成本，这，是一个问题。

后来趁着技术分享会的机会，和公司内的 iOS 开发们分享了这份框架，反响很好。恰逢此时我接手标准化工作，标准化框架尚未开始构建，便决心将 WebService 打造为标准化框架中的网络层。于是 WebService 从此开始 HT 打头。

至于后来 Review 到其他项目组的代码，发现 5 个新起的项目全用了这套框架，还有被改写成 Swift 版本等，都是后话了。

### 不停地修正与理念变更

如我所说，最初是希望 `HTWebservice` 变成使用者可以只修改一个指向服务器的 URL , 就可以使用的 drop-in 型框架。框架所依赖的接口返回格式是这样的

```json
{
    "code": ##, // 0 = 业务成功， 1 = 业务失败
    "message": "",
    "data": "",
}
```

这里有两个问题

* 框架强依赖于返回的接口格式和字段名
* 框架对业务成功与否的判断强依赖于 code 的定义。

而这些都是需要和后台开发人员人为约定的。因此也是不可靠的。

于是首先将 `code`,`data`,`message` 三个 Key 定义在了 Plist 中，让使用者可以根据自己约定的情况进行修改。后又把 `code` 对应的 Enum 开放到头文件中供使用者修改（这里同样造成了 Pod 一更新，就会导致使用者的修改失效的问题）。然而这些都是治标不治本的，直到遇到了下面的问题： 

在实践的过程中，发现公司的接口并没有统一的标准！！ **每个项目组都有各自的 JSON Wrapper** 。

比如这样的 Wrapper ,再怎么修改 plist 也无济于事了。

```json
{
    "errors": [], // 如果 errors 为空数组则代表业务成功
    "data": [], // 如果业务成功则有数据，统一抽象为数组
    "meta": {}, // 统一抽象为分页
    "extraData": "", // 供某些特殊情况下携带额外数据
}
```

为了适应各种不同的接口格式，只能把接口格式定义、判断业务成功失败等都交给框架使用者去判断了。这样大大地增加了学习成本。

为了让框架更普适，权衡后还是选择了牺牲学习成本来提高框架的灵活性。于是就有了现在大家看到的这两个属性。

```
/**
 *  该类的配置对象
 */
@property (nonatomic, strong, readonly, nonnull) id<HTWSConfig> config;

/**
 *  该类的返回数据数据结构对象
 */
@property (nonatomic, strong, readonly, nonnull) T responseStructure;
```

至此，基本上 `HTWebService` 的骨架就出来了。之后就是不断完善类似于**添加 Nullability 来兼容 Swift** ，**使用轻量泛型使返回值不需要每次都强转** 等小细节，然后才有了现在大家所见到的样子。

### 小插曲

在 HTWebService 被整合进标准化框架，框架演进至 1.3.1 版本时，被同事**修改了文件名并将全套框架[开源](https://github.com/mushank/ZKStandard)**。可以看到 Plist 文件还存在，因此用 Pod 导入更新版本时会导致 plist 被修改的问题还没有解决。也是让人哭笑不得的😂。

### 致谢

[@Leon](https://github.com/leonhoo)是我实习期间的 Mentor , 是一位十多年工作经验的**真全栈**。他在我实习成长过程中给了许多帮助。在平时的交流中，他也时常令我有醍醐灌顶之感，是一位难得的良师益友。


