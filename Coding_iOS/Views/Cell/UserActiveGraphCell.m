//
//  UserActiveGraphCell.m
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/28.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "UserActiveGraphCell.h"
#import "ActivityMonScrollView.h"
#import "UserActiveStatusView.h"

@interface UserActiveGraphCell ()
@property (nonatomic, strong) ActivityMonScrollView *scrollView;
@property (nonatomic, strong) NSArray *userActiveStatusViewArray;
@end

@implementation UserActiveGraphCell

#pragma mark - 生命周期方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self creatView];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - 外部方法

+ (CGFloat)cellHeight {
    return 202;
}

#pragma makr - 消息

#pragma mark - 系统委托

#pragma mark - 自定义委托

#pragma mark - 响应方法

#pragma mark - 私有方法

- (void)creatView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *textArray = @[@"M", @"W", @"F"];
    NSArray *topArray = @[@43, @65, @87];
    for (int i = 0; i < 3; i++) {
        UILabel *mondayLabel = [[UILabel alloc] init];
        mondayLabel.text = textArray[i];
        mondayLabel.textColor = [UIColor colorWithRGBHex:0x999999];
        mondayLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:mondayLabel];
        mondayLabel.sd_layout.leftSpaceToView(self.contentView, 15).topSpaceToView(self.contentView, [topArray[i] intValue]).widthIs(12).heightIs(17);
    }
    
    _scrollView = [[ActivityMonScrollView alloc] init];
    [self.contentView addSubview:_scrollView];
    _scrollView.sd_layout.leftSpaceToView(self.contentView, 32).topSpaceToView(self.contentView, 15).rightSpaceToView(self.contentView, 0).heightIs(98);
    
    NSMutableArray *temp = [NSMutableArray array];
    UIView *stateView = [[UIView alloc] init];
    [self.contentView addSubview:stateView];
    stateView.sd_layout.leftSpaceToView(self.contentView, 15).topSpaceToView(_scrollView, 15).rightSpaceToView(self.contentView, 15).heightIs(59);
    
    for (int i = 0; i < 3; i++) {
        UserActiveStatusView *itemView = [[UserActiveStatusView alloc] init];
        itemView.borderWidth = .5;
        itemView.borderColor = [UIColor colorWithRGBHex:0xd8dde4];
        [stateView addSubview:itemView];
        itemView.sd_layout.heightIs(59);
        [temp addObject:itemView];
    }
    self.userActiveStatusViewArray = temp;
    [stateView setupAutoWidthFlowItems:[temp copy] withPerRowItemsCount:temp.count verticalMargin:0 horizontalMargin:-.5];
}

- (NSString *)addSeparatorWithStr:(NSString *)str {
    NSMutableString *tempStr = [NSMutableString stringWithFormat:@"%@", str];
    NSInteger index = tempStr.length;
    while ((index - 3) > 0) {
        index -= 3;
        [tempStr insertString:@"," atIndex:index];
    }
    return tempStr;
}

#pragma mark - get/set方法

- (void)setActivenessModel:(ActivenessModel *)activenessModel {
    _activenessModel = activenessModel;
    
    _scrollView.dailyActiveness = activenessModel.dailyActiveness;
    _scrollView.startMon = [[activenessModel.start_date substringWithRange:NSMakeRange(5, 2)] integerValue];
    
    NSArray *statusArray = @[@[[NSString stringWithFormat:@"%@ 度", [self addSeparatorWithStr:_activenessModel.total_with_seal_top_line]],
                               @"过去一年的活跃度"],
                             @[[NSString stringWithFormat:@"%@ 天", [self addSeparatorWithStr:_activenessModel.longest_active_duration.days]],
                               @"最长连续活跃天数"],
                             @[[NSString stringWithFormat:@"%@ 天", [self addSeparatorWithStr:_activenessModel.current_active_duration.days]],
                               @"当前连续活跃天数"],
                             ];
    for (int i = 0; i < _userActiveStatusViewArray.count; i++) {
        UserActiveStatusView *itemView = _userActiveStatusViewArray[i];
        itemView.title = statusArray[i][0];
        itemView.details = statusArray[i][1];
    }
}

@end
