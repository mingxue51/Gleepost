//
//  GLPMessageDetailsViewController.m
//  Gleepost
//
//  Created by Silouanos on 18/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPMessageDetailsViewController.h"
#import "GLPMessageDetailsSegmentCell.h"
#import "GLPNameTimestampCell.h"
#import "GLPMessageCell.h"
#import "UINavigationBar+Format.h"
#import "GLPConversationRead.h"
#import "TableViewHelper.h"

@interface GLPMessageDetailsViewController () <GLPMessageDetailsSegmentCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *finalReads;
@property (assign, nonatomic) ButtonType buttonType;

@property (strong, nonatomic, readonly) NSString *readHeaderMessage;
@property (strong, nonatomic, readonly) NSString *deliveredHeaderMessage;

@end

@implementation GLPMessageDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialiseObjects];
    [self configureNavigationBar];
    [self registerTableViewCells];
    [self configureReads];
}

- (void)initialiseObjects
{
    _buttonType = kButtonLeft;
    _readHeaderMessage = @"PEOPLE WHO HAVE READ THIS MESSAGE";
    _deliveredHeaderMessage = @"DELIVERED";
}

- (void)configureReads
{
    NSMutableArray *reads = [[NSMutableArray alloc] init];
    
    for(GLPConversationRead *conversationRead in _reads)
    {
        if(_message.remoteKey <= conversationRead.messageRemoteKey)
        {
            [reads addObject:conversationRead];
        }
    }
    
    _finalReads = reads;
    
    DDLogDebug(@"GLPMessageDetailsViewController : final reads %@", _reads);
    DDLogDebug(@"GLPMessageDetailsViewController : message remote key %ld", (long)_message.remoteKey);
    
    
    [_tableView reloadData];
}

- (void)configureNavigationBar
{
    [self.navigationController.navigationBar whiteBackgroundFormatWithShadow:YES];
    self.title = @"MESSAGE DETAILS";
}

- (void)registerTableViewCells
{
    [_tableView registerNib:[UINib nibWithNibName:@"GLPNameTimestampCell" bundle:nil] forCellReuseIdentifier:@"GLPNameTimestampCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GLPMessageDetailsSegmentCell" bundle:nil] forCellReuseIdentifier:@"GLPMessageDetailsSegmentCell"];
    [_tableView registerClass:[GLPMessageCell class] forCellReuseIdentifier:@"GLPMessageCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 2;
    }
    else
    {
        return _finalReads.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            //Configure message cell.
            GLPMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"GLPMessageCell" forIndexPath:indexPath];
            [messageCell setViewMode:YES];
            [messageCell configureWithMessage:_message];
            cell = messageCell;
        }
        else
        {
            //Configure segment.
            GLPMessageDetailsSegmentCell *messageDetailsSegmentCell = [tableView dequeueReusableCellWithIdentifier:@"GLPMessageDetailsSegmentCell" forIndexPath:indexPath];
            messageDetailsSegmentCell.delegate = self;
            
            cell = messageDetailsSegmentCell;
        }
    }
    else if (indexPath.section >= 1)
    {
        //Configure users' cells.

        GLPNameTimestampCell *nameTimestampCell = [tableView dequeueReusableCellWithIdentifier:@"GLPNameTimestampCell" forIndexPath:indexPath];
        GLPConversationRead *conversationRead = [_finalReads objectAtIndex:indexPath.row];
        [nameTimestampCell setConversationRead:conversationRead];
        cell = nameTimestampCell;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            height = [GLPMessageCell viewHeightForMessageInViewMode:_message];
        }
        else
        {
            height = [GLPMessageDetailsSegmentCell height];
        }
    }
    else if (indexPath.section >= 1)
    {
        height = [GLPNameTimestampCell height];
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        if(_buttonType == kButtonLeft)
        {
            return [TableViewHelper generateHeaderViewWithTitle:_readHeaderMessage andBottomLine:YES];
        }
        else
        {
            return [TableViewHelper generateHeaderViewWithTitle:_deliveredHeaderMessage andBottomLine:YES];
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return 30.0;
    }
    return 0.0;
}

#pragma mark - GLPMessageDetailsSegmentCellDelegate

- (void)segmentSwitchedWithButtonType:(ButtonType)conversationsType
{
    _buttonType = conversationsType;
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
