#import "WordPressDotComAPIClient.h"
#import "AFJSONRequestOperation.h"

#import "TTTDateTransformers.h"
#import "NSString+HTML.h"

static NSString* const kWordPressDotComAPIBaseURLString = @"https://public-api.wordpress.com/rest/v1/";

@implementation WordPressDotComAPIClient

+ (instancetype)sharedClient {
    static WordPressDotComAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString: kWordPressDotComAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

#pragma mark - AFIncrementalStore

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *) fetchRequest
                             withContext:(NSManagedObjectContext *) context {

    NSMutableURLRequest *mutableURLRequest = nil;
    NSDictionary* params = @{@"category" : @"top-stories,boston-red-sox,boston-bruins,boston-celtics,new-england-patriots"};

    if ([fetchRequest.entityName isEqualToString: @"Post"] ) {
        mutableURLRequest = [self requestWithMethod: @"GET"
                                               path: @"sites/nesn.com/posts"
                                         parameters: params];
    }

    return mutableURLRequest;
}

- (id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject {
    return [responseObject objectForKey: @"posts"];
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation 
                                     ofEntity:(NSEntityDescription *)entity 
                                 fromResponse:(NSHTTPURLResponse *)response {

    NSMutableDictionary *mutablePropertyValues = [[super
                                                   attributesForRepresentation: representation
                                                   ofEntity: entity
                                                   fromResponse: response]
                                                  mutableCopy];

    NSURL*imageURL;
    NSString* photon;
    
    // Customize the response object to fit the expected attribute keys and values

    if ([entity.name isEqualToString: @"Post"]) {
        imageURL = [NSURL URLWithString: [representation valueForKey: @"featured_image"]];
        photon = @"http://i0.wp.com/%@/%@?resize=%d,%d";

        //-- WordPress.com unique identifier
        [mutablePropertyValues setValue: [NSNumber numberWithInteger:[[representation valueForKey:@"ID"] integerValue]]
                                 forKey: @"postID"];

        //-- Date created
        [mutablePropertyValues setValue: [[NSValueTransformer
                                           valueTransformerForName: TTTISO8601DateTransformerName]
                                          reverseTransformedValue: [representation valueForKey:@"date"] ]
                                 forKey: @"createdAt"];
        //-- Date modified
        [mutablePropertyValues setValue: [[NSValueTransformer
                                           valueTransformerForName: TTTISO8601DateTransformerName]
                                          reverseTransformedValue: [representation valueForKey:@"modified"]]
                                 forKey: @"modifiedAt"];
        //-- Title
        [mutablePropertyValues setValue: [[representation valueForKey: @"title"] stringByDecodingHTMLEntities]
                                 forKey: @"title"];

        //-- Content
        [mutablePropertyValues setValue: [representation valueForKey: @"content"]
                                 forKey: @"body"];
        
        //-- Categories
        [mutablePropertyValues
         setValue: [[[representation objectForKey: @"categories"] allKeys] componentsJoinedByString: @","]
         forKey: @"categories"];

        //-- Thumbnail URL
        [mutablePropertyValues setValue: [NSString stringWithFormat: photon,
                                          imageURL.host,
                                          imageURL.relativePath,
                                          200,
                                          200
                                          ]
                                 forKey: @"thumbnailImageURL"];

        //-- 16:9 image URL
        [mutablePropertyValues setValue: [NSString stringWithFormat: photon,
                                          imageURL.host,
                                          imageURL.relativePath,
                                          558,
                                          314
                                          ]
                                 forKey: @"fullSizeImageURL"];

        //-- Post link
        [mutablePropertyValues setValue: [representation valueForKey: @"URL"]
                                 forKey: @"link"];
        //-- Author name
        [mutablePropertyValues setValue: [[representation valueForKey: @"author"]
                                          objectForKey: @"name"]
                                 forKey: @"authorName"];

    }
    
    return mutablePropertyValues;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context {
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context {
    return NO;
}

@end
