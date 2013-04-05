//
//  AnswersViewController.m
//  HomeWorks
//
//  Created by Sergey Egorov on 4/3/13.
//  Copyright (c) 2013 Trylogic. All rights reserved.
//

#import <RaptureXML/RXMLElement.h>
#import "AnswersViewController.h"
#import "AnswerViewController.h"
#import "NSObject+homeWorksServiceLocator.h"

NSString *kCellID = @"answerCell";
NSString *kLockedCellID = @"lockedAnswerCell";
NSString *kHeaderID = @"collectionHeader";

@interface AnswersViewController () <QLPreviewControllerDataSource>
@end

@implementation AnswersViewController

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.item > 1) {
        return;
    }

    AnswerViewController *previewController=[[AnswerViewController alloc]init];
    previewController.dataSource=self;
    [previewController.navigationItem setRightBarButtonItem:nil];
    [self.navigationController pushViewController:previewController animated:YES];
    //[self.navigationController pushViewController:[[AnswerViewController alloc] initWithURL:@"http://www.trylogic.ru/homeworks/terms/5/subjects/0/books/0/2.png"] animated:YES];
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 2;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Homeworks.bundle/terms/6/subjects/0/books/0/%d", (index + 1)] ofType:@"png"]];
}


- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return 50;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    NSLog(@"%@", [[[self.catalogRxml child:@"term"] child:@"subject"] attribute:@"name"]);
    
    self.collectionView.allowsMultipleSelection = NO;

}

- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    PSUICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:((indexPath.item > 1) ? kLockedCellID : kCellID) forIndexPath:indexPath];

    if(indexPath.item < 2) {
        [[cell.contentView.subviews objectAtIndex:0] setText:[NSString stringWithFormat:@"%d", (indexPath.item + 1)]];
    }

    return cell;
}

- (PSUICollectionReusableView *)collectionView:(PSUICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	
	if ([kind isEqualToString:PSTCollectionElementKindSectionHeader]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderID forIndexPath:indexPath];
	}
    
    return nil;
}


@end