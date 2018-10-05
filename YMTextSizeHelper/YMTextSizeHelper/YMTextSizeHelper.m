//
//  YMTextSizeHelper.m
//  YMTextSizeHelper
//
//  Created by yuman on 2018/7/26.
//  Copyright © 2018年 yuman. All rights reserved.
//

#import "YMTextSizeHelper.h"

static const CGFloat EPS = 0.001;
static const CGFloat BIG_FLOAT = CGFLOAT_MAX / 2.0;
static const NSStringDrawingOptions kDrawOptions = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;

@interface YMTextSizeConfig ()

@property (nonatomic, strong) NSString *key;

@end

@implementation YMTextSizeConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxWidth = CGFLOAT_MAX;
        _maxHeight = CGFLOAT_MAX;
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
    if (!(config.options & ((YMTextSizeResultOptionsAllTextLinesNumber << 1) - 1))) {
        return NO;
    }
    return YES;
}

@end

@interface YMTextSizeResult ()

@property (nonatomic, assign) YMTextSizeResultOptions hasSolvedOptions;

@end

@implementation YMTextSizeResult

+ (YMTextSizeResult *)zeroResult
{
    YMTextSizeResult *result = [[YMTextSizeResult alloc] init];
    result.size = CGSizeZero;
    result.attributedText = nil;
    result.hasMore = NO;
    result.currentLinesNumber = 0;
    result.allTextLinesNumber = 0;
    return result;
}

@end

@interface YMTextSizeHelper()

@property (class, nonatomic, strong) NSCache *cache;

@end

@implementation YMTextSizeHelper

static NSCache *_cache = nil;

+ (YMTextSizeResult *)getSizeResultWithMakeConfigBlock:(makeTextSizeConfig)makeConfigBlock
{
    YMTextSizeConfig *config = [[YMTextSizeConfig alloc] init];
    if (makeConfigBlock) {
        makeConfigBlock(config);
    }
    return [YMTextSizeHelper getSizeResultWithConfig:config];
}

+ (YMTextSizeResult *)getSizeResultWithConfig:(YMTextSizeConfig *)config
{
    YMTextSizeResult *result = [YMTextSizeResult zeroResult];
    if (![YMTextSizeConfig checkConfigVaild:config]) {
        return result;
    }
    
    if (config.isCache) {
        config.key = [YMTextSizeHelper getKeyByConfig:config];
        YMTextSizeResult *result = [YMTextSizeHelper getCacheResultByConfig:config];
        if (result) {
            return result;
        }
    }
    
    if ([config.text hasPrefix:@"\n"] || [config.text hasPrefix:@"\r"]) {
        config.text = [NSString stringWithFormat:@" %@", config.text];
    }
    
    NSMutableDictionary *attributes = ([config.otherAttributes isKindOfClass:[NSDictionary class]]) ? ([config.otherAttributes mutableCopy]) : ([[NSMutableDictionary alloc] init]);
    NSMutableParagraphStyle *paragraphStyle = ([attributes[NSParagraphStyleAttributeName] isKindOfClass:[NSParagraphStyle class]]) ? ([attributes[NSParagraphStyleAttributeName] mutableCopy]) : ([[NSMutableParagraphStyle alloc] init]);
    
    CGFloat allTextHeight = -1.0;
    CGFloat oneLineHeight = config.font.lineHeight;
    CGFloat oneLineAndSpacingHeight = oneLineHeight + config.lineSpacing;
    BOOL isNoNeedLineSpacing = (fabs(config.lineSpacing) < EPS) || (config.numberOfLines == 1) || (config.maxWidth > BIG_FLOAT);
    
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = isNoNeedLineSpacing ? 0 : config.lineSpacing;
    [attributes setObject:config.font forKey:NSFontAttributeName];
    [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
    NSAttributedString *allText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
    
    CGFloat maxHeightByLines = (config.numberOfLines == 0) ? (CGFLOAT_MAX) : ((oneLineHeight * config.numberOfLines) + (config.lineSpacing * (config.numberOfLines - 1)));
    CGFloat realMaxHeight = MIN(maxHeightByLines, config.maxHeight);
    CGSize size = [allText boundingRectWithSize:CGSizeMake(config.maxWidth, realMaxHeight) options:kDrawOptions context:nil].size;
    
    if (!isNoNeedLineSpacing && (fabs(size.height - oneLineAndSpacingHeight) < EPS)) {
        paragraphStyle.lineSpacing = 0;
        [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
        allText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        size.height = oneLineHeight;
    }
    
    if (config.options & YMTextSizeResultOptionsSize) {
        result.size = CGSizeMake(ceil(size.width), ceil(size.height));
    }
    
    if (config.options & YMTextSizeResultOptionsAttributedText) {
        if (config.lineBreakMode == NSLineBreakByWordWrapping) {
            result.attributedText = allText;
        } else {
            paragraphStyle.lineBreakMode = config.lineBreakMode;
            [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
            result.attributedText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        }
    }
    
    if ((config.options & YMTextSizeResultOptionsHasMore)) {
        if (((realMaxHeight - size.height) > oneLineAndSpacingHeight) || (config.maxWidth > BIG_FLOAT)) {
            result.hasMore = NO;
        } else {
            allTextHeight = [allText boundingRectWithSize:CGSizeMake(config.maxWidth, CGFLOAT_MAX) options:kDrawOptions context:nil].size.height;
            result.hasMore = ((allTextHeight - size.height) > oneLineAndSpacingHeight);
        }
    }
    
    if (config.options & YMTextSizeResultOptionsCurrentLinesNumber) {
        result.currentLinesNumber = round(((size.height + config.lineSpacing) / oneLineAndSpacingHeight));
    }
    
    if (config.options & YMTextSizeResultOptionsAllTextLinesNumber) {
        if (allTextHeight < 0) {
            allTextHeight = [allText boundingRectWithSize:CGSizeMake(config.maxWidth, CGFLOAT_MAX) options:kDrawOptions context:nil].size.height;
        }
        result.allTextLinesNumber = round(((allTextHeight + config.lineSpacing) / oneLineAndSpacingHeight));
    }
    
    if (config.isCache) {
        [YMTextSizeHelper saveCacheResultByConfig:config result:result];
    }
    
    return result;
}

+ (void)setCache:(NSCache *)cache
{
    _cache = cache;
}

+ (NSCache *)cache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[NSCache alloc] init];
    });
    return _cache;
}

+ (NSString *)getKeyByConfig:(YMTextSizeConfig *)config
{
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:config.text attributes:config.otherAttributes];
    NSString *maxWidth = config.maxWidth > BIG_FLOAT ? @"BIG_FLOAT" : [NSString stringWithFormat:@"%.2f", config.maxWidth];
    NSString *maxHeight = config.maxHeight > BIG_FLOAT ? @"BIG_FLOAT" : [NSString stringWithFormat:@"%.2f", config.maxHeight];
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_%.2f_%@", string, config.font, maxWidth, maxHeight, @(config.numberOfLines), config.lineSpacing, @(config.lineBreakMode)];
    return key;
}

+ (YMTextSizeResult *)getCacheResultByConfig:(YMTextSizeConfig *)config
{
    YMTextSizeResult *result = [YMTextSizeHelper.cache objectForKey:config.key];
    if (!result || ((config.options|result.hasSolvedOptions) != result.hasSolvedOptions)) {
        return nil;
    } else {
        return result;
    }
}

+ (void)saveCacheResultByConfig:(YMTextSizeConfig *)config result:(YMTextSizeResult *)result
{
    YMTextSizeResult *oldResult = [YMTextSizeHelper.cache objectForKey:config.key];
    if (!oldResult) {
        result.hasSolvedOptions = config.options;
        [YMTextSizeHelper.cache setObject:result forKey:config.key];
    } else if (((oldResult.hasSolvedOptions|config.options) != oldResult.hasSolvedOptions)) {
        oldResult.hasSolvedOptions |= config.options;
        if (config.options&YMTextSizeResultOptionsSize) {
            oldResult.size = result.size;
        }
        if (config.options&YMTextSizeResultOptionsAttributedText) {
            oldResult.attributedText = result.attributedText;
        }
        if (config.options&YMTextSizeResultOptionsHasMore) {
            oldResult.hasMore = result.hasMore;
        }
        if (config.options&YMTextSizeResultOptionsCurrentLinesNumber) {
            oldResult.currentLinesNumber = result.currentLinesNumber;
        }
        if (config.options&YMTextSizeResultOptionsAllTextLinesNumber) {
            oldResult.allTextLinesNumber = result.allTextLinesNumber;
        }
        [YMTextSizeHelper.cache setObject:oldResult forKey:config.key];
    }
}

@end
