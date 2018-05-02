//
//  ChatCell.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/27.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "ChatCell.h"
#import "AppDelegate.h"
#import "ToolsMethod.h"
#import "NSAttributedString+NSAttributedString.h"
#import "Emoji.h"
#import "EmojiPackager.h"
#import "_00_Chat-Swift.h"
#define Padding 20
@implementation ChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _nameLabel = [[UILabel alloc]init];
        _backgrounImgView = [[UIImageView alloc]init];
        _contentLabel = [[UILabel alloc]init];
        
        [_nameLabel setFont:[UIFont systemFontOfSize:11]];
        [_nameLabel setTextColor:[UIColor lightGrayColor]];
        
        [_contentLabel setFont:[UIFont systemFontOfSize:13]];
        [_contentLabel setTextColor:[UIColor blackColor]];
        [_contentLabel setNumberOfLines:-1];
        
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_backgrounImgView];
        [self.contentView addSubview:_contentLabel];
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        _nameLabel = [[UILabel alloc]init];
        _backgrounImgView = [[UIImageView alloc]init];
        _contentLabel = [[UILabel alloc]init];
        
    }
    return self;
}

- (void)paddingContent:(NSDictionary *)dict andAudio:(nullable NSData *)audioData inSize:(CGSize)size onScreenSize:(CGSize)screenSize from:(NSInteger)sender {
    NSString *content = dict[@"msg"];
    NSAttributedString *contentAttr = [[NSAttributedString alloc]initWithString:content];
//    NSString *demoStr = contentAttr.getPlainString;
    
    
    NSString *name = dict[@"sender"];
//    NSData *audioData = dict["audio"];
    self.audioData = dict[@"audio"];
    self.audioTime = dict[@"audio_time"];
//    CGRect rect = [ToolsMethod countCharactersWidthAndHeight:dict inSize:size onScreenSize:screenSize  withAttribute:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}];
    NSMutableAttributedString *contentAttributeStr = [[NSMutableAttributedString alloc]initWithString:content];

    CGRect rect = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
//    CGFloat xPoint = sender == 1 ? screenSize.width - rect.size.width - 20 : 20;

    // 判断是否有表情
    NSArray *emojiArray = dict[@"emojis"];
    if (emojiArray.count > 0) {
        EmojiPackager *packer = [[EmojiPackager alloc]init];
        BOOL isFirst = NO;
        NSInteger coun = 0;
        NSInteger contentLength = contentAttributeStr.length;
        // 在这里设置文本的大小,对齐方式等.再在下面替换文字为图片即可
        [contentAttributeStr addAttribute:NSForegroundColorAttributeName
         
                                    value:[UIColor blueColor]
         
                                    range:NSMakeRange(0, contentAttributeStr.length)];
        
        [contentAttributeStr addAttribute:NSFontAttributeName
         
                                    value:[UIFont systemFontOfSize:16]
         
                                    range:NSMakeRange(0 , contentAttributeStr.length)];
        
        // NSParagraphStyle
        NSMutableParagraphStyle *paragtaphStyle = [[NSMutableParagraphStyle alloc] init];
//
//        paragtaphStyle.alignment = NSTextAlignmentJustified;
//
//        paragtaphStyle.paragraphSpacing = 11.0;
//
        paragtaphStyle.paragraphSpacingBefore = 0.6;
//
//        paragtaphStyle.headIndent = 0.0;
        paragtaphStyle.lineSpacing = 0.5;
        paragtaphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attrDict01 = @{ NSParagraphStyleAttributeName: paragtaphStyle,
                                      NSFontAttributeName: [UIFont systemFontOfSize: 6] };
//        [contentAttributeStr addAttributes:attrDict01 range:NSMakeRange(0, contentAttributeStr.length)];
        // ------------------
        [contentAttributeStr addAttribute:NSBaselineOffsetAttributeName value:@(5) range:NSMakeRange(0, contentAttributeStr.length)];
        
        for (NSDictionary *tempDict in emojiArray) {
            Emoji *emoji = [packer findEmoji:tempDict[@"emoji"]];
            EmojiAttachment *amojiAttachement = [[EmojiAttachment alloc]initWithEm:emoji];
            if (!isFirst) {
                isFirst = YES;
                
                NSRange range = NSMakeRange([(NSNumber *)tempDict[@"rangeLocation"] integerValue], [(NSNumber *)tempDict[@"rangeLength"] integerValue]);
                NSTextAttachment *contentAttachment = [[NSTextAttachment alloc]init];
                contentAttachment.image = [UIImage imageWithContentsOfFile:emoji.png];
                int yPoint = (rect.size.height + 10 - 26) / 2;
                contentAttachment.bounds = CGRectMake(0, yPoint, 26, 26);
                CGRect tempRect = contentAttachment.bounds;
                tempRect.size = CGSizeMake(23, 23);

                NSAttributedString *imageAttribute = [NSAttributedString attributedStringWithAttachment:contentAttachment];
                
                [contentAttributeStr deleteCharactersInRange:range];
                [contentAttributeStr insertAttributedString:imageAttribute atIndex:range.location];
                contentLength -= (range.length - 1);
                coun = range.length - 1;
                
            } else {
                NSRange range = NSMakeRange([(NSNumber *)tempDict[@"rangeLocation"] integerValue] - coun, [(NSNumber *)tempDict[@"rangeLength"] integerValue]);
                NSTextAttachment *contentAttachment = [[NSTextAttachment alloc]init];
                contentAttachment.image = [UIImage imageWithContentsOfFile:emoji.png];

                int yPoint = (rect.size.height + 10 - 26) / 2;
                contentAttachment.bounds = CGRectMake(0, yPoint, 26, 26);
                NSAttributedString *imageAttribute = [NSAttributedString attributedStringWithAttachment:contentAttachment];
                
                [contentAttributeStr deleteCharactersInRange:range];
                [contentAttributeStr insertAttributedString:imageAttribute atIndex:range.location];
                coun += (range.length - 1);

            }
            

            
        }

        [_contentLabel setAttributedText:contentAttributeStr];
//        [_contentLabel setFrame:CGRectMake(xPoint, 15, rect.size.width, rect.size.height + 10)];

    } else {
        [_contentLabel setText:content];
        [_contentLabel setFont:[UIFont systemFontOfSize:16]];
        
//        [_contentLabel setFrame:CGRectMake(xPoint, 15, rect.size.width, rect.size.height + 10)];
    }
    // ------------
    
    if (self.audioData.length > 0) {
        CGFloat width = [self audioSize:self.audioTime];
        rect.size.width = width;
    }
//    CGRect rect = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
    CGFloat xPoint = sender == 1 ? screenSize.width - rect.size.width - 20 : 20;
    [_contentLabel setFrame:CGRectMake(xPoint, 15, rect.size.width, rect.size.height + 10)];
//    [_contentLabel setText:content];
    
    
    UIImage *image = sender == 1 ? [UIImage imageNamed:@"GreenBubble"] : [UIImage imageNamed:@"BlueBubble"];
    UIImage *newImage = [image stretchableImageWithLeftCapWidth:20 topCapHeight:15];
    [_backgrounImgView setImage:newImage];
    [_backgrounImgView setFrame:CGRectMake(xPoint - Padding / 2, 20 - Padding / 2, rect.size.width + Padding, rect.size.height + Padding)];
    
    CGRect nameRect = [name boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9]} context:nil];
    CGFloat nameXPoint = sender == 1 ? screenSize.width - nameRect.size.width - 20 : 20;
    [_nameLabel setFrame:CGRectMake(nameXPoint, 0, nameRect.size.width, nameRect.size.height)];
    [_nameLabel setText:name];
}

- (void)fillContent:(Emoji *)emoji {
    UIImage *image = nil;
    if (emoji.isRemove) {
        image = [UIImage imageNamed:@"compose_emotion_delete"];
    } else {
        image = [UIImage imageWithContentsOfFile:emoji.png];
    }
    
}

//- (void)paddingContent:(NSDictionary *)dict inSize:(CGSize)size onScreenSize:(CGSize)screenSize from:(NSInteger)sender {
//    NSString *content = dict[@"msg"];
//    NSString *name = dict[@"sender"];
//
//    CGRect rect = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
//    CGFloat xPoint = sender == 1 ? screenSize.width - rect.size.width - 20 : 20;
//    [_contentLabel setFrame:CGRectMake(xPoint, 20, rect.size.width, rect.size.height)];
//    [_contentLabel setText:content];
//
//
//    UIImage *image = sender == 1 ? [UIImage imageNamed:@"GreenBubble"] : [UIImage imageNamed:@"BlueBubble"];
//    UIImage *newImage = [image stretchableImageWithLeftCapWidth:20 topCapHeight:15];
//    [_backgrounImgView setImage:newImage];
//    [_backgrounImgView setFrame:CGRectMake(xPoint - Padding / 2, 20 - Padding / 2, rect.size.width + Padding, rect.size.height + Padding)];
//
//    CGRect nameRect = [name boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9]} context:nil];
//    CGFloat nameXPoint = sender == 1 ? screenSize.width - nameRect.size.width - 20 : 20;
//    [_nameLabel setFrame:CGRectMake(nameXPoint, 0, nameRect.size.width, nameRect.size.height)];
//    [_nameLabel setText:name];
//}

- (CGFloat)audioSize:(NSString *)timeintevel {
    NSInteger time = [timeintevel integerValue];
    if (time <= 3) {
        return 60;
    } else if (time <= 6){
        return 90;
    } else if (time <= 9){
        return 120;
    } else if (time <= 12){
        return 140;
    } else if (time <= 15){
        return 160;
    } else if (time <= 20){
        return 180;
    } else {
        return 200;
    }
}
@end
