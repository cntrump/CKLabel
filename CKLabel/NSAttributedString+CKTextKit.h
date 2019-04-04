//
//  NSAttributedString+CKTextKit.h
//  CKLabel
//
//  Created by vvveiii on 2019/4/4.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import <UIKit/NSStringDrawing.h>
#import <UIKit/NSParagraphStyle.h>

@interface NSAttributedString (CKTextKit)

- (CGSize)ck_boundingSizeWithSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode maximumNumberOfLines:(NSUInteger)maximumNumberOfLines;

@end

@interface NSMutableAttributedString (CKTextKit)

- (void)ck_addEntityAttribute:(id<NSObject>)entity range:(NSRange)range;

@end
