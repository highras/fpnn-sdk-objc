//
//  ViewController.m
//  Test
//
//  Created by zsl on 2019/11/27.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import "ViewController.h"
#import <Fpnn/Fpnn.h>
#import "BlockAsynReceiveViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * listView;
@property(nonatomic,strong)NSArray * array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}
-(void)loadView{
    self.array = @[
    @"BlockSynReceiveViewController",
    @"BlockAsynReceiveViewController",
    @"BlockSynReplyViewController",
    @"BlockAsynReplyViewController",
    @"DelegateSynReceiveViewController",
    @"DelegateAsynReceiveViewController",
    @"DelegateSynReplyViewController",
    @"DelegateAsynReplyViewController",
    @"PressureTestViewController"];
    self.view = self.listView;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController * vc = [[BlockAsynReceiveViewController alloc]init];
    vc.title = self.array[indexPath.row+indexPath.section*4];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
        return 1;
    }
    return 4;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel * lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    lb.textColor = [UIColor blackColor];
    lb.text = section == 0 ? @"    block" : @"    delegate";
    if (section == 2) {
        lb.text = @"    PressureTest";
    }
    lb.font = [UIFont boldSystemFontOfSize:22];
    return lb;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    }
    cell.textLabel.text = self.array[indexPath.row+indexPath.section*4];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    return cell;
}
-(UITableView*)listView{
    if (_listView == nil) {
        _listView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _listView.delegate = self;
        _listView.dataSource = self;
    }
    return _listView;
}
@end
