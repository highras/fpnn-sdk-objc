//
//  PressureTestViewController.m
//  Test
//
//  Created by zsl on 2019/12/5.
//  Copyright © 2019 FunPlus. All rights reserved.
//
#include <atomic>
#import "PressureTestViewController.h"
#import <Fpnn/Fpnn.h>
@interface PressureTestViewController (){
 
    std::atomic<int64_t> _send;
    std::atomic<int64_t> _recv;
    std::atomic<int64_t> _sendError;
    std::atomic<int64_t> _recvError;
    std::atomic<int64_t> _timecost;
    
    NSMutableDictionary* _questPayload;
    
}
@property (nonatomic) int clientCount;
@property (nonatomic) int totalQPS;
@end


int64_t exact_real_usec()
{
    struct timespec now;
    clock_gettime(CLOCK_REALTIME, &now);
    return (int64_t)now.tv_sec * 1000000 + now.tv_nsec / 1000;
}


@implementation PressureTestViewController
-(void)dealloc{
    NSLog(@"PressureTestViewController dealloc");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self launch];
    });
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
    
    NSLog(@"-- qps: %d, usec: %d", qps, usec);
    
    FPNNTCPClient* client = [FPNNTCPClient clientWithHost:@"" port:9876];
    [client connect];
    
    while (true)
    {
        @autoreleasepool {
            
            int64_t send_time = exact_real_usec();
            
            FPNNQuest * quest = [FPNNQuest questWithMethod:@"two way demo" message:_questPayload twoWay:YES] ;
            BOOL status = [client sendQuest:quest success:^(NSDictionary * _Nullable data) {
                
                if (data) {
                    
                    [self incRecv];
                    int64_t recv_time = exact_real_usec();
                    int64_t diff = recv_time - send_time;
                    [self addTimecost:diff];
                }
                
            } fail:^(FPNError * _Nullable error) {
                if (error) {
                    
                    [self incRecvError];
                    if (error.code == FPNN_EC_CORE_TIMEOUT){
                        NSLog(@"Timeouted occurred when recving.");
                    }else{
                        NSLog(@"error occurred when recving.");
                    }
                    
                }
            }];
            
            if (status){
                
                _send++;
            
            }else{
                
                _sendError++;
                NSLog(@"error occurred when sending");
                
            }
            
            
            int64_t sent_time = exact_real_usec();
            int64_t real_usec = usec - (sent_time - send_time);
            if (real_usec > 0)
                usleep((unsigned int)real_usec);
            
        }
        
        
    }
    
    
}

- (void)launch{
    
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
