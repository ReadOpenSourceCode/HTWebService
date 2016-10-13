//
//  PSBaseModel.m
//  Demo
//
//  Created by Pan on 2016/10/13.
//  Copyright © 2016年 shengpan. All rights reserved.
//

#import "PSBaseModel.h"
@implementation PSBaseModel


- (HTWebService<PSResponse *> *)webService
{
    if (!_webService)
    {
        _webService = [[HTWebService alloc] initWithConfig:[PSWSConfig new]
                                         responseStructure:[PSResponse new]];
        // 如果有需要，还可以在这里配置点请求头之类的。
        // [_webService setValue:@"11" forHTTPHeaderField:@"X-Request-Limit"];
    }
    return _webService;
}

@end
