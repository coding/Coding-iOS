//
//  Project_RootViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#import "Project_RootViewController.h"
#import "Coding_NetAPIManager.h"
#import "LoginViewController.h"
#import "ProjectListView.h"
#import "ProjectViewController.h"
#import "HtmlMedia.h"
#import "UnReadManager.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "NProjectViewController.h"
#import "ProjectListCell.h"
#import "TweetSendViewController.h"
#import "EditTaskViewController.h"
#import "AddUserViewController.h"
#import "UsersViewController.h"
#import "Ease_2FA.h"
#import "PopMenu.h"
#import "PopFliterMenu.h"
#import "ProjectSquareViewController.h"
#import "SearchViewController.h"
#import "pop.h"
#import "StartImagesManager.h"
#import "ZXScanCodeViewController.h"
#import "OTPListViewController.h"
#import "WebViewController.h"
#import "ProjectToChooseListViewController.h"

@interface Project_RootViewController ()
@property (strong, nonatomic) NSMutableDictionary *myProjectsDict;
@property (nonatomic, strong) PopMenu *myPopMenu;
@property (nonatomic, strong) PopFliterMenu *myFliterMenu;
@property (strong, nonatomic) UIButton *titleBtn;
@property (nonatomic,assign) NSInteger selectNum;  //筛选状态
@end
@implementation Project_RootViewController
#pragma mark TabBar
- (void)tabBarItemClicked{
    [super tabBarItemClicked];
    if (_myCarousel.currentItemView && [_myCarousel.currentItemView isKindOfClass:[ProjectListView class]]) {
        ProjectListView *listView = (ProjectListView *)_myCarousel.currentItemView;
        [listView tabBarItemClicked];
    }
}

- (BOOL)isRoot{
    return [self isMemberOfClass:[Project_RootViewController class]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSegmentItems];
    _useNewStyle = TRUE;
    _oldSelectedIndex = 0;
    _selectNum = 0;
    _myProjectsDict = [[NSMutableDictionary alloc] initWithCapacity:_segmentItems.count];
    //添加myCarousel
    _myCarousel = ({
        iCarousel *icarousel = [[iCarousel alloc] init];
        icarousel.dataSource = self;
        icarousel.delegate = self;
        icarousel.decelerationRate = 1.0;
        icarousel.scrollSpeed = 1.0;
        icarousel.type = iCarouselTypeLinear;
        icarousel.pagingEnabled = YES;
        icarousel.clipsToBounds = YES;
        icarousel.bounceDistance = 0.2;
        [self.view addSubview:icarousel];
        [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        icarousel;
    });
    __weak typeof(_myCarousel) weakCarousel = _myCarousel;
    //初始化过滤目录
    _myFliterMenu = [[PopFliterMenu alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64) items:nil];
    __weak typeof(self) weakSelf = self;
    _myFliterMenu.clickBlock = ^(NSInteger pageIndex){
        [weakSelf mobClickFliterMenuIndex:pageIndex];
        if (pageIndex==1000) {
            [weakSelf goToProjectSquareVC];
        }else{
            [weakCarousel scrollToItemAtIndex:pageIndex animated:NO];
            weakSelf.selectNum = pageIndex;
        }
    };
    _myFliterMenu.closeBlock=^(){
        [weakSelf closeFliter];
    };
    //初始化弹出菜单
    NSArray *menuItems = @[
                           [MenuItem itemWithTitle:@"项目" iconName:@"pop_Project" index:0],
                           [MenuItem itemWithTitle:@"任务" iconName:@"pop_Task" index:1],
                           [MenuItem itemWithTitle:@"冒泡" iconName:@"pop_Tweet" index:2],
                           [MenuItem itemWithTitle:@"添加好友" iconName:@"pop_User" index:3],
                           [MenuItem itemWithTitle:@"私信" iconName:@"pop_Message" index:4],
                           [MenuItem itemWithTitle:@"两步验证" iconName:@"pop_2FA" index:5],
                           ];
    if (!_myPopMenu) {
        _myPopMenu = [[PopMenu alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-64) items:menuItems];
        _myPopMenu.perRowItemCount = 3;
        _myPopMenu.menuAnimationType = kPopMenuAnimationTypeSina;
    }
    @weakify(self);
    _myPopMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem){
        @strongify(self);
        if (!selectedItem) return;
        [MobClick event:kUmeng_Event_Request_ActionOfLocal label:[NSString stringWithFormat:@"首页_添加_%@", selectedItem.title]];
        switch (selectedItem.index) {
            case 0:
                [self goToNewProjectVC];
                break;
            case 1:
                [self goToNewTaskVC];
                break;
            case 2:
                [self goToNewTweetVC];
                break;
            case 3:
                [self goToAddUserVC];
                break;
            case 4:
                [self goToMessageVC];
                break;
            case 5:
                [self goTo2FA];
                break;
            default:
                NSLog(@"%@",selectedItem.title);
                break;
        }
    };
    if ([self isRoot]) {
        [self setupTitleBtn];
    }
    [self setupNavBtn];
    self.icarouselScrollEnabled = NO;
    [[StartImagesManager shareManager] handleStartLink];//如果 start_image 有对应的 link 的话，需要进入到相应的 web 页面
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_myCarousel) {
        ProjectListView *listView = (ProjectListView *)_myCarousel.currentItemView;
        if (listView) {
            [listView refreshToQueryData];
        }
    }
    [_myFliterMenu refreshMenuDate];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeMenu];
    if (_myFliterMenu.showStatus) {
        [_myFliterMenu dismissMenu];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UnReadManager shareManager] updateUnRead];
}

- (void)mobClickFliterMenuIndex:(NSInteger)index{
    static NSArray *menuList;
    if (!menuList) {
        menuList = @[@"全部项目",
                     @"我创建的",
                     @"我参与的",
                     @"我关注的",
                     @"我收藏的",
                     @"项目广场"];
    }
    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:[NSString stringWithFormat:@"首页_筛选_%@", menuList.count > index? menuList[index]: menuList.lastObject]];
}

#pragma mark - sub class method
- (void)setIcarouselScrollEnabled:(BOOL)icarouselScrollEnabled{
    _myCarousel.scrollEnabled = icarouselScrollEnabled;
}
- (void)configSegmentItems{
    _segmentItems = @[@"全部项目",@"我创建的", @"我参与的",@"我关注的",@"我收藏的"];
}
#pragma mark - nav item
- (void)setupNavBtn{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(addItemClicked:)];
}

- (void)setupTitleBtn{
    if (!_titleBtn) {
        _titleBtn = [UIButton new];
        [_titleBtn setTitleColor:kColorNavTitle forState:UIControlStateNormal];
        [_titleBtn.titleLabel setFont:[UIFont systemFontOfSize:kNavTitleFontSize]];
        [_titleBtn addTarget:self action:@selector(fliterClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = _titleBtn;
        [self setTitleBtnStr:@"全部项目"];
    }
}

- (void)setTitleBtnStr:(NSString *)titleStr{
    if (_titleBtn) {
        CGFloat titleWidth = [titleStr getWidthWithFont:_titleBtn.titleLabel.font constrainedToSize:CGSizeMake(kScreen_Width, 30)];
        CGFloat imageWidth = 12;
        CGFloat btnWidth = titleWidth +imageWidth;
        _titleBtn.frame = CGRectMake((kScreen_Width-btnWidth)/2, (44-30)/2, btnWidth, 30);
        _titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
        _titleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth, 0, -titleWidth);
        [_titleBtn setTitle:titleStr forState:UIControlStateNormal];
        [_titleBtn setImage:[UIImage imageNamed:@"btn_fliter_down"] forState:UIControlStateNormal];
    }
}

- (void)setSelectNum:(NSInteger)selectNum{
    _selectNum = selectNum;
    [self setTitleBtnStr:_segmentItems[_selectNum]];
}

-(void)addItemClicked:(id)sender{
    [self closeFliter];
    if (!_myPopMenu.isShowed) {
        [_myPopMenu showMenuAtView:kKeyWindow startPoint:CGPointMake(0, -100) endPoint:CGPointMake(0, -100)];
    } else{
        [self closeMenu];
    }
}

-(void)fliterClicked:(id)sender{
    [self closeMenu];
    if (_myFliterMenu.showStatus == YES) {
        [_myFliterMenu dismissMenu];
    }else {
        _myFliterMenu.selectNum = _selectNum >= 3? _selectNum + 1: _selectNum;
        [_myFliterMenu showMenuAtView:kKeyWindow];
    }
}
-(void)closeFliter{
    if ([_myFliterMenu showStatus]) {
        [_myFliterMenu dismissMenu];
    }
}
-(void)closeMenu{
    if ([_myPopMenu isShowed]) {
        [_myPopMenu dismissMenu];
    }
}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return _segmentItems.count;
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    Projects *curPros = [_myProjectsDict objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    if (!curPros) {
        curPros = [self projectsWithIndex:index];
        [_myProjectsDict setObject:curPros forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    ProjectListView *listView = (ProjectListView *)view;
    if (listView) {
        [listView setProjects:curPros];
    }else{
        __weak Project_RootViewController *weakSelf = self;
        listView = [[ProjectListView alloc] initWithFrame:carousel.bounds projects:curPros block:^(Project *project) {
            [weakSelf goToProject:project];
            DebugLog(@"\n=====%@", project.name);
        } tabBarHeight:CGRectGetHeight(self.rdv_tabBarController.tabBar.frame)];
        
        listView.clickButtonBlock=^(EaseBlankPageType curType) {
            switch (curType) {
                case EaseBlankPageTypeProject_ALL:
                case EaseBlankPageTypeProject_CREATE:
                case EaseBlankPageTypeProject_JOIN:
                    [weakSelf goToNewProjectVC];
                    break;
                case EaseBlankPageTypeProject_WATCHED:
                case EaseBlankPageTypeProject_STARED:
                    [weakSelf goToProjectSquareVC];
                    break;
                default:
                    break;
            }
        };
        //使用新系列Cell样式
        listView.useNewStyle = _useNewStyle;
        if ([self isRoot]) {//根视图设置，子类不设置
            [listView setSearchBlock:^{
                [weakSelf goToSearchVC];
            } andScanBlock:^{
                [weakSelf scanBtnClicked];
            }];
        }
    }
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
}

- (Projects *)projectsWithIndex:(NSUInteger)index{
    return [Projects projectsWithType:index andUser:nil];
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    [self.view endEditing:YES];
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
    if (_oldSelectedIndex != carousel.currentItemIndex) {
        _oldSelectedIndex = carousel.currentItemIndex;
        ProjectListView *curView = (ProjectListView *)carousel.currentItemView;
        [curView refreshToQueryData];
    }
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}
#pragma mark VC
- (void)goToNewProjectVC{
    UIStoryboard *newProjectStoryboard = [UIStoryboard storyboardWithName:@"NewProject" bundle:nil];
    UIViewController *newProjectVC = [newProjectStoryboard instantiateViewControllerWithIdentifier:@"NewProjectVC"];
    [self.navigationController pushViewController:newProjectVC animated:YES];
}
- (void)goToNewTaskVC{
    ProjectToChooseListViewController *chooseVC = [[ProjectToChooseListViewController alloc] init];
    [self.navigationController pushViewController:chooseVC animated:YES];
}

- (void)goToNewTweetVC{
    TweetSendViewController *vc = [[TweetSendViewController alloc] init];
    vc.sendNextTweet = ^(Tweet *nextTweet){
        [nextTweet saveSendData];//发送前保存草稿
        [[Coding_NetAPIManager sharedManager] request_Tweet_DoTweet_WithObj:nextTweet andBlock:^(id data, NSError *error) {
            if (data) {
                [Tweet deleteSendData];//发送成功后删除草稿
            }
        }];
    };
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self.parentViewController presentViewController:nav animated:YES completion:nil];
}
- (void)goTo2FA{
    OTPListViewController *vc = [OTPListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)goToProject:(Project *)project{
    NProjectViewController *vc = [[NProjectViewController alloc] init];
    vc.myProject = project;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)goToAddUserVC{
    AddUserViewController *vc = [[AddUserViewController alloc] init];
    vc.type = AddUserTypeFollow;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)goToMessageVC{
    UsersViewController *vc = [[UsersViewController alloc] init];
    vc.curUsers = [Users usersWithOwner:[Login curLoginUser] Type:UsersTypeFriends_Message];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)goToProjectSquareVC{
    ProjectSquareViewController *vc=[ProjectSquareViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)goToSearchVC{
    [self closeFliter];
    [self closeMenu];
    SearchViewController *vc=[SearchViewController new];
    BaseNavigationController *searchNav=[[BaseNavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:searchNav animated:NO completion:nil];
}
#pragma mark scan QR-Code
- (void)scanBtnClicked{
    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:@"首页_扫描二维码"];
    ZXScanCodeViewController *vc = [ZXScanCodeViewController new];
    __weak typeof(self) weakSelf = self;
    vc.scanResultBlock = ^(ZXScanCodeViewController *vc, NSString *resultStr){
        [weakSelf dealWithScanResult:resultStr ofVC:vc];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)dealWithScanResult:(NSString *)resultStr ofVC:(ZXScanCodeViewController *)vc{
    if ([OTPListViewController handleScanResult:resultStr ofVC:vc]) {
        return;
    }
    UIViewController *nextVC  = [BaseViewController analyseVCFromLinkStr:resultStr];
    NSURL *URL = [NSURL URLWithString:resultStr];
    if (nextVC) {
        [self.navigationController pushViewController:nextVC animated:YES];
    }else if ([[URL host] hasSuffix:@"coding.net"]){
        //网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:resultStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }else if ([[UIApplication sharedApplication] canOpenURL:URL]){
        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"可能存在风险，是否打开此链接？\n「%@」", resultStr]];
        [alertV bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertV bk_addButtonWithTitle:@"打开链接" handler:nil];
        [alertV bk_setWillDismissBlock:^(UIAlertView *al, NSInteger index) {
            if (index == 1) {
                [[UIApplication sharedApplication] openURL:URL];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [alertV show];
    }else if (resultStr.length > 0){
        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"已识别此二维码内容为：\n「%@」", resultStr]];
        [alertV bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertV bk_addButtonWithTitle:@"复制链接" handler:nil];
        [alertV bk_setWillDismissBlock:^(UIAlertView *al, NSInteger index) {
            if (index == 1) {
                [[UIPasteboard generalPasteboard] setString:resultStr];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertV show];
    }else{
        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"无效条码" message:@"未检测到条码信息"];
        [alertV bk_addButtonWithTitle:@"重试" handler:^{
            if (![vc isScaning]) {
                [vc startScan];
            }
        }];
        [alertV show];
    }
}
@end
