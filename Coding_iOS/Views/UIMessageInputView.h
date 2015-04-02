//
//  UIMessageInputView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGEmojiKeyBoardView.h"
#import "Projects.h"
#import "YLImageView.h"


typedef NS_ENUM(NSInteger, UIMessageInputViewContentType) {
    UIMessageInputViewContentTypeTweet = 0,
    UIMessageInputViewContentTypePriMsg,
    UIMessageInputViewContentTypeTopic,
    UIMessageInputViewContentTypeTask
};

typedef NS_ENUM(NSInteger, UIMessageInputViewState) {
    UIMessageInputViewStateSystem,
    UIMessageInputViewStateEmotion,
    UIMessageInputViewStateAdd
};
@protocol UIMessageInputViewDelegate;

@interface UIMessageInputView : UIView<UITextViewDelegate>
@property (strong, nonatomic) NSString *placeHolder;
@property (assign, nonatomic) BOOL isAlwaysShow;
@property (assign, nonatomic, readonly) UIMessageInputViewContentType contentType;
@property (strong, nonatomic) User *toUser;
@property (strong, nonatomic) NSNumber *commentOfId;
@property (strong, nonatomic) Project *curProject;

@property (nonatomic, weak) id<UIMessageInputViewDelegate> delegate;
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type;
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type placeHolder:(NSString *)placeHolder;

- (void)prepareToShow;
- (void)prepareToDismiss;
- (BOOL)notAndBecomeFirstResponder;
- (BOOL)isAndResignFirstResponder;
- (BOOL)isCustomFirstResponder;
@end

@protocol UIMessageInputViewDelegate <NSObject>
@optional
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text;
- (void)messageInputView:(UIMessageInputView *)inputView sendBigEmotion:(NSString *)emotionName;
- (void)messageInputView:(UIMessageInputView *)inputView addIndexClicked:(NSInteger)index;
- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom;
@end


@interface UIMessageInputView_Add : UIView
@property (copy, nonatomic) void(^addIndexBlock)(NSInteger);
@end

typedef NS_ENUM(NSInteger, UIMessageInputView_MediaState) {
    UIMessageInputView_MediaStateInit,
    UIMessageInputView_MediaStateUploading,
    UIMessageInputView_MediaStateUploadSucess,
    UIMessageInputView_MediaStateUploadFailed
};
@interface UIMessageInputView_Media : NSObject
@property (strong, nonatomic) ALAsset *curAsset;
@property (strong, nonatomic) NSURL *assetURL;
@property (strong, nonatomic) NSString *urlStr;
@property (assign, nonatomic) UIMessageInputView_MediaState state;
+ (id)mediaWithAsset:(ALAsset *)asset urlStr:(NSString *)urlStr;
@end

#define kCCellIdentifier_UIMessageInputView_CCell @"UIMessageInputView_CCell"

@interface UIMessageInputView_CCell : UICollectionViewCell
@property (strong, nonatomic) UIMessageInputView_Media *curMedia;
@property (copy, nonatomic) void (^deleteBlock)(UIMessageInputView_Media *toDelete);
@end