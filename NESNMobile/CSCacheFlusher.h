//
//  CSCacheFlusher.h
//  comScore
//
// Copyright 2014 comScore, Inc. All right reserved.
//

#import <Foundation/Foundation.h>

@class CSCore;

@interface CSCacheFlusher : NSObject {
    CSCore *_core;
    NSTimer *_timer;
    bool _isForeground;
}

- (id)initWithCore:(CSCore *)aCore;

- (void)start;

- (void)stop;

- (void)reset;
@end