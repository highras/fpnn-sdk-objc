//
//  FPEncryptor.m
//  fpnn
//
//  Created by dixun on 2018/6/12.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "FPEncryptor.h"
#import "FPPackage.h"
#import "FPData.h"
#import "FPConfig.h"

@interface FPEncryptor() {
    
}
@end


@implementation FPEncryptor

- (instancetype)initWithPkg:(FPPackage *)pkg {
    
    if (self = [super init]) {
        
        _pkg = pkg;
    }
    
    return self;
}

- (BOOL) isCrypto {
    
    // TODO
    return NO;
}

- (void) clear {
    
    // TODO
}

- (NSData *) deCode:(NSData *)bytes {
    
    if (self.cryptoed) {
        
        if (self.streamMode) {
            
            return [self streamDecode:bytes];
        }
        
        return [self cryptoDecode:bytes];
    }

    return bytes;
}

- (NSData *) cryptoDecode:(NSData *)bytes {
    
    // TODO
    return bytes;
}

- (NSData *) streamDecode:(NSData *)bytes {
    
    // TODO
    return bytes;
}

- (NSData *) enCode:(NSData *)bytes {
    
    if (self.cryptoed) {
        
        if (self.streamMode) {
            
            return [self streamEncode:bytes];
        }
        
        return [self cryptoEncode:bytes];
    }
    
    return bytes;
}

- (NSData *) cryptoEncode:(NSData *)bytes {
    
    // TODO
    return bytes;
}

- (NSData *) streamEncode:(NSData *)bytes {
    
    // TODO
    return bytes;
}

- (FPData *) peekHead:(NSData *)bytes {
    
    if (self.cryptoed) {
        
        if (self.streamMode) {
            
            return [self streamPeekHead:bytes];
        }
        
        return [self cryptoPeekHead:bytes];
    }
    
    return [self commonPeekHead:bytes];
}

- (FPData *) peekHeadWithData:(FPData *)peek {
    
    // TODO
    if (self.cryptoed) {
        
        FPData * data = [self.pkg peekHead:peek.buffer];
        data.buffer = peek.buffer;
        
        return data;
    }
    
    return peek;
}

- (FPData *) cryptoPeekHead:(NSData *)bytes {
    
    // TODO
    return nil;
}

- (FPData *) streamPeekHead:(NSData *)bytes {
    
    // TODO
    return nil;
}

- (BOOL) checkHead:(FPData *)data {
    
    if (![self.pkg isTcp:data] && ![self.pkg isHttp:data]) {
        
        return NO;
    }
    
    if (data.version < 0x0 || data.version >= sizeof(FPConfig.FPNN_VERSION)) {
        
        return NO;
    }
    
    if (![self.pkg checkVersion:data]) {
        
        return NO;
    }
    
    if (![self.pkg isMsgPack:data] && ![self.pkg isJson:data]) {
        
        return NO;
    }
    
    if (![self.pkg isOneWay:data] && ![self.pkg isTwoWay:data] && ![self.pkg isAnswer:data]) {
        
        return NO;
    }
    
    return YES;
}

- (FPData *) commonPeekHead:(NSData *)bytes {
    
    if (bytes.length >= 12) {
        
        FPData * data = [self.pkg peekHead:bytes];
        
        if (![self checkHead:data]) {
            
            return nil;
        }
        
        if ([self.pkg isOneWay:data]) {
            
            data.pkglen = 12 + data.ss + data.psize;
        }
        
        if ([self.pkg isTwoWay:data]) {
            
            data.pkglen = 16 + data.ss + data.psize;
        }
        
        if ([self.pkg isAnswer:data]) {
            
            data.pkglen = 16 + data.psize;
        }
        
        data.buffer = bytes;
        return data;
        
    }
    
    return nil;
}
@end
