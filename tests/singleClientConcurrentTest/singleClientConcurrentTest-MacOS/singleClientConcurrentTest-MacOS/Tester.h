//
//  Tester.h
//  singleClientConcurrentTest-MacOS
//
//  Created by 施王兴 on 2017/12/29.
//  Copyright © 2017年 施王兴. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tester : NSObject

+ (void)showSignDesc;

- (instancetype)initWithClient:(NSString*)endpoint;

- (void)testWithThreadCount:(int)threadCount andThreadQuestCount:(int)questCount;

@end
