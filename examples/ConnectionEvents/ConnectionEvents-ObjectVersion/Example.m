//
//  Example.m
//  ConnectionEvents-ObjectVersion
//
//  Created by 施王兴 on 2017/12/29.
//  Copyright © 2017年 施王兴. All rights reserved.
//

#import "FPNNSDK.h"
#import "Example.h"

@interface ExampleEventProcessor : FPNNQuestProcessor

@end

@implementation ExampleEventProcessor

- (void)connected
{
    NSLog(@"Connection connected.");
}

- (void)connectionWillClose:(BOOL)closeByError
{
    NSLog(@"Connection will close.");
}

@end



@implementation Example

+ (void)exampleWithEndpoint:(NSString*)endpoint
{
    FPNNTCPClient* client = [FPNNTCPClient clientWithEndpoint:endpoint];
    [client setQuestProcessor:[[ExampleEventProcessor alloc] init]];
    
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
