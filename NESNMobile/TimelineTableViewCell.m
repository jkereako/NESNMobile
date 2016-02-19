//
//  PostTableViewCell.m
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "TimelineTableViewCell.h"
#import "Post.h"
#import "Score.h"

#import "UIImageView+AFNetworking.h"
#import "NESNAppDelegate.h"

@implementation TimelineTableViewCell {
@private
    NESNAppDelegate* _appDelegate;
    __strong Post*_post;
    __strong Score* _score;
    __strong NSString* _extraText;
}

@synthesize imageView, textLabel, detailTextLabel, extraTextLabel;
@synthesize post = _post;
@synthesize score = _score;
@synthesize extraText = _extraText;

-(void)awakeFromNib{
    if (!_appDelegate) {
         _appDelegate = (NESNAppDelegate *)[[UIApplication sharedApplication] delegate];
    }

    self.imageView.layer.masksToBounds = YES;

    [self.imageView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [self.imageView.layer setBorderWidth: 1.0];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];

    if ( !self ) {
        return nil;
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 * Sets extra text
 *
 * @author Jeff Kereakoglow
 * @param NSString extraText
 */
- (void)setExtraText: (NSString*) extraText {
    _extraText = extraText;
    self.extraTextLabel.text = _extraText;
    [self.extraTextLabel setHidden: NO];

    [self setNeedsLayout];
}

/**
 * Sets a WordPress post.
 *
 * @author Jeff Kereakoglow
 * @param Post post The WordPress post object
 */
- (void)setPost: (Post*) post {
    _post = post;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    self.textLabel.text = _post.title;
    self.detailTextLabel.text = [[_appDelegate timeIntervalFormatter]
                                 stringForTimeIntervalFromDate: [NSDate date]
                                 toDate: _post.modifiedAt];

    [self.imageView setImageWithURL: [ NSURL URLWithString: _post.thumbnailImageURL]
                   placeholderImage: [ UIImage imageNamed: @"UITableViewCell Placeholder" ]];

    [self setNeedsLayout];
}

/**
 * Sets a score. lol.
 *
 * @author Jeff Kereakoglow
 * @param Score score
 */
- (void)setScore: (Score*) score {
    _score = score;

    self.accessoryType = UITableViewCellAccessoryNone;

    self.textLabel.text = _score.scoringString;
    self.detailTextLabel.text = _score.gameTimeString;

    [self.imageView setImage: [UIImage imageNamed: _score.nesnTeamThumbnailName]];
    [self setNeedsLayout];
}

+ (CGFloat)heightForCellWithPost:(Post *)post {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGSize sizeToFit = [post.title sizeWithFont: [UIFont systemFontOfSize: 17.0f] constrainedToSize:CGSizeMake(219.0f, CGFLOAT_MAX)
                                  lineBreakMode: NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    return fmaxf(70.0f, (float)sizeToFit.height + 45.0f);
}

#pragma mark - UIView
- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect detailTextLabelFrame, extraTextLabelFrame = CGRectMake(0.0, 0.0, 0.0, 0.0);
    CGFloat cellHeight = 70.0f;
    CGSize extraTextSize = CGSizeMake(0.0, 0.0);

    // For cells that don't have a disclosure indicator...
    if ( UITableViewCellAccessoryNone == self.accessoryType ) {
        detailTextLabelFrame = CGRectOffset(self.textLabel.frame, 0.0f, 18.0f);

        if (_extraText) {
            extraTextLabelFrame = detailTextLabelFrame;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            extraTextSize = [_extraText sizeWithFont: [UIFont systemFontOfSize: 12.0f] constrainedToSize:CGSizeMake(219.0f, CGFLOAT_MAX)
                                       lineBreakMode: NSLineBreakByWordWrapping];
#pragma clang diagnostic pop

            detailTextLabelFrame = CGRectOffset(detailTextLabelFrame, extraTextSize.width + 5.0f, 0.0f);
        }


    }

    else {
        cellHeight = [[self class] heightForCellWithPost: _post];
        detailTextLabelFrame = CGRectOffset(self.textLabel.frame, 0.0f, 25.0f);

        if ( cellHeight > 120 ) {
            detailTextLabelFrame = CGRectOffset(detailTextLabelFrame, 0.0f, 8.0f);
        }
    }

    detailTextLabelFrame.size.height = cellHeight;

    self.detailTextLabel.frame = detailTextLabelFrame;

    if (! CGRectIsEmpty( extraTextLabelFrame ) ) {
        extraTextLabelFrame.size.height = cellHeight;
        self.extraTextLabel.frame = extraTextLabelFrame;
    }
}

@end
