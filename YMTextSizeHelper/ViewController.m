//
//  ViewController.m
//  YMTextSizeHelper
//
//  Created by yuman01 on 2018/7/26.
//  Copyright © 2018年 yuman. All rights reserved.
//

#import "ViewController.h"
#import "YMTextSizeHelper.h"

static NSString * const kTestString = @"\n🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123🙆🐴🍁☺️😺你好我是yuman123";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testTrue];
}

- (void)testTrue
{
    YMTextSizeResult *result = [self getResult];
    NSLog(@"%@", NSStringFromCGSize(result.size));
    NSLog(@"%@", @(result.hasMore));
    NSLog(@"%@", @(result.linesNumber));
    
    UILabel *label = [[UILabel alloc] init];
    label.text = kTestString;
    label.numberOfLines = 3;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.font = [UIFont systemFontOfSize:15];
    label.frame = CGRectMake(80, 80, 200, label.frame.size.height);
    label.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:label];
    [label sizeToFit];
    if (label.frame.size.width > 200) {
        label.frame = CGRectMake(80, 80, 200, label.frame.size.height);
    }
    
    NSLog(@"%@", NSStringFromCGSize(label.frame.size));
}

- (YMTextSizeResult *)getResult
{
    YMTextSizeResult *result = [YMTextSizeHelper calculateSizeWithConfigMaker:^(YMTextSizeConfig *config) {
        config.text = kTestString;
        config.font = [UIFont systemFontOfSize:15];
        config.maxWidth = 200;
    //    config.maxHeight = 30;
    //    config.lineSpacing = 10;
        config.numberOfLines = 3;
        config.lineBreakMode = NSLineBreakByTruncatingTail;
        config.options = YMTextSizeResultOptionsSize|YMTextSizeResultOptionsAttributedText|YMTextSizeResultOptionsHasMore|YMTextSizeResultOptionsLinesNumber;
    }];
    return result;
}

@end
