//
//  CKLayoutManager.h
//  CKLabel
//
//  Created by vvveiii on 2019/5/17.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKLayoutManager : NSLayoutManager

@property(nonatomic, assign) BOOL debugGlyph;

@end

NSLayoutManager *CKLayoutManagerFactory(void);
