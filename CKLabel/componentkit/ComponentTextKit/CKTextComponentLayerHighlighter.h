/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

const NSRange CKTextComponentLayerInvalidHighlightRange = { NSNotFound, 0 };

@class CKTextComponentLayer;

@interface CKTextComponentLayerHighlighter : NSObject

- (instancetype)initWithTextComponentLayer:(CKTextComponentLayer *)textComponentLayer;

@property (nonatomic, assign) NSRange highlightedRange;

@property (nonatomic, strong) UIColor *highlightColor;

- (void)layoutHighlight;

@end
