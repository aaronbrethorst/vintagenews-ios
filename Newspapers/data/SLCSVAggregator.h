//
//  SLCSVAggregator.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLCSVAggregator : NSObject <CHCSVParserDelegate>
@property(readonly,strong) NSMutableArray *lines;
@property(readonly,strong) NSError *error;
@end
