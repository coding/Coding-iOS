//
//  MLEmojiLabel.m
//  MLEmojiLabel
//
//  Created by molon on 5/19/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLEmojiLabel.h"

#pragma mark - 正则列表

#define REGULAREXPRESSION_OPTION(regularExpression,regex,option) \
\
static inline NSRegularExpression * k##regularExpression() { \
static NSRegularExpression *_##regularExpression = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_##regularExpression = [[NSRegularExpression alloc] initWithPattern:(regex) options:(option) error:nil];\
});\
\
return _##regularExpression;\
}\


#define REGULAREXPRESSION(regularExpression,regex) REGULAREXPRESSION_OPTION(regularExpression,regex,NSRegularExpressionCaseInsensitive)


REGULAREXPRESSION(URLRegularExpression,@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)")

REGULAREXPRESSION(PhoneNumerRegularExpression, @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}")

REGULAREXPRESSION(EmailRegularExpression, @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}")

REGULAREXPRESSION(AtRegularExpression, @"@[\\u4e00-\\u9fa5\\w\\-]+")


//@"#([^\\#|.]+)#"
REGULAREXPRESSION_OPTION(PoundSignRegularExpression, @"#([\\u4e00-\\u9fa5\\w\\-]+)#", NSRegularExpressionCaseInsensitive)

//微信的表情符其实不是这种格式，这个格式的只是让人看起来更友好。。
//REGULAREXPRESSION(EmojiRegularExpression, @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]")

//@"/:[\\w:~!@$&*()|+<>',?-]{1,8}" , // @"/:[\\x21-\\x2E\\x30-\\x7E]{1,8}" ，经过检测发现\w会匹配中文，好奇葩。
REGULAREXPRESSION(SlashEmojiRegularExpression, @"/:[\\x21-\\x2E\\x30-\\x7E]{1,8}")

const CGFloat kLineSpacing = 4.0;
const CGFloat kAscentDescentScale = 0.25; //在这里的话无意义，高度的结局都是和宽度一样

const CGFloat kEmojiWidthRatioWithLineHeight = 1.25;//和字体高度的比例

const CGFloat kEmojiOriginYOffsetRatioWithLineHeight = 0.10; //表情绘制的y坐标矫正值，和字体高度的比例，越大越往下
NSString *const kCustomGlyphAttributeImageName = @"CustomGlyphAttributeImageName";

#define kEmojiReplaceCharacter @"\uFFFC"

#define kURLActionCount 5
NSString * const kURLActions[] = {@"url->",@"email->",@"phoneNumber->",@"at->",@"poundSign->"};

@interface MLEmojiLabel()<TTTAttributedLabelDelegate>

@property (nonatomic, strong) NSRegularExpression *customEmojiRegularExpression;
@property (nonatomic, strong) NSDictionary *customEmojiDictionary;

@end

@implementation MLEmojiLabel

#pragma mark - 表情包字典
+ (NSDictionary *)emojiDictionary {
    static NSDictionary *emojiDictionary = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"expressionImage.plist"];
	    emojiDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
	});
	return emojiDictionary;
}

#pragma mark - 表情 callback
typedef struct CustomGlyphMetrics {
    CGFloat ascent;
    CGFloat descent;
    CGFloat width;
} CustomGlyphMetrics, *CustomGlyphMetricsRef;

static void deallocCallback(void *refCon) {
	free(refCon), refCon = NULL;
}

static CGFloat ascentCallback(void *refCon) {
	CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;
	return metrics->ascent;
}

static CGFloat descentCallback(void *refCon) {
	CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;
	return metrics->descent;
}

static CGFloat widthCallback(void *refCon) {
	CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;
	return metrics->width;
}

#pragma mark - 初始化和TTT的一些修正
/**
 *  TTT很鸡巴。commonInit是被调用了两回。如果直接init的话，因为init其中会调用initWithFrame
 *  PS.已经在里面把init里的修改掉了
 */
- (void)commonInit {
    
    //这个是用来生成plist时候用到
//    [self initPlist];
    
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;
    
    self.delegate = self;
    self.numberOfLines = 0;
    self.font = [UIFont systemFontOfSize:14.0];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
    
    /**
     *  PS:这里需要注意，TTT里默认把numberOfLines不为1的情况下实际绘制的lineBreakMode是以word方式。
     *  而默认UILabel似乎也是这样处理的。我不知道为何。已经做修改。
     */
    self.lineBreakMode = NSLineBreakByCharWrapping;
    
    self.textInsets = UIEdgeInsetsZero;
    self.lineHeightMultiple = 1.0f;
//    self.leading = kLineSpacing; //默认行间距
    
    [self setValue:[NSArray array] forKey:@"links"];
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableInactiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableInactiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    UIColor *commonLinkColor = [UIColor colorWithRed:0.112 green:0.000 blue:0.791 alpha:1.000];
    
    //点击时候的背景色
    [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor colorWithWhite:0.631 alpha:1.000] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
    
    if ([NSMutableParagraphStyle class]) {
        [mutableLinkAttributes setObject:commonLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:commonLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableInactiveLinkAttributes setObject:[UIColor grayColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        
        
        //把原有TTT的NSMutableParagraphStyle设置给去掉了。会影响到整个段落的设置
    } else {
        [mutableLinkAttributes setObject:(__bridge id)[commonLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:(__bridge id)[commonLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableInactiveLinkAttributes setObject:(__bridge id)[[UIColor grayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        
        
        //把原有TTT的NSMutableParagraphStyle设置给去掉了。会影响到整个段落的设置
    }
    
    self.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    self.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    self.inactiveLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableInactiveLinkAttributes];
}

/**
 *  如果是有attributedText的情况下，有可能会返回少那么点的，这里矫正下
 *
 */
- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.attributedText) {
        return [super sizeThatFits:size];
    }
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}


//这里是抄TTT里的，因为他不是放在外面的
static inline CGFloat TTTFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case NSTextAlignmentCenter:
            return 0.5f;
        case NSTextAlignmentRight:
            return 1.0f;
        case NSTextAlignmentLeft:
        default:
            return 0.0f;
    }
}

#pragma mark - 绘制表情
- (void)drawOtherForEndWithFrame:(CTFrameRef)frame
                          inRect:(CGRect)rect
                         context:(CGContextRef)c
{
    //PS:这个是在TTT里drawFramesetter....方法最后做了修改的基础上。
    
    CGFloat emojiOriginYOffset = self.font.lineHeight*kEmojiOriginYOffsetRatioWithLineHeight;
    
    //找到行
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    //找到每行的origin，保存起来
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    //修正绘制offset，根据当前设置的textAlignment
    CGFloat flushFactor = TTTFlushFactorForTextAlignment(self.textAlignment);
    
    CFIndex lineIndex = 0;
    for (id line in lines) {
        //获取当前行的宽度和高度，并且设置对应的origin进去，就获得了这行的bounds
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds((__bridge CTLineRef)line, &ascent, &descent, &leading) ;
        CGRect lineBounds = CGRectMake(0.0f, 0.0f, width, ascent + descent + leading) ;
        lineBounds.origin.x = origins[lineIndex].x;
        lineBounds.origin.y = origins[lineIndex].y;
        
        //这里其实是能获取到当前行的真实origin.x，根据textAlignment，而lineBounds.origin.x其实是默认一直为0的(不会受textAlignment影响)
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush((__bridge CTLineRef)line, flushFactor, rect.size.width);
        
        //找到当前行的每一个要素，姑且这么叫吧。可以理解为有单独的attr属性的各个range。
        for (id glyphRun in (__bridge NSArray *)CTLineGetGlyphRuns((__bridge CTLineRef)line)) {
            //找到此要素所对应的属性
            NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes((__bridge CTRunRef) glyphRun);
            //判断是否有图像，如果有就绘制上去
            NSString *imageName = attributes[kCustomGlyphAttributeImageName];
            if (imageName) {
                CGRect runBounds = CGRectZero;
                CGFloat runAscent = 0.0f;
                CGFloat runDescent = 0.0f;
                
                runBounds.size.width = (CGFloat)CTRunGetTypographicBounds((__bridge CTRunRef)glyphRun, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
                runBounds.size.height = runAscent + runDescent;
                
                CGFloat xOffset = 0.0f;
                CFRange glyphRange = CTRunGetStringRange((__bridge CTRunRef)glyphRun);
                switch (CTRunGetStatus((__bridge CTRunRef)glyphRun)) {
                    case kCTRunStatusRightToLeft:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location + glyphRange.length, NULL);
                        break;
                    default:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location, NULL);
                        break;
                }
                runBounds.origin.x = penOffset + xOffset;
                runBounds.origin.y = origins[lineIndex].y;
                runBounds.origin.y -= runDescent;
                
                UIImage *image = [UIImage imageNamed:imageName];
                runBounds.origin.y -= emojiOriginYOffset; //稍微矫正下。
                CGContextDrawImage(c, runBounds, image.CGImage);
            }
        }
        
        lineIndex++;
    }
    
}


#pragma mark - main
/**
 *  返回经过表情识别处理的Attributed字符串
 */
- (NSMutableAttributedString*)mutableAttributeStringWithEmojiText:(NSString*)emojiText
{
    //获取所有表情的位置
//    NSArray *emojis = [kEmojiRegularExpression() matchesInString:emojiText
//                                                         options:NSMatchingWithTransparentBounds
//                                                           range:NSMakeRange(0, [emojiText length])];

    NSArray *emojis = nil;
    
    if (self.customEmojiRegularExpression) {
        //自定义表情正则
        emojis = [self.customEmojiRegularExpression matchesInString:emojiText
                        options:NSMatchingWithTransparentBounds
                        range:NSMakeRange(0, [emojiText length])];
    }else{
        emojis = [kSlashEmojiRegularExpression() matchesInString:emojiText
                                                options:NSMatchingWithTransparentBounds
                                                  range:NSMakeRange(0, [emojiText length])];
    }
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    NSUInteger location = 0;
    
    
    CGFloat emojiWith = self.font.lineHeight*kEmojiWidthRatioWithLineHeight;
    for (NSTextCheckingResult *result in emojis) {
        NSRange range = result.range;
		NSString *subStr = [emojiText substringWithRange:NSMakeRange(location, range.location - location)];
		NSMutableAttributedString *attSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
		[attrStr appendAttributedString:attSubStr];
        
		location = range.location + range.length;
        
		NSString *emojiKey = [emojiText substringWithRange:range];
        
        
        NSDictionary *emojiDict = self.customEmojiRegularExpression?self.customEmojiDictionary:[MLEmojiLabel emojiDictionary];
        
        //如果当前获得key后面有多余的，这个需要记录下
        NSMutableAttributedString *otherAppendStr = nil;
        
		NSString *imageName = emojiDict[emojiKey];
        if (!self.customEmojiRegularExpression) {
            //微信的表情没有结束符号,所以有可能会发现过长的只有头部才是表情的段，需要循环检测一次。微信最大表情特殊字符是8个长度，检测8次即可
            if (!imageName&&emojiKey.length>2) {
                NSUInteger maxDetctIndex = emojiKey.length>8+2?8:emojiKey.length-2;
                //从头开始检测是否有对应的
                for (NSUInteger i=0; i<maxDetctIndex; i++) {
                    //                NSLog(@"%@",[emojiKey substringToIndex:3+i]);
                    imageName = emojiDict[[emojiKey substringToIndex:3+i]];
                    if (imageName) {
                        otherAppendStr  = [[NSMutableAttributedString alloc]initWithString:[emojiKey substringFromIndex:3+i]];
                        break;
                    }
                }
            }
        }
        
		if (imageName) {
			// 这里不用空格，空格有个问题就是连续空格的时候只显示在一行
			NSMutableAttributedString *replaceStr = [[NSMutableAttributedString alloc] initWithString:kEmojiReplaceCharacter];
			NSRange __range = NSMakeRange([attrStr length], 1);
			[attrStr appendAttributedString:replaceStr];
            if (otherAppendStr) { //有其他需要添加的
                [attrStr appendAttributedString:otherAppendStr];
            }
            
			// 定义回调函数
			CTRunDelegateCallbacks callbacks;
			callbacks.version = kCTRunDelegateCurrentVersion;
			callbacks.getAscent = ascentCallback;
			callbacks.getDescent = descentCallback;
			callbacks.getWidth = widthCallback;
			callbacks.dealloc = deallocCallback;
            
			// 这里设置下需要绘制的图片的大小，这里我自定义了一个结构体以便于存储数据
			CustomGlyphMetricsRef metrics = malloc(sizeof(CustomGlyphMetrics));
            metrics->width = emojiWith;
			metrics->ascent = 1/(1+kAscentDescentScale)*metrics->width;
			metrics->descent = metrics->ascent*kAscentDescentScale;
			CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, metrics);
			[attrStr addAttribute:(NSString *)kCTRunDelegateAttributeName
                            value:(__bridge id)delegate
                            range:__range];
			CFRelease(delegate);
            
			// 设置自定义属性，绘制的时候需要用到
			[attrStr addAttribute:kCustomGlyphAttributeImageName
                            value:imageName
                            range:__range];
		} else {
			NSMutableAttributedString *originalStr = [[NSMutableAttributedString alloc] initWithString:emojiKey];
			[attrStr appendAttributedString:originalStr];
		}
    }
    if (location < [emojiText length]) {
        NSRange range = NSMakeRange(location, [emojiText length] - location);
        NSString *subStr = [emojiText substringWithRange:range];
        NSMutableAttributedString *attrSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
        [attrStr appendAttributedString:attrSubStr];
    }
    return attrStr;
}


- (void)setEmojiText:(NSString*)emojiText
{
    _emojiText = emojiText;
    if (!emojiText||emojiText.length<=0) {
        [super setText:nil];
        return;
    }
    
    NSMutableAttributedString *mutableAttributedString = nil;
    
    if (self.disableEmoji) {
        mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:emojiText];
    }else{
        mutableAttributedString = [self mutableAttributeStringWithEmojiText:emojiText];
    }
    
    [self setText:mutableAttributedString afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
    
    NSRange stringRange = NSMakeRange(0, mutableAttributedString.length);
    
    NSRegularExpression * const regexps[] = {kURLRegularExpression(),kEmailRegularExpression(),kPhoneNumerRegularExpression(),kAtRegularExpression(),kPoundSignRegularExpression()};
    
    NSMutableArray *results = [NSMutableArray array];
    
    NSUInteger maxIndex = self.isNeedAtAndPoundSign?kURLActionCount:kURLActionCount-2;
    for (NSUInteger i=0; i<maxIndex; i++) {
        if (self.disableThreeCommon&&i<kURLActionCount-2) {
            continue;
        }
        NSString *urlAction = kURLActions[i];
        [regexps[i] enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
            
            //检查是否和之前记录的有交集，有的话则忽略
            for (NSTextCheckingResult *record in results){
                if (NSMaxRange(NSIntersectionRange(record.range, result.range))>0){
                    return;
                }
            }
            
            //添加链接
            NSString *actionString = [NSString stringWithFormat:@"%@%@",urlAction,[self.text substringWithRange:result.range]];
            
            //这里暂时用NSTextCheckingTypeCorrection类型的传递消息吧
            //因为有自定义的类型出现，所以这样方便点。
            NSTextCheckingResult *aResult = [NSTextCheckingResult correctionCheckingResultWithRange:result.range replacementString:actionString];
            
            [results addObject:aResult];
        }];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    //这里直接调用父类私有方法，好处能内部只会setNeedDisplay一次。一次更新所有添加的链接
    [super performSelector:@selector(addLinksWithTextCheckingResults:attributes:) withObject:results withObject:self.linkAttributes];
#pragma clang diagnostic pop
    
}

#pragma mark - size fit result
- (CGSize)preferredSizeWithMaxWidth:(CGFloat)maxWidth
{
    CGSize size = [MLEmojiLabel sizeThatFitsAttributedString:self.attributedText withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX) limitedToNumberOfLines:self.numberOfLines];
    return size;
}

#pragma mark - setter
- (void)setIsNeedAtAndPoundSign:(BOOL)isNeedAtAndPoundSign
{
    _isNeedAtAndPoundSign = isNeedAtAndPoundSign;
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [super setLineBreakMode:lineBreakMode];
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setDisableEmoji:(BOOL)disableEmoji
{
    _disableEmoji = disableEmoji;
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setDisableThreeCommon:(BOOL)disableThreeCommon
{
    _disableThreeCommon = disableThreeCommon;
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setCustomEmojiRegex:(NSString *)customEmojiRegex
{
    _customEmojiRegex = customEmojiRegex;
    
    if (customEmojiRegex&&customEmojiRegex.length>0) {
        self.customEmojiRegularExpression = [[NSRegularExpression alloc] initWithPattern:customEmojiRegex options:NSRegularExpressionCaseInsensitive error:nil];
    }else{
        self.customEmojiRegularExpression = nil;
    }
    
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setCustomEmojiPlistName:(NSString *)customEmojiPlistName
{
    _customEmojiPlistName = customEmojiPlistName;
    
    if (customEmojiPlistName&&customEmojiPlistName.length>0) {
        if (![customEmojiPlistName hasSuffix:@".plist"]) {
            customEmojiPlistName = [customEmojiPlistName stringByAppendingString:@".plist"];
        }
        NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:customEmojiPlistName];
	    self.customEmojiDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
    }else{
        self.customEmojiDictionary = nil;
    }
    
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

#pragma mark - delegate
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result;
{
    if (result.resultType == NSTextCheckingTypeCorrection) {
        //判断消息类型
        for (NSUInteger i=0; i<kURLActionCount; i++) {
            if ([result.replacementString hasPrefix:kURLActions[i]]) {
                NSString *content = [result.replacementString substringFromIndex:kURLActions[i].length];
                if(self.emojiDelegate&&[self.emojiDelegate respondsToSelector:@selector(mlEmojiLabel:didSelectLink:withType:)]){
                    //type的数组和i刚好对应
                    [self.emojiDelegate mlEmojiLabel:self didSelectLink:content withType:i];
                }
            }
        }
    }
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.emojiText];
}

#pragma mark - other
//为了生成plist方便的一个方法罢了
- (void)initPlist
{
    NSString *testString = @"/::)/::~/::B/::|/:8-)/::</::$/::X/::Z/::'(/::-|/::@/::P/::D/::O/::(/::+/:--b/::Q/::T/:,@P/:,@-D/::d/:,@o/::g/:|-)/::!/::L/::>/::,@/:,@f/::-S/:?/:,@x/:,@@/::8/:,@!/:!!!/:xx/:bye/:wipe/:dig/:handclap/:&-(/:B-)/:<@/:@>/::-O/:>-|/:P-(/::'|/:X-)/::*/:@x/:8*/:pd/:<W>/:beer/:basketb/:oo/:coffee/:eat/:pig/:rose/:fade/:showlove/:heart/:break/:cake/:li/:bome/:kn/:footb/:ladybug/:shit/:moon/:sun/:gift/:hug/:strong/:weak/:share/:v/:@)/:jj/:@@/:bad/:lvu/:no/:ok/:love/:<L>/:jump/:shake/:<O>/:circle/:kotow/:turn/:skip/:oY";
    NSMutableArray *testArray = [NSMutableArray array];
    NSMutableDictionary *testDict = [NSMutableDictionary dictionary];
    [kSlashEmojiRegularExpression() enumerateMatchesInString:testString options:0 range:NSMakeRange(0, testString.length) usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
        [testArray addObject:[testString substringWithRange:result.range]];
        [testDict setObject:[NSString stringWithFormat:@"Expression_%lu",(unsigned long)testArray.count] forKey:[testString substringWithRange:result.range]];
    }];
    
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *doc = [NSString stringWithFormat:@"%@/expression.plist",documentDir];
    NSLog(@"%@,length:%lu",doc,(unsigned long)testArray.count);
    if ([testArray writeToFile:doc atomically:YES]) {
        NSLog(@"归档expression.plist成功");
    }
    doc = [NSString stringWithFormat:@"%@/expressionImage.plist",documentDir];
    if ([testDict writeToFile:doc atomically:YES]) {
        NSLog(@"归档到expressionImage.plist成功");
    }
    
    //    NSString *testString = @"[微笑][撇嘴][色][发呆][得意][流泪][害羞][闭嘴][睡][大哭][尴尬][发怒][调皮][呲牙][惊讶][难过][酷][冷汗][抓狂][吐][偷笑][愉快][白眼][傲慢][饥饿][困][惊恐][流汗][憨笑][悠闲][奋斗][咒骂][疑问][嘘][晕][疯了][衰][骷髅][敲打][再见][擦汗][抠鼻][鼓掌][糗大了][坏笑][左哼哼][右哼哼][哈欠][鄙视][委屈][快哭了][阴险][亲亲][吓][可怜][菜刀][西瓜][啤酒][篮球][乒乓][咖啡][饭][猪头][玫瑰][凋谢][嘴唇][爱心][心碎][蛋糕][闪电][炸弹][刀][足球][瓢虫][便便][月亮][太阳][礼物][拥抱][强][弱][握手][胜利][抱拳][勾引][拳头][差劲][爱你][NO][OK][爱情][飞吻][跳跳][发抖][怄火][转圈][磕头][回头][跳绳][投降]";
    //    NSMutableArray *testArray = [NSMutableArray array];
    //    NSMutableDictionary *testDict = [NSMutableDictionary dictionary];
    //    [kEmojiRegularExpression() enumerateMatchesInString:testString options:0 range:NSMakeRange(0, testString.length) usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
    //        [testArray addObject:[testString substringWithRange:result.range]];
    //        [testDict setObject:[NSString stringWithFormat:@"Expression_%ld",testArray.count] forKey:[testString substringWithRange:result.range]];
    //    }];
    //    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //    NSString *doc = [NSString stringWithFormat:@"%@/expression.plist",documentDir];
    //    NSLog(@"%@,length:%ld",doc,testArray.count);
    //    if ([testArray writeToFile:doc atomically:YES]) {
    //        NSLog(@"归档expression.plist成功");
    //    }
    //    doc = [NSString stringWithFormat:@"%@/expressionImage.plist",documentDir];
    //    if ([testDict writeToFile:doc atomically:YES]) {
    //        NSLog(@"归档到expressionImage.plist成功");
    //    }
    
    
}

@end
