//
//  Graph.m
//  danmaku
//
//  Created by aaron qian on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Graph.h"

@interface GraphNode()
@property (nonatomic, readwrite, retain) NSSet *edgesIn;
@property (nonatomic, readwrite, retain) NSSet *edgesOut;
@property (nonatomic, readwrite, retain) id    value;
- (GraphEdge*)linkToNode:(GraphNode*)node;
- (GraphEdge*)linkToNode:(GraphNode*)node weight:(float)weight;
- (GraphEdge*)linkFromNode:(GraphNode*)node;
- (GraphEdge*)linkFromNode:(GraphNode*)node weight:(float)weight;
- (void)unlinkToNode:(GraphNode*)node;
- (void)unlinkFromNode:(GraphNode*)node;
@end

// private methods for Graph
@interface Graph()
@property (nonatomic, readwrite, retain) NSSet *nodes;
- (GraphNode*)smallest_distance:(NSMutableSet*)nodes;
@end


@implementation Graph

@synthesize nodes = nodes_;

- (id)init
{
    if ( (self = [super init]) ) {
        self.nodes = [NSMutableSet set];
    }
    
    return self;
}

- (void)dealloc
{
    [nodes_ release];
    [super dealloc];
}

// Using Dijkstra's algorithm to find shortest path
// See http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
- (NSArray*)shortestPath:(GraphNode*)source to:(GraphNode*)target {
    if (![nodes_ containsObject:source] || ![nodes_ containsObject:target]) 
    {
        return [NSArray array];
    }
    if([source isEqualToGraphNode:target]) return [NSArray array];
    
    NSMutableSet* remaining = [[nodes_ mutableCopy] autorelease];
    
    GraphNode *minNode = nil;
    for(GraphNode* node in [remaining objectEnumerator]) {
        if([node isEqualToGraphNode:source]) {
            node->dist = 0.0f;
            minNode = node;
        }
        else node->dist = INFINITY;
    }
    
    while ([remaining count] != 0) {
        if(minNode == nil) {
            // find the node in remaining with the smallest distance
            minNode = [self smallest_distance:remaining];

            if (minNode->dist == INFINITY)
                break;
            
            // we found it!
            if( [minNode isEqualToGraphNode:target] ) {
                NSMutableArray* path = [NSMutableArray array];
                GraphNode* temp = minNode;
                while (temp->customData != nil && temp->dist > 0.f) {
                    [path addObject:temp];
                    temp = temp->customData;
                }
                return [ NSMutableArray arrayWithArray:
                        [ [path reverseObjectEnumerator ] allObjects]];
            }
        }
        
        // didn't find it yet, keep going
        
        [remaining removeObject:minNode];

        // find neighbors that have not been removed yet
        NSMutableSet* neighbors = [minNode outNodes];
        [neighbors intersectSet:remaining];
        
        // loop through each neighbor to find min dist
        for (GraphNode* neighbor in [neighbors objectEnumerator]) {
            //NSLog(@"Looping neighbor %@", (NSString*)[neighbor value]);
            float alt = minNode->dist;
            alt += [[minNode edgeConnectedTo: neighbor] weight];
            
            if( alt < neighbor->dist ) {
                neighbor->dist = alt;
                neighbor->customData = minNode;
            }
        }
        minNode = nil;
    }
    
    return [NSArray array];
}

- (GraphNode*)smallest_distance:(NSMutableSet*)nodes {
    NSEnumerator *e = [nodes objectEnumerator];
    GraphNode* node;
    GraphNode* minNode = [e nextObject];
    float min = minNode->dist;
    
    while ( (node = [e nextObject]) ) {
        float temp = node->dist;
        
        if ( temp < min ) {
            min = temp;
            minNode = node;
        }
    }
    
    return minNode;
}

- (BOOL)hasNode:(GraphNode*)node {
    return !![nodes_ member:node];
}

// addNode first checks to see if we already have a node
// that is equal to the passed in node.
// If an equal node already exists, the existing node is returned
// Otherwise, the new node is added to the set and then returned.
- (GraphNode*)addNode:(GraphNode*)node {
    GraphNode* existing = [nodes_ member:node];
    if (!existing) {
       [nodes_ addObject:node]; 
        existing = node;
    }
    return existing;
}

- (GraphEdge*)addEdgeFromNode:(GraphNode*)fromNode toNode:(GraphNode*)toNode {
    fromNode = [self addNode:fromNode];
    toNode   = [self addNode:toNode];
    return [fromNode linkToNode:toNode];
}

- (GraphEdge*)addEdgeFromNode:(GraphNode*)fromNode toNode:(GraphNode*)toNode withWeight:(float)weight {
    fromNode = [self addNode:fromNode];
    toNode   = [self addNode:toNode];
    return [fromNode linkToNode:toNode weight:weight];    
}

- (void)removeNode:(GraphNode*)node {
    [nodes_ removeObject:node];
}

- (void)removeEdge:(GraphEdge*)edge {
    [[edge fromNode] unlinkToNode:[edge toNode]];
}

+ (Graph*)graph {
    return [[[self alloc] init] autorelease];
}

@end
