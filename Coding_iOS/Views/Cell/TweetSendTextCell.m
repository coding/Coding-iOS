//
//  TweetSendTextCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetContentCell_ContentFont [UIFont systemFontOfSize:16]
#define kKeyboardView_Height 216.0


#import "TweetSendTextCell.h"

@interface TweetSendTextCell () <AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>
@property (nonatomic, strong) UIView *keyboardToolBar;
@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (strong, nonatomic) UIButton *emotionButton, *atButton;
@end


@implementation TweetSendTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!_tweetContentView) {
            _tweetContentView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(7, 7, kScreen_Width-7*2, [TweetSendTextCell cellHeight]-10)];
            _tweetContentView.backgroundColor = [UIColor clearColor];
            _tweetContentView.font = kTweetContentCell_ContentFont;
            _tweetContentView.delegate = self;
            _tweetContentView.placeholder = @"来，发个冒泡吧...";
            _tweetContentView.returnKeyType = UIReturnKeyDefault;
            [self.contentView addSubview:_tweetContentView];
        }
        if (!_emojiKeyboardView) {
            _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kKeyboardView_Height) dataSource:self showBigEmotion:YES];
            _emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            _emojiKeyboardView.delegate = self;
            [_emojiKeyboardView setDoneButtonTitle:@"完成"];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight{
    CGFloat cellHeight = 95;

    return cellHeight;
}

#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(textView.text);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if ([text isEqualToString:@"\n"]) {
//        [_tweetContentView resignFirstResponder];
//        return NO;
//    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [kKeyWindow addSubview:self.keyboardToolBar];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self.keyboardToolBar removeFromSuperview];
    return YES;
}
#pragma mark KeyboardToolBar
- (UIView *)keyboardToolBar{
    if (!_keyboardToolBar) {
        _keyboardToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, 40)];
        [_keyboardToolBar addLineUp:YES andDown:NO andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
        _keyboardToolBar.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];

        CGFloat toolBarHeight = CGRectGetHeight(_keyboardToolBar.frame);
        _emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(15, (toolBarHeight - 30)/2, 30, 30)];
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
        [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_keyboardToolBar addSubview:_emotionButton];
        
        _atButton = [[UIButton alloc] initWithFrame:CGRectMake(15+30+20, (toolBarHeight - 30)/2, 30, 30)];
        [_atButton setImage:[UIImage imageNamed:@"keyboard_at"] forState:UIControlStateNormal];
        [_atButton addTarget:self action:@selector(atButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_keyboardToolBar addSubview:_atButton];
    }
    return _keyboardToolBar;
}
- (void)emotionButtonClicked:(id)sender{
    if (self.tweetContentView.inputView != self.emojiKeyboardView) {
        self.tweetContentView.inputView = self.emojiKeyboardView;
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
    }else{
        self.tweetContentView.inputView = nil;
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
    }
    [self.tweetContentView resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tweetContentView becomeFirstResponder];
    });
}
- (void)atButtonClicked:(id)sender{
    if (_atSomeoneBlock) {
        _atSomeoneBlock(self.tweetContentView);
    }
}

#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)aNotification{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"userInfo------------------:%@", userInfo);
    [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
        CGFloat keyboardY =  keyboardEndFrame.origin.y;
        [self.keyboardToolBar setY:keyboardY- CGRectGetHeight(self.keyboardToolBar.frame)];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark AGEmojiKeyboardView

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    NSRange selectedRange = self.tweetContentView.selectedRange;
    
    NSString *emotion_monkey = [emoji emotionMonkeyName];
    if (emotion_monkey) {
        emotion_monkey = [NSString stringWithFormat:@" :%@: ", emotion_monkey];
        self.tweetContentView.text = [self.tweetContentView.text stringByReplacingCharactersInRange:selectedRange withString:emotion_monkey];
        self.tweetContentView.selectedRange = NSMakeRange(selectedRange.location +emotion_monkey.length, 0);
        [self textViewDidChange:self.tweetContentView];
    }else{
        self.tweetContentView.text = [self.tweetContentView.text stringByReplacingCharactersInRange:selectedRange withString:emoji];
        self.tweetContentView.selectedRange = NSMakeRange(selectedRange.location +emoji.length, 0);
        [self textViewDidChange:self.tweetContentView];
    }
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.tweetContentView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView{
    [_tweetContentView resignFirstResponder];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    return [UIImage imageNamed:@"keyboard_emotion_emoji"];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    return [UIImage imageNamed:@"keyboard_emotion_emoji"];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"keyboard_emotion_delete"];
    return img;
}

@end




