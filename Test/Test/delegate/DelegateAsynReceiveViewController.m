//
//  DelegateAsynReceiveViewController.m
//  Test
//
//  Created by zsl on 2019/12/5.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import "DelegateAsynReceiveViewController.h"
#import <Fpnn/Fpnn.h>
@interface DelegateAsynReceiveViewController ()<FPNNProtocol>
@property(nonatomic,strong)FPNNTCPClient * testClient;
@end

@implementation DelegateAsynReceiveViewController

-(void)fpnnReceiveDataSuccess:(NSDictionary * _Nullable)responseData  client:(FPNNTCPClient * _Nullable)client quest:(FPNNQuest * _Nullable)quest{
    NSLog(@" recive data %@ %d  %@",responseData,client.isConnected,quest);
}

-(void)fpnnReceiveDataError:(NSError * _Nullable)error client:(FPNNTCPClient * _Nullable)client quest:(FPNNQuest * _Nullable)quest{
    NSLog(@" recive data error %@ ",error);
}

-(void)fpnnConnectionSuccess:(FPNNTCPClient *)client{
    NSLog(@" Connect Success  %@  %d  %d",client.connectedHost, client.connectedPort,client.isConnected);
    
}

-(void)fpnnConnectionClose:(FPNNTCPClient *)client{
    NSLog(@" Connect Close  %@ %d  %d",client.connectedHost,client.connectedPort,client.isConnected);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testClient = [FPNNTCPClient clientWithHost:@"52.83.220.166" port:13077];
    self.testClient.delegate = self;
    
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
    self.testClient.delegate = nil;
    NSLog(@"DelegateAsynReceiveViewController dealloc");
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
