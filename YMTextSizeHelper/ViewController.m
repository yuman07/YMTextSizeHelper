//
//  ViewController.m
//  YMTextSizeHelper
//
//  Created by yuman01 on 2018/7/26.
//  Copyright © 2018年 yuman. All rights reserved.
//

#import "ViewController.h"
#import "YMTextSizeHelper.h"

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
    
    NSTimeInterval begin1 = [NSDate date].timeIntervalSince1970;
    
    for (NSUInteger i = 0; i < maxTime; i++) {
        [result.attributedText boundingRectWithSize:CGSizeMake(200, 200) options:drawOptions context:nil];
    }
    
    NSTimeInterval end1 = [NSDate date].timeIntervalSince1970;
    
    NSTimeInterval time1 = (end1 - begin1) * 1000.0;
    
    NSTimeInterval begin2 = [NSDate date].timeIntervalSince1970;
    
    for (NSUInteger i = 0; i < maxTime; i++) {
        [self getResult];
    }
    
    NSTimeInterval end2 = [NSDate date].timeIntervalSince1970;
    
    NSTimeInterval time2 = (end2 - begin2) * 1000.0;
    
    NSLog(@"target time::(%.2f)", time1);
    NSLog(@"current time::(%.2f)", time2);
    NSLog(@"gap time::(%.2f)", time2 - time1);
}

- (void)testTrue
{
    YMTextSizeResult *result = [self getResult];
    
    UILabel *label = [[UILabel alloc] init];
    label.attributedText = result.attributedText;
    label.numberOfLines = 0;
    label.frame = CGRectMake(80, 80, result.size.width, result.size.height);
    label.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:label];
    
    NSLog(@"%@", NSStringFromCGSize(label.frame.size));
    NSLog(@"%@", @(result.hasMore));
    NSLog(@"%@", @(result.linesNumber));
}

- (YMTextSizeResult *)getResult
{
    YMTextSizeResult *result = [YMTextSizeHelper calculateSizeWithConfigMaker:^(YMTextSizeConfig *config) {
        config.text = @"人类一败涂地！\nOpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。人类一败涂地！OpenAI血虐Dota2半职业战队！马斯克仅评价了两个字。。。";
        config.font = [UIFont systemFontOfSize:15];
        config.maxWidth = 200;
        config.maxHeight = 200;
        config.lineSpacing = 7.789;
        config.numberOfLines = 0;
        config.lineBreakMode = NSLineBreakByTruncatingTail;
        config.options = YMTextSizeResultOptionsSize|YMTextSizeResultOptionsAttributedText;
    }];
    return result;
}

@end
