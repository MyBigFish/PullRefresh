//
//  ViewController.m
//  仿微信下拉刷新
//
//  Created by renren on 5/22/15.
//  Copyright (c) 2015 renren. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+Refresh.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray * dataArray;

@end

@implementation ViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.rowHeight = 44;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
    
    [self.tableView addHeaderRefreshBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
        
            for (int i = 0; i < 10; i++) {
                [self.dataArray insertObject:@"0" atIndex:0];
            }
            
            [self.tableView reloadData];
            
            [self.tableView endHeaderRefresh];
        });

    
    }];
    
    self.tableView.headerView.isValide = YES;
 
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self tableViewScrollCurrentIndexPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - click

- (IBAction)click:(id)sender {
    
    [self.tableView beginHeaderRefresh];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    
    NSString *text = [NSString stringWithFormat:@"%@",self.dataArray[indexPath.row]];
    cell.textLabel.text = text;
    return cell;
}


#pragma mark - get

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [@[] mutableCopy];
    
        for (int i = 0; i < 100; i++) {
            [_dataArray addObject:[NSString stringWithFormat:@"%@",@(i)]];
        }
    }
    return _dataArray;
}



@end
