//
//  ViewController.m
//  oneWayDuplex
//
//  Created by 施王兴 on 2018/1/2.
//  Copyright © 2018年 施王兴. All rights reserved.
//

#import "Example.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [Example example:@"35.167.185.139:13011"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
