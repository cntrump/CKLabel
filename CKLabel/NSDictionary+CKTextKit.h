//
//  NSDictionary+CKTextKit.h
//  CKLabel
//
//  Created by vvveiii on 2019/4/4.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CKTextKit)

- (id<NSObject>)ck_entityAttribute;

@end

@interface NSMutableDictionary (CKTextKit)

- (void)ck_addEntity:(id<NSObject>)entity;

@end
