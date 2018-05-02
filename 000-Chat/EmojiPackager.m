//
//  EmojiPackager.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//
#define DeleteSignInt 20
#import "EmojiPackager.h"
#import "Emoji.h"
@interface EmojiPackager()

@end
@implementation EmojiPackager

- (instancetype)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        [self package:dict];
    }
    return self;
}

- (void)package:(NSDictionary *)dict {
    NSMutableArray *emojis = [NSMutableArray array];
    NSArray *emojiArray = dict[@"emoticons"];
    NSString *fileName = dict[@"id"];
    NSInteger index = 0;
    for (NSDictionary *tempDict in emojiArray) {
        NSString *str = [tempDict objectForKey:@"png"];
        if (str) {
            [tempDict setValue:[NSString stringWithFormat:@"%@/Emoticons.bundle/%@/%@", [NSBundle mainBundle].bundlePath, fileName, str] forKey:@"png"];
        }
        
        Emoji *emoji = [[Emoji alloc]initWithDict:tempDict];
        [emojis addObject:emoji];
        index++;

        if (index == DeleteSignInt) {
            Emoji *emoji = [[Emoji alloc]initWithDict:@{@"isRemove" : @YES}];
            [emojis addObject:emoji];
            index = 0;
        }
    }
    [self appendEmptyEmoji:emojis];
}

// 添加空的 emoji, 填充界面
- (void)appendEmptyEmoji:(NSMutableArray *)emojis {
    int leave = emojis.count % 21;
    if (leave != 0) {
        int emptyEmojiCount = DeleteSignInt + 1 - leave;
        for (NSInteger i = 0; i < emptyEmojiCount - 1; i++) {
            Emoji *emoji = [[Emoji alloc]init];
            [emojis addObject:emoji];
        }
        Emoji *emoji = [[Emoji alloc]initWithDict:@{@"isRemove" : @YES}];
        [emojis addObject:emoji];
    }
    self.emojis = emojis.copy;
}

// 根据 emoji的[中文] 名字找出在哪个文件夹下,取出 image
- (Emoji *)findEmoji:(NSString *)emojiChs {
    // 在目录下的bundle, 可以直接用
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist" inDirectory:@"Emoticons.bundle"];
    NSDictionary *bundleDict = [NSDictionary dictionaryWithContentsOfFile:bundlePath];
    NSArray *packageArray = bundleDict[@"packages"];
    Emoji *emoji = nil;
    for (NSDictionary *tempDict in packageArray) {
        if ([tempDict[@"id"] isEqualToString:@"com.apple.emoji"]) {
            continue;
        }
        emoji = [self fineEmojiInOnePackage:tempDict[@"id"] equalTo:emojiChs];
        if (emoji) {
            break;
        }
    }
    
    return emoji;
}

- (Emoji *)fineEmojiInOnePackage:(NSString *)packageName equalTo:(NSString *)emojiChs {
    NSString *grounPath = [[NSBundle mainBundle] pathForResource:@"info" ofType:@"plist" inDirectory:[NSString stringWithFormat:@"Emoticons.bundle/%@", packageName]];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:grounPath];
    NSArray *emojiArray = dict[@"emoticons"];
    Emoji *emoji = nil;
    for (NSDictionary *tempDict in emojiArray) {
        if ([tempDict[@"chs"] isEqualToString:emojiChs]) {
            NSMutableDictionary *emojiDict = tempDict.mutableCopy;
            NSString *substring = [[grounPath substringWithRange:NSMakeRange(0, grounPath.length - 11)] stringByAppendingPathComponent:tempDict[@"png"]];
            [emojiDict setValue:substring forKey:@"png"];
            emoji = [[Emoji alloc]initWithDict:emojiDict.copy];
           
            break;
        }
    }
    return emoji;
}
@end
