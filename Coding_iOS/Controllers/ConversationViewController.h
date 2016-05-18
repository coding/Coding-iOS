//
//  ConversationViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "PrivateMessages.h"
#import "QBImagePickerController.h"
#import "UIMessageInputView.h"

@interface ConversationViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBImagePickerControllerDelegate, UIMessageInputViewDelegate>
@property (strong, nonatomic) PrivateMessages *myPriMsgs;
- (void)doPoll;
@end
