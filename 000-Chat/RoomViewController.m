//
//  RoomViewController.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/25.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "RoomViewController.h"
#import "AppDelegate.h"
#import "ChatViewController.h"

@interface RoomViewController () <XMPPRoomDelegate, UITableViewDelegate, UITableViewDataSource, RoomDelegate>
@property (nonatomic, strong) AppDelegate *app;
@property (nonatomic, strong) XMPPRoom *room;
@property (nonatomic, strong) NSMutableArray *roomArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation RoomViewController

- (void)loadView{
    [super loadView];
    self.app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    self.room = [[XMPPRoom alloc]init];
//    [self.room activate:self.app.stream];
//    [self.room addDelegate:self delegateQueue:self.app.queue];
    _roomArray = [NSMutableArray array];
    self.app.roomDelegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"li"];
    [self getRoomList];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.roomArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"li" forIndexPath:indexPath];
    DDXMLNode *node = self.roomArray[indexPath.row];
    cell.textLabel.text = node.stringValue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *chatRoom = _roomArray[indexPath.row];
    DDXMLNode *node = _roomArray[indexPath.row];
    [self joinRoom:node.stringValue];
}

- (void)joinRoom: (NSString *)jid {
    [self addRoom:jid];
}

- (void)addRoom:(NSString *)roomName {
    if (_app.roomStorage == nil) {
        _app.roomStorage = [[XMPPRoomCoreDataStorage alloc]init];
    }
    // ?指谁创建的
    XMPPJID *roomJid = [XMPPJID jidWithString:roomName];
    // 创建一个 聊天室
    _room = [[XMPPRoom alloc]initWithRoomStorage:_app.roomStorage jid:roomJid];
    // 建立聊天室和 xmppStream 的关联
    [_room activate:_app.stream];
    [_room addDelegate:self delegateQueue:_app.queue];
    // 不管新建还是加入已有的聊天室
    [_room joinRoomUsingNickname:_app.stream.myJID.user history:nil];
}

- (void)getRoomList {
    DDXMLElement *iqElement = [DDXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@%@", _app.stream.myJID.user, HOST_SUFFIX]];
    [iqElement addAttributeWithName:@"to" stringValue:ROOM_SUFFIX];
    [iqElement addAttributeWithName:@"id" stringValue:GET_ROOMS_ID];
    
    DDXMLElement *queryElement = [DDXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    [iqElement addChild:queryElement];
    // xmppstream向服务器发起查询聊天室查询,在服务器返回响应时,会调用 xmppstream 的- xmppStream:didReceiveIQ方法
    [_app.stream sendElement:iqElement];
}

- (void)listRooms:(DDXMLElement *)ele{
    NSArray *itemsArray = [ele elementsForName:@"item"];
    for (DDXMLElement *element in itemsArray) {
        [_roomArray addObject:[element attributeForName:@"jid"]];
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"you in");
    dispatch_async(dispatch_get_main_queue(), ^{
        ChatViewController *viewController = (ChatViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
        [viewController setCurrentSession:_room.roomJID.full];
        [viewController setRoomUserSession:_app.stream.myJID.bare];
        [viewController setRoom:self.room];
        [self presentViewController:viewController animated:YES completion:nil];
    });
    
}

@end
