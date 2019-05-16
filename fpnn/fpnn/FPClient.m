//
//  FPClient.m
//  fpnn
//
//  Created by dixun on 2018/5/22.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "FPClient.h"
#import "FPSocket.h"
#import "FPPackage.h"
#import "FPProcessor.h"
#import "EventData.h"
#import "FPData.h"
#import "encryptor/FPEncryptor.h"
#import "gcd/ThreadPool.h"

@interface FPClient() {
    
}
@end

@implementation FPClient

- (instancetype)init {
    
    if (self = [super init]) {
        
        _seq = 0;
        _timeout = 30 * 1000;

        _pkg = [[FPPackage alloc] init];
        _cyr = [[FPEncryptor alloc] initWithPkg:self.pkg];
        _psr = [[FPProcessor alloc] init];
        _event = [[FPEvent alloc] init];
        _callback = [[FPCallback alloc] init];
        _buffer = [[NSMutableData alloc] initWithCapacity:12];
    }
    
    return self;
}

- (void) initWithEndpoint:(NSString *)endpoint andReconnect:(BOOL)reconnect andTimeout:(NSInteger)timeout {
    
    NSArray * ipport = [endpoint componentsSeparatedByString:@":"];
    [self initWithHost:(NSString *)ipport[0] andPort:[ipport[1] integerValue] andReconnect:reconnect andTimeout:timeout];
}

- (void) initWithHost:(NSString *)host andPort:(NSInteger)port andReconnect:(BOOL)reconnect andTimeout:(NSInteger)timeout {
    
    if (timeout > 0) {
        
        _timeout = timeout;
    }
    
    _reconnect = reconnect;
    
    __weak typeof(self) weakSelf = self;
    _secondBlock = ^(EventData * evd) {
        
        [weakSelf onSecond:evd.timestamp];
    };
    
    [[ThreadPool shareInstance].event addType:@"second" andListener:self.secondBlock];
    
    OnRecvBlock block = ^(NSData * chunk) {
        
        [self onData:chunk];
    };
    
    _sock = [[FPSocket alloc] initWithBlock:block andHost:host andPort:port andTimeout:self.timeout];

    [self.sock.event addType:@"connect" andListener:^(EventData * evd) {
        
        [self onConnect];
    }];
    
    [self.sock.event addType:@"close" andListener:^(EventData * evd) {
        
        [self onClose];
    }];
    
    [self.sock.event addType:@"error" andListener:^(EventData * evd) {
        
        [self onError:evd.error];
    }];
}

- (BOOL) isOpen {
    
    if (self.sock != nil) {
        
        return [self.sock isOpen];
    }
    
    return NO;
}

- (BOOL) hasConnect {
    
    if (self.sock != nil) {
        
        return [self.sock isOpen] || [self.sock isConnecting];
    }
    
    return NO;
}

- (void) connect {
    
    [self.sock open];
}

- (void) close {
    
    [self.sock closeWithError:nil];
}

- (void) destroy {
    
    _reconnect = false;
    
    [self.event removeAll];

    [self.psr destroy];
    [self.sock destroy];
    
    [self onClose];

    if (self.secondBlock != nil) {

        [[ThreadPool shareInstance].event removeType:@"second" andListener:self.secondBlock];
        _secondBlock = nil;
    }
}

- (void) closeWithError:(NSError *)error {
    
    [self.sock closeWithError:error];
}

- (void) sendQuest:(FPData *)data {
    
    [self sendQuest:data andBlock:nil andTimeout:0];
}

- (void) sendQuest:(FPData *)data andBlock:(CallbackBlock)block {
    
    [self sendQuest:data andBlock:block andTimeout:0];
}

- (void) sendQuest:(FPData *)data andBlock:(CallbackBlock)block andTimeout:(NSInteger)timeout {
    
    if (data.seq == 0) {
        
        data.seq = [self addSeq];
    }
    
    NSData * buf = [self.pkg enCode:data];
    buf = [self.cyr enCode:buf];
    
    if (block != nil) {
        
        [self.callback addKey:[self.pkg getKey:data] andCallback:block andTimeout:timeout];
    }
    
    if (buf != nil) {
        
        [self.sock writeWithBuffer:buf];
    }
}

- (void) sendNotify:(FPData *)data {
    
    if (data.mtype != 0x0) {
        
        data.mtype = 0x0;
    }
    
    NSData * buf = [self.pkg enCode:data];
    buf = [self.cyr enCode:buf];
    
    if (buf != nil) {
        
        [self.sock writeWithBuffer:buf];
    }
}

- (NSInteger) addSeq {
    
    [[NSBlockOperation blockOperationWithBlock:^{
        
        self->_seq++;
    }] start];
    
    return self.seq;
}

- (void) onData:(NSData *)chunk {
    
    @synchronized (self.buffer) {

        [self.buffer appendData:chunk];
        self.wpos += chunk.length;
    }

    [self readPeekData];
}

- (void) readPeekData {
    
    if (self.wpos == 12) {
        
        self.peekData = [self.cyr peekHead:self.buffer];
        
        if (self.peekData == nil) {
            
            NSError * error = [NSError errorWithDomain:@"worng package head!" code:0 userInfo:nil];
            [self.sock closeWithError:error];
            return;
        }
    }
    
    if (self.wpos == self.peekData.pkglen) {
        
        NSRange range = NSMakeRange(0, self.peekData.pkglen);
        self.peekData.buffer = [self.buffer subdataWithRange:range];

        @synchronized (self.buffer) {
            
            self.wpos = 0;
            
            [self.buffer resetBytesInRange:NSMakeRange(0, 12)];
            [self.buffer setLength:0];
        }
        
        [self.sock readToLength:12];

        self.peekData.buffer = [self.cyr deCode:self.peekData.buffer];
        
        if (![self.pkg deCode:self.peekData]) {
            
            NSError * error = [NSError errorWithDomain:@"worng package body!" code:0 userInfo:nil];
            [self.sock closeWithError:error];
            return;
        }

        if ([self.pkg isAnswer:self.peekData]) {

            NSString * cbkey = [self.pkg getKey:self.peekData];
            [self.callback execKey:cbkey andData:self.peekData];
        }
        
        if ([self.pkg isQuest:self.peekData]) {
            
            [self pushService:self.peekData];
        }
        
        self.peekData = nil;
    } else {
        
        [self.sock readToLength:self.peekData.pkglen - self.wpos];
    }
}

- (void) pushService:(FPData *)quest {
    
    AnswerBlock answer = ^(NSObject * payload, BOOL error) {
        
        FPData * data = [[FPData alloc] init];
        data.flag = quest.flag;
        data.mtype = 0x2;
        data.seq = quest.seq;
        data.ss = error ? 0x1 : 0x0;
        
        if ([self.pkg isJson:data]) {
            
            data.json = (NSString *)payload;
        }
        
        if ([self.pkg isMsgPack:data]) {
            
            data.msgpack = (NSData *)payload;
        }
        
        [self sendQuest:data];
    };
    
    [self.psr service:quest andAnswer:answer];
}

- (void) onSecond:(NSInteger)timestamp {
    
    [self.event fireEvent:[[EventData alloc] initWithType:@"second" andTimestamp:timestamp]];
    
    [self.psr onSecond:timestamp];
    [self.callback onSecond:timestamp];
    
    if ([self hasConnect]) {
        
        [self.sock onSecond:timestamp];
    }
}

- (void) onConnect {
    
    [self.sock readToLength:12];
    [self.event fireEvent:[[EventData alloc] initWithType:@"connect"]];
}

- (void) onClose {
    
    _seq = 0;
    _wpos = 0;
    _peekData = nil;

    [self.buffer resetBytesInRange:NSMakeRange(0, self.buffer.length)];
    [self.buffer setLength:0];

    [self.callback removeAll];

    [self.cyr clear];
    [self.event fireEvent:[[EventData alloc] initWithType:@"close"]];

    if (self.reconnect) {

        [self reConnect];
    }
}

- (void) onError:(NSError *)error {
    
    [self.event fireEvent:[[EventData alloc] initWithType:@"error" andError:error]];
}

- (void) reConnect {
    
    if ([self hasConnect]) {
        
        return;
    }

    if ([self.cyr isCrypto]) {
        
        // TODO connect with encrypto
        [self connect];
        return;
    }
    
    [self connect];
}
@end
