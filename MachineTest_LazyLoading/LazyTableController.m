//
//  ViewController.m
//  MachineTest_LazyLoading
//
//  Created by Rajesh Sharma on 26/11/15.
//  Copyright (c) 2015 Practice. All rights reserved.
//

#define DataURL @"https://itunes.apple.com/search?term=apple&media=software"
#define BatchCount 10
#define LastSection 2
#define CellLazy @"lazycell"
#define CellLoading @"loadingCell"

#import "LazyTableController.h"
#import "ConnectionManager.h"

@interface LazyTableController ()
@property (strong, nonatomic) IBOutlet UITableView *lazyTableView;
@property (strong, nonatomic) NSArray          *arrTableMainData;
@property (strong, nonatomic) NSMutableArray   *arrTableData;
@property (assign, nonatomic) NSInteger        pageValue;
@end

@implementation LazyTableController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _arrTableData = [NSMutableArray arrayWithCapacity:2];
    ConnectionManager *conManager = [ConnectionManager sharedConnectionManager];
    _pageValue = 1;
    [conManager getDataFromURL:DataURL completion:^(id response) {
       
        _arrTableMainData = [[NSArray alloc] initWithArray:[response objectForKey:@"results"]];
        NSLog(@"Response data --> %@",_arrTableMainData);
        [self trigerToLoadMoreDataAfterIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [_lazyTableView reloadData];
}

#pragma mark - Helper Functions

- (void)loadMoreData:(NSArray *)data {
    
    if(data) {
        [_arrTableData addObjectsFromArray:data];
        if([NSThread isMainThread]) {
            
            [_lazyTableView reloadData];
        }
        else {
            [_lazyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)trigerToLoadMoreDataAfterIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *arrDataToLoad = nil;
    NSInteger remaingData = _arrTableMainData.count - _arrTableData.count;
    if(remaingData > BatchCount)
    {
        arrDataToLoad = [NSArray arrayWithArray:[_arrTableMainData subarrayWithRange:NSMakeRange(_arrTableData.count, BatchCount)]];
    }
    else if (remaingData > 0){
        if(_pageValue == 1)
        {
            arrDataToLoad = [NSArray arrayWithArray:_arrTableMainData];
        }
        else
        {
            arrDataToLoad = [NSArray arrayWithArray:[_arrTableMainData subarrayWithRange:NSMakeRange(_arrTableData.count, remaingData)]];
        }
    }
    if(remaingData == 0) {
        
    }
    [self loadMoreData:arrDataToLoad];
    _pageValue++;
}

#pragma mark - TableView Delegate Function
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == (LastSection - 1)) {
        
        [self trigerToLoadMoreDataAfterIndexPath:indexPath];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return LastSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(section == (LastSection - 1)) {
        
        if(_arrTableData.count == _arrTableMainData.count) {
            
            return 0;
        }
        return 1;
    }
    return [_arrTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    NSLog(@"Section --> %ld",(long)indexPath.section);
    if (indexPath.section == (LastSection - 1)) {

        cell = [tableView dequeueReusableCellWithIdentifier:CellLoading];
    }
    else if(_arrTableData.count > indexPath.row )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellLazy];
        NSDictionary *dataDic = [_arrTableData objectAtIndex:indexPath.row];
        cell.textLabel.text = [dataDic valueForKey:@"trackName"];
        cell.detailTextLabel.text = [dataDic valueForKey:@"description"];
        [[ConnectionManager sharedConnectionManager] imageLoadingForURL:[dataDic valueForKey:@"artworkUrl60"] andImageView:cell.imageView];
    }
    return cell;
}

@end
