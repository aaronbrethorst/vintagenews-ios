//
//  SLNewspaperIssue.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLNewspaperIssue.h"

NSDateFormatter *formatter = nil;

@interface SLNewspaperIssue ()
@property(readwrite,strong) NSArray *pdfURLs;
@property(readwrite,strong) NSArray *pages;
@end

@implementation SLNewspaperIssue

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];

    if (self)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd";
        });

        self.dateIssued = [formatter dateFromString:dict[@"date_issued"]];
        self.URL = [NSURL URLWithString:dict[@"url"]];
    }

    return self;
}

- (NSURL*)thumbnailURL
{
    return [NSURL URLWithString:[self.URL.absoluteString.stringByDeletingPathExtension stringByAppendingString:@"/seq-1/thumbnail.jpg"]];
}

- (void)synchronizeData:(void(^)())block
{
    if (!self.pages || self.pages.count == 0)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

            self.pages = JSON[@"pages"];

            NSMutableArray *pdfURLs = [NSMutableArray array];
            for (NSDictionary *dict in self.pages)
            {
                NSString *url = dict[@"url"];
                NSString *pdfURL = [[url stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
                [pdfURLs addObject:[NSURL URLWithString:pdfURL]];
            }

            self.pdfURLs = [NSArray arrayWithArray:pdfURLs];

            block();
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"%@", error);
            block();
        }];
        [operation start];
    }
    else
    {
        block();
    }
}
@end
