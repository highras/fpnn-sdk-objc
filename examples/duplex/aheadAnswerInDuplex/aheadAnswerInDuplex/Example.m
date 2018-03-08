//
//  Example.m
//  aheadAnswerInDuplex
//
//  Created by 施王兴 on 2018/1/2.
//  Copyright © 2018年 施王兴. All rights reserved.
//

#import "FPNNSDK.h"
#import "ExampleQuestProcessor.h"
#import "Example.h"

@implementation Example

+ (void)example:(NSString*)endpoint
{
    FPNNTCPClient* client = [FPNNTCPClient clientWithEndpoint:endpoint];
    [client setQuestProcessor:[[ExampleQuestProcessor alloc] init]];
    
    FPNNQuest* quest = [FPNNQuest quest:@"duplex demo"];
    [quest param:@"duplex method" value:@"duplexQuest"];
    
    FPNNAnswer* answer = [client sendQuest:quest];
    if (answer.errorAnswer)
    {
        NSNumber* code = (NSNumber*)[answer get:@"code"];
        NSLog(@"Received error answer quest. code is %d", [code intValue]);
    }
    else
        NSLog(@"Received answer of quest.");
}

@end
