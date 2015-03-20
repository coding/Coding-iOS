//
//  ProjectDescriptionCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kProjectDescriptionCell_Font [UIFont systemFontOfSize:15]
#define kProjectDescriptionCell_ContentWidth (kScreen_Width - kPaddingLeftWidth*2)

#import "ProjectDescriptionCell.h"
#import "EaseGitButton.h"

@interface ProjectDescriptionCell ()
@property (strong, nonatomic) UILabel *proDesL;
@property (strong, nonatomic) NSMutableArray *gitButtons;
@end

@implementation ProjectDescriptionCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_proDesL) {
            _proDesL = [[UILabel alloc] init];
            _proDesL.numberOfLines = 0;
            _proDesL.font = kProjectDescriptionCell_Font;
            _proDesL.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_proDesL];
        }
        if (!_gitButtons) {
            NSInteger gitBtnNum = 3;
            CGFloat whiteSpace = 7.0;
            CGFloat btnWidth = (kProjectDescriptionCell_ContentWidth - whiteSpace *2) /3;
            _gitButtons = [[NSMutableArray alloc] initWithCapacity:gitBtnNum];
            
            for (int i = 0; i < gitBtnNum; i++) {
                EaseGitButton *gitBtn = [EaseGitButton gitButtonWithFrame:CGRectMake(kPaddingLeftWidth + i *(btnWidth +whiteSpace),0, btnWidth, kScaleFrom_iPhone5_Desgin(30)) type:i];
                
                [gitBtn bk_addEventHandler:^(EaseGitButton *sender) {
                    if (sender.type == EaseGitButtonTypeStar
                        || sender.type == EaseGitButtonTypeWatch) {
                        gitBtn.checked = !gitBtn.checked;
                        gitBtn.userNum += gitBtn.checked? 1: -1;
                    }
                    if (self.gitButtonClickedBlock) {
                        self.gitButtonClickedBlock(i);
                    }
                } forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:gitBtn];
                [_gitButtons addObject:gitBtn];
            }
        }
    }
    return self;
}

- (void)setCurProject:(Project *)curProject{
    _curProject = curProject;
    if (!_curProject) {
        return;
    }
    _proDesL.text = _curProject.description_mine;
    [_gitButtons enumerateObjectsUsingBlock:^(EaseGitButton *obj, NSUInteger idx, BOOL *stop) {
        switch (idx) {
            case EaseGitButtonTypeStar:
            {
                obj.userNum = _curProject.star_count.integerValue;
                obj.checked = _curProject.stared.boolValue;
            }
                break;
            case EaseGitButtonTypeWatch:
            {
                obj.userNum = _curProject.watch_count.integerValue;
                obj.checked = _curProject.watched.boolValue;
            }
                break;
            case EaseGitButtonTypeFork:
            default:
            {
                obj.userNum = _curProject.fork_count.integerValue;
                obj.checked = NO;
            }
                break;
        }
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat desHeight = [_curProject.description_mine getSizeWithFont:kProjectDescriptionCell_Font constrainedToSize:CGSizeMake(kProjectDescriptionCell_ContentWidth, CGFLOAT_MAX)].height;
    [_proDesL setFrame:CGRectMake(kPaddingLeftWidth, kPaddingLeftWidth, kProjectDescriptionCell_ContentWidth, desHeight)];
    
    CGFloat gitBtnY = kPaddingLeftWidth*2 +desHeight;
    [_gitButtons enumerateObjectsUsingBlock:^(EaseGitButton *obj, NSUInteger idx, BOOL *stop) {
        CGFloat diffY = ABS(CGRectGetMinY(obj.frame) - gitBtnY);
        if (diffY > 1) {
            [obj setY:gitBtnY];
        }
    }];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Project class]]) {
        cellHeight = kPaddingLeftWidth *3 + kScaleFrom_iPhone5_Desgin(33);
        
        Project *curProject = (Project *)obj;
        CGFloat desHeight = [curProject.description_mine getSizeWithFont:kProjectDescriptionCell_Font constrainedToSize:CGSizeMake(kProjectDescriptionCell_ContentWidth, CGFLOAT_MAX)].height;
        cellHeight += desHeight;
    }
    return cellHeight;
}

@end
