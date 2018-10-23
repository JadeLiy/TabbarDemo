//
//  TabbarModel.h
//  TabbarDemo
//
//  Created by jade on 2018/10/22.
//  Copyright © 2018年 Jade. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TabbarModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *clickimg;
- (instancetype)initWithDic:(NSDictionary *)dic;
- (NSDictionary *)getDic;
@end

NS_ASSUME_NONNULL_END
