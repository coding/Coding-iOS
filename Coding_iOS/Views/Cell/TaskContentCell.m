//
//  TaskContentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-19.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#define kTaskContentCell_ContentHeightMin kScaleFrom_iPhone5_Desgin(90.0)
#define kTextView_Pading 8.0
#define kTaskContentCell_ContentWidth (kScreen_Width-kPaddingLeftWidth-kPaddingLeftWidth + 2*kTextView_Pading)
#define kTaskContentCell_ContentFont [UIFont systemFontOfSize:18]


#import "TaskContentCell.h"
#import "ProjectTagsView.h"
#import "Coding_NetAPIManager.h"

@interface TaskContentCell ()
@property (strong, nonatomic) ProjectTagsView *tagsView;

@property (strong, nonatomic) UITextView *taskContentView;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) UILabel *creatorLabel, *numLabel;
@property (strong, nonatomic) UIView *downLineView, *upLineView;
@end

@implementation TaskContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_tagsView) {
            _tagsView = [ProjectTagsView viewWithTags:nil];
            @weakify(self);
            _tagsView.addTagBlock = ^(){
                @strongify(self);
                if (self.addTagBlock) {
                    self.addTagBlock();
                }
            };
            _tagsView.deleteTagBlock = ^(ProjectTag *curTag){
                @strongify(self);
                [self deleteTag:curTag];
            };
            [self.contentView addSubview:_tagsView];
        }
        if (!_upLineView) {
            _upLineView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - 2*kPaddingLeftWidth, 0.5)];
            _upLineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_line"]];
            [self.contentView addSubview:_upLineView];
        }
        if (!_taskContentView) {
            _taskContentView = [[UITextView alloc] initWithFrame:CGRectZero];
            _taskContentView.backgroundColor = [UIColor clearColor];
            _taskContentView.font = kTaskContentCell_ContentFont;
            _taskContentView.delegate = self;
            [self.contentView addSubview:_taskContentView];
        }
        if (!_numLabel) {
            if (!_numLabel) {
                _numLabel = [[UILabel alloc] init];
                _numLabel.font = [UIFont systemFontOfSize:12];
                _numLabel.textColor = kColor222;
                [self.contentView addSubview:_numLabel];
            }
        }
        if (!_creatorLabel) {
            _creatorLabel = [[UILabel alloc] init];
            _creatorLabel.font = [UIFont systemFontOfSize:12];
            _creatorLabel.textColor = kColor999;
            [self.contentView addSubview:_creatorLabel];
        }
        if (!_deleteBtn) {
            _deleteBtn = ({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.titleLabel.font = [UIFont systemFontOfSize:13];
                [button setTitleColor:kColor666 forState:UIControlStateNormal];
                [button setTitle:@"删除" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:button];
                button;
            });
        }
        if (!_downLineView) {
            _downLineView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - 2*kPaddingLeftWidth, 0.5)];
            _downLineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_line"]];
            [self.contentView addSubview:_downLineView];
        }
        [_upLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(0.5);
            make.bottom.equalTo(_tagsView).offset(7);
        }];
        [_taskContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_upLineView.mas_bottom).offset(5.0);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth-kTextView_Pading);
            make.right.equalTo(self.contentView).offset(-(kPaddingLeftWidth-kTextView_Pading));
            make.height.mas_equalTo(kTaskContentCell_ContentHeightMin);
        }];
        [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(kPaddingLeftWidth);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            make.height.mas_equalTo(20);
        }];
        [_creatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.numLabel.mas_right);
            make.right.lessThanOrEqualTo(_deleteBtn.mas_left).offset(10);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            make.height.mas_equalTo(20);
        }];
        
        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 20));
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            make.right.equalTo(self.contentView.mas_right).offset(-kPaddingLeftWidth);
        }];
        [_downLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(0.5);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_task) {
        return;
    }
    _tagsView.tags = _task.labels;
    [_tagsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo([ProjectTagsView getHeightForTags:self.task.labels]);
    }];
    
    _taskContentView.text = _task.content;
    
    if (_task.handleType > TaskHandleTypeEdit) {
        _creatorLabel.text = [NSString stringWithFormat:@"%@ 现在", _task.creator.name];
        _deleteBtn.hidden = YES;
        _numLabel.hidden = YES;
    }else{
        _numLabel.text = [NSString stringWithFormat:@"#%@  ", _task.number.stringValue];
        _creatorLabel.text = [NSString stringWithFormat:@"%@ 创建于 %@", _task.creator.name, [_task.created_at stringDisplay_HHmm]];
        _deleteBtn.hidden = !([_task.creator.global_key isEqualToString:[Login curLoginUser].global_key] || _task.project.owner_id.integerValue == [Login curLoginUser].id.integerValue);
    }
}

- (void)deleteBtnClicked:(id)sender{
    if (_deleteBtnClickedBlock) {
        _deleteBtnClickedBlock(_task);
    }
}
- (void)descriptionBtnClicked:(id)sender{
    if (_descriptionBtnClickedBlock) {
        _descriptionBtnClickedBlock(_task);
    }
}

- (void)deleteTag:(ProjectTag *)curTag{
    curTag = [ProjectTag tags:_task.labels hasTag:curTag];
    if (curTag) {
        NSMutableArray *selectedTags = [_task.labels mutableCopy];
        [selectedTags removeObject:curTag];
        @weakify(self);
        [[Coding_NetAPIManager sharedManager] request_EditTask:_task withTags:selectedTags andBlock:^(id data, NSError *error) {
            @strongify(self);
            if (data) {
                self.task.labels = selectedTags;
                if (self.tagsChangedBlock) {
                    self.tagsChangedBlock();
                }
            }
        }];
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Task class]]) {
        Task *task = (Task *)obj;
        cellHeight += 12;
        cellHeight += [ProjectTagsView getHeightForTags:task.labels];
        cellHeight += 7 + 5 + kTaskContentCell_ContentHeightMin + 40;
    }
    return cellHeight;
}

#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(textView.text);
    }
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (self.textViewBecomeFirstResponderBlock) {
        self.textViewBecomeFirstResponderBlock();
    }
    return YES;
}

@end
