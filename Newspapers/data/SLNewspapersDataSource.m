//
//  SLNewspapersDataSource.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLNewspapersDataSource.h"
#import "SLCSVAggregator.h"

#define kSLNewspapersAPIBaseURLString @"http://chroniclingamerica.loc.gov/newspapers.txt"

@interface SLNewspapersDataSource () <NSURLConnectionDelegate>
@property(readwrite) BOOL loading;
@property(readwrite,strong) NSError *lastError;
@property(strong) NSURL *URL;
@property(strong) NSURLConnection *connection;
@property(readwrite,strong) NSArray *newspapers;
@property(strong) NSMutableData *data;
@end

@implementation SLNewspapersDataSource

+ (SLNewspapersDataSource*)shared
{
    static SLNewspapersDataSource *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SLNewspapersDataSource alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.connection = nil;
        self.lastError = nil;
        self.loading = NO;
        self.URL = [NSURL URLWithString:kSLNewspapersAPIBaseURLString];
        self.newspapers = [[NSArray alloc] init];
    }
    return self;
}

#pragma mark - Public Methods

- (void)refresh
{
    @synchronized(self)
    {
        if (self.loading)
        {
            return;
        }
        
        self.loading = YES;
        
        self.data = [[NSMutableData alloc] init];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [self.connection start];
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.lastError = [error copy];
    self.loading = NO;
    self.data = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSInputStream *inputStream = [[NSInputStream alloc] initWithData:self.data];
    
    SLCSVAggregator *aggregator = [[SLCSVAggregator alloc] init];
    NSStringEncoding encoding = 0;
    CHCSVParser * parser = [[CHCSVParser alloc] initWithInputStream:inputStream usedEncoding:&encoding delimiter:[@"|" characterAtIndex:0]];
    
    parser.delegate = aggregator;
    
    [parser parse];
    
    if (aggregator.error)
    {
        self.lastError = aggregator.error;
    }
    else
    {
        NSMutableArray *newspapers = [[NSMutableArray alloc] init];

        for (NSInteger i=1; i<aggregator.lines.count; i++)
        {
            NSArray *line = aggregator.lines[i];
            
            if (line.count == [SLNewspaper numberOfFields])
            {
                [newspapers addObject:[[SLNewspaper alloc] initWithArray:line]];
            }
        }

        [newspapers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *title1 = [[obj1 title] lowercaseString];
            NSString *title2 = [[obj2 title] lowercaseString];

            if ([title1 hasPrefix:@"the"])
            {
                title1 = [title1 substringFromIndex:3];
            }

            if ([title2 hasPrefix:@"the"])
            {
                title2 = [title2 substringFromIndex:3];
            }

            return [title1 compare:title2];
        }];

        self.newspapers = [NSArray arrayWithArray:newspapers];
    }
    
    self.data = nil;
    self.connection = nil;
    self.loading = NO;
}

@end
