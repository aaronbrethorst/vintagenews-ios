//
//  SLMasterViewController.m
//  Newspapers
//
//  Created by Aaron Brethorst on 6/22/13.
//  Copyright (c) 2013 Structlab. All rights reserved.
//

#import "SLNewspapersViewController.h"
#import "SLNewspaperDetailsViewController.h"
#import "SLNewspapersDataSource.h"
#import "SLNewspaperTableViewCell.h"
#import "SLCreditsViewController.h"
#import "GAI.h"

@interface SLNewspapersViewController ()
@property(strong) NSDateFormatter *formatter;
@property(strong) NSArray *searchResults;
@end

@implementation SLNewspapersViewController

- (id)init
{
    self = [super initWithNibName:@"SLNewspapersViewController" bundle:nil];
    if (self)
    {
        self.title = NSLocalizedString(@"Newspapers", @"");
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.dateFormat = @"yyyy";
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
        
        [self setupKVO];
    }
    return self;
}

- (void)setupKVO
{
    [[SLNewspapersDataSource shared] addObserver:self forKeyPath:@"loading" options:0 context:NULL];
    [[SLNewspapersDataSource shared] addObserver:self forKeyPath:@"newspapers" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [SLNewspapersDataSource shared])
    {
        if ([keyPath isEqual:@"loading"])
        {
            //
        }
        else if ([keyPath isEqual:@"newspapers"])
        {
            [self.tableView reloadData];
        }
    }
}

- (void)dealloc
{
    [[SLNewspapersDataSource shared] removeObserver:self forKeyPath:@"loading"];
    [[SLNewspapersDataSource shared] removeObserver:self forKeyPath:@"newspapers"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"About", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(about)];
    
    [[SLNewspapersDataSource shared] refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[[GAI sharedInstance] defaultTracker] sendView:NSStringFromClass([self class])];
}

- (void)about
{
    SLCreditsViewController *credits = [[SLCreditsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:credits];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UISearchDisplayController/UISearchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.title CONTAINS[cd] %@ OR self.state CONTAINS[cd] %@", searchText, searchText];
    self.searchResults = [[SLNewspapersDataSource shared].newspapers filteredArrayUsingPredicate:predicate];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Search"
                                                      withAction:@"View"
                                                       withLabel:self.searchBar.text
                                                       withValue:@(1)];

}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat wtf = [SLNewspaperTableViewCell rowHeight];
        
    return wtf;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        return [SLNewspapersDataSource shared].newspapers.count;
    }
    else
    {
        return self.searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLNewspaperTableViewCell *cell = [SLNewspaperTableViewCell cellForTableView:tableView];

    SLNewspaper *newspaper = nil;

    if (tableView == self.tableView)
    {
        newspaper = [SLNewspapersDataSource shared].newspapers[indexPath.row];
    }
    else
    {
        newspaper = self.searchResults[indexPath.row];
    }

    cell.titleLabel.text = newspaper.title;
    cell.stateLabel.text = newspaper.state;
    cell.dateLabel.text = [NSString stringWithFormat:@"%@-%@", [self.formatter stringFromDate:newspaper.firstIssueDate], [self.formatter stringFromDate:newspaper.lastIssueDate]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLNewspaper *newspaper = nil;

    if (tableView == self.tableView)
    {
        newspaper = [SLNewspapersDataSource shared].newspapers[indexPath.row];
    }
    else
    {
        newspaper = self.searchResults[indexPath.row];
    }

    if (self.searchBar.isFirstResponder)
    {
        [self.searchBar resignFirstResponder];
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
	    if (!self.detailViewController)
        {
	        self.detailViewController = [[SLNewspaperDetailsViewController alloc] init];
	    }
	    self.detailViewController.newspaper = newspaper;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    else
    {
        self.detailViewController.newspaper = newspaper;
    }
}

@end
