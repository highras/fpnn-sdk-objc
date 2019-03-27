//
//  FPSocket.m
//  fpnn
//
//  Created by dixun on 2018/5/22.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "FPSocket.h"
#import "FPEvent.h"
#import "EventData.h"

@interface FPSocket() {
    
}
@end


@implementation FPSocket

- (instancetype)initWithBlock:(OnRecvBlock)block andHost:(NSString *)host andPort:(NSInteger)port andTimeout:(NSInteger)timeout {
    
    if (self = [super init]) {
        
        _expire = 0;
        
        _host = host;
        _port = port;
        _timeout = timeout;

        _recvBlock = block;
        _event = [[FPEvent alloc] init];
        
        _queue = dispatch_queue_create("delegate_serial_queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (BOOL) isOpen {
    
    if (self.socket != nil) {
        
        return self.socket.isConnected;
    }
    
    return NO;
}

- (BOOL) isConnecting {
    
    return self.isConnectionPending;
}

- (void) open {
   
    if (self.socket != nil && !self.socket.isDisconnected) {
       
        [self onError:[NSError errorWithDomain:@"has been connect!" code:0 userInfo:nil]];
        return;
    }
    
    self.isConnectionPending = YES;
    self.isClosed = NO;
    
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.queue];
    _socket.IPv4PreferredOverIPv6 = NO; // 设置支持IPV6
    
    NSError * error = nil;
    
    if (![self.socket connectToHost:self.host onPort:self.port withTimeout:self.timeout error:&error]) {
        
        [self onClose:error];
        return;
    }
    
    if (self.timeout > 0) {
        
        NSInteger timestamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
        self.expire = timestamp + self.timeout;
    }
}

- (void) destroy {
    
    _recvBlock = nil;
    [self.event removeAll];
    
    [self closeWithError:nil];
    [self onClose:nil];
}

- (void) writeWithBuffer:(NSData *)buffer {
    
    [self.socket writeData:buffer withTimeout:-1 tag:0];
}

- (void) closeWithError:(NSError *)error {
    
    if (!self.isClosed) {
        
        self.isClosed = YES;
        
        if (error != nil) {
            
            [self onError:error];
        }
        
        [self.socket disconnect];
    }
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    self.isConnectionPending = NO;
    [self onConnect];
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
    
    [self onClose:error];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    [self onData:data];
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
//    NSLog(@"didWriteDataWithTag:%ld", tag);
}

- (void) readNextData {
    
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void) readToLength:(NSInteger)length {
    
    [self.socket readDataToLength:length withTimeout:-1 tag:0];
}

- (void) onError:(NSError *)error {
    
    [self.event fireEvent:[[EventData alloc] initWithType:@"error" andError:error]];
}

- (void) onConnect {
    
    self.expire = 0;
    [self.event fireEvent:[[EventData alloc] initWithType:@"connect"]];
}

- (void) onClose:(NSError *)error {
    
    self.expire = 0;
    self.isConnectionPending = NO;

    if (self.socket != nil) {

        self.socket.delegate = nil;

        _socket = nil;
    }

    if (error != nil) {

        [self onError:error];
    }
    
    [self.event fireEvent:[[EventData alloc] initWithType:@"close"]];
}

- (void) onData:(NSData *)chunk {
    
    if (self.recvBlock != nil) {
        
        self.recvBlock(chunk);
    }
}

- (void) onSecond:(NSInteger)timestamp {
    
    if (self.expire > 0) {
        
        if (timestamp > self.expire) {
            
            [self closeWithError:[NSError errorWithDomain:@"connect time out!" code:0 userInfo:nil]];
        }
    }
}
@end
