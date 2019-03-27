//
//  TestCase.h
//  test
//
//  Created by dixun on 2018/5/22.
//  Copyright © 2018年 funplus. All rights reserved.
//

#ifndef TestCase_h
#define TestCase_h

#import <Foundation/Foundation.h>

@class FPClient;

@interface TestCase : NSObject

@property(nonatomic, readonly, strong) FPClient * client;

- (instancetype)init;
- (void) beginTest;

@end

#endif /* TestCase_h */
