//
//  JokeListViewController.m
//  Demo
//
//  Created by Pan on 2016/10/13.
//  Copyright © 2016年 shengpan. All rights reserved.
//

#import "JokeListViewController.h"
#import "PSJokeListModel.h"

@interface JokeListViewController ()

@property (nonatomic, strong) PSJokeListModel *model;


@end

@implementation JokeListViewController

#pragma mark - Public

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.model fetchJokeList];
}

#pragma mark - IBAction


#pragma mark - Navigation


#pragma mark - Delegate


#pragma mark - Private Method


#pragma mark - Getter and Setter

- (PSJokeListModel *)model
{
    if (!_model)
    {
        _model = [[PSJokeListModel alloc] init];
    }
    return _model;
}

@end
