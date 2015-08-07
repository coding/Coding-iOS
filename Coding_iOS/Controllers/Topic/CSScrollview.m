//
//  CSScrollview.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSScrollview.h"

@interface CSScrollview () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView* listView;
@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation CSScrollview

- (instancetype)initWithFrame:(CGRect)frame layout:(UICollectionViewFlowLayout*)layout
{
    self = [super initWithFrame:frame];
    if (self) {
        _listView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.backgroundColor = [UIColor clearColor];
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.pagingEnabled = YES;
        
        [_listView registerClass:[CSScrollUnit class] forCellWithReuseIdentifier:@"CSScrollUnit"];
        [self addSubview:_listView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControl.pageIndicatorTintColor = [UIColor greenColor];
//        [_pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged]; //用户点击UIPageControl的响应函数
        [self addSubview:_pageControl];
    }
    return self;
}

- (void)update:(NSArray*)datas
{
    if (datas.count > 0) {
        
//        dispatch_sync(dispatch_get_main_queue(),^{
            _items = [NSArray arrayWithArray:datas];
            [_listView reloadData];
            _pageControl.currentPage = 0;
            _pageControl.numberOfPages = _items.count;
            CGSize size= [_pageControl sizeForNumberOfPages:_items.count];
            _pageControl.size = CGSizeMake(size.width, 20);
            _pageControl.bottom = self.height;
            _pageControl.centerX = self.width/2;
            
            if (self.autoScrollEnable) {
                [self beginAutoScroll];
            }
//        });
        
    }
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    self.pageControl.hidden = !showPageControl;
}

#pragma mark - autoscroll

- (void)beginAutoScroll
{
    if (!_autoScrollEnable) {
        return;
    }
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:CSScrollTime target:self selector:@selector(didAutoScroll) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)didAutoScroll
{
    if (!_items || _items.count == 0) {
        return;
    }
    
    NSInteger curIndex = _pageControl.currentPage;
    NSInteger willIndex = (curIndex + 1) % _pageControl.numberOfPages;
    NSIndexPath* path = [NSIndexPath indexPathForRow:willIndex inSection:0];
    
    [_listView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    _pageControl.currentPage = willIndex;
    
    //        [self beginAutoScroll];
}

#pragma mark -

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    if (_tapBlk) {
        _tapBlk(_items[indexPath.row]);
    }
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CSScrollUnit* unit = [collectionView dequeueReusableCellWithReuseIdentifier:@"CSScrollUnit" forIndexPath:indexPath];
    unit.refIteml = _items[indexPath.row];
    return unit;
}

//- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView
//{
//    [self beginAutoScroll];
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    //更新UIPageControl的当前页
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    [_pageControl setCurrentPage:offset.x / bounds.size.width];
    
    if (!_autoScrollEnable) {
        return;
    }
    
    NSArray* visiblelist = self.listView.visibleCells;
    if (visiblelist.count == 1) {
        UICollectionViewCell* visibleCell = visiblelist.lastObject;
        NSIndexPath* curIndexPath = [self.listView indexPathForCell:visibleCell];
        _pageControl.currentPage = curIndexPath.row;
    }
}

//- (void)pageTurn:(UIPageControl*)sender
//{
//    //令UIScrollView做出相应的滑动显示
//    CGSize viewSize = _listView.frame.size;
//    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
//    [_listView scrollRectToVisible:rect animated:YES];
//}


@end


@implementation CSScrollItem

+ (instancetype)itemWithData:(id)data imgUrl:(NSString*)imgUrl
{
    CSScrollItem* item = [[CSScrollItem alloc] init];
    item.data = data;
    item.imgUrl = imgUrl;
    return item;
}

@end

@implementation CSScrollUnit {
    UIImageView* _imgView;
}
- (void)setRefIteml:(CSScrollItem*)refIteml
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _imgView.backgroundColor = kColorTableBG;
        [self.contentView addSubview:_imgView];
    }
    [_imgView sd_setImageWithURL:[NSURL URLWithString:refIteml.imgUrl]];
}

@end

