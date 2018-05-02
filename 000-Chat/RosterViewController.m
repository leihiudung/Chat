//
//  RosterViewController.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/25.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "RosterViewController.h"
#import "RosterHeaderView.h"
#import "AppDelegate.h"
#import "ChatViewController.h"

@interface RosterViewController () <UITableViewDataSource, UITableViewDelegate, XMPPRosterDelegate, RosterDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) NSMutableArray *status;

@property (nonatomic, strong) NSMutableArray *onlineArray;
@property (nonatomic, strong) NSMutableArray *offlineArray;
@property (nonatomic, strong) NSMutableArray *tryRosterArray;
@property (nonatomic, strong) AppDelegate *app;
@property (nonatomic, strong) XMPPRoster *roster;
@end

@implementation RosterViewController{
    NSMutableArray *_offlineUsers;
}

- (void)loadView{
    [super loadView];
    self.titleArray = @[@"我的好友", @"离线好友", @"潜在好友"];
    
#ifdef __IPHONE_11_0
    
    if (@available(iOS 11.0, *)) {
        
    } else {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.app.rosterDelegate = self;
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self setupRoster];
    self.status = [NSMutableArray arrayWithArray:@[@NO, @NO, @NO]];
    self.onlineArray = [NSMutableArray array];
    self.offlineArray = [NSMutableArray array];
    self.tryRosterArray = [NSMutableArray array];
    [self.roster fetchRoster];
    
    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back.jpeg"] style:UIBarButtonItemStylePlain target:self action:nil];
    
    
}

// 创建并初始化XMPPRoster
- (void)setupRoster{
    if (self.app.rosterStorage == nil) {
        [self.app setRosterStorage:[[XMPPRosterCoreDataStorage alloc]init]];
        
    }
    
    self.roster = [[XMPPRoster alloc]initWithRosterStorage:self.app.rosterStorage];
    [self.roster activate:self.app.stream];
    [self.roster addDelegate:self delegateQueue:self.app.queue];
    _offlineUsers = [NSMutableArray array];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.titleArray[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = section == 0 ? self.onlineArray.count : (section == 1 ? self.offlineArray.count : self.tryRosterArray.count);
    BOOL flag = [(NSNumber *)self.status[section] boolValue];
    return flag ? rows : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rosterCell"];
    NSMutableArray *array = indexPath.section == 0 ? self.onlineArray : (indexPath.section == 1 ? self.offlineArray : self.tryRosterArray);
    cell.textLabel.text = array[indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    RosterHeaderView *view = [[NSBundle mainBundle]loadNibNamed:@"RosterHeaderView" owner:nil options:nil].lastObject;
    [view.icon setImage:[UIImage imageNamed:([(NSNumber *)self.status[section] boolValue] ? @"zhan.gif" : @"zhe.gif")]];
    [view setTag:section];
    [view.label setText:self.titleArray[section]];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(display:)]];

    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *currentSession = indexPath.section == 0 ? self.onlineArray[indexPath.row] : (indexPath.section == 1 ? self.offlineArray[indexPath.row] : self.tryRosterArray[indexPath.row]);
    ChatViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
    [viewController setCurrentSession:currentSession];
    [self presentViewController:viewController animated:YES completion:nil];
    
}

- (void)display:(UIGestureRecognizer *)recognizer{
    NSInteger section = recognizer.view.tag;

    self.status[section] = [NSNumber numberWithBool:![self.status[section] boolValue]];
    
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:section];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];

}

// 收到好友信息（包括加载好友、添加好友、被对方删除）都激发该方法
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{
    // 获取jid属性获取好友名
    NSString* rosterName = [item attributeStringValueForName:@"jid"];
    NSString* type = [item attributeStringValueForName:@"subscription"];
    NSString* ask = [item attributeStringValueForName:@"ask"];
    // 如果type为remove,且ask==nil，表明主动删除好友
    if ([type isEqualToString:@"remove"] && ask == nil) {
        [self.onlineArray removeObject: rosterName];
        [self.offlineArray removeObject: rosterName];
    }
    // 如果type为remove,且ask==subscribe，表明主动删除尝试添加的好友
    else if ([type isEqualToString:@"remove"] &&
             [ask isEqualToString:@"subscribe"]) {
        [self.tryRosterArray removeObject:rosterName];
    }
    // 如果type为to,且ask==nil，表明为该好友被删除
    if ([type isEqualToString:@"to"] && ask == nil) {
        [self.onlineArray removeObject:rosterName];
        [self.offlineArray removeObject:rosterName];
    }
    // 如果type为none,且ask=="subscribe"，表明为正尝试添加该好友
    else if ([type isEqualToString:@"none"] && ask != nil &&
             [ask isEqualToString:@"subscribe"]) {
        // 避免重复添加
        if (![self.tryRosterArray containsObject:rosterName]) {
            [self.tryRosterArray addObject:rosterName];
        }
    }
    // 如果type为both,且ask==nil，表明为已添加的好友
    if ([type isEqualToString:@"both"] && ask == nil) {
        if ([self.tryRosterArray containsObject:rosterName]
            // 避免重复添加
            && ![self.onlineArray containsObject:rosterName]){
            // 从尝试添加的好友中删除该用户
            [self.tryRosterArray removeObject:rosterName];
            [self.onlineArray addObject:rosterName];
        }
        // 且该用户不是在线用户
        if (![self.onlineArray containsObject:rosterName] &&
            // 避免重复添加
            ![self.offlineArray containsObject:rosterName]){
            [self.offlineArray addObject:rosterName];
        }
    }

}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
//    _offlineUsers = _offlineArray.mutableCopy;
    [self checkOnlineStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
    });
}

- (void)checkOnlineStatus {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *roster in self.offlineArray.copy) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://lixiaodongdemac-mini.local:9090/plugins/presence/status?jid=%@&type=xml", roster]];
        
        NSError *error;
        NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (error == nil) {
            if (![str containsString:@"type=\"unavailable\""]) {
                [self.offlineArray removeObject:roster];
                [self.onlineArray addObject:roster];
                
            }
        } else {
            NSLog(@"error--%@", error);
            
        }
        
    }
    [_offlineUsers removeAllObjects];
    _offlineUsers = self.offlineArray.mutableCopy;
}

- (void)onOrOff:(NSString *)userId isOn:(BOOL)isOn{
    NSMutableString *mutableString = [NSMutableString stringWithString:userId];
    if (![userId containsString:@"@lixiaodongdemac-mini.local"]) {
        [mutableString appendString:@"@lixiaodongdemac-mini.local"];
    }
    if (isOn) {
        if (![self.onlineArray containsObject:mutableString.copy]) {
            [self.onlineArray addObject:mutableString.copy];
            [_offlineUsers removeObject:mutableString.copy];
            if ([self.offlineArray containsObject:mutableString.copy]) {
                [self.offlineArray removeObject:mutableString.copy];
            }
        }
    } else {
        if (![self.offlineArray containsObject:mutableString.copy]) {
            [self.offlineArray addObject:mutableString.copy];
            [_offlineUsers addObject:mutableString.copy];
            if ([self.onlineArray containsObject:mutableString.copy]) {
                [self.onlineArray removeObject:mutableString.copy];
            }
        }
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

// 收到好友请求时激发该方法
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    [self presenceSubscription:presence];
}

- (void)presenceSubscription:(XMPPPresence *)xmppRresence{
    NSString *userName = [xmppRresence from].user;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"TIps" message:[NSString stringWithFormat:@"%@ wannt to be your friend", userName] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 该方法还回再调用- didReceiveRosterItem方法刷新一遍数据
        [_roster acceptPresenceSubscriptionRequestFrom:[xmppRresence from] andAddToRoster:YES];
    }];
    UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"Disagree" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [_roster rejectPresenceSubscriptionRequestFrom:[xmppRresence from]];
        // 说明见下方 A
        [_roster removeUser:[xmppRresence from]];
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:rejectAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
        
    });
}

- (void)refresh{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];

    });
}


- (void)dealloc{
    NSLog(@"done");
}
- (IBAction)btnClick:(id)sender {
}
@end
