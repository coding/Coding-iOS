//
//  HotTopicBannerView.m
//  Coding_iOS
//
//  Created by Lambda on 15/8/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "HotTopicBannerView.h"
#import "SMPageControl.h"
#import "AutoSlideScrollView.h"
#import "YLImageView.h"

@interface HotTopicBannerView ()
@property (strong, nonatomic) SMPageControl *myPageControl;
@property (strong, nonatomic) AutoSlideScrollView *mySlideView;
@property (strong, nonatomic) NSMutableArray *imageViewList;
@end

@implementation HotTopicBannerView

- (instancetype)init
{
    
    self = [super init];
    if (self) {
        [self setSize:CGSizeMake(kScreen_Width, self.height)];
    }
    return self;
}

- (void)setCurBannerList:(NSArray *)curBannerList{
    _curBannerList = curBannerList;
    
    if (!_myPageControl) {
        _myPageControl = ({
            SMPageControl *pageControl = [[SMPageControl alloc] init];
            pageControl.userInteractionEnabled = NO;
            pageControl.backgroundColor = [UIColor clearColor];
            pageControl.pageIndicatorImage = [UIImage imageNamed:@"banner__page_unselected"];
            pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"banner__page_selected"];
            pageControl.frame = CGRectMake(0, 0, kScreen_Width, 0);
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
            AutoSlideScrollView *slideView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, self.height) animationDuration:5.0];
            slideView.layer.masksToBounds = YES;
            slideView.scrollView.scrollsToTop = NO;
            
            slideView.totalPagesCount = ^NSInteger(){
                return weakSelf.curBannerList.count;
            };
            slideView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
                if (weakSelf.curBannerList.count > pageIndex) {
                    YLImageView *imageView = [weakSelf p_reuseViewForIndex:pageIndex];
                    NSDictionary *curBanner = weakSelf.curBannerList[pageIndex];
                    
                    [imageView sd_setImageWithURL:[curBanner[@"image_url"] urlWithCodePath]];
                    return imageView;
                }else{
                    return [UIView new];
                }
            };
            slideView.currentPageIndexChangeBlock = ^(NSInteger currentPageIndex){
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

- (YLImageView *)p_reuseViewForIndex:(NSInteger)pageIndex{
    if (!_imageViewList) {
        _imageViewList = [[NSMutableArray alloc] initWithCapacity:3];
        for (int i = 0; i < 3; i++) {
            YLImageView *view = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, self.width,self.height)];
            view.backgroundColor = kColorTableBG;
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
    
    _myPageControl.numberOfPages = _curBannerList.count;
    _myPageControl.currentPage = currentPageIndex;
    
    [_mySlideView reloadData];
}


@end
