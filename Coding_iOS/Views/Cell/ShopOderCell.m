//
//  ShopOderCell.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/21.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ShopOderCell.h"
#import "ShopOrder.h"
#import "NSDate+Common.h"

#define FONT(F) [UIFont systemFontOfSize:F]

@interface ShopOderCell()
{
    UIView      *_superView;
    
    UIImageView *_coverView;
    
    UILabel     *_priceLabel;
    UILabel     *_titleLabel;
    UILabel     *_descLabel;
    UILabel     *_countLabel;
    UILabel     *_pointLabel;
    UILabel     *_moneyLabel;
    UIButton    *_codingCoinView;
    
    UILabel     *_orderNumLabel;
    UILabel     *_remarksLabel;
    UILabel     *_nameLabel;
    UILabel     *_addressLabel;
    UILabel     *_phoneNumLabel;
    UILabel     *_sendStatusLabel;
    UILabel     *_sendTimeLabel;
    UILabel     *_expressLabel;

    UIButton    *_deleteButton;
    UIButton    *_payButton;
}
@end

@implementation ShopOderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        [self setUpContentView];
    }
    return self;
}


- (void)setUpContentView
{
    _superView = [UIView new];
    [self.contentView addSubview:_superView];
    [_superView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    _orderNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _orderNumLabel.font = FONT(15);
    _orderNumLabel.backgroundColor = [UIColor clearColor];
    _orderNumLabel.textColor = kColorDark4;
    [_superView addSubview:_orderNumLabel];
    [_orderNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.top.offset(15);
    }];
    
    UIView *lineView1 = [UIView new];
    lineView1.backgroundColor = kColorDDD;
    [_superView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(44);
        make.left.equalTo(_orderNumLabel);
        make.right.equalTo(_superView);
        make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
    }];
    
    UIView *_goodsInfoView = [[UIView alloc] init];
    [_superView addSubview:_goodsInfoView];
    [_goodsInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView1.mas_bottom);
        make.left.right.equalTo(_superView);
        make.height.mas_equalTo(110);
    }];
    
    _coverView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _coverView.backgroundColor = [UIColor clearColor];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.layer.masksToBounds =YES;
    [_goodsInfoView addSubview:_coverView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = FONT(15);
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.minimumScaleFactor = 0.5;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = kColor222;
    [_goodsInfoView addSubview:_titleLabel];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _countLabel.font = FONT(15);
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.text  = @"ⅹ1";
    _countLabel.textColor = kColorBrandGreen;
    [_goodsInfoView addSubview:_countLabel];
    
    _codingCoinView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_codingCoinView setImage:[UIImage imageNamed:@"shop_coding_coin_icon"] forState:UIControlStateNormal];
    [_codingCoinView setTitle:@"  码币 " forState:UIControlStateNormal];
    [_codingCoinView setTitleColor:kColorDark7 forState:UIControlStateNormal];
    [_codingCoinView.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [_goodsInfoView addSubview:_codingCoinView];
    
    
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(80);
        make.centerY.equalTo(_goodsInfoView);
        make.left.offset(15);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverView);
        make.left.equalTo(_coverView.mas_right).offset(20);
        make.right.offset(-(40));
    }];
    
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_titleLabel);
        make.right.offset(-15);
    }];
    
    [_codingCoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_coverView);
        make.left.equalTo(_titleLabel);
    }];
    
    UIView *lineView2 = [UIView new];
    lineView2.backgroundColor = kColorDDD;
    [_superView addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_goodsInfoView.mas_bottom).offset(88);
        make.left.equalTo(_orderNumLabel);
        make.right.equalTo(_superView);
        make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
    }];
    
    // 码币抵扣
    UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    pointLabel.font = FONT(14);
    pointLabel.backgroundColor = [UIColor clearColor];
    pointLabel.textColor = kColorDark7;
    pointLabel.text = @"码币抵扣";
    [_superView addSubview:pointLabel];
    
    _pointLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _pointLabel.textAlignment = NSTextAlignmentRight;
    _pointLabel.font = FONT(14);
    _pointLabel.backgroundColor = [UIColor clearColor];
    _pointLabel.textColor = kColorDark3;
    [_superView addSubview:_pointLabel];
    
    [pointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_goodsInfoView.mas_bottom).offset(22);
        make.left.equalTo(_orderNumLabel);
    }];
    
    [_pointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pointLabel.mas_top);
        make.left.equalTo(pointLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right).offset(-15);
    }];

    // 商品实付
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    moneyLabel.font = FONT(14);
    moneyLabel.backgroundColor = [UIColor clearColor];
    moneyLabel.textColor = kColorDark7;
    moneyLabel.text = @"商品实付";
    [_superView addSubview:moneyLabel];
    
    _moneyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _moneyLabel.textAlignment = NSTextAlignmentRight;
    _moneyLabel.font = FONT(14);
    _moneyLabel.backgroundColor = [UIColor clearColor];
    _moneyLabel.textColor = kColorDark3;
    [_superView addSubview:_moneyLabel];
    
    [moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_goodsInfoView.mas_bottom).offset(66);
        make.left.equalTo(_orderNumLabel);
    }];
    
    [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(moneyLabel.mas_top);
        make.left.equalTo(moneyLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right).offset(-15);
    }];


    //基本的送货信息
    
    // 收货人
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.font = FONT(14);
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = kColorDark7;
    nameLabel.text = @"收货人：";
    [_superView addSubview:nameLabel];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = FONT(14);
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = kColorDark3;
    [_superView addSubview:_nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView2.mas_bottom).offset(15);
        make.left.equalTo(_orderNumLabel);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_top);
        make.left.equalTo(nameLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right).offset(-15);
    }];
    
    //联系电话：
    UILabel *phoneNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    phoneNumLabel.font = FONT(14);
    phoneNumLabel.backgroundColor = [UIColor clearColor];
    phoneNumLabel.textColor = kColorDark7;
    phoneNumLabel.text = @"联系电话：";
    [_superView addSubview:phoneNumLabel];
    
    _phoneNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _phoneNumLabel.font = FONT(14);
    _phoneNumLabel.backgroundColor = [UIColor clearColor];
    _phoneNumLabel.textColor = kColorDark3;
    [_superView addSubview:_phoneNumLabel];
    
    [phoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(9);
        make.left.equalTo(nameLabel.mas_left);
    }];
    
    [_phoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneNumLabel.mas_top);
        make.left.equalTo(phoneNumLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right).offset(-15);

    }];

    //状态 :
    UILabel *sendStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    sendStatusLabel.font = FONT(14);
    sendStatusLabel.backgroundColor = [UIColor clearColor];
    sendStatusLabel.textColor = kColorDark7;
    sendStatusLabel.text = @"发货状态：";
    [_superView addSubview:sendStatusLabel];
    
    _sendStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _sendStatusLabel.font = FONT(14);
    _sendStatusLabel.backgroundColor = [UIColor clearColor];
    _sendStatusLabel.textColor = kColorDark3;
    [_superView addSubview:_sendStatusLabel];
    
    [sendStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneNumLabel.mas_bottom).offset(9);
        make.left.equalTo(_orderNumLabel);
    }];
    
    [_sendStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendStatusLabel.mas_top);
        make.left.equalTo(sendStatusLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right).offset(-15);

    }];
    
    //快递：
    UILabel *expressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    expressLabel.font = FONT(14);
    expressLabel.backgroundColor = [UIColor clearColor];
    expressLabel.textColor = kColorDark7;
    expressLabel.text = @"快递：";
    [_superView addSubview:expressLabel];
    
    _expressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _expressLabel.font = FONT(14);
    _expressLabel.backgroundColor = [UIColor clearColor];
    _expressLabel.textColor = kColorDark3;
    [_superView addSubview:_expressLabel];
    
    [expressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendStatusLabel.mas_bottom).offset(9);
        make.left.equalTo(_orderNumLabel);
    }];
    
    [_expressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(expressLabel.mas_top);
        make.left.equalTo(expressLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right).offset(-15);
    }];
    
    
    //快递：
    UILabel *sendTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    sendTimeLabel.font = FONT(14);
    sendTimeLabel.backgroundColor = [UIColor clearColor];
    sendTimeLabel.textColor = kColorDark7;
    sendTimeLabel.text = @"时间：";
    [_superView addSubview:sendTimeLabel];
    
    _sendTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _sendTimeLabel.font = FONT(14);
    _sendTimeLabel.backgroundColor = [UIColor clearColor];
    _sendTimeLabel.textColor = kColorDark3;
    [_superView addSubview:_sendTimeLabel];
    
    [sendTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(expressLabel.mas_bottom).offset(9);
        make.left.equalTo(_orderNumLabel);
    }];
    
    [_sendTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendTimeLabel.mas_top);
        make.left.equalTo(sendTimeLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right).offset(-15);

    }];
    
    //快递：
    UILabel *remarkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    remarkLabel.font = FONT(14);
    remarkLabel.backgroundColor = [UIColor clearColor];
    remarkLabel.textColor = kColorDark7;
    remarkLabel.text = @"备注：";
    [_superView addSubview:remarkLabel];
    
    _remarksLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _remarksLabel.font = FONT(14);
    _remarksLabel.backgroundColor = [UIColor clearColor];
    _remarksLabel.textColor = kColorDark3;
    [_superView addSubview:_remarksLabel];
    
    [remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendTimeLabel.mas_bottom).offset(9);
        make.left.equalTo(_orderNumLabel);
    }];
    
    [_remarksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remarkLabel.mas_top);
        make.left.equalTo(remarkLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right).offset(-15);
    }];
    

    //收货地址 :
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    addressLabel.font = FONT(14);
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.textColor = kColorDark7;
    addressLabel.text = @"收货地址 : ";
    [_superView addSubview:addressLabel];
    
    _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _addressLabel.font = FONT(14);
    _addressLabel.backgroundColor = [UIColor clearColor];
    _addressLabel.numberOfLines = 0;
    _addressLabel.textColor = kColorDark3;
    [_superView addSubview:_addressLabel];
    
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remarkLabel.mas_bottom).offset(9);
        make.left.equalTo(_orderNumLabel);
    }];
    
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addressLabel.mas_top).offset(-2);
        make.left.equalTo(addressLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right).offset(-15);
        make.width.equalTo(@(kScreen_Width - 26 - 70));
    }];
    
    UIView *lineView3 = [UIView new];
    lineView3.backgroundColor = kColorDDD;
    [_superView addSubview:lineView3];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_addressLabel.mas_bottom).offset(15);
        make.left.equalTo(_orderNumLabel);
        make.right.equalTo(_superView);
        make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
    }];

    __weak typeof(self) weakSelf = self;
    _deleteButton = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = FONT(14);
        [button setTitleColor:kColorDark7 forState:UIControlStateNormal];
        [button setTitle:@"取消订单" forState:UIControlStateNormal];
        [button doBorderWidth:1 color:kColorDark7 cornerRadius:4];
        [button bk_addEventHandler:^(id sender) {
            if (weakSelf.deleteActionBlock) {
                weakSelf.deleteActionBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_superView addSubview:button];
        button;
    });
    _payButton = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = FONT(14);
        [button setTitleColor:kColorBrandOrange forState:UIControlStateNormal];
        [button setTitle:@"付款" forState:UIControlStateNormal];
        [button doBorderWidth:1 color:kColorBrandOrange cornerRadius:4];
        [button bk_addEventHandler:^(id sender) {
            if (weakSelf.payActionBlock) {
                weakSelf.payActionBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_superView addSubview:button];
        button;
    });
    [_payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 30));
        make.top.equalTo(lineView3.mas_bottom).offset(10);
        make.right.offset(-15);
    }];
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 30));
        make.top.equalTo(_payButton);
        make.right.equalTo(_payButton.mas_left).offset(-10);
    }];
}

- (void)configViewWithModel:(ShopOrder *)order
{
    _titleLabel.text = order.giftName;
    [_coverView sd_setImageWithURL:[order.giftImage urlImageWithCodePathResize:90 * 2]];
    NSString *points_cost = [NSString stringWithFormat:@"  %@ 码币",[order.pointsCost stringValue]];
    [_codingCoinView setTitle:points_cost forState:UIControlStateNormal];
    
    _orderNumLabel.text = [NSString stringWithFormat:@"订单编号：%@", order.orderNo];
    NSString *remarkStr = order.remark ?: @"";
    if (order.optionName.length > 0) {
        remarkStr = [remarkStr stringByAppendingFormat:@"（%@）", order.optionName];
    }
    _remarksLabel.text  = remarkStr.length > 0? remarkStr: @"无";
    _nameLabel.text     = order.receiverName;
    _addressLabel.text  = order.receiverAddress;
    _phoneNumLabel.text = order.receiverPhone;
    if ([order.createdAt doubleValue] > 0) {
         NSDate *date =[NSDate dateWithTimeIntervalSince1970: ((double)(order.createdAt.longLongValue))/1000.0];
        if (date) {
            _sendTimeLabel.text = [date stringWithFormat:@"yyyy年MM月dd日 HH:mm"];
        }
    }
    _pointLabel.text = [NSString stringWithFormat:@"%.2f 码币", order.pointDiscount.floatValue];
    _moneyLabel.text = [NSString stringWithFormat:@"￥%.2f", order.paymentAmount.floatValue];
    if ([order.expressNo isEmpty]) {
        _expressLabel.text  = @"暂无";
    }else{
        _expressLabel.text  = order.expressNo;
    }
    NSInteger status = order.status.integerValue;//3 待付款, 0 未发货, 1 已发货, 2 已完成
    _sendStatusLabel.text = (status == 1 || status == 2? @"已发货": @"未发货");
    _deleteButton.hidden = _payButton.hidden = (status != 3);
    [_superView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_addressLabel.mas_bottom).offset(status == 3? (14 + 50): 14);
    }];
    CGFloat height = [self systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    self.frame = CGRectMake(0, 0, kScreen_Width, height);
    self.cellHeight = height;
}

@end
