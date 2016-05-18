//
//  UIMessageInputView_CCell.m
//  Coding_iOS
//
//  Created by Ease on 15/4/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "UIMessageInputView_CCell.h"
#import "YLImageView.h"

@interface UIMessageInputView_CCell ()
@property (strong, nonatomic) UIMessageInputView_Media *media;
@property (strong, nonatomic) YLImageView *imgView;
@property (strong, nonatomic) UIButton *deleteBtn;
@end

@implementation UIMessageInputView_CCell
- (void)setCurMedia:(UIMessageInputView_Media *)curMedia andTotalCount:(NSInteger)totalCount{
    if (!_imgView) {
        _imgView = [[YLImageView alloc] initWithFrame:CGRectZero];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.layer.masksToBounds = YES;
        _imgView.layer.cornerRadius = 2.0;
        [self.contentView addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"btn_delete_tweetimage"] forState:UIControlStateNormal];
        _deleteBtn.backgroundColor = [UIColor blackColor];
        _deleteBtn.layer.cornerRadius = 10;
        _deleteBtn.layer.masksToBounds = YES;
        [_deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteBtn];
        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    
    if (_media != curMedia) {
        _media = curMedia;
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_queue_t queue = dispatch_queue_create("UIMessageInputView_CCellForAsset", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            [assetsLibrary assetForURL:_media.assetURL resultBlock:^(ALAsset *asset) {
                _media.curAsset = asset;
                dispatch_semaphore_signal(semaphore);
            } failureBlock:^(NSError *error) {
                _media.curAsset = nil;
                dispatch_semaphore_signal(semaphore);
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        CGImageRef imageRef = nil;
        if (totalCount < 3) {
            imageRef = _media.curAsset.defaultRepresentation.fullScreenImage;
        }else{
            imageRef = _media.curAsset.thumbnail;
        }
        if (imageRef) {
            self.imgView.image = [UIImage imageWithCGImage:imageRef];
        } else {
            [self.imgView sd_setImageWithURL:[_media.urlStr urlImageWithCodePathResizeToView:self.contentView] placeholderImage:kPlaceholderCodingSquareWidth(55.0) options:SDWebImageRetryFailed| SDWebImageLowPriority| SDWebImageHandleCookies];
        }
    }
}

- (void)deleteBtnClicked:(id)sender{
    if (_deleteBlock) {
        _deleteBlock(_media);
    }
}
@end
