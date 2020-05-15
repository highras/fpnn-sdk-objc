//
//  FPNNQuest.h
//  Fpnn
//
//  Created by zsl on 2019/11/22.
//  Copyright © 2019 FunPlus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FPNNQuest : NSObject
@property(nonatomic,readonly,assign)BOOL twoWay;
@property(nonatomic,strong)NSDictionary * message;
@property(nonatomic,readonly,strong)NSString * method;

- (instancetype _Nullable)initWithMethod:(NSString * _Nonnull)method twoWay:(BOOL)isTwoWay;
- (instancetype _Nullable)initWithMethod:(NSString * _Nonnull)method message:(NSDictionary * _Nullable)message twoWay:(BOOL)isTwoWay;
+ (instancetype _Nullable)questWithMethod:(NSString * _Nonnull)method twoWay:(BOOL)isTwoWay;
+ (instancetype _Nullable)questWithMethod:(NSString * _Nonnull)method message:(NSDictionary * _Nullable)message twoWay:(BOOL)isTwoWay;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

