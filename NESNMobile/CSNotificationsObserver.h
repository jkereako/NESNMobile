//
//  CSNotificationsObserver.h
//  comScore
//
// Copyright 2014 comScore, Inc. All right reserved.
//

#import <Foundation/Foundation.h>
#import "CSCore.h"

@interface CSNotificationsObserver : NSObject {
@protected
    CSCore *_core;
    BOOL _inForeground;
}

- (id)initWithCore:(CSCore *)aCore;

- (void)applicationWillCrash:(NSException *)exception;

@end
