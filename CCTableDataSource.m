#import "CCTableDataSource.h"

@interface TableSection:NSObject

@property (nonatomic, strong) CCTableComponent *sectionHeader;
@property (nonatomic, strong) CCTableComponent *sectionFooter;
@property (nonatomic, strong) NSMutableArray *cells;

@end

@implementation TableSection
@end

@implementation CCViewTableComponent

-(void)configureWithData:(id)data
{
    CCViewConfigureBlock block = data[@"block"];
    if (block) {
        block(self);
    }
}

+(CGFloat)heightForData:(id)data
{
    return [data[@"height"] floatValue];
}

@end

@implementation CCCellTableComponent

-(void)configureWithData:(id)data
{
    CCCellConfigureBlock block = data[@"block"];
    if (block) {
        block(self);
    }
}

+(CGFloat)heightForData:(id)data
{
    return [data[@"height"] floatValue];
}

@end

@implementation CCHeaderFooterTableComponent

-(void)configureWithData:(id)data
{
    CCHeaderFooterConfigureBlock block = data[@"block"];
    if (block) {
        block(self);
    }
}

+(CGFloat)heightForData:(id)data
{
    return [data[@"height"] floatValue];
}

@end

@implementation CCTableComponent

-(id)init
{
    self = [super init];
    if (self) {
        self.componentIdentifier = [[NSUUID UUID] UUIDString];
    }
    return self;
}

+(CCTableComponent *)componentWithClass:(Class<CCTableComponentDelegate>)class data:(id)data
{
    CCTableComponent *component = [CCTableComponent new];
    component.componentClass = class;
    component.data = data;
    return component;
}

+(CCTableComponent *)componentWithClass:(Class<CCTableComponentDelegate>)class data:(id)data identifier:(NSString *)identifier
{
    CCTableComponent *component = [CCTableComponent new];
    component.componentClass = class;
    component.data = data;
    component.componentIdentifier = identifier;
    return component;
}

+(CCTableComponent *)componentWithClass:(Class<CCTableComponentDelegate>)class data:(id)data identifier:(NSString *)identifier selectedBlock:(CCSelectCellBlock)selectedBlock
{
    CCTableComponent *component = [CCTableComponent new];
    component.componentClass = class;
    component.data = data;
    if (identifier) {
        component.componentIdentifier = identifier;
    }
    component.CCSelectCellBlock = selectedBlock;
    return component;
}

+(CCTableComponent *)componentWithViewConfigure:(CCViewConfigureBlock)block andHeight:(CGFloat)height
{
    CCTableComponent *component =[CCTableComponent new];
    component.componentClass = [CCViewTableComponent class];
    component.data = [NSDictionary dictionaryWithObjectsAndKeys:@(height), @"height", block, @"block", nil];
    return component;
}

+(CCTableComponent *)componentWithCellConfigure:(CCCellConfigureBlock)block andHeight:(CGFloat)height
{
    CCTableComponent *component =[CCTableComponent new];
    component.componentClass = [CCCellTableComponent class];
    component.data = [NSDictionary dictionaryWithObjectsAndKeys:@(height), @"height", block, @"block", nil];
    return component;
}

+(CCTableComponent *)componentWithHeaderFooterConfigure:(CCHeaderFooterConfigureBlock)block andHeight:(CGFloat)height
{
    CCTableComponent *component =[CCTableComponent new];
    component.componentClass = [CCHeaderFooterTableComponent class];
    component.data = [NSDictionary dictionaryWithObjectsAndKeys:@(height), @"height", block, @"block", nil];
    return component;
}

+(CCTableComponent *)componentWithHeaderFooterConfigure:(CCHeaderFooterConfigureBlock)block andHeight:(CGFloat)height identifier:(NSString *)identifier
{
    CCTableComponent *component =[CCTableComponent new];
    component.componentClass = [CCHeaderFooterTableComponent class];
    component.data = [NSDictionary dictionaryWithObjectsAndKeys:@(height), @"height", block, @"block", nil];
    component.componentIdentifier = identifier;
    return component;
}

@end

@interface CCTableDataSource()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) CCTableComponent *tableHeader;
@property (nonatomic, strong) CCTableComponent *tableFooter;
@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, weak) id<UITableViewDelegate> tableViewDelegate;

@end

@implementation CCTableDataSource

-(id)initWithTableView:(UITableView *)tableview
{
    self = [super init];
    if (self) {
        self.tableView = tableview;
        tableview.dataSource = self;
        tableview.delegate = self;
        self.sections = [NSMutableArray new];
    }
    return self;
}

-(id)initWithTableView:(UITableView *)tableview delegate:(id<UITableViewDelegate>)delegate
{
    self = [self initWithTableView:tableview];
    if (self) {
        self.tableViewDelegate = delegate;
    }
    return self;
}

-(void)setTableHeader:(CCTableComponent *)component
{
    if (!_tableHeader && component) {
        _tableHeader = component;
        UIView<CCTableComponentDelegate> *headerView = [(Class)component.componentClass new];
        headerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, [component.componentClass heightForData:component.data]);
        [headerView configureWithData:component.data];
        self.tableView.tableHeaderView = headerView;
    } else if (_tableHeader && !component) {
        _tableHeader = nil;
        self.tableView.tableHeaderView = nil;
    }
}

-(void)setTableFooter:(CCTableComponent *)component
{
    if (!_tableFooter && component) {
        _tableFooter = component;
        UIView<CCTableComponentDelegate> *footerView = [(Class)component.componentClass new];
        footerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, [component.componentClass heightForData:component.data]);
        [footerView configureWithData:component.data];
        self.tableView.tableFooterView = footerView;
    } else if (_tableFooter && !component) {
        _tableFooter = nil;
        self.tableView.tableFooterView = nil;
    }
}

-(NSUInteger)addSection
{
    TableSection *section = [TableSection new];
    section.cells = [NSMutableArray new];
    [self.sections addObject:section];
    return self.sections.count - 1;
}

-(void)setHeader:(CCTableComponent *)component ofSection:(NSUInteger)section
{
    NSAssert(section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[section];
    tableSection.sectionHeader = component;
    [self.tableView registerClass:component.componentClass forHeaderFooterViewReuseIdentifier:component.componentIdentifier];
}

-(void)setFooter:(CCTableComponent *)component ofSection:(NSUInteger)section
{
    NSAssert(section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[section];
    tableSection.sectionFooter = component;
    [self.tableView registerClass:component.componentClass forHeaderFooterViewReuseIdentifier:component.componentIdentifier];

}

-(void)addCell:(CCTableComponent *)component toSection:(NSUInteger)section
{
    NSAssert(section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[section];
    [tableSection.cells addObject:component];
    [self.tableView registerClass:component.componentClass forCellReuseIdentifier:component.componentIdentifier];
}

-(void)addCellWithCellConfigure:(CCCellConfigureBlock)block toSection:(NSUInteger)section
{
    CCTableComponent *component =[CCTableComponent new];
    component.componentClass = [CCCellTableComponent class];
    component.data = [NSDictionary dictionaryWithObjectsAndKeys:@(self.tableView.rowHeight), @"height", block, @"block", nil];
    [self addCell:component toSection:section];
}

-(void)addCellWithCellConfigure:(CCCellConfigureBlock)block andHeight:(CGFloat)height toSection:(NSUInteger)section
{
    CCTableComponent *component =[CCTableComponent new];
    component.componentClass = [CCCellTableComponent class];
    component.data = [NSDictionary dictionaryWithObjectsAndKeys:@(height), @"height", block, @"block", nil];
    [self addCell:component toSection:section];
}

-(void)removeCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[indexPath.section];
    NSAssert(indexPath.row < tableSection.cells.count, @"cell exists");
    [tableSection.cells removeObjectAtIndex:indexPath.row];
}

-(void)removeLastCellOfSection:(NSUInteger)section
{
    NSAssert(section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[section];
    [tableSection.cells removeLastObject];
}

-(id)dataAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[indexPath.section];
    NSAssert(indexPath.row < tableSection.cells.count, @"cell exists");
    CCTableComponent *component = tableSection.cells[indexPath.row];
    return component.data;
}

-(void)updateData:(id)data atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[indexPath.section];
    NSAssert(indexPath.row < tableSection.cells.count, @"cell exists");
    CCTableComponent *component = tableSection.cells[indexPath.row];
    component.data = data;
}

-(id)dataForHeaderAtSection:(NSUInteger)section
{
    NSAssert(section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[section];
    return tableSection.sectionHeader.data;
}

-(void)updateData:(id)data forHeaderOfSection:(NSUInteger)section
{
    NSAssert(section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[section];
    CCTableComponent *header = tableSection.sectionHeader;
    header.data = data;
}

-(id)dataForFooterAtSection:(NSUInteger)section
{
    NSAssert(section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[section];
    return tableSection.sectionFooter.data;
}

-(void)updateData:(id)data forFooterOfSection:(NSUInteger)section
{
    NSAssert(section < self.sections.count, @"section exists");
    TableSection *tableSection = self.sections[section];
    CCTableComponent *footer = tableSection.sectionFooter;
    footer.data = data;
}

-(void)clearAll
{
    self.tableHeader = nil;
    self.tableFooter = nil;
    [self.sections removeAllObjects];
}

-(void)clearAllSections
{
    [self.sections removeAllObjects];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TableSection *tableSection = self.sections[section];
    return tableSection.cells.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableSection *tableSection = self.sections[indexPath.section];
    CCTableComponent *component = tableSection.cells[indexPath.row];
    UITableViewCell<CCTableComponentDelegate> *cell = [tableView dequeueReusableCellWithIdentifier:component.componentIdentifier];
    [cell configureWithData:component.data];
    return cell;
}

#pragma mark - UITableViewDelegate ui frame related

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableSection *tableSection = self.sections[indexPath.section];
    CCTableComponent *component = tableSection.cells[indexPath.row];
    return [component.componentClass heightForData:component.data];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TableSection *tableSection = self.sections[section];
    if (!tableSection) {
        return nil;
    } else {
        CCTableComponent *component = tableSection.sectionHeader;
        if (!component) {
            return nil;
        } else {
            UITableViewHeaderFooterView<CCTableComponentDelegate> *header = (UITableViewHeaderFooterView<CCTableComponentDelegate> *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:component.componentIdentifier];
            [header configureWithData:component.data];
            return header;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    TableSection *tableSection = self.sections[section];
    if (!tableSection) {
        return 0;
    } else {
        CCTableComponent *component = tableSection.sectionHeader;
        if (!component) {
            return 0;
        } else {
            return [component.componentClass heightForData:component.data];
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    TableSection *tableSection = self.sections[section];
    if (!tableSection) {
        return nil;
    } else {
        CCTableComponent *component = tableSection.sectionFooter;
        if (!component) {
            return nil;
        } else {
            UITableViewHeaderFooterView<CCTableComponentDelegate> *footer = (UITableViewHeaderFooterView<CCTableComponentDelegate> *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:component.componentIdentifier];
            [footer configureWithData:component.data];
            return footer;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    TableSection *tableSection = self.sections[section];
    if (!tableSection) {
        return 0;
    } else {
        CCTableComponent *component = tableSection.sectionFooter;
        if (!component) {
            return 0;
        } else {
            return [component.componentClass heightForData:component.data];
        }
    }
}

#pragma mark - UITableViewDelegate others

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableSection *tableSection = self.sections[indexPath.section];
    CCTableComponent *component = tableSection.cells[indexPath.row];
    if (component.CCSelectCellBlock) {
        UITableViewCell<CCTableComponentDelegate> *cell = (UITableViewCell<CCTableComponentDelegate> *)[tableView cellForRowAtIndexPath:indexPath];
        component.CCSelectCellBlock(indexPath, cell, component);
    }
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.tableViewDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.tableViewDelegate scrollViewDidScroll:scrollView];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.tableViewDelegate scrollViewWillBeginDragging:scrollView];
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.tableViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.tableViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.tableViewDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.tableViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)]) {
        return [self.tableViewDelegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    } else {
        return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]) {
        return [self.tableViewDelegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]) {
        [self.tableViewDelegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}

@end
