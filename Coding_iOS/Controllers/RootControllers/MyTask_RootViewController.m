//
//  MyTask_RootViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "MyTask_RootViewController.h"
#import "Coding_NetAPIManager.h"
#import "EditTaskViewController.h"
#import "RDVTabBarController.h"
#import "TaskSelectionView.h"
#import "ScreenView.h"

@interface MyTask_RootViewController ()

@property (strong, nonatomic) Projects *myProjects;
@property (strong, nonatomic) NSMutableDictionary *myProTksDict;
@property (strong, nonatomic) NSMutableArray *myProjectList;

@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;

@property (strong, nonatomic) UIButton *titleBtn;
@property (nonatomic, strong) TaskSelectionView *myFliterMenu;
@property (nonatomic, strong) ScreenView *screenView;

@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *status; //任务状态，进行中的为1，已完成的为2
@property (nonatomic, strong) NSString *label; //任务标签
@property (nonatomic, strong) NSString *project_id;
@property (nonatomic, assign) TaskRoleType role;
@end

@implementation MyTask_RootViewController

#pragma mark TabBar
- (void)tabBarItemClicked{
    [super tabBarItemClicked];
    if (_myCarousel.currentItemView && [_myCarousel.currentItemView isKindOfClass:[ProjectTaskListView class]]) {
        ProjectTaskListView *listView = (ProjectTaskListView *)_myCarousel.currentItemView;
        [listView tabBarItemClicked];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTitleBtn];
    
    _myProjects = [Projects projectsWithType:ProjectsTypeAll andUser:nil];
    _myProTksDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    _myProjectList = [[NSMutableArray alloc] initWithObjects:[Project project_All], nil];
    //添加myCarousel
    self.myCarousel = ({
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
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kMySegmentControlIcon_Height, 0, 0, 0));
        }];
        icarousel;
    });
    
    UIBarButtonItem *addBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(addItemClicked:)];
     UIBarButtonItem *screenBar = [self HDCustomNavButtonWithTitle:nil imageName:@"task_filter_nav_unchecked" target:self action:@selector(screenItemClicked:)];
    self.navigationItem.rightBarButtonItems = @[addBar, screenBar];
    
    
    //初始化过滤目录
    _myFliterMenu = [[TaskSelectionView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64) items:@[@"我的任务（0）", @"我关注的（0）", @"我创建的（0）"]];
    __weak typeof(self) weakSelf = self;
    _myFliterMenu.clickBlock = ^(NSInteger pageIndex){
        _role = pageIndex;
        NSString *title = weakSelf.myFliterMenu.items[pageIndex];
        [weakSelf.titleBtn setTitle:[title substringToIndex:4] forState:UIControlStateNormal];
        ProjectTaskListView *listView = (ProjectTaskListView *)weakSelf.myCarousel.currentItemView;
        [weakSelf assignmentWithlistView:listView];
        [listView refresh];
        [weakSelf resetTaskCount];
        [weakSelf loadTasksLabels];

    };
    _myFliterMenu.closeBlock=^(){
        [weakSelf.myFliterMenu dismissMenu];
    };
    
    _screenView = [ScreenView creat];
    weakSelf.screenView.tastArray = @[[NSString stringWithFormat:@"进行中的（0）"],
                                      [NSString stringWithFormat:@"已完成的（0）"]
                                      ];
    _screenView.selectBlock = ^(NSString *keyword, NSString *status, NSString *label) {
        [((UIButton *)screenBar.customView) setImage:[UIImage imageNamed:@"task_filter_nav_checked"] forState:UIControlStateNormal];
        weakSelf.keyword = keyword;
        weakSelf.status = status;
        weakSelf.label = label;
        if (keyword == nil && status == nil && label == nil) {
            [((UIButton *)screenBar.customView) setImage:[UIImage imageNamed:@"task_filter_nav_unchecked"] forState:UIControlStateNormal];

        }
        ProjectTaskListView *listView = (ProjectTaskListView *)weakSelf.myCarousel.currentItemView;
        [weakSelf assignmentWithlistView:listView];
        [listView refresh];

    };
}



- (void)addItemClicked:(id)sender{
    [_myFliterMenu dismissMenu];

    EditTaskViewController *vc = [EditTaskViewController new];
    
    NSInteger curIndex = _myCarousel.currentItemIndex;
    Project *defaultPro = curIndex > 0? _myProjectList[curIndex]: nil;
    vc.myTask = [Task taskWithProject:defaultPro andUser:defaultPro? [Login curLoginUser]: nil];
    vc.myTask.handleType = TaskHandleTypeAddWithoutProject;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)screenItemClicked:(UIBarButtonItem *)sender {
    [_myFliterMenu dismissMenu];
    [_screenView showOrHide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resetCurView];
    [self resetTaskCount];
    [self loadTasksLabels];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_myFliterMenu dismissMenu];
}


- (void)resetCurView{
    if (!_myProjects.isLoading) {
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_ProjectsHaveTasks_WithObj:_myProjects andBlock:^(id data, NSError *error) {
            if (data) {
                [weakSelf configSegmentControlWithData:data];
            }
        }];
    }
}

- (void)resetTaskCount {
    
    __block NSInteger processing, done, watchAll, watchAllProcessing, create, createProcessing;
    
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_project_tasks_countWithProjectId:_project_id andBlock:^(id data, NSError *error) {
        if (_project_id == nil) {
            processing = [data[@"data"][@"processing"] integerValue];
            done = [data[@"data"][@"done"] integerValue];
            
            watchAll = [data[@"data"][@"watchAll"] integerValue];
            watchAllProcessing = [data[@"data"][@"watchAllProcessing"] integerValue];
            
            create = [data[@"data"][@"create"] integerValue];
            createProcessing = [data[@"data"][@"createProcessing"] integerValue];
        } else {
            done = [data[@"data"][@"ownerDone"] integerValue];
            processing = [data[@"data"][@"ownerProcessing"] integerValue];
            
            NSInteger watcherDone = [data[@"data"][@"watcherDone"] integerValue];
            watchAllProcessing = [data[@"data"][@"watcherProcessing"] integerValue];
            
            NSInteger creatorDone = [data[@"data"][@"creatorDone"] integerValue];
            createProcessing = [data[@"data"][@"creatorProcessing"] integerValue];
            
            watchAll = watcherDone + watchAllProcessing;
            create = creatorDone + createProcessing;
            
        }
        
        weakSelf.myFliterMenu.items = @[[NSString stringWithFormat:@"我的任务（%ld）", processing + done],
                                        [NSString stringWithFormat:@"我关注的（%ld）", watchAll],
                                        [NSString stringWithFormat:@"我创建的（%ld）", create]
                                        ];
        if (weakSelf.role == TaskRoleTypeWatcher) {
            processing = watchAllProcessing;
            done = watchAll - processing;
        }
        
        if (weakSelf.role == TaskRoleTypeCreator) {
            processing = createProcessing;
            done = create - processing;
        }
        
        weakSelf.screenView.tastArray = @[[NSString stringWithFormat:@"进行中的（%ld）", processing],
                                          [NSString stringWithFormat:@"已完成的（%ld）", done]
                                          ];

    }];
}

- (void)loadTasksLabels {
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_projects_tasks_labelsWithRole:_role projectId:_project_id andBlock:^(id data, NSError *error) {
        if (data != nil) {
            weakSelf.screenView.labels = data;
        }
    }];
}

- (void)configSegmentControlWithData:(Projects *)freshProjects {
    NSMutableSet *oldProSet = [[NSSet alloc] initWithArray:[self.myProjectList valueForKey:@"id"]].mutableCopy;
    NSMutableSet *freshProSet = [[NSSet alloc] initWithArray:[freshProjects.list valueForKey:@"id"]].mutableCopy;
    [oldProSet removeObject:@(-1)];//代表「全部项目」的 id 号
    BOOL dataHasChanged = ![oldProSet isEqualToSet:freshProSet];
    
    if (dataHasChanged) {
        self.myProjectList = [[NSMutableArray alloc] initWithObjects:[Project project_All], nil];
        [self.myProjectList addObjectsFromArray:freshProjects.list];
        
        //重置滑块
        if (_mySegmentControl) {
            [_mySegmentControl removeFromSuperview];
        }
        
        __weak typeof(self) weakSelf = self;
        CGRect segmentFrame = CGRectMake(0, 0, kScreen_Width, kMySegmentControlIcon_Height);
        _mySegmentControl = [[XTSegmentControl alloc] initWithFrame:segmentFrame Items:_myProjectList selectedBlock:^(NSInteger index) {
            [weakSelf.myCarousel scrollToItemAtIndex:index animated:NO];
        }];
        [self.view addSubview:_mySegmentControl];
        
        if (_myCarousel.currentItemIndex != 0) {
            _myCarousel.currentItemIndex = 0;
        }
        [_myCarousel reloadData];
    }

}

#pragma mark iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [_myProjectList count];
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    Project *curPro = [_myProjectList objectAtIndex:index];
    Tasks *curTasks = [_myProTksDict objectForKey:curPro.id];
    if (!curTasks) {
        curTasks = [Tasks tasksWithPro:curPro queryType:TaskQueryTypeAll];
        [_myProTksDict setObject:curTasks forKey:curPro.id];
    }
   
    ProjectTaskListView *listView = (ProjectTaskListView *)view;
    if (listView) {
        [self assignmentWithlistView:listView];
        [listView setTasks:curTasks];
    }else{
        __weak typeof(self) weakSelf = self;
        listView = [[ProjectTaskListView alloc] initWithFrame:carousel.bounds tasks:curTasks project_id:curTasks.project.id.stringValue keyword:_keyword status:_status label:_label userId:nil role:_role block:^(ProjectTaskListView *taskListView, Task *task) {
            EditTaskViewController *vc = [[EditTaskViewController alloc] init];
            vc.myTask = task;
            vc.taskChangedBlock = ^(){
                [taskListView refreshToQueryData];
            };
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } tabBarHeight:CGRectGetHeight(self.rdv_tabBarController.tabBar.frame)];
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
    ProjectTaskListView *curView = (ProjectTaskListView *)carousel.currentItemView;
    NSInteger index = carousel.currentItemIndex;
    if (index == 0) {
        _project_id = nil;
    } else {
        _project_id = ((Project *)_myProjectList[index]).id.stringValue;
    }
    [self assignmentWithlistView:curView];
    [self resetTaskCount];
    [self loadTasksLabels];

    [curView refreshToQueryData];
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}

- (void)setupTitleBtn{
    if (!_titleBtn) {
        _titleBtn = [UIButton new];
        [_titleBtn setTitleColor:kColorNavTitle forState:UIControlStateNormal];
        [_titleBtn.titleLabel setFont:[UIFont systemFontOfSize:kNavTitleFontSize]];
        [_titleBtn addTarget:self action:@selector(fliterClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = _titleBtn;
        [self setTitleBtnStr:@"我的任务"];
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

-(void)fliterClicked:(id)sender{
    if (_myFliterMenu.showStatus) {
        [_myFliterMenu dismissMenu];
    }else {
        [_myFliterMenu showMenuAtView:kKeyWindow];
    }

    
}

- (UIBarButtonItem *)HDCustomNavButtonWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)targe action:(SEL)action {
    UIButton *itemButtom = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    [itemButtom setImage:image forState:UIControlStateNormal];
    itemButtom.titleLabel.font = [UIFont systemFontOfSize: 16];
    [itemButtom setTitle:title forState:UIControlStateNormal];
    [itemButtom setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    UIColor *color = [UINavigationBar appearance].titleTextAttributes[NSForegroundColorAttributeName];
    if (color == nil) {
        color = [UIColor blackColor];
    }
    [itemButtom setTitleColor:color forState:UIControlStateNormal];
    itemButtom.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [itemButtom addTarget:targe action:action
         forControlEvents:UIControlEventTouchUpInside];
    if (title == nil && imageName != nil) {
        [itemButtom setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    } else {
        [itemButtom setFrame:CGRectMake(0, 0, 80, 40)];
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]
                                      initWithCustomView:itemButtom];
    return barButtonItem;
}

- (void)assignmentWithlistView:(ProjectTaskListView *)listView {
    listView.keyword = self.keyword;
    listView.status = self.status;
    listView.label = self.label;
    listView.project_id = self.project_id;
    listView.role = self.role;
}


@end
