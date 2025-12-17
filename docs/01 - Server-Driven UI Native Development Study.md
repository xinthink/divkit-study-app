# **In-Depth Research Report on Server-Driven UI (SDUI) in Mobile Native Development: Architectural Paradigms, Framework Analysis, and DivKit Practices**

## **1. Executive Summary**

As mobile internet applications become increasingly complex, the speed of app feature iteration has become a key competitive indicator for enterprises. Traditional mobile app development models - namely client-driven models - rely on app store release cycles, which appear increasingly cumbersome and lagging when facing business scenarios requiring rapid A/B testing, dynamic operational activity configuration, and personalized interface display. To solve this core contradiction, Server-Driven UI (SDUI) has emerged as an architectural paradigm and has been widely adopted by tech giants such as Airbnb, Lyft, Uber, and Yandex.

This report aims to provide a detailed and in-depth analysis of SDUI solutions in the mobile native UI development field (particularly Jetpack Compose and SwiftUI). The report will focus on the **DivKit** framework as the core research object, deeply deconstructing its "rendering engine" based technical approach, and conducting horizontal comparisons with "orchestration" solutions represented by **Nativeblocks** and Google's experimental **RemoteCompose** "instruction stream" approach.

The research finds that SDUI is not just a technical choice, but rather an architectural restructuring that transfers UI decision-making power from the client to the server. DivKit, through its powerful JSON template inheritance mechanism and cross-platform rendering engine, provides a mature "out-of-the-box" solution that effectively solves multi-platform consistency issues. However, it still has architectural isolation layers brought by "view wrapping" in deep native integration with modern declarative UI frameworks (Compose/SwiftUI). In contrast, custom SDUI solutions based on native component registries (Registry Pattern), while requiring significant upfront investment, can better align with Compose and SwiftUI's state management and lifecycles. This report provides technology decision-makers with comprehensive guidance from architectural principles, framework selection, best practices to risk avoidance.

## **2. Evolution of Mobile Architecture and Theoretical Foundation of SDUI**

To deeply understand the value of SDUI frameworks like DivKit, we must first examine the evolution history of mobile app architecture. Essentially, SDUI represents a fundamental shift in the "Source of Truth" - transferring the definition power of the view layer from client-side binary files at compile time to server-side responses at runtime.

### **2.1 Bottlenecks of Traditional Client-Driven Architecture**

In classic MVC, MVP, or MVVM architectures, mobile clients are designed as "thick clients." In this model, the client contains all layout definitions (XML, XIB, or Compose/SwiftUI code), view logic (such as data binding, conditional rendering), and navigation logic. The server only serves as a data provider, returning pure business data (such as JSON format {"title": "Product A", "price": 100}).

This architecture worked well in the early days of mobile internet, but in modern high-frequency iteration business environments, it exposes core bottlenecks: **compilation and distribution barriers**. Any minor UI adjustment (such as changing the color of a "purchase" button from blue to red, or adjusting the relative position of price and image in a product card) requires going through the following lengthy cycle:

1. **Code modification and compilation**: Developers modify code locally.

2. **QA testing**: Regression testing to ensure no side effects.

3. **App store review**: Submit to App Store or Google Play, waiting 24 to 72 hours for review.

4. **User update lag**: Waiting for users to actively update the app, complete coverage of mainstream user groups usually takes weeks or even months.

This long cycle not only kills the possibility of rapid trial and error (A/B testing) but also creates maintenance nightmares when different versions of clients coexist.

### **2.2 Server-Driven UI (SDUI) Architectural Paradigm**

SDUI fundamentally subverts the above model. In SDUI architecture, what the server sends is no longer just data, but **how the data should be displayed**. The client degenerates into a generic "rendering container" or "interpreter," which doesn't contain specific business UI knowledge, only knows how to draw basic UI primitives such as "container," "text," "image," or "list."

#### **2.2.1 Core Characteristics**

* **Dynamic layout capability**: The server can change page structure at any time. A list originally arranged vertically can instantly become a grid layout by changing the JSON structure sent, without requiring client release.

* **Atomic component library**: The client pre-implements a series of generic atomic components (Atoms) or molecular components (Molecules). The server assembles these components through protocols.

* **BFF (Backend for Frontend) layer**: Usually requires a dedicated aggregation layer responsible for calling underlying microservices and converting domain models to view models/schemas.

### **2.3 Classification of SDUI Technology Schools**

Current SDUI solutions in the market are not uniform. Based on different implementation principles, they can be divided into three major schools. Understanding this classification is crucial for positioning DivKit.

| Technology School | Description | Representative Solutions | Advantages | Disadvantages |
| :---- | :---- | :---- | :---- | :---- |
| **JSON Rendering Engine** | Client contains a large engine responsible for parsing specific JSON Schema and building view trees itself. | **DivKit**, Jasonette | High consistency, unified cross-platform protocol, not limited to simple components, engine has built-in layout capabilities. | UI style may produce "non-native feel" (Uncanny Valley); engine itself is heavy; difficult to use latest system features. |
| **Native Orchestration** | Server sends semantic component keys (like HeroCard), client maps to native components through registry (SwiftUI Views/Composables). | **Nativeblocks**, Airbnb Ghost Platform | 100% native experience, utilizes existing design systems, optimal performance. | Requires strict synchronization of component library versions between client and server; multi-platform consistency needs manual guarantee. |
| **Remote Rendering / Pixel Streaming** | Server sends underlying drawing instructions (DrawRect, DrawText) or directly transmits pixel streams. | **RemoteCompose**, Web SSR | Ultimate flexibility, server pixel-level control. | High bandwidth consumption, accessibility support difficulties, interaction delay sensitivity. |

**DivKit** belongs to the typical **JSON Rendering Engine** school. It defines a platform-independent DSL (Domain Specific Language), and the client engine is responsible for translating it to Android Views or iOS UIViews. **Nativeblocks** leans more toward **Native Orchestration**, focusing on managing native Compose or SwiftUI components.

## ---

**3. Core Case Deep Analysis: DivKit Framework Architecture and Implementation**

DivKit is a fully functional SDUI framework developed and open-sourced by Yandex, initially applied in high-traffic applications such as Yandex App, Alice voice assistant, and Edadeal. As a mature industrial-grade framework, DivKit has accumulated extensive design experience in solving issues like large JSON volumes, rendering performance, and cross-platform consistency.

### **3.1 DivKit's Core Data Model: DivJson and Templating**

DivKit's core lies in its defined JSON Schema, which is not just a simple layout description but a subset of a programming language that supports logic, state, and inheritance.

#### **3.1.1 Separation Design of card and templates**

In DivKit's response body, data is strictly divided into card (instance data) and templates (template definitions). This design directly borrows the concept of "class" and "instance" from object-oriented programming.

* **Templates**: Define the structural skeleton of UI. For example, defining a template for a "news card" includes the positional relationship between title, image, and summary, font sizes, margins, and other style information.

* **Card**: Defines specific data filling. It references the template and fills in specific text content and image URLs.

This separation greatly optimizes network transmission efficiency. In a Feed stream containing 100 news items, the layout structure only needs to be defined once in templates, while 100 data items only need to transmit field values, avoiding redundant layout description transmission.

#### **3.1.2 Template Inheritance and Parameterization**

DivKit's template system supports **inheritance**, which is a core feature that distinguishes it from many simple SDUI solutions.

* **Inheritance mechanism**: Developers can define a base template base_card, then define promo_card inheriting from base_card, only overriding background color properties. This allows the server to build a "server-side design system" where changes to one affect all.

* **Parameter mapping**: In templates, fields can use variable placeholders (like "$title_text": "param_title"). When using templates, parameters are passed to dynamically replace these placeholders. This capability makes templates highly reusable.

**Code Example Analysis (JSON Structure):**

```json
{
  "templates": {
    "user_profile": {
      "type": "container",
      "items": [
        { "type": "image", "$image_url": "avatar_url" },
        { "type": "text", "$text": "user_name" }
      ]
    }
  },
  "card": {
    "type": "user_profile",
    "avatar_url": "https://example.com/photo.jpg",
    "user_name": "Alice"
  }
}
```

Through the above structure, DivKit actually implements a lightweight component-based development model at the JSON level.

### **3.2 Deep Implementation Mechanism on Android**

On the Android platform, DivKit's implementation details reveal its trade-offs between performance and compatibility.

#### **3.2.1 Rendering Pipeline: View System vs. Canvas**

Research shows that DivKit's underlying rendering on Android is mainly based on the **native View System** rather than directly drawing on Canvas (like Flutter or some game engines).

* **Div2View**: This is DivKit's core entry View. It inherits from ViewGroup.

* **Mapping mechanism**: DivKit parses JSON nodes (like div-text) and maps them to native TextView or its subclasses; div-container maps to LinearLayout or custom layout containers.

* **Advantages**: Using native Views ensures out-of-the-box support for accessibility services (Accessibility/TalkBack), while preserving native interaction behaviors like text selection and copy-paste. Additionally, this makes DivKit easier to mix with existing native code.

* **Disadvantages**: Compared to direct Canvas manipulation, View object creation and measurement (Measure/Layout) overhead is larger. To alleviate this issue, DivKit internally performs extensive object pool reuse and layout hierarchy flattening optimization.

#### **3.2.2 Integration Strategy with Jetpack Compose**

Although Jetpack Compose is the future of Android UI, DivKit currently does not provide pure native Composable function mapping. Its integration with Compose is implemented through **AndroidView wrapper**.

Integration Mode:

Developers need to use AndroidView Composable in Compose code to host Div2View.

```kotlin
AndroidView(
    factory = { context ->
        Div2View(Div2Context(context, configuration)).apply {
             // Initialization logic
        }
    },
    update = { view ->
        view.setData(divData, DivDataTag("feed_card"))
    }
)
```

Architecture Impact Analysis:

This "wrapper" mode means DivKit is a "black box" in Compose's node tree. Compose's state management system (State/SnapshotSystem) cannot directly penetrate and control DivKit's fine-grained elements. DivKit maintains its own state machine and lifecycle internally. This "dual state source" may cause synchronization issues in complex interaction scenarios, requiring developers to handle data flow extremely carefully.

### **3.3 iOS Implementation and SwiftUI Bridge**

On the iOS side, DivKit also adopts a similar strategy, building on UIKit foundation and performing high-performance layout calculations through LayoutKit.

#### **3.3.1 DivHostingView and SwiftUI**

DivKit provides DivHostingView on iOS, which is a subclass of UIView. To use it in SwiftUI, it must be encapsulated through the UIViewRepresentable protocol.

**Technical Details**:

* **Layout engine**: DivKit integrates **LayoutKit** (also used by companies like LinkedIn), which allows layout calculations in background threads, with the main thread only responsible for applying layout results. This is crucial for complex Feed stream scrolling performance, avoiding main thread blocking.

* **SwiftUI Bridge**:

```swift
struct DivViewWrapper: UIViewRepresentable {
    let divData: DivData
    let components: DivKitComponents

    func makeUIView(context: Context) -> DivHostingView {
        return DivHostingView(divkitComponents: components)
    }

    func updateUIView(_ uiView: DivHostingView, context: Context) {
        // Update data logic
    }
}
```

This implementation also means DivKit is essentially running a UIKit island in the SwiftUI world. While this ensures rendering correctness, it sacrifices some ergonomic advantages of pure SwiftUI native development (such as automatic EnvironmentObject passing).

### **3.4 Interactivity and State Management: Beyond Static Display**

If SDUI could only display static content, its value would be greatly diminished. DivKit achieves dynamic interaction through the following mechanisms:

1. **Variables**: JSON can define variables (String, Integer, Boolean). These variables have scope and can be bound to UI properties (e.g., text color bound to a color variable).

2. **Triggers**: Support for defining logical expressions. When variable values meet conditions (like scroll_offset > 100), specific Actions are triggered.

3. **Actions**: Built-in multiple actions like set_variable (modify variable values), open_url (route navigation). Most powerful is support for custom Actions - client code can register DivActionHandler to handle specific business instructions sent by the server (like "add to cart").

4. **Patch mechanism (differential updates)**: This is DivKit's killer feature. The server can send a div-patch containing only the parts that need to change (e.g., after user likes, only update the like icon state) instead of resending the entire card. The client engine is responsible for merging the Patch into the current DOM tree. This greatly improves user experience in weak network environments.

## ---

**4. Deep Comparison: DivKit vs. Nativeblocks vs. Custom Solutions**

When choosing SDUI solutions, enterprises typically face the choice of "building wheels" or "using wheels." Additionally, emerging commercial platforms like Nativeblocks offer different value propositions.

### **4.1 Nativeblocks: Commercial Ecosystem Based on Orchestration**

Different from DivKit's "engine" mode, **Nativeblocks** positions itself as a complete SDUI ecosystem, including SDK, visual editor (Studio), and CLI tools.

#### **4.1.1 Architecture Differences: Orchestration vs. Rendering**

* **Native mapping**: Nativeblocks倾向于**编排**原生组件。它不强迫你使用其内置的 text 组件，而是允许你将 JSON 节点映射到你现有的 SwiftUI View 或 Jetpack Compose Composable。这意味着你的 Design System 组件可以直接被复用，保持了 100% 的原生外观和交互手感。

* **Compile-time generation**: Nativeblocks utilizes compiler technology (like KSP on Android) to generate JSON to Kotlin/Swift code mapping logic at compile time, which is typically more efficient and type-safe than runtime reflection mechanisms.

#### **4.1.2 Toolchain and Business Model**

* **Visual editor**: Nativeblocks provides a Figma-like web editor where non-technical personnel (product managers, operations) can directly drag and drop components to generate UI and push to the server. DivKit lacks this level of visual tools, mainly relying on developers writing or generating JSON.

* **Risk analysis**: Nativeblocks is a Freemium SaaS product. While the core SDK is partially open source (Apache/MIT license), its visual editor and advanced orchestration services are closed source and paid. This introduces **vendor lock-in** risk. If Nativeblocks discontinues service or significantly increases prices, the core UI production pipeline will be blocked. In contrast, DivKit is completely open source under Apache 2.0 license with fully controllable code.

### **4.2 RemoteCompose: Google's Experimental Exploration**

**RemoteCompose** is an experimental project being explored by Google's AndroidX team, representing another extreme of SDUI - **pixel streaming/instruction streaming**.

* **Working principle**: It doesn't transmit semantic JSON (like "button"), but serializes Canvas drawing instructions (like "draw a rounded rectangle at coordinates x,y with red color").

* **Comparison with DivKit**: DivKit transmits "Intent," RemoteCompose transmits "Implementation."

* **Prospects**: RemoteCompose can achieve extremely complex custom drawing and animation cross-platform synchronization, even achieving pixel-level complete consistency. However, it's currently in very early stages, lacks semantic information, and poses huge challenges for accessibility support.

### **4.3 Custom Solutions (Registry Pattern): Mainstream Choice for Large Companies**

Companies like Airbnb (Ghost Platform), Lyft, and Uber mostly adopt self-developed **Registry Pattern** solutions.

* **Principle**:

  1. Server sends business component keys (like ListingCard).

  2. Client maintains a Map<String, ComponentFactory>.

  3. Find corresponding SwiftUI View or Jetpack Compose function based on key and render.

* **Fit with Compose/SwiftUI**: This pattern currently integrates most closely with declarative UI frameworks. It doesn't need to introduce intermediate View layers like DivKit, but directly dynamically combines components in the Compose/SwiftUI render tree.

* **Cost**: Requires maintaining huge infrastructure work such as protocol version control, backward compatibility handling, and toolchain construction.

## ---

**5. Best Practices: Implementing SDUI in SwiftUI and Jetpack Compose**

If deciding to implement SDUI in modern declarative frameworks (whether using DivKit or custom development), specific engineering practices must be followed to avoid technical pitfalls.

### **5.1 Jetpack Compose Integration Pattern: Registry Pattern Details**

The core of implementing SDUI in Compose lies in building an efficient component dispatcher.

#### **5.1.1 Component Registry Design**

Don't use huge when expressions, which make code difficult to maintain. Recommend using Map structure:

```kotlin
// Define component interface
typealias ComposeFactory = @Composable (UiModel) -> Unit

// Component registry
val ComponentRegistry = mapOf<String, ComposeFactory>(
    "hero_banner" to { model -> HeroBanner(model) },
    "product_list" to { model -> ProductList(model) }
)

@Composable
fun ServerDrivenScreen(components: List<UiModel>) {
    LazyColumn {
        items(components, key = { it.id }) { component ->
            val factory = ComponentRegistry[component.type]
            if (factory != null) {
                factory(component)
            } else {
                // Graceful degradation: handle unknown components
                FallbackComponent(component)
            }
        }
    }
}
```

#### **5.1.2 State Hoisting and Data Flow**

In SDUI, Composables must be **stateless**. All states (like text in input boxes, expansion panel open/close) should be elevated to ViewModel, or even passed back to the server through two-way binding.

* **Challenge**: When server updates JSON causing recomposition, if state is saved inside Composable (using remember), it may be lost due to component structure changes.

* **Solution**: Use key identifiers to help Compose recognize component identity, ensuring state preservation during list reordering.

### **5.2 SwiftUI Integration Challenges: Type Erasure and Performance**

SwiftUI's strong type system naturally conflicts with SDUI's dynamic nature.

#### **5.2.1 AnyView Pitfalls**

Beginners often tend to use AnyView to erase specific View types to put them in an array:

```swift
// Anti-pattern: poor performance
func render(component: Component) -> AnyView {
    switch component.type {
    case .text: return AnyView(TextView(component))
    case .image: return AnyView(ImageView(component))
    }
}
```

AnyView breaks SwiftUI's view structural identity, making it difficult for SwiftUI to perform efficient Diff algorithm comparisons, causing it to destroy and rebuild the entire view tree on each data update, leading to serious performance issues.

#### **5.2.2 Correct Approach: @ViewBuilder and Enum Encapsulation**

Best practice is to use enums to encapsulate all possible component types and use switch statements in body. This allows SwiftUI compiler to infer definite view structures.

```swift
enum UIComponentView: View {
    case text(TextModel)
    case image(ImageModel)

    var body: some View {
        switch self {
        case .text(let model): TextView(model)
        case .image(let model): ImageView(model)
        }
    }
}
```

Or use @ViewBuilder to maintain type information transmission.

### **5.3 Version Control and Backward Compatibility**

SDUI's biggest nightmare is **Schema evolution**. When the server releases a new component VideoPlayer, but the old version client (v1.0) code doesn't register this component, the app may crash or display blank.

**Defense Strategy Table:**

| Strategy | Implementation Details | Applicable Scenarios |
| :---- | :---- | :---- |
| **Graceful Degradation** | When client encounters unknown type, render a height-0 EmptyView or generic "please upgrade version" prompt card. | Basic requirement for all SDUI implementations. |
| **Strict Version Negotiation** | Client request header carries X-Client-Version, server filters unsupported component data based on version. | Prevent old version users from receiving unparseable data packets. |
| **Universal Container Fallback** | Design a universal WebView component as "universal fallback." If native cannot render a component, server sends the component's Web URL, client displays with WebView. | Scenarios with strong timeliness like operational activities where client hasn't released in time. |

## ---

**6. Potential Risks and Technical Limitations**

Despite SDUI's great appeal, the complexity it introduces cannot be ignored.

### **6.1 Apple App Store Review Risk (Guideline 2.5.2)**

Apple's review guidelines section 2.5.2 explicitly prohibits apps from "downloading executable code."

* **Compliance red line**: As long as what's downloaded is **configuration data (JSON/XML) rather than logic scripts (JS/Lua)**, it's generally considered compliant. DivKit and Nativeblocks patterns (sending UI descriptions, logic executed by local pre-buried code) are widely accepted by Apple.

* **High-risk area**: If attempting to download JavaScript and execute it locally to change core business logic (such as bypassing payment processes), it will very likely lead to app removal. SDUI should focus on "presentation layer" dynamicization, not "business logic layer" dynamicization.

### **6.2 Security Risk: Injection Attacks**

SDUI exposes UI structure to the network, introducing security risks similar to web development.

* **SSTI (Server-Side Template Injection)**: Although mainly targeting servers, if clients blindly render all content sent by the server, man-in-the-middle attacks (MITM) may tamper with JSON, injecting a fake "login box" to steal user passwords (phishing attacks).

* **Defense**: Must implement strict Schema validation (JSON Schema Validation) and use HTTPS certificate pinning (SSL Pinning) to prevent data tampering.

### **6.3 Debugging and Observability Challenges**

Under SDUI architecture, "interface display errors" become distributed system problems.

* **Problem location**: When users report "home page button missing," developers cannot find the cause by just looking at client code. The problem may be in server configuration, BFF layer data transformation, or client version compatibility logic.

* **Toolchain needs**: Must establish powerful full-chain logging systems, recording original JSON snapshots sent by the server, to be able to "replay" user's UI state when troubleshooting problems.

## ---

**7. Conclusions and Strategic Recommendations**

SDUI represents the inevitable stage of mobile development industrialization. It transforms UI production from "handicraft-style" hard coding to "assembly line-style" configuration.

For teams evaluating SDUI introduction, this report proposes the following strategic recommendations:

1. **For teams seeking mature, low-cost solutions**: **DivKit** is currently the best choice. It provides complete cross-platform engines, template systems, and toolchains, and is completely open source. Although there are certain "foreign body feelings" (wrapper mode) in Compose/SwiftUI integration, its stability and feature richness are sufficient to support large-scale business.

2. **For teams pursuing ultimate native experience and Design System reuse**: Recommend adopting **Registry Pattern** for custom development or evaluating **Nativeblocks**. In Compose and SwiftUI, mapping JSON to native components can achieve optimal performance and development experience while maintaining codebase modernization.

3. **Progressive adoption**: Don't attempt to refactor the entire App to SDUI. Best practice is to adopt **hybrid architecture** - core navigation, settings pages, and other frequently interacted static pages remain local native development; while home Feed streams, marketing activity pages, help centers, and other frequently updated content modules adopt SDUI.

As Jetpack Compose and SwiftUI further mature, and AI-assisted UI code generation (Generative UI) capabilities improve, future SDUI may evolve toward "server-side generation of native code" or more efficient binary instruction streams. But currently, DivKit and other JSON engine-based solutions remain the optimal balance between flexibility and engineering costs.

## **References**

1. Nativeblocks vs Divkit, accessed December 11, 2025, https://nativeblocks.io/blog/nativeblocks-vs-divkit/

2. Server-Driven UI: Agile Interfaces Without App Releases - DZone, accessed December 11, 2025, https://dzone.com/articles/server-driven-ui-agile-interfaces-without-app-releases

3. Server-Driven UI Design Patterns: A Professional Guide with Examples - Dev Cookies, accessed December 11, 2025, https://devcookies.medium.com/server-driven-ui-design-patterns-a-professional-guide-with-examples-a536c8f9965f

4. How to Safely Release Server-Driven UI Updates at Scale - Digia Tech, accessed December 11, 2025, https://www.digia.tech/post/server-driven-ui-release-management

5. FAQ | DivKit, accessed December 11, 2025, https://divkit.tech/docs/en/concepts/faq

6. What is Server-Side Includes Injection? How Does It Work & What Are Other Common Types of SQL Attacks Explained for Web Security Beginners, accessed December 11, 2025, https://www.webasha.com/blog/what-is-server-side-includes-injection-how-does-it-work-what-are-other-common-types-of-sql-attacks-explained-for-web-security-beginners

7. Yandex Releases DivKit, an Open Framework for Server-Driven UI | by Tayrinn - Medium, accessed December 11, 2025, https://medium.com/yandex/yandex-releases-divkit-an-open-framework-for-server-driven-ui-cad519252f0f

8. Instructions for Android - DivKit, accessed December 11, 2025, https://divkit.tech/docs/en/quickstart/android

9. Templates | DivKit, accessed December 11, 2025, https://divkit.tech/docs/en/concepts/templates

10. DivKit — Cross-platform Server-Driven UI framework, accessed December 11, 2025, https://divkit.tech/

11. DivKit: an opensource framework for Server Driven UI : r/androiddev - Reddit, accessed December 11, 2025, https://www.reddit.com/r/androiddev/comments/wz9umx/divkit_an_opensource_framework_for_server_driven/

12. FAQ | DivKit, accessed December 11, 2025, https://divkit.tech/docs/en/quickstart/android-faq

13. Typical stack - DivKit, accessed December 11, 2025, https://divkit.tech/docs/en/

14. Jetpack Compose Tutorial - Android Developers, accessed December 11, 2025, https://developer.android.com/develop/ui/compose/tutorial

15. Instructions for iOS | DivKit, accessed December 11, 2025, https://divkit.tech/docs/en/quickstart/ios

16. divkit-ios/DivKit/DivKitComponents.swift at main - GitHub, accessed December 11, 2025, https://github.com/divkit/divkit-ios/blob/main/DivKit/DivKitComponents.swift

17. Actions with elements | DivKit, accessed December 11, 2025, https://divkit.tech/docs/en/concepts/interaction

18. Nativeblocks android kotlin compiler - GitHub, accessed December 11, 2025, https://github.com/nativeblocks/nativeblocks-compiler-android

19. SDUI Pricing - Server-Driven UI Framework Pricing | Nativeblocks, accessed December 11, 2025, https://nativeblocks.io/pricing

20. Nativeblocks - Server-Driven UI Framework | Dynamic Mobile UI, accessed December 11, 2025, https://nativeblocks.io/

21. RemoteCompose: Another Paradigm for Server-Driven UI in Jetpack Compose | by Jaewoong Eum | Nov, 2025 | ProAndroidDev, accessed December 11, 2025, https://proandroiddev.com/remotecompose-another-paradigm-for-server-driven-ui-in-jetpack-compose-92186619ba8f

22. A Deep Dive into Airbnb's Server-Driven UI System | by Ryan Brooks - Medium, accessed December 11, 2025, https://medium.com/airbnb-engineering/a-deep-dive-into-airbnbs-server-driven-ui-system-842244c5f5

23. The Journey to Server Driven UI At Lyft Bikes and Scooters | by Alex Hartwell, accessed December 11, 2025, https://eng.lyft.com/the-journey-to-server-driven-ui-at-lyft-bikes-and-scooters-c19264a0378e

24. ViewBuilder vs. AnyView - Alejandro M. P., accessed December 11, 2025, https://alejandromp.com/development/blog/viewbuilder-vs-anyview/

25. SwiftUI and AnyView: Performance benchmarks - Using Swift, accessed December 11, 2025, https://forums.swift.org/t/swiftui-and-anyview-performance-benchmarks/65717

26. @ViewBuilder usage explained with code examples - SwiftLee, accessed December 11, 2025, https://www.avanderlee.com/swiftui/viewbuilder/

27. Server-Driven UI Best Practices and Common Pitfalls - Nativeblocks, accessed December 11, 2025, https://nativeblocks.io/blog/best-practices-and-common-pitfalls/

28. Fixing Section 2.5.2 - Saagar Jha, accessed December 11, 2025, https://saagarjha.com/blog/2020/11/08/fixing-section-2-5-2/

29. App Review Guidelines - Apple Developer, accessed December 11, 2025, https://developer.apple.com/app-store/review/guidelines/

30. Server driven UI and Apple review guidelines. : r/iOSProgramming - Reddit, accessed December 11, 2025, https://www.reddit.com/r/iOSProgramming/comments/11m5aq1/server_driven_ui_and_apple_review_guidelines/

31. Are LiveView Native Apps Accepted By Apple? - DockYard, accessed December 11, 2025, https://dockyard.com/blog/2024/12/20/are-liveview-native-apps-accepted-by-apple

32. What SSTI | Server-Side Template Injection Attacks - Imperva, accessed December 11, 2025, https://www.imperva.com/learn/application-security/server-side-template-injection-ssti/