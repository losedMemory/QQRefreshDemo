//
//  UIScrollView+ZSRefresh.m
//  QQRefreshDemo
//
//  Created by 周松 on 16/12/13.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "UIScrollView+ZSRefresh.h"
#import <objc/runtime.h>
#import "ZSRefreshIndicator.h"

@implementation UIScrollView (ZSRefresh)
static char ZSRefreshIndicatorKey;
- (void)setIndicator:(ZSRefreshIndicator *)indicator{
    if (indicator != self.indicator) {
        [self.indicator removeFromSuperview];
        [self willChangeValueForKey:@"indicator"];
        objc_setAssociatedObject(self, &ZSRefreshIndicatorKey, indicator, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"indicator"];
        [self addSubview:indicator];
     }
}

- (ZSRefreshIndicator *)indicator{
    return objc_getAssociatedObject(self, &ZSRefreshIndicatorKey);
}

#pragma mark --重写
- (void)setFrame:(CGRect)frame{
    if (self.frame.size.width != frame.size.width) {
        [self centerSub:frame.size.width];
    }
    [super setFrame:frame];

}

- (void)setBounds:(CGRect)bounds{
    if (self.bounds.size.width != bounds.size.width) {
        [self centerSub:bounds.size.width];
    }
    [super setBounds:bounds];

}

- (void)centerSub:(CGFloat)width{
    CGRect frame = self.indicator.frame;
    frame.size.width = width;
    frame.origin.x = (width - frame.size.width) / 2.1;
    self.indicator.frame = frame;
}

#pragma mark --添加刷新事件
- (void)addRefreshWithblock:(void (^)())block{
    self.delaysContentTouches = NO;
    //刷新控件
    self.indicator = [[ZSRefreshIndicator alloc]init];
    CGRect frame = self.indicator.frame;
    frame.origin.y = -frame.size.height;
    frame.size.width = self.bounds.size.width;
    self.indicator.frame = frame;
    self.indicator.refreshBlock = block;
    //添加观察者
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)didChangeValueForKey:(NSString *)key{
    if ([key isEqualToString:@"contentOffset"] && self.contentOffset.y <= 0) {
        self.indicator.pullProgress = -self.contentOffset.y;

    }
}
- (void)dealloc{
//    [self removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark --结束刷新
- (void)refreshSuccess{
    [self.indicator refreshSuccess:YES];
}
- (void)refreshFail{
    [self.indicator refreshSuccess:NO];
}

@end














