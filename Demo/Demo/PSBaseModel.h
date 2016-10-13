//
//  PSBaseModel.h
//  Demo
//
//  Created by Pan on 2016/10/13.
//  Copyright © 2016年 shengpan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HTWebService/HTWebService.h>
#import "PSResponse.h"
#import "PSWSConfig.h"

@interface PSBaseModel : NSObject

@property (nonatomic, strong) HTWebService<PSResponse *> *webService;

@end
