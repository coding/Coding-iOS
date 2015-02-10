//
//  UIMessageInputView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kKeyboardView_Height 216.0
#define kMessageInputView_Height 50.0
#define kMessageInputView_HeightMax 100.0
#define kMessageInputView_PadingHeight 7.0
#define kMessageInputView_Font [UIFont systemFontOfSize:16]
#define kMessageInputView_Width_Tool 35.0

#import "UIMessageInputView.h"
#import "UIPlaceHolderTextView.h"

//at某人的功能
#import "UsersViewController.h"
#import "ProjectMemberListViewController.h"
#import "Users.h"
#import "Login.h"


static NSMutableDictionary *_inputDict;


@interface UIMessageInputView () <AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>
@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (strong, nonatomic) UIMessageInputView_Add *addKeyboardView;
@property (strong, nonatomic) UIPlaceHolderTextView *inputTextView;
@property (strong, nonatomic) UIButton *addButton, *emotionButton;
@property (assign, nonatomic) CGFloat viewHeightOld;
@property (assign, nonatomic) UIMessageInputViewState inputState;
@end

@implementation UIMessageInputView


- (void)setFrame:(CGRect)frame{
    CGFloat oldheightToBottom = kScreen_Height - CGRectGetMinY(self.frame);
    CGFloat newheightToBottom = kScreen_Height - CGRectGetMinY(frame);
    [super setFrame:frame];
    if (abs(oldheightToBottom - newheightToBottom) > 0.1) {
        NSLog(@"heightToBottom-----:%.2f", newheightToBottom);
        if (_delegate && [_delegate respondsToSelector:@selector(messageInputView:heightToBottomChenged:)]) {
            [self.delegate messageInputView:self heightToBottomChenged:newheightToBottom];
        }
    }
}

- (void)setInputState:(UIMessageInputViewState)inputState{
    if (_inputState != inputState) {
        _inputState = inputState;
        switch (_inputState) {
            case UIMessageInputViewStateSystem:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];

            }
                break;
            case UIMessageInputViewStateEmotion:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
                
            }
                break;
            case UIMessageInputViewStateAdd:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
                
            }
                break;
            default:
                break;
        }
    }
}
- (void)setPlaceHolder:(NSString *)placeHolder{
    if (_inputTextView && ![_inputTextView.placeholder isEqualToString:placeHolder]) {
        _placeHolder = placeHolder;
        _inputTextView.placeholder = placeHolder;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:lineView];
        _viewHeightOld = kMessageInputView_Height;
        if (!_inputTextView) {
            CGFloat inputTextViewHeight = kMessageInputView_Height -2*kMessageInputView_PadingHeight;
            _inputTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kMessageInputView_PadingHeight, kScreen_Width -2*kPaddingLeftWidth, inputTextViewHeight)];
            _inputTextView.layer.borderWidth = 0.5;
            _inputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            _inputTextView.layer.cornerRadius = inputTextViewHeight/2;
            _inputTextView.font = kMessageInputView_Font;
            _inputTextView.returnKeyType = UIReturnKeySend;
            _inputTextView.scrollsToTop = NO;
            _inputTextView.delegate = self;
            [self addSubview:_inputTextView];
        }
        _inputState = UIMessageInputViewStateSystem;
        _isAlwaysShow = NO;
        _curProject = nil;
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark remember input

- (NSMutableDictionary *)shareInputDict{
    if (!_inputDict) {
        _inputDict = [[NSMutableDictionary alloc] init];
    }
    return _inputDict;
}

- (NSString *)inputKey{
    NSString *inputKey = nil;
    if (_contentType == UIMessageInputViewContentTypePriMsg) {
        inputKey = [NSString stringWithFormat:@"privateMessage_%@", self.toUser.global_key];
    }else{
        if (_commentOfId) {
            switch (_contentType) {
                case UIMessageInputViewContentTypeTweet:
                    inputKey = [NSString stringWithFormat:@"tweet_%@_%@", _commentOfId.stringValue, _toUser.global_key.length > 0? _toUser.global_key:@""];
                    break;
                case UIMessageInputViewContentTypeTopic:
                    inputKey = [NSString stringWithFormat:@"topic_%@_%@", _commentOfId.stringValue, _toUser.global_key.length > 0? _toUser.global_key:@""];
                    break;
                case UIMessageInputViewContentTypeTask:
                    inputKey = [NSString stringWithFormat:@"task_%@_%@", _commentOfId.stringValue, _toUser.global_key.length > 0? _toUser.global_key:@""];
                    break;
                default:
                    break;
            }
        }
    }
    return inputKey;
}

- (NSString *)inputStr{
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        return [[self shareInputDict] objectForKey:inputKey];
    }
    return nil;
}

- (void)deleteInputStr{
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        [[self shareInputDict] removeObjectForKey:inputKey];
    }
}

- (void)saveInputStr{
    if (_inputTextView) {
        NSString *inputStr = _inputTextView.text;
        NSString *inputKey = [self inputKey];
        if (inputKey && inputKey.length > 0) {
            if (inputStr && inputStr.length > 0) {
                [[self shareInputDict] setObject:inputStr forKey:inputKey];
            }else{
                [[self shareInputDict] removeObjectForKey:inputKey];
            }
        }
    }
}

- (void)setToUser:(User *)toUser{
    _toUser = toUser;
    NSString *inputStr = [self inputStr];
    if (_inputTextView) {
        if (_contentType != UIMessageInputViewContentTypePriMsg) {
            self.placeHolder = _toUser? [NSString stringWithFormat:@"回复 %@:", _toUser.name]: @"撰写评论";
        }else{
            self.placeHolder = @"请输入私信内容";
        }
        
        [_inputTextView setText:inputStr];
        [self textViewDidChange:_inputTextView];
    }
}

#pragma mark Public M
- (void)prepareToShow{
    [self setY:kScreen_Height];
    [kKeyWindow addSubview:self];
    [kKeyWindow addSubview:_emojiKeyboardView];
    [kKeyWindow addSubview:_addKeyboardView];
    if (_isAlwaysShow) {
        [UIView animateWithDuration:0.25 animations:^{
            [self setY:kScreen_Height - CGRectGetHeight(self.frame)];
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        }];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}
- (void)prepareToDismiss{
    [self isAndResignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self setY:kScreen_Height];
    } completion:^(BOOL finished) {
        [_emojiKeyboardView removeFromSuperview];
        [_addKeyboardView removeFromSuperview];
        [self removeFromSuperview];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (BOOL)notAndBecomeFirstResponder{
    self.inputState = UIMessageInputViewStateSystem;
    if ([_inputTextView isFirstResponder]) {
        return NO;
    }else{
        [_inputTextView becomeFirstResponder];
        return YES;
    }
}
- (BOOL)isAndResignFirstResponder{
    if (self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion) {
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emojiKeyboardView setY:kScreen_Height];
            [_addKeyboardView setY:kScreen_Height];
            if (self.isAlwaysShow) {
                [self setY:kScreen_Height- CGRectGetHeight(self.frame)];
            }else{
                [self setY:kScreen_Height];
            }
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
        return YES;
    }else{
        if ([_inputTextView isFirstResponder]) {
            [_inputTextView resignFirstResponder];
            return YES;
        }else{
            return NO;
        }
    }
}

- (BOOL)isCustomFirstResponder{
    return ([_inputTextView isFirstResponder] || self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion);
}

+ (instancetype)messageInputViewWithType:(UIMessageInputViewType)type{
    return [self messageInputViewWithType:type placeHolder:nil];
}
+ (instancetype)messageInputViewWithType:(UIMessageInputViewType)type placeHolder:(NSString *)placeHolder{
    UIMessageInputView *messageInputView = [[UIMessageInputView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kMessageInputView_Height)];
    [messageInputView customUIWithType:type];
    if (placeHolder) {
        messageInputView.placeHolder = placeHolder;
    }else{
        messageInputView.placeHolder = @"说点什么吧...";
    }
    return messageInputView;
}

- (void)customUIWithType:(UIMessageInputViewType)type{
    if (type == UIMessageInputViewTypeSimple) {
        [_inputTextView setWidth:(kScreen_Width -2*kPaddingLeftWidth - kMessageInputView_Width_Tool)];
        if (_addButton) {
            _addButton.hidden = YES;
        }
        if (!_emotionButton) {
            _emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth/2 -kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
            [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
            [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_emotionButton];
        }
        _emotionButton.hidden = NO;
    }else if (type == UIMessageInputViewTypeMedia){
        [_inputTextView setWidth:(kScreen_Width -2*kPaddingLeftWidth - 2*kMessageInputView_Width_Tool)];
        if (!_addButton) {
            _addButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth/2 -kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];

            [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
            [_addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_addButton];
        }
        _addButton.hidden = NO;
        if (!_emotionButton) {
            _emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth/2 -2*kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
            [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
            [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_emotionButton];
        }
        _emotionButton.hidden = NO;
    }
    
    if (!_emojiKeyboardView) {
        _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kKeyboardView_Height) dataSource:self showBigEmotion:(type == UIMessageInputViewTypeMedia)];
        _emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _emojiKeyboardView.delegate = self;
        [_emojiKeyboardView setY:kScreen_Height];
    }
    if (type == UIMessageInputViewTypeMedia) {
        if (!_addKeyboardView) {
            _addKeyboardView = [[UIMessageInputView_Add alloc] initWithFrame:_emojiKeyboardView.bounds];
            [_addKeyboardView setY:kScreen_Height];
        }
        __weak typeof(self) weakSelf = self;
        _addKeyboardView.addIndexBlock = ^(NSInteger index){
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(messageInputView:addIndexClicked:)]) {
                [weakSelf.delegate messageInputView:weakSelf addIndexClicked:index];
            }
        };
    }
}
#pragma mark addButton M
- (void)addButtonClicked:(id)sender{
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateAdd) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    }else{
        self.inputState = UIMessageInputViewStateAdd;
        [_inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height;
    }
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_addKeyboardView setY:endY];
        [_emojiKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY- CGRectGetHeight(self.frame)];
        }
    } completion:^(BOOL finished) {
    }];
}
- (void)emotionButtonClicked:(id)sender{
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateEmotion) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    }else{
        self.inputState = UIMessageInputViewStateEmotion;
        [_inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height;
    }
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_emojiKeyboardView setY:endY];
        [_addKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY- CGRectGetHeight(self.frame)];
        }
    } completion:^(BOOL finished) {
    }];
}
#pragma mark UITextViewDelegate M
- (void)sendTextStr{
    [self deleteInputStr];
    NSString *sendStr = self.inputTextView.text;
    if (sendStr && ![sendStr isEmpty] && _delegate && [_delegate respondsToSelector:@selector(messageInputView:sendText:)]) {
        [self.delegate messageInputView:self sendText:sendStr];
        self.inputTextView.text = nil;
        [self textViewDidChange:_inputTextView];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self sendTextStr];
        return NO;
    }else if ([text isEqualToString:@"@"]){
        __weak typeof(self) weakSelf = self;
        
        if (self.curProject) {
            //@项目成员
            [ProjectMemberListViewController showATSomeoneWithBlock:^(User *curUser) {
                [weakSelf atSomeUser:curUser inTextView:textView andRange:range];
            } withProject:self.curProject];
        }else{
            //@好友
            [UsersViewController showATSomeoneWithBlock:^(User *curUser) {
                [weakSelf atSomeUser:curUser inTextView:textView andRange:range];
            }];
        }
        return NO;
    }
    return YES;
}
- (void)atSomeUser:(User *)curUser inTextView:(UITextView *)textView andRange:(NSRange)range{
    NSString *appendingStr;
    if (curUser) {
        appendingStr = [NSString stringWithFormat:@"@%@ ", curUser.name];
    }else{
        appendingStr = @"@";
    }
    textView.text = [textView.text stringByReplacingCharactersInRange:range withString:appendingStr];
    textView.selectedRange = NSMakeRange(range.location +appendingStr.length, 0);
    [self textViewDidChange:textView];
    [self notAndBecomeFirstResponder];
}
- (void)textViewDidChange:(UITextView *)textView{
    [self saveInputStr];
    CGFloat viewHeightNew = [textView.text getHeightWithFont:textView.font constrainedToSize:CGSizeMake(CGRectGetWidth(textView.frame)-16, kMessageInputView_HeightMax)]+16 + 2*kMessageInputView_PadingHeight;
    viewHeightNew = MAX(kMessageInputView_Height, viewHeightNew);
    if (viewHeightNew != _viewHeightOld) {

        CGFloat diffHeight = viewHeightNew - _viewHeightOld;
        
        CGRect viewFrame = self.frame;
        CGRect textViewFrame = textView.frame;
 
        viewFrame.size.height += diffHeight;
        viewFrame.origin.y -= diffHeight;
        textViewFrame.size.height += diffHeight;
        self.frame = viewFrame;
        textView.frame = textViewFrame;
        if (viewHeightNew < _viewHeightOld) {
            //textView的contentSize并没有根据现实内容的大小马上改变，所以在这里对它的ContentOffset处理也做一个延时
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [textView setContentOffset:CGPointMake(0, MAX(0, textView.contentSize.height - textViewFrame.size.height)) animated:YES];
            });
        }else{
            [textView setContentOffset:CGPointMake(0, MAX(0, textView.contentSize.height - textViewFrame.size.height)) animated:YES];
        }
        _viewHeightOld = viewHeightNew;
    }
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (self.inputState != UIMessageInputViewStateSystem) {
        self.inputState = UIMessageInputViewStateSystem;
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emojiKeyboardView setY:kScreen_Height];
            [_addKeyboardView setY:kScreen_Height];
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (self.inputState == UIMessageInputViewStateSystem) {
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            if (_isAlwaysShow) {
                [self setY:kScreen_Height- CGRectGetHeight(self.frame)];
            }else{
                [self setY:kScreen_Height];
            }
        } completion:^(BOOL finished) {
        }];
    }
    return YES;
}
#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)aNotification{
    if (self.inputState == UIMessageInputViewStateSystem && [self.inputTextView isFirstResponder]) {
        NSDictionary* userInfo = [aNotification userInfo];
        NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
            CGFloat keyboardY =  keyboardEndFrame.origin.y;
            if (ABS(keyboardY - kScreen_Height) < 0.1) {
                if (_isAlwaysShow) {
                    [self setY:kScreen_Height- CGRectGetHeight(self.frame)];
                }else{
                    [self setY:kScreen_Height];
                }
            }else{
                [self setY:keyboardY-CGRectGetHeight(self.frame)];
            }

        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark AGEmojiKeyboardView

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {

    NSString *emotion_monkey = [emoji emotionMonkeyName];
    if (emotion_monkey) {
        emotion_monkey = [NSString stringWithFormat:@" :%@: ", emotion_monkey];
        if (_delegate && [_delegate respondsToSelector:@selector(messageInputView:sendBigEmotion:)]) {
            [self.delegate messageInputView:self sendBigEmotion:emotion_monkey];
        }
    }else{
        NSRange selectedRange = self.inputTextView.selectedRange;
        self.inputTextView.text = [self.inputTextView.text stringByReplacingCharactersInRange:selectedRange withString:emoji];
        self.inputTextView.selectedRange = NSMakeRange(selectedRange.location +emoji.length, 0);
        [self textViewDidChange:self.inputTextView];
    }
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.inputTextView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView{
    [self sendTextStr];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageEmoji) {
        img = [UIImage imageNamed:@"keyboard_emotion_emoji"];
    }else if (category == AGEmojiKeyboardViewCategoryImageMonkey){
        img = [UIImage imageNamed:@"keyboard_emotion_monkey"];
    }
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageEmoji) {
        img = [UIImage imageNamed:@"keyboard_emotion_emoji"];
    }else if (category == AGEmojiKeyboardViewCategoryImageMonkey){
        img = [UIImage imageNamed:@"keyboard_emotion_monkey"];
    }
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"keyboard_emotion_delete"];
    return img;
}

@end

@implementation UIMessageInputView_Add
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        UIButton *photoItem = [self buttonWithImageName:@"keyboard_add_photo" title:@"照片" index:0];
        UIButton *cameraItem = [self buttonWithImageName:@"keyboard_add_camera" title:@"拍摄" index:1];
        [self addSubview:photoItem];
        [self addSubview:cameraItem];
    }
    return self;
}

- (UIButton *)buttonWithImageName:(NSString *)imageName title:(NSString *)title index:(NSInteger)index{
    CGFloat itemWidth = (kScreen_Width- 2*kPaddingLeftWidth)/3;
    CGFloat leftX = kPaddingLeftWidth, topY = 10;
    UIButton *addItem = [[UIButton alloc] initWithFrame:CGRectMake(leftX +index*itemWidth +(itemWidth -50)/2, topY, 50, 80)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 50, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    [addItem addSubview:titleLabel];
    
    [addItem setImageEdgeInsets:UIEdgeInsetsMake(-10, 0, 10, 0)];
    [addItem setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    addItem.tag = 2000+index;
    [addItem addTarget:self action:@selector(clickedItem:) forControlEvents:UIControlEventTouchUpInside];
    return addItem;
}

- (void)clickedItem:(UIButton *)sender{
    NSInteger index = sender.tag - 2000;
    if (_addIndexBlock) {
        _addIndexBlock(index);
    }
}




@end