//
//  HeaderView.m
//  仿微信下拉刷新
//
//  Created by renren on 5/22/15.
//  Copyright (c) 2015 renren. All rights reserved.
//

#import "HeaderView.h"

#define kRefreshContentOffset @"contentOffset"

// 下拉刷新控件的状态
typedef enum {
    /** 普通闲置状态 */
    RefreshHeaderStateIdle = 1,
    /** 正在刷新中的状态 */
    RefreshHeaderStateRefreshing,
} RefreshHeaderState;


@interface HeaderView ()

@property (nonatomic,strong) UIActivityIndicatorView *activityView;
@property (nonatomic,assign) RefreshHeaderState state;

/** 父控件 */
@property (weak, nonatomic) UITableView *tableView;

/** 记录scrollView刚开始的inset */
@property (assign, nonatomic) UIEdgeInsets scrollViewOriginalInset;

@end

@implementation HeaderView

#pragma mark - lifeCycle

- (void)dealloc
{
    [self.superview removeObserver:self forKeyPath:kRefreshContentOffset context:nil];
}

- (instancetype)init
{
    if (self = [super init]) {
        self.state = RefreshHeaderStateIdle;
        self.isValide = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.activityView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, 44/2.0f);
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    [self.superview removeObserver:self forKeyPath:kRefreshContentOffset context:nil];
    
    if (newSuperview) {
        
        [newSuperview addObserver:self forKeyPath:kRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        self.tableView = (UITableView *)newSuperview;
        
        [self addSubview:self.activityView];
        
        [self configureFrame];
    }
}

- (void)configureFrame
{
    self.frame = CGRectMake(0, -44, CGRectGetWidth(self.tableView.frame), 44);
}


#pragma mark KVO属性监听

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (self.state == RefreshHeaderStateRefreshing) return;
    
    // 根据contentOffset调整state
    if ([keyPath isEqualToString:kRefreshContentOffset]) {
        [self adjustStateWithContentOffset];
    }
}


#pragma mark 根据contentOffset调整state

- (void)adjustStateWithContentOffset
{
    if (self.isValide == NO) {
        return;
    }
    
    // 在刷新的 refreshing 状态，动态设置 content inset
    if (self.state == RefreshHeaderStateRefreshing) {
        if(self.tableView.contentOffset.y >= -_scrollViewOriginalInset.top ) {
            
            UIEdgeInsets inset = self.tableView.contentInset;
            inset.top = _scrollViewOriginalInset.top;
        } else {
            
            UIEdgeInsets inset = self.tableView.contentInset;
            
            //如果下拉,平滑出现
            
            CGFloat value1 = _scrollViewOriginalInset.top + CGRectGetHeight(self.bounds);
            CGFloat value2 = _scrollViewOriginalInset.top - self.tableView.contentOffset.y;
            
            inset.top = MIN(value1, value2);
            self.tableView.contentInset = inset;
        }
        return;
    }
    
    // 当前的contentOffset
    CGPoint contentOffset = self.tableView.contentOffset;
    
    CGFloat offsetY = contentOffset.y;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - _scrollViewOriginalInset.top;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (offsetY >= happenOffsetY) return;
    
    if (offsetY < 0) {
        [self startRefresh];
    }
    
}


#pragma mark - public method

- (void)startRefresh
{
    if (self.window) {
        self.state = RefreshHeaderStateRefreshing;
    }
}

- (void)stopRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.state = RefreshHeaderStateIdle;
    });

}

#pragma mark - get && set

- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil) {
         _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityView startAnimating];
    }
    return _activityView;
}


- (void)setValide:(BOOL)isValide
{
    _isValide = isValide;
    
    if (_isValide == YES) {
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
}

- (void)setState:(RefreshHeaderState)state
{
    if (_state == state) return;
    
    // 旧状态
    RefreshHeaderState oldState = _state;
    
    // 赋值
    _state = state;
    
    switch (state) {
        case RefreshHeaderStateIdle: {
            if (oldState == RefreshHeaderStateRefreshing) {
                
                // 恢复inset和offset
                [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
                    // 修复top值不断累加
                    
                    UIEdgeInsets inset = self.tableView.contentInset;
                    inset.top -= CGRectGetHeight(self.frame);
                    self.tableView.contentInset = inset;
                    
                } completion:^(BOOL finished) {
                    
                }];
            }
            break;
        }
            
        case RefreshHeaderStateRefreshing: {
            
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
                
                CGFloat top = _scrollViewOriginalInset.top + CGRectGetHeight(self.frame);
                UIEdgeInsets inset = self.tableView.contentInset;
                inset.top = top;
                self.tableView.contentInset = inset;
                
                // 设置滚动位置
                CGPoint offset = self.tableView.contentOffset;
                offset.y = -top;
                self.tableView.contentOffset = offset;

                
            } completion:^(BOOL finished) {
                if (self.headerRefreshBlock) {
                    self.headerRefreshBlock();
                }
            }];
            break;
        }
            
        default:
            break;
    }
}


- (BOOL)isRefreshing
{
    if (self.state == RefreshHeaderStateRefreshing) {
        return YES;
    }
    return NO;
}

@end
