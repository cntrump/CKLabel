//
//  ViewController.m
//  CKLabelTestHost
//
//  Created by vvveiii on 2019/4/4.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import "ViewController.h"
@import CKLabel;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CKLabel *ckClickableLabel = [[CKLabel alloc] init];
    ckClickableLabel.attributedText = [[NSAttributedString alloc] initWithString:@"a coder's notepad"
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName: UIColor.purpleColor,
                                                                                   NSFontAttributeName: [UIFont systemFontOfSize:15],
                                                                                   CKTextKitEntityAttributeName: [[CKTextKitEntityAttribute alloc] initWithEntity:@"https://lvv.me"]
                                                                                   }];
    ckClickableLabel.didTapText = ^(NSRange range, NSDictionary *attrs) {
        NSString *urlString = (NSString *)attrs.ck_entityAttribute;
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:urlString]];
    };
    [self.view addSubview:ckClickableLabel];
    CGSize size = [ckClickableLabel sizeThatFits:CGSizeMake(300, INFINITY)];
    ckClickableLabel.frame = CGRectMake(10, 50, size.width, size.height);
    
    CKLabel *ckAsyncLabel = [[CKLabel alloc] init];
    ckAsyncLabel.font = [UIFont systemFontOfSize:15];
    ckAsyncLabel.textColor = UIColor.orangeColor;
    ckAsyncLabel.text = @"Shall I compare thee to a summer's day?\n"
                        @"Thou art more lovely and more temperate:\n"
                        @"Rough winds do shake the darling buds of May,\n"
                        @"And summer's lease hath all too short a date:\n"
                        @"Sometime too hot the eye of heaven shines,\n"
                        @"And often is his gold complexion dimm'd;\n"
                        @"And every fair from fair sometime declines,\n"
                        @"By chance or nature's changing course untrimm'd\n"
                        @"But thy eternal summer shall not fade\n"
                        @"Nor lose possession of that fair thou owest;\n"
                        @"Nor shall Death brag thou wander'st in his shade,\n"
                        @"When in eternal lines to time thou growest:\n"
                        @"So long as men can breathe or eyes can see,\n"
                        @"So long lives this and this gives life to thee.";
    [self.view addSubview:ckAsyncLabel];
    
    // auto layout
    ckAsyncLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:ckAsyncLabel attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:ckClickableLabel attribute:NSLayoutAttributeBottom
                                                        multiplier:1 constant:10];
    [self.view addConstraint:c];
    
    c = [NSLayoutConstraint constraintWithItem:ckAsyncLabel attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view attribute:NSLayoutAttributeLeft
                                    multiplier:1 constant:10];
    [self.view addConstraint:c];
    
    c = [NSLayoutConstraint constraintWithItem:ckAsyncLabel attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view attribute:NSLayoutAttributeRight
                                    multiplier:1 constant:-10];
    [self.view addConstraint:c];
}

@end
