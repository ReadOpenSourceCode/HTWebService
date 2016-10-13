//
//  PSJokeListModel.m
//  Demo
//
//  Created by Pan on 2016/10/13.
//  Copyright © 2016年 shengpan. All rights reserved.
//

#import "PSJokeListModel.h"

@implementation PSJokeListModel

- (void)fetchJokeList
{
    [self.webService getEasilyWithPath:@"api/4/section/2"
                            parameters:nil
                       businessSuccess:^(PSResponse * _Nonnull response) {
                           // 做业务成功之后想做的事情
                       } finally:^{
                           // 做网络请求结束之后想做的事情
                       }];
}

@end
