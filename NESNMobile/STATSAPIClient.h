//
//  STATSAPIClient.h
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface STATSAPIClient : AFHTTPClient

+ ( STATSAPIClient* )sharedClient;

@end
