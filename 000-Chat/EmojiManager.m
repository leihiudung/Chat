//
//  EmojiManager.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "EmojiManager.h"
#import "EmojiPackager.h"
#import "Emoji.h"
@interface EmojiManager()
@end
@implementation EmojiManager

+ (instancetype)shareEmojiManager {
    static dispatch_once_t onceToken;
    static EmojiManager *emojiManager = nil;
    dispatch_once(&onceToken, ^{
        emojiManager = [[EmojiManager alloc]init];
        [emojiManager getEmojiGroup];
    });
    return emojiManager;
}

- (void)getEmojiGroup {
    self.emojiGroup = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist" inDirectory:@"Emoticons.bundle"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *array = dict[@"packages"];
    int i = 0;
    for (NSDictionary *tempDict in array) {
        NSString *groupName = tempDict[@"id"];
        EmojiPackager *packager = [self getEmojiInGroup:groupName];
        self.emojiGroup[i] = packager;
        i++;
    }

}

- (EmojiPackager *)getEmojiInGroup:(NSString *)groupName {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"info" ofType:@"plist" inDirectory:[NSString stringWithFormat:@"Emoticons.bundle/%@", groupName]];
    NSDictionary *groupDict = [NSDictionary dictionaryWithContentsOfFile:path];
    EmojiPackager *packager = [[EmojiPackager alloc]initWithDictionary:groupDict];
    return packager;
    
}

- (Emoji *)fineEmojiWithChs:(NSString *)chs {
    
    return nil;
}

@end
