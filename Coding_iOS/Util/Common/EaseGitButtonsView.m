//
//  EaseGitButtonsView.m
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//


#import "EaseGitButtonsView.h"
#import "EaseGitButton.h"

@interface EaseGitButtonsView ()
@property (strong, nonatomic) NSMutableArray *gitButtons;

@end

@implementation EaseGitButtonsView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addLineUp:YES andDown:NO];
        self.backgroundColor = kColorWhite;
    }
    return self;
}

- (void)setCurProject:(Project *)curProject{
    _curProject = curProject;
    if (_curProject.is_public.boolValue) {
        if (!_gitButtons) {
            NSInteger gitBtnNum = 3;
            CGFloat whiteSpace = 7.0;
            CGFloat btnWidth = (kScreen_Width - 2*kPaddingLeftWidth - whiteSpace *2) /3;
            _gitButtons = [[NSMutableArray alloc] initWithCapacity:gitBtnNum];
            
            for (int i = 0; i < gitBtnNum; i++) {
                EaseGitButton *gitBtn = [EaseGitButton gitButtonWithFrame:CGRectMake(kPaddingLeftWidth + i *(btnWidth +whiteSpace),(EaseGitButtonsView_Height - kSafeArea_Bottom - 36)/2, btnWidth, 36) type:i];
                __weak typeof(gitBtn) weakGitBtn = gitBtn;
                gitBtn.buttonClickedBlock = ^(EaseGitButton *button, EaseGitButtonPosition position){
                    if (position == EaseGitButtonPositionLeft) {
                        if (button.type == EaseGitButtonTypeStar
                            || button.type == EaseGitButtonTypeWatch) {
                            weakGitBtn.checked = !weakGitBtn.checked;
                            weakGitBtn.userNum += weakGitBtn.checked? 1: -1;
                        }
                    }
                    if (self.gitButtonClickedBlock) {
                        self.gitButtonClickedBlock(i, position);
                    }
                };
                
                [self addSubview:gitBtn];
                [_gitButtons addObject:gitBtn];
            }
        }
        
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

        self.hidden = NO;
    }else{
        self.hidden = YES;
    }
}
@end
