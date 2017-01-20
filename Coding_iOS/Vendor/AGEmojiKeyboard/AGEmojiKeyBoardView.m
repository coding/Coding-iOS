//
//  AGEmojiKeyboardView.m
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "AGEmojiKeyBoardView.h"
#import "AGEmojiPageView.h"
#import "SMPageControl.h"
static const NSUInteger DefaultRecentEmojisMaintainedCount = 50;

static NSString *const segmentRecentName = @"Recent";
NSString *const RecentUsedEmojiCharactersKey = @"RecentUsedEmojiCharactersKey";


@interface AGEmojiKeyboardView () <UIScrollViewDelegate, AGEmojiPageViewDelegate>

//@property (nonatomic) UISegmentedControl *segmentsBar;
@property (nonatomic, strong) UIEaseTabBar *easeTabBar;
@property (nonatomic) SMPageControl *pageControl;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSDictionary *emojis;
@property (nonatomic) NSMutableArray *pageViews;
@property (nonatomic) NSString *category;

@end

@implementation AGEmojiKeyboardView

- (NSDictionary *)emojis {
    if (!_emojis) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion_list"
                                                              ofType:@"plist"];
        _emojis = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
        DebugLog(@"File read");
    }
    return _emojis;
}

- (NSString *)categoryNameAtIndex:(NSUInteger)index {
    //    NSArray *categoryList = @[segmentRecentName, @"People", @"Objects", @"Nature", @"Places", @"Symbols"];
    NSArray *categoryList = @[@"emoji", @"emoji_code", @"big_monkey", @"big_monkey_gif"];
    return index < categoryList.count? categoryList[index]: categoryList.lastObject;
}

- (AGEmojiKeyboardViewCategoryImage)defaultSelectedCategory {
    if ([self.dataSource respondsToSelector:@selector(defaultCategoryForEmojiKeyboardView:)]) {
        return [self.dataSource defaultCategoryForEmojiKeyboardView:self];
    }
    return AGEmojiKeyboardViewCategoryImageEmoji;
}

- (NSUInteger)recentEmojisMaintainedCount {
    if ([self.dataSource respondsToSelector:@selector(recentEmojisMaintainedCountForEmojiKeyboardView:)]) {
        return [self.dataSource recentEmojisMaintainedCountForEmojiKeyboardView:self];
    }
    return DefaultRecentEmojisMaintainedCount;
}

- (NSArray *)imagesForSelectedSegments {
    static NSMutableArray *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [NSMutableArray array];
        for (int i = 0;
             i < self.emojis.allKeys.count;
             ++i) {
            [array addObject:[self.dataSource emojiKeyboardView:self imageForSelectedCategory:i]];
        }
    });
    return array;
}

- (NSArray *)imagesForNonSelectedSegments {
    static NSMutableArray *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [NSMutableArray array];
        for (int i = 0;
             i < self.emojis.allKeys.count;
             ++i) {
            [array addObject:[self.dataSource emojiKeyboardView:self imageForNonSelectedCategory:i]];
        }
    });
    return array;
}

// recent emojis are backed in NSUserDefaults to save them across app restarts.
- (NSMutableArray *)recentEmojis {
    NSArray *emojis = [[NSUserDefaults standardUserDefaults] arrayForKey:RecentUsedEmojiCharactersKey];
    NSMutableArray *recentEmojis = [emojis mutableCopy];
    if (recentEmojis == nil) {
        recentEmojis = [NSMutableArray array];
    }
    return recentEmojis;
}

- (void)setRecentEmojis:(NSMutableArray *)recentEmojis {
    // remove emojis if they cross the cache maintained limit
    if ([recentEmojis count] > self.recentEmojisMaintainedCount) {
        NSIndexSet *indexesToBeRemoved = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.recentEmojisMaintainedCount, [recentEmojis count] - self.recentEmojisMaintainedCount)];
        [recentEmojis removeObjectsAtIndexes:indexesToBeRemoved];
    }
    [[NSUserDefaults standardUserDefaults] setObject:recentEmojis forKey:RecentUsedEmojiCharactersKey];
}

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<AGEmojiKeyboardViewDataSource>)dataSource  showBigEmotion:(BOOL)showBigEmotion{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kColorNavBG;
        // initialize category
        _dataSource = dataSource;
        self.category = [self categoryNameAtIndex:self.defaultSelectedCategory];
        CGFloat easeTabBar_Height = 36.0;
        CGFloat self_Height = CGRectGetHeight(self.bounds);
        __weak typeof(self) weakSelf = self;
        if (!showBigEmotion) {
            self.easeTabBar = [[UIEaseTabBar alloc] initWithFrame:CGRectMake(0, (self_Height - easeTabBar_Height), CGRectGetWidth(self.bounds), easeTabBar_Height)
                                                   selectedImages:[self.imagesForSelectedSegments objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]]
                                                 unSelectedImages:[self.imagesForNonSelectedSegments objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]]];
        }else{
            self.easeTabBar = [[UIEaseTabBar alloc] initWithFrame:CGRectMake(0, (self_Height - easeTabBar_Height), CGRectGetWidth(self.bounds), easeTabBar_Height)
                                                   selectedImages:self.imagesForSelectedSegments
                                                 unSelectedImages:self.imagesForNonSelectedSegments];
        }
        self.easeTabBar.selectedIndexChangedBlock = ^(UIEaseTabBar *sender){
            [weakSelf categoryChangedViaSegmentsBar:sender];
        };
        self.easeTabBar.sendButtonClickedBlock = ^(){
            DebugLog(@"ease Send");
            [weakSelf.delegate emojiKeyBoardViewDidPressSendButton:weakSelf];
        };
        self.easeTabBar.selectedIndex = self.defaultSelectedCategory;
        [self addSubview:self.easeTabBar];
        
        self.pageControl = [[SMPageControl alloc] init];
        self.pageControl.pageIndicatorImage = [UIImage imageNamed:@"keyboard_page_unselected"];
        self.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"keyboard_page_selected"];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.backgroundColor = [UIColor clearColor];
        CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
        NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                      inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.easeTabBar.bounds) - pageControlSize.height)];
        self.pageControl.numberOfPages = numberOfPages;
        pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
        self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                                           CGRectGetHeight(self.bounds)- easeTabBar_Height - pageControlSize.height- 10.0,
                                                           pageControlSize.width,
                                                           pageControlSize.height));
        [self.pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
        self.pageControl.currentPage = 0;
        [self addSubview:self.pageControl];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(self.bounds),
                                                                         CGRectGetHeight(self.bounds) - CGRectGetHeight(self.easeTabBar.bounds) - pageControlSize.height -20.0)];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
    NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                  inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.easeTabBar.bounds) - pageControlSize.height)];
    
    NSInteger currentPage = (self.pageControl.currentPage > numberOfPages) ? numberOfPages : self.pageControl.currentPage;
    
    // if (currentPage > numberOfPages) it is set implicitly to max pageNumber available
    self.pageControl.numberOfPages = numberOfPages;
    pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
    self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                                       CGRectGetHeight(self.bounds) - CGRectGetHeight(self.easeTabBar.bounds) - pageControlSize.height- 10.0,
                                                       pageControlSize.width,
                                                       pageControlSize.height));
    
    self.scrollView.frame = CGRectMake(0,
                                       0,
                                       CGRectGetWidth(self.bounds),
                                       CGRectGetHeight(self.bounds) - CGRectGetHeight(self.easeTabBar.bounds) - pageControlSize.height- 20.0);
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds) * currentPage, 0);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * numberOfPages, CGRectGetHeight(self.scrollView.bounds));
    [self purgePageViews];
    self.pageViews = [NSMutableArray array];
    [self setPage:currentPage];
}

#pragma mark event handlers

- (void)categoryChangedViaSegmentsBar:(UIEaseTabBar *)sender {
    // recalculate number of pages for new category and recreate emoji pages
    DebugLog(@"%@", @( sender.selectedIndex ));
    
    self.category = [self categoryNameAtIndex:sender.selectedIndex];
    self.pageControl.currentPage = 0;
    [self setNeedsLayout];
}

- (void)pageControlTouched:(UIPageControl *)sender {
    DebugLog(@"%@", @( sender.currentPage ));
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
    bounds.origin.y = 0;
    // scrollViewDidScroll is called here. Page set at that time.
    [self.scrollView scrollRectToVisible:bounds animated:YES];
}

// Track the contentOffset of the scroll view, and when it passes the mid
// point of the current view’s width, the views are reconfigured.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.pageControl.currentPage == newPageNumber) {
        return;
    }
    self.pageControl.currentPage = newPageNumber;
    [self setPage:self.pageControl.currentPage];
}

#pragma mark change a page on scrollView

// Check if setting pageView for an index is required
- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
    if (index >= self.pageControl.numberOfPages) {
        return NO;
    }
    for (AGEmojiPageView *page in self.pageViews) {
        if ((page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds)) == index) {
            return NO;
        }
    }
    return YES;
}

// Create a pageView and add it to the scroll view.
- (AGEmojiPageView *)synthesizeEmojiPageView {
    CGSize frameSize = self.scrollView.bounds.size;
    CGFloat btnWidth, btnHeight;
    if ([self.category hasPrefix:@"big_"]) {
        btnWidth = floor(frameSize.width/4.0);
        btnHeight = floor(frameSize.height/2.0);
    }else{
        btnWidth = floor(frameSize.width/7.0);
        btnHeight = floor(frameSize.height/3.0);
    }
    
    NSUInteger rows = [self numberOfRowsForFrameSize:self.scrollView.bounds.size];
    NSUInteger columns = [self numberOfColumnsForFrameSize:self.scrollView.bounds.size];
    
    AGEmojiPageView *pageView = [[AGEmojiPageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))
                                                  backSpaceButtonImage:[self.dataSource backSpaceButtonImageForEmojiKeyboardView:self]
                                                            buttonSize:CGSizeMake(btnWidth, btnHeight)
                                                                  rows:rows
                                                               columns:columns];
    pageView.delegate = self;
    [self.pageViews addObject:pageView];
    [self.scrollView addSubview:pageView];
    return pageView;
}

// return a pageView that can be used in the current scrollView.
// look for an available pageView in current pageView-s on scrollView.
// If all are in use i.e. are of current page or neighbours
// of current page, we create a new one

- (AGEmojiPageView *)usableEmojiPageView {
    AGEmojiPageView *pageView = nil;
    for (AGEmojiPageView *page in self.pageViews) {
        NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds);
        if (abs((int)(pageNumber - self.pageControl.currentPage)) > 1) {
            pageView = page;
            break;
        }
    }
    if (!pageView) {
        pageView = [self synthesizeEmojiPageView];
    }
    return pageView;
}

// Set emoji page view for given index.
- (void)setEmojiPageViewInScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {
    
    if (![self requireToSetPageViewForIndex:index]) {
        return;
    }
    
    AGEmojiPageView *pageView = [self usableEmojiPageView];
    
    NSUInteger rows = [self numberOfRowsForFrameSize:scrollView.bounds.size];
    NSUInteger columns = [self numberOfColumnsForFrameSize:scrollView.bounds.size];
    NSInteger numberOfEmojisOnAPage;
    if ([self.category hasPrefix:@"big_"]) {
        numberOfEmojisOnAPage = rows * columns;
    }else{
        numberOfEmojisOnAPage = rows * columns - 1;
    }
    NSUInteger startingIndex = index * numberOfEmojisOnAPage;
    NSUInteger endingIndex = (index + 1) * numberOfEmojisOnAPage;
    NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category
                                                    fromIndex:startingIndex
                                                      toIndex:endingIndex];
    DebugLog(@"Setting page at index %@", @( index ));
    [pageView setButtonTexts:buttonTexts forCategory:self.category];
    pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds), 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
}

// Set the current page.
// sets neightbouring pages too, as they are viewable by part scrolling.
- (void)setPage:(NSInteger)page {
    [self setEmojiPageViewInScrollView:self.scrollView atIndex:page - 1];
    [self setEmojiPageViewInScrollView:self.scrollView atIndex:page];
    [self setEmojiPageViewInScrollView:self.scrollView atIndex:page + 1];
}

- (void)purgePageViews {
    for (AGEmojiPageView *page in self.pageViews) {
        page.delegate = nil;
    }
    self.pageViews = nil;
}

#pragma mark data methods

- (NSUInteger)numberOfColumnsForFrameSize:(CGSize)frameSize {
    NSInteger columns;
    if ([self.category hasPrefix:@"big_"]) {
        columns = 4;
    }else{
        columns = 7;
    }
    return columns;
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
    NSInteger rows;
    if ([self.category hasPrefix:@"big_"]) {
        rows = 2;
    }else{
        rows = 3;
    }
    return rows;
}

- (NSArray *)emojiListForCategory:(NSString *)category {
    if ([category isEqualToString:segmentRecentName]) {
        return [self recentEmojis];
    }
    return [self.emojis objectForKey:category];
}

// for a given frame size of scroll view, return the number of pages
// required to show all the emojis for a category
- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrameSize:(CGSize)frameSize {
    
    if ([category isEqualToString:segmentRecentName]) {
        return 1;
    }
    
    NSUInteger emojiCount = [[self emojiListForCategory:category] count];
    NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
    NSUInteger numberOfColumns = [self numberOfColumnsForFrameSize:frameSize];
    NSUInteger numberOfEmojisOnAPage;
    if ([category hasPrefix:@"big_"]) {
        numberOfEmojisOnAPage = (numberOfRows * numberOfColumns);
    }else{
        numberOfEmojisOnAPage = (numberOfRows * numberOfColumns) - 1;
    }
    NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
    DebugLog(@"%@ %@ %@ :: %@", @( numberOfRows ), @( numberOfColumns ), @( emojiCount ), @( numberOfPages ));
    return numberOfPages;
}

// return the emojis for a category, given a staring and an ending index
- (NSMutableArray *)emojiTextsForCategory:(NSString *)category fromIndex:(NSUInteger)start toIndex:(NSUInteger)end {
    NSArray *emojis = [self emojiListForCategory:category];
    end = ([emojis count] > end)? end : [emojis count];
    NSIndexSet *index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)];
    return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark EmojiPageViewDelegate

- (void)setInRecentsEmoji:(NSString *)emoji {
    NSAssert(emoji != nil, @"Emoji can't be nil");
    
    NSMutableArray *recentEmojis = [self recentEmojis];
    for (int i = 0; i < [recentEmojis count]; ++i) {
        if ([recentEmojis[i] isEqualToString:emoji]) {
            [recentEmojis removeObjectAtIndex:i];
        }
    }
    [recentEmojis insertObject:emoji atIndex:0];
    [self setRecentEmojis:recentEmojis];
}

// add the emoji to recents
- (void)emojiPageView:(AGEmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji {
    [self setInRecentsEmoji:emoji];
    [self.delegate emojiKeyBoardView:self didUseEmoji:emoji];
}

- (void)emojiPageViewDidPressBackSpace:(AGEmojiPageView *)emojiPageView {
    DebugLog(@"Back button pressed");
    [self.delegate emojiKeyBoardViewDidPressBackSpace:self];
}

- (void)setDoneButtonTitle:(NSString *)doneStr{
    [self.easeTabBar.sendButton setTitle:doneStr forState:UIControlStateNormal];
}
@end


@interface UIEaseTabBar ()
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSArray *selectedImages, *unSelectedImages;
@property (nonatomic) NSMutableArray *tabButtons;
@property (nonatomic) CGFloat buttonWidth;
@end


@implementation UIEaseTabBar
- (instancetype)initWithFrame:(CGRect)frame selectedImages:(NSArray *)selectedImages unSelectedImages:(NSArray *)unSelectedImages{
    self = [super initWithFrame:frame];
    if (self) {
        [self addLineUp:YES andDown:NO andColor:kColorDDD];
        self.selectedImages = selectedImages;
        self.unSelectedImages = unSelectedImages;
        self.numOfTabs = selectedImages.count;
        self.buttonWidth = 60.0;
        self.tabButtons = [[NSMutableArray alloc] init];
        [self configScrollView];
        [self configSendButton];
        _selectedIndex = -1;
        self.selectedIndex = 0;
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    if (selectedIndex != _selectedIndex) {
        _selectedIndex = selectedIndex;
        for (int i=0; i<_numOfTabs; i++) {
            UIButton *tabButton = self.tabButtons[i];
            if (i==selectedIndex) {
                [tabButton setImage:self.selectedImages[i] forState:UIControlStateNormal];
                [tabButton setBackgroundColor:kColorNavBG];
            }else{
                [tabButton setImage:self.unSelectedImages[i] forState:UIControlStateNormal];
                [tabButton setBackgroundColor:[UIColor clearColor]];
            }
        }
    }
}

- (UIButton *)tabButtonWithIndex:(NSInteger)index{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_buttonWidth *index, 0, _buttonWidth, CGRectGetHeight(self.frame))];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_buttonWidth-0.5, 0, 0.5, CGRectGetHeight(self.frame))];
    lineView.backgroundColor = kColorDDD;
    [button addSubview:lineView];
    [button addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)configScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) -_buttonWidth, CGRectGetHeight(self.frame))];
    self.scrollView.delegate = nil;
    [self addSubview:self.scrollView];
    for (int i=0; i<self.numOfTabs; i++) {
        UIButton *button = [self tabButtonWithIndex:i];
        [self.scrollView addSubview:button];
        [self.tabButtons addObject:button];
    }
}
- (void)configSendButton{
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) -self.buttonWidth, 0, self.buttonWidth, CGRectGetHeight(self.frame))];
    [self.sendButton setBackgroundColor:kColorBrandGreen];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
}

- (void)sendButtonClicked:(id)sender{
    if (self.sendButtonClickedBlock) {
        self.sendButtonClickedBlock();
    }
}

- (void)tabButtonClicked:(id)sender{
    NSInteger index = [self.tabButtons indexOfObject:sender];
    if (index != NSNotFound && index != _selectedIndex) {
        self.selectedIndex = index;
        if (self.selectedIndexChangedBlock) {
            self.selectedIndexChangedBlock(self);
        }
    }
}

@end
