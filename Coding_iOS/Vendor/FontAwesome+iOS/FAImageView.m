//
//  FAImageView.m
//
//  Copyright (c) 2012 Alex Usbergo. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//
//  An UIImageView with the support of displaying
//  a vectorial icon (by using the fontawesome iconic font)
//  if the image is missing


#import "FAImageView.h"
#import "UIFont+FontAwesome.h"

@implementation FAImageView

/* When the image is set to nil the defaultView will be added as subview,
 * otherwise it will be removed */
- (void)setImage:(UIImage*)image
{
    [super setImage:image];
    self.defaultView.hidden = (nil != image);
}

#pragma mark - Toggle the icon view

/* Lazy initialization of the view */
- (UILabel*)defaultView
{
    if (nil != _defaultView)
        return _defaultView;
    
    //The size of the default view is the same of self
    _defaultView = [[UILabel alloc] initWithFrame:self.bounds];
    _defaultView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //The default icon is the ban icon
    [self setDefaultIcon:FAIconBanCircle];
    
    _defaultView.font = [UIFont iconicFontOfSize:self.bounds.size.height];
    _defaultView.textAlignment = NSTextAlignmentCenter;
    _defaultView.adjustsFontSizeToFitWidth = YES;
    
    //UIAppearance selectors
    _defaultView.textColor = [UIColor whiteColor];
    _defaultView.backgroundColor = [UIColor colorWithRed:.9f green:.9f blue:.9f alpha:1.f];

    //It starts hidden
    _defaultView.hidden = YES;

    [self addSubview:_defaultView];

    return _defaultView;
}

#pragma mark - Properties

- (void)setDefaultIconIdentifier:(NSString*)defaultIconIdentifier
{
    self.defaultIcon = [NSString fontAwesomeEnumForIconIdentifier:defaultIconIdentifier];
}

- (void)setDefaultIcon:(FAIcon)defaultIcon
{
    _defaultIcon = defaultIcon;
    _defaultView.text = [NSString fontAwesomeIconStringForEnum:defaultIcon];
}

@end
