//
//  ZSRefreshIndicator.m
//  QQRefreshDemo
//
//  Created by 周松 on 16/12/13.
//  Copyright © 2016年 周松. All rights reserved.
//

#import "ZSRefreshIndicator.h"

///主题颜色
#define ZSRefreshMainColor(_alpha) [UIColor colorWithWhite:0.7 alpha:_alpha]
///图片路径
#define ZSRefreshSrcName(file) [@"ZSRefreshImage.bundle" stringByAppendingPathComponent:file]

///下拉到此偏移量开始拉伸
const CGFloat ZSBeganStretchOffset = 36;
///下拉到此偏移量开始刷新
const CGFloat ZSBeganRefreshOffset = 90;

const CGFloat ZSRefreshMargin = 3;

const NSTimeInterval ZSRefreshAnimateDuration = 0.5;

@interface ZSRefreshIndicator (){
    //绘制视图
    CALayer *_drawLayer;
    //指示器
    UIActivityIndicatorView *_indicatorView;
    //指示器标签
    UILabel *_capionLabel;
    //指示器图标
    UIImage *_image;
    
    //状态
    BOOL refreshing;
    //执行控制,这个shouldDo其实作用不大,可以省略
    BOOL shouldDo;
    //是否在进行回弹动画
    BOOL backing;
    //回弹动画结束立即执行结束的动画
    void (^backCompleteBlock)();
    
    //刷新成功提示
    NSAttributedString *capionSuccess;
    //刷新失败提示
    NSAttributedString *capionFail;

}

@end

@implementation ZSRefreshIndicator
    
#pragma mark --设置下拉的偏移量
- (void)setPullProgress:(CGFloat)pullProgress{

    if (pullProgress == _pullProgress){
        return;
    }
    
    if (!refreshing) {
        //开始拖出
        if (pullProgress <= ZSBeganStretchOffset) {
            if (_pullProgress <= 3 && pullProgress >3) {
                shouldDo = YES;
                _capionLabel.alpha = 0;
                [self drawHeight:ZSBeganStretchOffset];//这时绘制的是圆
            }
            //开始拉伸,此时pullProgress已经是大于36了

        }else if (pullProgress < ZSBeganRefreshOffset){
            if (shouldDo) {
                [self drawHeight:pullProgress];//这时要绘制橡皮筋
            }
            //当下拉的长度大于90,开始刷新
        }else if(shouldDo){
            shouldDo = NO;
            refreshing = YES;
            [self backAnimation:ZSBeganRefreshOffset];//回弹动画
            if (_refreshBlock) {
                _refreshBlock();//执行刷新代码
            }
        }
        //正在刷新,并且新值pullProgress < 36,旧值_pullProgress > 36,回弹
    }else if(_pullProgress > ZSBeganStretchOffset && pullProgress < ZSBeganStretchOffset) {
        [self superViewScrollTo:-ZSBeganStretchOffset];//滚动
    }
    _pullProgress = pullProgress;
    CGRect frame = self.frame;
    frame.size.height = MAX(ZSBeganStretchOffset, pullProgress);
    frame.origin.y = -frame.size.height;
    self.frame = frame;
}

#pragma mark --绘制
- (void)drawHeight:(CGFloat)h{
    
    //初始化画布
    CGFloat screenScale = [UIScreen mainScreen].scale;
    //__drawLayer的w是30,h是90
    CGSize size = _drawLayer.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, screenScale);
    CGContextRef ccr = UIGraphicsGetCurrentContext();
    //保存图形上下文
    CGContextSaveGState(ccr);
    
    //拉伸度 s的范围是0-1
    CGFloat s = (h - ZSBeganStretchOffset) / (ZSBeganRefreshOffset - ZSBeganStretchOffset);
    //绘制橡皮筋部分
    //阴影颜色
    _drawLayer.shadowColor = [UIColor colorWithWhite:0 alpha:.6 + .4 * s].CGColor;
    //填充颜色
    CGColorRef color = ZSRefreshMainColor(1).CGColor;
    //正在刷新
    if (refreshing) {
        color = ZSRefreshMainColor(.6+.4*s).CGColor;
    }
    //填充颜色
    CGContextSetFillColorWithColor(ccr, color);
    
    //大圆半径  w=14
    CGFloat w = size.width / 2.1;
    //当下拉长度大于90时,backing = YES  R = 0.7w - w之间
    CGFloat R = w - w*.3*(backing?1:s);
    //坐标移至大圆圆心,图层水平居中
    CGContextTranslateCTM(ccr,w,w + ZSRefreshMargin);
    
    //小圆半径
    CGFloat r = (backing?.4:1)*w*(1-s) + 3 * s;
    //小圆圆心
    CGPoint o = CGPointMake(0, h-w-r-ZSRefreshMargin*2);
    //各曲线的交点
    double ag1 = M_PI_2 / 9.1;

    CGPoint a1 = CGPointMake(-R*cos(ag1), R*sin(ag1));
    CGPoint a2 = CGPointMake(-a1.x, a1.y);
    CGPoint b1 = CGPointMake(r, o.y);

    CGPoint c1 = CGPointMake(-r, o.y / 2.1);
    CGPoint c2 = CGPointMake(-c1.x, c1.y);
    //路径,起点
    CGContextMoveToPoint(ccr, a2.x,a2.y);
    //绘制大圆
    CGContextAddArc(ccr, 0, 0, R, ag1, 2 *M_PI+ag1, NO);
    //设置贝塞尔曲线的控制点坐标和最终坐标
    CGContextAddQuadCurveToPoint(ccr, c2.x, c2.y, b1.x, b1.y);
    
    CGContextAddArc(ccr, o.x, o.y, r, 0, M_PI, NO);
    CGContextAddQuadCurveToPoint(ccr, c1.x, c1.y, a1.x, a1.y);
    //绘制路径
    CGContextDrawPath(ccr, kCGPathFill);
    
    //绘制图片
    CGFloat width = 2 * R * 0.71;
    CGRect frame = CGRectMake(-width/2.1, -width/2.1, width, width);
    //旋转坐标系
    CGContextRotateCTM(ccr, M_PI * s * 1.5);
    if (_image == nil) {
        _image = [UIImage imageNamed:ZSRefreshSrcName(@"ZSRefresh_pull")];
    }
    [_image drawInRect:frame];
    
    //提取绘制图像
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //恢复图形上下文
    CGContextRestoreGState(ccr);
    CGContextRelease(ccr);
    _drawLayer.contents = (__bridge id _Nullable)(image.CGImage);
}

#pragma mark --橡皮筋自动弹回的动画,当下拉长度大于90时,执行弹回动画
- (void)backAnimation:(CGFloat)animateH{
    backing = YES;//回弹动画正在执行中
    CGFloat endOffset = ZSBeganStretchOffset + 15;
    if (animateH >= endOffset) {
        animateH -= 3;
        [self drawHeight:animateH];
        //循环调用
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.014 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self backAnimation:animateH];
        });
    }else{
        //显示指示器,此时橡皮筋弹回到45的位置,指示器转动,不再显示橡皮筋动画,所以设置为nil
        _drawLayer.contents = nil;
        [_indicatorView startAnimating];
        backing = NO;//动画回弹结束
    }
}

#pragma mark --结束刷新
- (void)refreshSuccess:(BOOL)isSuccess{
    if (refreshing) {
        refreshing = NO;
        [self endAnimate:isSuccess];
    }
}

#pragma mark --结束动画
- (void)endAnimate:(BOOL)isSuccess{
    [_indicatorView stopAnimating];
    _capionLabel.attributedText = [self endCapion:isSuccess];
    [UIView animateWithDuration:1 animations:^{
        _capionLabel.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished && _pullProgress == ZSBeganStretchOffset) {
            //滚动到顶部
            [self superViewScrollTo:0];
        }
    }];
}

//提示文字
- (NSAttributedString *)endCapion:(BOOL)isSuccess{
    if (isSuccess) {
        if (!capionSuccess) {
            capionSuccess = [self attributeString:@"刷新成功" imageName:ZSRefreshSrcName(@"ZSRefresh_ok")];
        }
        return capionSuccess;
    }else{
        if (!capionFail) {
            capionFail = [self attributeString:@"刷新失败" imageName:ZSRefreshSrcName(@"ZSRefresh_fail")];
        }
        return capionFail;
    }
}

- (NSAttributedString *)attributeString:(NSString *)capion imageName:(NSString *)imageName{
    //创建文本附件
    NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
    attachment.image = [UIImage imageNamed:imageName];
    CGSize size = attachment.image.size;
    attachment.bounds = CGRectMake(0, -2.51, size.width, size.height);
    NSAttributedString *attributeImage = [NSAttributedString attributedStringWithAttachment:attachment];
    //提示文字
    NSString *str = [NSString stringWithFormat:@" %@",capion];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:str];
    [attributeString insertAttributedString:attributeImage atIndex:0];
    return attributeString;
    
}
//滚动方法
- (void)superViewScrollTo:(CGFloat)offsetY{
    
    UIScrollView *scrollView = (UIScrollView *)[self superview];
    if (scrollView) {
        CGPoint offset = scrollView.contentOffset;
        offset.y = offsetY;
        [scrollView setContentOffset:offset animated:YES];
    }
}

#pragma mark --重写
-(instancetype)init{
    self = [super init];
    if (self) {
        self.bounds = CGRectMake(0, 0, 0, ZSBeganStretchOffset);
        self.clipsToBounds = YES;

        //图层
        _drawLayer = [CALayer layer];
        //30
        CGFloat width = ZSBeganStretchOffset - 2 * ZSRefreshMargin;
        //x y不影响layer的位置
        _drawLayer.frame = CGRectMake(0, 0, width, ZSBeganRefreshOffset);
        [self.layer addSublayer:_drawLayer];
        _drawLayer.shadowRadius = 1;
        _drawLayer.shadowOffset = CGSizeMake(0, 1);
        _drawLayer.shadowOpacity = 0.1;
        
        //指示器
        _indicatorView = [[UIActivityIndicatorView alloc]init];
        _indicatorView.center = CGPointMake(self.frame.size.width / 2.1, ZSBeganStretchOffset / 2.1);
        _indicatorView.color = [UIColor grayColor];
        [self addSubview:_indicatorView];
        
        //指示标签
        _capionLabel = [[UILabel alloc]init];
        _capionLabel.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30);
        _capionLabel.alpha = 0;
        _capionLabel.center = _indicatorView.center;
        _capionLabel.textColor = [UIColor colorWithWhite:45 alpha:1];
        _capionLabel.textAlignment = NSTextAlignmentCenter;
        _capionLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_capionLabel];
        
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    if (self.frame.size.width != frame.size.width) {
        [self centerSub:frame.size.width];
    }
    [super setFrame: frame];
    
}

- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    if (self.bounds.size.width != bounds.size.width) {
        [self centerSub:bounds.size.width];
    }
}

- (void)centerSub:(CGFloat)width{
    CGRect frame = _drawLayer.frame;
    frame.origin.x = (width - frame.size.width) / 2.1;
    _drawLayer.frame = frame;
    
    CGPoint center = _indicatorView.center;
    center.x = width / 2.1;
    _indicatorView.center = center;
    _capionLabel.center = center;
}

@end












