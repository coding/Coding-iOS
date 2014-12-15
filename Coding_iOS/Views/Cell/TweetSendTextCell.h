//
//  TweetSendTextCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "Users.h"
#import "AGEmojiKeyBoardView.h"

@interface TweetSendTextCell : UITableViewCell<UITextViewDelegate>
@property (strong, nonatomic) UIPlaceHolderTextView *tweetContentView;
@property (nonatomic,copy) void(^textValueChangedBlock)(NSString*);
@property (nonatomic,copy) void(^atSomeoneBlock)(UITextView *tweetContentView);
+ (CGFloat)cellHeight;
@end
