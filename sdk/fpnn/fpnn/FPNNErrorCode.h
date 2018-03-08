//
//  FPNNErrorCode.h
//  fpnn
//
//  Created by 施王兴 on 2018/1/12.
//  Copyright © 2018年 FunPlus. All rights reserved.
//

#ifndef FPNNErrorCode_h
#define FPNNErrorCode_h

enum {
    FPNN_EC_OK                            = 0,
    
    //for proto
    FPNN_EC_PROTO_UNKNOWN_ERROR        = 10001,
    FPNN_EC_PROTO_NOT_SUPPORTED,
    FPNN_EC_PROTO_INVALID_PACKAGE,
    FPNN_EC_PROTO_JSON_CONVERT,
    FPNN_EC_PROTO_STRING_KEY,
    FPNN_EC_PROTO_MAP_VALUE,
    FPNN_EC_PROTO_METHOD_TYPE,
    FPNN_EC_PROTO_PROTO_TYPE,
    FPNN_EC_PROTO_KEY_NOT_FOUND,
    FPNN_EC_PROTO_TYPE_CONVERT,
    FPNN_EC_PROTO_FILE_SIGN,
    
    //for core
    FPNN_EC_CORE_UNKNOWN_ERROR            = 20001,
    FPNN_EC_CORE_CONNECTION_CLOSED,
    FPNN_EC_CORE_TIMEOUT,
    FPNN_EC_CORE_UNKNOWN_METHOD,
    FPNN_EC_CORE_ENCODING,
    FPNN_EC_CORE_DECODING,
    FPNN_EC_CORE_SEND_ERROR,
    FPNN_EC_CORE_RECV_ERROR,
    FPNN_EC_CORE_INVALID_PACKAGE,
    FPNN_EC_CORE_HTTP_ERROR,
    FPNN_EC_CORE_WORK_QUEUE_FULL,
    FPNN_EC_CORE_INVALID_CONNECTION,
    FPNN_EC_CORE_FORBIDDEN,
    
    //for other
    FPNN_EC_ZIP_COMPRESS                = 30001,
    FPNN_EC_ZIP_DECOMPRESS,
};

#endif /* FPNNErrorCode_h */
