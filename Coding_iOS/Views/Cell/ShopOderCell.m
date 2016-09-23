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
    UIImageView *_coverView;
    
    UILabel     *_priceLabel;
    UILabel     *_titleLabel;
    UILabel     *_descLabel;
//    UILabel     *_countLabel;
    UIButton    *_codingCoinView;
    
    UILabel     *_orderNumLabel;
    UILabel     *_remarksLabel;
    UILabel     *_nameLabel;
    UILabel     *_addressLabel;
    UILabel     *_phoneNumLabel;
    UILabel     *_sendStatusLabel;
    UILabel     *_sendTimeLabel;
    UILabel     *_expressLabel;

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
        [self setUpContentView];
        
    }
    return self;
}


- (void)setUpContentView
{
    UIView *superView = [UIView new];
    [self.contentView addSubview:superView];
    [superView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    UILabel *orderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    orderLabel.font = FONT(14);
    orderLabel.backgroundColor = [UIColor clearColor];
    orderLabel.text = @" 订单编号 ";
    orderLabel.textAlignment = NSTextAlignmentCenter;
    orderLabel.layer.masksToBounds = YES;
    orderLabel.layer.cornerRadius = 4;
    orderLabel.layer.borderWidth = 0.5;
    orderLabel.layer.borderColor = [UIColor colorWithHexString:@"0xB5B5B5"].CGColor;
    orderLabel.textColor = kColor222;
    [superView addSubview:orderLabel];
    
    _orderNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _orderNumLabel.font = FONT(15);
    _orderNumLabel.backgroundColor = [UIColor clearColor];
    _orderNumLabel.textColor = [UIColor colorWithHexString:@"0x000000"];
    [superView addSubview:_orderNumLabel];
    
    [orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superView.mas_left).offset(12);
        make.top.equalTo(superView.mas_top).offset(12);
//        make.width.offset(132/2);
        make.height.offset(20);
    }];
    
    [_orderNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(orderLabel.mas_right).offset(16);
        make.centerY.equalTo(orderLabel.mas_centerY);
    }];
    
    UIView *_goodsInfoView = [[UIView alloc] init];
    _goodsInfoView.backgroundColor = kColorTableSectionBg;
    [superView addSubview:_goodsInfoView];
    [_goodsInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(orderLabel.mas_bottom).offset(15);
        make.left.equalTo(superView.mas_left).offset(12);
        make.right.equalTo(superView.mas_right).offset(-12);
        make.height.offset(108/2);
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
    
    _remarksLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _remarksLabel.font = FONT(12);
    _remarksLabel.numberOfLines = 0 ;
    _remarksLabel.backgroundColor = [UIColor clearColor];
    _remarksLabel.textColor = kColor666;
    [_goodsInfoView addSubview:_remarksLabel];
    
//    _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    _countLabel.font = FONT(12);
//    _countLabel.backgroundColor = [UIColor clearColor];
//    _countLabel.text  = @"ⅹ1";
//    _countLabel.textColor = kColorBrandGreen;
//    [_goodsInfoView addSubview:_countLabel];
    
    _codingCoinView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_codingCoinView setImage:[UIImage imageNamed:@"shop_coding_coin_icon"] forState:UIControlStateNormal];
    [_codingCoinView setTitle:@"  码币 " forState:UIControlStateNormal];
    [_codingCoinView setTitleColor:kColor222 forState:UIControlStateNormal];
    [_codingCoinView.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    [_goodsInfoView addSubview:_codingCoinView];
    
    
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(_goodsInfoView);
        make.width.offset(90);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverView.mas_top).offset(7);
        make.left.equalTo(_coverView.mas_right).offset(12);
        make.right.equalTo(superView.mas_right).offset(-(40));
    }];
    
//    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(_titleLabel.mas_centerY);
//        make.right.equalTo(_goodsInfoView.mas_right).offset(-7);
//        make.width.offset(20);
//    }];
    
    [_codingCoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(8);
        make.left.equalTo(_titleLabel.mas_left);
    }];
    
    [_remarksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_codingCoinView.mas_bottom).offset(7);
        make.left.equalTo(_titleLabel.mas_left);
    }];
    
    //基本的送货信息
    
    // 收货人
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.font = FONT(14);
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = kColor666;
    nameLabel.text = @"收货人：";
    [superView addSubview:nameLabel];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = FONT(14);
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = kColor666;
    [superView addSubview:_nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_goodsInfoView.mas_bottom).offset(12);
        make.left.equalTo(_goodsInfoView.mas_left);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_top);
        make.left.equalTo(nameLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right);
    }];
    
    //联系电话：
    UILabel *phoneNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    phoneNumLabel.font = FONT(14);
    phoneNumLabel.backgroundColor = [UIColor clearColor];
    phoneNumLabel.textColor = kColor666;
    phoneNumLabel.text = @"联系电话：";
    [superView addSubview:phoneNumLabel];
    
    _phoneNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _phoneNumLabel.font = FONT(14);
    _phoneNumLabel.backgroundColor = [UIColor clearColor];
    _phoneNumLabel.textColor = kColor666;
    [superView addSubview:_phoneNumLabel];
    
    [phoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(9);
        make.left.equalTo(nameLabel.mas_left);
    }];
    
    [_phoneNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneNumLabel.mas_top);
        make.left.equalTo(phoneNumLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right);

    }];

    //状态 :
    UILabel *sendStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    sendStatusLabel.font = FONT(14);
    sendStatusLabel.backgroundColor = [UIColor clearColor];
    sendStatusLabel.textColor = kColor666;
    sendStatusLabel.text = @"状态：";
    [superView addSubview:sendStatusLabel];
    
    _sendStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _sendStatusLabel.font = FONT(14);
    _sendStatusLabel.backgroundColor = [UIColor clearColor];
    _sendStatusLabel.textColor = kColor666;
    [superView addSubview:_sendStatusLabel];
    
    [sendStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneNumLabel.mas_bottom).offset(9);
        make.left.equalTo(_goodsInfoView.mas_left);
    }];
    
    [_sendStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendStatusLabel.mas_top);
        make.left.equalTo(sendStatusLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right);

    }];
    
    //快递：
    UILabel *expressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    expressLabel.font = FONT(14);
    expressLabel.backgroundColor = [UIColor clearColor];
    expressLabel.textColor = kColor666;
    expressLabel.text = @"快递：";
    [superView addSubview:expressLabel];
    
    _expressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _expressLabel.font = FONT(14);
    _expressLabel.backgroundColor = [UIColor clearColor];
    _expressLabel.textColor = kColor666;
    [superView addSubview:_expressLabel];
    
    [expressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendStatusLabel.mas_bottom).offset(9);
        make.left.equalTo(_goodsInfoView.mas_left);
    }];
    
    [_expressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(expressLabel.mas_top);
        make.left.equalTo(expressLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right);

    }];
    
    
    //快递：
    UILabel *sendTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    sendTimeLabel.font = FONT(14);
    sendTimeLabel.backgroundColor = [UIColor clearColor];
    sendTimeLabel.textColor = kColor666;
    sendTimeLabel.text = @"时间：";
    [superView addSubview:sendTimeLabel];
    
    _sendTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _sendTimeLabel.font = FONT(14);
    _sendTimeLabel.backgroundColor = [UIColor clearColor];
    _sendTimeLabel.textColor = kColor666;
    [superView addSubview:_sendTimeLabel];
    
    [sendTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(expressLabel.mas_bottom).offset(9);
        make.left.equalTo(_goodsInfoView.mas_left);
    }];
    
    [_sendTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendTimeLabel.mas_top);
        make.left.equalTo(sendTimeLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right);

    }];
    
    //快递：
    UILabel *remarkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    remarkLabel.font = FONT(14);
    remarkLabel.backgroundColor = [UIColor clearColor];
    remarkLabel.textColor = kColor666;
    remarkLabel.text = @"备注：";
    [superView addSubview:remarkLabel];
    
    _remarksLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _remarksLabel.font = FONT(14);
    _remarksLabel.backgroundColor = [UIColor clearColor];
    _remarksLabel.textColor = kColor666;
    [superView addSubview:_remarksLabel];
    
    [remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendTimeLabel.mas_bottom).offset(9);
        make.left.equalTo(_goodsInfoView.mas_left);
    }];
    
    [_remarksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remarkLabel.mas_top);
        make.left.equalTo(remarkLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right);
        
    }];
    

    //收货地址 :
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    addressLabel.font = FONT(14);
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.textColor = kColor666;
    addressLabel.text = @"收货地址 : ";
    [superView addSubview:addressLabel];
    
    _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _addressLabel.font = FONT(14);
    _addressLabel.backgroundColor = [UIColor clearColor];
    _addressLabel.numberOfLines = 0;
//    _addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _addressLabel.textColor = kColor666;
    [superView addSubview:_addressLabel];
    
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(remarkLabel.mas_bottom).offset(9);
        make.left.equalTo(_goodsInfoView.mas_left);
//        make.right.equalTo(_addressLabel.mas_left);
//        make.width.offset(70);
        make.height.offset(15);
    }];
    
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addressLabel.mas_top).offset(-2);
        make.left.equalTo(addressLabel.mas_right);
        make.right.equalTo(_goodsInfoView.mas_right);
        make.width.equalTo(@(kScreen_Width - 26 - 70));
        make.bottom.equalTo(superView.mas_bottom).offset(-15);
    }];
    
    [superView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_orderNumLabel.mas_top).offset(-15);
        make.bottom.equalTo(_addressLabel.mas_bottom).offset(15);
    }];
}

- (void)configViewWithModel:(ShopOrder *)order
{
    _titleLabel.text = order.giftName;
    [_coverView sd_setImageWithURL:[order.giftImage urlImageWithCodePathResize:90 * 2]];
    NSString *points_cost = [NSString stringWithFormat:@"  %@ 码币",[order.pointsCost stringValue]];
    [_codingCoinView setTitle:points_cost forState:UIControlStateNormal];
    
    _orderNumLabel.text = order.orderNo;
    NSString *remarkStr = order.remark ?: @"";
    if (order.optionName.length > 0) {
        remarkStr = [remarkStr stringByAppendingFormat:@"（%@）", order.optionName];
    }
    _remarksLabel.text  = remarkStr.length > 0? remarkStr: @"无";
    _nameLabel.text     = order.receiverName;
    _addressLabel.text  = order.receiverAddress;
    _phoneNumLabel.text = order.receiverPhone;
    switch (order.status.intValue) {
        case 0:
            _sendStatusLabel.text = @"未发货";

            break;
        case 1:
            _sendStatusLabel.text = @"已发货";
            
            break;
        default:
            break;
    }
    if ([order.createdAt doubleValue] > 0) {
        
         NSDate *date =[NSDate dateWithTimeIntervalSince1970: ((double)(order.createdAt.longLongValue))/1000.0];
        if (date) {
            _sendTimeLabel.text = [date stringWithFormat:@"yyyy年MM月dd日 HH:mm"];
        }
    }
    if ([order.expressNo isEmpty]) {
        _expressLabel.text  = @"暂无";
    }else
        _expressLabel.text  = order.expressNo;

    CGFloat height = [self systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    self.frame = CGRectMake(0, 0, kScreen_Width, height);
    self.cellHeight = height;
     
}

@end
