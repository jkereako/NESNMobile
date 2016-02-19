//
//  NESNAppDelegate.h
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordPressDotComIncrementalStore.h"
#import "TTTTimeIntervalFormatter.h"
#import "GADRequest.h"
#import "GADBannerView.h"

@interface NESNAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Static properties
@property (readonly, strong, nonatomic) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (readonly, strong, nonatomic) GADRequest *googleAdRequest;

// Helpers
- (void) configureBannerView:( GADBannerView* ) bannerView forDeviceOrientation: (UIInterfaceOrientation) orientation;

- (void)saveContext;

@end
