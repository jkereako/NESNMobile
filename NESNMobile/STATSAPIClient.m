//
//  STATSAPIClient.m
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import "STATSAPIClient.h"
#import "AFHTTPRequestOperation.h"

static NSString * const kSTATSAPIBaseURL = @"http://stats.nesn.com/";

@implementation STATSAPIClient

+ (STATSAPIClient* )sharedClient {
    static STATSAPIClient* _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        _sharedClient = [[STATSAPIClient alloc]
                         initWithBaseURL: [NSURL URLWithString: kSTATSAPIBaseURL]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];

    if (!self) {
        return nil;
    }

    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];

    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"text/html"];

    // By default, the example ships with SSL pinning enabled for the app.net API pinned against the public key of adn.cer file included with the example. In order to make it easier for developers who are new to AFNetworking, SSL pinning is automatically disabled if the base URL has been changed. This will allow developers to hack around with the example, without getting tripped up by SSL pinning.
    if ([[url scheme] isEqualToString:@"http"] && [[url host] isEqualToString:@"stats.nesn.com"]) {
        [self setDefaultSSLPinningMode: AFSSLPinningModeNone];
    }

    return self;
}

@end
