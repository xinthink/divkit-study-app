# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an active implementation project for studying integration challenges between DivKit (Yandex's Server-Driven UI framework) and modern declarative UI frameworks (SwiftUI/Jetpack Compose). The repository contains both research documentation and working iOS implementation code.

Project structure:

- `/ios` - iOS implementation (Xcode workspace, project files, Swift source code)
  - `DivStudyApp.xcworkspace` - Main workspace
  - `DivStudyApp.xcodeproj` - Xcode project
- `/android` - Android implementation (planned)
- `/docs` - Research documentation and technical analysis

## Key Research Document

The primary document is `/docs/02 - Integration Challenges of DivKit in Modern Declarative UI Frameworks.md` - a 26KB technical report analyzing architectural pitfalls when integrating DivKit with declarative UI frameworks, and a set of experiments have been designed to reveal those risks.

Furthermore, there is a comprehensive research about mainstream SDUI solutions: `/docs/01 - Server-Driven UI Native Development Study.md`.

## Study Context

The documentation describes an experimental "DivStudy App" project that was designed to test:
- State management synchronization issues
- Layout conflicts between traditional Views and declarative UI
- Type safety challenges with JSON-based configurations
- Debugging observability limitations
- Security vulnerability risks

## Technical Environment Reference

Based on the study documentation, the experimental app was designed for:

**iOS Configuration:**
- iOS 16.0+
- SwiftUI with Swift 5.7+
- Integration via `UIViewRepresentable` / `DivHostingView`
- Swift Package Manager (SPM) dependency management

**Android Configuration:**
- Android 12.0+ (API Level 31+)
- Jetpack Compose with Material 3, Kotlin 1.8+
- Integration via `AndroidView` / `Div2View`
- Gradle Version Catalogs dependency management

## Development Commands

**iOS Development:**
- Always use XcodeBuildMCP tools for all build operations
- Session defaults should be configured before building/running
- Use `screenshot` for visual validation
- Use `describe_ui` for textual UI hierarchy analysis
- Target simulator: iPhone 17
- Project location: `/ios/DivStudyApp.xcworkspace`

**Android Development:**
- Not yet implemented
- Future: Gradle build system with Jetpack Compose dependencies

**Git Operations:**
- Never execute git commits, pushes, or branch operations without explicit user request

## Architecture Insights

The study identifies five major architectural challenges:

1. **State Management "Black Box" Effect**: DivKit maintains internal state separate from declarative UI state, requiring imperative bridge code
2. **"Island" Effect**: Traditional Views embedded in declarative UI create layout conflicts and performance issues
3. **Type Erasure**: JSON-based configuration loses compile-time type safety
4. **Debugging Blind Spots**: Limited observability into DivKit's internal operations
5. **Security Vulnerabilities**: Potential injection attacks through JSON payloads

## Research Methodology

The study employed a "Codelab"-style empirical approach with five test modules:
- Module A: Dynamic Form (State management testing)
- Module B: Hybrid Feed (Layout performance testing)
- Module C: Anomaly Injection (Error handling testing)
- Module D: Debugging Observability (Debugging capabilities testing)
- Module E: Security Sandbox (Security vulnerability testing)

## Important Notes

- **Project Status**: Active iOS implementation in progress, research documentation complete
- **iOS Implementation**: Located in `/ios`, built with Xcode workspace structure
- Development follows the architectural insights from research documentation
- Research focus: Integration challenges between DivKit and declarative UI frameworks

**Development Guidelines:**
- Use 'iPhone 17' simulator for testing
- Always build and run via XcodeBuildMCP (never use xcodebuild directly)
- UI validation: `screenshot` (visual) + `describe_ui` (textual)
- New projects: Scaffold using XcodeBuildMCP tools, don't create manually
- Git operations: Only execute when explicitly requested by user

**Code Quality:**
- Follow SOLID, KISS, DRY, YAGNI principles
- Maintain consistent code comments language with existing codebase
- Prefer specialized tools over bash commands for file operations
- Use `Context7` tools to confirm latest development documentation before coding or fixing issues
