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
    YMTextSizeResultOptionsCurrentLinesNumber  = 1 << 3,
    YMTextSizeResultOptionsAllLinesNumber      = 1 << 4
};

@interface YMTextSizeConfig : NSObject

/// 文本内容，必须设置，默认为nil
@property (nonatomic, copy) NSString *text;

/// 文本字体，必须设置，默认为nil
@property (nonatomic, strong) UIFont *font;

/// 文本的最大宽度，默认为CGFLOAT_MAX
@property (nonatomic, assign) CGFloat maxWidth;

/// 文本的最大高度，默认为CGFLOAT_MAX
@property (nonatomic, assign) CGFloat maxHeight;

/// 文本的最大行数，默认为0(即无限制)
@property (nonatomic, assign) NSUInteger numberOfLines;

/// 文本的行间距，默认为0
@property (nonatomic, assign) CGFloat lineSpacing;

/// 文本的截断模式，默认为NSLineBreakByWordWrapping
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

/// 文本的其它属性，默认为nil
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *otherAttributes;

/// 需要计算哪些结果的options，默认为YMTextSizeResultOptionsSize
@property (nonatomic, assign) YMTextSizeResultOptions options;

/// 文本如果可能会被多次重复计算，可将此flag设置为YES以提高性能，默认为NO
@property (nonatomic, assign) BOOL isCache;

@end

@interface YMTextSizeResult : NSObject

@property (nonatomic, assign) CGSize size;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSUInteger currentLinesNumber;
@property (nonatomic, assign) NSUInteger allLinesNumber;

@end

typedef void(^makeTextSizeConfig)(YMTextSizeConfig * config);

@interface YMTextSizeHelper : NSObject

+ (YMTextSizeResult *)getSizeResultWithConfig:(YMTextSizeConfig *)config;

+ (YMTextSizeResult *)getSizeResultWithMakeConfigBlock:(makeTextSizeConfig)makeConfigBlock;

@end
