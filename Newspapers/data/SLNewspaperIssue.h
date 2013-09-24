//
//  SLNewspaperIssue.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLNewspaperIssue : NSObject

@property(strong) NSDate *dateIssued;
@property(strong) NSURL *URL;
@property(readonly, strong) NSArray *pages;
@property(readonly, strong) NSArray *pdfURLs;

- (id)initWithDictionary:(NSDictionary*)dict;
- (void)synchronizeData:(void(^)())block;
- (NSURL*)thumbnailURL;
@end
