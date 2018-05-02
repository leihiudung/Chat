//
//  ChatViewController.h
//  000-Chat
//
//  Created by 李晓东 on 2018/4/26.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface ChatViewController : UIViewController
// 对方的 session;是的
@property (nonatomic, strong) NSString *currentSession;
@property (nonatomic, strong) XMPPRoom *room;
@property (nonatomic, strong) NSString *roomUserSession;
@end
