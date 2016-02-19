//
//  NESNTimelineViewController.m
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NESNAppDelegate.h"
#import "NESNTimelineViewController.h"

#import "Score.h"
#import "Post.h"
#import "TimelineTableViewCell.h"

// Categories
#import "UIImageView+AFNetworking.h"
#import "NSDate-Utilities.h"

@interface NESNTimelineViewController () <NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_fetchedResultsController;

// Only instance variables, colloquially known as "ivars", can appear under the
// compiler directive, @private.
@private
    NESNAppDelegate* _appDelegate;
    NSString* _cacheKey;
    BOOL _hasNESNArticles;
    NSArray* _scores;
    NSDate* _lastSynchronization;
}

// IBOutlet stands for "Interface Builder outlet". It's a way to connect the code to
// Interface Builder (IB)
@property (nonatomic, weak) IBOutlet UITableView  *aTableView;
@property (nonatomic, weak) IBOutlet GADBannerView  *bottomBanner;

- (void) reloadData:(__unused id)sender;
- (void) refetchPosts:(__unused id)sender;
- (void) reloadScores:(__unused id)sender;

@end

static NSUInteger const kSynchronizationIntervalInMinutes = 5;
static NSString* const kTopBannerAdUnitID = @"ca-app-pub-3361410694315698/5903379992";

@implementation NESNTimelineViewController
/**
 * Helper method to reload all data WordPress post and scoring data.
 *
 * @author Jeff Kereakoglow
 * @param id sender
 */
- (void) reloadData: (__unused id ) sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;

    [self reloadScores: nil];

    // Limit the number of times the user updates stories from NESN.com.
    if ( _lastSynchronization ) {
        if ( kSynchronizationIntervalInMinutes > [_lastSynchronization minutesBeforeDate: [NSDate date]] ) {
            NSLog(@"\n  Did not synchronize with NESN.com.\n");
            return;
        }
    }

    [self refetchPosts: nil];
    _lastSynchronization = [NSDate date];
}

/**
 * Pings http://stats.nesn.com/mobile_scores.js.asp to retrieve scoring
 * information
 *
 * @author Jeff Kereakoglow
 * @param id sender
 */
- (void)reloadScores:(__unused id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;

    [Score timelineScoresWithBlock: ^(NSArray *scores, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString( @"Error", nil)
                                        message: [error localizedDescription]
                                       delegate: nil
                              cancelButtonTitle: nil
                              otherButtonTitles: NSLocalizedString( @"OK", nil), nil] show];
        }
        else {
            // Filter the scores so that the score corresponds to the team.
            for ( Score* score in scores ) {
                if ( [score.nesnTeamThumbnailName isEqualToString: self.title ] ) {
                    _scores = [NSArray arrayWithObject: score];
                    break;
                }
            }

            // Show all scores if the user is on the home page (Top Stories).
            if( ! _scores && [@"Top Stories" isEqualToString: self.title ] ) {
                _scores = scores;
            }

            [self.aTableView reloadData];
        }

        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];

}

/**
 * Fetches WordPress posts from local storage, and if conditions are met,
 * download more.
 *
 * @author Jeff Kereakoglow
 * @param id sender
 */
- (void) refetchPosts:(__unused id)sender {
    [_fetchedResultsController performSelectorOnMainThread: @selector( performFetch: )
                                                withObject: nil
                                             waitUntilDone: YES
                                                     modes: @[ NSRunLoopCommonModes ]];
}

#pragma mark - UIViewController
- (void) awakeFromNib {
    if (!_appDelegate) {
        _appDelegate = (NESNAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
}

- (void) viewWillAppear: (BOOL)animated {
    [super viewWillAppear: animated];

    // i.e. "Boston Red Sox index", "New England Patriots index"
    self.screenName = [NSString stringWithFormat: @"%@ index", self.title];

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    [_appDelegate configureBannerView: self.bottomBanner
                 forDeviceOrientation: orientation];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self configureNavigationLogoForDeviceOrientation: orientation];

    _cacheKey = [NSString stringWithFormat: @"PostTimeLine%@", self.title];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName: @"Post"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:
                                    [NSSortDescriptor sortDescriptorWithKey: @"modifiedAt"
                                                                  ascending: NO ] ];
    // Retrieve the latest 20 stories only
    fetchRequest.fetchLimit = 15;

    // Filter the fetch request by category. In this case, the category is 1 of
    // the 4 major teams.
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"categories CONTAINS %@",
                                 self.title ] ];


    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest: fetchRequest
                                 managedObjectContext: [(id)[[UIApplication sharedApplication] delegate] managedObjectContext] sectionNameKeyPath: nil
                                 cacheName: _cacheKey];

    _fetchedResultsController.delegate = self;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                              target: self
                                              action: @selector(reloadData:)];

    // Ad Mob boilerplate
    [self.bottomBanner setDelegate: self];
    [self.bottomBanner setRootViewController: self];
    [self.bottomBanner setAdUnitID: kTopBannerAdUnitID ];
    [self.bottomBanner loadRequest: [_appDelegate googleAdRequest]];
    [self reloadData: nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];


    [_appDelegate configureBannerView: self.bottomBanner
                 forDeviceOrientation: toInterfaceOrientation];

    [self configureNavigationLogoForDeviceOrientation: toInterfaceOrientation];

}

//#pragma mark - UITabbarDelegate
//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
//    NSLog(@"Selected....");
//}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionsCount = 0;

    if (_scores) {
        sectionsCount = 1;
    }
    return sectionsCount + [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    NSInteger rowCount = 0;

    switch (section) {
        case 0:
            if ( _scores) {
                rowCount = [_scores count];
                break;
            }

        case 1:
            _hasNESNArticles = YES;
            rowCount = [[[_fetchedResultsController sections] objectAtIndex: 0] numberOfObjects];

            if ( 0 == rowCount) {
                rowCount = 1;
                _hasNESNArticles = NO;
            }
            break;
    }

    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    TimelineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    if (cell == nil) {
        cell = [[TimelineTableViewCell alloc]
                initWithStyle: UITableViewCellStyleDefault
                reuseIdentifier: CellIdentifier];
    }

    [self configureCell: cell atIndexPath: indexPath];

    return cell;
}

- (void) configureCell: (UITableViewCell *)cell atIndexPath:(NSIndexPath *) indexPath {

    switch (indexPath.section) {
        case 0:
            if ( _scores ) {
                @try {
                    if ( [ (Score*)[_scores objectAtIndex: [indexPath row] ] isGameLive ] ) {
                        [(TimelineTableViewCell *)cell setExtraText: NSLocalizedString( @"Live", nil)];
                    }

                    [(TimelineTableViewCell *)cell setScore: (Score *) [_scores objectAtIndex: [indexPath row] ]];

                }
                @catch (NSException *exception) {
                    [[(TimelineTableViewCell *)cell extraTextLabel] setHidden: YES];
                    NSLog( @"Exception: %@", exception);
                }

              break;
            }


        case 1:
            if ( ! _hasNESNArticles ) {
                cell.textLabel.text = NSLocalizedString( @"No articles available.", nil);
                cell.detailTextLabel.text = NSLocalizedString( @"Try again in a few minutes.", nil);
                cell.imageView.image = [UIImage imageNamed: self.title ];
            }
            else {
                @try {
                    [[(TimelineTableViewCell *)cell extraTextLabel] setHidden: YES];
                    [(TimelineTableViewCell *)cell setPost: (Post *) [_fetchedResultsController
                                                                      objectAtIndexPath: [NSIndexPath
                                                                                          indexPathForRow:indexPath.row
                                                                                          inSection:0]
                                                                      ]
                     ];
                }
                @catch (NSException *exception) {
                    NSLog( @"Exception: %@", exception);
                }
            }


            break;
    }
}

#pragma mark - UITableViewDelegate
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 0:
            sectionName = NSLocalizedString( @"Scores", nil);
            break;
        case 1:
            sectionName = NSLocalizedString( @"Articles", nil);
            break;
    }
    return sectionName;
}
*/

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    // Returning plain-ol' 0 forces iOS to use the default spacing, so we need
    // to approximate 0 the best we can.
    return 0.0001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = 70.0f;

    if ( ! _hasNESNArticles) {
        return rowHeight;
    }

    switch (indexPath.section) {
        case 0:
            // Return a row height of 70.0 only if there are scores available.
            if (_scores) {
                break;
            }
        case 1:
            rowHeight = [TimelineTableViewCell
                         heightForCellWithPost: [_fetchedResultsController
                                                 objectAtIndexPath: [NSIndexPath
                                                                     indexPathForRow: indexPath.row
                                                                     inSection: 0]]];
            ;
            break;
    }

    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath: indexPath animated: YES ];
    Post* post;

    switch (indexPath.section) {
        case 0:
            if ( _scores ) {

                [[[UIActionSheet alloc] initWithTitle:  ((Score *) [_scores objectAtIndex: [indexPath row] ]).link
                                             delegate: self
                                    cancelButtonTitle: NSLocalizedString( @"Cancel", nil)
                               destructiveButtonTitle: nil
                                    otherButtonTitles: NSLocalizedString( @"Open link in browser", nil), nil]
                 showInView:self.view];
                break;
            }

        default:
            post = (Post* ) [_fetchedResultsController
                                   objectAtIndexPath:
                                   [NSIndexPath indexPathForRow: indexPath.row
                                                      inSection: 0]];

            dispatch_async(
                           dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^(void) {
                               //Background Thread
                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString: post.link]];
                           });
            break;
    }

}


#pragma mark - NSFetchedResultsControllerDelegate

- (void) controllerDidChangeContent: ( NSFetchedResultsController* ) controller {
    [self.aTableView reloadData];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: actionSheet.title]];
}

#pragma mark - GADBannerViewDelegate
- (void) adViewDidReceiveAd: (GADBannerView *)bannerView {
    [UIView beginAnimations: @"BannerSlide" context: nil];

    bannerView.frame = CGRectMake( 0.0,
                                  self.view.frame.size.height - (self.tabBarController.tabBar.frame.size.height + bannerView.frame.size.height),
                                  bannerView.frame.size.width,
                                  bannerView.frame.size.height);

    [bannerView setHidden: NO];

    [UIView commitAnimations];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    [bannerView setHidden: YES];
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}

#pragma mark - Helpers

/**
 * Displays a NESN ticket logo on the navigation bar configured for device
 * orientation.
 *
 * @author Jeff Kereakoglow
 * @param UIInterfaceOrientation orientation
 */
- (void) configureNavigationLogoForDeviceOrientation: (UIInterfaceOrientation) orientation {
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Navigation Bar Landscape Logo"]];
            break;

        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Navigation Bar Portrait Logo"]];
            break;

        // Does nothing, but prevents a warning from appearing.
        default:
            break;
    }
}

/**
 * Displays a Google advertisement configured for device orientation.
 *
 * @author Jeff Kereakoglow
 * @param UIInterfaceOrientation orientation
 * @param GADBannerView bannerView
 */
- (void) configureBannerView:( GADBannerView* ) bannerView forDeviceOrientation: (UIInterfaceOrientation) orientation {
    CGRect frame = self.bottomBanner.frame;

    if( UIInterfaceOrientationIsPortrait( orientation ) ){
        frame.size.height = 50.0f;

        [self.bottomBanner setAdSize: kGADAdSizeSmartBannerPortrait ];


    }
    else if( UIInterfaceOrientationIsLandscape( orientation ) ){
        frame.size.height = 32.0f;

        [self.bottomBanner setAdSize: kGADAdSizeSmartBannerLandscape ];

    }

    [self.bottomBanner setFrame: frame];
}

@end
