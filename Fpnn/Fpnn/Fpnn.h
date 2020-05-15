//
//  Fpnn.h
//  Fpnn
//
//  Created by 张世良 on 2019/11/19.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import <Foundation/Foundation.h>

// 1.在TARGETS->Build Settings->Other Linker Flags （选中ALL视图）中添加-ObjC，字母O和C大写，符号“-”请勿忽略
// 2.静态库中采用Objective-C++实现，因此需要您保证您工程中至少有一个.mm后缀的源文件(您可以将任意一个.m后缀的文件改名为.mm)

#import <Fpnn/FPNNTCPClient.h>
#import <Fpnn/FPNNQuest.h>
#import <Fpnn/FPNNAnswer.h>
#import <Fpnn/FPNNAsyncAnswer.h>
#import <Fpnn/FPNNProtocol.h>
#import <Fpnn/FPNNErrorCode.h>
#import <Fpnn/FPNError.h>

//! Project version number for Fpnn.
FOUNDATION_EXPORT double FpnnVersionNumber;

//! Project version string for Fpnn.
FOUNDATION_EXPORT const unsigned char FpnnVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Fpnn/PublicHeader.h>


