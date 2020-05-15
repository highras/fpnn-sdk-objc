//
//  BlockAsynReceiveViewController.m
//  Test
//
//  Created by zsl on 2019/12/5.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import "BlockAsynReceiveViewController.h"
#import <Fpnn/Fpnn.h>
@interface BlockAsynReceiveViewController ()
@property(nonatomic,strong)FPNNTCPClient * testClient;
@end

@implementation BlockAsynReceiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.testClient = [FPNNTCPClient clientWithHost:@"" port:9876];
    __weak typeof(self) weakSelf = self;
    self.testClient.connectionSuccessCallBack = ^{
        
        NSLog(@"block Connect Success %d %d",weakSelf.testClient.isConnected,weakSelf.testClient.connectedPort);
        
    };
    self.testClient.connectionCloseCallBack = ^{
        
        NSLog(@"block Connect Close %d",weakSelf.testClient.isConnected);
        
    };
    
    FPNNQuest * quest = [FPNNQuest questWithMethod:@"two way demo" message:@{@"234":@"123"} twoWay:YES];
    [self.testClient sendQuest:quest
              timeout:0
              success:^(NSDictionary * _Nullable data) {

                NSLog(@"success recive data = %@",data);

              } fail:^(FPNError * _Nullable error) {

                NSLog(@"fail recive error = %@",error);

    }];
            
        
    
        

            
    
    
    
    
    NSLog(@"asyn");
        
}
-(void)dealloc{
    NSLog(@"BlockAsynReceiveViewController dealloc");
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
