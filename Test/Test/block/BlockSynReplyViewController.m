//
//  BlockSynReplyViewController.m
//  Test
//
//  Created by zsl on 2019/12/5.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import "BlockSynReplyViewController.h"
#import <Fpnn/Fpnn.h>
@interface BlockSynReplyViewController ()
@property(nonatomic,strong)FPNNTCPClient * testClient;
@end

@implementation BlockSynReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.testClient = [FPNNTCPClient clientWithHost:@"" port:13077];
    __weak typeof(self) weakSelf = self;
    self.testClient.connectionSuccessCallBack = ^{
        
        NSLog(@"block Connect Success %d",weakSelf.testClient.isConnected);
        
    };
    self.testClient.connectionCloseCallBack = ^{
        
        NSLog(@"block Connect Close %d",weakSelf.testClient.isConnected);
        
    };
        
    self.testClient.listenAndReplyCallBack = ^FPNNAnswer * _Nullable(NSDictionary * _Nullable data, NSString * _Nullable method){
        NSLog(@"recv quest data = %@  method = %@",data,method);

        FPNNAnswer * answer = [FPNNAnswer answerWithMessage:@{@"11123123":@"33444"}];
        
        return answer;
    };
    
    FPNNQuest * quest = [FPNNQuest questWithMethod:@"duplex demo" message:@{@"duplex method":@"duplexQuest"} twoWay:YES];
    [self.testClient sendQuest:quest success:^(NSDictionary * _Nullable data) {
        NSLog(@"success recive data = %@",data);
    } fail:^(FPNError * _Nullable error) {
        NSLog(@"fail recive error = %@",error);
    }];
    
    
}
-(void)dealloc{
    NSLog(@"BlockSynReplyViewController dealloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
