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
    NSUInteger maxTime = 10000;
    NSStringDrawingOptions drawOptions = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    
    mach_timebase_info_data_t timebaseInfo;
    mach_timebase_info(&timebaseInfo);
    
    uint64_t start1 = mach_absolute_time();
    
    for (NSUInteger i = 0; i < maxTime; i++) {
        [result.attributedText boundingRectWithSize:CGSizeMake(100, 300) options:drawOptions context:nil];
    }
    
    uint64_t end1 = mach_absolute_time();
    
    NSTimeInterval time1 = (((end1 - start1) / 1e6) * timebaseInfo.numer) / timebaseInfo.denom;
    
    uint64_t start2 = mach_absolute_time();
    
    for (NSUInteger i = 0; i < maxTime; i++) {
        [self getResult];
    }
    
    uint64_t end2 = mach_absolute_time();
    
    NSTimeInterval time2 = (((end2 - start2) / 1e6) * timebaseInfo.numer) / timebaseInfo.denom;
    
    NSLog(@"target time::(%.2lf)", time1);
    NSLog(@"current time::(%.2lf)", time2);
    NSLog(@"excess time::(%.2lf)", time2 - time1);
    
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
        config.text = @"人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。";
        config.font = [UIFont systemFontOfSize:15];
        config.maxWidth = 100;
        config.maxHeight = 300;
        config.lineSpacing = 17.789;
        config.numberOfLines = 20;
        config.lineBreakMode = NSLineBreakByWordWrapping;
      //  config.isCache = YES;
        config.options = YMTextSizeResultOptionsSize|YMTextSizeResultOptionsAttributedText;
    }];
    return result;
}

@end
