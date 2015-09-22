//
//  SettingTagsViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#define kCCellIdentifier_Tag @"TagCCell"


#import "SettingTagsViewController.h"
#import "TagCCell.h"
#import "TagsManager.h"
@interface SettingTagsViewController ()
@property (strong, nonatomic) UICollectionView *tagsView;
@property (strong, nonatomic) NSMutableArray *mySelectedTags;

@end

@implementation SettingTagsViewController

+ (instancetype)settingTagsVCWithAllTags:(NSArray *)allTags selectedTags:(NSArray *)selectedTags doneBlock:(void(^)(NSArray *selectedTags))block{
    SettingTagsViewController *vc = [[SettingTagsViewController alloc] init];
    if (allTags) {
        vc.allTags = allTags;
    }else{
        vc.allTags = [NSArray array];
    }
    if (selectedTags && selectedTags.count > 0) {
        vc.selectedTags = [NSMutableArray arrayWithArray:selectedTags];
    }else{
        vc.selectedTags = [NSMutableArray array];
    }
    vc.doneBlock = block;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mySelectedTags = [_selectedTags mutableCopy];

    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(doneBtnClicked:)] animated:YES];
    @weakify(self);
    RAC(self.navigationItem.rightBarButtonItem, enabled) =
    [RACSignal combineLatest:@[RACObserve(self, mySelectedTags)] reduce:^id (NSArray *tags){
                                   @strongify(self);
                                   return @(![self tagsHasChanged]);
                               }];
    
    self.title = @"个性标签";
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.tagsView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.tagsView setBackgroundColor:[UIColor clearColor]];
    [self.tagsView registerClass:[TagCCell class] forCellWithReuseIdentifier:kCCellIdentifier_Tag];
    self.tagsView.dataSource = self;
    self.tagsView.delegate = self;
    [self.view addSubview:self.tagsView];
    [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tagsHasChanged{
    BOOL tagsHasChanged = NO;
    NSSet *oldSet = [NSSet setWithArray:_selectedTags], *newSet = [NSSet setWithArray:_mySelectedTags];
    tagsHasChanged = [newSet isEqualToSet:oldSet];
    return tagsHasChanged;
}

- (void)doneBtnClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.doneBlock) {
        self.doneBlock(_mySelectedTags);
    }
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _allTags.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TagCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_Tag forIndexPath:indexPath];
    Tag *curTag = [_allTags objectAtIndex:indexPath.row];
    ccell.curTag = curTag;
    ccell.hasBeenSelected = [_mySelectedTags containsObject:curTag.id.stringValue];
    return ccell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [TagCCell ccellSizeWithObj:[_allTags objectAtIndex:indexPath.row]];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Tag *curTag = [_allTags objectAtIndex:indexPath.row];
    NSString *tagId = curTag.id.stringValue;
    
    NSMutableArray *tempArray = [self mutableArrayValueForKey:@"mySelectedTags"];
    if ([tempArray containsObject:tagId]) {
        [tempArray removeObject:tagId];
    }else{
        if (tempArray.count >= 10) {
            [NSObject showHudTipStr:@"用户个性标签不能超过10个"];
            return;
        }
        [tempArray addObject:tagId];
    }
    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}


@end
