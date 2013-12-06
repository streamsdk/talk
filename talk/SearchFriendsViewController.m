//
//  SearchFriendsViewController.m
//  talk
//
//  Created by wangsh on 13-12-6.
//  Copyright (c) 2013年 wangshuai. All rights reserved.
//

#import "SearchFriendsViewController.h"

#define SEARCH_TAG 1000
@interface SearchFriendsViewController ()

@end

@implementation SearchFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Add Friends";
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];

    UISearchBar * searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width-60, 50)];
    [searchBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    searchBar.delegate = self;
    searchBar.tag =SEARCH_TAG;
    searchBar.barStyle=UIBarStyleDefault;
    searchBar.placeholder=@"search";
    searchBar.keyboardType=UIKeyboardTypeNamePhonePad;
    [self.view addSubview:searchBar];
    
    UIButton * cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancel setFrame:CGRectMake(0, 64, 60, 50)];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelSelected) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancel];
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {

}
-(void) cancelSelected {
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
