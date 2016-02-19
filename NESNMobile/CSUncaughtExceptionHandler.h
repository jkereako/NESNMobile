//
// CSUncaughtExceptionHandler.h
// comScore
//
// Copyright 2014 comScore, Inc. All right reserved.
//

#import <UIKit/UIKit.h>

@interface CSUncaughtExceptionHandler : NSObject {
    BOOL _dismissed;
}

+ (NSString *)parseCall:(NSString *)call;

@end

void CSInstallUncaughtExceptionHandler();
