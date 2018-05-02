//
//  CustomNavigationController.m
//  000-Chat
//
//  Created by 李晓东 on 2018/5/2.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "CustomNavigationController.h"
#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController:viewController animated:animated];
    //替换掉leftBarButtonItem
    if (viewController.navigationItem.leftBarButtonItem== nil && [self.viewControllers count] > 1) {
        viewController.navigationItem.leftBarButtonItem =[self customLeftBackButton];
    }
}

#pragma mark - 自定义返回按钮图片
-(UIBarButtonItem*)customLeftBackButton{
    
    UIImage *image = [UIImage imageNamed:@"nav_back"];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize navSize = self.navigationBar.bounds.size;
    backButton.frame = CGRectMake(0, 0, navSize.height / 2, navSize.height / 2);
    
    [backButton setBackgroundImage:image
                          forState:UIControlStateNormal];
    
    [backButton addTarget:self
                   action:@selector(popself)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    Autorelease(backItem);
    
    return backItem;
}

#pragma mark - 返回按钮事件(pop)
-(void)popself
{
    [self popViewControllerAnimated:YES];
}

+ (void)initialize{
    //取出设置主题的对象
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    //设置导航栏的背景图片
    NSString *navBarBg = nil;
    if (iOS7)
    {
        navBarBg = @"nav_color";
        navBar.tintColor = [UIColor whiteColor];
    }
    else
    {
        navBarBg = @"nav_color";
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    [navBar setBackgroundImage:[UIImage imageNamed:navBarBg] forBarMetrics:UIBarMetricsDefault];
    
    //标题颜色
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

}
@end
