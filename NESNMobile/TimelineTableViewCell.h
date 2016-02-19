//
//  PostTableViewCell.h
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post, Score;

@interface TimelineTableViewCell : UITableViewCell
@property (nonatomic, strong) Score *score;
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) NSString *extraText;

// Interface Builder outlets
@property (nonatomic, retain) IBOutlet UIImageView  *imageView;
@property (nonatomic, retain) IBOutlet UILabel  *textLabel;
@property (nonatomic, retain) IBOutlet UILabel  *detailTextLabel;
@property (nonatomic, retain) IBOutlet UILabel  *extraTextLabel;

+ (CGFloat) heightForCellWithPost: (Post* ) post;

@end
