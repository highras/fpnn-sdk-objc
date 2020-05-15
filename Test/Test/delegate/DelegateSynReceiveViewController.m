//
//  DelegateSynReceiveViewController.m
//  Test
//
//  Created by zsl on 2019/12/5.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import "DelegateSynReceiveViewController.h"
#import <Fpnn/Fpnn.h>
@interface DelegateSynReceiveViewController ()<FPNNProtocol>
@property(nonatomic,strong)FPNNTCPClient * testClient;
@end

@implementation DelegateSynReceiveViewController

-(void)fpnnReceiveDataSuccess:(NSDictionary * _Nullable)responseData  client:(FPNNTCPClient * _Nullable)client quest:(FPNNQuest * _Nullable)quest{
    NSLog(@" recive data %@ %d",responseData,client.isConnected);
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
    self.testClient.delegate = nil;
    NSLog(@"DelegateSynReceiveViewController dealloc");
}
@end
