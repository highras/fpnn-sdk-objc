//
//  BlockAsynReplyViewController.m
//  Test
//
//  Created by zsl on 2019/12/5.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import "BlockAsynReplyViewController.h"
#import <Fpnn/Fpnn.h>
@interface BlockAsynReplyViewController ()
@property(nonatomic,strong)FPNNTCPClient * testClient;
@end

@implementation BlockAsynReplyViewController

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

        FPNNAsyncAnswer * iAsyncAnswer = [FPNNAsyncAnswer asyncAnswerWithClient:weakSelf.testClient answerMessage:@{@"666":@"666"}];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            sleep(5);//时间过久会超时
            [iAsyncAnswer sendAnswerMessage];

        });
        
        return nil;
    };
    
    FPNNQuest * quest = [FPNNQuest questWithMethod:@"duplex demo" message:@{@"duplex method":@"duplexQuest"} twoWay:YES];
    [self.testClient sendQuest:quest success:^(NSDictionary * _Nullable data) {
        NSLog(@"success recive data  %@  %@",data,weakSelf.testClient);
    } fail:^(FPNError * _Nullable error) {
        NSLog(@"fail recive error  %@  %@",error,weakSelf.testClient);
    }];
}

-(void)dealloc{
    NSLog(@"BlockAsynReplyViewController dealloc");
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
