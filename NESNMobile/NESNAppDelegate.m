//
//  NESNAppDelegate.m
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import "NESNAppDelegate.h"

#import "AFNetworkActivityIndicatorManager.h"

//-- Analytics Headers
#import "GAI.h"
#import "CSComScore.h"
#import "QuantcastMeasurement.h"

#import "NESNShortcode.h"

static NSString* const kComScorePublisherSecret = @"95ca974d72e187cdaadd709b955aebe5";
static NSString* const kComScoreCustomerC2 = @"6783782";
static NSString* const kGoogleAnalyticsTrackingID = @"UA-5887545-14";
static NSString* const kQuantcastAPIKey = @"14ckt3wvxq0bgzk8-15cmjz2n6gfyqg70";

@implementation NESNAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURLCache *URLCache = [[NSURLCache alloc]
                            initWithMemoryCapacity: 8 * 1024 * 1024
                            diskCapacity: 20 * 1024 * 1024
                            diskPath: nil];

    [NSURLCache setSharedURLCache: URLCache];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    // The complete list of registered WordPress shortcodes for NESN.com.
    NSArray* shortcodes = @[@"embed",@"wp_caption", @"caption", @"gallery", @"playlist", @"video-playlist",
     @"audio", @"video", @"latex", @"taxonomy_image_plugin", @"acm-tag", @"nesn_embed",
     @"nesn_media_gallery", @"nesn_team_schedule", @"nesn_league_schedule",
     @"nesn_league_standings", @"nesn_league_stats", @"nesn_odds",
     @"nesn_tv_schedule", @"nesn_google_consumer_survey", @"nesn_survey_gizmo",
     @"facebook_like_button", @"facebook_send_button", @"contact-form"];

    for ( NSString *shortcode in shortcodes) {
        [[NESNShortcode sharedShortcode] registerShortCode: shortcode];
    }

    //-- Google Analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel: kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId: kGoogleAnalyticsTrackingID];

    //-- comScore
    [CSComScore setCustomerC2: kComScoreCustomerC2];
    [CSComScore setPublisherSecret: kComScorePublisherSecret];
    [CSComScore setAppContext];
    [CSComScore onUxActive];
    [CSComScore onUxInactive];
    [CSComScore enableAutoUpdate: 60 foregroundOnly: YES];

    //-- Quantcast
    [[QuantcastMeasurement sharedInstance] setupMeasurementSessionWithAPIKey: kQuantcastAPIKey
                                                              userIdentifier: nil
                                                                      labels: nil];

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // Clear the URL cache if the app is hogging too many resources.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the
    // application terminates.
    [self saveContext];
}

#pragma mark - Getters

/**
* Static getter for GADRequest.
*
* @return GADRequest
*/
- (GADRequest* ) googleAdRequest {
    static GADRequest *_googleAdRequest = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        _googleAdRequest = [GADRequest request];
        [_googleAdRequest setTestDevices: @[
                                            // Default simulator ID
                                            GAD_SIMULATOR_ID,

                                            // Jeff's 15" MacBook Pro
                                            @"273B8712-DEE8-5FB8-AEE3-C17728DB11C8",

                                            // iPad
                                            @"91c580e700a74eb8f38e9212e722611a260c6d13",

                                            // iPad 2
                                            @"388fbf8b4c2ddff3464411ae72a2e6f90114e1b4"
                                            ]];
    });

    return _googleAdRequest;
}

/**
* Static getter for TTTTimeIntervalFormatter.
*
* @return TTTTimeIntervalFormatter
*/
- (TTTTimeIntervalFormatter* ) timeIntervalFormatter {
    static TTTTimeIntervalFormatter *_timeIntervalFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        _timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        [_timeIntervalFormatter setLocale: [NSLocale currentLocale]];

        // This replaces "1 day ago" with "yesterday" and "1 week ago" with
        // "last week"
        [_timeIntervalFormatter setUsesIdiomaticDeicticExpressions: YES];
    });

    return _timeIntervalFormatter;
}

#pragma mark - Helpers
- (void) configureBannerView:( GADBannerView* ) bannerView forDeviceOrientation: (UIInterfaceOrientation) orientation {
    CGRect frame = bannerView.frame;

    if( UIInterfaceOrientationIsPortrait( orientation ) ) {
        if (50.0f == frame.size.height) {
            return;
        }
        frame.size.height = 50.0f;

        [bannerView setAdSize: kGADAdSizeSmartBannerPortrait ];


    }
    else if( UIInterfaceOrientationIsLandscape( orientation ) ) {
        if (32.0f == frame.size.height) {
            return;
        }

        frame.size.height = 32.0f;

        [bannerView setAdSize: kGADAdSizeSmartBannerLandscape ];

    }

    [bannerView setFrame: frame];
}

#pragma mark - Core Data
- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NESNMobile" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    AFIncrementalStore *incrementalStore = (AFIncrementalStore *)[_persistentStoreCoordinator addPersistentStoreWithType:[WordPressDotComIncrementalStore type] configuration:nil URL:nil options:nil error:nil];

    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"NESNMobile.sqlite"];

    NSDictionary *options = @{
        NSInferMappingModelAutomaticallyOption : @(YES),
        NSMigratePersistentStoresAutomaticallyOption: @(YES)
    };

    NSError *error = nil;
    if (![incrementalStore.backingPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

@end
