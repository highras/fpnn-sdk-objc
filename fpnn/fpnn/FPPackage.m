//
//  FPPackage.m
//  fpnn
//
//  Created by dixun on 2018/5/30.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "FPPackage.h"
#import "FPData.h"
#import "FPConfig.h"

@interface FPPackage() {
    
}
@end


@implementation FPPackage

- (NSString *) getKey:(FPData *)data {
    
    return [@"FPNN_" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)data.seq]];
}

- (BOOL) isHttp:(FPData *) data {
    
    NSData * magic = [[NSData alloc] initWithBytes:data.magic length:4];
    NSData * http_magic = [[NSData alloc] initWithBytes:FPConfig.HTTP_MAGIC length:4];
    
    return [http_magic isEqualToData:magic];
}

- (BOOL) isTcp:(FPData *) data {
    
    NSData * magic = [[NSData alloc] initWithBytes:data.magic length:4];
    NSData * http_magic = [[NSData alloc] initWithBytes:FPConfig.TCP_MAGIC length:4];
    
    return [http_magic isEqualToData:magic];
}

- (BOOL) isMsgPack:(FPData *) data {
    
    return 0x1 == data.flag;
}

- (BOOL) isJson:(FPData *) data {
    
    return 0x0 == data.flag;
}

- (BOOL) isOneWay:(FPData *) data {
    
    return 0x0 == data.mtype;
}

- (BOOL) isTwoWay:(FPData *) data {
    
    return 0x1 == data.mtype;
}

- (BOOL) isQuest:(FPData *) data {
    
    return [self isOneWay:data] || [self isTwoWay:data];
}

- (BOOL) isAnswer:(FPData *) data {
    
    return 0x2 == data.mtype;
}

- (BOOL) isSupportPack:(FPData *) data {
    
    return [self isMsgPack:data] != [self isJson:data];
}

- (BOOL) checkVersion:(FPData *) data {
    
    if (data.version < 0 || data.version >= 2) {
        
        return NO;
    }

    return YES;
}

- (NSData *) enCode:(FPData *)data {
    
    NSData * buf = nil;
    
    if ([self isOneWay:data]) {
        
        buf = [self enCodeOneway:data];
    }
    
    if ([self isTwoWay:data]) {
        
        buf = [self enCodeTwoway:data];
    }
    
    if ([self isAnswer:data]) {
        
        buf = [self enCodeAnswer:data];
    }
    
    return buf;
}

- (NSData *) enCodeOneway:(FPData *)data {
    
    NSInteger size = 12 + data.ss + data.psize;
    NSMutableData * buf = [self buildHeader:data andSize:size];
    
    [self writeByte:data.ss toBuffer:buf];
    [self writeUInt32:(uint32_t)data.psize toBuffer:buf];
    [self writeString:data.method toBuffer:buf];
    
    if ([self isJson:data]) {
        
        [self writeString:data.json toBuffer:buf];
    }
    
    if ([self isMsgPack:data]) {

        [self writeBytes:data.msgpack toBuffer:buf];
    }
    
    return buf;
}

- (NSData *) enCodeTwoway:(FPData *)data {
    
    NSInteger size = 16 + data.ss + data.psize;
    NSMutableData * buf = [self buildHeader:data andSize:size];
    
    [self writeByte:data.ss toBuffer:buf];
    [self writeUInt32:(uint32_t)data.psize toBuffer:buf];
    [self writeUInt32:(uint32_t)data.seq toBuffer:buf];
    [self writeString:data.method toBuffer:buf];

    if ([self isJson:data]) {
        
        [self writeString:data.json toBuffer:buf];
    }
    
    if ([self isMsgPack:data]) {
        
        [self writeBytes:data.msgpack toBuffer:buf];
    }
    
    return buf;
}

- (NSData *) enCodeAnswer:(FPData *)data {
    
    NSInteger size = 16 + data.psize;
    NSMutableData * buf = [self buildHeader:data andSize:size];
    
    [self writeByte:data.ss toBuffer:buf];
    [self writeUInt32:(uint32_t)data.psize toBuffer:buf];
    [self writeUInt32:(uint32_t)data.seq toBuffer:buf];

    if ([self isJson:data]) {
        
        [self writeString:data.json toBuffer:buf];
    }
    
    if ([self isMsgPack:data]) {
        
        [self writeBytes:data.msgpack toBuffer:buf];
    }
    
    return buf;
}

- (FPData *) peekHead:(NSData *)bytes {
    
    if (bytes.length < 12) {
        
        return nil;
    }
    
    FPData * peek = [[FPData alloc] init];
    
    NSData * magic = [self readBytes:peek.wpos length:4 fromBuffer:bytes];
    peek.wpos += 4;
    
    peek.magic = (Byte *)[magic bytes];

    char index = 0;
    
    index = [self readByte:peek.wpos fromBuffer:bytes];
    peek.wpos += 1;
    peek.version = (NSInteger)FPConfig.FPNN_VERSION[index];

    index = [self readByte:peek.wpos fromBuffer:bytes];
    peek.wpos += 1;
    
    if (index == FPConfig.FP_FLAG[0]) {
        
        peek.flag = 0;
    }
    
    if (index == FPConfig.FP_FLAG[1]) {
        
        peek.flag = 1;
    }
    
    index = [self readByte:peek.wpos fromBuffer:bytes];
    peek.wpos += 1;
    peek.mtype = (NSInteger)FPConfig.FP_MESSAGE_TYPE[index];

    index = [self readByte:peek.wpos fromBuffer:bytes];
    peek.wpos += 1;
    peek.ss = (NSInteger)index;

    peek.psize = [self readUInt32:peek.wpos fromBuffer:bytes];
    peek.wpos += 4;
    
    
    return peek;
}

- (BOOL) deCode:(FPData *)data {
    
    if ([self isOneWay:data]) {
        
        return [self deCodeOneWay:data];
    }
    
    if ([self isTwoWay:data]) {
        
        return [self deCodeTwoWay:data];
    }
    
    if ([self isAnswer:data]) {

        return [self deCodeAnswer:data];
    }
    
    return NO;
}

- (BOOL) deCodeOneWay:(FPData *)data {
    
    if (data.buffer.length != 12 + data.ss + data.psize) {
        
        return NO;
    }
    
    data.method = [self readString:data.wpos length:data.ss fromBuffer:data.buffer];
    data.wpos += data.ss;
    
    if ([self isJson:data]) {
        
        data.json = [self readString:data.wpos length:data.psize fromBuffer:data.buffer];
    }
    
    if ([self isMsgPack:data]) {
        
        data.msgpack = [self readBytes:data.wpos length:data.psize fromBuffer:data.buffer];
    }
    
    data.wpos += data.ss;
    return YES;
}

- (BOOL) deCodeTwoWay:(FPData *)data {
    
    if (data.buffer.length != 16 + data.ss + data.psize) {
        
        return NO;
    }
    
    data.seq = [self readUInt32:data.wpos fromBuffer:data.buffer];
    data.wpos += 4;
    
    data.method = [self readString:data.wpos length:data.ss fromBuffer:data.buffer];
    data.wpos += data.ss;
    
    if ([self isJson:data]) {
        
        data.json = [self readString:data.wpos length:data.psize fromBuffer:data.buffer];
    }
    
    if ([self isMsgPack:data]) {
        
        data.msgpack = [self readBytes:data.wpos length:data.psize fromBuffer:data.buffer];
    }
    
    data.wpos += data.ss;
    return YES;
}

- (BOOL) deCodeAnswer:(FPData *)data {
    
    if (data.buffer.length != 16 + data.psize) {
        
        return NO;
    }
    
    data.seq = [self readUInt32:data.wpos fromBuffer:data.buffer];
    data.wpos += 4;

    if ([self isJson:data]) {
        
        data.json = [self readString:data.wpos length:data.psize fromBuffer:data.buffer];
    }
    
    if ([self isMsgPack:data]) {
        
        data.msgpack = [self readBytes:data.wpos length:data.psize fromBuffer:data.buffer];
    }
    
    data.wpos += data.ss;
    return YES;
}

- (NSMutableData *) buildHeader:(FPData *)data andSize:(NSInteger)size {
    
    NSMutableData * buf = [[NSMutableData alloc] initWithCapacity:size];
    
    if ([self isHttp:data]) {
       
        NSData * magic = [[NSData alloc] initWithBytes:FPConfig.HTTP_MAGIC length:4];
        [self writeBytes:magic toBuffer:buf];
    }
    
    if ([self isTcp:data]) {
        
        NSData * magic = [[NSData alloc] initWithBytes:FPConfig.TCP_MAGIC length:4];
        [self writeBytes:magic toBuffer:buf];
    }
    
    [self writeByte:FPConfig.FPNN_VERSION[data.version] toBuffer:buf];

    if ([self isJson:data]) {
        
        [self writeByte:FPConfig.FP_FLAG[data.flag] toBuffer:buf];
    }
    
    if ([self isMsgPack:data]) {
        
        [self writeByte:FPConfig.FP_FLAG[data.flag] toBuffer:buf];
    }
    
    [self writeByte:FPConfig.FP_MESSAGE_TYPE[data.mtype] toBuffer:buf];

    return buf;
}

- (void) writeBytes:(NSData *)bytes toBuffer:(NSMutableData *)buffer {
    
    if (bytes.length) {
        
        [buffer appendData:bytes];
    }
}

- (void) writeBytes:(const char*)rawBytes length:(uint32_t)length toBuffer:(NSMutableData *)buffer {
    
    if (length) {
        
        [buffer appendBytes:rawBytes length:length];
    }
}

- (void) writeInt32:(int32_t)value toBuffer:(NSMutableData *)buffer {
    
    [self writeBytes:(const char *)&value length:sizeof(int32_t) toBuffer:buffer];
}

- (void) writeUInt32:(uint32_t)value toBuffer:(NSMutableData *)buffer {
    
    [self writeBytes:(const char *)&value length:sizeof(uint32_t) toBuffer:buffer];
}

- (void) writeByte:(char)byte toBuffer:(NSMutableData *)buffer {
    
    [self writeBytes:(const char *)&byte length:sizeof(char) toBuffer:buffer];
}

- (void) writeString:(NSString *)str toBuffer:(NSMutableData *)buffer {
    
    [self writeBytes:[str dataUsingEncoding:NSUTF8StringEncoding] toBuffer:buffer];
}

- (NSData *) readBytes:(NSInteger)begin length:(NSInteger)len fromBuffer:(NSData *)buffer {
    
    return [buffer subdataWithRange:NSMakeRange(begin, len)];
}

- (int32_t) readInt32:(NSInteger)begin fromBuffer:(NSData *)buffer {
    
    int32_t res;
    [buffer getBytes:&res range:NSMakeRange(begin, sizeof(int32_t))];
    
    return res;
}

- (uint32_t) readUInt32:(NSInteger)begin fromBuffer:(NSData *)buffer {
    
    uint32_t res;
    [buffer getBytes:&res range:NSMakeRange(begin, sizeof(uint32_t))];
    
    return res;
}

- (char) readByte:(NSInteger)begin fromBuffer:(NSData *)buffer {
    
    char res;
    [buffer getBytes:&res range:NSMakeRange(begin, sizeof(char))];
    
    return res;
}

- (NSString *) readString:(NSInteger)begin length:(NSInteger)len fromBuffer:(NSData *)buffer {
    
    NSData * data = [self readBytes:begin length:len fromBuffer:buffer];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
