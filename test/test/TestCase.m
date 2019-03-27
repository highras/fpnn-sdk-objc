//
//  TestCase.m
//  test
//
//  Created by dixun on 2018/5/22.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import <MPMessagePack/MPMessagePack.h>

#import "TestCase.h"
#import "FPClient.h"
#import "ThreadPool.h"
#import "EventData.h"
#import "FPData.h"
#import "CallbackData.h"

@interface TestCase() {
    
}
@end

@implementation TestCase

- (instancetype)init {
    
    if (self = [super init]) {
        
        _client = [[FPClient alloc] init];
    }
    
    return self;
}

- (void) beginTest {
    
    [[ThreadPool shareInstance] startTimerThread];
    
    [self.client initWithHost:@"35.167.185.139" andPort:13013 andReconnect:YES andTimeout:5 * 1000];

    EventBlock listener = ^(EventData * event) {
        
        if ([event.type isEqualToString:@"connect"]) {
            
            [self onConnect];
        } else if ([event.type isEqualToString:@"close"]) {
            
            [self onClose];
        } else if ([event.type isEqualToString:@"error"]) {
            
            [self onError:event.error];
        }
    };
    
    [self.client.event addType:@"connect" andListener:listener];
    [self.client.event addType:@"close" andListener:listener];
    [self.client.event addType:@"error" andListener:listener];
    
    [self.client connect];
}

- (void) onConnect {
    
    NSLog(@"Connected!");
    
    NSDictionary * dict = @{ @"pid": @(1017), @"uid": @(654321), @"what": @"rtmGated", @"addrType": @"ipv4", @"array": @[@(1.1f), @(2.1)] };

    NSError * error = nil;
    NSData * data = [MPMessagePackWriter writeObject:dict error:&error];
    
    if (error != nil) {
        
        NSLog(@"err:");
        [self onError:error];
        return;
    }
    
    FPData * buffer = [[FPData alloc] init];
    buffer.flag = 0x1;
    buffer.mtype = 0x1;
    buffer.method = @"httpDemo";

    buffer.msgpack = data;
    
    [self.client sendQuest:buffer andBlock:^(CallbackData * cbd) {

        NSError * error = nil;
        NSDictionary * dict = [MPMessagePackReader readData:cbd.data.msgpack error:&error];
        
        if (error != nil) {
           
            NSLog(@"err:");
            [self onError:error];
            return;
        }
        
        NSLog(@"%@", dict);
    }];
}

- (void) onClose {
    
    NSLog(@"Closed!");
}

- (void) onError:(NSError *)error {
    
    NSLog(@"Error! Domain: %@, Code: %ld", error.domain, error.code);
}
@end
