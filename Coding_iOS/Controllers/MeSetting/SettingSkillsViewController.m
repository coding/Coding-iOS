//
//  SettingSkillsViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/12/25.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "SettingSkillsViewController.h"

#import "Login.h"
#import "Coding_NetAPIManager.h"

#import "SkillCCell.h"
#import "ActionSheetStringPicker.h"


@interface SettingSkillsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *tagsView;

//CodingSkill
@property (strong, nonatomic) NSDictionary *skillNameDict;
@property (strong, nonatomic) NSMutableArray<CodingSkill *> *skills;
@end

@implementation SettingSkillsViewController

+ (instancetype)settingSkillsVCWithDoneBlock:(void(^)(NSArray *selectedSkills))block{
    SettingSkillsViewController *vc = [SettingSkillsViewController new];
    vc.doneBlock = block;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置开发技能";
    [self refresh];
}

- (void)refresh{
    [self.view beginLoading];
    __weak typeof(self) weakSelf = self;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/options/skills" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        [weakSelf.view endLoading];
        if (data) {
            weakSelf.skillNameDict = data[@"data"];
            [weakSelf setupContent];
        }
    }];
}

- (void)setupContent{
    User *curUser = [Login curLoginUser];
    self.skills = curUser.skills.mutableCopy ?: @[].mutableCopy;
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(doneBtnClicked:)] animated:YES];
    
    __weak typeof(self) weakSelf = self;
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, kScreen_Width, 44)];
    addBtn.backgroundColor = kColorWhite;
    [addBtn bk_addEventHandler:^(id sender) {
        [weakSelf addBtnClicked];
    } forControlEvents:UIControlEventTouchUpInside];
    [addBtn addLineUp:YES andDown:YES andColor:kColorD8DDE4];
    [self.view addSubview:addBtn];
    UILabel *addLeftL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColor222];
    UILabel *addRightL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorDark7];
    addLeftL.text = @"开发技能";
    addRightL.text = @"请选择";
    UIImageView *addRightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_arrow_left"]];
    [addBtn addSubview:addLeftL];
    [addBtn addSubview:addRightL];
    [addBtn addSubview:addRightArrow];
    [addLeftL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(addBtn);
        make.left.offset(15);
    }];
    [addRightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(addBtn);
        make.right.offset(-10);
    }];
    [addRightL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(addBtn);
        make.right.equalTo(addRightArrow.mas_left).offset(-5);
    }];
    
    UILabel *headerL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
    headerL.text = @"已选择的开发技能";
    [self.view addSubview:headerL];
    [headerL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(addBtn.mas_bottom).offset(20);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.tagsView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.tagsView setBackgroundColor:[UIColor clearColor]];
    [self.tagsView registerClass:[SkillCCell class] forCellWithReuseIdentifier:kCCellIdentifier_SkillCCell];
    self.tagsView.dataSource = self;
    self.tagsView.delegate = self;
    [self.view addSubview:self.tagsView];
    [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerL.mas_bottom).offset(5);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)addBtnClicked{
    __weak typeof(self) weakSelf = self;
    NSMutableArray *skillNameList = _skillNameDict.allValues.mutableCopy;
    [skillNameList removeObjectsInArray:[_skills valueForKey:@"skillName"]];
    [ActionSheetStringPicker showPickerWithTitle:nil rows:@[skillNameList, [CodingSkill levelList]] initialSelection:@[@0, @0] doneBlock:^(ActionSheetStringPicker *picker, NSArray *selectedIndex, NSArray *selectedValue) {
        CodingSkill *addSkill = [CodingSkill new];
        addSkill.skillName = selectedValue.firstObject;
        for (NSString *key in weakSelf.skillNameDict) {
            if ([weakSelf.skillNameDict[key] isEqualToString:addSkill.skillName]) {
                addSkill.skillId = @(key.integerValue);
                break;
            }
        }
        addSkill.level = @([selectedIndex.lastObject integerValue] + 1);
        [weakSelf.skills addObject:addSkill];
        [weakSelf.tagsView reloadData];
    } cancelBlock:nil origin:self.view];
}

- (void)doneBtnClicked:(id)sender{
    if (_skills.count <= 0) {
        [NSObject showHudTipStr:@"开发技能不能为空"];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
        if (self.doneBlock) {
            self.doneBlock(_skills);
        }
    }
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _skills.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SkillCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_SkillCCell forIndexPath:indexPath];
    ccell.curSkill = _skills[indexPath.row];
    __weak typeof(self) weakSelf = self;
    ccell.deleteBlock = ^(CodingSkill *deletedSkill) {
        [weakSelf.skills removeObject:deletedSkill];
        [weakSelf.tagsView reloadData];
    };
    return ccell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [SkillCCell ccellSizeWithObj:_skills[indexPath.row]];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 15, 15, 15);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

@end
