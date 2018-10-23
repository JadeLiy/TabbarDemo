//
//  TabbarModel.m
//  TabbarDemo
//
//  Created by jade on 2018/10/22.
//  Copyright © 2018年 Jade. All rights reserved.
//

#import "TabbarModel.h"
#import "ViewController.h"
@implementation TabbarModel
- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        self.name = dic[@"name"];
        self.type = dic[@"type"];
        self.img = dic[@"img"];
        self.clickimg = dic[@"clickimg"];
    }
    return self;
}

- (NSDictionary *)getDic {
    return @{
             @"name":self.name,
             @"titleSize":@"13",
             @"foneName":@"HelveticaNeue",
             @"selectedColor":[UIColor orangeColor],
             @"unselectedColor":[UIColor grayColor],
             @"selectedImage":self.img,
             @"unselectedImage":self.clickimg,
             @"ClassVC":ViewController.class,
             };
}
@end
