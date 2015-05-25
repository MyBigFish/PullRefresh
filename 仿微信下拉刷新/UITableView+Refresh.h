//
//  UIScrollView+Refresh.h
//  仿微信下拉刷新
//
//  Created by renren on 5/22/15.
//  Copyright (c) 2015 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface UITableView (Refresh)

@property (nonatomic,strong) HeaderView *headerView;
/**
 *  头部刷新回调方法
 *
 *  @param block 回调block
 */
- (void)addHeaderRefreshBlock:(void(^)())block;

/**
 *  开始头部刷新
 */
- (void)beginHeaderRefresh;

/**
 *  结束头部刷新
 */
- (void)endHeaderRefresh;

@end
