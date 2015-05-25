//
//  UIScrollView+Refresh.m
//  仿微信下拉刷新
//
//  Created by renren on 5/22/15.
//  Copyright (c) 2015 renren. All rights reserved.
//

#import "UITableView+Refresh.h"
#import <objc/runtime.h>
#import "HeaderView.h"

char* const ASSOCIATION_REFRESH_HEADERVIEW = "ASSOCIATION_REFRESH_HEADERVIEW";

@implementation UITableView (Refresh)

#pragma mark - public method

- (void)addHeaderRefreshBlock:(void (^)())block
{
    self.headerView = [[HeaderView alloc] init];
    self.headerView.headerRefreshBlock = block;
    
}

- (void)beginHeaderRefresh
{
    [self.headerView startRefresh];
}

- (void)endHeaderRefresh
{
    [self.headerView stopRefresh];
}
#pragma mark - get && set

- (void)setHeaderView:(HeaderView *)headerView
{
    if (headerView != self.headerView) {
        [self.headerView removeFromSuperview];
        
        [self willChangeValueForKey:@"headerView"];
        
        objc_setAssociatedObject(self,&ASSOCIATION_REFRESH_HEADERVIEW,headerView,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"headerView"];
        
        [self addSubview:headerView];
        
    }
    
}

- (HeaderView *)headerView
{
    return objc_getAssociatedObject(self,&ASSOCIATION_REFRESH_HEADERVIEW);
}

- (void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero))
    {
        if (contentSize.height > self.contentSize.height)
        {
            CGPoint offset = self.contentOffset;
            offset.y += (contentSize.height - self.contentSize.height);
            self.contentOffset = offset;
        }
    }
    [super setContentSize:contentSize];
}

@end
