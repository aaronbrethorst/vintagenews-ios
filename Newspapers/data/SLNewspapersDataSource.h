//
//  SLNewspapersDataSource.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLNewspaper.h"

@interface SLNewspapersDataSource : NSObject
@property(readonly) BOOL loading;
@property(strong,readonly) NSError *lastError;
@property(readonly,strong) NSArray *newspapers;
+ (SLNewspapersDataSource*)shared;
- (void)refresh;
@end
