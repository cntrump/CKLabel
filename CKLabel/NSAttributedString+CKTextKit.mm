//
//  NSAttributedString+CKTextKit.m
//  CKLabel
//
//  Created by vvveiii on 2019/4/4.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import "NSAttributedString+CKTextKit.h"
#import "CKTextKitContext.h"
#import "CKTextKitAttributes.h"
#import "CKTextKitEntityAttribute.h"
#import "CKLayoutManager.h"

@implementation NSAttributedString (CKTextKit)

- (CGSize)ck_boundingSizeWithSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode maximumNumberOfLines:(NSUInteger)maximumNumberOfLines {
    __block CGSize boundingSize;
    
    CKTextKitContext *context = [[CKTextKitContext alloc] initWithAttributedString:self
                                                                     lineBreakMode:lineBreakMode
                                                              maximumNumberOfLines:maximumNumberOfLines
                                                                   constrainedSize:size
                                                              layoutManagerFactory:&CKLayoutManagerFactory];
    [context performBlockWithLockedTextKitComponents:^(NSLayoutManager *layoutManager, NSTextStorage *textStorage, NSTextContainer *textContainer) {
        boundingSize = CGRectIntegral([layoutManager usedRectForTextContainer:textContainer]).size;
    }];
    
    return boundingSize;
}

@end

@implementation NSMutableAttributedString (CKTextKit)

- (void)ck_addEntityAttribute:(id<NSObject>)entity range:(NSRange)range {
    NSParameterAssert(entity);
    
    [self addAttribute:CKTextKitEntityAttributeName value:[[CKTextKitEntityAttribute alloc] initWithEntity:entity] range:range];
}

@end
