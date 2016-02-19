#import "AFIncrementalStore.h"
#import "AFRestClient.h"

@interface WordPressDotComAPIClient : AFRESTClient <AFIncrementalStoreHTTPClient>

+ (WordPressDotComAPIClient *)sharedClient;

@end
