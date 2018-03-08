//
//  Tester.h
//  asyncStressClient-MacOS
//
//  Created by 施王兴 on 2017/12/29.
//  Copyright © 2017年 施王兴. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tester : NSObject

@property (strong, nonatomic) NSString* endpoint;
@property (nonatomic) int clientCount;
@property (nonatomic) int totalQPS;

- (void)launch;
- (void)showStatistics;

@end
