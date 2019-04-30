//
//  ViewController.m
//  CKLabelTestHost
//
//  Created by vvveiii on 2019/4/4.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonRandom.h>
@import CKLabel;

#define RGB(rgb) [UIColor colorWithRed:(((rgb) & 0xff0000) >> 16) / 255.0 \
                                   green:(((rgb) & 0xff00) >> 8) / 255.0 \
                                    blue:((rgb) & 0xff) / 255.0 \
                                   alpha:1]

#pragma mark - UIFont (icofont)

@interface UIFont (icofont)

+ (UIFont *)fontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldFontOfSize:(CGFloat)fontSize;
+ (UIFont *)italicFontOfSize:(CGFloat)fontSize;

@end

@implementation UIFont (icofont)

+ (UIFont *)fontOfSize:(CGFloat)fontSize {
    UIFont *systemFont = [UIFont systemFontOfSize:fontSize];

    NSMutableDictionary *attrs = NSMutableDictionary.dictionary;
    attrs[UIFontDescriptorNameAttribute] = @"icofont";
    attrs[UIFontDescriptorCascadeListAttribute] = @[[UIFontDescriptor fontDescriptorWithName:systemFont.fontName size:fontSize]];

    UIFontDescriptor *fd = [UIFontDescriptor fontDescriptorWithFontAttributes:attrs];

    return [UIFont fontWithDescriptor:fd size:fontSize];
}

+ (UIFont *)boldFontOfSize:(CGFloat)fontSize {
    UIFont *systemFont = [UIFont boldSystemFontOfSize:fontSize];

    NSMutableDictionary *attrs = NSMutableDictionary.dictionary;
    attrs[UIFontDescriptorNameAttribute] = @"icofont";
    attrs[UIFontDescriptorCascadeListAttribute] = @[[UIFontDescriptor fontDescriptorWithName:systemFont.fontName size:fontSize]];

    UIFontDescriptor *fd = [UIFontDescriptor fontDescriptorWithFontAttributes:attrs];

    return [UIFont fontWithDescriptor:fd size:fontSize];
}

+ (UIFont *)italicFontOfSize:(CGFloat)fontSize {
    UIFont *systemFont = [UIFont italicSystemFontOfSize:fontSize];

    NSMutableDictionary *attrs = NSMutableDictionary.dictionary;
    attrs[UIFontDescriptorNameAttribute] = @"icofont";
    attrs[UIFontDescriptorCascadeListAttribute] = @[[UIFontDescriptor fontDescriptorWithName:systemFont.fontName size:fontSize]];

    UIFontDescriptor *fd = [UIFontDescriptor fontDescriptorWithFontAttributes:attrs];

    return [UIFont fontWithDescriptor:fd size:fontSize];
}

@end

#pragma mark - NSString (Random)

@interface NSString (Random)

@end

@implementation NSString (Random)

+ (NSMutableString *)randomStringWithLength:(NSInteger)length {
    static char a[] = {
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    };

    NSMutableString *string = NSMutableString.string;
    char *bytes = new char[length];
    CCRNGStatus status = CCRandomGenerateBytes(bytes, length);
    if (status == kCCSuccess) {
        for (NSInteger i = 0; i < length; i++) {
            NSInteger idx = abs(bytes[i]) % 62;
            [string appendFormat:@"%c", a[idx]];
        }
    }

    delete [] bytes;

    return string;
}

@end

#pragma mark - DemoCell

@interface DemoCell : UITableViewCell {
    CKLabel *_textLabel;
}

- (void)updateContent;

@end

@implementation DemoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _textLabel = [[CKLabel alloc] initWithFrame:CGRectZero];
        _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _textLabel.didTapText = ^(NSRange range, NSDictionary * _Nonnull attrs) {
            NSString *link = (NSString *)attrs.ck_entityAttribute;
            NSLog(@"<did tap; range: %ld-%ld; '%@'>", range.location, range.length, link);
        };
        [self.contentView addSubview:_textLabel];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:@[
                                           [NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:20],
                                           [NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:20],
                                           [NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-20],
                                           [NSLayoutConstraint constraintWithItem:_textLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-20]
                                           ]];
    }

    return self;
}

- (void)updateContent {
    NSMutableString *text = [NSString randomStringWithLength:1024];
    [text insertString:@"\U0000ef70" atIndex:30];
    [text insertString:@"\U0000ef71" atIndex:180];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                   attributes:@{
                                                                                                NSFontAttributeName: [UIFont fontOfSize:15],
                                                                                                NSForegroundColorAttributeName: RGB(0x515151)
                                                                                                }];
    [attrString addAttributes:@{
                                NSFontAttributeName: [UIFont boldFontOfSize:15],
                                CKTextKitEntityAttributeName: [[CKTextKitEntityAttribute alloc] initWithEntity:@"link"],
                                NSForegroundColorAttributeName: RGB(0x576b95),
                                NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                }
                       range:NSMakeRange(30, 50)];
    [attrString addAttributes:@{
                                NSFontAttributeName: [UIFont italicFontOfSize:15],
                                CKTextKitEntityAttributeName: [[CKTextKitEntityAttribute alloc] initWithEntity:@"link"],
                                NSForegroundColorAttributeName: RGB(0x576b95),
                                NSUnderlineStyleAttributeName: @(NSUnderlineStyleDouble)
                                }
                        range:NSMakeRange(180, 50)];
    _textLabel.attributedText = attrString;
}

@end

#pragma mark - ViewController

@interface ViewController () <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:DemoCell.class forCellReuseIdentifier:NSStringFromClass(DemoCell.class)];
    [self.view addSubview:_tableView];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]
                                ]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DemoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DemoCell.class) forIndexPath:indexPath];
    [cell updateContent];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 220;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

@end
