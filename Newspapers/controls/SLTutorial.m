//
//  SLTutorial.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/23/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLTutorial.h"

@implementation SLTutorial

- (void)showTutorial:(UIWindow*)window
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HideTutorial"])
    {
        return;
    }
    
    MYIntroductionView *introductionView = [[MYIntroductionView alloc] initWithFrame:window.bounds headerImage:nil panels:@[self.panel2, self.panel3]];
    introductionView.delegate = self;


    [introductionView showInView:window];
}

- (void)introductionDidFinishWithType:(MYFinishType)finishType
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HideTutorial"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (MYIntroductionPanel*)panel2
{
    NSString *desc = NSLocalizedString(@"This app provides a view into public domain data from newspapers from the mid 19th century through to the early 20th century through the Library of Congress' Chronicling America project.", @"");
    return [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"example.jpg"] description:desc];
}

- (MYIntroductionPanel*)panel3
{
    NSString *desc = NSLocalizedString(@"Thanks for your interest, and I hope you like the project. If you have any questions or feedback, please email me at aaron@structlab.com.", @"");
    return [[MYIntroductionPanel alloc] initWithimage:[UIImage imageNamed:@"thumbs_up"] description:desc];
}
@end
