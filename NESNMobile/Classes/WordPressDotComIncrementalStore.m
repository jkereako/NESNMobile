#import "WordPressDotComIncrementalStore.h"
#import "WordPressDotComAPIClient.h"

@implementation WordPressDotComIncrementalStore

+ (void)initialize {
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
    return NSStringFromClass(self);
}

+ (NSManagedObjectModel *)model {
    return [[NSManagedObjectModel alloc]
            initWithContentsOfURL:[[NSBundle mainBundle]
                                   URLForResource: @"WordPressDotCom"
                                   withExtension: @"xcdatamodeld"]];
}

- (id <AFIncrementalStoreHTTPClient>)HTTPClient {
    return [WordPressDotComAPIClient sharedClient];
}

@end