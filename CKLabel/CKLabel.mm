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
#import "CKLayoutManager.h"

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
    CKTextKitCommonAttributes _commonAttrs;
    NSMutableParagraphStyle *_paragraphStyle;
    BOOL _needUpdate;
    CGRect _innerBounds;
    NSMutableArray<UIAccessibilityElement *> *_accessibleElements;
}

@property(nonatomic, readonly) CKTextComponentLayer *textLayer;

@property(nonatomic, strong) CKTextKitRenderer *innerRenderer;

@end

@implementation CKLabel

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; baseClass: %@; frame:(%lf %lf, %lf %lf); layer= <%@: %p>; '%@'>",
            NSStringFromClass(self.class), self, NSStringFromClass(self.superclass),
            CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame),
            NSStringFromClass(self.layer.class), self.layer,
            _innerAttributedText ? _innerAttributedText.string : _text];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _innerBounds = self.bounds;
        _needUpdate = YES;
        _font = [UIFont systemFontOfSize:17];
        _textColor = UIColor.blackColor;
        _textAlignment = NSTextAlignmentNatural;
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

    self.renderer = self.innerRenderer;
}

- (CGSize)sizeThatFits:(CGSize)size {
    [super sizeThatFits:size];

    if (self.attributedText.length == 0) {
        return CGSizeZero;
    }

    NSLineBreakMode lineBreakMode = _lineBreakMode;
    if (_lineBreakMode == NSLineBreakByWordWrapping || _lineBreakMode == NSLineBreakByCharWrapping) {
        lineBreakMode = NSLineBreakByTruncatingTail;
    }

    CKTextKitCommonAttributes commonAttrs;
    commonAttrs.lineBreakMode = lineBreakMode;
    commonAttrs.maximumNumberOfLines = _numberOfLines;
    commonAttrs.truncationAttributedString = self.truncationAttributedText;
    commonAttrs.attributedString = self.attributedText;
    commonAttrs.layoutManagerFactory = &CKLayoutManagerFactory;

    __block CGRect usedRect = CGRectZero;
    CKTextKitRenderer *renderer = [[CKTextKitRenderer alloc] initWithTextKitAttributes:commonAttrs constrainedSize:size];
    [renderer.context performBlockWithLockedTextKitComponents:^(NSLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        (void)[layoutManager glyphRangeForTextContainer:textContainer];
        usedRect = [layoutManager usedRectForTextContainer:textContainer];
    }];

    return CGRectIntegral(usedRect).size;
}

- (CGSize)intrinsicContentSize {
    [super intrinsicContentSize];

    if (_preferredMaxLayoutWidth > 0 && _numberOfLines != 1) {
        return [self sizeThatFits:CGSizeMake(_preferredMaxLayoutWidth, INFINITY)];
    }

    CGFloat w = CGRectGetWidth(self.bounds) ? : INFINITY;
    
    return [self sizeThatFits:CGSizeMake(w, INFINITY)];
}

#pragma mark - getter

- (CKTextKitRenderer *)innerRenderer {
    if (!_innerRenderer || !CGRectEqualToRect(_innerBounds, self.bounds) || _needUpdate) {
        _commonAttrs.lineBreakMode = _lineBreakMode;
        _commonAttrs.maximumNumberOfLines = _numberOfLines;
        _commonAttrs.truncationAttributedString = self.truncationAttributedText;
        _commonAttrs.attributedString = self.attributedText;
        _commonAttrs.layoutManagerFactory = &CKLayoutManagerFactory;

        _innerRenderer = [[CKTextKitRenderer alloc] initWithTextKitAttributes:_commonAttrs
                                                              constrainedSize:CGSizeMake(CGRectGetWidth(self.bounds), INFINITY)];
        _innerBounds = self.bounds;
        _needUpdate = NO;

        UIAccessibilityElement *element = [self.accessibleElements objectAtIndex:0];
        element.accessibilityValue = self.attributedText.string;
    }

    return _innerRenderer;
}

- (NSRange)visibleCharacterRange {
    std::vector<NSRange> visibleRanges = self.innerRenderer.visibleRanges;
    NSRange visibleCharacterRange = NSMakeRange(NSNotFound, 0);

    size_t len = visibleRanges.size();
    for (size_t i = 0; i < len; i++) {
        NSRange r = visibleRanges[i];

        if (visibleCharacterRange.location == NSNotFound) {
            visibleCharacterRange.location = r.location;
        }

        visibleCharacterRange.length += r.length;
    }

    return visibleCharacterRange;
}

#pragma mark - setter

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    CGFloat width = CGRectGetWidth(bounds);
    [self updateConstraintsIfNeeded:width];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;

    [self updateContent];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    if (_highlightColor == highlightColor) {
        return;
    }

    _highlightColor = highlightColor;
    self.textLayer.highlighter.highlightColor = _highlightColor;
}

- (NSAttributedString *)attributedText {
    if (_text && !_innerAttributedText && _needUpdate) {
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

- (NSString *)text {
    return self.attributedText.string;
}

- (void)setText:(NSString *)text {
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
    if (_truncationText && !_innerTruncationAttributedText && _needUpdate) {
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

- (void)updateConstraintsIfNeeded:(CGFloat)width {
    CGFloat maxWidth = _preferredMaxLayoutWidth;
    if (maxWidth != width) {
        _preferredMaxLayoutWidth = width;
        [self invalidateIntrinsicContentSize];
#if !TARGET_OS_OSX
        [self.superview layoutIfNeeded];
#endif
    }
}

- (void)updateContent {
    _needUpdate = YES;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NO;
    }

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

#pragma mark - UIAccessibility

- (NSArray *)accessibleElements {
    if (!_accessibleElements) {
        _accessibleElements = [[NSMutableArray alloc] init];

        UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        element.accessibilityTraits = UIAccessibilityTraitStaticText;
        [_accessibleElements addObject:element];
    }

    _accessibleElements.firstObject.accessibilityFrame = [self.superview convertRect:self.frame toView:nil];

    return _accessibleElements;
}

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSInteger)accessibilityElementCount {
    return [[self accessibleElements] count];
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return [[self accessibleElements] objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return [[self accessibleElements] indexOfObject:element];
}

@end
