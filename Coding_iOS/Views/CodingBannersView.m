//
//  CodingBannersView.m
//  Coding_iOS
//
//  Created by Ease on 15/7/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CodingBannersView.h"
#import "SMPageControl.h"
#import "AutoSlideScrollView.h"

@interface CodingBannersView ()
@property (assign, nonatomic) CGFloat padding_top, padding_bottom, image_width, ratio;

@property (strong, nonatomic) UILabel *typeLabel, *titleLabel;
@property (strong, nonatomic) SMPageControl *myPageControl;
@property (strong, nonatomic) AutoSlideScrollView *mySlideView;
@property (strong, nonatomic) NSMutableArray *imageViewList;
@end

@implementation CodingBannersView

- (instancetype)init
{
    
    self = [super init];
    if (self) {
        _padding_top = 40;
        _padding_bottom = 15;
        _image_width = kScreen_Width - 2*kPaddingLeftWidth;
        _ratio = 0.3;
        CGFloat viewHeight = _padding_top + _padding_bottom + _image_width * _ratio;
        [self setSize:CGSizeMake(kScreen_Width, viewHeight)];
    }
    return self;
}

- (void)setCurBannerList:(NSArray *)curBannerList{
    if ([[_curBannerList valueForKey:@"title"] isEqualToArray:[curBannerList valueForKey:@"title"]]) {
        return;
    }
    _curBannerList = curBannerList;
    
    if (!_typeLabel) {
        _typeLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, (_padding_top - 15)/2, 30, 15)];
            [label doBorderWidth:0.5 color:[UIColor colorWithHexString:@"0xb5b5b5"] cornerRadius:2.0];
            label.textColor = [UIColor colorWithHexString:@"0x666666"];
            label.font = [UIFont systemFontOfSize:10];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"活动";
            label;
        });
        _typeLabel.text = [(CodingBanner *)_curBannerList.firstObject name];
        [self addSubview:_typeLabel];
    }
    
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_typeLabel.frame) + 5.0, (_padding_top - 30)/2, _image_width - CGRectGetWidth(_typeLabel.frame) - 70, 30)];
            label.textColor = [UIColor colorWithHexString:@"0x222222"];
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
        _titleLabel.text = [(CodingBanner *)_curBannerList.firstObject title];
        [self addSubview:_titleLabel];
    }
    
    if (!_myPageControl) {
        _myPageControl = ({
            SMPageControl *pageControl = [[SMPageControl alloc] init];
            pageControl.userInteractionEnabled = NO;
            pageControl.backgroundColor = [UIColor clearColor];
            pageControl.pageIndicatorImage = [UIImage imageNamed:@"banner__page_unselected"];
            pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"banner__page_selected"];
            pageControl.frame = (CGRect){CGRectGetMaxX(_titleLabel.frame) + 5, (_padding_top - 10)/2, kScreen_Width - CGRectGetMaxX(_titleLabel.frame) - kPaddingLeftWidth - 5, 10};
            pageControl.numberOfPages = _curBannerList.count;
            pageControl.currentPage = 0;
            pageControl.alignment = SMPageControlAlignmentRight;
            pageControl;
        });
        [self addSubview:_myPageControl];
    }
    
    if (!_mySlideView) {
        _mySlideView = ({
            __weak typeof(self) weakSelf = self;
            AutoSlideScrollView *slideView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, _padding_top, _image_width, _image_width * _ratio) animationDuration:5.0];
//            slideView.layer.cornerRadius = 2.0;
            slideView.layer.masksToBounds = YES;
            slideView.scrollView.scrollsToTop = NO;
            
            slideView.totalPagesCount = ^NSInteger(){
                return weakSelf.curBannerList.count;
            };
            slideView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
                if (weakSelf.curBannerList.count > pageIndex) {
                    UIImageView *imageView = [weakSelf p_reuseViewForIndex:pageIndex];
                    CodingBanner *curBanner = weakSelf.curBannerList[pageIndex];
                    [imageView sd_setImageWithURL:[curBanner.image urlWithCodePath]];
                    return imageView;
                }else{
                    return [UIView new];
                }
            };
            slideView.currentPageIndexChangeBlock = ^(NSInteger currentPageIndex){
                if (weakSelf.curBannerList.count > currentPageIndex) {
                    CodingBanner *curBanner = weakSelf.curBannerList[currentPageIndex];
                    weakSelf.typeLabel.text = curBanner.name;
                    weakSelf.titleLabel.text = curBanner.title;
                }else{
                    weakSelf.typeLabel.text = weakSelf.titleLabel.text = @"...";
                }
                weakSelf.myPageControl.currentPage = currentPageIndex;
            };
            slideView.tapActionBlock = ^(NSInteger pageIndex){
                if (weakSelf.tapActionBlock && weakSelf.curBannerList.count > pageIndex) {
                    weakSelf.tapActionBlock(weakSelf.curBannerList[pageIndex]);
                }
            };
            
            slideView;
        });
        [self addSubview:_mySlideView];
    }
    [self reloadData];
    NSLog(@"%@", _curBannerList);
}

- (UIImageView *)p_reuseViewForIndex:(NSInteger)pageIndex{
    if (!_imageViewList) {
        _imageViewList = [[NSMutableArray alloc] initWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, _padding_top, _image_width, _image_width * _ratio)];
            view.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
            view.clipsToBounds = YES;
            view.contentMode = UIViewContentModeScaleAspectFill;
            [_imageViewList addObject:view];
        }
    }
    UIImageView *imageView;
    NSInteger currentPageIndex = self.mySlideView.currentPageIndex;
    if (pageIndex == currentPageIndex) {
        imageView = _imageViewList[1];
    }else if (pageIndex == currentPageIndex + 1
              || (labs(pageIndex - currentPageIndex) > 1 && pageIndex < currentPageIndex)){
        imageView = _imageViewList[2];
    }else{
        imageView = _imageViewList[0];
    }
    return imageView;
}

- (void)reloadData{
    self.hidden = _curBannerList.count <= 0;
    if (_curBannerList.count <= 0) {
        return;
    }
    
    NSInteger currentPageIndex = MIN(self.mySlideView.currentPageIndex, _curBannerList.count - 1) ;
    CodingBanner *curBanner = _curBannerList[currentPageIndex];
    _titleLabel.text = curBanner.title;
    _typeLabel.text = curBanner.name;
    
    _myPageControl.numberOfPages = _curBannerList.count;
    _myPageControl.currentPage = currentPageIndex;
    
    [_mySlideView reloadData];
}

@end
