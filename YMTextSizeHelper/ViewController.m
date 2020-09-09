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
    
    [self testTrue];
}

- (void)testTrue
{
    NSArray *testStringArray = @[@"您",@"好",@"中",@"国",@"w",@"i",@"d",@"t",@"h",@",",@"。",@"a",@"b",@"c",@"\n", @"1",@"5",@"2",@"j",@"A",@"J",@"0",@"🆚",@"👃",@" "];
    NSMutableString *text = [[NSMutableString alloc] init];
    NSUInteger length = arc4random() % 200 + 1;
    for (NSUInteger i = 0; i < length; i++) {
        [text appendString:testStringArray[arc4random() % testStringArray.count]];
    }
    
    YMTextSizeConfig *config = [[YMTextSizeConfig alloc] init];
    config.text = [text copy];
    config.font = [UIFont systemFontOfSize:15];
    config.maxWidth = 300;
    config.numberOfLines = 2;
    config.lineBreakMode = NSLineBreakByTruncatingTail;
    config.options = YMTextSizeResultOptionsSize|YMTextSizeResultOptionsAttributedText|YMTextSizeResultOptionsHasMore|YMTextSizeResultOptionsLinesNumber;
    
    
    YMTextSizeResult *result = [YMTextSizeHelper calculateSizeWithConfig:config];
    NSLog(@"Y : %@", NSStringFromCGSize(result.size));
    NSLog(@"Y : %@", @(result.hasMore));
    NSLog(@"Y : %@", @(result.linesNumber));
    
    UILabel *label = [[UILabel alloc] init];
    label.text = config.text;
    label.numberOfLines = config.numberOfLines;
    label.lineBreakMode = config.lineBreakMode;
    label.font = config.font;
    label.frame = CGRectMake(80, 80, config.maxWidth, 0);
    label.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:label];
    [label sizeToFit];
    
    if (label.frame.size.width > config.maxWidth) {
        label.frame = CGRectMake(80, 80, config.maxWidth, label.frame.size.height);
    }
    
    NSLog(@"M : %@", NSStringFromCGSize(label.frame.size));
    
    UILabel *tLabel = [[UILabel alloc] init];
    tLabel.backgroundColor = [UIColor yellowColor];
    tLabel.frame = CGRectMake(80, 300, result.size.width, result.size.height);
    tLabel.attributedText = result.attributedText;
    tLabel.numberOfLines = 0;
    [self.view addSubview:tLabel];
}

@end
