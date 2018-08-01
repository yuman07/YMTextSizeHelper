//
//  ViewController.m
//  YMTextSizeHelper
//
//  Created by yuman01 on 2018/7/26.
//  Copyright © 2018年 yuman. All rights reserved.
//

#import "ViewController.h"
#import "YMTextSizeHelper.h"
#import <mach/mach.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testTime];
    
//    [self testTrue];
}

- (void)testTime
{
    YMTextSizeResult *result =  [self getResult];
    NSStringDrawingOptions drawOptions = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    
    mach_timebase_info_data_t timebaseInfo;
    mach_timebase_info(&timebaseInfo);
    uint64_t start = mach_absolute_time();
    
    
    for (NSUInteger i = 0; i < 100000; i++) {
   //     [self getResult];
        [result.attributedText boundingRectWithSize:CGSizeMake(100, 300) options:drawOptions context:nil];
    }
    
    uint64_t end = mach_absolute_time();
    
    NSTimeInterval time = (((end - start) / 1e6) * timebaseInfo.numer) / timebaseInfo.denom;
    
    NSLog(@"(%.2lf)", time/10.0);
}

- (void)testTrue
{
    YMTextSizeResult *result = [self getResult];
    
    UILabel *label = [[UILabel alloc] init];
    label.attributedText = result.attributedText;
    label.numberOfLines = 0;
    label.frame = CGRectMake(50, 50, result.size.width, result.size.height);
    label.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:label];
    
    NSLog(@"%d", result.hasMore);
}

- (YMTextSizeResult *)getResult
{
    YMTextSizeResult *result = [YMTextSizeHelper getSizeResultWithMakeConfigBlock:^(YMTextSizeConfig *config) {
        config.text = @"福建省的看法ddd？？？仅是打开荆防颗粒福建省的看法仅。。是fdfd打：：开荆防颗粒福建省的看法仅是打开荆g防颗粒福建省的。看法仅是打开荆防颗粒福建省的看法仅是打开荆防颗粒";
        config.font = [UIFont systemFontOfSize:15];
        config.maxWidth = 100;
        config.maxHeight = 300;
        config.lineSpacing = 17.789;
        config.numberOfLines = 10;
        config.lineBreakMode = NSLineBreakByTruncatingTail;
        config.options = YMTextSizeResultOptionsSize|YMTextSizeResultOptionsAttributedText;
    }];
    return result;
}

@end
