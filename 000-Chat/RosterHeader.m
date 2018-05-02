//
//  RosterHeader.m
//  000-Chat
//
//  Created by 李晓东 on 2018/4/26.
//  Copyright © 2018年 PeanutXu. All rights reserved.
//

#import "RosterHeader.h"

@implementation RosterHeader

- (instancetype)init{
    if (self = [super init]) {
        UIView *view = [[NSBundle mainBundle]loadNibNamed:@"rosterHeader" owner:nil options:nil].lastObject;
        [view setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        UINib *nib = [UINib nibWithNibName:@"rosterHeader" bundle:nil];
//        UIView *view = [nib instantiateWithOwner:self options:nil].lastObject;
        _rosterHeader = view;
        [self addSubview:_rosterHeader];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {

        UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
        UIView *view = [nib instantiateWithOwner:self options:nil].lastObject;
//        UIView *view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].lastObject;
//        _rosterHeader = view;
        [self addSubview:self.rosterHeader];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

//    self.rosterHeader.frame = self.bounds;
}

@end
