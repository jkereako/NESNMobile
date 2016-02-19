//
//  Score.h
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Score : NSObject

extern NSUInteger const kHourInSeconds;
extern NSUInteger const kDayInSeconds;

@property (nonatomic, assign ) NSUInteger gameID;
@property (nonatomic, assign ) NSUInteger gameSequence;
@property (nonatomic, strong ) NSString *sportsLeague;
@property (nonatomic, strong ) NSString *status;
@property (nonatomic, assign ) NSUInteger homeTeamID;
@property (nonatomic, strong ) NSString *homeTeam;
@property (nonatomic, strong ) NSString *awayTeam;
@property (nonatomic, assign ) NSUInteger awayTeamID;
@property (nonatomic, assign ) NSUInteger homeTeamScore;
@property (nonatomic, assign ) NSUInteger awayTeamScore;
@property (nonatomic, strong ) NSString *gameTimeString;
@property (nonatomic, strong ) NSString *scoringString;
@property (nonatomic, strong ) NSDate *gameTime;
@property (nonatomic, strong ) NSString *nesnTeamThumbnailName;
@property (nonatomic, strong ) NSString *link;

- ( id )initWithAttributes:(NSDictionary *)attributes;
+ ( NSDictionary* ) displayRules;
+ ( NSDictionary* ) displayRulesForLeague: ( NSString* ) league;
- ( BOOL ) isGameLive;
- ( BOOL ) scoreIsValidAccordingToDisplayRules: ( Score* ) score;
- ( NSArray* ) scoresFilteredWithDisplayRules: ( NSArray* ) scores;
- ( NSString* ) stringBySanitizingJSONString: ( NSString * ) filthyJSON;
+ (void) timelineScoresWithBlock: (void (^)( NSArray *scores, NSError *error ) )block;

@end
