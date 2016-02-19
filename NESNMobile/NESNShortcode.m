//
//  NESNShortcode.m
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/25/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import "NESNShortcode.h"

@implementation NESNParsedShortcode
@synthesize shortcode, tag, content, attributes;

- (instancetype)init
{
    self = [super init];
    if ( !self) {
        return nil;
    }

    attributes = [NSMutableDictionary dictionary];

    return self;
}
@end

@interface NESNShortcode() {
@private
    NSMutableArray* _shortcodes;
    NSRegularExpression* _shortcodeRegex;
    NSRegularExpression* _attributeRegex;
    NESNParsedShortcode *_parsedShortcode;
}
@end

@implementation NESNShortcode

@synthesize shortcodePattern, attributePattern;

+ (instancetype)sharedShortcode {
    static NESNShortcode *_sharedShortcode = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        _sharedShortcode = [[self alloc] init];
    });

    return _sharedShortcode;
}

- (instancetype) init {
    self = [super init];

    if (!self) {
        return nil;
    }
    _parsedShortcode =[[NESNParsedShortcode alloc]  init];
    _shortcodes = [NSMutableArray array];

    NSError *error = nil;

    // Taken from WordPress
    // @see: https://github.com/WordPress/WordPress/blob/master/wp-includes/shortcodes.php#L233-L260
    shortcodePattern = @"\\[(\\[?)(%@)(?![\\w-])([^\\]\\/]*(?:\\/(?!\\])[^\\]\\/]*)*?)(?:(\\/)\\]|\\](?:([^\\[]*+(?:\\[(?!\\/\\2\\])[^\\[]*+)*+)\\[\\/\\2\\])?)(\\]?)";


    // Taken from WordPress
    // @see: https://github.com/WordPress/WordPress/blob/master/wp-includes/shortcodes.php#L308
    attributePattern = @"(\\w+)\\s*=\\s*\"([^\"]*)\"(?:\\s|$)|(\\w+)\\s*=\\s*\'([^\']*)\'(?:\\s|$)|(\\w+)\\s*=\\s*([^\\s\'\"]+)(?:\\s|$)|\"([^\"]*)\"(?:\\s|$)|(\\S+)(?:\\s|$)";


    _attributeRegex = [NSRegularExpression
                       regularExpressionWithPattern: attributePattern
                       options: NSRegularExpressionCaseInsensitive
                       error: &error];

    if ( !_attributeRegex ) {
        NSLog(@"\n Error: %@", error);
    }

    return self;
}

/**
 * A helper method which adds a shortcode represented as an NSString to an
 * array of shortcodes. WordPress uses the term "register shortcode",
 * hence the name and purpose of this helper method.
 *
 * @author Jeff Kereakoglow
 * @param NSString shortcode
 */
- (void) registerShortCode: ( NSString* ) shortcode {
    [_shortcodes addObject: shortcode];
}

/**
 * A getter method which returns the array of registered shortcodes.
 *
 * @author Jeff Kereakoglow
 * @return NSArray The array of registered shortcodes
 */
- (NSArray* ) shortcodes {
    return (NSArray* ) _shortcodes;
}

/**
 * Parses an NSString representation of a WordPress shortcode and returns a
 * collection of the shortcode's components.
 *
 * @author Jeff Kereakoglow
 * @param NSString string The shortcode
 * @param NESNParsedShortcode The shortcode string parsed into components.
 */
- (NESNParsedShortcode* ) parseString:(NSString *)string {
    [self parseString: string shortcodeComponent: NESNShortcodeTag];

    return _parsedShortcode;
}

/**
 * Parses an NSString representation of a WordPress shortcode. This method is
 * not intended to be invoked directly.
 *
 * @author Jeff Kereakoglow
 * @param NSString string The shortcode
 * @param NESNShortcodeComponentType component Indicates the shortcode component, which can either be a tag or a parameter.
 */
- (void) parseString: (NSString* ) string shortcodeComponent: (NESNShortcodeComponentType) component {
    NSError *error = nil;
    NSArray *matchGroups = nil;
    NSArray* matches = nil;
    NSRegularExpression *regex = nil;
    NSString *pattern = nil;

    switch( component ) {
        case NESNShortcodeTag:
            // Add the registered shortcodes to the shortcode pattern
            pattern = [NSString stringWithFormat: shortcodePattern,
                       [[self shortcodes] componentsJoinedByString: @"|"]  ];
            break;

        case NESNShortcodeParameter:
            // Add the registered shortcodes to the shortcode pattern
            pattern = attributePattern;
            break;
    }

    regex = [NSRegularExpression
             regularExpressionWithPattern: pattern
             options: NSRegularExpressionCaseInsensitive
             error: &error];

    if ( !regex ) {
        NSLog(@"\n Error: %@", error);
    }


    matches = [regex matchesInString: string
                             options: 0
                               range: NSMakeRange(0, [string length])];

    if ( [matches count] ) {
        matchGroups = [self helpParseMatches: matches matchText: string];

        switch( component ) {
                //-- Shortcode
                // 0 is the entire shortcode extracted from the text ([shortcode param="arg"]test text[/shortcode])
                // 2 is the shortcode tag name (i.e. "nesn_embed_service")
                // 3 are the shortcode parameters
                // 5 is the text in between the tags [shortcode]this text[/shortcode]
            case NESNShortcodeTag:
                for (NSArray *group in matchGroups) {
                    [_parsedShortcode setShortcode: [group objectAtIndex: 0] ];
                    [_parsedShortcode setTag: [group objectAtIndex: 1] ];
//                    [_parsedShortcode setContent: [group objectAtIndex: 2]];

                    [self parseString: [group objectAtIndex: 2]
                   shortcodeComponent: NESNShortcodeParameter];
                }
                break;

                //-- Parameters
                // 0 is the paramter=argument
                // 1 is the parameter
                // 2 is the argument
            case NESNShortcodeParameter:
                for (NSArray *group in matchGroups) {
                    [[_parsedShortcode attributes] setValue: [group objectAtIndex: 2]
                                                     forKey: [group objectAtIndex: 1]];

                }

                break;
        }
    }

    // NSLog(@"%@", _parsedShortcode);
}


- (NSArray* ) helpParseMatches: (NSArray* ) matches matchText: (NSString* ) matchText {
    NSUInteger i = 0;
    NSUInteger limit = 0;
    NSRange group;
    NSMutableArray *groups = nil;
    NSMutableArray *stack = nil;

    for ( NSTextCheckingResult *match  in matches) {
        limit = [match numberOfRanges];

        for ( i = 0; i != limit; ++i ) {
            group = [match rangeAtIndex: i ];

            if ( group.length ) {
                // Lazy initialization
                if (! groups) {
                    groups = [NSMutableArray array];

                }
                [groups addObject: [matchText substringWithRange: group]];
            }
        }

        if (! stack) {
            stack = [NSMutableArray array];
        }

        [stack addObject: groups];
        groups = nil;
    }

    return stack;
}

/**
 * Parses a parameters and arguments of a  shortcode.
 *
 * @author Jeff Kereakoglow
 * @param NSString parameterString The string of parameters to parse
 */
- (void) parseParameters: (NSString* ) parameterString {

}
@end
