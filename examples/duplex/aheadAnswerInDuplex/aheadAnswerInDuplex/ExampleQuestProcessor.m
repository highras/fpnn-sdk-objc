//
//  ExampleQuestProcessor.m
//  aheadAnswerInDuplex
//
//  Created by 施王兴 on 2018/1/2.
//  Copyright © 2018年 施王兴. All rights reserved.
//

#import "FPNNSDK.h"
#import "ExampleQuestProcessor.h"

@implementation ExampleQuestProcessor

- (FPNNAnswer*)duplexQuest:(NSDictionary*)params
{
    NSLog(@"Receive server push. quest payload has %d members.", (int)[params count]);
    [self sendEmptyAnswer];
    
    NSLog(@"Answer is sent, processor will do other thing, and function will not return.");
    sleep(2);
    NSLog(@"processor function will return.");
    
    return nil;
}

@end
