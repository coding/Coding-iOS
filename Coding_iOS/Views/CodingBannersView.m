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
#import "YLImageView.h"

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
        self.backgroundColor = kColorTableBG;
        _padding_top = 0;
        _padding_bottom = 40;
        _image_width = kScreen_Width;
        _ratio = 0.4;
        CGFloat viewHeight = _padding_top + _padding_bottom + _image_width * _ratio;
        [self setSize:CGSizeMake(kScreen_Width, viewHeight)];
        [self addLineUp:NO andDown:YES];
    }
    return self;
}

- (void)setCurBannerList:(NSArray *)curBannerList{
    if ([[_curBannerList valueForKey:@"title"] isEqualToArray:[curBannerList valueForKey:@"title"]]) {
        return;
    }
    _curBannerList = curBannerList;
    if (!_mySlideView) {
        _mySlideView = ({
            __weak typeof(self) weakSelf = self;
            AutoSlideScrollView *slideView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, _padding_top, _image_width, _image_width * _ratio) animationDuration:5.0];
            slideView.layer.masksToBounds = YES;
            slideView.scrollView.scrollsToTop = NO;
            
            slideView.totalPagesCount = ^NSInteger(){
                return weakSelf.curBannerList.count;
            };
            slideView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
                if (weakSelf.curBannerList.count > pageIndex) {
                    YLImageView *imageView = [weakSelf p_reuseViewForIndex:pageIndex];
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
                    weakSelf.typeLabel.text = curBanner.displayName;
                    weakSelf.titleLabel.text = curBanner.title;
                }else{
                    weakSelf.typeLabel.text = weakSelf.titleLabel.text = @"...    ";
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
    if (!_myPageControl) {
        _myPageControl = ({
            SMPageControl *pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 30, _mySlideView.bottom + (40 - 10)/2, 30, 10)];
            pageControl.userInteractionEnabled = NO;
            pageControl.backgroundColor = [UIColor clearColor];
            pageControl.pageIndicatorImage = [UIImage imageNamed:@"banner__page_unselected"];
            pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"banner__page_selected"];
            pageControl.numberOfPages = _curBannerList.count;
            pageControl.currentPage = 0;
            pageControl.alignment = SMPageControlAlignmentRight;
            pageControl;
        });
        [self addSubview:_myPageControl];
    }

    if (!_typeLabel) {
        _typeLabel = ({
            UILabel *label = [UILabel labelWithFont:[UIFont systemFontOfSize:10] textColor:kColor666];
            [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            [label doBorderWidth:0.5 color:nil cornerRadius:2.0];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"活动    ";
            label;
        });
        _typeLabel.text = [(CodingBanner *)_curBannerList.firstObject displayName];
        [self addSubview:_typeLabel];
    }
    
    if (!_titleLabel) {
        _titleLabel =  [UILabel labelWithFont:[UIFont systemFontOfSize:12] textColor:kColor222];
        _titleLabel.text = [(CodingBanner *)_curBannerList.firstObject title];
        [self addSubview:_titleLabel];
    }
    [_typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kPaddingLeftWidth);
        make.centerY.equalTo(_myPageControl);
        make.height.mas_equalTo(18);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_typeLabel.mas_right).offset(5);
        make.right.equalTo(_myPageControl.mas_left).offset(-5);
        make.centerY.equalTo(_myPageControl);
    }];
    [self reloadData];
    NSLog(@"%@", _curBannerList);
}

- (YLImageView *)p_reuseViewForIndex:(NSInteger)pageIndex{
    if (!_imageViewList) {
        _imageViewList = [[NSMutableArray alloc] initWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            YLImageView *view = [[YLImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, _padding_top, _image_width, _image_width * _ratio)];
            view.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
            view.clipsToBounds = YES;
            view.contentMode = UIViewContentModeScaleAspectFill;
            [_imageViewList addObject:view];
        }
    }
    YLImageView *imageView;
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
    _typeLabel.text = curBanner.displayName;
    
    _myPageControl.numberOfPages = _curBannerList.count;
    _myPageControl.currentPage = currentPageIndex;
    
    [_mySlideView reloadData];
}

@end
