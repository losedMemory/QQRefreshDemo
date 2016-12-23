//
//  ZSRefreshIndicator.h
//  QQRefreshDemo
//
//  Created by 周松 on 16/12/13.
//  Copyright © 2016年 周松. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSRefreshIndicator : UIView

///下拉进度
@property (assign, nonatomic) CGFloat pullProgress;

///刷新执行
@property (strong, nonatomic) void (^refreshBlock)();

///刷新结果
- (void)refreshSuccess:(BOOL)isSuccess;

@end
