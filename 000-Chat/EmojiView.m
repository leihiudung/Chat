//
//  EmojiView.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/29.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#define ScreenWidth self.frame.size.width
#define ScreenHeight self.frame.size.height
#define ColumnNum 7
#define RowNum 3
#import "EmojiView.h"
#import "Emoji.h"
#import "EmojiPackager.h"
#import "EmojiManager.h"
#import "EmojiViewCollectionCell.h"

@interface EmojiView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *emojiPackage;
@property (nonatomic, strong) EmojiManager *emojiManager;
@property (nonatomic, strong) ClickEmojiBlock clickEmojiBlock;
@property (nonatomic, strong) UIView *toolView;
@end
@implementation EmojiView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        [flowLayout setMinimumLineSpacing:0];
        [flowLayout setMinimumInteritemSpacing:0];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [flowLayout setItemSize:CGSizeMake(ScreenWidth / ColumnNum, 210 / RowNum)];
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 210 - 50, ScreenWidth, 210) collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView setPagingEnabled:YES];
        [self addSubview:_collectionView];
        
        _toolView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 50, ScreenWidth, 50)];
        [_toolView setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:_toolView];
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendBtn setFrame:CGRectMake(ScreenWidth - 60, 0, 50, 50)];
        [sendBtn setTitle:@"Send" forState: UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_toolView addSubview:sendBtn];
        [sendBtn addTarget:self action:@selector(sendEmoji:) forControlEvents:UIControlEventTouchUpInside];
        
        _emojiManager = [EmojiManager shareEmojiManager];

        _emojiPackage = _emojiManager.emojiGroup.copy;
        [_collectionView registerClass:[EmojiViewCollectionCell class] forCellWithReuseIdentifier:@"li"];
    }
    return self;
}

- (void)sendEmoji:(id)sender {
    [self.delegate sendMessageInEmoji];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _emojiPackage.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *temp = [(EmojiPackager *)_emojiPackage[section] emojis];
    
    return [(EmojiPackager *)_emojiPackage[section] emojis].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    EmojiViewCollectionCell *cell = (EmojiViewCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"li" forIndexPath:indexPath];
    Emoji *emoji = (Emoji *)[(EmojiPackager *)_emojiPackage[indexPath.section] emojis][indexPath.item];
    
    [cell fillContent:emoji];
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    Emoji *emoji = [(EmojiPackager *)_emojiPackage[indexPath.section] emojis][indexPath.item];
    [self.delegate operaInEmoji:emoji];
}

- (void)dealloc{
    _emojiPackage = nil;
}

@end
