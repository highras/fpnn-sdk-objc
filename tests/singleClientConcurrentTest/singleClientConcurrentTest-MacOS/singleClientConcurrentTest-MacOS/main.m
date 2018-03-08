//
//  main.m
//  singleClientConcurrentTest-MacOS
//
//  Created by 施王兴 on 2017/12/29.
//  Copyright © 2017年 施王兴. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tester.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        Tester* test = [[Tester alloc] initWithClient:@"35.167.185.139:13011"];
        [Tester showSignDesc];
        [test testWithThreadCount:10 andThreadQuestCount:30000];
        [test testWithThreadCount:20 andThreadQuestCount:30000];
        [test testWithThreadCount:30 andThreadQuestCount:30000];
        [test testWithThreadCount:40 andThreadQuestCount:30000];
        [test testWithThreadCount:50 andThreadQuestCount:30000];
        [test testWithThreadCount:60 andThreadQuestCount:30000];
    }
    return 0;
}
