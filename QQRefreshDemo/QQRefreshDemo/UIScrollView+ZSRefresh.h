//
//  UIScrollView+ZSRefresh.h
//  QQRefreshDemo
//
//  Created by 周松 on 16/12/13.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (ZSRefresh)

///添加刷新组件,block为刷新执行
- (void)addRefreshWithblock:(void(^)())block;

///刷新成功
- (void)refreshSuccess;
///刷新失败
- (void)refreshFail;

@end
