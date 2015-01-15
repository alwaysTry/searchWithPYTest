//
//  SearchResultTabCon.m
//  searchText
//
//  Created by yanzhg on 14-9-4.
//  Copyright (c) 2014年 yanzhg. All rights reserved.
//

#import "SearchResultTabCon.h"
#import "PinYin4Objc.h"

@interface SearchResultTabCon ()
{
    NSMutableArray *_allCitiesArr;
    NSMutableArray *_resultArr;
}

@end
@implementation SearchResultTabCon

- (void)viewDidLoad
{
    self.tableView.backgroundColor = [UIColor whiteColor];
   
}

- (void)setSearchText:(NSString *)searchText
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"citydict"
                                                   ofType:@"plist"];
    NSArray *arrr = [[[NSDictionary alloc]initWithContentsOfFile:path] allValues];
    NSMutableArray *allCitiesArr = [NSMutableArray array];
    
    for (NSArray *arr in arrr) {
        for (NSString *str in arr) {
            [allCitiesArr addObject:str];
        }
    }
    
    _resultArr = [NSMutableArray array];
    for (int i = 0; i < allCitiesArr.count; i++) {
        NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:allCitiesArr[i]];
        NSRange titleResult=[tempPinYinStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (titleResult.length > 0) {
            [_resultArr addObject:allCitiesArr[i]];
        }
        
        NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:allCitiesArr[i]];
        NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (titleHeadResult.length>0) {
            [_resultArr addObject:allCitiesArr[i]];
        }
        
        NSRange range = [allCitiesArr[i] rangeOfString:searchText];
        if (range.location != NSNotFound) {
            [_resultArr addObject:allCitiesArr[i]];
        }
        
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
    }
    cell.textLabel.text = _resultArr[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor darkTextColor];
    UILabel *textLabel = [[UILabel alloc]init];
    // 这怎么会有一个警告呢？求解
    textLabel.text = [NSString stringWithFormat:@"总共搜索到%d个结果",_resultArr.count];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:15];
    textLabel.frame = CGRectMake(12, 0, 320, 20);
    [headerView addSubview:textLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *text = _resultArr[indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[ NSString stringWithFormat:@"切换%@为当前城市？",text] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kpushNameOne object:nil];
    
}
@end
