//
//  SLNewspaper.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLNewspaperIssue.h"

@interface SLNewspaper : NSObject
@property(strong) NSString *persistentLink;
@property(strong) NSString *state;
@property(strong) NSString *title;
@property(strong) NSString *lccn;
@property(strong) NSString *oclc;
@property(strong) NSString *issn;
@property NSInteger numberOfIssues;
@property(strong) NSDate *firstIssueDate;
@property(strong) NSDate *lastIssueDate;
@property(strong) NSString *moreInfo;
@property(readonly,strong) NSArray *issues;
@property(readonly,strong) NSDictionary *sectionedIssues;
@property(readonly,strong) NSArray *sectionTitles;
+ (NSUInteger)numberOfFields;
- (id)initWithArray:(NSArray*)array;

- (NSURL*)detailsURL;
- (void)synchronizeData:(void(^)())block;
@end
