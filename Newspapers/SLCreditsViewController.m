//
//  SLCreditsViewController.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/24/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLCreditsViewController.h"

@interface SLCreditsViewController ()

@end

@implementation SLCreditsViewController

- (id)init
{
    self = [super initWithNibName:@"SLCreditsViewController" bundle:nil];

    if (self)
    {
        self.title = NSLocalizedString(@"About and Credits", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(close)];

    NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];

    [self.webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[NSBundle mainBundle].bundlePath]];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
