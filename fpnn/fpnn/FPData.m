//
//  FPData.m
//  fpnn
//
//  Created by dixun on 2018/5/24.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "FPData.h"
#import "FPConfig.h"

@interface FPData() {
    
}
@end

@implementation FPData

- (instancetype)init {
    
    if (self = [super init]) {
        
        _magic = FPConfig.TCP_MAGIC;
        _version = 0x1;
        _flag = 0x1;
        _mtype = 0x1;
        _ss = 0x0;
        _seq = 0x0;
        _psize = 0x0;
        _wpos = 0x0;
        
        _pkglen = 0x0;
        
        _method = nil;
        _json = nil;
        _msgpack = nil;
        
        _buffer = nil;
    }
    
    return self;
}

- (void) setMethod:(NSString *)method {
    
    _method = method;
    
    if (self.method != nil) {
        
        self.ss = (NSInteger)[[self.method dataUsingEncoding:NSUTF8StringEncoding] length];
    }
}

- (void) setMsgpack:(NSData *)msgpack {
    
    _msgpack = msgpack;
    
    if (self.msgpack != nil) {
        
        self.psize = self.msgpack.length;
    }
}

- (void) setJson:(NSString *)json {
    
    _json = json;
    
    if (self.json != nil) {
        
        self.psize = (NSInteger)[[self.json dataUsingEncoding:NSUTF8StringEncoding] length];
    }
}

- (void) setPkglen:(NSInteger)pkglen {
    
    _pkglen = pkglen;
    _buffer = nil;
}
@end
