//
//  FRDLivelyButton.h
//  FRDLivelyButton
//
//  Created by Sebastien Windal on 2/24/14.
//  MIT license. See the LICENSE file distributed with this work.
//

#import <UIKit/UIKit.h>


typedef enum {
    kFRDLivelyButtonStyleHamburger,
    kFRDLivelyButtonStyleClose,
    kFRDLivelyButtonStylePlus,
    kFRDLivelyButtonStyleCirclePlus,
    kFRDLivelyButtonStyleCircleClose,
    kFRDLivelyButtonStyleCaretUp,
    kFRDLivelyButtonStyleCaretDown,
    kFRDLivelyButtonStyleCaretLeft,
    kFRDLivelyButtonStyleCaretRight,
    kFRDLivelyButtonStyleArrowLeft,
    kFRDLivelyButtonStyleArrowRight
} kFRDLivelyButtonStyle;

@interface FRDLivelyButton : UIButton

-(kFRDLivelyButtonStyle) buttonStyle;

-(void) setStyle:(kFRDLivelyButtonStyle)style animated:(BOOL)animated;

@property (nonatomic, strong) NSDictionary *options;
+(NSDictionary *) defaultOptions;

// button customization options:

// scale to apply to the button CGPath(s) when the button is pressed. Default is 0.9:
extern NSString *const kFRDLivelyButtonHighlightScale;
// the button CGPaths stroke width, default 1.0f pixel
extern NSString *const kFRDLivelyButtonLineWidth;
// the button CGPaths stroke color, default is black
extern NSString *const kFRDLivelyButtonColor;
// the button CGPaths stroke color when highlighted, default is light gray
extern NSString *const kFRDLivelyButtonHighlightedColor;
// duration in second of the highlight (pressed down) animation, default 0.1
extern NSString *const kFRDLivelyButtonHighlightAnimationDuration;
// duration in second of the unhighlight (button release) animation, defualt 0.15
extern NSString *const kFRDLivelyButtonUnHighlightAnimationDuration;
// duration in second of the style change animation, default 0.3
extern NSString *const kFRDLivelyButtonStyleChangeAnimationDuration;


@end
