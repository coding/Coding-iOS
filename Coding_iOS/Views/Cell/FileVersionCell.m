//
//  FileVersionCell.m
//  Coding_iOS
//
//  Created by Ease on 15/8/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kFileVersionCell_IconWidth 45.0
#define kFileVersionCell_LeftPading (kPaddingLeftWidth +kFileVersionCell_IconWidth +20.0)
#define kFileVersionCell_TopPading 10.0

#import "FileVersionCell.h"
#import "Coding_FileManager.h"
#import "ASProgressPopUpView.h"
#import "YLImageView.h"

@interface FileVersionCell ()<ASProgressPopUpViewDelegate>
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel, *infoLabel, *sizeLabel;
@property (strong, nonatomic) UIButton *stateButton;

@property (strong, nonatomic) ASProgressPopUpView *progressView;
@end

@implementation FileVersionCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_iconView) {
            _iconView = [[YLImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([FileVersionCell cellHeight] - kFileVersionCell_IconWidth)/2, kFileVersionCell_IconWidth, kFileVersionCell_IconWidth)];
            _iconView.layer.masksToBounds = YES;
            _iconView.layer.cornerRadius = 2.0;
            _iconView.layer.borderWidth = 0.5;
            _iconView.layer.borderColor = kColorDDD.CGColor;
            _iconView.contentMode = UIViewContentModeScaleAspectFill;
            [self.contentView addSubview:_iconView];
        }
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileVersionCell_LeftPading, kFileVersionCell_TopPading, (kScreen_Width - kFileVersionCell_LeftPading - 60), 25)];
            _nameLabel.textColor = kColor222;
            _nameLabel.font = [UIFont systemFontOfSize:16];
            [self.contentView addSubview:_nameLabel];
        }
        if (!_sizeLabel) {
            _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileVersionCell_LeftPading, ([FileVersionCell cellHeight]- 15)/2+3, (kScreen_Width - kFileVersionCell_LeftPading - 60), 15)];
            _sizeLabel.textColor = kColor999;
            _sizeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_sizeLabel];
        }
        if (!_infoLabel) {
            _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileVersionCell_LeftPading, ([FileVersionCell cellHeight]- 15 - kFileVersionCell_TopPading), (kScreen_Width - kFileVersionCell_LeftPading - 60), 15)];
            _infoLabel.textColor = kColor999;
            _infoLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_infoLabel];
        }
        if (!_progressView) {
            _progressView = [[ASProgressPopUpView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, [FileVersionCell cellHeight]-2.5, kScreen_Width- kPaddingLeftWidth, 2.0)];
            
            _progressView.popUpViewCornerRadius = 12.0;
            _progressView.delegate = self;
            _progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
            [_progressView setTrackTintColor:[UIColor colorWithHexString:@"0xe6e6e6"]];
            _progressView.popUpViewAnimatedColors = @[kColorBrandGreen];
            _progressView.hidden = YES;
            [self.contentView addSubview:self.progressView];
        }
        if (!_stateButton) {
            _stateButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width - 55), ([FileVersionCell cellHeight] - 25)/2, 45, 25)];
            [_stateButton addTarget:self action:@selector(clickedByUser) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_stateButton];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_curVersion) {
        return;
    }
    _nameLabel.text = _curVersion.remark;
    _sizeLabel.text = [NSString sizeDisplayWithByte:_curVersion.size.floatValue];
    _infoLabel.text = [NSString stringWithFormat:@"%@ %@ %@", _curVersion.owner.name, _curVersion.action_msg, [_curVersion.created_at stringDisplay_HHmm]];
    if (_curVersion.preview && _curVersion.preview.length > 0) {
        [_iconView sd_setImageWithURL:[NSURL URLWithString:_curVersion.preview]];
    }else{
        _iconView.image = [UIImage imageWithFileType:_curVersion.fileType];
    }
}

- (void)setCurVersion:(FileVersion *)curVersion{
    _curVersion = curVersion;
    if (!_curVersion) {
        return;
    }
    Coding_DownloadTask *cDownloadTask = [_curVersion cDownloadTask];
    [self updateProgress:cDownloadTask.progress];
    [self changeToState:_curVersion.downloadState];
}

- (void)updateProgress:(NSProgress *)progress{
    if (progress) {
        if (_curVersion.size.floatValue/1024/1024 > 5.0) {//大于5M的文件，下载时显示百分比
            [_progressView showPopUpViewAnimated:NO];
        }else{
            [_progressView hidePopUpViewAnimated:NO];
        }
        @weakify(self);
        [[RACObserve(progress, fractionCompleted)
          takeUntil:[RACSignal combineLatest:@[self.rac_prepareForReuseSignal, self.rac_willDeallocSignal]]]
         subscribeNext:^(NSNumber *fractionCompleted) {
             @strongify(self);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self updateCompleted:fractionCompleted.floatValue];
             });
         }];
    }else{
        _progressView.hidden = YES;
    }
}

- (void)updateCompleted:(CGFloat)fractionCompleted{
    //更新进度
    self.progressView.progress = fractionCompleted;
    if (ABS(fractionCompleted - 1.0) < 0.0001) {
        //已完成
        [self.progressView hidePopUpViewAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeToState:DownloadStateDownloaded];
            self.progressView.hidden = YES;
        });
    }else{
        self.progressView.hidden = NO;
    }
}

- (void)changeToState:(DownloadState)state{
    NSString *stateImageName;
    switch (state) {
        case DownloadStateDefault:
            stateImageName = @"icon_file_state_download";
            break;
        case DownloadStateDownloading:
            stateImageName = @"icon_file_state_pause";
            break;
        case DownloadStatePausing:
            stateImageName = @"icon_file_state_goon";
            break;
        case DownloadStateDownloaded:
            stateImageName = @"icon_file_state_look";
            break;
        default:
            stateImageName = @"icon_file_state_download";
            break;
    }
    [self setBackgroundColor:(state == DownloadStateDownloaded)? [UIColor colorWithHexString:@"0xf1fcf6"]:[UIColor clearColor]];
    [self.progressView setHidden:!(state == DownloadStateDownloading || state == DownloadStatePausing)];
    
    [_stateButton setImage:[UIImage imageNamed:stateImageName] forState:UIControlStateNormal];
}

- (void)clickedByUser{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    NSURL *fileUrl = [Coding_FileManager diskDownloadUrlForKey:_curVersion.storage_key];
    if (fileUrl) {//已经下载到本地了
        if (_showDiskFileBlock) {
            _showDiskFileBlock(fileUrl, _curVersion);
        }
    }else{//要下载
        NSURLSessionDownloadTask *downloadTask;
        if (_curVersion.cDownloadTask) {//暂停或者重新开始
            downloadTask = _curVersion.cDownloadTask.task;
            switch (downloadTask.state) {
                case NSURLSessionTaskStateRunning:
                    [downloadTask suspend];
                    [self changeToState:DownloadStatePausing];
                    
                    break;
                case NSURLSessionTaskStateSuspended:
                    [downloadTask resume];
                    [self changeToState:DownloadStateDownloading];
                    break;
                default:
                    break;
            }
        }else{//新建下载
            __weak typeof(self) weakSelf = self;
            Coding_DownloadTask *cDownloadTask = [manager addDownloadTaskForObj:_curVersion completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (error) {
                    [weakSelf changeToState:DownloadStateDefault];
                    [NSObject showError:error];
                    DebugLog(@"ERROR:%@", error.description);
                }else{
                    [weakSelf changeToState:DownloadStateDownloaded];
                    DebugLog(@"File downloaded to: %@", filePath);
                }
            }];
            [self updateProgress:cDownloadTask.progress];
            [self changeToState:DownloadStateDownloading];
        }
    }
}


+ (CGFloat)cellHeight{
    return 75.0;
}
#pragma mark ASProgressPopUpViewDelegate
- (void)progressViewWillDisplayPopUpView:(ASProgressPopUpView *)progressView;
{
    [self.superview bringSubviewToFront:self];
}

- (void)progressViewDidHidePopUpView:(ASProgressPopUpView *)progressView{
    progressView.hidden = YES;
}
@end
