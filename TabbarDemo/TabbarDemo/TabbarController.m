//
//  TabbarController.m
//  TabbarDemo
//
//  Created by jade on 2018/10/22.
//  Copyright © 2018年 Jade. All rights reserved.
//

#import "TabbarController.h"
#import "ViewController.h"
#import "TabbarModel.h"
#import <AFNetworking.h>
#import "UIImageView+WebCache.h"

@interface TabbarController ()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation TabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self networkMethod];
}

- (void)networkMethod {
    NSString *url = @"";// 自定义url
    NSDictionary *parm = @{}; // 自定义参数
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager POST:url parameters:parm progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.dataArr = [NSMutableArray array];
        if ([responseObject[@"state"] integerValue]==1) {
            self.dataArr = responseObject[@"data"];
        } else {
            self.dataArr = [self.dataSource mutableCopy];
        }
        [self setupUI];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.dataArr = [self.dataSource mutableCopy];
        [self setupUI];
    }];
}

- (void)setupUI {
    NSMutableArray *VCArr = [NSMutableArray array];
    for (id item in self.dataArr) {
        if ([item isKindOfClass:[TabbarModel class]]) {
            TabbarModel *model = item;
            NSDictionary *dic = [model getDic];
            Class vcClass = dic[@"ClassVC"];
            UIViewController *vc = [[vcClass alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self setTabBarItem:nav.tabBarItem
                          title:dic[@"name"]
                      titleSize:[dic[@"titleSize"] floatValue]
                  titleFontName:dic[@"foneName"]
                  selectedImage:dic[@"selectedImage"]
             selectedTitleColor:dic[@"selectedColor"]
                    normalImage:dic[@"unselectedImage"]
               normalTitleColor:dic[@"unselectedColor"]];
            [VCArr addObject:nav];
            
        } else if ([item isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = item;
            Class vcClass = dic[@"ClassVC"];
            UIViewController *vc = [[vcClass alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self setTabBarItem:nav.tabBarItem
                          title:dic[@"name"]
                      titleSize:[dic[@"titleSize"] floatValue]
                  titleFontName:dic[@"foneName"]
                  selectedImage:dic[@"selectedImage"]
             selectedTitleColor:dic[@"selectedColor"]
                    normalImage:dic[@"unselectedImage"]
               normalTitleColor:dic[@"unselectedColor"]];
            [VCArr addObject:nav];
        }
        
    }
    self.viewControllers = VCArr;
    [self setSelectedIndex:0];
    // 可设置badge值
}

- (void)setTabBarItem:(UITabBarItem *)tabBarItem
                title:(NSString *)title
            titleSize:(CGFloat)titleSize
        titleFontName:(NSString *)titleFontName
        selectedImage:(NSString *)selectedImage
   selectedTitleColor:(UIColor *)selectedTitleColor
          normalImage:(NSString *)unselectedImage
     normalTitleColor:(UIColor *)unselectedTitleColor {
    
    __block UIImage *image1;
    __block UIImage *image2;
    __block UITabBarItem *tabbar = tabBarItem;
    if ([unselectedImage hasPrefix:@"http"]) {
        [self loadImage:unselectedImage complet:^(UIImage *img) {
            image1 = img;
            if ([selectedImage hasPrefix:@"http"]) {
                [self loadImage:selectedImage complet:^(UIImage *img) {
                    image2 = img;
                    tabbar = [tabbar initWithTitle:title image:[image1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[image2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                }];
            } else {
                image2 = [UIImage imageNamed:selectedImage];
                tabbar = [tabbar initWithTitle:title image:[image1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[image2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            }
        }];
    } else {
        image1 = [UIImage imageNamed:unselectedImage];
        if ([selectedImage hasPrefix:@"http"]) {
            [self loadImage:selectedImage complet:^(UIImage *img) {
                image2 = img;
                tabbar = [tabbar initWithTitle:title
                                         image:[image1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                 selectedImage:[image2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            }];
        } else {
            image2 = [UIImage imageNamed:selectedImage];
            tabBarItem = [tabBarItem initWithTitle:title
                                             image:[image1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                     selectedImage:[image2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
    }
    
    // 未选中字体颜色
    [[UITabBarItem appearance] setBadgeTextAttributes:@{NSForegroundColorAttributeName:unselectedTitleColor, NSFontAttributeName:[UIFont fontWithName:titleFontName size:titleSize]} forState:UIControlStateNormal];
    
    // 选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:selectedTitleColor, NSFontAttributeName:[UIFont fontWithName:titleFontName size:titleSize]} forState:UIControlStateSelected];
    
}

// 加载图片
- (void)loadImage:(NSString *)image complet:(void(^)(UIImage *img))complet {
    // 设置图片 获取本地缓存的图片
    UIImage *newImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:image];
    if (newImage != nil) {
        // newImage就是图片 压缩尺寸25*25
        UIImage *newImage1 = [self imageCompressForSize:newImage targetSize:CGSizeMake(25, 25)];
        complet(newImage1);
    } else {
        //下载图片
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:image] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {//下载完成后
                //同上处理
                UIImage *newImage = [self imageCompressForSize:image targetSize:CGSizeMake(25, 25)];
                complet(newImage);
            }
        }];
//        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:image] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//
//        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            if (image) {//下载完成后
//                //同上处理
//                UIImage *newImage = [self imageCompressForSize:image targetSize:CGSizeMake(25, 25)];
//                complet(newImage);
//            }
//        }];
    }
}

//图片压缩色值不变
- (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        } else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (NSArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = @[
        @{
            @"name":@"首页",
            @"titleSize":@"13",
            @"foneName":@"HelveticaNeue",
            @"selectedColor":[UIColor orangeColor],
            @"unselectedColor":[UIColor grayColor],
            @"selectedImage":@"tabbarImg1",
            @"unselectedImage":@"tabbarImg",
            @"ClassVC":ViewController.class,
            @"isNew":@"",
            @"url":@"",
            },
        @{
            @"name":@"常见问题",
            @"titleSize":@"13",
            @"foneName":@"HelveticaNeue",
            @"selectedColor":[UIColor orangeColor],
            @"unselectedColor":[UIColor grayColor],
            @"selectedImage":@"tabbarImg1",
            @"unselectedImage":@"tabbarImg",
            @"ClassVC":ViewController.class,
            @"isNew":@"",
            @"url":@"",
            },
        @{
            @"name":@"发现",
            @"titleSize":@"13",
            @"foneName":@"HelveticaNeue",
            @"selectedColor":[UIColor orangeColor],
            @"unselectedColor":[UIColor grayColor],
            @"selectedImage":@"tabbarImg1",
            @"unselectedImage":@"tabbarImg",
            @"ClassVC":ViewController.class,
            @"isNew":@"",
            @"url":@"",
            },
        @{
            @"name":@"我的",
            @"titleSize":@"13",
            @"foneName":@"HelveticaNeue",
            @"selectedColor":[UIColor orangeColor],
            @"unselectedColor":[UIColor grayColor],
            @"selectedImage":@"tabbarImg1",
            @"unselectedImage":@"tabbarImg",
            @"ClassVC":ViewController.class,
            @"isNew":@"",
            @"url":@"",
            }];
    }
    
    return _dataSource;
}
@end
