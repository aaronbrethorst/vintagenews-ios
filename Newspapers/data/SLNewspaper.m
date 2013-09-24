//
//  SLNewspaper.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLNewspaper.h"

static NSArray *dateFormatters = nil;
static NSRegularExpression *titleRegex = nil;

@interface SLNewspaper ()
@property(readwrite,strong) NSDictionary *sectionedIssues;
@property(readwrite,strong) NSArray *sectionTitles;
@property(readwrite,strong) NSArray *issues;
@end

@implementation SLNewspaper

+ (void)configureHelpers
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titleRegex = [NSRegularExpression regularExpressionWithPattern:@"(.*)\\. \\(.*\\).*" options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSDateFormatter *f1 = [[NSDateFormatter alloc] init];
        f1.dateFormat = @"MMM. dd, yyyy";
        
        NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
        f2.dateFormat = @"MMMM dd, yyyy";
        
        NSDateFormatter *f4 = [[NSDateFormatter alloc] init];
        f4.dateFormat = @"MMM't'. dd, yyyy";
        
        dateFormatters = @[f1,f2,f4];
    });
}

+ (NSUInteger)numberOfFields
{
    return 10;
}

- (id)initWithArray:(NSArray *)array
{
    self = [super init];
    
    if (self)
    {
        [SLNewspaper configureHelpers];
        
        self.persistentLink = [array[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.state = [array[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.title = [array[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].capitalizedString;
        self.lccn = [array[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.oclc = [array[4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.issn = [array[5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.numberOfIssues = [array[6] integerValue];
        
        NSString *firstIssueString = [array[7] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastIssueString = [array[8] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        for (NSDateFormatter *f in dateFormatters)
        {
            if (!self.firstIssueDate)
            {
                self.firstIssueDate = [f dateFromString:firstIssueString];
            }
            
            if (!self.lastIssueDate)
            {
                self.lastIssueDate = [f dateFromString:lastIssueString];
            }
        }
        
        self.moreInfo = [array[9] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        self.title = [self.title stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];

        [titleRegex enumerateMatchesInString:self.title options:0 range:NSMakeRange(0, self.title.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            self.title = [self.title substringWithRange:[result rangeAtIndex:1]];
        }];
    }
    
    return self;
}

- (NSURL*)detailsURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://chroniclingamerica.loc.gov/lccn/%@.json", self.lccn]];
}

- (void)synchronizeData:(void(^)())block
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.detailsURL];
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *issues = [NSMutableArray array];

        for (NSDictionary *dict in JSON[@"issues"])
        {
            SLNewspaperIssue *issue = [[SLNewspaperIssue alloc] initWithDictionary:dict];
            [issues addObject:issue];
        }
        self.issues = [NSArray arrayWithArray:issues];

        NSMutableDictionary *sectionedIssues = [NSMutableDictionary dictionary];

        for (SLNewspaperIssue *issue in self.issues)
        {
            NSString * year = [NSString stringWithFormat:@"%d",[[[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:issue.dateIssued] year]];

            NSMutableArray *array = sectionedIssues[year];
            if (!array)
            {
                array = [NSMutableArray array];
                sectionedIssues[year] = array;
            }

            [array addObject:issue];
        }

        self.sectionedIssues = [NSDictionary dictionaryWithDictionary:sectionedIssues];
        self.sectionTitles = [self.sectionedIssues.allKeys sortedArrayUsingSelector:@selector(compare:)];

        block();
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", error);
        block();
    }];
    [operation start];
}

- (NSString*)description
{
    NSDictionary *dict = @{@"Persistent link": self.persistentLink,
                           @"state": self.state,
                           @"title": self.title,
                           @"LCCN": self.lccn,
                           @"OCLC": self.oclc,
                           @"ISSN": self.issn,
                           @"Number of Issues": @(self.numberOfIssues),
                           @"First issue date": self.firstIssueDate,
                           @"Last issue date": self.lastIssueDate,
                           @"More info": self.moreInfo};
    
    return [dict description];
}
@end
