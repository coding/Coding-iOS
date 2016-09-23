//
//  FileChangeListCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileChangeListCell.h"

@interface FileChangeListCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *fileNameL, *changeStatusL;
@end

@implementation FileChangeListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = kColorTableBG;
        if (!_iconView) {
            _iconView = [UIImageView new];
            _iconView.layer.masksToBounds = YES;
            _iconView.layer.cornerRadius = 2.0;
            [self.contentView addSubview:_iconView];
            [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                make.size.mas_equalTo(CGSizeMake(20, 20));
            }];
        }
        if (!_fileNameL) {
            _fileNameL = [UILabel new];
            _fileNameL.font = [UIFont systemFontOfSize:15];
            _fileNameL.textColor = kColor222;
            [self.contentView addSubview:_fileNameL];
            [_fileNameL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_iconView.mas_right).offset(15);
                make.centerY.equalTo(self.contentView);
                make.height.mas_equalTo(20);
            }];
        }
        if (!_changeStatusL) {
            _changeStatusL = [UILabel new];
            [self.contentView addSubview:_changeStatusL];
            [_changeStatusL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_fileNameL.mas_right);
                make.right.equalTo(self.contentView);
                make.height.centerY.equalTo(_fileNameL);
                make.width.mas_equalTo(80);
            }];
        }
    }
    return self;
}

- (void)setCurFileChange:(FileChange *)curFileChange{
    _curFileChange = curFileChange;
    if (!_curFileChange) {
        return;
    }
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"file_changeType_%@", _curFileChange.changeType]];
    if (image) {
        _iconView.image = image;
    }else{
        _iconView.image = [UIImage imageNamed:@"file_changeType_MODIFY"];
        NSLog(@"%@ : %@", _curFileChange.changeType, _curFileChange.path);
    }
    _fileNameL.text = _curFileChange.displayFileName;
    _changeStatusL.attributedText = [self p_styleStatusStr];
}

- (NSAttributedString *)p_styleStatusStr{
    NSString *addStr = [NSString stringWithFormat:@"+%@", _curFileChange.insertions.stringValue];
    NSString *deleteStr = [NSString stringWithFormat:@"-%@", _curFileChange.deletions.stringValue];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@", addStr, deleteStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x98C685"]}
                        range:NSMakeRange(0, addStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0xDF7D7B"]}
                        range:NSMakeRange(attrString.length - deleteStr.length, deleteStr.length)];
    
    [attrString addAttribute:NSParagraphStyleAttributeName value:({
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.alignment = NSTextAlignmentRight;
        style;
    }) range:NSMakeRange(0, attrString.length)];
    return attrString;
}

+ (CGFloat)cellHeight{
    return 44.0;
}

@end
