//
//  FPConfig.m
//  fpnn
//
//  Created by dixun on 2018/5/30.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "FPConfig.h"

@interface FPConfig() {
    
}
@end

static Byte defined_version[2] = {0x0, 0x1};
static Byte defined_flag[2] = {0x40, 0x80};                     // 64: FP_FLAG_JSON, 128: FP_FLAG_MSGPACK
static Byte defined_msg_type[3] = {0x0, 0x1, 0x2};              // 0: FP_MT_ONEWAY, 1: FP_MT_TWOWAY, 2: FP_MT_ANSWER
static Byte defined_tcp_magic[4] = {0x46, 0x50, 0x4e, 0x4e};    // “FPNN”
static Byte defined_http_magic[4] = {0x50, 0x4f, 0x53, 0x54};   // “POST”

@implementation FPConfig

+ (Byte *) FPNN_VERSION {
    
    return defined_version;
}

+ (Byte *) FP_FLAG {
    
    return defined_flag;
}

+ (Byte *) FP_MESSAGE_TYPE {
    
    return defined_msg_type;
}

+ (Byte *) TCP_MAGIC {
    
    return defined_tcp_magic;
}

+ (Byte *) HTTP_MAGIC {

    return defined_http_magic;
}

+ (NSInteger) READ_BUFFER_LEN {
    
    return 12;
}

+ (NSInteger) SEND_TIMEOUT {
    
    return 20 * 1000;
}

+ (NSInteger) MAX_THREAD_COUNT {
    
    return 4;
}

@end
