//
//  YMTextSizeHelper.h
//  YMTextSizeHelper
//
//  Created by yuman on 2018/7/26.
//  Copyright © 2018年 yuman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, YMTextSizeResultOptions) {
    YMTextSizeResultOptionsSize                = 1 << 0,
    YMTextSizeResultOptionsAttributedText      = 1 << 1,
    YMTextSizeResultOptionsHasMore             = 1 << 2,
    YMTextSizeResultOptionsLinesNumber         = 1 << 3,
};

@interface YMTextSizeConfig : NSObject

/// 文本内容，必须设置，默认为nil
@property (nonatomic, copy) NSString *text;

/// 文本字体，必须设置，默认为nil
@property (nonatomic, strong) UIFont *font;

/// 文本的最大宽度，非必需，默认为CGFLOAT_MAX
@property (nonatomic, assign) CGFloat maxWidth;

/// 文本的最大高度，非必需，默认为CGFLOAT_MAX
@property (nonatomic, assign) CGFloat maxHeight;

/// 文本的最大行数，非必需，默认为0(即无限制)
@property (nonatomic, assign) NSUInteger numberOfLines;

/// 文本的行间距，非必需，默认为0
@property (nonatomic, assign) CGFloat lineSpacing;

/// 文本的截断模式，非必需，默认为NSLineBreakByTruncatingTail
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

/// 文本的其它属性，非必需，默认为nil
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *otherAttributes;

/// 需要计算哪些结果的options，非必需，默认为YMTextSizeResultOptionsSize
@property (nonatomic, assign) YMTextSizeResultOptions options;

@end

@interface YMTextSizeResult : NSObject

@property (nonatomic, assign) CGSize size;
@property (nonatomic, copy)   NSAttributedString *attributedText;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSUInteger linesNumber;

@end

/**
 一个简易的计算文本size工具类
 支持在子线程计算
 如果计算失败则返回nil
 */
@interface YMTextSizeHelper : NSObject

+ (YMTextSizeResult *)calculateSizeWithConfig:(YMTextSizeConfig *)config;

+ (YMTextSizeResult *)calculateSizeWithConfigMaker:(void(^)(YMTextSizeConfig *config))configMaker;

@end
