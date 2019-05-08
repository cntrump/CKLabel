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
    NSString *_text;
    NSAttributedString *_innerAttributedText;
    NSAttributedString *_innerTruncationAttributedText;
    CKTextKitCommonAttributes *_commonAttrs;
    NSMutableParagraphStyle *_paragraphStyle;
}

@property(nonatomic, readonly) CKTextComponentLayer *textLayer;

@end

@implementation CKLabel

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p; baseClass: %@; frame:(%lf %lf, %lf %lf); layer= <%@: %p>; '%@'>",
            NSStringFromClass(self.class), self, NSStringFromClass(self.superclass),
            CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame),
            NSStringFromClass(self.layer.class), self.layer,
            _innerAttributedText ? _innerAttributedText.string : _text];
}

- (void)dealloc {
    delete _commonAttrs;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _font = [UIFont systemFontOfSize:17];
        _textColor = UIColor.blackColor;
        _textAlignment = NSTextAlignmentNatural;
        _commonAttrs = new CKTextKitCommonAttributes;
        _paragraphStyle = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
        self.highlightColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:0.25];
        self.textLayer.highlighter.measureOption = CKTextKitRendererMeasureOptionLineHeight;
        self.displayMode = CKAsyncLayerDisplayModeAlwaysAsync;
        [self addTarget:self action:@selector(didTapText:) forControlEvents:CKUIControlEventTextViewDidTapText];
    }
    
    return self;
}

- (void)setDisplayMode:(CKAsyncLayerDisplayMode)displayMode {
    _displayMode = displayMode;
    self.textLayer.displayMode = displayMode;
}

- (CKTextComponentLayer *)textLayer {
    return static_cast<CKTextComponentLayer *>(self.layer);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _commonAttrs->lineBreakMode = _lineBreakMode;
    _commonAttrs->maximumNumberOfLines = _numberOfLines;
    _commonAttrs->attributedString = self.attributedText;
    _commonAttrs->truncationAttributedString = self.truncationAttributedText;
    CKTextKitRenderer *renderer = [[CKTextKitRenderer alloc] initWithTextKitAttributes:*_commonAttrs constrainedSize:self.bounds.size];

    self.renderer = renderer;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.attributedText ck_boundingSizeWithSize:size lineBreakMode:_lineBreakMode maximumNumberOfLines:_numberOfLines];
}

- (CGSize)intrinsicContentSize {
    CGFloat w = _preferredMaxLayoutWidth > 0 ? _preferredMaxLayoutWidth : INFINITY;
    
    return [self sizeThatFits:CGSizeMake(w, INFINITY)];
}

#pragma mark - setter

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
    if (_preferredMaxLayoutWidth == preferredMaxLayoutWidth) {
        return;
    }

    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    if (_highlightColor == highlightColor) {
        return;
    }

    _highlightColor = highlightColor;
    self.textLayer.highlighter.highlightColor = _highlightColor;
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
    if (_innerAttributedText && [attributedText isEqualToAttributedString:_innerAttributedText]) {
        return;
    }

    _text = nil;
    _innerAttributedText = attributedText.copy;
    
    [self updateContent];
}

- (NSString *)text {
    return _innerAttributedText.string;
}

- (void)setText:(NSString *)text {
    if (_text && [text isEqualToString:_text]) {
        return;
    }

    _innerAttributedText = nil;
    _text = text.copy;

    [self updateContent];
}

- (void)setFont:(UIFont *)font {
    if (_font == font) {
        return;
    }

    _font = font;
    
    if (_text) {
        [self updateContent];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor == textColor) {
        return;
    }

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
    if (_innerTruncationAttributedText && [truncationAttributedText isEqualToAttributedString:_innerTruncationAttributedText]) {
        return;
    }

    _truncationText = nil;
    _innerTruncationAttributedText = truncationAttributedText.copy;
    
    [self updateContent];
}

- (void)setTruncationText:(NSString *)truncationText {
    if (_truncationText && [truncationText isEqualToString:_truncationText]) {
        return;
    }

    _innerTruncationAttributedText = nil;
    _truncationText = truncationText.copy;

    [self updateContent];
}

- (void)setTruncationTextColor:(UIColor *)truncationTextColor {
    if (_truncationTextColor == truncationTextColor) {
        return;
    }

    _truncationTextColor = truncationTextColor;
    
    if (_truncationText) {
        [self updateContent];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_textAlignment == textAlignment) {
        return;
    }

    _textAlignment = textAlignment;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    if (_lineSpacing == lineSpacing) {
        return;
    }

    _lineSpacing = lineSpacing;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
    if (_paragraphSpacing == paragraphSpacing) {
        return;
    }

    _paragraphSpacing = paragraphSpacing;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setLineHeightMultiple:(CGFloat)lineHeightMultiple {
    if (_lineHeightMultiple == lineHeightMultiple) {
        return;
    }

    _lineHeightMultiple = lineHeightMultiple;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setParagraphSpacingBefore:(CGFloat)paragraphSpacingBefore {
    if (_paragraphSpacingBefore == paragraphSpacingBefore) {
        return;
    }

    _paragraphSpacingBefore = paragraphSpacingBefore;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_lineBreakMode == lineBreakMode) {
        return;
    }

    _lineBreakMode = lineBreakMode;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    if (_numberOfLines == numberOfLines) {
        return;
    }

    _numberOfLines = numberOfLines;

    if (_text || _truncationText) {
        [self updateContent];
    }
}

#pragma mark -

- (NSParagraphStyle *)paragraphStyle {
    _paragraphStyle.alignment = _textAlignment;
    _paragraphStyle.lineSpacing = _lineSpacing;
    _paragraphStyle.paragraphSpacing = _paragraphSpacing;
    _paragraphStyle.lineHeightMultiple = _lineHeightMultiple;
    _paragraphStyle.paragraphSpacingBefore = _paragraphSpacingBefore;

    return _paragraphStyle;
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

- (void)renderInContext:(nullable CGContextRef)context {
    if (!context) {
        return;
    }

    UIGraphicsPushContext(context);
    [self.renderer drawInContext:context bounds:self.bounds];
    UIGraphicsPopContext();
}

@end
