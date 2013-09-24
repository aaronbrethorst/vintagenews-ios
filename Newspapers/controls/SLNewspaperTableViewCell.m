//
//  SLNewspaperTableViewCell.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/23/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLNewspaperTableViewCell.h"

@implementation SLNewspaperTableViewCell

+ (CGFloat)rowHeight
{
    return 62.f;
}

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithReuseIdentifier:(NSString*)reuseIdentifier];
    if (self)
    {
        self.titleLabel.text = @"";
        self.dateLabel.text = @"";
        self.stateLabel.text = @"";
    }
    return self;
}
@end
