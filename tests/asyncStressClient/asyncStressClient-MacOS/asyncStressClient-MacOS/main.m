//
//  main.m
//  asyncStressClient-MacOS
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
        
        Tester* tester = [[Tester alloc] init];
        tester.endpoint = @"35.167.185.139:13011";
        [tester launch];
        
        while (true)
        {
            sleep(3);
        }
    }
    return 0;
}
