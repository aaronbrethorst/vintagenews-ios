//
//  SLNewspaperTableViewCell.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/23/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLTableViewCell.h"

@interface SLNewspaperTableViewCell : SLTableViewCell
@property(nonatomic,strong) IBOutlet UILabel *titleLabel;
@property(nonatomic,strong) IBOutlet UILabel *stateLabel;
@property(nonatomic,strong) IBOutlet UILabel *dateLabel;
@end
