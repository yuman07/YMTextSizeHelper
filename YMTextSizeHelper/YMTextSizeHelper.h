//
//  YMTextSizeHelper.h
//  YMTextSizeHelper
//
//  Created by yuman01 on 2018/7/26.
//  Copyright © 2018年 yuman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, YMTextSizeResultOptions) {
    YMTextSizeResultOptionsSize               = 1 << 0,
    YMTextSizeResultOptionsAttributedText     = 1 << 1,
    YMTextSizeResultOptionsHasMore            = 1 << 2
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

/// 文本的最大行数，必须和label的设置同步，默认为1
@property (nonatomic, assign) NSUInteger numberOfLines;

/// 文本的截断模式，必须和label的设置同步，默认为NSLineBreakByTruncatingTail
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

/// 文本的行间距，默认为0
@property (nonatomic, assign) CGFloat lineSpacing;

/// 文本的其它属性(这些属性的范围必须为全文本)，默认为nil
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey,id> *otherAttributes;

/// 想要哪些结果的options，默认为YMTextSizeResultOptionsSize
@property (nonatomic, assign) YMTextSizeResultOptions options;

/// 是否可以保证文本在config各属性的限制下能展示完全无截断，默认为NO
@property (nonatomic, assign) BOOL isMakeSureShowCompleted;

@end

@interface YMTextSizeResult : NSObject

@property (nonatomic, assign) CGSize size;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, assign) BOOL hasMore;

@end

typedef YMTextSizeConfig*(^makeTextSizeConfig)(void);

@interface YMTextSizeHelper : NSObject

+ (YMTextSizeResult *)getSizeResultWithConfig:(YMTextSizeConfig *)config;

+ (YMTextSizeResult *)getSizeResultWithMakeConfigBlock:(makeTextSizeConfig)makeConfigBlock;

@end
