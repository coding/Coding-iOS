//
//  FileDownloadView.m
//  Coding_iOS
//
//  Created by Ease on 14/12/16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "FileDownloadView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ASProgressPopUpView.h"
#import "Coding_FileManager.h"

@interface FileDownloadView ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel, *infoLabel, *sizeLabel;
@property (strong, nonatomic) ASProgressPopUpView *progressView;
@property (strong, nonatomic) UIButton *stateButton;
@property (strong, nonatomic) NSProgress *progress;
@end

@implementation FileDownloadView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //        CGFloat frameHeight = CGRectGetHeight(frame);
        CGFloat frameWidth = CGRectGetWidth(frame);
        
        CGFloat curBottomY = 80;
        
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake((frameWidth - 90)/2, curBottomY, 90, 90)];
            _iconView.layer.masksToBounds = YES;
            _iconView.layer.cornerRadius = 2.0;
            _iconView.layer.borderWidth = 0.5;
            _iconView.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
            [self addSubview:_iconView];
        }
        curBottomY += CGRectGetHeight(_iconView.frame) +20;
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((frameWidth - 260)/2, curBottomY, 260, 25)];
            _nameLabel.textAlignment = NSTextAlignmentCenter;
            _nameLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _nameLabel.font = [UIFont systemFontOfSize:16];
            [self addSubview:_nameLabel];
        }
        curBottomY += 25 +10;
        if (!_sizeLabel) {
            _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake((frameWidth - 260)/2, curBottomY, 260, 20)];
            _sizeLabel.textAlignment = NSTextAlignmentCenter;
            _sizeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _sizeLabel.font = [UIFont systemFontOfSize:12];
            [self addSubview:_sizeLabel];
        }
        curBottomY += 20 +20;
        
        if (!_progressView) {
            _progressView = [[ASProgressPopUpView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, curBottomY, kScreen_Width- 2*kPaddingLeftWidth, 2.0)];
            
            _progressView.popUpViewCornerRadius = 12.0;
            _progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
            [_progressView setTrackTintColor:[UIColor colorWithHexString:@"0xe6e6e6"]];
            _progressView.popUpViewAnimatedColors = @[[UIColor colorWithHexString:@"0x3bbd79"]];
            _progressView.hidden = YES;
            [_progressView hidePopUpViewAnimated:NO];
            [self addSubview:self.progressView];
        }
        curBottomY += 20;
        if (!_stateButton) {
            _stateButton = [[UIButton alloc] initWithFrame:CGRectMake((frameWidth - 260)/2, curBottomY, 260, 45)];
            _stateButton = [UIButton buttonWithStyle:StrapPrimaryStyle andTitle:@"下载文件" andFrame:CGRectMake((frameWidth - 260)/2, curBottomY, 260, 45) target:self action:@selector(clickedByUser)];
            [self addSubview:_stateButton];
        }
    }
    return self;
}

- (void)setFile:(ProjectFile *)file{
    _file = file;
    if (!_file) {
        return;
    }
    
    if (_file.preview && _file.preview.length > 0) {
        [_iconView sd_setImageWithURL:[NSURL URLWithString:_file.preview]];
    }else{
        _iconView.image = [UIImage imageNamed:[_file fileIconName]];
    }
    _nameLabel.text = _file.name;
    _sizeLabel.text = [NSString sizeDisplayWithByte:_file.size.floatValue];
    
    [self changeToState:_file.downloadState];
    
    [_progressView showPopUpViewAnimated:NO];
    
    Coding_DownloadTask *cDownloadTask = [_file cDownloadTask];
    if (cDownloadTask) {
        self.progress = cDownloadTask.progress;
    }
}

- (void)setProgress:(NSProgress *)progress{
    _progress = progress;
    __weak typeof(self) weakSelf = self;
    if (_progress) {
        [RACObserve(self, progress.fractionCompleted) subscribeNext:^(NSNumber *fractionCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updatePregress:fractionCompleted.doubleValue];
            });
        }];
    }else{
        _progressView.hidden = YES;
    }
}

- (void)updatePregress:(double)fractionCompleted{
    //更新进度
    self.progressView.progress = fractionCompleted;
    if (ABS(fractionCompleted - 1.0) < 0.0001) {
        //已完成
        [self.progressView hidePopUpViewAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressView.hidden = YES;
            [self changeToState:DownloadStateDownloaded];
        });
    }else{
        self.progressView.hidden = NO;
    }
}

- (void)clickedByUser{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    NSURL *fileUrl = [manager diskDownloadUrlForFile:_file.diskFileName];
    if (fileUrl) {//已经下载到本地了
        if (_goToFileBlock) {
            _goToFileBlock(self.file);
        }
    }else{//要下载
        NSURLSessionDownloadTask *downloadTask;
        if (_file.cDownloadTask) {//暂停或者重新开始
            downloadTask = _file.cDownloadTask.task;
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
            Coding_DownloadTask *cDownloadTask = [manager addDownloadTaskForFile:self.file completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (error) {
                    [weakSelf changeToState:DownloadStateDefault];
                    [weakSelf showError:error];
                    NSLog(@"ERROR:%@", error.description);
                }else{
                    [weakSelf changeToState:DownloadStateDownloaded];
                    NSLog(@"File downloaded to: %@", filePath);
                }
            }];
            
            self.progress = cDownloadTask.progress;
            _progressView.progress = 0.0;
            _progressView.hidden = NO;
            [self changeToState:DownloadStateDownloading];
        }
    }
}

- (void)changeToState:(DownloadState)state{
    NSString *stateTitle;
    switch (state) {
        case DownloadStateDefault:
            stateTitle = @"下载文件";
            break;
        case DownloadStateDownloading:
            stateTitle = @"暂停下载";
            break;
        case DownloadStatePausing:
            stateTitle = @"恢复下载";
            break;
        case DownloadStateDownloaded:
            stateTitle = @"用其他应用打开";
            break;
        default:
            break;
    }
    if (state == DownloadStateDownloaded && self.completionBlock && !self.hidden) {
        self.completionBlock();
    }
    [self.progressView setHidden:!(state == DownloadStateDownloading || state == DownloadStatePausing)];
    [_stateButton setTitle:stateTitle forState:UIControlStateNormal];
    if (state == DownloadStateDownloaded) {
        [_stateButton defaultStyle];
    }else{
        [_stateButton primaryStyle];
    }
}

@end
