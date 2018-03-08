//
//  ViewController.m
//  asyncStressClient
//
//  Created by 施王兴 on 2017/11/24.
//  Copyright © 2017年 施王兴. All rights reserved.
//

#import "../Tester.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Tester* tester = [[Tester alloc] init];
    tester.endpoint = @"35.167.185.139:13011";
    [tester launch];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
