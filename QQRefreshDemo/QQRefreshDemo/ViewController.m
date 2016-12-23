//
//  ViewController.m
//  QQRefreshDemo
//
//  Created by 周松 on 16/12/13.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+ZSRefresh.h"
#define SCREENW [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@property (nonatomic,strong) UIScrollView *scrollView;

//刷新成功
@property (nonatomic,strong) UIButton *successRefreshButton;

//刷新失败
@property (nonatomic,strong) UIButton *failedRefreshButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];

    [self.view addSubview:self.scrollView];
//    让导航栏不透明
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"橡皮筋刷新";
    
    self.successRefreshButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW / 2 - 40, 200, 90, 30)];
    [self.successRefreshButton setTitle:@"刷新成功" forState:UIControlStateNormal];
    [self.view addSubview:self.successRefreshButton];
    self.successRefreshButton.backgroundColor = [UIColor orangeColor];
    [self.successRefreshButton addTarget:self action:@selector(successRefreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.failedRefreshButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREENW / 2 - 40, 300, 90, 30)];
    [self.failedRefreshButton setTitle:@"刷新失败" forState:UIControlStateNormal];
    [self.view addSubview:self.failedRefreshButton];
    self.failedRefreshButton.backgroundColor = [UIColor orangeColor];
    [self.failedRefreshButton addTarget:self action:@selector(failedRefreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewDidAppear:(BOOL)animated{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1);
    //添加刷新控件
    [self.scrollView addRefreshWithblock:^{
        
    }];
   
}
///刷新成功的点击事件
- (void)successRefreshButtonClick{
    [self.scrollView refreshSuccess];
}

///刷新失败的点击事件
- (void)failedRefreshButtonClick{
    [self.scrollView refreshFail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
