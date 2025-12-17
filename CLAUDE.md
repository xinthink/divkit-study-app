# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a research documentation repository containing a comprehensive study on integration challenges between DivKit (Yandex's Server-Driven UI framework) and modern declarative UI frameworks (SwiftUI/Jetpack Compose). The repository contains only documentation - no actual implementation code exists.

Project structure:

- `/ios` - Root of the Xcode workspace and project, all iOS specific code or scripts should be put here
- `/android` - Android specific code and build scripts

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

No build, test, or development commands are available in this repository as it contains only documentation. Any future implementation would need to establish:
- iOS: Xcode project setup with Swift Package Manager
- Android: Gradle build system with Jetpack Compose dependencies

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

- This repository serves as research documentation only
- The actual "DivStudy App" implementation code is not included
- Any future development should reference the architectural recommendations in the study document
- The research focuses on integration challenges, not implementation guidance
- Use the 'iPhone 17' simulator for testing
- Always build and run the app via XcodeBuildMCP
- Validate UI implementation using the XcodeBuildMCP 'describe_ui' tool
- Always scafold the ios project using the XcodeMCPServer, don't create from scratch
