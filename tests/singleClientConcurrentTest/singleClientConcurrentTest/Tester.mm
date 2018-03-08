//
//  Tester.m
//  singleClientConcurrentTest
//
//  Created by 施王兴 on 2017/12/28.
//  Copyright © 2017年 施王兴. All rights reserved.
//

#include <atomic>
#include <sys/time.h>
#import "FPNNSDK.h"
#import "Tester.h"

int64_t slack_real_sec()
{
    struct timeval now;
    gettimeofday(&now, NULL);
    
    return now.tv_sec;
}

int64_t slack_real_msec()
{
    struct timeval now;
    gettimeofday(&now, NULL);
    
    return (now.tv_sec * 1000 + now.tv_usec / 1000);
}

@implementation Tester
{
    std::atomic<int> _threadCount;
    FPNNTCPClient* _client;
    NSMutableDictionary* _questPayload;
}

+ (void)showSignDesc
{
    NSLog(@"Sign:");
    NSLog(@"    +: establish connection");
    NSLog(@"    ~: close connection");
    NSLog(@"    #: connection error");
    
    NSLog(@"    *: send sync quest");
    NSLog(@"    &: send async quest");
    
    NSLog(@"    ^: sync answer Ok");
    NSLog(@"    ?: sync answer exception");
    NSLog(@"    |: sync answer exception by connection closed");
    //NSLog(@"    (: sync operation fpnn exception");
    //NSLog(@"    ): sync operation unknown exception");
    
    NSLog(@"    $: async answer Ok");
    NSLog(@"    @: async answer exception");
    NSLog(@"    ;: async answer exception by connection closed");
    //NSLog(@"    {: async operation fpnn exception");
    //NSLog(@"    }: async operation unknown exception");
    
    NSLog(@"    !: close operation");
    //NSLog(@"    [: close operation fpnn exception");
    //NSLog(@"    ]: close operation unknown exception");
}

- (instancetype)initWithClient:(NSString*)endpoint
{
    self = [super init];
    if (self)
    {
        _threadCount = 0;
        
        _client = [FPNNTCPClient clientWithEndpoint:endpoint];
        [_client setConnectedCallback:^(void){
            printf("+");
        }];
        [_client setConnectionWillCloseCallback:^(BOOL closeByError){
            printf(closeByError ? "#" : "~");
        }];
        
        [self buildpayload];
    }
    return self;
}

- (void)buildpayload
{
    _questPayload = [NSMutableDictionary dictionary];
    [_questPayload setValue:@"one" forKey:@"quest"];
    [_questPayload setObject:[NSNumber numberWithInt:2] forKey:@"int"];
    [_questPayload setObject:[NSNumber numberWithDouble:3.3] forKey:@"double"];
    [_questPayload setValue:[NSNumber numberWithBool:YES] forKey:@"boolean"];
    
    NSArray *array = [NSArray arrayWithObjects:@"first_vec", [NSNumber numberWithInt:4], nil];
    [_questPayload setValue:array forKey:@"ARRAY"];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setValue:@"first_map" forKey:@"map1"];
    [dict setValue:[NSNumber numberWithBool:YES] forKey:@"map2"];
    [dict setValue:[NSNumber numberWithInt:5] forKey:@"map3"];
    [dict setValue:[NSNumber numberWithDouble:5.7] forKey:@"map4"];
    [dict setValue:@"中文" forKey:@"map5"];
    
    [_questPayload setValue:dict forKey:@"MAP"];
}

- (void)test_worker:(NSNumber *)nsQps
{
    int act = 0;
    int count = nsQps.intValue;
    for (int i = 0; i < count; i++)
    {
        int64_t index = (slack_real_msec() + i + ((int64_t)(&i) >> 16)) % 64;
        if (i >= 10)
        {
            if (index < 6)
                act = 2;    //-- close operation
            else if (index < 32)
                act = 1;    //-- async quest
            else
                act = 0;    //-- sync quest
        }
        else
            act = index & 0x1;
        
        switch (act)
        {
            case 0:
            {
                printf("*");
                FPNNAnswer* answer = [_client sendQuest:@"two way demo" withPayload:_questPayload];
                if (answer)
                {
                    if (!answer.errorAnswer)
                        printf("^");
                    else
                    {
                        NSNumber* code = (NSNumber*)[answer get:@"code"];
                        if (code && (code.intValue == FPNN_EC_CORE_CONNECTION_CLOSED
                                     || code.intValue == FPNN_EC_CORE_INVALID_CONNECTION))
                            printf("|");
                        else
                            printf("?");
                    }
                }
                else
                    printf("?");
                
                break;
            }
            case 1:
            {
                printf("&");
                BOOL status = [_client sendQuest:@"two way demo" withPayload:_questPayload withCallbackBlock:^(int errorCode, NSDictionary* payload){
                    if (errorCode == 0)
                        printf("$");
                    else if (errorCode == FPNN_EC_CORE_CONNECTION_CLOSED || errorCode == FPNN_EC_CORE_INVALID_CONNECTION)
                        printf(";");
                    else
                        printf("@");
                }];
                if (status == NO)
                    printf("@");
                
                break;
            }
            case 2:
            {
                printf("!");
                [_client close];
                break;
            }
        }
    }
    
    _threadCount--;
}

- (void)testWithThreadCount:(int)threadCount andThreadQuestCount:(int)questCount
{
    _threadCount = threadCount;
    
    NSLog(@"\n========[ Test: thread %d, per thread quest: %d, ]==========\n", threadCount, questCount);
    
    for(int i = 0 ; i < threadCount; i++)
        [NSThread detachNewThreadSelector:@selector(test_worker:) toTarget:self withObject:[NSNumber numberWithInt:questCount]];
    
    while (_threadCount)
        sleep(1);
}

@end
