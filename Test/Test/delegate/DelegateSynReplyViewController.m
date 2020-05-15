//
//  DelegateSynReplyViewController.m
//  Test
//
//  Created by zsl on 2019/12/5.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import "DelegateSynReplyViewController.h"
#import <Fpnn/Fpnn.h>
@interface DelegateSynReplyViewController ()<FPNNProtocol>
@property(nonatomic,strong)FPNNTCPClient * testClient;
@end

@implementation DelegateSynReplyViewController

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

-(FPNNAnswer*)fpnnListenAndReplyMessage:(NSDictionary * _Nullable)data method:(NSString * _Nullable)method client:(FPNNTCPClient * _Nullable)client {
    NSLog(@"ListenAndReplyMessage %@ %@",data,method);

    FPNNAnswer * answer = [FPNNAnswer answerWithMessage:@{@"11123123":@"33444"}];
    answer.error = [NSError errorWithDomain:@" 我错啦" code:1111 userInfo:nil];
    
    return answer;
}


-(FPNNAnswer*)duplexQuest:(NSDictionary * _Nullable)data method:(NSString * _Nullable)method client:(FPNNTCPClient * _Nullable)client {
    NSLog(@"duplexQuestListenAndReplyMessage %@ %@",data,method);

    FPNNAnswer * answer = [FPNNAnswer answerWithMessage:@{@"11123123":@"33444"}];
    answer.error = [NSError errorWithDomain:@" 我错啦" code:1111 userInfo:nil];
    
    return answer;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.testClient = [FPNNTCPClient clientWithHost:@"52.83.220.166" port:13077];
    self.testClient.delegate = self;
    
    FPNNQuest * quest = [FPNNQuest questWithMethod:@"duplex demo" message:@{@"duplex method":@"duplexQuest"} twoWay:YES];
    [self.testClient sendQuest:quest
              timeout:0
              success:^(NSDictionary * _Nullable data) {
        
                NSLog(@"success recive data = %@",data);
    
              } fail:^(FPNError * _Nullable error) {
                    
                NSLog(@"fail recive error = %@",error);
    
    }];
}
-(void)dealloc{
    self.testClient.delegate = nil;
    NSLog(@"DelegateSynReplyViewController dealloc");
}
@end
