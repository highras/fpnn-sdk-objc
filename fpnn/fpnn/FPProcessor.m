//
//  FPProcessor.m
//  fpnn
//
//  Created by dixun on 2018/5/31.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "FPEvent.h"
#import "EventData.h"
#import "FPData.h"
#import "FPProcessor.h"

@interface FPProcessor() {
    
}
@end


@implementation FPProcessor

- (FPEvent *) getEvent {
    
    if (self.processor != nil) {
        
        return [self.processor getEvent];
    }
    
    return nil;
}

- (void) service:(FPData *)data andAnswer:(AnswerBlock)answer {
    
    if (self.processor == nil) {
        
        self.processor = [[BaseProcessor alloc] initWithEvent: [[FPEvent alloc] init]];
    }
    
    [self.processor service:data andAnswer:answer];
}

- (void) onSecond:(NSInteger)timestamp {
    
    if (self.processor != nil) {
        
        [self.processor onSecond:timestamp];
    }
}

- (void) destroy {
    
    FPEvent * event = [self getEvent];
    
    if (event != nil) {
        
        [event removeAll];
    }
}
@end

@implementation BaseProcessor

- (instancetype)initWithEvent:(FPEvent *)event {
    
    if (self = [super init]) {
       
        _event = event;
    }
    
    return self;
}

- (void) service:(FPData *)data andAnswer:(AnswerBlock)answer {
    
    if (data.flag == 0) {
        
        [self.event fireEvent:[[EventData alloc] initWithType:data.method andPayload:data.json]];
    }
    
    if (data.flag == 1) {
        
        [self.event fireEvent:[[EventData alloc] initWithType:data.method andPayload:data.msgpack]];
    }
}

- (FPEvent *) getEvent {
    
    return self.event;
}

- (void) onSecond:(NSInteger)timestamp {}
@end
