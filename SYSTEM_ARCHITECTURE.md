# System Architecture - Unique Staffing Professionals

## High-Level System Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        Browser[Web Browser]
        Mobile[Mobile Browser]
    end

    subgraph "CDN & Hosting"
        Netlify[Netlify CDN]
        Assets[Static Assets]
    end

    subgraph "Frontend Application"
        React[React 19 + TypeScript]
        Router[React Router]
        
        subgraph "State Management"
            Theme[ThemeProvider]
            Lang[LanguageProvider]
            Auth[AuthProvider]
            BizInfo[BusinessInfoProvider]
        end
        
        subgraph "UI Components"
            Public[Public Pages]
            Admin[Admin Dashboard]
            Forms[Application Forms]
            UI[shadcn/ui Components]
        end
    end

    subgraph "Backend Services"
        Supabase[Supabase Platform]
        
        subgraph "Supabase Services"
            DB[(PostgreSQL Database)]
            AuthSvc[Authentication]
            Storage[File Storage]
            RLS[Row Level Security]
        end
    end

    Browser --> Netlify
    Mobile --> Netlify
    Netlify --> Assets
    Netlify --> React
    
    React --> Router
    Router --> Theme
    Theme --> Lang
    Lang --> Auth
    Auth --> BizInfo
    
    BizInfo --> Public
    BizInfo --> Admin
    BizInfo --> Forms
    
    Public --> UI
    Admin --> UI
    Forms --> UI
    
    Auth --> Supabase
    Forms --> Supabase
    Admin --> Supabase
    
    Supabase --> DB
    Supabase --> AuthSvc
    Supabase --> Storage
    Supabase --> RLS
```

## Application Architecture

```mermaid
graph LR
    subgraph "Entry Point"
        Main[main.tsx]
    end
    
    subgraph "Root Component"
        App[App.tsx]
        ErrorBoundary[ErrorFallback]
    end
    
    subgraph "Context Providers"
        TP[ThemeProvider]
        LP[LanguageProvider]
        AP[AuthProvider]
        BP[BusinessInfoProvider]
    end
    
    subgraph "Routing"
        Routes[React Router]
        Home[Home Page]
        Login[Admin Login]
        Dashboard[Admin Dashboard]
        ServiceArea[Service Area Page]
    end
    
    Main --> App
    App --> ErrorBoundary
    ErrorBoundary --> TP
    TP --> LP
    LP --> AP
    AP --> BP
    BP --> Routes
    
    Routes --> Home
    Routes --> Login
    Routes --> Dashboard
    Routes --> ServiceArea
```

## Data Flow Architecture

```mermaid
sequenceDiagram
    participant User
    participant Browser
    participant React
    participant Context
    participant Supabase
    participant Database

    User->>Browser: Visit Site
    Browser->>React: Load Application
    React->>Context: Initialize Providers
    Context->>Browser: Check localStorage
    Browser-->>Context: Theme & Language Prefs
    
    User->>React: Submit Application
    React->>Context: Validate Form
    Context->>Supabase: Upload Resume
    Supabase->>Database: Store Applicant Data
    Database-->>Supabase: Confirm Save
    Supabase-->>React: Success Response
    React-->>User: Show Confirmation
    
    User->>React: Admin Login
    React->>Supabase: Authenticate
    Supabase->>Database: Verify Credentials
    Database-->>Supabase: Auth Token
    Supabase-->>Context: Set Auth State
    Context-->>React: Update UI
    React-->>User: Show Dashboard
```

## Component Architecture

```mermaid
graph TD
    subgraph "Page Components"
        HomePage[Home.tsx]
        AdminPage[AdminDashboard.tsx]
        LoginPage[AdminLogin.tsx]
        ServicePage[ServiceAreaPage.tsx]
    end
    
    subgraph "Feature Components"
        Hero[Hero Section]
        Services[Services Section]
        Industries[Industries Section]
        WhyUs[Why Choose Us]
        Testimonials[Testimonials]
        Contact[Contact Section]
        ApplyForm[Application Form]
    end
    
    subgraph "Admin Components"
        Analytics[AnalyticsDashboard]
        ApplicantList[ApplicantList]
        ApplicantDetail[ApplicantDetail]
        BizManager[BusinessInfoManager]
    end
    
    subgraph "Shared Components"
        Nav[Navigation]
        Footer[Footer]
        LangToggle[LanguageToggle]
        ThemeToggle[ThemeToggle]
    end
    
    subgraph "UI Primitives"
        Button[Button]
        Card[Card]
        Dialog[Dialog]
        Form[Form]
        Input[Input]
        Select[Select]
        Table[Table]
    end
    
    HomePage --> Hero
    HomePage --> Services
    HomePage --> Industries
    HomePage --> WhyUs
    HomePage --> Testimonials
    HomePage --> Contact
    HomePage --> ApplyForm
    
    AdminPage --> Analytics
    AdminPage --> ApplicantList
    AdminPage --> ApplicantDetail
    AdminPage --> BizManager
    
    Hero --> Nav
    Hero --> LangToggle
    Hero --> ThemeToggle
    
    ApplyForm --> Form
    ApplyForm --> Input
    ApplyForm --> Button
    
    Analytics --> Card
    ApplicantList --> Table
    ApplicantDetail --> Dialog
```

## Database Schema

```mermaid
erDiagram
    APPLICANTS {
        uuid id PK
        timestamp created_at
        timestamp updated_at
        varchar full_name
        varchar email
        varchar phone
        varchar position_interested
        int experience_years
        text resume_url
        varchar resume_filename
        text cover_letter
        enum status
        text notes
    }
    
    BUSINESS_INFO {
        uuid id PK
        timestamp created_at
        timestamp updated_at
        varchar company_name
        varchar phone
        varchar email
        text address
        jsonb hours
        text description
    }
    
    TESTIMONIALS {
        uuid id PK
        timestamp created_at
        timestamp updated_at
        varchar author_name
        varchar author_title
        int rating
        text content
        boolean is_active
    }
    
    TESTIMONIAL_TRANSLATIONS {
        uuid id PK
        uuid testimonial_id FK
        varchar language
        text content
        timestamp created_at
    }
    
    SERVICE_TRANSLATIONS {
        uuid id PK
        varchar service_key
        varchar language
        varchar title
        text description
        timestamp created_at
    }
    
    TESTIMONIALS ||--o{ TESTIMONIAL_TRANSLATIONS : has
```

## Authentication Flow

```mermaid
stateDiagram-v2
    [*] --> Unauthenticated
    
    Unauthenticated --> LoginPage : Navigate to /admin/login
    LoginPage --> Authenticating : Submit Credentials
    
    Authenticating --> Authenticated : Success
    Authenticating --> LoginPage : Failure
    
    Authenticated --> Dashboard : Redirect
    Dashboard --> ViewingApplicants : View List
    Dashboard --> ManagingBusiness : Edit Info
    Dashboard --> ViewingAnalytics : View Stats
    
    ViewingApplicants --> ReviewingApplicant : Select Applicant
    ReviewingApplicant --> UpdatingStatus : Change Status
    UpdatingStatus --> ViewingApplicants : Save
    
    Authenticated --> Unauthenticated : Logout
    Unauthenticated --> [*]
```

## File Upload Flow

```mermaid
sequenceDiagram
    participant User
    participant Form
    participant Validation
    participant Supabase
    participant Storage
    participant Database

    User->>Form: Select Resume File
    Form->>Validation: Check File Type
    Validation->>Validation: Validate Size (<5MB)
    Validation->>Validation: Validate Type (PDF/DOC)
    
    alt Valid File
        Validation->>Form: File OK
        User->>Form: Submit Application
        Form->>Supabase: Upload to Storage
        Supabase->>Storage: Store in 'resumes' bucket
        Storage-->>Supabase: Return URL
        Supabase->>Database: Save Applicant + URL
        Database-->>Supabase: Confirm
        Supabase-->>Form: Success
        Form-->>User: Show Confirmation
    else Invalid File
        Validation-->>Form: Error
        Form-->>User: Show Error Message
    end
```

## Internationalization Architecture

```mermaid
graph TD
    subgraph "Language Detection"
        Browser[Browser Language]
        LocalStorage[localStorage]
        Default[Default: English]
    end
    
    subgraph "Translation System"
        Context[LanguageContext]
        Translations[translations.ts]
        Hook[useLanguage Hook]
    end
    
    subgraph "Supported Languages"
        EN[English]
        ES[Spanish]
        FR[French]
    end
    
    subgraph "Components"
        Hero[Hero Section]
        Services[Services]
        Footer[Footer]
        Forms[Forms]
    end
    
    Browser --> Context
    LocalStorage --> Context
    Default --> Context
    
    Context --> Translations
    Translations --> EN
    Translations --> ES
    Translations --> FR
    
    Context --> Hook
    
    Hook --> Hero
    Hook --> Services
    Hook --> Footer
    Hook --> Forms
```

## Theme System Architecture

```mermaid
graph LR
    subgraph "Theme Detection"
        System[System Preference]
        Storage[localStorage]
        Default[Default: Light]
    end
    
    subgraph "Theme Provider"
        NextThemes[next-themes]
        ThemeContext[Theme Context]
    end
    
    subgraph "CSS Variables"
        Root[:root]
        Dark[.dark]
        OKLCH[OKLCH Color Space]
    end
    
    subgraph "Components"
        All[All Components]
        Tailwind[Tailwind Classes]
    end
    
    System --> NextThemes
    Storage --> NextThemes
    Default --> NextThemes
    
    NextThemes --> ThemeContext
    ThemeContext --> Root
    ThemeContext --> Dark
    
    Root --> OKLCH
    Dark --> OKLCH
    
    OKLCH --> Tailwind
    Tailwind --> All
```

## Security Architecture

```mermaid
graph TB
    subgraph "Public Access"
        PublicPages[Public Pages]
        ApplicationForm[Application Form]
    end
    
    subgraph "Authentication Layer"
        Login[Login Page]
        SupabaseAuth[Supabase Auth]
        Session[Session Management]
    end
    
    subgraph "Protected Resources"
        AdminDash[Admin Dashboard]
        ApplicantData[Applicant Data]
        FileAccess[Resume Files]
    end
    
    subgraph "Database Security"
        RLS[Row Level Security]
        Policies[RLS Policies]
    end
    
    subgraph "Storage Security"
        PrivateBucket[Private Bucket]
        SignedURLs[Signed URLs]
    end
    
    PublicPages --> ApplicationForm
    ApplicationForm --> SupabaseAuth
    
    Login --> SupabaseAuth
    SupabaseAuth --> Session
    
    Session --> AdminDash
    AdminDash --> ApplicantData
    AdminDash --> FileAccess
    
    ApplicantData --> RLS
    RLS --> Policies
    
    FileAccess --> PrivateBucket
    PrivateBucket --> SignedURLs
```

## Deployment Pipeline

```mermaid
graph LR
    subgraph "Development"
        Local[Local Dev]
        Git[Git Commit]
    end
    
    subgraph "Version Control"
        GitHub[GitHub Repository]
        Branch[Feature Branch]
        Main[Main Branch]
    end
    
    subgraph "CI/CD"
        NetlifyBuild[Netlify Build]
        TypeCheck[Type Check]
        Lint[ESLint]
        Build[Vite Build]
    end
    
    subgraph "Deployment"
        Preview[Preview Deploy]
        Production[Production Deploy]
        CDN[Global CDN]
    end
    
    Local --> Git
    Git --> GitHub
    GitHub --> Branch
    Branch --> NetlifyBuild
    
    NetlifyBuild --> TypeCheck
    TypeCheck --> Lint
    Lint --> Build
    
    Build --> Preview
    
    Branch --> Main
    Main --> NetlifyBuild
    Build --> Production
    Production --> CDN
```

## Performance Optimization

```mermaid
graph TD
    subgraph "Build Optimization"
        Vite[Vite Bundler]
        TreeShake[Tree Shaking]
        CodeSplit[Code Splitting]
        Minify[Minification]
    end
    
    subgraph "Runtime Optimization"
        LazyLoad[Lazy Loading]
        Memoization[React Memoization]
        VirtualScroll[Virtual Scrolling]
    end
    
    subgraph "Asset Optimization"
        ImageOpt[Image Optimization]
        IconOpt[Icon Optimization]
        FontOpt[Font Loading]
    end
    
    subgraph "Caching Strategy"
        CDNCache[CDN Caching]
        BrowserCache[Browser Cache]
        SWCache[Service Worker]
    end
    
    Vite --> TreeShake
    Vite --> CodeSplit
    Vite --> Minify
    
    TreeShake --> LazyLoad
    CodeSplit --> LazyLoad
    
    LazyLoad --> Memoization
    Memoization --> VirtualScroll
    
    ImageOpt --> CDNCache
    IconOpt --> CDNCache
    FontOpt --> CDNCache
    
    CDNCache --> BrowserCache
    BrowserCache --> SWCache
```

## Monitoring & Observability

```mermaid
graph TB
    subgraph "Application"
        Frontend[React App]
        ErrorBoundary[Error Boundary]
        Console[Console Logs]
    end
    
    subgraph "Netlify Monitoring"
        Analytics[Netlify Analytics]
        Logs[Build Logs]
        Functions[Function Logs]
    end
    
    subgraph "Supabase Monitoring"
        DBMetrics[Database Metrics]
        AuthMetrics[Auth Metrics]
        StorageMetrics[Storage Metrics]
    end
    
    subgraph "User Monitoring"
        Performance[Performance API]
        Errors[Error Tracking]
        Usage[Usage Analytics]
    end
    
    Frontend --> ErrorBoundary
    ErrorBoundary --> Console
    
    Frontend --> Analytics
    Frontend --> Performance
    Frontend --> Errors
    Frontend --> Usage
    
    Analytics --> Logs
    Logs --> Functions
    
    Frontend --> DBMetrics
    Frontend --> AuthMetrics
    Frontend --> StorageMetrics
```

## Technology Stack

```mermaid
mindmap
  root((Unique Staffing))
    Frontend
      React 19
      TypeScript
      Vite
      React Router
    Styling
      Tailwind CSS 4
      shadcn/ui
      Radix UI
      OKLCH Colors
    State Management
      React Context
      next-themes
      Custom Providers
    Forms
      React Hook Form
      Zod Validation
    Backend
      Supabase
        PostgreSQL
        Authentication
        Storage
        RLS
    Deployment
      Netlify
        CDN
        Build Pipeline
        Environment Variables
    Development
      ESLint
      TypeScript
      Git
      GitHub
```

## Key Features Map

```mermaid
mindmap
  root((Features))
    Public Site
      Job Listings
      Application Form
      Company Info
      Testimonials
      Contact
    Internationalization
      English
      Spanish
      French
      Auto-detection
      Manual Toggle
    Theming
      Light Mode
      Dark Mode
      System Preference
      OKLCH Colors
    Admin Dashboard
      Applicant Management
      Status Tracking
      Resume Viewing
      Analytics
      Business Info Editor
    Security
      Authentication
      RLS Policies
      Private Storage
      Secure Sessions
    Accessibility
      ARIA Labels
      Keyboard Navigation
      Screen Reader Support
      Focus Management
      Skip Links
```

---

**Document Version**: 1.0.0  
**Last Updated**: December 2025  
**Maintained By**: Development Team
