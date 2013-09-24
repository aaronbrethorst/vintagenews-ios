//
//  SLPDFLoader.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/23/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLPDFLoader.h"

@interface SLPDFLoader ()
@property(strong) AFHTTPRequestOperation *operation;
@end

@implementation SLPDFLoader

- (void)downloadPDF:(NSURL*)URL progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{

    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [self.operation setDownloadProgressBlock:progressBlock];
    [self.operation setCompletionBlockWithSuccess:success failure:failure];
    [self.operation start];
}

- (void)cancel
{
    [self.operation cancel];
}

@end
