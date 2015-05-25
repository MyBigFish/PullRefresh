//
//  HeaderView.h
//  仿微信下拉刷新
//
//  Created by renren on 5/22/15.
//  Copyright (c) 2015 renren. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^HeaderRefreshBlock)();

@interface HeaderView : UIView

@property (nonatomic,strong) HeaderRefreshBlock headerRefreshBlock;

@property (nonatomic,assign,readonly) BOOL isRefreshing;

@property (nonatomic,assign,setter = setValide:) BOOL isValide;

- (void)startRefresh;

- (void)stopRefresh;

@end
