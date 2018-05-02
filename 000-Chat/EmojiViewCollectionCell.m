//
//  EmojiViewCollectionCell.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "EmojiViewCollectionCell.h"
#import "Emoji.h"
@interface EmojiViewCollectionCell()
@property (nonatomic, strong) UIButton *button;
@end
@implementation EmojiViewCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setFrame:self.contentView.frame];
        [self.button setUserInteractionEnabled:NO];
        [self.contentView addSubview:self.button];
    }
    return self;
}

- (void)fillContent:(Emoji *)emoji {
    UIImage *image = nil;
    if (emoji.isRemove) {
        image = [UIImage imageNamed:@"compose_emotion_delete"];
    } else {
        image = [UIImage imageWithContentsOfFile:emoji.png];
    }
    
    [self.button setImage:image forState:UIControlStateNormal];
    
    [self.button setTitle:emoji.emojiIcon forState:UIControlStateNormal];
    [self.button.titleLabel setFont:[UIFont systemFontOfSize:33]];
}

@end
