//
//  CallbackData.m
//  fpnn
//
//  Created by dixun on 2018/5/28.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "CallbackData.h"

@interface CallbackData() {
    
}
@end


@implementation CallbackData

- (instancetype)initWithData:(FPData *)data {
    
    if (self = [super init]) {
        
        _data = data;
    }
    
    return self;
}

- (instancetype)initWithError:(NSError *)error {
    
    if (self = [super init]) {
        
        _error = error;
    }
    
    return self;
}

- (instancetype)initWithPayload:(NSObject *)payload {
    
    if (self = [super init]) {
        
        _payload = payload;
    }
    
    return self;
}

- (void) checkError:(NSDictionary *)data andIsAnswerErr:(BOOL)isAnswerErr {
    
    if (self.error == nil) {
        
        if (data == nil) {
            
            _error = [NSError errorWithDomain:@"data is null!" code:0 userInfo:nil];
        }
        
        if (isAnswerErr) {
            
            NSString * code = [data valueForKey:@"code"];
            NSString * ex = [data valueForKey:@"ex"];
            
            if (code != nil || ex != nil) {
                
                NSString * reason = [NSString stringWithFormat:@"code: %@, ex: %@", code, ex];
                _error = [NSError errorWithDomain:reason code:0 userInfo:nil];
            }
        }
    }
    
    if (self.error == nil) {
        
        _payload = data;
    }
    
    _data = nil;
}

@end
