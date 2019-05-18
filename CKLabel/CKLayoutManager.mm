//
//  CKLayoutManager.m
//  CKLabel
//
//  Created by vvveiii on 2019/5/17.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import "CKLayoutManager.h"

#define RGB(rgb) [UIColor colorWithRed:(((rgb) & 0xff0000) >> 16) / 255.0 green:(((rgb) & 0xff00) >> 8) / 255.0 blue:((rgb) & 0xff) / 255.0 alpha:1]

@implementation CKLayoutManager

- (instancetype)init {
    if (self = [super init]) {
        self.delegate = self;
    }

    return self;
}
#if DEBUG
- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];

    if (_debugGlyph) {
        CGFloat dx = origin.x;
        CGFloat dy = origin.y;
        NSTextContainer *textContainer = self.textContainers.firstObject;

        CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(graphicsContext);
        UIBezierPath *path = [UIBezierPath bezierPath];

        for (NSUInteger i = glyphsToShow.location; i < NSMaxRange(glyphsToShow); i++) {
            [self enumerateEnclosingRectsForGlyphRange:NSMakeRange(i, 1) withinSelectedGlyphRange:NSMakeRange(i, 1) inTextContainer:textContainer usingBlock:^(CGRect rect, BOOL * _Nonnull stop) {
                rect = CGRectOffset(rect, dx, dy);
                [path appendPath:[UIBezierPath bezierPathWithRect:rect]];
            }];
        }

        [RGB(0xe6ffed) setFill];
        [path fill];
        [RGB(0xacf2bd) setStroke];
        [path stroke];

        CGContextRestoreGState(graphicsContext);
    }
}
#endif

#pragma mark - NSLayoutManagerDelegate

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldSetLineFragmentRect:(inout CGRect *)lineFragmentRect
 lineFragmentUsedRect:(inout CGRect *)lineFragmentUsedRect baselineOffset:(inout CGFloat *)baselineOffset
      inTextContainer:(NSTextContainer *)textContainer forGlyphRange:(NSRange)glyphRange {
    NSInteger characterIndex = [layoutManager characterIndexForGlyphAtIndex:glyphRange.location];
    NSParagraphStyle *paragraphStyle = [layoutManager.textStorage attribute:NSParagraphStyleAttributeName atIndex:characterIndex effectiveRange:NULL];
    CGFloat lineSpacing = paragraphStyle.lineSpacing;
    CGFloat lineHeightMultiple = 1;
    if (paragraphStyle.lineHeightMultiple != 0) {
        lineHeightMultiple = paragraphStyle.lineHeightMultiple;
    }

    CGFloat baseline = *baselineOffset;
    CGFloat height = (*lineFragmentRect).size.height;
    CGFloat usedHeight = (*lineFragmentUsedRect).size.height;

    BOOL isFirstLine = NO;
    if (glyphRange.location == 0) {
        isFirstLine = YES;
    }

    CGFloat glyphHeight = (usedHeight - lineSpacing) / lineHeightMultiple;
    CGFloat glyphBaseline = baseline - (usedHeight - glyphHeight) + lineSpacing;

    if (isFirstLine) {
        *baselineOffset = glyphBaseline;
        (*lineFragmentRect).size.height = height - (baseline - glyphBaseline);
        (*lineFragmentUsedRect).size.height = usedHeight - (baseline - glyphBaseline);
    } else {
        *baselineOffset = baseline;
        (*lineFragmentRect).size.height = height;
        (*lineFragmentUsedRect).size.height = usedHeight;
    }

    return YES;
}

@end

NSLayoutManager *CKLayoutManagerFactory(void) {
    CKLayoutManager *layoutManager = [[CKLayoutManager alloc] init];
#if DEBUG
    layoutManager.debugGlyph = YES;
#endif
    return layoutManager;
}
