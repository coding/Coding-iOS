//
//  UIMessageInputView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kKeyboardView_Height 216.0
#define kMessageInputView_Height 50.0
#define kMessageInputView_HeightMax 120.0
#define kMessageInputView_PadingHeight 7.0
#define kMessageInputView_Width_Tool 35.0
#define kMessageInputView_MediaPadding 1.0

#import "UIMessageInputView.h"
#import "UIPlaceHolderTextView.h"
#import "UIMessageInputView_Add.h"
#import "UIMessageInputView_CCell.h"
#import "UIMessageInputView_Voice.h"

//at某人的功能
#import "UsersViewController.h"
#import "ProjectMemberListViewController.h"
#import "Users.h"
#import "Login.h"

#import "UICustomCollectionView.h"
#import "QBImagePickerController.h"
#import "Helper.h"

#import "Coding_FileManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MJPhotoBrowser.h"
#import "FunctionTipsManager.h"

static NSMutableDictionary *_inputStrDict, *_inputMediaDict;


@interface UIMessageInputView () <AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource, QBImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>


@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;

@property (strong, nonatomic) UIMessageInputView_Add *addKeyboardView;
@property (strong, nonatomic) UIMessageInputView_Voice *voiceKeyboardView;

@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UIPlaceHolderTextView *inputTextView;
@property (strong, nonatomic) UIButton *arrowKeyboardButton;

@property (strong, nonatomic) UICustomCollectionView *mediaView;
@property (strong, nonatomic) NSMutableArray *mediaList, *uploadMediaList;

@property (strong, nonatomic) UIButton *addButton, *emotionButton, *photoButton, *voiceButton;

@property (assign, nonatomic) CGFloat viewHeightOld;

@property (assign, nonatomic) UIMessageInputViewState inputState;

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) NSString *uploadingPhotoName;

@end

@implementation UIMessageInputView


- (void)setFrame:(CGRect)frame{
    CGFloat oldheightToBottom = kScreen_Height - CGRectGetMinY(self.frame);
    CGFloat newheightToBottom = kScreen_Height - CGRectGetMinY(frame);
    [super setFrame:frame];
    if (fabs(oldheightToBottom - newheightToBottom) > 0.1) {
        DebugLog(@"heightToBottom-----:%.2f", newheightToBottom);
        if (oldheightToBottom > newheightToBottom) {//降下去的时候保存
            [self saveInputStr];
            [self saveInputMedia];
        }
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
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateEmotion:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateAdd:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateVoice:
            {
                [self.addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        _contentView.hidden = _inputState == UIMessageInputViewStateVoice;
        _arrowKeyboardButton.hidden = !_contentView.hidden;
        
        [self updateContentViewBecauseOfMedia:NO];
        _arrowKeyboardButton.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}
- (void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolder = placeHolder;
    if (_inputTextView && ![_inputTextView.placeholder isEqualToString:placeHolder]) {
        _inputTextView.placeholder = placeHolder;
    }
}

- (NSMutableArray *)mediaList{
    if (!_mediaList) {
        _mediaList =[[NSMutableArray alloc] init];
    }
    return _mediaList;
}

- (void)mediaListChenged{
    [self saveInputMedia];
    if (_mediaView) {
        [self.mediaView reloadData];
        [self updateContentViewBecauseOfMedia:YES];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kColorNavBG;
        [self addLineUp:YES andDown:NO andColor:kColorCCC];
        _viewHeightOld = CGRectGetHeight(frame);
        _inputState = UIMessageInputViewStateSystem;
        _isAlwaysShow = NO;
        _curProject = nil;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didPan:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat verticalDiff = [panGesture translationInView:self].y;
        if (verticalDiff > 60) {
            [self isAndResignFirstResponder];
        }
    }
}

#pragma mark remember input

- (NSMutableDictionary *)shareInputStrDict{
    if (!_inputStrDict) {
        _inputStrDict = [[NSMutableDictionary alloc] init];
    }
    return _inputStrDict;
}

- (NSMutableDictionary *)shareInputMediaDict{
    if (!_inputMediaDict) {
        _inputMediaDict = [[NSMutableDictionary alloc] init];
    }
    return _inputMediaDict;
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
        return [[self shareInputStrDict] objectForKey:inputKey];
    }
    return nil;
}

- (void)deleteInputData{
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        [[self shareInputStrDict] removeObjectForKey:inputKey];
        [[self shareInputMediaDict] removeObjectForKey:inputKey];
    }
}

- (void)saveInputStr{
    NSString *inputStr = _inputTextView.text;
    NSString *inputKey = [self inputKey];
    if (inputKey && inputKey.length > 0) {
        if (inputStr && inputStr.length > 0) {
            [[self shareInputStrDict] setObject:inputStr forKey:inputKey];
        }else{
            [[self shareInputStrDict] removeObjectForKey:inputKey];
        }
    }
}

- (void)saveInputMedia{
    NSString *inputKey = [self inputKey];
    if (inputKey && inputKey.length > 0) {
        if (_mediaList.count > 0) {
            [[self shareInputMediaDict] setObject:_mediaList forKey:inputKey];
        }else{
            [[self shareInputMediaDict] removeObjectForKey:inputKey];
        }
    }
}

- (NSMutableArray *)inputMedia{
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        return [[self shareInputMediaDict] objectForKey:inputKey];
    }
    return nil;
}

- (void)setToUser:(User *)toUser{
    _toUser = toUser;
    NSString *inputStr = [self inputStr];
    if (_inputTextView) {

        if (_contentType != UIMessageInputViewContentTypePriMsg) {
            _inputTextView.placeholder = _toUser? [NSString stringWithFormat:@"回复 %@", _toUser.name]: _placeHolder;
        }else{
            self.placeHolder = _placeHolder;
        }
        _inputTextView.selectedRange = NSMakeRange(0, _inputTextView.text.length);
        [_inputTextView insertText:inputStr? inputStr: @""];
        
        _mediaList = [self inputMedia];
        [self mediaListChenged];
    }
}

#pragma mark Public M
- (void)prepareToShow{
    if ([self superview] == kKeyWindow) {
        return;
    }
    [self setY:kScreen_Height];
    [kKeyWindow addSubview:self];
    [kKeyWindow addSubview:_emojiKeyboardView];
    [kKeyWindow addSubview:_addKeyboardView];
    [kKeyWindow addSubview:_voiceKeyboardView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if (_isAlwaysShow && ![self isCustomFirstResponder]) {
        [UIView animateWithDuration:0.25 animations:^{
            [self setY:kScreen_Height - CGRectGetHeight(self.frame)];
        }];
    }
}
- (void)prepareToDismiss{
    if ([self superview] == nil) {
        return;
    }
    [self isAndResignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self setY:kScreen_Height];
    } completion:^(BOOL finished) {
        [_emojiKeyboardView removeFromSuperview];
        [_addKeyboardView removeFromSuperview];
        [_voiceKeyboardView removeFromSuperview];
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
    if (self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice) {
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emojiKeyboardView setY:kScreen_Height];
            [_addKeyboardView setY:kScreen_Height];
            [_voiceKeyboardView setY:kScreen_Height];
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
    return ([_inputTextView isFirstResponder] || self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice);
}

+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type{
    return [self messageInputViewWithType:type placeHolder:nil];
}
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type placeHolder:(NSString *)placeHolder{
    UIMessageInputView *messageInputView = [[UIMessageInputView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kMessageInputView_Height)];
    [messageInputView customUIWithType:type];
    if (placeHolder) {
        messageInputView.placeHolder = placeHolder;
    }else{
        messageInputView.placeHolder = @"撰写评论";
    }
    return messageInputView;
}

- (void)customUIWithType:(UIMessageInputViewContentType)type{
    _contentType = type;
    CGFloat contentViewHeight = kMessageInputView_Height -2*kMessageInputView_PadingHeight;
    
    NSInteger toolBtnNum;
    BOOL hasEmotionBtn, hasAddBtn, hasPhotoBtn, hasVoiceBtn;
    BOOL showBigEmotion;
    
    
    switch (_contentType) {
        case UIMessageInputViewContentTypeTweet:
        {
            toolBtnNum = 1;
            hasEmotionBtn = YES;
            hasAddBtn = NO;
            hasPhotoBtn = NO;
            showBigEmotion = NO;
            hasVoiceBtn = NO;
        }
            break;
        case UIMessageInputViewContentTypePriMsg:
        {
            toolBtnNum = 2;
            hasEmotionBtn = YES;
            hasAddBtn = YES;
            hasPhotoBtn = NO;
            showBigEmotion = YES;
            hasVoiceBtn = YES;
        }
            break;
        case UIMessageInputViewContentTypeTopic:
        case UIMessageInputViewContentTypeTask:
        {
            toolBtnNum = 1;
            hasEmotionBtn = NO;
            hasAddBtn = NO;
            hasPhotoBtn = YES;
            showBigEmotion = NO;
            hasVoiceBtn = NO;
        }
            break;
        default:
            toolBtnNum = 1;
            hasEmotionBtn = NO;
            hasAddBtn = NO;
            hasPhotoBtn = NO;
            showBigEmotion = NO;
            hasVoiceBtn = NO;
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.borderWidth = 0.5;
        _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _contentView.layer.cornerRadius = contentViewHeight/2;
        _contentView.layer.masksToBounds = YES;
        _contentView.alwaysBounceVertical = YES;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat left = hasVoiceBtn ? (7+kMessageInputView_Width_Tool+7) : kPaddingLeftWidth;
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(kMessageInputView_PadingHeight, left, kMessageInputView_PadingHeight, kPaddingLeftWidth + toolBtnNum *kMessageInputView_Width_Tool));
        }];
    }
    
    if (!_inputTextView) {
        _inputTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - kPaddingLeftWidth - toolBtnNum *kMessageInputView_Width_Tool - (hasVoiceBtn ? 7+kMessageInputView_Width_Tool+7 : kPaddingLeftWidth), contentViewHeight)];
        _inputTextView.font = [UIFont systemFontOfSize:16];
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.scrollsToTop = NO;
        _inputTextView.delegate = self;
        
        //输入框缩进
        UIEdgeInsets insets = _inputTextView.textContainerInset;
        insets.left += 8.0;
        insets.right += 8.0;
        _inputTextView.textContainerInset = insets;
        
        [self.contentView addSubview:_inputTextView];
    }
    
    if (hasEmotionBtn && !_emotionButton) {
        _emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth/2 - toolBtnNum * kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
        [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_emotionButton];
    }
    _emotionButton.hidden = !hasEmotionBtn;
    
    if (hasAddBtn && !_addButton) {
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth/2 -kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
        
        [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addButton];
    }
    _addButton.hidden = !hasAddBtn;
    
    if (hasPhotoBtn && !_photoButton) {
        _photoButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth/2 -kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
        
        [_photoButton setImage:[UIImage imageNamed:@"keyboard_photo"] forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(photoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_photoButton];
    }
    _photoButton.hidden = !hasPhotoBtn;
    
    if (hasEmotionBtn && !_emojiKeyboardView) {
        _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kKeyboardView_Height) dataSource:self showBigEmotion:showBigEmotion];
        _emojiKeyboardView.delegate = self;
        [_emojiKeyboardView setY:kScreen_Height];
    }
    
    if (hasAddBtn && !_addKeyboardView) {
        _addKeyboardView = [[UIMessageInputView_Add alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height)];
        _addKeyboardView.addIndexBlock = ^(NSInteger index){
            if ([weakSelf.delegate respondsToSelector:@selector(messageInputView:addIndexClicked:)]) {
                [weakSelf.delegate messageInputView:weakSelf addIndexClicked:index];
            }
        };
    }
    
    if (hasPhotoBtn && !_mediaView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _mediaView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_inputTextView.frame), CGRectGetWidth(_inputTextView.frame), 1) collectionViewLayout:layout];
        _mediaView.scrollEnabled = NO;
        [_mediaView setBackgroundView:nil];
        [_mediaView setBackgroundColor:[UIColor clearColor]];
        [_mediaView registerClass:[UIMessageInputView_CCell class] forCellWithReuseIdentifier:kCCellIdentifier_UIMessageInputView_CCell];
        _mediaView.dataSource = self;
        _mediaView.delegate = self;
        [self.contentView addSubview:_mediaView];
    }
    
    if (_inputTextView) {
        [[RACObserve(self.inputTextView, contentSize) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSValue *contentSize) {
            [weakSelf updateContentViewBecauseOfMedia:NO];
        }];
    }
    
    if (hasPhotoBtn) {
        //监听-上传文件成功
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationUploadCompled object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
            //{NSURLResponse: response, NSError: error, ProjectFile: data}
            NSDictionary* userInfo = [aNotification userInfo];
            [self completionUploadWithResult:[userInfo objectForKey:@"data"] error:[userInfo objectForKey:@"error"]];
        }];
    }
    
    if (hasVoiceBtn && !_voiceButton) {
        _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(7, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
        
        [_voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
        [_voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_voiceButton];
    }
    _voiceButton.hidden = !hasVoiceBtn;
    
    if (hasVoiceBtn && !_arrowKeyboardButton) {
        _arrowKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowKeyboardButton.frame = CGRectMake(0, 0, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool);
        [_arrowKeyboardButton setImage:[UIImage imageNamed:@"keyboard_arrow_down"] forState:UIControlStateNormal];
        [_arrowKeyboardButton addTarget:self action:@selector(arrowButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_arrowKeyboardButton];
    }
    _arrowKeyboardButton.hidden = YES;
    
    if (hasVoiceBtn && !_voiceKeyboardView) {
        _voiceKeyboardView = [[UIMessageInputView_Voice alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height)];
        _voiceKeyboardView.recordSuccessfully = ^(NSString *file, NSTimeInterval duration){
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(messageInputView:sendVoice:duration:)]) {
                [weakSelf.delegate messageInputView:weakSelf sendVoice:file duration:duration];
            }
        };
    }
}

- (void)updateContentViewBecauseOfMedia:(BOOL)becauseOfMedia{
    
    CGSize textSize = _inputTextView.contentSize, mediaSize = CGSizeZero;
    if (!becauseOfMedia) {
        if (ABS(CGRectGetHeight(_inputTextView.frame) - textSize.height) > 0.5) {
            [_inputTextView setHeight:textSize.height];
        }
    }
    if (_mediaView) {
        CGFloat collectionItemHeight;
        if (_mediaList.count <= 0) {
            collectionItemHeight = 0;
        }else if (_mediaList.count == 1) {
            collectionItemHeight = 0.6* CGRectGetWidth(_inputTextView.frame);
        }else if (_mediaList.count == 2){
            collectionItemHeight = (CGRectGetWidth(_inputTextView.frame) - kMessageInputView_MediaPadding)/3;
        }else{
            collectionItemHeight = (CGRectGetWidth(_inputTextView.frame) - 2* kMessageInputView_MediaPadding)/3;
        }
        CGFloat mediaHeight = ceilf(_mediaList.count/3.0)* (collectionItemHeight+ kMessageInputView_MediaPadding) - kMessageInputView_MediaPadding;
        mediaSize = CGSizeMake(CGRectGetWidth(_mediaView.frame), mediaHeight);
        
        CGRect mediaFrame = CGRectMake(0, CGRectGetMaxY(_inputTextView.frame), mediaSize.width, mediaSize.height);
        if (!CGRectEqualToRect(mediaFrame, _mediaView.frame)) {
            _mediaView.frame = mediaFrame;
        }
    }
    if (_contentView.hidden) {
        textSize.height = kMessageInputView_Height - 2*kMessageInputView_PadingHeight;
    }
    CGSize contentSize = CGSizeMake(textSize.width, textSize.height + mediaSize.height);
    CGFloat selfHeight = MAX(kMessageInputView_Height, contentSize.height + 2*kMessageInputView_PadingHeight);
    
    CGFloat maxSelfHeight = kScreen_Height/2;
    if (kDevice_Is_iPhone5){
        maxSelfHeight = 230;
    }else if (kDevice_Is_iPhone6) {
        maxSelfHeight = 290;
    }else if (kDevice_Is_iPhone6Plus){
        maxSelfHeight = kScreen_Height/2;
    }else{
        maxSelfHeight = 140;
    }
    
    selfHeight = MIN(maxSelfHeight, selfHeight);
    CGFloat diffHeight = selfHeight - _viewHeightOld;
    if (ABS(diffHeight) > 0.5) {
        CGRect selfFrame = self.frame;
        selfFrame.size.height += diffHeight;
        selfFrame.origin.y -= diffHeight;
        [self setFrame:selfFrame];
        self.viewHeightOld = selfHeight;
    }
    [self.contentView setContentSize:contentSize];
    
    CGFloat bottomY = becauseOfMedia? contentSize.height: textSize.height;
    CGFloat offsetY = MAX(0, bottomY - (CGRectGetHeight(self.frame)- 2* kMessageInputView_PadingHeight));
    [self.contentView setContentOffset:CGPointMake(0, offsetY) animated:YES];
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _mediaList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UIMessageInputView_CCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_UIMessageInputView_CCell forIndexPath:indexPath];
    [ccell setCurMedia:[_mediaList objectAtIndex:indexPath.row] andTotalCount:_mediaList.count];
    @weakify(self);
    ccell.deleteBlock = ^(UIMessageInputView_Media *toDelete){
        @strongify(self);
        [self.mediaList removeObject:toDelete];
        [self mediaListChenged];
    };
    return ccell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize ccellSize;
    CGFloat contentWidth = CGRectGetWidth(_inputTextView.frame);
    if (_mediaList.count <= 0) {
        ccellSize = CGSizeZero;
    }else if (_mediaList.count == 1) {
        ccellSize = CGSizeMake(contentWidth, 0.6* contentWidth);
    }else if (_mediaList.count == 2){
        ccellSize = CGSizeMake((contentWidth - kMessageInputView_MediaPadding)/2, (contentWidth - kMessageInputView_MediaPadding)/3);
    }else{
        ccellSize = CGSizeMake((contentWidth - 2* kMessageInputView_MediaPadding)/3, (contentWidth - 2* kMessageInputView_MediaPadding)/3);
    }
    return ccellSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return kMessageInputView_MediaPadding;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return kMessageInputView_MediaPadding;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self isAndResignFirstResponder];
    //        显示大图
    int count = (int)_mediaList.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    for (int i = 0; i<count; i++) {
        UIMessageInputView_Media *mediaItem = [_mediaList objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_queue_t queue = dispatch_queue_create("MJPhotoBrowserForAsset", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            [assetsLibrary assetForURL:mediaItem.assetURL resultBlock:^(ALAsset *asset) {
                mediaItem.curAsset = asset;
                photo.image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                dispatch_semaphore_signal(semaphore);
            } failureBlock:^(NSError *error) {
                mediaItem.curAsset = nil;
                photo.url = [NSURL URLWithString:mediaItem.urlStr]; // 图片路径
                dispatch_semaphore_signal(semaphore);
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
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
        [_voiceKeyboardView setY:kScreen_Height];
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
        [_voiceKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY- CGRectGetHeight(self.frame)];
        }
    } completion:^(BOOL finished) {
    }];
}
- (void)photoButtonClicked:(id)sender{
    //        相册
    if (![Helper checkPhotoLibraryAuthorizationStatus]) {
        return;
    }
    [self isAndResignFirstResponder];
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 6;
    UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:imagePickerController];
    [[BaseViewController presentingVC] presentViewController:navigationController animated:YES completion:^{
    }];
}

- (void)voiceButtonClicked:(id)sender {
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateVoice) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    } else {
        self.inputState = UIMessageInputViewStateVoice;
        [_inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height;
    }
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_voiceKeyboardView setY:endY];
        [_emojiKeyboardView setY:kScreen_Height];
        [_addKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY- CGRectGetHeight(self.frame)];
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)arrowButtonClicked:(id)sender {
    [self isAndResignFirstResponder];
}

#pragma mark QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    
    _uploadMediaList = [[NSMutableArray alloc] initWithCapacity:assets.count];
    for (ALAsset *asset in assets) {
        [_uploadMediaList addObject:[UIMessageInputView_Media mediaWithAsset:asset urlStr:nil]];
    }
    [self doUploadMediaList];
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    [[BaseViewController presentingVC] dismissViewControllerAnimated:YES completion:nil];
}

#pragma uploadMedia
- (void)doUploadMediaList{
    __block UIMessageInputView_Media *media = nil;
    __block NSInteger index = 0;
    [_uploadMediaList enumerateObjectsUsingBlock:^(UIMessageInputView_Media *obj, NSUInteger idx, BOOL *stop) {
        if (obj.state == UIMessageInputView_MediaStateInit) {
            media = obj;
            index = idx;
            *stop = YES;
        }
    }];
    if (media && media.curAsset) {
        [self doUploadMedia:media withIndex:index];
    }else{
        [self hudTipWillShow:nil];
        [[BaseViewController presentingVC] dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)doUploadMedia:(UIMessageInputView_Media *)media withIndex:(NSInteger)index{
    //保存到app内
    NSString* originalFileName = [[media.curAsset defaultRepresentation] filename];
    NSString *fileName = [NSString stringWithFormat:@"%@|||%@|||%@", self.curProject.id.stringValue, @"0", originalFileName];
    
    if ([Coding_FileManager writeUploadDataWithName:fileName andAsset:media.curAsset]) {
        [self hudTipWillShow:[NSString stringWithFormat:@"正在上传第 %ld 张图片...", (long)index +1]];
        media.state = UIMessageInputView_MediaStateUploading;
        self.uploadingPhotoName = originalFileName;
        Coding_UploadTask *uploadTask =[[Coding_FileManager sharedManager] addUploadTaskWithFileName:fileName projectIsPublic:_curProject.is_public.boolValue];
        @weakify(self)
        [RACObserve(uploadTask, progress.fractionCompleted) subscribeNext:^(NSNumber *fractionCompleted) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.HUD) {
                    self.HUD.progress = MAX(0, fractionCompleted.floatValue-0.05);
                    DebugLog(@"uploadingPhotoName - %@ : %.2f", self.uploadingPhotoName, fractionCompleted.floatValue);
                }
            });
        }];
    }else{
        media.state = UIMessageInputView_MediaStateUploadFailed;
        [NSObject showHudTipStr:[NSString stringWithFormat:@"%@ 文件处理失败", originalFileName]];
    }
}

- (void)completionUploadWithResult:(id)responseObject error:(NSError *)error{
    //移除文件（共有项目不能自动移除）
    NSString *diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@", self.curProject.id.stringValue, @"0", self.uploadingPhotoName];
    [Coding_FileManager deleteUploadDataWithName:diskFileName];

    __block UIMessageInputView_Media *media = nil;
    [_uploadMediaList enumerateObjectsUsingBlock:^(UIMessageInputView_Media *obj, NSUInteger idx, BOOL *stop) {
        if (obj.state == UIMessageInputView_MediaStateUploading) {
            media = obj;
            *stop = YES;
        }
    }];
    if (!media) {
        return;
    }else{
        if (responseObject) {
            NSString *fileName = nil, *fileUrlStr = @"";
            if ([responseObject isKindOfClass:[NSString class]]) {
                fileUrlStr = responseObject;
            }else if ([responseObject isKindOfClass:[ProjectFile class]]){
                ProjectFile *curFile = responseObject;
                fileName = curFile.name;
                fileUrlStr = curFile.owner_preview;
            }
            
            if (!fileName || [fileName isEqualToString:self.uploadingPhotoName]) {
                media.urlStr = fileUrlStr;
                media.state = UIMessageInputView_MediaStateUploadSucess;
                [self.mediaList addObject:media];
                [self mediaListChenged];
            }
        }
        if (media.state != UIMessageInputView_MediaStateUploadSucess) {
            media.state = UIMessageInputView_MediaStateUploadFailed;
        }
        [self doUploadMediaList];
    }
}

- (void)hudTipWillShow:(NSString *)tipStr{
    if (tipStr.length > 0) {
        [self resignFirstResponder];
        if (!_HUD) {
            _HUD = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
            _HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
            _HUD.removeFromSuperViewOnHide = YES;
        }else{
            [kKeyWindow addSubview:_HUD];
            [_HUD show:NO];
        }
        _HUD.progress = 0;
        _HUD.labelText = tipStr;
    }else{
        [_HUD hide:NO];
    }
}

#pragma mark UITextViewDelegate M
- (void)sendTextStr{
    [self deleteInputData];
    NSMutableString *sendStr = [NSMutableString stringWithString:self.inputTextView.text];
    if (_mediaList.count > 0) {
        [_mediaList enumerateObjectsUsingBlock:^(UIMessageInputView_Media *obj, NSUInteger idx, BOOL *stop) {
            [sendStr appendFormat:@"\n![图片](%@)", obj.urlStr];
        }];
    }
    if (sendStr && ![sendStr isEmpty] && _delegate && [_delegate respondsToSelector:@selector(messageInputView:sendText:)]) {
        [self.delegate messageInputView:self sendText:sendStr];
    }
    [_mediaList removeAllObjects];
    _inputTextView.selectedRange = NSMakeRange(0, _inputTextView.text.length);
    [_inputTextView insertText:@""];
    [self updateContentViewBecauseOfMedia:NO];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        if (![self.inputTextView.text hasListenChar]) {
            [self sendTextStr];
        }
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardDidChangeFrameNotification object:nil];//英文键盘，重新弹出键盘时，没有WillChange的通知
    NSString *appendingStr;
    if (curUser) {
        appendingStr = [NSString stringWithFormat:@"@%@ ", curUser.name];
    }else{
        appendingStr = @"@";
    }
    [textView setSelectedRange:range];
    [textView insertText:appendingStr];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (self.inputState != UIMessageInputViewStateSystem) {
        self.inputState = UIMessageInputViewStateSystem;
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emojiKeyboardView setY:kScreen_Height];
            [_addKeyboardView setY:kScreen_Height];
            [_voiceKeyboardView setY:kScreen_Height];
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
    if ([aNotification name] == UIKeyboardDidChangeFrameNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    if (self.inputState == UIMessageInputViewStateSystem && [self.inputTextView isFirstResponder]) {
        NSDictionary* userInfo = [aNotification userInfo];
        CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardY =  keyboardEndFrame.origin.y;

        CGFloat selfOriginY = keyboardY == kScreen_Height? self.isAlwaysShow? kScreen_Height - CGRectGetHeight(self.frame): kScreen_Height : keyboardY - CGRectGetHeight(self.frame);
//        if (keyboardY == kScreen_Height) {
//            if (self.isAlwaysShow) {
//                selfOriginY = kScreen_Height- CGRectGetHeight(self.frame);
//            }else{
//                selfOriginY = kScreen_Height;
//            }
//        }else{
//            selfOriginY = keyboardY-CGRectGetHeight(self.frame);
//        }
        if (selfOriginY == self.frame.origin.y) {
            return;
        }
        
        
        __weak typeof(self) weakSelf = self;
        void (^endFrameBlock)() = ^(){
            [weakSelf setY:selfOriginY];
        };
        if ([aNotification name] == UIKeyboardWillChangeFrameNotification) {
            NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
            [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
                endFrameBlock();
            } completion:nil];
        }else{
            endFrameBlock();
        }
    }
}

#pragma mark AGEmojiKeyboardView

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {

    NSString *emotion_monkey = [emoji emotionSpecailName];
    if (emotion_monkey) {
        if (_delegate && [_delegate respondsToSelector:@selector(messageInputView:sendBigEmotion:)]) {
            [self.delegate messageInputView:self sendBigEmotion:emotion_monkey];
        }
    }else{
        [self.inputTextView insertText:emoji];
    }
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.inputTextView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView{
    [self sendTextStr];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [UIImage imageNamed:(category == AGEmojiKeyboardViewCategoryImageEmoji? @"keyboard_emotion_emoji":
                                        category == AGEmojiKeyboardViewCategoryImageMonkey? @"keyboard_emotion_monkey":
                                        category == AGEmojiKeyboardViewCategoryImageMonkey_Gif? @"keyboard_emotion_monkey_gif":
                                        @"keyboard_emotion_emoji_code")] ?: [UIImage new];
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    return [self emojiKeyboardView:emojiKeyboardView imageForSelectedCategory:category];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"keyboard_emotion_delete"];
    return img;
}

@end
