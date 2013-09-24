//
//  SLTutorial.h
//  Newspapers
//
//  Created by Aaron Brethorst on 6/23/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYIntroductionView.h"
#import "MYIntroductionPanel.h"

@interface SLTutorial : NSObject <MYIntroductionDelegate>
- (void)showTutorial:(UIWindow*)window;
@end
