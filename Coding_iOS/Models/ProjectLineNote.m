//
//  ProjectLineNote.m
//  Coding_iOS
//
//  Created by Ease on 15/5/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectLineNote.h"

@implementation ProjectLineNote
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeNone];
        _content = _htmlMedia.contentDisplay;
    }
}

@end


@implementation ProjectLineNoteComment

- (void)setLabel:(NSString *)label{
    if ([label isKindOfClass:[NSString class]] && label.length > 0) {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[label dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        _label = [NSObject objectOfClass:@"ProjectTag" fromJSON:jsonDict];
        
    }else{
        _label = nil;
    }
}

@end
