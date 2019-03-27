//
//  ViewController.m
//  test
//
//  Created by dixun on 2018/5/22.
//  Copyright © 2018年 funplus. All rights reserved.
//

#import "ViewController.h"
#import "TestCase.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TestCase * test = [[TestCase alloc] init];
    [test beginTest];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
