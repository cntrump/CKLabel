//
//  NSDictionary+CKTextKit.m
//  CKLabel
//
//  Created by vvveiii on 2019/4/4.
//  Copyright © 2019 vvveiii. All rights reserved.
//

#import "NSDictionary+CKTextKit.h"
#import "CKTextKitAttributes.h"
#import "CKTextKitEntityAttribute.h"

@implementation NSDictionary (CKTextKit)

- (id<NSObject>)ck_entityAttribute {
    return static_cast<CKTextKitEntityAttribute *>(self[CKTextKitEntityAttributeName]).entity;
}

@end

@implementation NSMutableDictionary (CKTextKit)

- (void)ck_addEntity:(id<NSObject>)entity {
    if (entity) {
        self[CKTextKitEntityAttributeName] = [[CKTextKitEntityAttribute alloc] initWithEntity:entity];
    } else {
        [self removeObjectForKey:CKTextKitEntityAttributeName];
    }
}

@end
