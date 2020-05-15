//
//  DelegateAsynReplyViewController.m
//  Test
//
//  Created by zsl on 2019/12/5.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import "DelegateAsynReplyViewController.h"
#import <Fpnn/Fpnn.h>
@interface DelegateAsynReplyViewController ()<FPNNProtocol>
@property(nonatomic,strong)FPNNTCPClient * testClient;
@property(nonatomic,weak)FPNNTCPClient * testClient1;
@property(nonatomic,strong)FPNNAsyncAnswer * iAsyncAnswer;
@end

@implementation DelegateAsynReplyViewController


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

    //self.iAsyncAnswer = [FPNNIAsyncAnswer iAsyncAnswerWithClient:client message:@{@"666":@"666"} ];
    FPNNAsyncAnswer * iAsyncAnswer = [self _getiAsyncAnswer:client];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        sleep(5);//时间过久会超时
        [iAsyncAnswer sendAnswerMessage];


    });
    
    return nil;
}
-(FPNNAsyncAnswer *)_getiAsyncAnswer:(FPNNTCPClient*)client{
    return [FPNNAsyncAnswer asyncAnswerWithClient:client answerMessage:@{@"666":@"666"} ];
}
//-(FPNNAnswer*)duplexQuest:(NSDictionary * _Nullable)data method:(NSString * _Nullable)method client:(FPNNTCPClient * _Nullable)client {
//    NSLog(@"duplexQuest ListenAndReplyMessage %@ %@",data,method);
//
//    FPNNIAsyncAnswer * iAsyncAnswer = [FPNNIAsyncAnswer iAsyncAnswerWithClient:client message:@{@"666":@"666"}];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        sleep(3);//时间过久会超时
//        [iAsyncAnswer sendMessage];
//
//    });
//
//    return nil;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.testClient = [FPNNTCPClient clientWithHost:@"52.83.220.166" port:13077];
    self.testClient.delegate = self;
    __weak typeof(self) weakSelf = self;
    FPNNQuest * quest = [FPNNQuest questWithMethod:@"duplex demo" message:@{@"duplex method":@"duplexQuest"} twoWay:YES];
    [self.testClient sendQuest:quest
              timeout:0
              success:^(NSDictionary * _Nullable data) {
            
                NSLog(@"success recive data = %@  %@",data,weakSelf.testClient);
        
              } fail:^(FPNError * _Nullable error) {
    
                NSLog(@"fail recive error = %@  %@",error,weakSelf.testClient);
    }];
    
    NSLog(@"asyn");
}
-(void)dealloc{
    self.testClient.delegate = nil;
    NSLog(@"DelegateAsynReplyViewController dealloc");
}
@end

