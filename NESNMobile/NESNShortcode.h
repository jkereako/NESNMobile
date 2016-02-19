//
//  NESNShortcode.h
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/25/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NESNShortcodeTag,
    NESNShortcodeParameter
} NESNShortcodeComponentType;

@interface NESNParsedShortcode : NSObject
@property (readwrite, nonatomic) NSString *shortcode;
@property (readwrite, nonatomic) NSString *tag;
@property (readwrite, nonatomic) NSString *content;
@property (readwrite, nonatomic) NSDictionary *attributes;
@end

@interface NESNShortcode : NSObject

@property (readonly, nonatomic) NSString* shortcodePattern;
@property (readonly, nonatomic) NSString* attributePattern;
@property (readonly, nonatomic) NSArray* shortcodes;

+ (instancetype)sharedShortcode;

- (void) registerShortCode: ( NSString* ) shortcode;
- (NESNParsedShortcode* ) parseString: (NSString* ) string;

@end
