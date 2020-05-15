//
//  BlockSynReceiveViewController.m
//  Test
//
//  Created by zsl on 2019/12/5.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import "BlockSynReceiveViewController.h"
#import <Fpnn/Fpnn.h>
@interface BlockSynReceiveViewController ()
@property(nonatomic,strong)FPNNTCPClient * testClient;
@end

@implementation BlockSynReceiveViewController

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
    FPNNQuest * quest = [FPNNQuest questWithMethod:@"two way demo" message:@{@"234":@[@"1",@"2"]} twoWay:YES];
    FPNNAnswer * answer = [self.testClient sendQuest:quest];
    if (answer != nil) {
        if (answer.error) {
            NSLog(@"fail  sync recive error = %@",answer.error);
        }else{
            NSLog(@"success  sync recive data = %@",answer.responseData);
        }
    }else{
        NSLog(@"is no twoWay");
    }

    NSLog(@"syn");
}
-(void)dealloc{
    NSLog(@"BlockSynReceiveViewController dealloc");
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
