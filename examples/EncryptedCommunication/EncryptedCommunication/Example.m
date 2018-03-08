//
//  Example.m
//  EncryptedCommunication
//
//  Created by 施王兴 on 2018/1/2.
//  Copyright © 2018年 施王兴. All rights reserved.
//

#import "FPNNSDK.h"
#import "Example.h"

@implementation Example

+ (void)example:(NSString*)endpoint
{
    FPNNTCPClient* client = [FPNNTCPClient clientWithEndpoint:@"35.167.185.139:13011"];
    
    //-- Der format
    /*
    NSString *derFilePath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test-secp256k1-public.der"];
    BOOL status = [client enableEncryptorByDerFile:derFilePath packageMode:YES withReinforce:NO];
    if (!status)
    {
        NSLog(@"cannot read key files.");
        return;
    }
    */
    
    //-- Pem format
    NSString *pemFilePath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test-secp256k1-public.pem"];
    BOOL status = [client enableEncryptorByPemFile:pemFilePath packageMode:YES withReinforce:NO];
    if (!status)
    {
        NSLog(@"cannot read key files.");
        return;
    }
    
    FPNNQuest* quest = [FPNNQuest quest:@"two way demo"];
    [quest param:@"quest" value:@"one"];
    [quest param:@"int" value:[NSNumber numberWithInt:2]];
    [quest param:@"double" value:[NSNumber numberWithDouble:3.3]];
    [quest param:@"boolean" value:[NSNumber numberWithBool:YES]];
    
    [client sendQuest:quest withCallbackBlock:^(int errorCode, NSDictionary* payload){
        if (errorCode == FPNN_EC_OK)
            NSLog(@"Received answer of first quest.");
        else
            NSLog(@"Received error answer of first quest. code is %d", errorCode);
    }];
    
    quest = [FPNNQuest quest:@"httpDemo"];
    [quest param:@"quest" value:@"two"];
    
    FPNNAnswer* answer = [client sendQuest:quest];
    if (answer.errorAnswer)
    {
        NSNumber* code = (NSNumber*)[answer get:@"code"];
        NSLog(@"Received error answer of second quest. code is %d", [code intValue]);
    }
    else
        NSLog(@"Received answer of second quest.");
}

@end
