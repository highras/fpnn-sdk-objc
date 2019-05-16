//
//  FPEvent.m
//  fpnn
//
//  Created by dixun on 2018/5/25.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "FPEvent.h"
#import "EventData.h"
#import "ThreadPool.h"

@interface FPEvent() {
    
}
@end


@implementation FPEvent

- (instancetype)init {
    
    if (self = [super init]) {
        
        _listeners = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    return self;
}

- (void) addType:(NSString *)type andListener:(EventBlock)listener {

    @synchronized (self.listeners) {
        
        NSArray * keys = [self.listeners allKeys];
        
        if (![keys containsObject:type]) {
            
            [self.listeners setValue:[[NSMutableArray alloc] initWithCapacity:1] forKey:type];
        }
        
        [[self.listeners objectForKey:type] addObject:listener];
    }
}

- (void) fireEvent:(EventData *)evd {

    NSMutableArray * queue = [self.listeners objectForKey:evd.type];
    
    if (queue.count > 0) {
        
        @synchronized (queue) {
            
            for (EventBlock listener in queue) {
                
                NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
                
                    listener(evd);
                }];
            
                [[ThreadPool shareInstance] executeOperation:operation andQueue:nil];
            }
        }
    }
}

- (void) removeAll {
    
    @synchronized (self.listeners) {
        
        [self.listeners removeAllObjects];
    }
}

- (void) removeType:(NSString *)type {
    
    @synchronized (self.listeners) {
        
        [self.listeners removeObjectForKey:type];
    }
}

- (void) removeType:(NSString *)type andListener:(EventBlock)listener {
    
    NSMutableArray * queue = [self.listeners objectForKey:type];
    NSInteger index = [queue indexOfObject:listener];
    
    if (index != -1) {
        
        [queue removeObjectAtIndex:index];
    }
}
@end
