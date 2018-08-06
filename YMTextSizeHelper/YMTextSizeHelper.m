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

static NSString * const kOneLine = @"一行text";

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
    if ((config.options & (YMTextSizeResultOptionsSize|YMTextSizeResultOptionsAttributedText|YMTextSizeResultOptionsHasMore)) == 0) {
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
    
    NSMutableDictionary *attributes = ([config.otherAttributes isKindOfClass:[NSDictionary class]]) ? ([config.otherAttributes mutableCopy]) : ([[NSMutableDictionary alloc] init]);
    NSMutableParagraphStyle *paragraphStyle = ([attributes[NSParagraphStyleAttributeName] isKindOfClass:[NSParagraphStyle class]]) ? ([attributes[NSParagraphStyleAttributeName] mutableCopy]) : ([[NSMutableParagraphStyle alloc] init]);
    
    BOOL isNoNeedLineHeight = (config.numberOfLines == 0) || (config.isMakeSureShowCompleted) || (config.maxWidth > BIG_FLOAT);
    BOOL isNoNeedLineSpacing = (fabs(config.lineSpacing) < EPS) || (config.numberOfLines == 1) || (config.maxWidth > BIG_FLOAT);
    BOOL isMakeSureShowCompleted = (config.isMakeSureShowCompleted) || (config.maxWidth > BIG_FLOAT) || (config.numberOfLines == 0 && config.maxHeight > BIG_FLOAT);
    
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [attributes setObject:config.font forKey:NSFontAttributeName];
    
    if (isNoNeedLineHeight && isNoNeedLineSpacing) {
        paragraphStyle.lineSpacing = 0;
        [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        if (config.options&YMTextSizeResultOptionsSize) {
            result.size = [string boundingRectWithSize:CGSizeMake(config.maxWidth, config.maxHeight) options:kDrawOptions context:nil].size;
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
                if (config.options&YMTextSizeResultOptionsSize) {
                    currentHeight = result.size.height;
                } else {
                    currentHeight = ceil([string boundingRectWithSize:CGSizeMake(config.maxWidth, config.maxHeight) options:kDrawOptions context:nil].size.height);
                }
                CGFloat allHeight = ceil([string boundingRectWithSize:CGSizeMake(config.maxWidth, CGFLOAT_MAX) options:kDrawOptions context:nil].size.height);
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
        if (config.options == YMTextSizeResultOptionsHasMore && isMakeSureShowCompleted) {
            result.hasMore = NO;
            return result;
        }
        
        paragraphStyle.lineSpacing = 0;
        [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
        NSAttributedString *oneText = [[NSAttributedString alloc] initWithString:kOneLine attributes:[attributes copy]];
        
        CGFloat oneLineHeight = [YMTextSizeHelper getCacheOneLineHeight:oneText];
        CGFloat maxHeightByLines = (isNoNeedLineHeight) ? (CGFLOAT_MAX) : ((oneLineHeight * config.numberOfLines) + (config.lineSpacing * (config.numberOfLines - 1)));
        CGFloat realMaxHeight = MIN(maxHeightByLines, config.maxHeight);
        
        paragraphStyle.lineSpacing = isNoNeedLineSpacing ? 0 : config.lineSpacing;
        [attributes setObject:[paragraphStyle copy] forKey:NSParagraphStyleAttributeName];
        NSAttributedString *allText = [[NSAttributedString alloc] initWithString:config.text attributes:[attributes copy]];
        
        CGSize size = [allText boundingRectWithSize:CGSizeMake(config.maxWidth, realMaxHeight) options:kDrawOptions context:nil].size;
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
                CGFloat allHeight = ceil([allText boundingRectWithSize:CGSizeMake(config.maxWidth, CGFLOAT_MAX) options:kDrawOptions context:nil].size.height);
                result.hasMore = (allHeight > result.size.height);
            }
        }
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

+ (CGFloat)getCacheOneLineHeight:(NSAttributedString *)oneText
{
    NSNumber *height = [YMTextSizeHelper.cache objectForKey:oneText];
    if (height) {
        return [height doubleValue];
    } else {
        CGFloat oneLineHeight = ceil([oneText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:kDrawOptions context:nil].size.height);
        [YMTextSizeHelper.cache setObject:@(oneLineHeight) forKey:oneText];
        return oneLineHeight;
    }
}

+ (NSString *)getKeyByConfig:(YMTextSizeConfig *)config
{
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:config.text attributes:config.otherAttributes];
    NSString *maxWidth = config.maxWidth > BIG_FLOAT ? @"BIG_FLOAT" : [NSString stringWithFormat:@"%.2lf", config.maxWidth];
    NSString *maxHeight = config.maxHeight > BIG_FLOAT ? @"BIG_FLOAT" : [NSString stringWithFormat:@"%.2lf", config.maxHeight];
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_%.2lf_%@", string, config.font, maxWidth, maxHeight, @(config.numberOfLines), config.lineSpacing, @(config.lineBreakMode)];
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
    result.hasSolvedOptions |= config.options;
    [YMTextSizeHelper.cache setObject:result forKey:config.key];
}

@end
