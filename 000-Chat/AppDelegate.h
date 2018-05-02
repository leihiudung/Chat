//
//  AppDelegate.h
//  000-Chat
//
//  Created by 李晓东 on 2018/4/25.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPFramework/XMPPFramework.h>
#import "Constant.h"

@protocol LoginRegistDelegate
- (void)login;
@end

@protocol RosterDelegate
- (void)onOrOff:(NSString*)userId isOn:(BOOL) isOn;
- (void)refresh;
@end
@protocol RoomDelegate
- (void)listRooms:(DDXMLElement*) ele;
@end

@protocol ChatDelegate
- (void)didReceiveMessage:(XMPPMessage*) messagePath;
- (NSString *)getCurrentSession;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (nonatomic, strong) nsmud *<##>
@property (nonatomic, strong) XMPPStream *stream;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *rosterStorage;
@property (nonatomic, strong) XMPPRoomCoreDataStorage *roomStorage;
@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) id<LoginRegistDelegate> loginRegistDelegate;
@property (nonatomic, strong) id<RosterDelegate> rosterDelegate;
@property (nonatomic, strong) id<RoomDelegate> roomDelegate;
@property (nonatomic, strong) id<ChatDelegate> chatDelegate;
- (void)connect:(BOOL)isRegist;

@end

