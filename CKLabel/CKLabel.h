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

@property(nonatomic, copy) NSString *text;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColor;

@property(nonatomic, copy) NSString *truncationText;
@property(nonatomic, strong) UIColor *truncationTextColor;

@property(nonatomic, copy) NSAttributedString *attributedText;
@property(nonatomic, copy) NSAttributedString *truncationAttributedText;

@property(nonatomic, strong) UIColor *highlightColor;

// Support for constraint-based layout (auto layout)
// If nonzero, this is used when determining -intrinsicContentSize for multiline labels
@property(nonatomic, assign) CGFloat preferredMaxLayoutWidth;

@property(nonatomic, copy) void (^didTapText)(NSRange range, NSDictionary *attrs);

@end
