//
// CSEncoding.h
// ComScore
//
// Copyright 2014 comScore, Inc. All right reserved.
//

#import <Foundation/Foundation.h>


@interface CSEncoding : NSObject {
}

+ (NSString *)urlencode:(NSString *)str;

+ (NSString *)urldecode:(NSString *)str;

+ (CSEncoding *)coder;

+ (NSArray *)escapeChars;

+ (NSArray *)replaceChars;

@end
