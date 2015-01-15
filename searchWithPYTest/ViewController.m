//
//  ViewController.m
//  searchText
//
//  Created by yanzhg on 14-9-4.
//  Copyright (c) 2014年 yanzhg. All rights reserved.
//
#define KVIEW_WIDTH (self.view.bounds.size.width)
#define KVIEW_HEIGHT (self.view.bounds.size.height)
#define KOFF_START_Y (([[UIDevice currentDevice].systemName floatValue] >= 7.0)?20:0)
#define KSRARCHBAR_HEIGHT 44

#import "ViewController.h"
#import "SearchResultTabCon.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSMutableArray *_headerTitleArr;
    NSMutableArray *_cellTitleArr;
    NSMutableDictionary *_cities;
    UITableView *_tableView;
    UIView *_coverView;
    SearchResultTabCon *_searchResultCon;
    UISearchBar *_searchBar;
    BOOL        _notifEndEdi;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 初始化tableview
	[self setupTableView];

    // 初始化UISearchBar
    [self setupSearchView];
    
    // 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarEndEdting) name:kpushNameOne object:nil];
}

#pragma mark - 通知
- (void)searchBarEndEdting
{
    _notifEndEdi = YES;
    [_searchBar endEditing:YES];
}

#pragma mark - 初始化tableview
- (void)setupTableView
{
    _tableView = [[UITableView alloc]init];
    _tableView.frame = CGRectMake(0, KSRARCHBAR_HEIGHT+20, KVIEW_WIDTH, KVIEW_HEIGHT - KSRARCHBAR_HEIGHT);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _headerTitleArr = [NSMutableArray array];
    _cellTitleArr = [NSMutableArray array];
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"citydict"
                                                   ofType:@"plist"];
    _cities = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    [_headerTitleArr addObjectsFromArray:[[_cities allKeys] sortedArrayUsingSelector:@selector(compare:)]];
}

#pragma mark - 初始化UISearchBar
- (void)setupSearchView
{
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    searchBar.frame = CGRectMake(0, 20, KVIEW_WIDTH, KSRARCHBAR_HEIGHT);
    searchBar.delegate = self;
    searchBar.placeholder = @"输入城市名或拼音进行搜索";
    [self.view addSubview:searchBar];
    _searchBar = searchBar;
}

#pragma mark - 数据源方法
#pragma mark 索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _headerTitleArr;
}

#pragma mark 组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _headerTitleArr.count;
}
#pragma mark 每组行数
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_headerTitleArr objectAtIndex:section];
    NSArray *citySection = [_cities objectForKey:key];
    return [citySection count];
}

#pragma mark 某个cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    NSString *key = [_headerTitleArr objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[_cities objectForKey:key] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark 每组的标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_headerTitleArr objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [_headerTitleArr objectAtIndex:indexPath.section];
    NSString *text = [[_cities objectForKey:key] objectAtIndex:indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[ NSString stringWithFormat:@"切换%@为当前城市？",text] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
}

#pragma mark - UISearchBar 代理方法
#pragma mark 开始编辑
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    // 显示取消按钮
    [searchBar setShowsCancelButton:YES animated:YES];
    
    // 添加蒙版
    _coverView = [[UIView alloc]init];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.alpha = 0.5f;
    _coverView.frame = _tableView.frame;
    [self.view addSubview:_coverView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_coverView addGestureRecognizer:tap];
    [_coverView addGestureRecognizer:pan];
    
    return YES;
}

#pragma mark 取消编辑
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    
    if (_notifEndEdi) {
        return YES;
    }else{
        searchBar.text = nil;
        // 隐藏取消按钮
        [searchBar setShowsCancelButton:NO animated:YES];
        
        // 隐藏蒙版
        [_coverView removeFromSuperview];
        _coverView = nil;
        
        // 删除结果页view
        if (_searchResultCon) {
            [_searchResultCon.view removeFromSuperview];
            [_searchResultCon removeFromParentViewController];
        }
        
        return YES;
    }
}

- (void)tapAction
{
    _notifEndEdi = NO;
    [self.view endEditing:YES];
}

#pragma mark 搜索文字发生改变
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // 判断
    if (searchText.length) {
        if (_searchResultCon == nil) {
            _searchResultCon = [[SearchResultTabCon alloc]init];
            [self addChildViewController:_searchResultCon];
        }
        _searchResultCon.view.frame = _tableView.frame;
        _searchResultCon.searchText = searchBar.text;
        [self.view addSubview:_searchResultCon.view];
    }else
    {
        [_searchResultCon.view removeFromSuperview];
        [_searchResultCon removeFromParentViewController];
        
    }
    
}

#pragma 取消按钮点击方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _notifEndEdi = NO;
    [searchBar resignFirstResponder];
    
}


@end
