//
//  YMTextSizeHelper.m
//  YMTextSizeHelper
//
//  Created by yuman on 2018/7/26.
//  Copyright © 2018年 yuman. All rights reserved.
//

#import "YMTextSizeHelper.h"

static const CGFloat kEPS = 0.0001;
static const CGFloat kBigFloat = CGFLOAT_MAX / 2.0;
static const NSStringDrawingOptions kDrawOptions = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;

#define CHECK_DOUBLE_INVALID(_DOUBLE_) \
({ double __a__ = (_DOUBLE_); ((isnan(__a__) || isinf(__a__))); })

@implementation YMTextSizeConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxWidth = CGFLOAT_MAX;
        _maxHeight = CGFLOAT_MAX;
        _lineBreakMode = NSLineBreakByTruncatingTail;
        _options = YMTextSizeResultOptionsSize;
    }
    return self;
}

+ (BOOL)checkConfigValid:(YMTextSizeConfig *)config
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
    if (CHECK_DOUBLE_INVALID(config.maxWidth) || CHECK_DOUBLE_INVALID(config.maxHeight) || CHECK_DOUBLE_INVALID(config.lineSpacing)) {
        return NO;
    }
    if (config.maxWidth < kEPS || config.maxHeight < kEPS || config.lineSpacing < -kEPS) {
        return NO;
    }
    if (config.otherAttributes && ![config.otherAttributes isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    if (!(config.options & ((YMTextSizeResultOptionsLinesNumber << 1) - 1))) {
        return NO;
    }
    return YES;
}

@end

@implementation YMTextSizeResult

@end

@implementation YMTextSizeHelper

+ (YMTextSizeResult *)calculateSizeWithConfigMaker:(void (^)(YMTextSizeConfig *))configMaker
{
    YMTextSizeConfig *config = [[YMTextSizeConfig alloc] init];
    if (configMaker) {
        configMaker(config);
    }
    return [YMTextSizeHelper calculateSizeWithConfig:config];
}

+ (YMTextSizeResult *)calculateSizeWithConfig:(YMTextSizeConfig *)config
{
    if (![YMTextSizeConfig checkConfigValid:config]) {
        return nil;
    }
    
    if ([config.text hasPrefix:@"\n"] || [config.text hasPrefix:@"\r"]) {
        config.text = [NSString stringWithFormat:@" %@", config.text];
    }
    
    NSMutableDictionary *attributes = ([config.otherAttributes isKindOfClass:[NSDictionary class]]) ? ([config.otherAttributes mutableCopy]) : ([NSMutableDictionary dictionary]);
    NSMutableParagraphStyle *paragraphStyle = ([attributes[NSParagraphStyleAttributeName] isKindOfClass:[NSParagraphStyle class]]) ? ([attributes[NSParagraphStyleAttributeName] mutableCopy]) : ([[NSMutableParagraphStyle alloc] init]);
    
    CGFloat oneLineHeight = config.font.lineHeight;
    CGFloat oneLineAndSpacingHeight = oneLineHeight + config.lineSpacing;
    BOOL isMakeSureNoLineSpacing = (fabs(config.lineSpacing) < kEPS) || (config.numberOfLines == 1) || (config.maxWidth > kBigFloat) || (config.text.length == 1);
    
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = isMakeSureNoLineSpacing ? 0 : config.lineSpacing;
    [attributes setObject:config.font forKey:NSFontAttributeName];
    [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
    
    CGFloat maxHeightByLines = (config.numberOfLines == 0) ? (CGFLOAT_MAX) : (config.numberOfLines * oneLineAndSpacingHeight - config.lineSpacing);
    CGFloat realMaxHeight = MIN(maxHeightByLines, config.maxHeight);
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(config.maxWidth, realMaxHeight) options:kDrawOptions context:nil].size;
    
    if (!isMakeSureNoLineSpacing && (fabs(size.height - oneLineAndSpacingHeight) < kEPS)) {
        paragraphStyle.lineSpacing = 0;
        [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
        attributedText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        size.height = oneLineHeight;
    }
    
    YMTextSizeResult *result = [[YMTextSizeResult alloc] init];
    
    if (config.options & YMTextSizeResultOptionsSize) {
        result.size = CGSizeMake(ceil(size.width), ceil(size.height));
    }
    
    if (config.options & YMTextSizeResultOptionsAttributedText) {
        if (config.lineBreakMode == NSLineBreakByWordWrapping) {
            result.attributedText = attributedText;
        } else {
            paragraphStyle.lineBreakMode = config.lineBreakMode;
            [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
            result.attributedText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        }
    }
    
    if ((config.options & YMTextSizeResultOptionsHasMore)) {
        if ((config.maxWidth > kBigFloat) || ((realMaxHeight - size.height) > oneLineAndSpacingHeight)) {
            result.hasMore = NO;
        } else {
            CGFloat allTextHeight = [attributedText boundingRectWithSize:CGSizeMake(config.maxWidth, CGFLOAT_MAX) options:kDrawOptions context:nil].size.height;
            result.hasMore = ((allTextHeight - size.height) > oneLineAndSpacingHeight);
        }
    }
    
    if (config.options & YMTextSizeResultOptionsLinesNumber) {
        result.linesNumber = round(((size.height + config.lineSpacing) / oneLineAndSpacingHeight));
    }
    
    return result;
}

@end
