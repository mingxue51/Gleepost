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

@interface PollingPostView () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) GLPPoll *pollData;

@end

const CGFloat POLLING_TWO_LINES_HEIGHT = 45.0;
const CGFloat POLLING_ONE_LINE_HEIGHT = 20.0;
const CGFloat POLLING_CELL_FIXED_HEIGHT = 92.0;

@implementation PollingPostView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self registerCell];
}

#pragma mark - Configuration

- (void)registerCell
{
    [self.tableView registerNib:[UINib nibWithNibName:@"GLPPollingOptionCell" bundle:nil] forCellReuseIdentifier:@"GLPPollingOptionCell"];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogDebug(@"Table view index path row %ld", (long)indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
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
    NSString *pollTitle = self.pollData.options[indexPath.row];
    [cell setTitle:pollTitle withPercentage:0.2 enable:NO];
    return cell;
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
    
    DDLogDebug(@"get content label %f content %@", [PollingPostView getMaxTitleLabelWidth], content);
    
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
