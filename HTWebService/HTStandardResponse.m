//
//  HTStandardResponse.m
//  HTStandard
//
//  Created by Pan on 15/9/22.
//  Copyright (c) 2015年 Insigma Hengtian Software Co.,Ltd  All rights reserved.
//

#import "HTStandardResponse.h"

NSNotificationName const HTStandardResponseTokenOverdueNofitification = @"HTStandardResponseTokenOverdueNofitification";


@implementation HTStandardResponse

- (instancetype)initWithJSON:(NSDictionary *)JSON
{
    self = [super init];
    if (self)
    {
        _code = [[JSON objectForKey:@"code"] integerValue];
        _message = [JSON objectForKey:@"message"];
        _data = [JSON objectForKey:@"data"];
    }
    return self;
}

- (BOOL)isBusinessSuccess;
{
    return self.code == HTResponseCodeSuccess;
}

- (BOOL)shouldHandleBusinessFailure
{
    if (self.code == HTResponseCodeTokenOverdue)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HTStandardResponseTokenOverdueNofitification object:self.message];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSString *)messageWhenBusinessFailure;
{
    return self.message;
}

@end
