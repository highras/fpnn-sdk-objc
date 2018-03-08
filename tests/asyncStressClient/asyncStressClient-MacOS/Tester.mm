//
//  Tester.m
//  asyncStressClient-MacOS
//
//  Created by 施王兴 on 2017/12/29.
//  Copyright © 2017年 施王兴. All rights reserved.
//

#include <atomic>
#import "FPNNSDK.h"
#import "Tester.h"

int64_t exact_real_usec()
{
    struct timespec now;
    clock_gettime(CLOCK_REALTIME, &now);
    return (int64_t)now.tv_sec * 1000000 + now.tv_nsec / 1000;
}

@implementation Tester
{
    std::atomic<int64_t> _send;
    std::atomic<int64_t> _recv;
    std::atomic<int64_t> _sendError;
    std::atomic<int64_t> _recvError;
    std::atomic<int64_t> _timecost;
    
    NSMutableDictionary* _questPayload;
}

- (instancetype)init
{
    self  = [super init];
    if (self)
    {
        _clientCount = 10;
        _totalQPS = 5000;
        
        _send = 0;
        _recv = 0;
        _sendError = 0;
        _recvError = 0;
        _timecost = 0;
        
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
    return self;
}

- (void)incRecv
{
    _recv++;
}

- (void)incRecvError
{
    _recvError++;
}

- (void)addTimecost:(int64_t)cost
{
    _timecost.fetch_add(cost);
}

- (void)test_worker:(NSNumber *)nsQps
{
    int qps = [nsQps intValue];
    int usec = 1000 * 1000 / qps;
    Tester* ins = self;
    
    NSLog(@"-- qps: %d, usec: %d", qps, usec);
    
    FPNNTCPClient* client = [[FPNNTCPClient alloc] initWithEndpoint:_endpoint autoReconnection:YES];
    [client connect];
    
    while (true)
    {
        int64_t send_time = exact_real_usec();
        BOOL status = [client sendQuest:@"two way demo" withPayload:_questPayload withCallbackBlock:^(int errorCode, NSDictionary* dict){
            if (errorCode != FPNN_EC_OK)
            {
                [ins incRecvError];
                if (errorCode == FPNN_EC_CORE_TIMEOUT)
                    NSLog(@"Timeouted occurred when recving.");
                else
                    NSLog(@"error occurred when recving.");
                
                return;
            }
            
            [ins incRecv];
            
            int64_t recv_time = exact_real_usec();
            int64_t diff = recv_time - send_time;
            [ins addTimecost:diff];
        }];
        
        if (status)
            _send++;
        else
        {
            _sendError++;
            NSLog(@"error occurred when sending");
        }
        
        int64_t sent_time = exact_real_usec();
        int64_t real_usec = usec - (sent_time - send_time);
        if (real_usec > 0)
            usleep((unsigned int)real_usec);
    }
}

- (void)launch
{
    int threadQPS = _totalQPS / _clientCount;
    if (threadQPS == 0)
        threadQPS = 1;
    int remain = _totalQPS - threadQPS * _clientCount;
    
    for(int i = 0 ; i < _clientCount; i++)
        [NSThread detachNewThreadSelector:@selector(test_worker:) toTarget:self withObject:[NSNumber numberWithInt:threadQPS]];
    
    if (remain > 0)
        [NSThread detachNewThreadSelector:@selector(test_worker:) toTarget:self withObject:[NSNumber numberWithInt:remain]];
    
    [NSThread detachNewThreadSelector:@selector(showStatistics) toTarget:self withObject:nil];
}

- (void)showStatistics
{
    const int sleepSeconds = 3;
    
    int64_t send = _send;
    int64_t recv = _recv;
    int64_t sendError = _sendError;
    int64_t recvError = _recvError;
    int64_t timecost = _timecost;
    
    
    while (true)
    {
        int64_t start = exact_real_usec();
        
        sleep(sleepSeconds);
        
        int64_t s = _send;
        int64_t r = _recv;
        int64_t se = _sendError;
        int64_t re = _recvError;
        int64_t tc = _timecost;
        
        int64_t ent = exact_real_usec();
        
        int64_t ds = s - send;
        int64_t dr = r - recv;
        int64_t dse = se - sendError;
        int64_t dre = re - recvError;
        int64_t dtc = tc - timecost;
        
        send = s;
        recv = r;
        sendError = se;
        recvError = re;
        timecost = tc;
        
        int64_t real_time = ent - start;
        
        if (dr)
            dtc = dtc / dr;
        
        ds = ds * 1000 * 1000 / real_time;
        dr = dr * 1000 * 1000 / real_time;
        //dse = dse * 1000 * 1000 / real_time;
        //dre = dre * 1000 * 1000 / real_time;
        
        NSLog(@"time interval: %f ms, send error: %lld, recv error: %lld", (real_time / 1000.0), dse, dre);
        NSLog(@"[QPS] send: %lld, recv: %lld, per quest time cost: %lld usec", ds, dr, dtc);
    }
}


@end
