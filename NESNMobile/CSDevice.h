//
//  CSDevice.h
//  comScore
//
// Copyright 2014 comScore, Inc. All right reserved.
//

#import <Foundation/Foundation.h>

@interface CSDevice : NSObject

+ (BOOL)gcdAvailable;

+ (NSString *)ssid;

+ (NSString *)topViewControllerName;

@end
