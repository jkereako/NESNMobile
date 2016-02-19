//
//  Score.m
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import "Score.h"
#import "NSDate-Utilities.h"
#import "STATSAPIClient.h"
#import "NESNAppDelegate.h"

@implementation Score{
@private
    NESNAppDelegate* _appDelegate;
}


@synthesize gameID, gameSequence, sportsLeague, status, homeTeamID, homeTeam, homeTeamScore;
@synthesize gameTimeString, gameTime, awayTeamID, awayTeam, awayTeamScore;
@synthesize scoringString, nesnTeamThumbnailName, link;

static NSString* const kKeyRank = @"rank";
static NSString* const kKeyFutureBoundary = @"future";
static NSString* const kKeyPastBoundary = @"past";
static NSString* const kKeyShowInCategories = @"categories";


// Game
static NSString* const kSTATSKeyLeague = @"league";
static NSString* const kSTATSKeyGameID = @"game_ID";
static NSString* const kSTATSKeyGameNumber = @"game_number";
static NSString* const kSTATSKeyGameStatus = @"game_status";
static NSString* const kSTATSKeyGameTime = @"time_text";
static NSString* const kSTATSKeyGameYear = @"game_year";
static NSString* const kSTATSKeyGameMonth = @"game_month";
static NSString* const kSTATSKeyGameDay = @"game_day";
static NSString* const kSTATSKeyGameHour = @"game_hour";
static NSString* const kSTATSKeyGameMinute = @"game_minute";
// Home team
static NSString* const kSTATSKeyHomeTeamID = @"home_ID";
static NSString* const kSTATSKeyHomeTeamName = @"home_name";
static NSString* const kSTATSKeyHomeTeamNameAbbreviation = @"home_name_abbr";
static NSString* const kSTATSKeyHomeTeamScore = @"home_score";
// Away team
static NSString* const kSTATSKeyAwayTeamID = @"away_ID";
static NSString* const kSTATSKeyAwayTeamName = @"away_name";
static NSString* const kSTATSKeyAwayTeamNameAbbreviation = @"away_name_abbr";
static NSString* const kSTATSKeyAwayTeamScore = @"away_score";

- (instancetype) initWithAttributes:( NSDictionary *)attributes {
    self = [super init];

    if ( !self ) {
        return nil;
    }

    if (!_appDelegate) {
        _appDelegate = (NESNAppDelegate *)[[UIApplication sharedApplication] delegate];
    }

    @autoreleasepool {
        NSDateComponents *comps = nil;
        NSCalendar *cal = nil;
        NSDate* statsDate = nil;
        NSDateFormatter* statsDateFormat = nil;
        NSDateFormatter* nesnDateFormat = nil;

        @try {

            // Calculate official game time as an NSDate
            comps = [[NSDateComponents alloc] init];


            [comps setDay: [[ attributes valueForKeyPath: kSTATSKeyGameDay ] integerValue] ];
            [comps setMonth: [[ attributes valueForKeyPath: kSTATSKeyGameMonth ] integerValue] ];
            [comps setYear: [[ attributes valueForKeyPath: kSTATSKeyGameYear ]  integerValue] ];
            [comps setHour: [[ attributes valueForKeyPath: kSTATSKeyGameHour ] integerValue] ];
            [comps setMinute: [[ attributes valueForKeyPath: kSTATSKeyGameMinute ] integerValue] ];
            [comps setSecond: 0 ];

            cal = [NSCalendar currentCalendar];

            // MEMORY LEAK
            self.gameTime = [cal dateFromComponents: comps];

            self.gameID = (NSUInteger) [ [ attributes valueForKeyPath: kSTATSKeyGameID ] integerValue ];
            self.gameSequence = (NSUInteger) [ [ attributes valueForKeyPath: kSTATSKeyGameNumber ] integerValue ];
            self.sportsLeague = [ attributes valueForKeyPath: kSTATSKeyLeague ];
            self.status = [ attributes valueForKeyPath: kSTATSKeyGameStatus ];
            self.homeTeam = [ attributes valueForKeyPath: kSTATSKeyHomeTeamNameAbbreviation ];
            self.homeTeamID = (NSUInteger) [[ attributes valueForKeyPath: kSTATSKeyHomeTeamID ] integerValue];
            self.awayTeam = [ attributes valueForKeyPath: kSTATSKeyAwayTeamNameAbbreviation ];
            self.awayTeamID = (NSUInteger) [[ attributes valueForKeyPath: kSTATSKeyAwayTeamID ] integerValue];

            if ([[ attributes valueForKeyPath: kSTATSKeyAwayTeamScore ]
                 isEqual: [NSNull null] ] &&
                [[ attributes valueForKeyPath: kSTATSKeyHomeTeamScore ]
                 isEqual: [NSNull null] ]
                ) {
                self.homeTeamScore = -1;
                self.awayTeamScore = -1;

                self.scoringString = [NSString
                                      stringWithFormat: NSLocalizedString( @"Pre-game score format", nil),
                                      self.awayTeam,
                                      self.homeTeam];

            }
            else {
                self.homeTeamScore = (NSUInteger) [[ attributes valueForKeyPath: kSTATSKeyHomeTeamScore ] integerValue];
                self.awayTeamScore = (NSUInteger) [[ attributes valueForKeyPath: kSTATSKeyAwayTeamScore ] integerValue];

                self.scoringString = [NSString
                                      stringWithFormat: NSLocalizedString( @"In-game score format", nil),
                                      self.awayTeam,
                                      self.awayTeamScore,
                                      self.homeTeam,
                                      self.homeTeamScore];
            }

            self.gameTimeString = [ attributes valueForKeyPath: kSTATSKeyGameTime ];

            // Date formatting

            statsDateFormat = [[NSDateFormatter alloc] init];

            [statsDateFormat setDateFormat: NSLocalizedString( @"STATS general date format", nil)];

            // Append the current year to the date string.
            statsDate = [statsDateFormat dateFromString:
                         [NSString stringWithFormat:@"%@ %ld",
                          self.gameTimeString,
                          (long)comps.year ] ];

            // Can we parse the string? If so, the game has not started yet.
            if ( statsDate  ) {

                nesnDateFormat = [[NSDateFormatter alloc] init];
                [nesnDateFormat setDateFormat: NSLocalizedString( @"General date format", nil)];

                if ([statsDate isTomorrow]) {
                    [nesnDateFormat setDateFormat: NSLocalizedString( @"Tomorrow date format", nil)];
                }


                self.gameTimeString = [nesnDateFormat stringFromDate: statsDate];
            }

            [statsDateFormat setDateFormat: NSLocalizedString( @"STATS today date format", nil)];

            statsDate = [statsDateFormat dateFromString: self.gameTimeString];

            // Can we parse the string? If so, the game is happening today.
            if ( statsDate  ) {
                comps = [cal components:(NSHourCalendarUnit)
                              fromDate:statsDate];

                nesnDateFormat = [[NSDateFormatter alloc] init];

                if ( [comps hour] > 17 ) {
                     [nesnDateFormat setDateFormat:
                      NSLocalizedString( @"Tonight date format", nil)];
                }
                else{
                    [nesnDateFormat setDateFormat:
                     NSLocalizedString( @"Today date format", nil)];
                }

                self.gameTimeString = [nesnDateFormat stringFromDate: statsDate];
            }

            if ( [NSLocalizedString( @"STATS postponed", nil) isEqualToString: self.gameTimeString ] ) {
                self.gameTimeString = NSLocalizedString( @"Postponed", nil);
            }

            self.nesnTeamThumbnailName = nil;

        }
        @catch (NSException *exception) {
        }
        @finally {
            cal = nil;
            comps = nil;
        }
    }


    return self;
}

- (void) dealloc {
    self.gameTime = nil;
    self.awayTeam = nil;
    self.homeTeam = nil;
    self.gameTimeString = nil;
    self.status = nil;
    self.scoringString = nil;
}

/**
 * Creates a string representation of a Score object.
 *
 * @author Jeff Kereakoglow
 * @param Score score
 * @return BOOL
 */
- (NSString *)description {

    return [NSString stringWithFormat: @"\n Game ID: %lu\n League: %@\n Game status = %@\n Home team: %@\n Home team ID: %lu\n Away team: %@\n Away team Id: %lu\n Home team socre: %lu\n Away team score: %lu\n Game time string: %@\n Scoring string: %@",
            (unsigned long)self.gameID,
            self.sportsLeague,
            self.status,
            self.homeTeam,
            (unsigned long)self.homeTeamID,
            self.awayTeam,
            (unsigned long)self.awayTeamID,
            (unsigned long)self.homeTeamScore,
            (unsigned long)self.awayTeamScore,
            self.gameTimeString,
            self.scoringString];
}

/**
 * Defines display rules for the scores.
 *
 * @author Jeff Kereakoglow
 * @return NSDictionary* The display rules
 */
+ (NSDictionary*) displayRules {
    static NSDictionary* displayRules = nil;

    if ( nil == displayRules ) {
        displayRules = @{
                         @"mlb": @{
                                 kKeyRank : @0,
                                 kKeyShowInCategories: @[ @"Red Sox" ],
                                 // 1 day
                                 kKeyFutureBoundary : [NSNumber numberWithInteger: D_DAY],
                                 // 15 hours
                                 kKeyPastBoundary : [NSNumber numberWithInteger: -( D_HOUR * 15 ) ]
                                 },
                         @"nhl": @{
                                 kKeyRank : @1,
                                 kKeyShowInCategories: @[ @"Bruins" ],
                                 // 6 Days
                                 kKeyFutureBoundary : [ NSNumber numberWithInteger: D_DAY * 6 ],
                                 // 18 Hours
                                 kKeyPastBoundary : [ NSNumber numberWithInteger: -( D_HOUR * 18 ) ]
                                 },
                         @"nfl": @{
                                 kKeyRank : @2,
                                 kKeyShowInCategories: @[ @"Patriots" ],
                                 // 4 days
                                 kKeyFutureBoundary : [ NSNumber numberWithInteger: D_DAY * 4 ],
                                 // 1 day
                                 kKeyPastBoundary : [ NSNumber numberWithInteger: -D_HOUR ]
                                 },
                         @"nba": @{
                                 kKeyRank : @3,
                                 kKeyShowInCategories: @[ @"Celtics" ],
                                 // 2 days
                                 kKeyFutureBoundary : [ NSNumber numberWithInteger: D_DAY * 2 ],
                                 //18 hours
                                 kKeyPastBoundary : [ NSNumber numberWithInteger: -( D_HOUR * 18 ) ]
                                 },
                         @"mls": @{
                                 kKeyRank : @4,
                                 kKeyShowInCategories: @[ @"Soccer" ],
                                 // 1 hour
                                 kKeyFutureBoundary : [ NSNumber numberWithInteger: D_HOUR ],
                                 // 4 hours
                                 kKeyPastBoundary : [ NSNumber numberWithInteger: -( D_HOUR * 4 ) ]
                                 },
                         @"epl": @{
                                 kKeyRank : @5,
                                 kKeyShowInCategories: @[ @"Soccer" ],
                                 // 1 day
                                 kKeyFutureBoundary : [ NSNumber numberWithInteger: D_DAY ],
                                 // 18 hours
                                 kKeyPastBoundary : [ NSNumber numberWithInteger: -( D_HOUR * 18 ) ]
                                 },
                         @"eng_fa_cup": @{
                                 kKeyRank : @6,
                                 kKeyShowInCategories: @[ @"Soccer" ],
                                 // 1 day
                                 kKeyFutureBoundary : [ NSNumber numberWithInteger: D_DAY ],
                                 // 18 hours
                                 kKeyPastBoundary : [ NSNumber numberWithInteger: -( D_HOUR * 18 ) ]
                                 }
                         };
    }

    return displayRules;
}

- ( BOOL ) isGameLive {
    return NO;
}

/**
 * Cleans the JSON string coming from http://stats.nesn.com/mobile_scores.js.asp.
 * Wraps all of the keys and values in quotes, removes leading zeroes from
 * integers and removes the JavaScript variable, "var nesnTeams".
 *
 * @author Jeff Kereakoglow
 * @param NSString* filthyJSON
 * @return NSString* The cleaned JSON string
 */
- ( NSString* ) stringBySanitizingJSONString:( NSString * ) filthyJSON {
    // Create your expression
    NSString *cleanedJSON = nil;

    @autoreleasepool {
        // Remove the variable assignment.
        cleanedJSON = [filthyJSON stringByReplacingOccurrencesOfString: @"var nesnTeams = "
                                                            withString: @""];
        // Remove the final semi colon
        cleanedJSON = [cleanedJSON stringByReplacingOccurrencesOfString: @"}];"
                                                             withString: @"}]"];

        // Replace single quotes
        cleanedJSON = [cleanedJSON stringByReplacingOccurrencesOfString: @"'"
                                                             withString: @"\""];

        // Wrap the keys in single quotes
        cleanedJSON = [cleanedJSON stringByReplacingOccurrencesOfString: @"([a-zA-Z_]+)\\s*:"
                                                             withString: @"\"$1\":"
                                                                options: NSRegularExpressionSearch
                                                                  range: NSMakeRange( 0, [cleanedJSON length] )];

        // Remove leading zeroes of game_hour, game_minute and game_second.
        cleanedJSON = [cleanedJSON stringByReplacingOccurrencesOfString: @"0(\\d),"
                                                             withString: @"$1,"
                                                                options: NSRegularExpressionSearch
                                                                  range: NSMakeRange(0, [cleanedJSON length])];


        // Replace empty strings with null
        cleanedJSON = [cleanedJSON stringByReplacingOccurrencesOfString: @"\"\""
                                                             withString: @"null"];
    }


    return cleanedJSON;
}

/**
 * Validates a score against the defined display rules.
 *
 * @author Jeff Kereakoglow
 * @param Score score
 * @return BOOL
 */
- ( BOOL ) scoreIsValidAccordingToDisplayRules: ( Score* ) score {
    NSDictionary* displayRules = nil;
    NSDate* currentDate = [ NSDate date ];
    NSInteger p = 0;
    NSInteger f = 0;
    BOOL returnValue = NO;

    displayRules = [Score displayRulesForLeague: score.sportsLeague ];
    f =  [[ displayRules valueForKey: kKeyFutureBoundary ] integerValue ];
    p =  [[ displayRules valueForKey: kKeyPastBoundary ] integerValue ];

    // @see: http://webd.fr/637-comparer-deux-nsdate
    // Read: "If score.gameTime is later than currentDate plus f..."
    if ( [score.gameTime compare: [currentDate dateByAddingTimeInterval: p ] ] == NSOrderedDescending &&
        // Read: "If score.gameTime is earlier than currentDate plus f..."
        [score.gameTime compare: [currentDate dateByAddingTimeInterval: f ] ] == NSOrderedAscending ) {
        returnValue = YES;
    }

    displayRules = nil;
    currentDate = nil;

    return returnValue;
}

/**
 * Filters an array of Score objects using the display rules,
 *
 * @author Jeff Kereakoglow
 * @param NSArray* The unfiltered scores
 * @return NSArray* The filtered scores
 */
- ( NSArray* ) scoresFilteredWithDisplayRules: ( NSArray* ) scores {
    NSDictionary* displayRules = [Score displayRules];
    NSDate* currentDate = [NSDate date];
    NSInteger p = 0;
    NSInteger f = 0;
    NSMutableArray *mutableScores = [ NSMutableArray arrayWithCapacity: [ scores count ] ];

    for ( Score *score in scores) {
        displayRules = [Score displayRulesForLeague: score.sportsLeague ];
        f =  [[displayRules valueForKey: kKeyFutureBoundary] integerValue ];
        p =  [[displayRules valueForKey: kKeyPastBoundary] integerValue ];

        // @see: http://webd.fr/637-comparer-deux-nsdate
        // Read: "If score.gameTime is later than currentDate plus f..."
        if ( [score.gameTime compare: [currentDate dateByAddingTimeInterval: p ] ] == NSOrderedDescending &&
            // Read: "If score.gameTime is earlier than currentDate plus f..."
            [score.gameTime compare: [currentDate dateByAddingTimeInterval: f ] ] == NSOrderedAscending ) {
            [ mutableScores addObject: score ];

        }

    }

    displayRules = nil;
    currentDate = nil;

    return mutableScores;
}

/**
 * Returns the display rules for a specific league.
 *
 * @author Jeff Kereakoglow
 * @param NSString* The name of the league
 * @return NSDictionary* The display rules for that league.
 */
+( NSDictionary* ) displayRulesForLeague: ( NSString* ) league {
    NSDictionary* displayRules = [self displayRules];

    return [displayRules valueForKey: league];
}



/**
 * Makes an HTTP request to http://stats.nesn.com/mobile_scores.js.asp and
 * downlaods scoring information for the 4 Boston teams as well as the New
 * England Revolution and the Liverpool Football Club. The incoming data is
 * invalid JSON, so the data is first cleaned and then it is parsed. Finally, the
 * scoring data is filtered by removing games which have already passed by
 * several days or will not occur in several days.
 *
 * @author Jeff Kereakoglow
 * @param code block
 */
+ (void) timelineScoresWithBlock: (void (^)( NSArray *scores, NSError *error ) )block {
    [[STATSAPIClient sharedClient] getPath: @"mobile_scores.js.asp"
                                parameters: nil
                                   success: ^( AFHTTPRequestOperation* __unused operation, id data) {
                                       NSArray *scores = nil;
                                       NSMutableArray *filteredScores = nil;
                                       NSArray *sortedScores = nil;
                                       NSError *error = nil;
                                       Score *score = [[Score alloc] init];

                                       if ( [ data isKindOfClass:[ NSData class ] ] ) {
                                           // Create your expression
                                           NSString *string = [[NSMutableString alloc]
                                                               initWithData: data
                                                               encoding: NSUTF8StringEncoding];

                                           // MEMORY LEAK
                                           string = [score stringBySanitizingJSONString: string];

                                           // MEMORY LEAK
                                           scores = [NSJSONSerialization JSONObjectWithData: [string dataUsingEncoding: NSUTF8StringEncoding]
                                                                                    options: NSJSONReadingMutableContainers
                                                                                      error: &error];

                                           //                      NSLog(@"%@", error);
                                           string = nil;
                                           score = nil;
                                       }

                                       // MEMORY LEAK
                                       filteredScores = [NSMutableArray arrayWithCapacity:[ scores count ]];

                                       for ( NSDictionary *attributes in scores) {
                                           score = [[Score alloc] initWithAttributes: attributes];

                                           if ( [score scoreIsValidAccordingToDisplayRules: score ] ) {

                                               if ( [@"mlb" isEqualToString: score.sportsLeague ]) {
                                                   score.nesnTeamThumbnailName = @"Boston Red Sox";
                                                   score.link = @"http://mobile.stats.nesn.com/mlb/mlb_teams.aspx?id=2";
                                               }

                                               else if ( [@"nhl" isEqualToString: score.sportsLeague ]) {
                                                   score.nesnTeamThumbnailName = @"Boston Bruins";
                                                   score.link = @"http://mobile.stats.nesn.com/nhl/nhl_teams.aspx?id=2";
                                               }

                                               else if ( [@"nfl" isEqualToString: score.sportsLeague ]) {
                                                   score.nesnTeamThumbnailName = @"New England Patriots";
                                                   score.link = @"http://mobile.stats.nesn.com/nfl/nfl_teams.aspx?id=17";
                                               }

                                               else if ( [@"nba" isEqualToString: score.sportsLeague ]) {
                                                   score.nesnTeamThumbnailName = @"Boston Celtics";
                                                   score.link = @"http://mobile.stats.nesn.com/nba/nba_teams.aspx?id=2";
                                               }

                                               else if ( [@"epl" isEqualToString: score.sportsLeague ]) {
                                                   score.nesnTeamThumbnailName = @"Liverpool Football Club";
                                                   score.link = @"http://stats.nesn.com/epl/teamstats.asp?team=32";
                                               }

                                               [ filteredScores addObject: score ];
                                           }

                                           score = nil;

                                       }

                                       sortedScores = [filteredScores sortedArrayUsingComparator:
                                                       ^NSComparisonResult( Score* a, Score* b) {
                                                           NSNumber *first = [[Score displayRulesForLeague: a.sportsLeague ]
                                                                              objectForKey: kKeyRank];
                                                           NSNumber *second = [[Score displayRulesForLeague: b.sportsLeague ]
                                                                               objectForKey: kKeyRank];

                                                           return [first compare: second];
                                                       }];

                                       filteredScores = nil;
                                       score = nil;
                                       scores = nil;

                                       if ( block ) {
                                           block( sortedScores, nil);
                                       }
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if (block) {
                                           block([NSArray array], error);
                                       }
                                   }];
}

@end
