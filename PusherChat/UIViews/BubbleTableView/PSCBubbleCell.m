//
//  PSCBubbleCell.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/16/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCBubbleCell.h"
#import "PSCBubbleData.h"

@interface PSCBubbleCell()
@property (nonatomic, retain) UIView *customView;
@property (nonatomic, strong) UIImageView *bubbleImageView;
@end

@implementation PSCBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!self.bubbleImageView){
            self.bubbleImageView = [[UIImageView alloc] init];
            [self.contentView addSubview:self.bubbleImageView];
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureDataWithModel:(id)model
{
    PSCBubbleData *data = (PSCBubbleData *)model;
    
    NSBubbleType type = data.type;
    
    CGFloat width = data.view.frame.size.width;
    CGFloat height = data.view.frame.size.height;
    
    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - data.insets.left - data.insets.right;
    CGFloat y = 0;
    
    [self.customView removeFromSuperview];
    self.customView = data.view;
    self.customView.frame = CGRectMake(x + data.insets.left, y + data.insets.top, width, height);
    [self.contentView addSubview:self.customView];
    
    if (type == BubbleTypeSomeoneElse){
        self.bubbleImageView.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    }
    else{
        self.bubbleImageView.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }
    
    self.bubbleImageView.frame = CGRectMake(x, y, width + data.insets.left + data.insets.right, height + data.insets.top + data.insets.bottom);
}

@end
