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
        vc.selectedTags = [[NSMutableArray alloc] init];
    }
    vc.doneBlock = block;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView{
    [super loadView];
    CGRect frame = [UIView frameWithOutNav];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneBtnClicked:)];
    self.title = @"个性标签";
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.tagsView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.tagsView setBackgroundColor:kColorTableBG];
    [self.tagsView registerClass:[TagCCell class] forCellWithReuseIdentifier:kCCellIdentifier_Tag];
    self.tagsView.dataSource = self;
    self.tagsView.delegate = self;
    [self.view addSubview:self.tagsView];
}

- (void)doneBtnClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.doneBlock) {
        self.doneBlock(_selectedTags);
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
    ccell.hasBeenSelected = [_selectedTags containsObject:curTag.id.stringValue];
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
    if ([_selectedTags containsObject:tagId]) {
        [_selectedTags removeObject:tagId];
    }else{
        [_selectedTags addObject:tagId];
    }
    [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}


@end
