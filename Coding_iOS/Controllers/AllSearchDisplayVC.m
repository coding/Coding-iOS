//
//  AllSearchDisplayVC.m
//  Coding_iOS
//
//  Created by jwill on 15/11/19.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "AllSearchDisplayVC.h"
#import "TopicHotkeyView.h"
#import "Coding_NetAPIManager.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "XHRealTimeBlur.h"
#import "CSSearchModel.h"
#import "RKSwipeBetweenViewControllers.h"
#import "CSHotTopicView.h"
#import "CSMyTopicVC.h"
#import "UserInfoViewController.h"
#import "WebViewController.h"
#import "CSHotTopicPagesVC.h"
#import "CSTopicDetailVC.h"
#import "PublicSearchModel.h"
#import "Login.h"
#import "NSString+Attribute.h"

// cell--------------
#import "ProjectAboutMeListCell.h"
#import "FileSearchCell.h"
#import "TweetSearchCell.h"
#import "UserSearchCell.h"
#import "TaskSearchCell.h"
#import "TopicSearchCell.h"
#import "PRMRSearchCell.h"

// nav--------
#import "TweetDetailViewController.h"
#import "ConversationViewController.h"

#import "iCarousel.h"
#import "XTSegmentControl.h"

@interface AllSearchDisplayVC () <UISearchBarDelegate, UIScrollViewDelegate, iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) XHRealTimeBlur *backgroundView;
@property (nonatomic, strong) UIButton *btnMore;
@property (nonatomic, strong) TopicHotkeyView *topicHotkeyView;

@property (nonatomic, strong) UIView *searchResultView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) PublicSearchModel *searchPros;
@property (nonatomic, strong) UIScrollView  *searchHistoryView;
@property (nonatomic, assign) double historyHeight;
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) iCarousel *myCarousel;

- (void)initSearchResultsTableView;
- (void)initSearchHistoryView;
- (void)didClickedMoreHotkey:(UIGestureRecognizer *)sender;
- (void)didCLickedCleanSearchHistory:(id)sender;
- (void)didClickedContentView:(UIGestureRecognizer *)sender;
- (void)didClickedHistory:(UIGestureRecognizer *)sender;

@end

@implementation AllSearchDisplayVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _searchHistoryView.delegate = nil;
}

- (NSArray *)titlesArray{
    if (!_titlesArray) {
        _titlesArray = @[@"项目", @"任务", @"讨论", @"冒泡", @"文档", @"用户", @"合并请求", @"Pull 请求"];
    }
    return _titlesArray;
}

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    
    if(!visible) {
        
        [_searchResultView removeFromSuperview];
        [_backgroundView removeFromSuperview];
        [_contentView removeFromSuperview];
        
        _searchResultView = nil;
        _contentView = nil;
        _backgroundView = nil;
        _searchHistoryView = nil;
        
        [super setActive:visible animated:animated];
    }else {
        
        [super setActive:visible animated:animated];
        NSArray *subViews = self.searchContentsController.view.subviews;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
            
            for (UIView *view in subViews) {
                
                if ([view isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                    
                    NSArray *sub = view.subviews;
                    ((UIView*)sub[2]).hidden = YES;
                }
            }
        } else {
            
            [[subViews lastObject] removeFromSuperview];
        }
        
        if(!_contentView) {
            
            _contentView = ({
                
                UIView *view = [[UIView alloc] init];
                view.frame = CGRectMake(0.0f, 0, kScreen_Width, kScreen_Height - 60.0f);
                view.backgroundColor = [UIColor clearColor];
                view.userInteractionEnabled = YES;
                
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
                [view addGestureRecognizer:tapGestureRecognizer];
                
                view;
            });
            
            _backgroundView = ({
                XHRealTimeBlur *blur = [[XHRealTimeBlur alloc] initWithFrame:_contentView.frame];
                blur.blurStyle = XHBlurStyleTranslucentWhite;
                blur;
                
            });
            _backgroundView.userInteractionEnabled = NO;
            
            [self initSearchHistoryView];
        }
        
        
        [self.parentVC.view addSubview:_backgroundView];
        [self.parentVC.view addSubview:_contentView];
        [self.parentVC.view bringSubviewToFront:_contentView];
        self.searchBar.delegate = self;
    }
}

#pragma mark - UI

- (void)initSearchResultsTableView {
    if (!self.searchResultView) {
        self.searchResultView = [[UIView alloc] initWithFrame:_contentView.bounds];
        //添加myCarousel
        self.myCarousel = ({
            CGRect iFrame = _contentView.bounds;
            iFrame.origin.y = kMySegmentControl_Height;
            iFrame.size.height -= kMySegmentControl_Height;
            iCarousel *icarousel = [[iCarousel alloc] initWithFrame:iFrame];
            icarousel.dataSource = self;
            icarousel.delegate = self;
            icarousel.decelerationRate = 1.0;
            icarousel.scrollSpeed = 1.0;
            icarousel.type = iCarouselTypeLinear;
            icarousel.pagingEnabled = YES;
            icarousel.clipsToBounds = YES;
            icarousel.bounceDistance = 0.2;
            [self.searchResultView addSubview:icarousel];
            icarousel;
        });
        
        //添加滑块
        __weak typeof(_myCarousel) weakCarousel = _myCarousel;
        
        self.mySegmentControl = [[XTSegmentControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kMySegmentControl_Height) Items:self.titlesArray selectedBlock:^(NSInteger index) {
            [weakCarousel scrollToItemAtIndex:index animated:NO];
        }];
        self.mySegmentControl.backgroundColor = kColorNavBG;
        
        [self.searchResultView addSubview:self.mySegmentControl];
        [self.parentVC.view addSubview:self.searchResultView];
    }
    [_searchResultView.superview bringSubviewToFront:_searchResultView];
    [self refresh];
}

- (void)initSearchHistoryView {
    
    if(!_searchHistoryView) {
        
        _searchHistoryView = [[UIScrollView alloc] init];
        _searchHistoryView.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_searchHistoryView];
        self.searchBar.delegate=self;
        [self registerForKeyboardNotifications];
    }
    [[_searchHistoryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSArray *array = [CSSearchModel getSearchHistory];
    if (array.count > 0) {
        CGFloat imageLeft = 12.0f;
        CGFloat textLeft = 34.0f;
        CGFloat height = 44.0f;
        _historyHeight=height*(array.count+1);
        //set history list
        [_searchHistoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(@0);
            make.left.mas_equalTo(@0);
            make.width.mas_equalTo(kScreen_Width);
            make.height.mas_equalTo(_historyHeight);
        }];
        _searchHistoryView.contentSize = CGSizeMake(kScreen_Width, _historyHeight);
        for (int i = 0; i < array.count; i++) {
            UILabel *lblHistory = [[UILabel alloc] initWithFrame:CGRectMake(textLeft, i * height, kScreen_Width - textLeft, height)];
            lblHistory.userInteractionEnabled = YES;
            lblHistory.font = [UIFont systemFontOfSize:14];
            lblHistory.textColor = kColor222;
            lblHistory.text = array[i];
            
            UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
            leftView.left = 12;
            leftView.centerY = lblHistory.centerY;
            leftView.image = [UIImage imageNamed:@"icon_search_clock"];
            
            UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
            rightImageView.right = kScreen_Width - 12;
            rightImageView.centerY = lblHistory.centerY;
            rightImageView.image = [UIImage imageNamed:@"icon_arrow_searchHistory"];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(imageLeft, (i + 1) * height, kScreen_Width - imageLeft, 0.5)];
            view.backgroundColor = kColorDDD;
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedHistory:)];
            [lblHistory addGestureRecognizer:tapGestureRecognizer];
            
            [_searchHistoryView addSubview:lblHistory];
            [_searchHistoryView addSubview:leftView];
            [_searchHistoryView addSubview:rightImageView];
            [_searchHistoryView addSubview:view];
        }
        {
            UIButton *btnClean = [UIButton buttonWithType:UIButtonTypeCustom];
            btnClean.titleLabel.font = [UIFont systemFontOfSize:14];
            [btnClean setTitle:@"清除搜索历史" forState:UIControlStateNormal];
            [btnClean setTitleColor:[UIColor colorWithHexString:@"0x1bbf75"] forState:UIControlStateNormal];
            [btnClean setFrame:CGRectMake(0, array.count * height, kScreen_Width, height)];
            [_searchHistoryView addSubview:btnClean];
            [btnClean addTarget:self action:@selector(didCLickedCleanSearchHistory:) forControlEvents:UIControlEventTouchUpInside];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(imageLeft, (array.count + 1) * height, kScreen_Width - imageLeft, 0.5)];
            view.backgroundColor = kColorDDD;
            [_searchHistoryView addSubview:view];
        }


    }else{
        _historyHeight = kScreen_Height - 236 - 64;
        //set history list
        [_searchHistoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(@0);
            make.left.mas_equalTo(@0);
            make.width.mas_equalTo(kScreen_Width);
            make.height.mas_equalTo(_historyHeight);
        }];
        _searchHistoryView.contentSize = CGSizeMake(kScreen_Width, _historyHeight);
        CGFloat designScale = (kScreen_Width/ 375);
        CGFloat tipVWidth = 210 * designScale;
        CGFloat imageWidth = 24 * designScale;
        CGFloat paddingWidth = MAX(0, (tipVWidth - 4* imageWidth)/ 3);
        CGFloat fontSize = 13 * designScale;

        UIView *tipV = [UIView new];
        UILabel *titleL = [UILabel labelWithSystemFontSize:15 * designScale textColorHexString:@"0x999999"];
        titleL.text = @"搜索更多内容";
        UIView *lineV = [UIView new];
        lineV.backgroundColor = kColorDDD;
        [tipV addSubview:titleL];
        [tipV addSubview:lineV];
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(tipV);
            make.top.equalTo(tipV).offset(50);
        }];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(tipV);
            make.top.equalTo(titleL.mas_bottom).offset(15);
            make.height.mas_equalTo(1);
        }];
        NSArray *imageArray = @[@"project", @"task", @"topic", @"tweet", @"file", @"user", @"mr", @"pr"];
        for (int index = 0; index < self.titlesArray.count && index < imageArray.count; index++) {
            UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"search_icon_%@", imageArray[index]]]];
            UILabel *label = [UILabel labelWithSystemFontSize:fontSize textColorHexString:@"0x999999"];
            label.text = self.titlesArray[index];
            [tipV addSubview:imageV];
            [tipV addSubview:label];
            [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(imageWidth, imageWidth));
                make.top.equalTo(lineV.mas_bottom).offset(20 + (imageWidth + 45) * (index / 4));
                make.left.equalTo(tipV).offset((paddingWidth + imageWidth) * (index % 4));
            }];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(imageV.mas_bottom).offset(10);
                make.centerX.equalTo(imageV);
            }];
        }
        [_searchHistoryView addSubview:tipV];
        [tipV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_searchHistoryView);
            make.left.equalTo(_searchHistoryView).offset((kScreen_Width - tipVWidth)/ 2);
            make.size.mas_equalTo(CGSizeMake(tipVWidth, _historyHeight));
        }];
    }
}

#pragma mark - event
- (void)didClickedMoreHotkey:(UIGestureRecognizer *)sender {
    [self.searchBar resignFirstResponder];
    
    CSHotTopicPagesVC *vc = [CSHotTopicPagesVC new];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
    
}

- (void)didCLickedCleanSearchHistory:(id)sender {
    
    [CSSearchModel cleanAllSearchHistory];
    [self initSearchHistoryView];
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender {
    
    [self.searchBar resignFirstResponder];
}

- (void)didClickedHistory:(UIGestureRecognizer *)sender {
    
    UILabel *label = (UILabel *)sender.view;
    self.searchBar.text = label.text;
    [CSSearchModel addSearchHistory:self.searchBar.text];
    [self initSearchHistoryView];
    [self.searchBar resignFirstResponder];
    [self initSearchResultsTableView];
}


#pragma mark -- goVC
- (void)cellClickedObj:(id)obj type:(eSearchType)type{
    if(type==eSearchType_Tweet) {
        [self goToTweet:obj];
    }else if(type==eSearchType_Project){
        [self goToProject:obj];
    }else if (type==eSearchType_Document){
        [self goToFileVC:obj];
    }else if (type==eSearchType_User){
        [self goToUserInfo:obj];
    }else if (type==eSearchType_Task){
        [self goToTask:obj];
    }else if (type==eSearchType_Topic){
        [self goToTopic:obj];
    }else if (type==eSearchType_Merge){
        [self goToMRDetail:obj];
    }else if(type==eSearchType_Pull){
        [self goToMRDetail:obj];
    }
}

- (void)goToProject:(Project *)project{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:project.project_path];
    [self.parentVC.navigationController pushViewController:vc animated:TRUE];
}

-(void)goToTweet:(Tweet *)tweet{
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.curTweet = tweet;
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToFileVC:(ProjectFile *)file{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:file.path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToUserInfo:(User *)user{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:user.path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToTask:(Task*)curTask{
    NSString *path=[NSString stringWithFormat:@"%@/task/%@",curTask.project.project_path,curTask.id];
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToTopic:(ProjectTopic*)curTopic{
    NSString *path=[NSString stringWithFormat:@"%@/topic/%@",curTopic.project.project_path,curTopic.id];
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToMRDetail:(MRPR *)curMR{
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:curMR.path];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}

- (void)goToConversation:(User *)curUser{
    ConversationViewController *vc = [[ConversationViewController alloc] init];
    User *copyUser=[curUser copy];
    copyUser.name=[NSString getStr:copyUser.name removeEmphasize:@"em"];
    copyUser.global_key=[NSString getStr:copyUser.global_key removeEmphasize:@"em"];
    copyUser.pinyinName=[NSString getStr:copyUser.pinyinName removeEmphasize:@"em"];
    vc.myPriMsgs = [PrivateMessages priMsgsWithUser:copyUser];
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}


#pragma mark -
#pragma mark Search Data Request

- (void)refresh {
    [self requestAll];
}

-(void)reloadDisplayData{
    for (CodingSearchDisplayView *view in _myCarousel.visibleItemViews) {
        view.searchBarText = self.searchBar.text;
        view.searchPros = _searchPros;
    }
}

-(void)requestAll{
    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:@"全局搜索_全部(发起请求)"];
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] requestWithSearchString:self.searchBar.text typeStr:@"all" andPage:1 andBlock:^(id data, NSError *error) {
        if(data) {
            weakSelf.searchPros = [NSObject objectOfClass:@"PublicSearchModel" fromJSON:data];
            NSDictionary *dataDic = (NSDictionary *)data;
            
            //topic 处理 content 关键字
            NSArray *resultTopic =[dataDic[@"project_topics"] objectForKey:@"list"] ;
            for (int i=0;i<[_searchPros.project_topics.list count];i++) {
                ProjectTopic *curTopic=[_searchPros.project_topics.list objectAtIndex:i];
                if ([resultTopic count]>i) {
                    curTopic.contentStr= [[[resultTopic objectAtIndex:i] objectForKey:@"content"] firstObject];
                }
            }
            
            //task 处理 description 关键字
            NSArray *resultTask =[dataDic[@"tasks"] objectForKey:@"list"] ;
            for (int i=0;i<[weakSelf.searchPros.tasks.list count];i++) {
                Task *curTask=[weakSelf.searchPros.tasks.list objectAtIndex:i];
                if ([resultTask count]>i) {
                    curTask.descript= [[[resultTask objectAtIndex:i] objectForKey:@"description"] firstObject];
                }
            }
            [weakSelf reloadDisplayData];
        }
    }];
}

- (void)analyseLinkStr:(NSString *)linkStr{
    if (linkStr.length <= 0) {
        return;
    }
    UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr];
    if (vc) {
        [self.parentVC.navigationController pushViewController:vc animated:YES];
    }else{
        //网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
        [self.parentVC.navigationController pushViewController:webVc animated:YES];
    }
}


- (void)registerForKeyboardNotifications
{
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
}

-(void)keyboardWasShown{
    if (_historyHeight+236>(kScreen_Height-64)) {
        [_searchHistoryView setHeight:kScreen_Height-236-64];
    }
}

-(void)keyboardWillBeHidden{
    if (_historyHeight+236>(kScreen_Height-64)) {
        [_searchHistoryView setHeight:_historyHeight];
    }
}

#pragma mark - UISearchBarDelegate Support

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [CSSearchModel addSearchHistory:searchBar.text];
    [self initSearchHistoryView];
    [self.searchBar resignFirstResponder];
    
    [self initSearchResultsTableView];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return TRUE;
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [self.titlesArray count];
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    CodingSearchDisplayView *listView = (CodingSearchDisplayView *)view;
    if (listView) {
        listView.curSearchType = index;
        listView.searchBarText = self.searchBar.text;
        listView.searchPros = _searchPros;
    }else{
        listView = [[CodingSearchDisplayView alloc] initWithFrame:carousel.bounds];
        listView.curSearchType = index;
        listView.searchBarText = self.searchBar.text;
        listView.searchPros = _searchPros;
        __weak typeof(self) weakSelf = self;
        [listView setCellClickedBlock:^(id clickedItem, eSearchType searType) {
            [weakSelf cellClickedObj:clickedItem type:searType];
        }];
        [listView setGoToConversationBlock:^(User *curUser) {
            [weakSelf goToConversation:curUser];
        }];
        [listView setRefreshAllBlock:^{
            [weakSelf refresh];
        }];
    }
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    if (_mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_mySegmentControl moveIndexWithProgress:offset];
        }
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    if (_mySegmentControl) {
        _mySegmentControl.currentIndex = carousel.currentItemIndex;
    }
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}


@end
