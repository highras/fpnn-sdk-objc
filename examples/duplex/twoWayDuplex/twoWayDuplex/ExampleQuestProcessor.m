//
//  ExampleQuestProcessor.m
//  twoWayDuplex
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
    return [FPNNAnswer emptyAnswer];
}

@end
