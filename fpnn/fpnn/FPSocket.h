//
//  FPSocket.h
//  fpnn
//
//  Created by dixun on 2018/5/22.
//  Copyright © 2018年 funplus. All rights reserved.
//

#ifndef FPSocket_h
#define FPSocket_h

#import <Foundation/Foundation.h>
#import "gcd/GCDAsyncSocket.h"

@class FPEvent;

typedef void(^OnRecvBlock)(NSData * chunk);

@interface FPSocket : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic, readwrite, strong) dispatch_queue_t queue;

@property(nonatomic, readonly, assign) NSInteger port;
@property(nonatomic, readonly, strong) NSString * host;
@property(nonatomic, readonly, assign) NSInteger timeout;
@property(nonatomic, readwrite, assign) NSInteger expire;

@property(nonatomic, readwrite, assign) BOOL isClosed;
@property(nonatomic, readwrite, assign) BOOL isConnectionPending;

@property(nonatomic, readonly, strong) OnRecvBlock recvBlock;
@property(nonatomic, readonly, strong) FPEvent * event;
@property (nonatomic, readonly, strong) GCDAsyncSocket * socket;

- (instancetype)initWithBlock:(OnRecvBlock)block andHost:(NSString *)host andPort:(NSInteger)port andTimeout:(NSInteger)timeout;

- (void) open;
- (void) destroy;
- (void) closeWithError:(NSError *)error;
- (void) writeWithBuffer:(NSData *)buffer;
- (void) onSecond:(NSInteger)timestamp;
- (void) readNextData;
- (void) readToLength:(NSInteger)length;

- (BOOL) isOpen;
- (BOOL) isConnecting;
@end

#endif /* FPSocket_h */
