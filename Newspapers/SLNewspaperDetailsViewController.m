//
//  SLDetailViewController.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLNewspaperDetailsViewController.h"
#import "SLIssueViewController.h"
#import "GAI.h"

@interface SLNewspaperDetailsViewController ()
@property(strong) UILabel *emptyLabel;
@property NSDateFormatter *formatter;
@property BOOL loaded;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation SLNewspaperDetailsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateStyle = NSDateFormatterLongStyle;
        self.formatter.timeStyle = NSDateFormatterNoStyle;
    }
    return self;
}

- (void)dealloc
{
    [_newspaper removeObserver:self forKeyPath:@"issues"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setupEmptyLabel];
    
    [self showPopover];
    
    [self configureView];
}

- (void)setupEmptyLabel
{
    self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.view.center.y)];
    self.emptyLabel.font = [UIFont boldSystemFontOfSize:24.f];
    self.emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [UIColor colorWithRed:(51.f/255.f) green:(51.f/255.f) blue:(51.f/255.f) alpha:1.f];
    self.emptyLabel.text = NSLocalizedString(@"Choose a newspaper to get started.", @"");
    [self.view addSubview:self.emptyLabel];
}

- (void)showPopover
{
    UIBarButtonItem *btn = self.navigationItem.leftBarButtonItem;
    id target = btn.target;
    SEL action = btn.action;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [target performSelector:action withObject:btn];
#pragma clang diagnostic pop
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [[[GAI sharedInstance] defaultTracker] sendView:NSStringFromClass([self class])];

    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Newspaper"
                        withAction:@"View"
                         withLabel:self.newspaper.title
                         withValue:@(1)];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _newspaper)
    {
        if ([keyPath isEqual:@"issues"])
        {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Managing the detail item

- (void)setNewspaper:(id)newNewspaper
{
    if (_newspaper != newNewspaper)
    {
        [_newspaper removeObserver:self forKeyPath:@"issues"];
        [newNewspaper addObserver:self forKeyPath:@"issues" options:0 context:NULL];
        
        _newspaper = newNewspaper;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        [self.emptyLabel removeFromSuperview];
        
        self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ (%d issues)", @""), _newspaper.title, _newspaper.numberOfIssues];
        
        [self configureView];

        self.loaded = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(showLoader) userInfo:nil repeats:NO];

        SLNewspaperDetailsViewController *weakSelf = self;
        [self.newspaper synchronizeData:^{
            weakSelf.loaded = YES;
            [SVProgressHUD dismiss];
            [weakSelf.tableView reloadData];
        }];
    }

    if (self.masterPopoverController != nil)
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)showLoader
{
    if (!self.loaded)
    {
        [SVProgressHUD show];
    }
}

- (void)configureView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.tableView.contentOffset = CGPointMake(0, 0);
    [self.tableView reloadData];
    
    if (self.newspaper)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"About", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(about)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Actions

- (void)about
{
    SVModalWebViewController *modalWeb = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:self.newspaper.moreInfo]];
    [self.navigationController presentViewController:modalWeb animated:YES completion:nil];
}

#pragma mark - UITableView

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.newspaper.sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = self.newspaper.sectionTitles.count;
    return count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.newspaper.sectionTitles[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSNumber *sectionTitle = self.newspaper.sectionTitles[section];
    NSInteger count = [self.newspaper.sectionedIssues[sectionTitle] count];
    return count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    NSNumber *sectionTitle = self.newspaper.sectionTitles[indexPath.section];
    SLNewspaperIssue *issue = self.newspaper.sectionedIssues[sectionTitle][indexPath.row];

    cell.textLabel.text = [self.formatter stringFromDate:issue.dateIssued];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *sectionTitle = self.newspaper.sectionTitles[indexPath.section];
    SLNewspaperIssue *issue = self.newspaper.sectionedIssues[sectionTitle][indexPath.row];

    SLIssueViewController *issueViewController = [[SLIssueViewController alloc] init];
    issueViewController.issue = issue;
    [self.navigationController pushViewController:issueViewController animated:YES];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Newspapers", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
