//
//  ViewController.m
//  singleClientConcurrentTest
//
//  Created by 施王兴 on 2017/12/28.
//  Copyright © 2017年 施王兴. All rights reserved.
//

#import "Tester.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Tester* test = [[Tester alloc] initWithClient:@"35.167.185.139:13011"];
    [Tester showSignDesc];
    [test testWithThreadCount:10 andThreadQuestCount:30000];
    [test testWithThreadCount:20 andThreadQuestCount:30000];
    [test testWithThreadCount:30 andThreadQuestCount:30000];
    [test testWithThreadCount:40 andThreadQuestCount:30000];
    [test testWithThreadCount:50 andThreadQuestCount:30000];
    [test testWithThreadCount:60 andThreadQuestCount:30000];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
