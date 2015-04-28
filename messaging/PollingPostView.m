//
//  PollingPostView.m
//  Gleepost
//
//  Created by Silouanos on 17/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "PollingPostView.h"
#import "GLPPoll.h"
#import "GLPPollingOptionCell.h"
#import "GLPPost.h"
#import "GLPPollOperationManager.h"
#import "PollingDataView.h"

@interface PollingPostView () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet PollingDataView *pollingDataView;

@property (strong, nonatomic) GLPPoll *pollData;
@property (assign, nonatomic) NSInteger postRemoteKey;

@end

const CGFloat POLLING_TWO_LINES_HEIGHT = 45.0;
const CGFloat POLLING_ONE_LINE_HEIGHT = 20.0;
const CGFloat POLLING_CELL_FIXED_HEIGHT = 92.0;

@implementation PollingPostView


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self registerCell];
    [self registerNotifications];
}

#pragma mark - Configuration

- (void)registerCell
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPPollingOptionCell" bundle:nil] forCellReuseIdentifier:@"GLPPollingOptionCell"];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseFromServer:) name:GLPNOTIFICATION_POLL_VIEW_STATUS_CHANGED object:nil];
}

- (void)deregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GLPNOTIFICATION_POLL_VIEW_STATUS_CHANGED object:nil];
}

#pragma mark - NSNotification methods

- (void)responseFromServer:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    PollOperationStatus operationStatus = [userInfo[@"kind_of_operation"] integerValue];
    NSInteger postRemoteKey = [userInfo[@"post_remote_key"] integerValue];
    
    if(postRemoteKey != self.postRemoteKey)
    {
        return;
    }
    
    if(operationStatus == kFailedToVote)
    {
        NSInteger option = [userInfo[@"option"] integerValue];

        //Revert voting.
        [self revertVoteWithOption:option];
    }
    else if(operationStatus == kPollUpdated)
    {
        self.pollData = userInfo[@"poll_updated_data"];
        [self.tableView reloadData];
    }
}

#pragma mark - Modifiers

- (void)setPollData:(GLPPoll *)pollData withPostRemoteKey:(NSInteger)postRemoteKey
{
    self.pollData = pollData;
    self.postRemoteKey = postRemoteKey;
    [self.pollingDataView setPollData:pollData];
    [self.tableView reloadData];
    [self.tableView setUserInteractionEnabled:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.pollData didUserVote])
    {
        DDLogDebug(@"PollingPostView : user already voted %ld", (long)indexPath.row);
        return;
    }
    
    DDLogDebug(@"PollingPostView : didn't voted yet %ld", (long)indexPath.row);

    
    [[GLPPollOperationManager sharedInstance] voteWithPollRemoteKey:self.postRemoteKey andOption:indexPath.row];
    [self increaseVoteAndUnlockPollCellInOption:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [GLPPollingOptionCell height];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pollData.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLPPollingOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GLPPollingOptionCell" forIndexPath:indexPath];
    NSString *optionTitle = self.pollData.options[indexPath.row];
    CGFloat optionPercentage = [self.pollData voteInPercentageWithOption:optionTitle];
    DDLogDebug(@"PollingPostView : percentage %f option %@ user did vote %d", optionPercentage, optionTitle, self.pollData.didUserVote);
    
    [cell setTitle:optionTitle withPercentage:optionPercentage withIndexRow:indexPath.row enable:self.pollData.didUserVote];
    return cell;
}

#pragma mark - UI & Data methods

- (void)revertVoteWithOption:(NSInteger)option
{
    [self.pollData revertVotingWithOption:self.pollData.options[option]];
    [self.pollingDataView setPollData:self.pollData];
    [self.tableView reloadData];
}

- (void)increaseVoteAndUnlockPollCellInOption:(NSInteger)option
{
    DDLogDebug(@"PollingPostView : increaseVoteAndUnlockPollCellInOption option %ld %@ %@", (long)option, self.pollData.options[option], self.pollData.options);
    
    [self.pollData userVotedWithOption:self.pollData.options[option]];
    [self.pollingDataView setPollData:self.pollData];
    [self.tableView reloadData];
}

- (void)refreshCellWithRow:(NSInteger)row withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:rowAnimation];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (CGFloat)pollingTitleHeightWithText:(NSString *)text
{
    CGFloat titleHeight = [PollingPostView getContentLabelSizeForContent:text];
    
    return titleHeight;
}

#pragma mark - Label size

+ (CGFloat)getContentLabelSizeForContent:(NSString *)content
{
    if(!content)
    {
        return 0.0;
    }
    
    UIFont *font = [UIFont fontWithName:GLP_HELV_NEUE_LIGHT size:19.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
        
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){[PollingPostView getMaxTitleLabelWidth], CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    CGSize size = rect.size;
    
    return size.height;
}

+ (CGFloat)getMaxTitleLabelWidth
{
    return [[UIScreen mainScreen] bounds].size.width - (24 * 2);
}

#pragma mark - Cell size

+ (CGFloat)cellHeightWithPostData:(GLPPost *)postData
{
    CGFloat finalHeight = POLLING_CELL_FIXED_HEIGHT + ([postData imagePost] ? 130.0 : 0) + postData.poll.options.count * [GLPPollingOptionCell height];
    finalHeight += [PollingPostView getContentLabelSizeForContent:postData.eventTitle];
    
    DDLogDebug(@"cell height post data %f", finalHeight);
    
    return finalHeight;
}

@end
