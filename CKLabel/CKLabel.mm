//
//  CKLabel.mm
//  CKLabel
//
//  Created by vvveiii on 2019/4/4.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import "CKLabel.h"
#import "CKTextComponentLayer.h"
#import "CKTextKitContext.h"
#import "CKTextKitRenderer+TextChecking.h"
#import "CKTextComponentLayerHighlighter.h"

struct CKTextKitCommonAttributes : CKTextKitAttributes {
    CKTextKitCommonAttributes () {
        attributedString = nil;
        truncationAttributedString = nil;
        avoidTailTruncationSet = nil;
        lineBreakMode = NSLineBreakByWordWrapping;
        maximumNumberOfLines = 0;
        shadowOffset = CGSizeZero;
        shadowColor = nil;
        shadowOpacity = 0;
        shadowRadius = 0;
        layoutManagerFactory = NULL;
    }
};

@interface CKLabel () {
    NSAttributedString *_innerAttributedText;
    NSAttributedString *_innerTruncationAttributedText;
    CKTextKitCommonAttributes *_commonAttrs;
}

@property(nonatomic, readonly) CKTextComponentLayer *textLayer;

@end

@implementation CKLabel

- (void)dealloc {
    delete _commonAttrs;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _font = [UIFont systemFontOfSize:17];
        _textColor = UIColor.blackColor;
        _textAlignment = NSTextAlignmentNatural;
        _commonAttrs = new CKTextKitCommonAttributes;
        self.highlightColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:0.25];
        self.textLayer.displayMode = CKAsyncLayerDisplayModeAlwaysAsync;
        [self addTarget:self action:@selector(didTapText:) forControlEvents:CKUIControlEventTextViewDidTapText];
    }
    
    return self;
}

- (CKTextComponentLayer *)textLayer {
    return static_cast<CKTextComponentLayer *>(self.layer);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _commonAttrs->attributedString = self.attributedText;
    _commonAttrs->truncationAttributedString = self.truncationAttributedText;
    CKTextKitRenderer *renderer = [[CKTextKitRenderer alloc] initWithTextKitAttributes:*_commonAttrs constrainedSize:self.bounds.size];

    self.renderer = renderer;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.attributedText ck_boundingSizeWithSize:size lineBreakMode:NSLineBreakByWordWrapping maximumNumberOfLines:0];
}

- (CGSize)intrinsicContentSize {
    CGFloat w = _preferredMaxLayoutWidth > 0 ? _preferredMaxLayoutWidth : INFINITY;
    
    return [self sizeThatFits:CGSizeMake(w, INFINITY)];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    CGFloat w = CGRectGetWidth(bounds);
    if (_preferredMaxLayoutWidth != w) {
        _preferredMaxLayoutWidth = w;
        
        __weak typeof(self) wself = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself invalidateIntrinsicContentSize];
        });
    }
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    self.textLayer.highlighter.highlightColor = highlightColor;
}

- (NSAttributedString *)attributedText {
    if (_text) {
        _innerAttributedText = [[NSAttributedString alloc] initWithString:_text attributes:@{
                                                                                        NSFontAttributeName: _font,
                                                                                        NSForegroundColorAttributeName: _textColor,
                                                                                        NSParagraphStyleAttributeName: self.paragraphStyle
                                                                                        }];
    }
    
    return _innerAttributedText;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _text = nil;
    _innerAttributedText = attributedText.copy;
    
    [self updateContent];
}

- (void)setText:(NSString *)text {
    _innerAttributedText = nil;
    _text = text.copy;

    [self updateContent];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    
    if (_text) {
        [self updateContent];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (!_truncationTextColor) {
        _truncationTextColor = textColor;
    }
    
    if (_text) {
        [self updateContent];
    }
}

- (NSAttributedString *)truncationAttributedText {
    if (_truncationText) {
        _innerTruncationAttributedText = [[NSAttributedString alloc] initWithString:_truncationText attributes:@{
                                                                                             NSFontAttributeName: _font,
                                                                                             NSForegroundColorAttributeName: _truncationTextColor,
                                                                                             NSParagraphStyleAttributeName: self.paragraphStyle
                                                                                             }];
    }
    
    return _innerTruncationAttributedText;
}

- (void)setTruncationAttributedText:(NSAttributedString *)truncationAttributedText {
    _truncationText = nil;
    _innerTruncationAttributedText = truncationAttributedText.copy;
    
    [self updateContent];
}

- (void)setTruncationText:(NSString *)truncationText {
    _innerTruncationAttributedText = nil;
    _truncationText = truncationText.copy;

    [self updateContent];
}

- (void)setTruncationTextColor:(UIColor *)truncationTextColor {
    _truncationTextColor = truncationTextColor;
    
    if (_truncationText) {
        [self updateContent];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
    _paragraphSpacing = paragraphSpacing;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple {
    _lineHeightMultiple = lineHeightMultiple;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
    _paragraphSpacingBefore = paragraphSpacingBefore;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (NSParagraphStyle *)paragraphStyle {
    NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
    style.alignment = _textAlignment;
    style.lineSpacing = _lineSpacing;
    style.paragraphSpacing = _paragraphSpacing;
    style.lineHeightMultiple = _lineHeightMultiple;
    style.paragraphSpacingBefore = _paragraphSpacingBefore;

    return style;
}

- (void)updateContent {
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    NSTextCheckingResult *trackingTextCheckingResult = [self.textLayer.renderer textCheckingResultAtPoint:point];
    
    return !!trackingTextCheckingResult;
}

- (void)didTapText:(CKLabel *)sender {
    __block NSDictionary *attrs = nil;
    NSRange highlightedRange = self.textLayer.highlighter.highlightedRange;
    [self.renderer.context performBlockWithLockedTextKitComponents:^(NSLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        attrs = [textStorage attributesAtIndex:highlightedRange.location longestEffectiveRange:NULL inRange:highlightedRange];
    }];
    
    if (_didTapText) {
        _didTapText(highlightedRange, attrs);
    }
}

@end
