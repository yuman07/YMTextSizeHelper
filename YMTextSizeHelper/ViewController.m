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
    
    YMTextSizeResult *result = [YMTextSizeHelper getSizeResultWithMakeConfigBlock:^YMTextSizeConfig *{
        YMTextSizeConfig *config = [[YMTextSizeConfig alloc] init];
        config.text = @"近代史开飞机上的看法施蒂利克女老师快女积分卡士大夫监考老师ksdjfksdfjsdklfjskfskldfjds";
        config.font = [UIFont systemFontOfSize:15];
        config.maxWidth = 80;
        config.maxHeight = 1000;
        config.lineSpacing = 7;
        config.numberOfLines = 0;
        config.lineBreakMode = NSLineBreakByTruncatingTail;
        config.options = YMTextSizeResultOptionsAttributedText;
        return config;
    }];

    
    UILabel *label = [[UILabel alloc] init];
    label.attributedText = result.attributedText;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor redColor];
    label.frame = CGRectMake(50, 50, result.size.width, result.size.height);
    [self.view addSubview:label];
    
}

@end
