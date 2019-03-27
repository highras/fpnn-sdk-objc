//
//  EventData.m
//  fpnn
//
//  Created by dixun on 2018/5/28.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "EventData.h"
#import "FPData.h"

@interface EventData() {
    
}
@end


@implementation EventData

- (instancetype)initWithType:(NSString *)type {
    
    if (self = [super init]) {
        
        _type = type;
    }
    
    return self;
}

- (instancetype)initWithType:(NSString *)type andData:(FPData *)data {
    
    if (self = [super init]) {
        
        _type = type;
        _data = data;
    }
    
    return self;
}

- (instancetype)initWithType:(NSString *)type andError:(NSError *)error {
    
    if (self = [super init]) {
        
        _type = type;
        _error = error;
    }
    
    return self;
}

- (instancetype)initWithType:(NSString *)type andPayload:(NSObject *)payload {
    
    if (self = [super init]) {
        
        _type = type;
        _payload = payload;
    }
    
    return self;
}

- (instancetype)initWithType:(NSString *)type andTimestamp:(NSInteger)timestamp {
    
    if (self = [super init]) {
        
        _type = type;
        _timestamp = timestamp;
    }
    
    return self;
}

- (instancetype)initWithType:(NSString *)type andRetry:(BOOL)retry {
    
    if (self = [super init]) {
        
        _type = type;
        _retry = retry;
    }
    
    return self;
}

@end
