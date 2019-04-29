//
//  CKLabel.h
//  CKLabel
//
//  Created by vvveiii on 2019/4/4.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CKLabel/CKTextComponentView.h>
#import <CKLabel/CKTextKitAttributes.h>
#import <CKLabel/CKTextKitEntityAttribute.h>
#import <CKLabel/NSAttributedString+CKTextKit.h>
#import <CKLabel/NSDictionary+CKTextKit.h>

@interface CKLabel : CKTextComponentView

@property(nullable, nonatomic, copy) NSString *text;
@property(nullable, nonatomic, strong) UIFont *font;
@property(nullable, nonatomic, strong) UIColor *textColor;

@property(nullable, nonatomic, copy) NSString *truncationText;
@property(nullable, nonatomic, strong) UIColor *truncationTextColor;

@property(nonatomic, assign) NSTextAlignment textAlignment;
@property(nonatomic, assign) CGFloat lineSpacing;
@property(nonatomic, assign) CGFloat paragraphSpacing;
@property(nonatomic, assign) CGFloat lineHeightMultiple;
@property(nonatomic, assign) CGFloat paragraphSpacingBefore;

@property(nullable, nonatomic, copy) NSAttributedString *attributedText;
@property(nullable, nonatomic, copy) NSAttributedString *truncationAttributedText;

@property(nullable, nonatomic, strong) UIColor *highlightColor;

@property(nonatomic, assign) NSUInteger numberOfLines;
@property(nonatomic, assign) NSLineBreakMode lineBreakMode;

// Support for constraint-based layout (auto layout)
// If nonzero, this is used when determining -intrinsicContentSize for multiline labels
@property(nonatomic, assign) CGFloat preferredMaxLayoutWidth;

@property(nullable, nonatomic, copy) void (^didTapText)(NSRange range, NSDictionary * _Nonnull attrs);

- (void)renderInContext:(nullable CGContextRef)context;

@end
