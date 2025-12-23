# **Mobile Architecture Paradigm Shift: In-Depth Research Report on Airbnb, Lyft, and Uber's Server-Driven UI (SDUI) Registry Pattern**

## **Executive Summary**

As the mobile internet enters an era of stock competition, the iteration speed and architectural flexibility of applications have become core competitive advantages for large technology companies. The traditional mobile development model—namely, the "Thick Client" architecture—is increasingly unable to meet the business needs of hyperscale applications due to its dependence on app store review cycles, fragmented multi-platform logic, and high maintenance costs. In this context, Server-Driven UI (SDUI), as an architectural paradigm that decouples release cycles from business logic, has been widely adopted by industry giants such as Airbnb, Lyft, and Uber.

This report aims to conduct a detailed comparative analysis and technical dissection of the SDUI solutions of the aforementioned three companies. The core focus of the report is the "Registry Pattern"—the critical mechanism connecting server-side abstract descriptions with client-side native component instantiation. By analyzing Airbnb's "Ghost Platform" and its GraphQL data mesh, Lyft's atomic design components based on Protobuf, and Uber's plugin-based exploration within the RIBs architecture, this report reveals the causes, technical decision paths, operational risk management, and valuable lessons learned from failure cases associated with the introduction of SDUI. The research shows that although the technical stacks of these companies (GraphQL vs. Protobuf, JSON vs. Thrift) differ, their underlying logic converges: through standardized protocols and centralized registration mechanisms, they achieve the delegation of UI rendering authority, thereby striking an optimal balance between native performance and web-like iteration speed.

---

## **Chapter 1: The Motivation for Paradigm Shift: From Thick Client to Server-Driven**

### **1.1 Scaling Bottlenecks of the "Thick Client" Architecture**

In the early days of mobile app development, MVC (Model-View-Controller) or MVVM (Model-View-ViewModel) architectures were the absolute mainstream. In this model, the client binary contained most of the business logic, page layout rules, and navigation flows. The server acted merely as a passive data provider, typically returning JSON data via RESTful APIs, which the client parsed and populated into hard-coded views.

However, for enterprises like Airbnb, Lyft, and Uber, which have hundreds of millions of users, operate globally, and are in a period of rapid growth, this model began to show severe diminishing marginal returns between 2015 and 2017.

#### **1.1.1 Uncontrollable Release Cycles (App Store Wall)**

The biggest pain point in mobile development is "release delay." Unlike the CI/CD process on the web, where deployments can happen at any time, mobile app updates must go through a long chain of building, internal testing, submission to app stores (Apple App Store and Google Play), review, and manual user updates.

For a two-sided marketplace like Airbnb, if it needs to urgently launch a new module for displaying property safety compliance for specific holidays or sudden public health events (such as COVID-19), the traditional release process could take weeks. At this point, even if the backend interface is ready, the business cannot be implemented as long as the client code does not have the corresponding UI components pre-built. This strong dependency on app store reviews is known as the "App Store Wall," which severely constrains business agility.

#### **1.1.2 Multi-Platform Logic Fragmentation and "Logic Drift"**

In the traditional development model, the same feature needs to be implemented separately on three platforms: iOS (Swift/Objective-C), Android (Kotlin/Java), and Web (React/JavaScript). This not only means triple the manpower cost but also leads to serious "Logic Drift."

For example, Lyft found in its early network layer implementation that different platforms had subtle differences in handling the optionality of API fields, HTTP status codes, and even JSON parsing fault tolerance. Over time, these differences accumulated into significant technical debt, causing the same order status to display as "In Progress" on iOS and "Pending Confirmation" on Android. One of the core demands of SDUI is to move these presentation logics to the server side to achieve "write once, render everywhere."

### **1.2 Cost-Benefit Analysis Model of SDUI**

Introducing SDUI is not without cost. It requires building complex backend infrastructure (BFF, Backend for Frontend), establishing strict protocol standards (Schema), and developing supporting visual operation tools.

| Dimension | Traditional Native Development Model | Server-Driven UI (SDUI) Model | Core Difference Analysis |
| :---- | :---- | :---- | :---- |
| **Iteration Speed** | T+N days (limited by review and user update rate) | T+0 (immediate effect) | SDUI completely decouples UI changes from app releases, enabling minute-level business launches. |
| **Development Cost** | High (iOS + Android + Web repeated development) | Medium (server-side Schema + universal client components) | Initial infrastructure cost is very high, but as the component library (Primitives) grows, marginal cost approaches zero. |
| **Code Maintenance** | Logic scattered across three platforms, difficult to synchronize | Logic converged on the server side, single source of truth | Solves multi-platform consistency issues, greatly reducing the complexity of regression testing. |
| **Package Size** | Grows linearly with business features | Relatively constant | The client only needs to include a universal component library; business logic is delivered as data and no longer occupies binary space. |
| **User Experience** | Ultimate native experience | Depends on rendering engine optimization | Early SDUI may have rendering delays, but preloading and local caching can approximate native experience. |

Lyft's engineering team points out that although SDUI increases the complexity of the server side, it brings a "snowball effect": as the foundation components (Primitives) continue to accumulate, developing new features often only requires combining existing components without writing any client code. This makes resource allocation more flexible, allowing backend engineers to directly deliver UI features.

## **Chapter 2: Theoretical Architecture of the Registry Pattern**

The core of SDUI lies in how to convert the abstract description (Schema) sent down by the server into interactive native views on the client side. This process is primarily carried by the "Registry Pattern."

### **2.1 Definition and Responsibilities of the Registry**

The registry is a singleton or static mapping table on the client side that maintains the mapping relationship from "component type identifier" (Type ID) to "native class" (Native Class).

In a typical interaction flow:

1. **Protocol Delivery**: The server returns a piece of JSON or Protobuf data containing the component type (e.g., "type": "CAROUSEL_VIEW") and component data (e.g., image URLs, title text).

2. **Mapping Lookup**: The client parser reads the "type" field and looks up the corresponding native implementation class in the registry.

3. **Instantiation and Hydration**: The registry returns the corresponding View class or ViewBuilder, the system instantiates it, and "hydrates" the data into the view.

### **2.2 Static Registration and Dynamic Distribution**

Technically, registries are divided into static and dynamic schools:

* **Static Registration**: Primarily adopted by Airbnb and Lyft. All possible UI components must be pre-compiled into the client's binary package. The server can only build pages by combining these existing components. If the server sends down a component type unknown to the client (e.g., a newly developed VR_VIEW), the client will be unable to render it.

  * *Advantages*: Type-safe, compile-time checks, high performance.

  * *Disadvantages*: Introducing new components still requires a release.

* **Dynamic Delivery**: Delivering JavaScript bundles (e.g., React Native) or WebAssembly to dynamically execute code.

  * *Risks*: Although flexible, it faces Apple's review risks (prohibiting hot updates that change core functionality) and performance overhead. Therefore, SDUI in mainstream large companies more often refers to "Server-Driven Configuration" rather than delivering executable code.

### **2.3 Abstract Component Model**

To make the registry work, a common component description language must be established. This usually includes:

* **Atomic Components**: Text, images, buttons, dividers.

* **Molecular Components**: Complex units composed of atoms, such as "property cards" or "driver information rows."

* **Container Components**: Components responsible for layout, such as vertical stacks, horizontal scroll areas, grids.

Uber and Lyft particularly emphasize atomic design, breaking down the UI into the finest-grained "Primitives" to give the server maximum compositional freedom.

## **Chapter 3: Airbnb Ghost Platform: Full-Stack Unification Based on GraphQL**

Airbnb's SDUI solution is called **Ghost Platform (GP)**, with a core design philosophy of eliminating the fragmentation in multi-platform development between "Guest" (guest side) and "Host" (host side). Airbnb chose GraphQL as the cornerstone of its data interaction, building a highly type-safe SDUI system.

### **3.1 Architectural Core: Viaduct Data Mesh**

Airbnb's backend architecture has evolved into a service mesh centered on data, called **Viaduct**. Unlike traditional process-oriented service calls, Viaduct allows clients to directly obtain UI structures through GraphQL queries.

In the Ghost Platform, Schema definitions are no longer simple resource data (such as User or Listing) but UI descriptions.

* **Schema Design**: Airbnb defined a unified GraphQL Schema, which includes the concepts of Section (block) and Screen (screen). Section is the basic building block of the UI.

* **Polymorphism**: Utilizing GraphQL's Union types, a page query can return multiple different types of Sections. For example, querying ListingPage might return ``.

### **3.2 Client Implementation: Epoxy and SectionComponentType**

On the Android side, Airbnb developed and open-sourced the **Epoxy** framework, a complex list-building library based on RecyclerView. The Ghost Platform is deeply integrated with Epoxy.

* **Registration Mechanism**: The core registration key is SectionComponentType. This is an enumeration or string identifier defined in the GraphQL Schema.

* **Rendering Process**:

  1. The client initiates a GraphQL query.

  2. Viaduct returns a JSON response containing sectionComponentType and the corresponding data model.

  3. The client's Ghost framework receives the response and uses the registry to find the corresponding EpoxyModel.

  4. Epoxy calculates the Diff (difference), updating only the changed UI areas, ensuring smooth 60fps performance even in complex long lists.

### **3.3 Adherence to Native Languages**

It is worth noting that after a period of experimenting with and ultimately abandoning React Native, Airbnb firmly chose to use **native languages** in SDUI.

* **Android**: Kotlin

* **iOS**: Swift

* **Web**: TypeScript

This means that although the Schema is unified, the components mapped in the registry are purely native. This strategy ensures both native high performance and interaction feel while achieving centralized control of logic.

## **Chapter 4: Lyft's Primitive System: Ultimate Efficiency with Protobuf and BFF**

Unlike Airbnb, which focuses on the flexibility of GraphQL, Lyft's SDUI architecture is deeply influenced by the evolution of its network infrastructure, choosing **Protocol Buffers (Protobuf)** as the communication protocol, emphasizing transmission efficiency and version compatibility.

### **4.1 From "Server-Supplemented" to "Server-Driven"**

Lyft divides the evolution of UI control into two stages:

* **Server Supplemented**: The server only sends down configuration switches or copy, with layouts hardcoded on the client side.

* **Server Driven**: The server sends down the complete view hierarchy structure.

This transformation was primarily driven by the Lyft Bikes & Scooters team, aiming to cope with complex hardware differences and market differences (rental processes vary drastically across different cities).

### **4.2 Core Primitives: Components and Actions**

Lyft architect Alex Hartwell proposed an extremely minimalist SDUI primitive design:

#### **4.2.1 Binary Classification of Components**

Lyft strictly divides components into two categories, which directly affect the implementation logic of the registry:

1. **Declarative/Generic Components**:

   * Similar to HTML's div, span, img.

   * **Characteristics**: Completely generic, with no business semantics. The server controls all styles (colors, margins, fonts).

   * **Registry Handling**: The client registry parses these into basic UI nodes, typically rendered using a Flexbox layout engine.

2. **Semantic Components**:

   * Business-specific components, such as "ride status cards" or "price estimation bars."

   * **Characteristics**: The client knows the component's style and interaction logic; the server only needs to send down data.

   * **Role**: Acts as an "escape hatch." When complex local animations or high-performance interactions (such as map sliders) are needed, semantic components are used to avoid the performance loss brought by generic components.

#### **4.2.2 Actions**

Lyft separates "interaction logic" from components, defining it as Action.

* The registry registers not only views but also actions.

* For example, a button component's data contains an Action field: onTap: { type: "UNLOCK_BIKE", bikeId: "123" }.

* This decoupling allows the same button to trigger completely different business logic in different scenarios without modifying client code.

### **4.3 Protocol Choice: Advantages of Protobuf**

Lyft chose Protobuf over JSON, primarily based on the following considerations:

* **Size Reduction**: Protobuf is a binary format, smaller in volume compared to JSON, which is crucial for transmitting complex UI trees in mobile network environments.

* **Backward Compatibility**: Protobuf has a strict field numbering mechanism. When the server adds new fields, old clients automatically ignore unknown fields without crashing, providing natural security guarantees for SDUI Schema evolution.

## **Chapter 5: Uber's Structured Modules: RIBs and Plugin Architecture**

Uber's SDUI practice is closely integrated with its unique mobile architecture **RIBs (Router, Interactor, Builder)**. Uber's exploration has undergone a process from aggressive cross-platform frameworks to pragmatic plugin-based transformations.

### **5.1 Adaptation of RIBs Architecture to SDUI**

The core of the RIBs architecture lies in emphasizing the **decoupling of business logic (Interactor) and views (View)**. Unlike MVC/MVVM, which relies on view hierarchies, RIBs' hierarchy is a business logic hierarchy.

* In SDUI scenarios, the data sent down by the server not only drives the View but also drives the state machine of the Router and Interactor.

* This means that Uber's SDUI is not just about "skin painting" but can drive the application's state transitions.

### **5.2 Success Case: Uber Freight's Plugin Factory Model**

The Uber Freight app faces extremely high list rendering complexity and business logic reuse requirements. They adopted an SDUI solution based on RIBs and plugins.

#### **5.2.1 Union Types and Plugin Registration**

Uber uses Thrift's Union types to define backend data models.

* **Data Source**: The backend API returns a list containing different business objects (such as Load, Facility, DriverInfo).

* **Plugin Factory**: This is a variant of Uber's registry pattern.

  * The client defines a PluginFactory interface.

  * For each backend Union type (e.g., LoadUnion), developers register a corresponding plugin.

  * **Conversion Logic**: When the main list RIB receives data, it iterates through the data, asking the plugin registry: "Who can handle this data type?"

  * The matching plugin factory converts the data into **a set** of mobile components. Note that this is a one-to-many mapping—a single backend data object can generate multiple UI components such as titles, maps, and buttons. This design is more flexible than Airbnb's one-to-one mapping.

### **5.3 Failed Exploration: Screenflow Project**

Uber once attempted to develop a universal SDUI framework called **Screenflow**, trying to unify iOS, Android, and Web with a set of JSON description languages.

* **Architecture**: Based on Flexbox layout, attempting to build a browser-like rendering engine on top of native.

* **Reasons for Failure**:

  1. **Abstraction Leakage**: Attempting to flatten platform differences is extremely difficult, leading to poor Flexbox performance on Android.

  2. **Organizational Restructuring**: The closure of the Amsterdam engineering team led to the project being shelved.

  3. **Lessons Learned**: Attempting to build a "universal" UI description language often leads to sacrificing performance for compatibility. Uber ultimately shifted to a more pragmatic, "component-driven" rather than "layout-driven" SDUI solution based on the existing RIBs architecture.

## **Chapter 6: Integration of Modern Declarative Frameworks and SDUI**

With the popularity of Android **Jetpack Compose** and iOS **SwiftUI**, the implementation of SDUI has undergone a qualitative leap. Both Lyft and Uber have begun large-scale migrations to these modern frameworks.

### **6.1 Declarative UI: Natural Ally of SDUI**

Traditional View systems (such as Android XML) require cumbersome findViewById and property settings, while declarative UI is inherently "state-driven."

* **Code Reduction**: Lyft reported that migrating button components to Compose reduced code by 60% and eliminated all XML files.

* **Simplification of Registry**: In Compose, the registry no longer needs to maintain complex ViewHolder factories but is simply a when expression (Kotlin):

```kotlin
@Composable
fun ServerDrivenComponent(uiModel: UiModel) {
    when (uiModel) {
        is TextModel -> TextComponent(uiModel)
        is ImageModel -> ImageComponent(uiModel)
        is RowModel -> RowComponent(uiModel) // Recursive rendering
        else -> FallbackComponent() // Handle unknown types
    }
}
```

### **6.2 State Management and Recomposition**

The "smart recomposition" mechanism of modern frameworks perfectly solves the update performance issues of SDUI. When the server pushes a new Schema, the Compose/SwiftUI framework automatically compares data differences and only redraws the changed nodes, without needing complex Diff calculations like Airbnb's early reliance on Epoxy.

## **Chapter 7: Operational Systems, Toolchains, and Visualization**

The success of SDUI depends not only on code but also on supporting toolchains.

### **7.1 Visual Editor**

To enable non-technical personnel (product managers, operations staff) to leverage SDUI capabilities, companies usually develop internal visual construction platforms.

* **WYSIWYG**: Tools like **Judo** allow users to assemble pages by dragging and dropping server-supported components (Keys in the registry).

* **Real-Time Preview**: Using WebSocket technology to preview editor modifications in real-time on real devices, greatly shortening the design-acceptance loop.

### **7.2 Integration with Design Systems**

SDUI must be strongly bound to the company's design system (DLS).

* Lyft developed the **LPL Lint** tool to check during the Figma design phase, ensuring that designers use components that already exist in the SDUI registry. This avoids the awkward situation where "design drafts are rich, but SDUI cannot implement them."

### **7.3 Quality Assurance (QA)**

* **Screenshot Testing**: Since UI logic is on the server side, client unit tests are difficult to cover all scenarios. Airbnb and Lyft widely adopt screenshot testing (such as Android's Paparazzi) to automatically verify the rendering results of each component in the registry under different data combinations.

* **Schema Validation**: Strict Schema validation (JSON Schema Validation or Protobuf validation) is performed at the BFF layer to prevent malformed data from causing client crashes.

## **Chapter 8: Risk Management and Security Considerations**

While handing over UI control to the server side is flexible, it also introduces new security boundary issues.

### **8.1 Injection Attacks and Malicious Payloads**

If an attacker hijacks the API that sends down UI configurations or injects malicious data into the server side, the consequences would be catastrophic.

* **XSS Variants**: If SDUI components support rich text or HTML rendering, attackers may inject malicious scripts.

* **Phishing Components**: Attackers may insert a forged "enter password" component into a normal payment page.

* **Defense Strategies**:

  * **Strict Whitelist Mechanism**: The registry must strictly verify component types, discarding or degrading any types not on the whitelist.

  * **Content Sanitization**: Escape all text content.

  * **Certificate Pinning**: Prevent man-in-the-middle attacks from tampering with Schemas.

### **8.2 Deep Link Hijacking**

Interactions in SDUI often rely on Deep Links (such as uber://ride?id=123).

* **Risk**: Malicious apps may register the same URL Scheme, causing users to jump to malicious apps when clicking SDUI buttons.

* **Defense**: Enforce the use of **Universal Links (iOS)** and **App Links (Android)**, which ensure only official apps can respond to specific URLs through domain verification.

### **8.3 Schema Version Hell and Backward Compatibility**

One of the biggest challenges SDUI faces is version management. The server has launched a new component NewCard, but the registry in older clients does not have this Key.

* **Unknown Field Strategy**: Clients must have the ability to "ignore unknown fields" (Protobuf supports this natively, JSON requires manual handling).

* **Degraded Rendering (Fallback)**: The registry should configure default Fallback components (usually an empty view with zero height) to ensure other parts of the page display normally instead of crashing directly.

* **Version Negotiation**: Clients carry the supported Schema version number (X-Client-Version) in the request header, and the BFF sends down compatible UI structures based on the version number (for example, downgrading a new carousel to a static image).

## **Chapter 9: Conclusions and Industry Insights**

### **9.1 Summary of Lessons Learned**

1. **Don't Try to Reinvent the Browser**: Uber Screenflow's failure proves that attempting to build a universal cross-platform rendering engine is extremely expensive and inefficient. SDUI should be "configuration of native components," not "webification of native rendering."

2. **Type Safety is Crucial**: The success of Airbnb and Lyft largely stems from the strong type contracts brought by GraphQL and Protobuf. Loose JSON structures easily lead to runtime errors in large-scale collaboration.

3. **Toolchains Determine Success or Failure**: Without supporting visual construction platforms and automated testing tools, SDUI will only transfer client-side complexity to the backend without truly improving operational efficiency.

### **9.2 Future Outlook**

With the development of AI technology, future SDUI will no longer be just "operationally configured UI" but "AI-generated UI." Combined with large models (LLM), BFF can dynamically generate personalized UI structure streams (Streaming UI) based on users' real-time intentions, context, and historical behavior, pushing them directly to the client's registry for rendering.

For companies pursuing extreme iteration speed, SDUI is no longer an option but a necessary path in the evolution of mobile architecture. By building a robust registry pattern, enterprises can break through the shackles of app stores and achieve real-time delivery of business value.

---

## **Cited Works**

1. Server-Driven UI: Agile Interfaces Without App Releases - DZone, accessed December 17, 2025, [https://dzone.com/articles/server-driven-ui-agile-interfaces-without-app-releases](https://dzone.com/articles/server-driven-ui-agile-interfaces-without-app-releases)

2. The Journey to Server Driven UI At Lyft Bikes and Scooters | by Alex Hartwell, accessed December 17, 2025, [https://eng.lyft.com/the-journey-to-server-driven-ui-at-lyft-bikes-and-scooters-c19264a0378e](https://eng.lyft.com/the-journey-to-server-driven-ui-at-lyft-bikes-and-scooters-c19264a0378e)

3. Lyft's Journey through Mobile Networking | by Michael Rebello | Lyft Engineering, accessed December 17, 2025, [https://eng.lyft.com/lyfts-journey-through-mobile-networking-d8e13c938166](https://eng.lyft.com/lyfts-journey-through-mobile-networking-d8e13c938166)

4. Airbnb's Server-Driven UI System - Hacker News, accessed December 17, 2025, [https://news.ycombinator.com/item?id=27707423](https://news.ycombinator.com/item?id=27707423)

5. A Deep Dive into Airbnb's Server-Driven UI System | by Ryan Brooks - Medium, accessed December 17, 2025, [https://medium.com/airbnb-engineering/a-deep-dive-into-airbnbs-server-driven-ui-system-842244c5f5](https://medium.com/airbnb-engineering/a-deep-dive-into-airbnbs-server-driven-ui-system-842244c5f5)

6. Changing user interface with Airbnb's Ghost Platform - Okoone, accessed December 17, 2025, [https://www.okoone.com/spark/product-design-research/changing-user-interface-with-airbnbs-ghost-platform/](https://www.okoone.com/spark/product-design-research/changing-user-interface-with-airbnbs-ghost-platform/)

7. Taming Service-Oriented Architecture Using A Data-Oriented ..., accessed December 17, 2025, [https://medium.com/airbnb-engineering/taming-service-oriented-architecture-using-a-data-oriented-service-mesh-da771a841344](https://medium.com/airbnb-engineering/taming-service-oriented-architecture-using-a-data-oriented-service-mesh-da771a841344)

8. Viaduct, accessed December 17, 2025, [https://viaduct.airbnb.tech/](https://viaduct.airbnb.tech/)

9. Airbnb's Server-Driven UI Platform - InfoQ, accessed December 17, 2025, [https://www.infoq.com/news/2021/07/airbnb-server-driven-ui/](https://www.infoq.com/news/2021/07/airbnb-server-driven-ui/)

10. Building the New Uber Freight App as Lists of Modular, Reusable Components - Reddit, accessed December 17, 2025, [https://www.reddit.com/r/androiddev/comments/cz0vvs/building_the_new_uber_freight_app_as_lists_of/](https://www.reddit.com/r/androiddev/comments/cz0vvs/building_the_new_uber_freight_app_as_lists_of/)

11. Protocol Buffer Design: Principles and Practices for Collaborative Development | by Roman Kotenko | Lyft Engineering, accessed December 17, 2025, [https://eng.lyft.com/protocol-buffer-design-principles-and-practices-for-collaborative-development-8f5aa7e6ed85](https://eng.lyft.com/protocol-buffer-design-principles-and-practices-for-collaborative-development-8f5aa7e6ed85)

12. How Lyft Leveraged iOS Live Activities to Enhance User Experience - InfoQ, accessed December 17, 2025, [https://www.infoq.com/news/2024/04/lyft-live-activities-ios/](https://www.infoq.com/news/2024/04/lyft-live-activities-ios/)

13. uber/RIBs: Uber's cross-platform mobile architecture framework - Android Repository, accessed December 17, 2025, [https://github.com/uber/RIBs](https://github.com/uber/RIBs)

14. Building the New Uber Freight App as Lists of Modular, Reusable ..., accessed December 17, 2025, [https://www.uber.com/blog/uber-freight-app-architecture-design/](https://www.uber.com/blog/uber-freight-app-architecture-design/)

15. Screenflow: an unfinished attempt at a cross-platform server-driven ..., accessed December 17, 2025, [https://artem-tyurin.medium.com/screenflow-an-unfinished-attempt-at-a-cross-platform-server-driven-ui-at-uber-749c1bc1d89](https://artem-tyurin.medium.com/screenflow-an-unfinished-attempt-at-a-cross-platform-server-driven-ui-at-uber-749c1bc1d89)

16. RemoteCompose: Another Paradigm for Server-Driven UI in Jetpack Compose | by Jaewoong Eum | Nov, 2025 | ProAndroidDev, accessed December 17, 2025, [https://proandroiddev.com/remotecompose-another-paradigm-for-server-driven-ui-in-jetpack-compose-92186619ba8f](https://proandroiddev.com/remotecompose-another-paradigm-for-server-driven-ui-in-jetpack-compose-92186619ba8f)

17. Lyft reduced their code for UI components by as much as 60% using Jetpack Compose, accessed December 17, 2025, [https://android-developers.googleblog.com/2022/10/lyft-reduced-their-code-for-ui-components-using-jetpack-compose.html](https://android-developers.googleblog.com/2022/10/lyft-reduced-their-code-for-ui-components-using-jetpack-compose.html)

18. Android Dev Story: Lyft reduced their code for UI components by as much as 60% using Jetpack Compose - YouTube, accessed December 17, 2025, [https://www.youtube.com/watch?v=QO6Cg9MSpE8](https://www.youtube.com/watch?v=QO6Cg9MSpE8)

19. Airbnb's Ghost platform - Product Hunt, accessed December 17, 2025, [https://www.producthunt.com/newsletters/archive/9040-airbnb-s-ghost-platform](https://www.producthunt.com/newsletters/archive/9040-airbnb-s-ghost-platform)

20. Judo: No-code, server-driven UI for iOS and Android apps | Product Hunt, accessed December 17, 2025, [https://www.producthunt.com/products/judo](https://www.producthunt.com/products/judo)

21. DivKit is an open source Server-Driven UI (SDUI) framework. SDUI is a an emerging technique that leverage the server to build the user interfaces of their mobile app - GitHub, accessed December 17, 2025, [https://github.com/divkit/divkit](https://github.com/divkit/divkit)

22. User-centered Design System Resources | by Runi Goswami | Lyft Design+, accessed December 17, 2025, [https://design.lyft.com/user-centered-design-system-resources-fe721cd6432b](https://design.lyft.com/user-centered-design-system-resources-fe721cd6432b)

23. Server-Driven UI: What Airbnb, Netflix, and Lyft Learned Building Dynamic Mobile Experiences | by Aubrey Haskett | Dec, 2025 | Medium, accessed December 17, 2025, [https://medium.com/@aubreyhaskett/server-driven-ui-what-airbnb-netflix-and-lyft-learned-building-dynamic-mobile-experiences-20e346265305](https://medium.com/@aubreyhaskett/server-driven-ui-what-airbnb-netflix-and-lyft-learned-building-dynamic-mobile-experiences-20e346265305)

24. Building a Resilient BFF for Server-Driven UI in Mobile Apps - Medium, accessed December 17, 2025, [https://medium.com/@dfs.techblog/building-a-resilient-bff-for-server-driven-ui-in-mobile-apps-19431f0d0ace](https://medium.com/@dfs.techblog/building-a-resilient-bff-for-server-driven-ui-in-mobile-apps-19431f0d0ace)

25. Unsafe use of deep links | Security - Android Developers, accessed December 17, 2025, [https://developer.android.com/privacy-and-security/risks/unsafe-use-of-deeplinks](https://developer.android.com/privacy-and-security/risks/unsafe-use-of-deeplinks)

26. Navigating the Depths of Deep Link Security - Payatu, accessed December 17, 2025, [https://payatu.com/blog/navigating-the-depths-of-deep-link-security/](https://payatu.com/blog/navigating-the-depths-of-deep-link-security/)

27. Measuring the Insecurity of Mobile Deep Links of Android - USENIX, accessed December 17, 2025, [https://www.usenix.org/system/files/conference/usenixsecurity17/sec17-liu.pdf](https://www.usenix.org/system/files/conference/usenixsecurity17/sec17-liu.pdf)

28. Schema Evolution and Compatibility for Schema Registry on Confluent Platform, accessed December 17, 2025, [https://docs.confluent.io/platform/current/schema-registry/fundamentals/schema-evolution.html](https://docs.confluent.io/platform/current/schema-registry/fundamentals/schema-evolution.html)

29. Server-Driven UI Best Practices and Common Pitfalls - Nativeblocks, accessed December 17, 2025, [https://nativeblocks.io/blog/best-practices-and-common-pitfalls/](https://nativeblocks.io/blog/best-practices-and-common-pitfalls/)

30. Deliver 2025: Unveiling new platform features - Uber Freight, accessed December 17, 2025, [https://www.uberfreight.com/en-US/blog/deliver-2025-unveiling-new-platform-features](https://www.uberfreight.com/en-US/blog/deliver-2025-unveiling-new-platform-features)
