//
//  UIKitSPI.h
//  CKLabel
//
//  Created by vvveiii on 2019/6/20.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#ifndef UIKitSPI_h
#define UIKitSPI_h

#import <UIKit/UIFont.h>

typedef enum {
    UIFontTraitPlain = 0,
    UIFontTraitItalic = 1 << 0,
    UIFontTraitBold = 1 << 1,
} UIFontTrait;

@interface UIFont ()

// Returns a font with specific family name, traits (bold/italic) and font size.
+ (UIFont *)fontWithFamilyName:(NSString *)familyName traits:(UIFontTrait)traits size:(CGFloat)fontSize;

// Returns the traits (bold/italic) of the font.
- (UIFontTrait)traits;

// Returns whether the font is monospaced or not.
- (BOOL)isFixedPitch;

// Create a font using a CSS font description.
+ (UIFont *)fontWithMarkupDescription:(NSString*)markupDescription;

// Returns the CSS rules that can reproduce this font.
- (NSString *)markupDescription;

@end

#endif /* UIKitSPI_h */
