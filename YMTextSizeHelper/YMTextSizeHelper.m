//
//  YMTextSizeHelper.m
//  YMTextSizeHelper
//
//  Created by yuman01 on 2018/7/26.
//  Copyright © 2018年 yuman. All rights reserved.
//

#import "YMTextSizeHelper.h"

static const CGFloat EPS = 0.001;
static const CGFloat HALF_FLOAT = CGFLOAT_MAX / 2.0;

static NSString * const kOneLine = @"一行text";

@implementation YMTextSizeConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxWidth = CGFLOAT_MAX;
        _maxHeight = CGFLOAT_MAX;
        _numberOfLines = 1;
        _lineBreakMode = NSLineBreakByWordWrapping;
        _options = YMTextSizeResultOptionsSize;
    }
    return self;
}

+ (BOOL)checkConfigVaild:(YMTextSizeConfig *)config
{
    if (!config || ![config isKindOfClass:[YMTextSizeConfig class]]) {
        return NO;
    }
    if (!config.text || ![config.text isKindOfClass:[NSString class]] || config.text.length == 0) {
        return NO;
    }
    if (!config.font || ![config.font isKindOfClass:[UIFont class]]) {
        return NO;
    }
    if (config.maxWidth <= 0 || config.maxHeight <= 0 || config.lineSpacing < 0) {
        return NO;
    }
    if (config.options == 0) {
        return NO;
    }
    return YES;
}

@end

@implementation YMTextSizeResult

+ (YMTextSizeResult *)zeroResult
{
    YMTextSizeResult *result = [[YMTextSizeResult alloc] init];
    result.size = CGSizeZero;
    result.attributedText = nil;
    result.hasMore = NO;
    return result;
}

@end

@implementation YMTextSizeHelper

+ (YMTextSizeResult *)getSizeResultWithMakeConfigBlock:(makeTextSizeConfig)makeConfigBlock
{
    YMTextSizeConfig *config = nil;
    if (makeConfigBlock) {
        config = makeConfigBlock();
    }
    return [YMTextSizeHelper getSizeResultWithConfig:config];
}

+ (YMTextSizeResult *)getSizeResultWithConfig:(YMTextSizeConfig *)config
{
    YMTextSizeResult *result = [YMTextSizeResult zeroResult];
    if (![YMTextSizeConfig checkConfigVaild:config]) {
        return result;
    }
    
    NSMutableDictionary *attributes = ([config.otherAttributes isKindOfClass:[NSDictionary class]]) ? ([config.otherAttributes mutableCopy]) : ([[NSMutableDictionary alloc] init]);
    NSMutableParagraphStyle *paragraphStyle = ([attributes[NSParagraphStyleAttributeName] isKindOfClass:[NSParagraphStyle class]]) ? ([attributes[NSParagraphStyleAttributeName] mutableCopy]) : ([[NSMutableParagraphStyle alloc] init]);
    NSStringDrawingOptions drawOptions = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    
    BOOL isNoNeedLineHeight = (config.numberOfLines == 0) || (config.isMakeSureShowCompleted) || (config.maxWidth > HALF_FLOAT);
    BOOL isNoNeedLineSpacing = (fabs(config.lineSpacing) < EPS) || (config.numberOfLines == 1) || (config.maxWidth > HALF_FLOAT);
    BOOL isMakeSureShowCompleted = (config.isMakeSureShowCompleted) || (config.maxWidth > HALF_FLOAT) || (config.numberOfLines == 0 && config.maxHeight > HALF_FLOAT);
    
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attributes setObject:config.font forKey:NSFontAttributeName];
    
    if (isNoNeedLineHeight && isNoNeedLineSpacing) {
        paragraphStyle.lineSpacing = 0;
        [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        if (config.options&YMTextSizeResultOptionsSize) {
            result.size = [string boundingRectWithSize:CGSizeMake(config.maxWidth, config.maxHeight) options:drawOptions context:nil].size;
            result.size = CGSizeMake(ceil(result.size.width), ceil(result.size.height));
        }
        if (config.options&YMTextSizeResultOptionsAttributedText) {
            paragraphStyle.lineBreakMode = config.lineBreakMode;
            [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
            result.attributedText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        }
        if (config.options&YMTextSizeResultOptionsHasMore) {
            if (isMakeSureShowCompleted) {
                result.hasMore = NO;
            } else {
                CGFloat currentHeight = 0;
                CGFloat allHeight = 0;
                if (config.options&YMTextSizeResultOptionsSize) {
                    currentHeight = result.size.height;
                } else {
                    currentHeight = ceil([string boundingRectWithSize:CGSizeMake(config.maxWidth, config.maxHeight) options:drawOptions context:nil].size.height);
                }
                allHeight = ceil([string boundingRectWithSize:CGSizeMake(config.maxWidth, CGFLOAT_MAX) options:drawOptions context:nil].size.height);
                result.hasMore = (allHeight > currentHeight);
            }
        }
    } else {
        if (config.options == YMTextSizeResultOptionsAttributedText && isNoNeedLineSpacing) {
            paragraphStyle.lineSpacing = 0;
            paragraphStyle.lineBreakMode = config.lineBreakMode;
            [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
            result.attributedText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
            return result;
        }
        
        paragraphStyle.lineSpacing = 0;
        [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
        NSAttributedString *oneText = [[NSAttributedString alloc] initWithString:kOneLine attributes:[attributes copy]];
        
        CGFloat oneLineHeight = ceil([oneText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:drawOptions context:nil].size.height);
        CGFloat maxHeightByLines = (isNoNeedLineHeight) ? (CGFLOAT_MAX) : ((oneLineHeight * config.numberOfLines) + (config.lineSpacing * (config.numberOfLines - 1)));
        CGFloat realMaxHeight = MIN(maxHeightByLines, config.maxHeight);
        
        paragraphStyle.lineSpacing = isNoNeedLineSpacing ? 0 : config.lineSpacing;
        [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
        NSAttributedString *allText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        
        CGSize size = [allText boundingRectWithSize:CGSizeMake(config.maxWidth, realMaxHeight) options:drawOptions context:nil].size;
        size = CGSizeMake(ceil(size.width), ceil(size.height));
        
        if (!isNoNeedLineSpacing && (fabs(size.height - oneLineHeight - config.lineSpacing) <= 1.0)) {
            paragraphStyle.lineSpacing = 0;
            [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
            allText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
            size = CGSizeMake(size.width, oneLineHeight);
        }
        
        if (config.options&YMTextSizeResultOptionsSize) {
            result.size = size;
        }
        if (config.options&YMTextSizeResultOptionsAttributedText) {
            paragraphStyle.lineBreakMode = config.lineBreakMode;
            [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
            result.attributedText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        }
        if (config.options&YMTextSizeResultOptionsHasMore) {
            if (isMakeSureShowCompleted || ((realMaxHeight - size.height - oneLineHeight - config.lineSpacing) > EPS)) {
                result.hasMore = NO;
            } else {
                CGFloat allHeight = ceil([allText boundingRectWithSize:CGSizeMake(config.maxWidth, CGFLOAT_MAX) options:drawOptions context:nil].size.height);
                result.hasMore = (allHeight > result.size.height);
            }
        }
    }
    return result;
}

@end
