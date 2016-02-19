//
//  NESNTimelineViewController.h
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "GAITrackedViewController.h"

@interface NESNTimelineViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, GADBannerViewDelegate>



- (void) configureNavigationLogoForDeviceOrientation: (UIInterfaceOrientation) orientation;
- (void) configureBannerView:( GADBannerView* ) bannerView forDeviceOrientation: (UIInterfaceOrientation) orientation;

@end