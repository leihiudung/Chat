//
//  AppDelegate.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/25.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate () <XMPPStreamDelegate>
@property (nonatomic, assign) BOOL *isRegist;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupStream];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupStream{
    _stream = [[XMPPStream alloc]init];
    [_stream addDelegate:self delegateQueue:self.queue];
    [_stream setKeepAliveInterval:30];
    [_stream setEnableBackgroundingOnSocket:YES];
    
    _xmppReconnect = [[XMPPReconnect alloc] initWithDispatchQueue:self.queue];
    [_xmppReconnect setAutoReconnect:YES];
    [_xmppReconnect activate:_stream];
    self.queue = dispatch_get_global_queue(0, 0);
    [_stream addDelegate:self delegateQueue:self.queue];
}

- (void)connect:(BOOL)isRegist {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userKey = [userDefault stringForKey:USER_KEY];
    NSString *serverKey = [userDefault stringForKey:SERVER_KEY];
    self.isRegist = isRegist;
    
    // 下线通知
    if ([_stream isConnected]) {
        [_stream disconnect];
    }
    [_stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@", userKey, HOST_SUFFIX]]];
    [_stream setHostName:serverKey];
    
    NSError *error;
    [_stream connectWithTimeout:2.0 error:&error];
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error{
    NSLog(@"error");
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket{
    NSLog(@"DidConnect");
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"DidTimeout");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *passKey = [userDefault stringForKey:PASS_KEY];
    NSError *error;
    if (self.isRegist) {
        [self.stream registerWithPassword:passKey error:&error];
    } else {
        [self.stream authenticateWithPassword:passKey error:&error];
    }
}

// 获取登录权限成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    XMPPPresence *presence = [XMPPPresence presence];
    [self.stream sendElement:presence];
    [self.loginRegistDelegate login];
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    
}

// 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    XMPPPresence *presence = [XMPPPresence presence];
    [self.stream sendElement:presence];
    [self.loginRegistDelegate login];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    
}

// 收到在线通知
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSString *type = presence.type;
    // 当前用户
    NSString *userId = sender.myJID.user;
    // 获取发送消息的用户
    NSString *presenceFromUser = presence.from.user;
    // 不是当前用户发送的消息 && 不是离开房间的消息
    if (![userId isEqualToString:presenceFromUser] && ![presence.from.domain isEqualToString:ROOM_SUFFIX]) {
        
        if ([type isEqualToString:@"available"]) {
            [_rosterDelegate onOrOff:presence.from.user isOn:YES];
        } else if ([type isEqualToString:@"unavailable"]) {
            [_rosterDelegate onOrOff:presence.from.user isOn:NO];
        }
    }
    
}

// 收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *to = [message attributeStringValueForName:@"to"];
    NSString *from = [message attributeStringValueForName:@"from"];
    NSString *type = [message attributeStringValueForName:@"type"];
    NSXMLElement *element = [message elementForName:@"body"];
    //    [XMPPJID jidWithUser:from domain:HOST_SUFFIX resource:nil];
    // 当用户停留在聊天页面,且收到的信息是正在聊天的对象
    if (self.chatDelegate != nil && [from hasPrefix:[self.chatDelegate getCurrentSession]] && element != nil) {
        [self.chatDelegate didReceiveMessage:message];
    }
    // 这里分两种情况,一是在聊天页面,但不是与收到的信息的对象聊天;二是还没进入聊天页面
    else if ((self.chatDelegate != nil && ![from hasPrefix:[self.chatDelegate getCurrentSession]]) || self.chatDelegate == nil) {
        if ([type isEqualToString:@"chat"] && element != nil) {
//            [self tmpStoreMessage:message from:[XMPPJID jidWithUser:from domain:HOST_SUFFIX resource:nil]];
            [self tmpStoreMessage:message from:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@", from, HOST_SUFFIX]]];
        }
        [self.rosterDelegate refresh];
    }
    
}

// --------------------查询聊天室记录,服务器返回结果--------------------
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    NSString* from = [iq fromStr];  // 获取iq的来源
    NSString* to = [iq to].user;  // 获取iq的发送目标
    NSString* userId = sender.myJID.user;
    // 如果from来自conference.yeeku-pro.local，则表明信息是聊天室信息
    if ([userId isEqualToString:to] && [from isEqualToString:ROOM_SUFFIX]
        && [iq isResultIQ] && [[iq attributeStringValueForName:@"id"]
                               isEqualToString:GET_ROOMS_ID]){
            // 调用roomListDelegate的方法更新房间列表
            [self.roomDelegate listRooms:[iq childElement]];
            
            return YES;
        }
    return NO;
}

// 存储用户还没来得及看的信息
- (void)tmpStoreMessage:(XMPPMessage *)message from:(XMPPJID *)jid{
//    NSString *path = NSTemporaryDirectory();
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", jid.bare]];
    NSString *content = [(DDXMLElement *)[message elementsForName:@"body"].lastObject stringValue];
    NSString *sender = jid.bare;
    // 不是语音时,是 nil
    NSString *audioStr = [[message elementsForName:@"attachment"].lastObject stringValue];
    NSString *audioTimeStr = [[message elementsForName:@"attachment_time"].lastObject stringValue];
    NSDictionary *dict = nil;
    if (audioStr != nil) {
        dict = @{@"sender": sender, @"msg" : content, @"audio" : audioStr, @"audio_time": audioTimeStr};
    } else{
        dict = @{@"sender": sender, @"msg" : content};
    }
    

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
        
    } else {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
    }
  
}

- (void)offline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_stream sendElement:presence];
    
}
@end
// 保存数据到文件的做法
/**
 - (void)tmpStoreMessage:(XMPPMessage *)message from:(XMPPJID *)jid{
 //    NSString *path = NSTemporaryDirectory();
 NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
 NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", jid.bare]];
 NSString *content = [(DDXMLElement *)[message elementsForName:@"body"].lastObject stringValue];
 NSString *sender = jid.bare;
 NSDictionary *dict = @{@"sender": sender, @"msg" : content};
 
 NSFileManager *fileManager = [NSFileManager defaultManager];
 NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
 
 if ([fileManager fileExistsAtPath:filePath]) {
 NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
 [fileHandle seekToEndOfFile];
 [fileHandle writeData:data];
 [fileHandle closeFile];
 
 } else {
 NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
 [fileManager createFileAtPath:filePath contents:data attributes:nil];
 }
 
 
 }
 */
