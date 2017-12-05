//
//  CSHotTopicVC.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSHotTopicView.h"
#import "Coding_NetAPIManager.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

#import "UILabel+Common.h"
#import "Tweet.h"

#import "CSTopicDetailVC.h"
#import "HotTopicBannerView.h"


#define kCellIdentifier_HotTopicTitleCell @"kCellIdentifier_HotTopicTitleCell"

@interface CSHotTopicView ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *listView;
@property (nonatomic,strong)NSArray *topiclist;
@property (nonatomic,strong)NSMutableArray *adlist;
@property (nonatomic,strong)HotTopicBannerView *adView;
@end

@implementation CSHotTopicView{
    CGFloat _adHeight;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor whiteColor];
    
    _adHeight =  kScreen_Width * 214/640;
    
    _listView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[CSTopicCell class] forCellReuseIdentifier:kCellIdentifier_TopicCell];
        [tableView registerClass:[CSHotTopicTitleCell class] forCellReuseIdentifier:kCellIdentifier_HotTopicTitleCell];
        [self addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView;
    });
    
    _topiclist = @[];
    _adlist = [NSMutableArray new];
    
    [self refreshAdlist];
    [self refreshHotTopiclist];
    
    return self;
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
    _adView = [HotTopicBannerView new];
    _adView.backgroundColor = [UIColor whiteColor];
    _adView.tapActionBlock = ^(NSDictionary *tapedBanner) {
        
        CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
        vc.topicID = [tapedBanner[@"id"] intValue];
        [wself.parentVC.navigationController pushViewController:vc animated:YES];
    };
    
    [[Coding_NetAPIManager sharedManager] request_TopicAdlistWithBlock:^(id data, NSError *error) {
//        if (data && [data isKindOfClass:[NSArray class]]) {
//            for (NSDictionary *dict in data) {
//                [wself.adlist addObject:({
//                    CodingBanner *banner = [CodingBanner new];
//                    banner.id = [dict objectForKey:@"id"];
//                    banner.status = @1;
//                    banner.name = [dict objectForKey:@"name"];
//                    banner.title = [dict objectForKey:@"description"];
//                    banner.image = [dict objectForKey:@"image_url"];
//                    banner;
//                })];
//            }
//        }else {
//            
//            wself.adlist = [NSMutableArray array];
//        }
        wself.adlist = data;
        
        wself.adView.frame = CGRectMake(0, 0, kScreen_Width, wself.adlist.count == 0 ? 0 : _adHeight);
        wself.adView.curBannerList = wself.adlist;
        wself.listView.tableHeaderView = wself.adView;
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
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:12];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 35;
    }
    NSDictionary *data = _topiclist[indexPath.row - 1];
    return [CSTopicCell cellHeightWithData:data];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        return;
    }
    
    CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
    NSDictionary *topic = _topiclist[indexPath.row - 1];
    vc.topicID = [topic[@"id"] intValue];
    
    [self.parentVC.navigationController pushViewController:vc animated:YES];
}


@end


#pragma mark - 


@interface CSTopicCell()<TTTAttributedLabelDelegate>
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UITTTAttributedLabel *contentLabel;
@property (nonatomic,strong)UILabel *userCountLabel;

@property (strong, nonatomic) UIImageView *detailIconView;

@property (nonatomic,strong)NSDictionary *refData;

@end

@implementation CSTopicCell

static CGFloat const kHotTopicCellPaddingRight = 15;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15, kScreen_Width - kPaddingLeftWidth - kHotTopicCellPaddingRight, 12)];
        _nameLabel.font = [UIFont boldSystemFontOfSize:15];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = kColor222;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_nameLabel];
        
        self.contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, _nameLabel.bottom + 15, kScreen_Width - kPaddingLeftWidth - 30, 30)];
        self.contentLabel.font = [UIFont systemFontOfSize:14];
        self.contentLabel.textColor = kColor222;
        self.contentLabel.numberOfLines = 0;
        
        self.contentLabel.linkAttributes = kLinkAttributes;
        self.contentLabel.activeLinkAttributes = kLinkAttributesActive;
        self.contentLabel.delegate = self;
        [self.contentLabel addLongPressForCopy];
        [self.contentView addSubview:self.contentLabel];
        
        _userCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 75, kScreen_Width - kPaddingLeftWidth - kHotTopicCellPaddingRight, 12)];
        _userCountLabel.font = [UIFont systemFontOfSize:12];
        _userCountLabel.backgroundColor = [UIColor clearColor];
        _userCountLabel.textColor = kColor999;
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_userCountLabel];
        
        if(!self.detailIconView) {
//            self.detailIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 8, 0, 20, 20)];
//            self.detailIconView.image = [UIImage imageNamed:@"me_info_arrow_left"];
//            [self.contentView addSubview:self.detailIconView];
        }
    }
    return self;
}

- (void)updateDisplayByTopic:(NSDictionary*)data {
    _refData = data;
    
    NSString *peopleCount = data[@"speackers"];
    if (!peopleCount) {
        peopleCount = data[@"speakers"];
    }
    if (!peopleCount) {
        peopleCount = @"0";
    }
    
    _nameLabel.text = [NSString stringWithFormat:@"#%@#",data[@"name"]];
    
    Tweet *tweet = [NSObject objectOfClass:@"Tweet" fromJSON:data[@"hot_tweet"]];
    NSString *contentStr = (tweet.content.length > 0) ? tweet.content : @"[图片]";
    [self.contentLabel setLongString:contentStr withFitWidth:self.contentLabel.width maxHeight:34];
    self.contentLabel.centerY = self.height / 2;
    for (HtmlMediaItem *item in tweet.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && item.href.length > 0) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    _userCountLabel.top = self.contentLabel.bottom + 10;
    _userCountLabel.text = [NSString stringWithFormat:@"%@人参与",peopleCount];
    
    [self.detailIconView setY:([CSTopicCell cellHeightWithData:data] - 12) / 2];
    
}
+ (CGFloat)contentLabelHeightWithTweet:(NSDictionary *)data {
    Tweet *tweet = [NSObject objectOfClass:@"Tweet" fromJSON:data[@"hot_tweet"]];
    NSString *content = (tweet.content.length > 0) ? tweet.content : @"[图片]";
    CGFloat width = kScreen_Width - kPaddingLeftWidth - kHotTopicCellPaddingRight;
    CGFloat realheight = [content getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(width, 1000)];
    return MIN(realheight, 34);
}

+ (CGFloat)cellHeightWithData:(NSDictionary*)data {
    
    CGFloat height = 15 * 3 + 8;
    height += 12;//namelabel
    height += [CSTopicCell contentLabelHeightWithTweet:data];
    height += 12;

    return height;
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
        self.textLabel.frame = CGRectMake(kPaddingLeftWidth, 12, kScreen_Width - 100, 12);
        self.textLabel.font = [UIFont systemFontOfSize:13];
        self.textLabel.textColor = kColor222;
        self.textLabel.text = @"热门话题榜单";
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(kPaddingLeftWidth, 12, kScreen_Width - 100, 12);
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
