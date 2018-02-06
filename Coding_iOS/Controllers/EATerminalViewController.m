//
//  EATerminalViewController.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/1/30.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EATerminalViewController.h"

@interface EATerminalViewController ()

@property (strong, nonatomic) UIWindow *myToolWindow;
@property (strong, nonatomic) UIView *myToolBar;
@property (strong, nonatomic) EATerminalPopView *myPopView;

@property (strong, nonatomic) NSArray *buttonList;
@end

@implementation EATerminalViewController

+ (instancetype)terminalVC{
    static NSInteger index = 0;
    NSURL *curUrl = [NSURL URLWithString:(index % 2 == 0)? @"http://ide.xiayule.net/login": @"http://192.168.0.212:8060/"];
    index++;
    return [[self alloc] initWithURL:curUrl];
}

- (void)setTitle:(NSString *)title{
    [super setTitle:@"Terminal"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
    [self updateButtonList];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.myToolWindow.hidden = YES;
    self.myToolWindow = nil;
    self.myToolBar = nil;
    [self.myPopView removeFromSuperview];
    self.myPopView = nil;
}

- (UIWindow *)myToolWindow{
    if (!_myToolWindow) {
        _myToolWindow = ({
            UIWindow *toolWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, 44)];
            toolWindow.backgroundColor = [UIColor clearColor];
            toolWindow.windowLevel = UIWindowLevelStatusBar;
            toolWindow.hidden = NO;
            toolWindow;
        });
    }
    return _myToolWindow;
}

- (UIView *)myToolBar{
    if (!_myToolBar) {
        _myToolBar = ({
            UIView *toolBar = [[UIView alloc] initWithFrame:self.myToolWindow.bounds];
            toolBar.backgroundColor = kColorWhite;
            [self.myToolWindow addSubview:toolBar];
            toolBar;
        });
    }
    return _myToolBar;
}

- (EATerminalPopView *)myPopView{
    if (!_myPopView) {
        _myPopView = [EATerminalPopView new];
        _myPopView.frame = CGRectMake(kScreen_Width - _myPopView.width - 5, kScreen_Height, _myPopView.width, _myPopView.height);
        _myPopView.hidden = YES;
        [kKeyWindow addSubview:_myPopView];
        __weak typeof(self) weakSelf = self;
        _myPopView.choosedIndexBlock = ^(NSArray *choosedList) {
            [weakSelf updateButtonList];
        };
    }
    return _myPopView;
}

- (void)updateButtonList{
    NSMutableArray *buttonList = @[@"esc", @"ctrl", @"alt", @"->"].mutableCopy;
    [buttonList addObjectsFromArray:self.myPopView.choosedList];
    [buttonList addObject:@"..."];
    self.buttonList = buttonList.copy;
}

- (void)setButtonList:(NSArray *)buttonList{
    _buttonList = buttonList;
    NSInteger buttonCount = MAX(1, _buttonList.count);
    CGFloat lineW = 1.0;
    CGFloat buttonW = (kScreen_Width - lineW * (buttonCount - 1))/ buttonCount;
    if (_buttonList.count == self.myToolBar.subviews.count) {
        for (EATerminalButton *button in self.myToolBar.subviews) {
            NSInteger index = (NSInteger)((button.x)/ (buttonW + lineW));
            button.name = _buttonList[index];
        }
    }else{
        [self.myToolBar.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        for (NSInteger index = 0; index < _buttonList.count; index++) {
            EATerminalButton *button = [EATerminalButton terminalButtonWithName:_buttonList[index]];
            button.frame = CGRectMake(index * (buttonW + lineW), 0, buttonW, self.myToolBar.height);
            [button addTarget:self action:@selector(terminalButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.myToolBar addSubview:button];
        }
    }
}

- (void)terminalButtonClicked:(EATerminalButton *)sender{
    DebugLog(@"%@", sender.name);
    if ([sender.name isEqualToString:@"..."]) {
        self.myPopView.hidden = !self.myPopView.hidden;
    }else{
        
    }
}

#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)aNotification{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
        CGFloat keyboardY =  keyboardEndFrame.origin.y;
        CGFloat footerToolBarY = keyboardY - ((keyboardY < kScreen_Height)? CGRectGetHeight(self.myToolWindow.frame): 0);
        footerToolBarY += 44;//盖住原本的那个bar
        self.myToolWindow.y = footerToolBarY;
        self.myPopView.y = footerToolBarY - self.myPopView.height - 5;
        if (keyboardY >= kScreen_Height) {
            self.myPopView.hidden = YES;
        }
    } completion:^(BOOL finished) {
    }];
}

@end

#define kEATerminalButton_SelectMark @""

@interface EATerminalButton ()
@property (assign, nonatomic) BOOL isSmall;
@end

@implementation EATerminalButton


+ (instancetype)terminalButtonWithName:(NSString *)name{
    EATerminalButton *button = [EATerminalButton new];
    button.isSmall = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:kColorDark2 forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor colorWithHexString:@"0xBBC2CA"];
    button.name = name;
    return button;
}

+ (instancetype)smallTerminalButtonWithName:(NSString *)name choosed:(BOOL)isChoosed{
    EATerminalButton *button = [EATerminalButton new];
    button.isSmall = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitleColor:kColorDark2 forState:UIControlStateNormal];
    
    button.name = name;
    button.isChoosed = isChoosed;
    button.enabled = [name isEqualToString:kEATerminalButton_SelectMark];
    return button;
}

+ (NSDictionary *)p_buttonImageDict{
    return @{@"->": @"terminal_tail",
             @"...": @"terminal_more",
             @"U": @"▲",
             @"D": @"▼",
             @"L": @"◀",
             @"R": @"▶",
             };
}

- (void)setName:(NSString *)name{
    _name = name;
    NSString *imageName = [self.class p_buttonImageDict][name];
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    if (buttonImage) {
        [self setImage:buttonImage forState:UIControlStateNormal];
        [self setTitle:nil forState:UIControlStateNormal];
    }else if (imageName){
        self.titleLabel.font = [UIFont systemFontOfSize:_isSmall? 12: 18];
        [self setImage:nil forState:UIControlStateNormal];
        [self setTitle:imageName forState:UIControlStateNormal];
    }else{
        self.titleLabel.font = [UIFont systemFontOfSize:_isSmall? 12: 15];
        [self setImage:nil forState:UIControlStateNormal];
        [self setTitle:_name forState:UIControlStateNormal];
    }
}

- (void)setIsChoosed:(BOOL)isChoosed{
    _isChoosed = isChoosed;
    if ([_name isEqualToString:kEATerminalButton_SelectMark]) {
        self.backgroundColor = [UIColor clearColor];
        [self setImage:[UIImage imageNamed:_isChoosed? @"terminal_box_selected": @"terminal_box_unselected"] forState:UIControlStateNormal];
    }else{
        self.backgroundColor = _isChoosed? [UIColor colorWithHexString:@"0xA7B0BD"]: kColorWhite;
    }
}

@end

#define kEATerminalPopView_ChoosedIndex @"EATerminalPopView_ChoosedIndex"

@interface EATerminalPopView ()

@end

@implementation EATerminalPopView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xD4D6DD"];
        CGFloat buttonW = 33;
        CGFloat buttonH = 31;
        CGFloat lineW = 2;
        CGFloat paddingW = 4;
        NSArray *buttonA = self.p_buttonA;
        NSInteger choosedIndex = self.choosedIndex;
        __weak typeof(self) weakSelf = self;
        for (NSInteger row = 0; row < buttonA.count; row++) {
            NSArray *buttonInRow = buttonA[row];
            for (NSInteger col = 0; col < buttonInRow.count; col++) {
                EATerminalButton *button = [EATerminalButton smallTerminalButtonWithName:buttonInRow[col] choosed:(row == choosedIndex)];
                button.frame = CGRectMake(paddingW + (lineW + buttonW)* col, paddingW + (lineW + buttonH)* row, buttonW, buttonH);
                [self addSubview:button];
                if ([buttonInRow[col] isEqualToString:kEATerminalButton_SelectMark]) {
                    [button bk_addEventHandler:^(EATerminalButton *sender) {
                        NSInteger rowIndex = (NSInteger)((sender.y - paddingW) / (buttonH + lineW));
                        weakSelf.choosedIndex = rowIndex;
                    } forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
        self.frame = CGRectMake(0, 0, paddingW * 2 - lineW + (lineW + buttonW)* [buttonA.firstObject count], paddingW * 2 - lineW + (lineW + buttonH)* buttonA.count);
        
        UIImageView *arrowV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"terminal_triangle"]];
        [self addSubview:arrowV];
        [arrowV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(15, 8));
            make.top.equalTo(self.mas_bottom);
            make.right.offset(-(paddingW + (buttonW - 15)/ 2));
        }];
    }
    return self;
}

- (NSArray *)p_buttonA{
    return @[@[kEATerminalButton_SelectMark, @"/", @"-", @"|", @"@"],
             @[kEATerminalButton_SelectMark, @"~", @".", @":", @";"],
             @[kEATerminalButton_SelectMark, @"U", @"D", @"L", @"R"]];
}

- (NSArray *)choosedList{
    NSMutableArray *choosedList = [self.p_buttonA[self.choosedIndex] mutableCopy];
    [choosedList removeObject:kEATerminalButton_SelectMark];
    return choosedList.copy;
}

- (NSInteger)choosedIndex{
    NSNumber *index = [[NSUserDefaults standardUserDefaults] objectForKey:kEATerminalPopView_ChoosedIndex];
    return index? MIN(index.integerValue, self.p_buttonA.count - 1): 2;
}

- (void)setChoosedIndex:(NSInteger)choosedIndex{
    [[NSUserDefaults standardUserDefaults] setObject:@(choosedIndex) forKey:kEATerminalPopView_ChoosedIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];

    CGFloat buttonH = 31;
    CGFloat lineW = 2;
    CGFloat paddingW = 4;
    for (UIView *subV in self.subviews) {
        if ([subV isKindOfClass:[EATerminalButton class]]) {
            NSInteger buttonRow = (NSInteger)((subV.y - paddingW) / (buttonH + lineW));
            ((EATerminalButton *)subV).isChoosed = (buttonRow == choosedIndex);
        }
    }
    if (_choosedIndexBlock) {
        _choosedIndexBlock(self.choosedList);
    }
}

@end
