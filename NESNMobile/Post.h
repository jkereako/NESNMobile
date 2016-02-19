//
//  Post.h
//  NESNMobile
//
//  Created by Jeff Kereakoglow on 3/12/14.
//  Copyright (c) 2014 New England Sports Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * postID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * modifiedAt;
@property (nonatomic, retain) NSString* body;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * thumbnailImageURL;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * categories;
@property (nonatomic, retain) NSString * fullSizeImageURL;

@end
