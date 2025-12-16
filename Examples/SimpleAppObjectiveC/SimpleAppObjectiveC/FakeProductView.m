//
//  FakeProductView.m
//  SimpleAppObjectiveC
//
//  Created by Daehoon Kim on 7/24/25.
//

#import "FakeProductView.h"

@interface FakeProductView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *regularPriceLabel;
@property (nonatomic, strong) UILabel *discountPriceLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation FakeProductView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window && self.onAppear) {
        self.onAppear();
    }
}

- (void)configureWithTitle:(NSString *)title
             regularPrice:(NSString *)regularPrice
            discountPrice:(NSString *)discountPrice
               description:(NSString *)descriptionText {
    self.titleLabel.text = title;
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:regularPrice];
    [attributed addAttribute:NSStrikethroughStyleAttributeName
                       value:@(NSUnderlineStyleSingle)
                       range:NSMakeRange(0, regularPrice.length)];
    self.regularPriceLabel.attributedText = attributed;
    
    self.discountPriceLabel.text = discountPrice;
    self.descriptionLabel.text = descriptionText;
}

#pragma mark - UI

- (void)setupUI {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.layer.cornerRadius = 12.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor separatorColor].CGColor;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.titleLabel.textColor = [UIColor labelColor];
    
    self.regularPriceLabel = [[UILabel alloc] init];
    self.regularPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.regularPriceLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.regularPriceLabel.textColor = [UIColor secondaryLabelColor];
    
    self.discountPriceLabel = [[UILabel alloc] init];
    self.discountPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.discountPriceLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.discountPriceLabel.textColor = [UIColor systemBlueColor];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.font = [UIFont systemFontOfSize:14];
    self.descriptionLabel.textColor = [UIColor secondaryLabelColor];
    self.descriptionLabel.numberOfLines = 0;
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.regularPriceLabel];
    [self addSubview:self.discountPriceLabel];
    [self addSubview:self.descriptionLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:16],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        
        [self.regularPriceLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        [self.regularPriceLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.regularPriceLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        
        [self.discountPriceLabel.topAnchor constraintEqualToAnchor:self.regularPriceLabel.bottomAnchor constant:4],
        [self.discountPriceLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.discountPriceLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        
        [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.discountPriceLabel.bottomAnchor constant:8],
        [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.descriptionLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-16]
    ]];
    
    // Default content
    [self configureWithTitle:@"Fake Monthly Plan"
                regularPrice:@"$14.99"
               discountPrice:@"$9.99 / month"
                 description:@"Demo-only fake product to showcase logViewProductItem."];
}

@end

