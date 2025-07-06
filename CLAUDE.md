# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Run Commands

This is an iOS project built with Xcode and Swift:

```bash
# Build and run the project
# Open the project in Xcode and build/run from there
open CathyUnitediOSInterview.xcodeproj

# Or build from command line
xcodebuild -project CathyUnitediOSInterview.xcodeproj -scheme CathyUnitediOSInterview -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## Architecture Overview

This is a Swift UIKit application demonstrating a friend list and invitation system using MVVM architecture:

### Core Architecture
- **MVVM Pattern**: `FriendsViewControllerVM` handles data and business logic
- **Combine Framework**: Uses `@Published` properties and `AnyPublisher` for reactive data binding
- **Diffable Data Source**: Manages `UITableView` updates for friend and invitation lists
- **Async/Await**: Modern Swift concurrency for API calls

### Key Components

**Data Layer**:
- `APIClient`: Singleton network client that fetches data from remote JSON endpoints
- `User` & `Friend` models: Core data structures with proper Codable conformance
- API endpoints from `https://dimanyen.github.io/` for different scenarios

**View Layer**:
- `FriendsViewController`: Main controller with scroll view and custom UI components
- Custom UI components: `GradientButtonView`, `PagingHeaderView`, `EmptyStateView`, etc.
- `FriendTableViewCell` & `FriendInvitationTableViewCell`: Custom table view cells

**ViewModel Layer**:
- `FriendsViewControllerVM`: Manages three scenarios (no friends, friends only, friends with invitations)
- Handles search filtering and data merging from multiple API endpoints

### Friend List Merging Logic
The app merges friend lists from multiple endpoints, deduplicating by `fid` and keeping the most recent `updateDate`. This is handled in `APIClient.fetchAndMergeFriendLists()`.

### Scenario System
The app supports three main scenarios via `FriendPageScenario` enum:
- `noFriends`: Empty state
- `friends`: Friends list only
- `friendsWithInvitations`: Friends with pending invitations

## Development Notes

**iOS Requirements**:
- Xcode 15 or later
- iOS 18.2+ deployment target
- Swift 5.0

**Entry Point**:
- `StartingViewController` allows selecting between the three scenarios
- Main functionality is in `FriendsViewController`

**State Management**:
- Uses Combine for reactive UI updates
- ViewModel publishes state changes to the view controller
- Pull-to-refresh functionality implemented

This project demonstrates modern iOS development practices with clean architecture separation and proper error handling.