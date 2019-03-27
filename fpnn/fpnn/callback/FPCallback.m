//
//  FPCallback.m
//  fpnn
//
//  Created by dixun on 2018/5/28.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "FPCallback.h"
#import "CallbackData.h"
#import "FPData.h"
#import "ThreadPool.h"

@interface FPCallback() {

}
@end


@implementation FPCallback

- (instancetype)init {
    
    if (self = [super init]) {

        _cbMap = [[NSMutableDictionary alloc] initWithCapacity:10];
        _exMap = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    return self;
}

- (void) addKey:(NSString *)key andCallback:(CallbackBlock)callback {
    
    @synchronized (self.cbMap) {
        
        [self.cbMap setValue:callback forKey:key];
    }
}

- (void) addKey:(NSString *)key andCallback:(CallbackBlock)callback andTimeout:(NSInteger)timeout {
    
    @synchronized (self.cbMap) {
        
        [self.cbMap setValue:callback forKey:key];
    }
    
    @synchronized (self.exMap) {
        
        NSNumber * expire = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000 + timeout];
        [self.exMap setValue:expire forKey:key];
    }
    
}

- (void) removeAll {
    
    @synchronized (self.cbMap) {
        
        [self.cbMap removeAllObjects];
    }
}

- (void) execKey:(NSString *)key andData:(FPData *)data {
    
    CallbackBlock callback = [self.cbMap objectForKey:key];
    
    @synchronized (self.cbMap) {
        
        [self.cbMap removeObjectForKey:key];
    }

    if (callback != nil) {
        
        NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
            
            callback([[CallbackData alloc] initWithData:data]);
        }];
        
        [[ThreadPool shareInstance] executeOperation:operation andQueue:nil];
    }
}

- (void) execKey:(NSString *)key andError:(NSError *)error {
    
    CallbackBlock callback = [self.cbMap objectForKey:key];

    @synchronized (self.cbMap) {
        
        [self.cbMap removeObjectForKey:key];
    }

    if (callback != nil) {
        
        NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
            
            callback([[CallbackData alloc] initWithError:error]);
        }];
        
        [[ThreadPool shareInstance] executeOperation:operation andQueue:nil];
    }
}

- (void) onSecond:(NSInteger)timestamp {
    
    @synchronized (self.exMap) {
        
        NSMutableArray * keys = [[NSMutableArray alloc] initWithCapacity:0];
        NSEnumerator * keyEnumer = [self.exMap keyEnumerator];
        
        id key = nil;
        
        while (key = [keyEnumer nextObject]) {
            
            NSInteger expire = [[self.exMap objectForKey:key] integerValue];
            
            if (expire > timestamp) {
                
                continue;
            }
            
            [keys addObject:key];
        }
        
        for (id rmkey in keys) {
            
            [self.exMap removeObjectForKey:rmkey];
            
            NSError * error = [NSError errorWithDomain:@"timeout with expire!" code:0 userInfo:nil];
            [self execKey:rmkey andError:error];
        }
    }
}
@end
