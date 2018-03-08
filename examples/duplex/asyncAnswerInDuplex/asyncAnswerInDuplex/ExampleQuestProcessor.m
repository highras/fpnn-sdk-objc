//
//  ExampleQuestProcessor.m
//  asyncAnswerInDuplex
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
    
    FPNNAsyncAnswer* async = [self genAsyncAnswer];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        NSLog(@"Will answer server push.");
        [async sendEmptyAnswer];
    });
    
    NSLog(@"Server push processing function will return.");
    return nil;
}


@end
