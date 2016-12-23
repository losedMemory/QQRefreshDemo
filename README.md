# QQRefreshDemo
###这是一个模仿QQ下拉刷新的效果.
####刷新控件是UIScrollView的分类,其中主要控件是在UIView上完成的,其中核心内容是下拉时橡皮筋的变化是通过贝塞尔曲线完成的,控制点坐标和最终点坐标的计算是关键,其他的难度并不是很大.
####关于这个效果的使用只要是UIScrollView及其子类就行,只需要两行代码.
	- (void)viewDidAppear:(BOOL)animated{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 1);
    //添加刷新控件
    [self.scrollView addRefreshWithblock:^{
        
    }];
   
}
