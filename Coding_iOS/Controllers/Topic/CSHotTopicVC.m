//
//  CSHotTopicVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSHotTopicVC.h"
#import "Coding_NetAPIManager.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

#import "UILabel+Common.h"
#import "Tweet.h"

#import "CSTopic.h"
#import "CSTopicDetailVC.h"


#define kCellIdentifier_HotTopicTitleCell @"kCellIdentifier_HotTopicTitleCell"

@interface CSHotTopicVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *listView;
@property (nonatomic,strong)NSArray *topiclist;
@property (nonatomic,strong)NSArray *adlist;
@property (nonatomic,strong)CSScrollview *adView;
@end

@implementation CSHotTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(onGoBack)];
    self.parentViewController.navigationItem.leftBarButtonItem = backItem;
    
    _listView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[CSTopicCell class] forCellReuseIdentifier:kCellIdentifier_TopicCell];
        [tableView registerClass:[CSHotTopicTitleCell class] forCellReuseIdentifier:kCellIdentifier_HotTopicTitleCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        {
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
            tableView.contentInset = insets;
            tableView.scrollIndicatorInsets = insets;
        }
        tableView;
    });
    
    _topiclist = @[];
    _adlist = @[];
    
    [self refreshAdlist];
    [self refreshHotTopiclist];
}

- (void)dealloc {
    _listView.delegate = nil;
    _listView.dataSource = nil;
}

#pragma mark - data refresh

- (void)refreshHotTopiclist{
    __weak typeof(self) wself = self;
    [[Coding_NetAPIManager sharedManager] request_HotTopiclistWithBlock:^(NSArray *topiclist, NSError *error) {
        if (topiclist) {
            wself.topiclist = [topiclist copy];
        }else {
            wself.topiclist = [NSArray array];
        }
        [wself.listView reloadData];
    }];
}

- (void)refreshAdlist {
    __weak typeof(self) wself = self;
    [[Coding_NetAPIManager sharedManager] request_TopicAdlistWithBlock:^(id data, NSError *error) {
        if (data && [data isKindOfClass:[NSArray class]]) {
            wself.adlist = [data copy];
        }else {
            wself.adlist = [NSArray array];
        }
        [wself.listView reloadData];
    }];
}

#pragma mark - tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_topiclist.count == 0) {
        return  0;
    }
    return _topiclist.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        CSHotTopicTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_HotTopicTitleCell forIndexPath:indexPath];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:12];
        return cell;
    }
    NSDictionary *data = _topiclist[indexPath.row - 1];
    CSTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicCell forIndexPath:indexPath];
    [cell updateDisplayByTopic:data];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:75];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 35;
    }
    return 94;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        return;
    }
    
    CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
    vc.topic = _topiclist[indexPath.row - 1];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_adlist.count == 0) {
        return 0;
    }
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_adlist.count == 0) {
        return nil;
    }
    
    if (!_adView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.itemSize = CGSizeMake(kScreen_Width, 80);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _adView = [[CSScrollview alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 80) layout:layout];
        _adView.autoScrollEnable = YES;
        _adView.showPageControl = NO;
        _adView.tapBlk = ^(CSScrollItem* item) {
            NSLog(@"tap --\n%@",item.data);
        };
    }
    
    NSArray *scrollItemlist = [_adlist bk_map:^id(NSDictionary *obj) {
        CSScrollItem *item = [CSScrollItem itemWithData:obj imgUrl:obj[@"image_url"]];
        return item;
    }];
    [_adView update:scrollItemlist];
    
    return _adView;
}


#pragma mark - init

#pragma mark -

- (void)onGoBack {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

@end


#pragma mark - 


@interface CSTopicCell()<TTTAttributedLabelDelegate>
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UITTTAttributedLabel *contentLabel;
@property (nonatomic,strong)UILabel *userCountLabel;

@end

@implementation CSTopicCell

static CGFloat const kHotTopicCellPaddingRight = 15;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 12, kScreen_Width - kPaddingLeftWidth - kHotTopicCellPaddingRight, 12)];
        _nameLabel.font = [UIFont boldSystemFontOfSize:15];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_nameLabel];
        
        
        self.contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 30, kScreen_Width - kPaddingLeftWidth - kHotTopicCellPaddingRight, 30)];
        self.contentLabel.font = [UIFont systemFontOfSize:14];
        self.contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        self.contentLabel.numberOfLines = 0;
        
        self.contentLabel.linkAttributes = kLinkAttributes;
        self.contentLabel.activeLinkAttributes = kLinkAttributesActive;
        self.contentLabel.delegate = self;
        [self.contentLabel addLongPressForCopy];
        [self.contentView addSubview:self.contentLabel];
        
        _userCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 75, kScreen_Width - kPaddingLeftWidth - kHotTopicCellPaddingRight, 12)];
        _userCountLabel.font = [UIFont systemFontOfSize:12];
        _userCountLabel.backgroundColor = [UIColor clearColor];
        _userCountLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_userCountLabel];
    }
    return self;
}

- (void)updateDisplayByTopic:(NSDictionary*)data {
    
    _nameLabel.text = [NSString stringWithFormat:@"#%@#",data[@"name"]];
    _userCountLabel.text = [NSString stringWithFormat:@"%@人参与",data[@"user_count"]];
    
    if (data[@"hot_tweet"]) {
        Tweet *tweet = [NSObject objectOfClass:@"Tweet" fromJSON:data[@"hot_tweet"]];
        [self.contentLabel setLongString:tweet.content withFitWidth:self.contentLabel.width maxHeight:40];
        self.contentLabel.centerY = self.height / 2;
        for (HtmlMediaItem *item in tweet.htmlMedia.mediaItems) {
            if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
                [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
            }
        }
    }
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
//    if (_mediaItemClickedBlock) {
//        _mediaItemClickedBlock([components objectForKey:@"value"]);
//    }
    NSLog(@"%@",components[@"value"]);
}

@end

@implementation CSHotTopicTitleCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel.frame = CGRectMake(kPaddingLeftWidth, 12, kScreen_Width - 100, 12);
        self.textLabel.font = [UIFont systemFontOfSize:13];
        self.textLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        self.textLabel.text = @"热门话题榜单";
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end


@interface CSHotAdCell()
@property (nonatomic,strong)CSScrollview *adView;
@end

@implementation CSHotAdCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.itemSize = CGSizeMake(kScreen_Width, 80);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _adView = [[CSScrollview alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 80) layout:layout];
        _adView.autoScrollEnable = YES;
        _adView.showPageControl = NO;
        _adView.tapBlk = ^(CSScrollItem* item) {
            NSLog(@"tap --\n%@",item.data);
        };
        
    }
    return self;
}

@end
