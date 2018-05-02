//
//  ChatViewController.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/26.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//


#import "ChatViewController.h"
#import "ChatCell.h"
#import "AudioRecordManager.h"
#import "Emoji.h"
#import "EmojiView.h"
#import "NSAttributedString+NSAttributedString.h"
#import "EmojiManager.h"
#import "NSString+EmojiString.h"

#import "_00_Chat-Swift.h"

#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>

#define ScreenWidth self.view.frame.size.width
#define ScreenHeight self.view.frame.size.height

typedef NS_ENUM(NSInteger, ToolBarClickType){
    ContentEnum,
    IconEnum,
    SoundEnum
};

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, ChatDelegate, UITextFieldDelegate, AVAudioPlayerDelegate, EmojiViewDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *totalView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *backImgView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *audioBtn;
@property (weak, nonatomic) IBOutlet UIButton *iconBtn;
@property (weak, nonatomic) IBOutlet UITextView *contentView;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) AudioRecordManager *audioRecordManager;

@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, NSString *> *> *historyMessages;
@property (nonatomic, strong) AppDelegate *app;
@end

@implementation ChatViewController{
    ToolBarClickType _clickType;
}

- (void)loadView{
    [super loadView];
    [_titleView setText:self.currentSession];
    self.historyMessages = [NSMutableArray array];
    [self getHistoryMessagesFromFile];
    [self.totalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.left.mas_equalTo(self.view.mas_left);
        make.height.mas_equalTo(ScreenHeight);
        make.right.mas_equalTo(self.view.mas_right);
    }];
    [self.totalView setBackgroundColor:[UIColor redColor]];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalView.mas_top);
        make.left.mas_equalTo(self.totalView.mas_left);
        make.right.mas_equalTo(self.totalView.mas_right);
        make.height.mas_equalTo(44);
    }];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.totalView.mas_left);
        make.right.mas_equalTo(self.totalView.mas_right);
        make.bottom.mas_equalTo(self.totalView.mas_bottom);
        make.height.mas_equalTo(44);
    }];
    
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.inputView.mas_left).mas_offset(50);
        make.right.mas_equalTo(self.audioBtn.mas_left);
        make.centerY.mas_equalTo(self.inputView.mas_centerY);
        make.width.mas_equalTo(self.inputView.mas_width).multipliedBy(0.6);
        make.height.mas_equalTo(38);
    }];
    [self.inputTextView setHidden:YES];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.inputView.mas_left).mas_offset(50);
        make.right.mas_equalTo(self.audioBtn.mas_left);
        make.centerY.mas_equalTo(self.inputView.mas_centerY);
        make.width.mas_equalTo(self.inputView.mas_width).multipliedBy(0.6);
        make.top.mas_equalTo(self.inputView.mas_top).mas_offset(4);
//        make.bottom.mas_equalTo(self.inputView.mas_bottom).mas_offset(4);
        make.height.mas_equalTo(38);
    }];
    
    [self.audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.inputView.mas_bottom);
        make.left.mas_equalTo(self.inputTextView.mas_right).mas_offset(10);
//        make.left.mas_equalTo(self.inputView.mas_right).mas_offset(10);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(44);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.mas_equalTo(self.totalView.mas_left);
        make.right.mas_equalTo(self.totalView.mas_right);
        make.bottom.mas_equalTo(self.inputView.mas_top);
    }];

    [self.iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.audioBtn.mas_bottom);
        make.left.mas_equalTo(self.audioBtn.mas_right);
        //        make.left.mas_equalTo(self.inputView.mas_right).mas_offset(10);
        make.height.mas_equalTo(self.audioBtn.mas_height);
        make.width.mas_equalTo(self.audioBtn.mas_height);
    }];
}

// textView 会随着文字数量来改变 textView 的高度.但最终最停留在某个高度值
- (void)textViewDidChange:(UITextView *)textView{
    CGRect textFrame = textView.frame;
    CGSize currentSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, 100.0)];
    if (currentSize.height <= 72) {
        [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(currentSize.height >= 44 ? currentSize.height : 44);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
     [EmojiManager shareEmojiManager];
    // Do any additional setup after loading the view.
    self.app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.app.chatDelegate = self;
//    [self.tableView registerClass:[ChatCell class] forCellReuseIdentifier:@"li"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    
    CALayer *inputViewLayer = self.inputView.layer;
    [inputViewLayer setBorderColor:[UIColor blueColor].CGColor];
    [inputViewLayer setBorderWidth:1];
    
    CALayer *layer = self.inputTextView.layer;
    [layer setBorderColor:[UIColor blackColor].CGColor];
    [layer setCornerRadius:5];
    [layer setBorderWidth:2];
    [self.inputTextView setReturnKeyType:UIReturnKeySend];
    [self.inputTextView setDelegate:self];
    [self.inputTextView setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    
    CALayer *contentLayer = self.contentView.layer;
    [contentLayer setBorderColor:[UIColor blackColor].CGColor];
    [contentLayer setBorderWidth:1];
    [contentLayer setCornerRadius:5];
    [contentLayer setMasksToBounds:YES];
    [self.contentView setDelegate:self];
    [self.contentView setReturnKeyType:UIReturnKeySend];
    
    
    [self.backImgView setUserInteractionEnabled:YES];
    [self.backImgView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backClick:)]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selfInputView:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selfInputViewHidden:) name:UIKeyboardWillHideNotification object:nil];
    [self.inputTextView addTarget:self action:@selector(editing:) forControlEvents:UIControlEventEditingDidBegin];
    
    [self.audioBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchDown];
    [self.audioBtn addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    self.audioRecordManager = [[AudioRecordManager alloc]init];
    //    [inputTextView addObserver:self selector:@selector(selfInputViewHidden:) name:UIkey object:nil];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = self.historyMessages.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatCell *cell = (ChatCell *)[tableView dequeueReusableCellWithIdentifier:@"li"];
    if (cell == nil) {
        cell = [[ChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"li"];
        
    }
//    cell.textLabel.text = self.historyMessages[indexPath.row][@"msg"];
    [cell paddingContent:self.historyMessages[indexPath.row] andAudio:nil inSize:CGSizeMake(ScreenWidth - 20 * 2, 10000) onScreenSize:[UIScreen mainScreen].bounds.size from:[self.historyMessages[indexPath.row][@"sender"] containsString:_app.stream.myJID.bare]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGRect rect = [self.historyMessages[indexPath.row][@"msg"] boundingRectWithSize:CGSizeMake(ScreenWidth - 20 * 2, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
    return rect.size.height + 60;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatCell *cell = (ChatCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(cell.audioData != nil) {
        
        [self playMusic:cell.audioData];
    }
}

- (void)editing:(UIControlEvents *)event {
    NSLog(@"done");
}

- (void)didReceiveMessage:(XMPPMessage *)messagePath{
    NSXMLElement *element = [messagePath elementForName:@"body"];
    NSString* from2 = [messagePath attributeStringValueForName:@"from"];
    NSMutableString *audioStr = [messagePath elementForName:@"attachment"].stringValue;
    NSString *audioTimeStr = [messagePath elementForName:@"attachment_time"].stringValue;
    NSString *msg = element.stringValue;
    NSArray *emojiArray = [msg adjustEmojiInString];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (self.room != nil) {
        dict[@"roomMenber"] = _roomUserSession;
        NSString *from = [(NSString *)[messagePath attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"].lastObject;
        
        if (![[NSString stringWithFormat:@"%@%@", from, HOST_SUFFIX] isEqualToString:_app.stream.myJID.bare] ) {
            dict[@"sender"] = from;
            dict[@"msg"] = msg;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger historyMessageCount = self.historyMessages.count;
                [self.historyMessages addObject:dict.copy];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.historyMessages.count - 1 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_historyMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }

    } else {
        dict[@"sender"] = self.currentSession;
        dict[@"msg"] = msg;
        if (emojiArray.count > 0) {
            dict[@"emojis"] = emojiArray;
        }
        if (audioStr != nil) {
            dict[@"audio"] = [self transformAudio:audioStr];
            dict[@"audio_time"] = audioTimeStr;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger historyMessageCount = self.historyMessages.count;
            [self.historyMessages addObject:dict.copy];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.historyMessages.count - 1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_historyMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        });
    }
   
    
}

// 转变音频文件为 data
- (NSData *)transformAudio:(NSString *)audioStr {
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:audioStr options:0];
    
    return data;
}

- (void)selfInputView:(NSNotification *)notification {
//    _clickType = ContentEnum;
    [self inputViewInKeyboard:_clickType maybeHadNofitication:notification];
//    NSDictionary *userInfo = notification.userInfo;
//    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
//    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//
//    [UIView animateWithDuration:duration animations:^{
//        [self.totalView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(ScreenHeight - keyboardRect.size.height);
//        }];
//    }];
//    NSIndexPath *indexPath = nil;
//    if (_historyMessages.count >= 1) {
//        indexPath = [NSIndexPath indexPathForRow:_historyMessages.count - 1 inSection:0];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
//    }

    
}
- (void)selfInputViewHidden:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.totalView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(ScreenHeight);
    }];
}

- (void)inputViewInKeyboard:(ToolBarClickType)clickType maybeHadNofitication:(NSNotification *)notification{
    if (clickType == ContentEnum) {
        self.contentView.inputView = nil;
        NSDictionary *userInfo = notification.userInfo;
        CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
        CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        [UIView animateWithDuration:duration animations:^{
            [self.totalView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(ScreenHeight - keyboardRect.size.height);
            }];
        }];
        NSIndexPath *indexPath = nil;
        if (_historyMessages.count >= 1) {
            indexPath = [NSIndexPath indexPathForRow:_historyMessages.count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
//        _clickType = ContentEnum;
        [self.contentView reloadInputViews];
//        [self.iconBtn setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    } else if (clickType == IconEnum) {
        NSDictionary *userInfo = notification.userInfo;
        CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
        CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//
//        [self.totalView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(ScreenHeight - keyboardRect.size.height);
//        }];
//
//        [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(self.totalView.mas_left);
//            make.right.mas_equalTo(self.totalView.mas_right);
//            make.bottom.mas_equalTo(self.totalView.mas_bottom);
//            make.height.mas_equalTo(44);
//        }];
        [self.totalView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(ScreenHeight - keyboardRect.size.height);
        }];
        EmojiView *emojiView = [[EmojiView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 260, ScreenWidth, 260)];
        [emojiView setDelegate:self];
        self.contentView.inputView = emojiView;
        [self.contentView reloadInputViews];
        
//        [self.iconBtn setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
//        [self.contentView resignFirstResponder];
    }
    
}

- (UIView*)duplicate:(UIView*)view{
    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
    return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *message = textField.text;
    [self sendMessage:message];
    // 清空输入框
    textField.text = @"";
    return NO;
}

// Mark: 这里主要是监听是否点击了发送(回车)按钮
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage:textView.text];
        [textView setText:@""];
        [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
        }];
        return NO;
    }
    return YES;
}

- (void)sendMessage:(NSString *)message {
    
    [self.contentView resignFirstResponder];
    message = [self.contentView.textStorage getPlainString];
    if (message.length != 0) {
        // 发送消息
        DDXMLElement *body = [DDXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        // 生成<message.../>元素
        DDXMLElement* mes = [DDXMLElement elementWithName:@"message"];
        // 根据不同聊天类型设置消息类型
        if ([_currentSession hasSuffix:ROOM_SUFFIX]) {
            [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
        }else{
            [mes addAttributeWithName:@"type" stringValue:@"chat"];
        }
        
        
        [mes addAttributeWithName:@"to" objectValue:_currentSession];
        [mes addAttributeWithName:@"from" objectValue:_app.stream.myJID.bare];
        [mes addChild:body];
        // 发送信息
        [_app.stream sendElement:mes];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"sender"] = _app.stream.myJID.bare;
//        dict[@"msg"] = message;
        
        NSArray *emojiArray = [message adjustEmojiInString];
        dict[@"msg"] = message;
        if (emojiArray.count > 0) {
            dict[@"emojis"] = emojiArray;
        };
        [_historyMessages addObject:dict];
        
        NSInteger rowsCount = _historyMessages.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowsCount inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_historyMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        
        
    }
}

- (void)getHistoryMessagesFromFile {
//    NSString *tempPath = NSTemporaryDirectory();
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", _currentSession]];
    // 主要作用是用 FIleHandle读取文件,等到 data 数据.然后在利用数组划分每个 string, 再把 String 转为 data, 再通过 JSONSerialization 把 data 转为 dictionary
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *data = [fileHandle readDataToEndOfFile];
    NSString *historyStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *array = [historyStr componentsSeparatedByString:@"}"];
    for (NSString *tempStr in array) {
        if (tempStr.length == 0) {

            return;
        }
        NSString *tempString = [tempStr stringByAppendingString:@"}"];
        NSData *tempData = [tempString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableContainers error:&err];
        if (dic[@"audio"] != nil) {
            dic[@"audio"] = [self transformAudio:dic[@"audio"]];
        }
        [_historyMessages addObject:dic.copy];
    }
    
    
}

- (void)backClick:(UIGestureRecognizer *)gesture {
    self.app.chatDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)getCurrentSession{
    return _currentSession;
}

- (NSData *)tempMethod {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"crash" ofType:@"wav"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

- (void)receiveAudio{
    
    
}

- (void)playMusic:(NSData *)data{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
    }

    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc]initWithData:data error:&error];
    [_audioPlayer setDelegate:self];
    [self.audioPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    
}

- (void)startRecord{
    NSLog(@"star");
    UIImageView *recordView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mic"]];
    CGRect totalFrame = self.totalView.frame;
    [recordView setFrame:CGRectMake((totalFrame.size.width - 100) / 2, (totalFrame.size.height - 100) / 2, 100, 100)];
    [recordView setTag:120];
    [self.totalView addSubview:recordView];
    
    [self.audioRecordManager startRecord];
}

- (void)stopRecord{
    NSLog(@"stop");
    UIImageView *recordView = [self.totalView viewWithTag:120];
    [recordView removeFromSuperview];
    recordView = nil;
    
    
    [self.audioRecordManager stopRecord:^(NSData *data, NSInteger timeInteval) {
        NSLog(@"inner - %@", [NSThread currentThread]);
        [self sendMusic:data andTime:timeInteval];
    } andFailure:^(NSString *errorStr) {
        
    }];
}

// MARK:发送音频文件
- (void)sendMusic:(NSData *)data andTime:(NSInteger)timeInteval{
    [self.inputTextView resignFirstResponder];
    XMPPJID *mJID = [XMPPJID jidWithString:self.currentSession];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:mJID];
    [message addAttributeWithName:@"from" stringValue:_app.stream.myJID.full];
    [message addBody:[NSString stringWithFormat:@"%ld 秒", timeInteval]];
    
    // 转换成base64的编码
    NSString *base64str = [data base64EncodedStringWithOptions:0];
    
    // 设置节点内容
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];
    XMPPElement *attachmentTime = [XMPPElement elementWithName:@"attachment_time" stringValue:[NSString stringWithFormat:@"%ld", timeInteval]];
    // 包含子节点
    [message addChild:attachment];
    [message addChild:attachmentTime];
    [_app.stream sendElement:message];
    
//    dict[@"audio"] = [self transformAudio:audioStr];
//    dict[@"audio_time"] = audioTimeStr;
    
    NSDictionary *dict = @{@"sender": _app.stream.myJID.bare, @"msg": [NSString stringWithFormat:@"%ld", timeInteval], @"audio": data, @"audio_time": [NSString stringWithFormat:@"%ld", timeInteval]};
    [_historyMessages addObject:dict];
    
   
    
    if (_historyMessages.count >= 1) {
        NSInteger rowsCount = _historyMessages.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowsCount inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }

}

- (IBAction)iconClick:(id)sender {
    NSString *imageIdentifier = [self.iconBtn.imageView.image accessibilityIdentifier];
    ToolBarClickType toolBarClickType;
    if (imageIdentifier == nil) {
        [self.iconBtn setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
        [self.iconBtn.imageView.image setAccessibilityIdentifier:@"keyboard"];
        toolBarClickType = IconEnum;
        _clickType = IconEnum;
        if (![self.contentView isFirstResponder]) {
            [self.contentView becomeFirstResponder];
        } else {
            [self inputViewInKeyboard:toolBarClickType maybeHadNofitication:nil];

        }
    } else if (![imageIdentifier isEqualToString:@"keyboard"]) {
        [self.iconBtn setImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
        [self.iconBtn.imageView.image setAccessibilityIdentifier:@"keyboard"];
        toolBarClickType = IconEnum;
        _clickType = IconEnum;
        if (![self.contentView isFirstResponder]) {
            [self.contentView becomeFirstResponder];
        } else {
            [self inputViewInKeyboard:toolBarClickType maybeHadNofitication:nil];

        }
        
    } else {
        [self.iconBtn setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
        [self.iconBtn.imageView.image setAccessibilityIdentifier:@"smile"];
//        [self inputViewInKeyboard:ContentEnum maybeHadNofitication:nil];
        toolBarClickType = ContentEnum;
        _clickType = ContentEnum;
        if (![self.contentView isFirstResponder]) {
            [self.contentView becomeFirstResponder];
        }
        [self inputViewInKeyboard:toolBarClickType maybeHadNofitication:nil];

    }
    

}

- (void)operaInEmoji:(Emoji *)emoji {
    if (emoji.isRemove) {
        [self.inputTextView deleteBackward];
    } else {
        if (emoji.emojiIcon) {
            [self.contentView replaceRange:self.inputTextView.selectedTextRange withText:emoji.emojiIcon];

        } else {
//            [self sendMessage:emoji.png];
            EmojiAttachment *amojiAttachement = [[EmojiAttachment alloc]initWithEm:emoji];
            NSAttributedString *mStr = [amojiAttachement imageTextWithFont:self.contentView.font];
            
            NSRange range = self.contentView.selectedRange;
            [self.contentView.textStorage insertAttributedString:mStr.copy atIndex:self.contentView.selectedRange.location];
            self.contentView.selectedRange = NSMakeRange(range.location + 1, 0);
            
        }
    }
}

- (void)sendMessageInEmoji{
//    self.contentView.attributedText
    [self sendMessage:self.contentView.text];
    if ([[self.iconBtn.imageView.image accessibilityIdentifier] isEqualToString:@"keyboard"]) {
        [self.iconBtn setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
        _clickType = ContentEnum;
    }
    [self.contentView setText:@""];
}

@end
