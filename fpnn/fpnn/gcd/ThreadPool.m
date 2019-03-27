//
//  ThreadPool.m
//  fpnn
//
//  Created by dixun on 2018/6/4.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "ThreadPool.h"
#import "FPEvent.h"
#import "EventData.h"
#import "FPConfig.h"

@interface ThreadPool() {
    
}
@end


@implementation ThreadPool

static ThreadPool * _instance = nil;

+ (instancetype) shareInstance {

    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance ;
}

+ (id) allocWithZone:(struct _NSZone *)zone {
    
    return [ThreadPool shareInstance] ;
}

- (id) copyWithZone:(struct _NSZone *)zone {
    
    return [ThreadPool shareInstance] ;
}

- (instancetype) init {
    
    if (self = [super init]) {
        
        _queue = dispatch_queue_create("thread_pool_serial_queue", DISPATCH_QUEUE_SERIAL);
        _event = [[FPEvent alloc] init];
    }
    
    return self;
}

- (void) executeOperation:(NSOperation *)operation andQueue:(NSOperationQueue *)queue {
    
    if (self.threadPool == nil) {
        
        self.threadPool = [[BaseThreadPool alloc] init];
    }
    
    [self.threadPool executeOperation:operation andQueue:queue];
}

- (void) setThreadPool:(id<ThreadPoolDelegate>)threadPool {
    
    @synchronized (self) {
        
        if (self->_threadPool == nil) {
            
            self->_threadPool = threadPool;
        }
    }
}

- (void) onSecond {
    
    NSInteger timestamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    [self.event fireEvent:[[EventData alloc] initWithType:@"second" andTimestamp:timestamp]];
}

- (void) startTimerThread {
    
    if (self.timer == nil) {
        
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
        
        dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), 1 * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        
        dispatch_source_set_event_handler(self.timer, ^{
            
            [self onSecond];
        });
        
        dispatch_resume(self.timer);
    }
}
@end


@implementation BaseThreadPool

- (instancetype) init {
    
    if (self = [super init]) {
        
        _concurrencyQueue = [[NSOperationQueue alloc] init];
        _concurrencyQueue.maxConcurrentOperationCount = FPConfig.MAX_THREAD_COUNT;
    }
    
    return self;
}

- (void) executeOperation:(NSOperation *)operation andQueue:(NSOperationQueue *)queue {
    
    if (queue != nil) {
        
        [queue addOperation:operation];
    } else {
        
        [_concurrencyQueue addOperation:operation];
    }
}

@end
