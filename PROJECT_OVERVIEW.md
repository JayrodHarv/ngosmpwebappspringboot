# SMP Portal - Project Overview

**Project Name:** NGO SMP Web App (Spring Boot)  
**Version:** 0.0.1-SNAPSHOT  
**Author:** Jared Harvey  
**Date Created:** 2024-02-22  
**Purpose:** A web application for managing Minecraft builds, votes, worlds, and users in a collaborative SMP environment.

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Architecture Overview](#architecture-overview)
3. [Database Schema](#database-schema)
4. [Data Models](#data-models)
5. [View Models](#view-models)
6. [DAOs & Data Access](#daos--data-access)
7. [Services & Business Logic](#services--business-logic)
8. [Controllers & Endpoints](#controllers--endpoints)
9. [Thymeleaf Layouts & Fragments](#thymeleaf-layouts--fragments)
10. [Authentication & Security](#authentication--security)
11. [Configuration](#configuration)

---

## Tech Stack

### Backend Framework
- **Spring Boot:** 4.0.6
- **Java:** 21
- **Build Tool:** Maven (with wrapper scripts)

### Web & View Layer
- **Web Framework:** Spring MVC (spring-boot-starter-web)
- **Template Engine:** Thymeleaf 3+
- **Layout Dialect:** thymeleaf-layout-dialect (for decorator pattern)
- **Security Integration:** thymeleaf-extras-springsecurity6

### Database & Persistence
- **Database:** MariaDB
- **JDBC Driver:** org.mariadb.jdbc
- **Data Access:** Spring Data JDBC (NamedParameterJdbcTemplate)
  - Custom DAOs using raw SQL queries and stored procedures
  - No ORM (not using JPA/Hibernate)

### Authentication & Authorization
- **Security:** Spring Security 6+
- **Permission Model:** Role-based access control with granular permissions

### Utilities & Productivity
- **Boilerplate Reduction:** Lombok (automatic getters, setters, constructors)
- **Bean Validation:** Spring Validation
- **Development Tools:** Spring Boot DevTools (hot reload)

### Frontend UI
- **CSS Framework:** Bootstrap 5.3.3 (CDN)
- **Icon Library:** Bootstrap Icons 1.11.3 (CDN)
- **Custom CSS:** main.css, votes.css

### Testing
- Spring Boot Test (JUnit 5, Mockito)

### File Upload & Storage
- **Multipart Upload:** Spring servlet multipart handling
- **Max File Size:** 10MB (configurable)
- **Storage Location:** `./uploads/` directory (disk-based)
- **File Naming:** SHA-256 hash for deduplication

---

## Architecture Overview

### MVC Pattern
The application follows a classic Spring MVC architecture:

```
Controller Layer
    ↓
Service Layer (Business Logic)
    ↓
DAO Layer (Data Access)
    ↓
Database (MariaDB)
    ↓
Thymeleaf Templates (View)
```

### Package Structure
```
com.jayrodharv.ngosmpwebappspringboot/
├── config/              # Spring configuration
│   ├── MvcConfig.java
│   └── SecurityConfig.java
├── controller/          # HTTP endpoints
│   ├── AuthController
│   ├── BuildController
│   ├── VoteController
│   ├── UserController
│   ├── WorldController
│   ├── RoleController
│   ├── HomeController
│   └── GenericErrorController
├── service/             # Business logic
│   ├── BuildService
│   ├── VoteService
│   ├── UserService
│   ├── ImageService
│   ├── WorldService
│   ├── RoleService
│   └── BuildTypeService
├── dao/                 # Data access
│   ├── BuildDAO
│   ├── VoteDAO
│   ├── UserDAO
│   ├── ImageDAO
│   ├── WorldDAO
│   ├── RoleDAO
│   └── BuildTypeDAO
└── model/               # Entity models & view models
    ├── User (entity)
    ├── UserVM (view model)
    ├── Build (entity)
    ├── BuildVM (view model)
    ├── Vote (entity)
    ├── VoteVM (view model)
    ├── VoteOption (entity)
    ├── VoteOptionVM (view model)
    ├── UserVote (entity)
    ├── UserVoteVM (view model)
    ├── World (entity)
    ├── BuildType (entity)
    ├── Role (entity)
    ├── Image (entity)
    └── BuildImage (entity)
```

---

## Database Schema

### Tables

#### 1. **Role**
Role-based access control with granular permissions.
```sql
Columns:
  - RoleID (VARCHAR 255, PRIMARY KEY)
  - CanAddBuilds, CanEditAllBuilds, CanDeleteAllBuilds (BIT)
  - CanViewBuildTypes, CanAddBuildTypes, CanEditBuildTypes, CanDeleteBuildTypes (BIT)
  - CanViewWorlds, CanAddWorlds, CanEditWorlds, CanDeleteWorlds (BIT)
  - CanViewAllVotes, CanAddVotes, CanEditAllVotes, CanDeleteAllVotes (BIT)
  - CanViewRoles, CanAddRoles, CanEditRoles, CanDeleteRoles (BIT)
  - CanViewUsers, CanAddUsers, CanEditUsers, CanBanUsers (BIT)
  - Description (VARCHAR 255)
```

#### 2. **User**
User account and authentication.
```sql
Columns:
  - UserID (VARCHAR 255, PRIMARY KEY) [Email address]
  - DisplayName (VARCHAR 255, UNIQUE)
  - Password (VARCHAR 255) [BCrypt hash]
  - Language (VARCHAR 255, DEFAULT 'en-US')
  - Status (ENUM: active, inactive, locked)
  - RoleID (VARCHAR 255, FK → Role, DEFAULT 'User')
  - PfpImageID (INT, FK → Image)
  - CreatedAt (DATETIME, DEFAULT CURRENT_TIMESTAMP)
  - LastLoggedIn (DATETIME)
  - UpdatedAt (DATETIME, ON UPDATE CURRENT_TIMESTAMP)
```

#### 3. **Image**
File metadata and storage information.
```sql
Columns:
  - ImageID (INT, PRIMARY KEY, AUTO_INCREMENT)
  - FileName (VARCHAR 255)
  - MimeType (VARCHAR 100)
  - FileSize (BIGINT)
  - FilePath (VARCHAR 500)
  - FileHash (CHAR 64, UNIQUE) [SHA-256]
  - CreatedAt (DATETIME, DEFAULT CURRENT_TIMESTAMP)
```

#### 4. **World**
Minecraft world/server instances.
```sql
Columns:
  - WorldID (VARCHAR 255, PRIMARY KEY)
  - DateStarted (DATE)
  - Description (TEXT)
```

#### 5. **BuildType**
Categories for builds (e.g., "House", "Farm", "Monument").
```sql
Columns:
  - BuildTypeID (VARCHAR 255, PRIMARY KEY)
  - Description (TEXT)
```

#### 6. **Build**
Individual build entries.
```sql
Columns:
  - BuildID (VARCHAR 100, PRIMARY KEY) [Build name]
  - UserID (VARCHAR 255, FK → User)
  - WorldID (VARCHAR 255, FK → World)
  - BuildTypeID (VARCHAR 255, FK → BuildType)
  - DateBuilt (DATE)
  - XCoord, YCoord, ZCoord (INT) [Minecraft coordinates]
  - CreatedAt (DATETIME, DEFAULT CURRENT_TIMESTAMP)
  - Description (TEXT)
```

#### 7. **BuildImage**
Association between builds and images (gallery).
```sql
Columns:
  - BuildID (VARCHAR 100, FK → Build, PK composite)
  - ImageID (INT, FK → Image, PK composite)
  - IsPrimary (BIT, DEFAULT 0)
  - SortOrder (INT, DEFAULT 0)
```

#### 8. **Vote**
Polls/votes for community decisions.
```sql
Columns:
  - VoteID (VARCHAR 255, PRIMARY KEY)
  - UserID (VARCHAR 255, FK → User)
  - Description (TEXT)
  - StartTime (DATETIME)
  - EndTime (DATETIME)
```

#### 9. **VoteOption**
Individual options within a vote.
```sql
Columns:
  - OptionID (INT, PRIMARY KEY, AUTO_INCREMENT)
  - VoteID (VARCHAR 255, FK → Vote)
  - Title (VARCHAR 255)
  - Description (TEXT)
  - ImageID (INT, FK → Image)
  - UNIQUE(VoteID, Title)
```

#### 10. **UserVote**
User's vote selections.
```sql
Columns:
  - UserID (VARCHAR 255, FK → User)
  - VoteID (VARCHAR 255, FK → Vote)
  - OptionID (INT, FK → VoteOption)
  - VoteTime (DATETIME, DEFAULT CURRENT_TIMESTAMP)
  - UNIQUE(UserID, VoteID) [One vote per user per poll]
```

### Cascade Rules
- **Foreign Key Actions:**
  - **ON UPDATE CASCADE** (most relationships)
  - **ON DELETE SET NULL** (for optional user references)
  - **ON DELETE CASCADE** (for dependent data like BuildImage)

---

## Data Models

### Entity Models (map directly to database tables)

#### **User**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class User {
    private String userId;          // email (PK)
    private String displayName;
    private String password;        // BCrypt hash
    private String language;
    private String status;          // active | inactive | locked
    private String roleId;
    private LocalDateTime createdAt;
    private LocalDateTime lastLoggedIn;
    private LocalDateTime updatedAt;
    private Integer pfpImageId;
    
    public boolean isActive() { return "active".equalsIgnoreCase(status); }
    public boolean isLocked() { return "locked".equalsIgnoreCase(status); }
    public boolean isInactive() { return "inactive".equalsIgnoreCase(status); }
}
```

#### **Build**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class Build {
    private String buildId;
    private String userId;
    private String worldId;
    private String buildTypeId;
    private LocalDate dateBuilt;
    private Integer xCoord;
    private Integer yCoord;
    private Integer zCoord;
    private LocalDateTime createdAt;
    private String description;
}
```

#### **Vote**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class Vote {
    private String voteId;
    private String userId;
    private String description;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    
    public boolean isActive() { /* checks if current time is between start/end */ }
    public boolean isConcluded() { /* checks if endTime passed */ }
    public boolean isPending() { /* checks if startTime not reached */ }
}
```

#### **VoteOption**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class VoteOption {
    private Integer optionId;
    private String voteId;
    private String title;
    private String description;
    private Integer imageId;
}
```

#### **UserVote**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class UserVote {
    private String userId;
    private String voteId;
    private Integer optionId;
    private LocalDateTime voteTime;
}
```

#### **World**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class World {
    private String worldId;
    private LocalDate dateStarted;
    private String description;
}
```

#### **BuildType**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class BuildType {
    private String buildTypeId;
    private String description;
}
```

#### **Role**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class Role {
    private String roleId;
    private String description;
    
    // Build permissions
    private boolean canAddBuilds;
    private boolean canEditAllBuilds;
    private boolean canDeleteAllBuilds;
    
    // BuildType permissions
    private boolean canViewBuildTypes;
    private boolean canAddBuildTypes;
    private boolean canEditBuildTypes;
    private boolean canDeleteBuildTypes;
    
    // World permissions
    private boolean canViewWorlds;
    private boolean canAddWorlds;
    private boolean canEditWorlds;
    private boolean canDeleteWorlds;
    
    // Vote permissions
    private boolean canViewAllVotes;
    private boolean canAddVotes;
    private boolean canEditAllVotes;
    private boolean canDeleteAllVotes;
    
    // Role permissions
    private boolean canViewRoles;
    private boolean canAddRoles;
    private boolean canEditRoles;
    private boolean canDeleteRoles;
    
    // User permissions
    private boolean canViewUsers;
    private boolean canAddUsers;
    private boolean canEditUsers;
    private boolean canBanUsers;
}
```

#### **Image**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class Image {
    private Integer imageId;
    private String fileName;
    private String mimeType;
    private Long fileSize;
    private String filePath;
    private LocalDateTime createdAt;
    private String fileHash;  // SHA-256
}
```

#### **BuildImage**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class BuildImage {
    private String buildId;
    private Integer imageId;
    private boolean isPrimary;
    private Integer sortOrder;
}
```

---

## View Models

View Models (VMs) are used to denormalize data for presentation. They typically combine data from multiple entities or add computed fields.

### **BuildVM**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class BuildVM {
    // Build fields
    private String buildId;
    private String userId;
    private LocalDate dateBuilt;
    private Integer xCoord;
    private Integer yCoord;
    private Integer zCoord;
    private LocalDateTime createdAt;
    private String buildDescription;

    // World fields (denormalized)
    private String worldId;
    private LocalDate worldDateStarted;
    private String worldDescription;

    // BuildType fields (denormalized)
    private String buildTypeId;
    private String buildTypeDescription;

    // Builder/User fields (denormalized)
    private String userDisplayName;

    // Primary image (denormalized from BuildImage + Image join)
    private Integer imageId;
    private String fileName;
    private String mimeType;
    private String filePath;

    // Full image gallery (populated by service, not stored in DB)
    private List<Image> images;
    
    // Helper methods
    public boolean hasPrimaryImage() { /* ... */ }
    public String coordString() { /* returns "X, Y, Z" */ }
}
```

**Source:** `sp_get_builds` stored procedure returns denormalized columns; Service hydrates the `images` list.

### **VoteVM**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class VoteVM {
    // Vote fields
    private String voteId;
    private String userId;
    private String description;
    private LocalDateTime startTime;
    private LocalDateTime endTime;

    // User fields (denormalized)
    private String displayName;

    // Aggregated counts
    private int totalOptions;
    private int totalVotes;

    // Related entities
    private List<VoteOptionVM> options;
    private List<UserVoteVM> userVotes;
    
    // Helper methods
    public boolean isActive() { /* ... */ }
    public boolean isConcluded() { /* ... */ }
    public boolean isPending() { /* ... */ }
    public boolean isDraft() { /* no start/end times set */ }
}
```

### **VoteOptionVM**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class VoteOptionVM {
    private Integer optionId;
    private String voteId;
    private String title;
    private String description;
    private Integer imageId;

    // Additional fields for view model
    private int voteCount;
    private Image image;
    
    public boolean hasImage() { return imageId != null && image != null; }
}
```

### **UserVoteVM**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class UserVoteVM {
    private String userId;
    private String voteId;
    private Integer optionId;
    private LocalDateTime voteTime;
    
    // Denormalized user data
    private String userDisplayName;
}
```

### **UserVM**
```java
@Data @NoArgsConstructor @AllArgsConstructor
public class UserVM {
    // Similar to User entity, may include additional denormalized Role information
}
```

---

## DAOs & Data Access

### **DAO Layer Pattern**

All DAOs use `NamedParameterJdbcTemplate` for raw SQL queries (no ORM). Each DAO:
- Uses `@Repository` annotation (Spring component)
- Injects `NamedParameterJdbcTemplate` via constructor
- Defines `RowMapper` instances for result mapping
- Calls stored procedures and raw SQL queries

### **BuildDAO**
```java
@Repository
public class BuildDAO {
    private final NamedParameterJdbcTemplate jdbc;
    
    // Methods:
    public List<BuildVM> findAll(int pageSize, int offset, 
                                  String worldId, String buildTypeId, String userDisplayName)
    public Optional<BuildVM> findById(String buildId)
    public List<BuildVM> findByUser(String userId)
    public List<Image> findImages(String buildId)
    public void insert(Build build)
    public void update(Build build)
    public void delete(String buildId)
}
```
**Queries:** Uses `sp_get_builds` stored procedure with filters; manually hydrates related images.

### **VoteDAO**
```java
@Repository
public class VoteDAO {
    // Methods:
    public List<VoteVM> findAll(int pageSize, int offset)
    public Optional<VoteVM> findById(String voteId)
    public List<VoteOptionVM> findOptions(String voteId)
    public List<UserVoteVM> findUserVotes(String voteId)
    public Optional<UserVote> findUserVote(String userId, String voteId)
    public void insert(Vote vote)
    public void update(Vote vote)
    public void delete(String voteId)
    public void insertUserVote(UserVote userVote)
    public void updateUserVote(UserVote userVote)
    public void insertOption(VoteOption option)
}
```

### **UserDAO**
```java
@Repository
public class UserDAO {
    // Methods:
    public Optional<User> findById(String userId)  // by email/PK
    public Optional<User> findByDisplayName(String displayName)
    public List<User> findAll()
    public void insert(User user)
    public void update(User user)
    public void delete(String userId)
}
```

### **ImageDAO**
```java
@Repository
public class ImageDAO {
    // Methods:
    public Optional<Image> findById(Integer imageId)
    public Optional<Image> findByHash(String hash)
    public void insert(Image image)
    public void delete(Integer imageId)
}
```

### **WorldDAO, BuildTypeDAO, RoleDAO**
Similar pattern:
- CRUD operations (Create, Read, Update, Delete)
- Query by PK and other filters
- Map results to model objects

---

## Services & Business Logic

### **Service Layer Pattern**

Services (`@Service` beans) contain business logic:
- Call one or more DAOs
- Perform validation
- Handle file operations
- Manage related data (e.g., hydrating images for builds)
- Throw exceptions for error conditions

### **BuildService**
```java
@Service
public class BuildService {
    private final BuildDAO buildDAO;
    private final ImageService imageService;
    
    // Methods:
    public List<BuildVM> findAll(int page, int pageSize, 
                                  String worldId, String buildTypeId, String userDisplayName)
    public Optional<BuildVM> findById(String buildId)
        // Hydrates full image gallery
    public List<BuildVM> findByUser(String userId)
    public void create(Build build)
    public void update(Build build)
    public void delete(String buildId)
    public void addImage(String buildId, MultipartFile file, boolean isPrimary)
    public void removeImage(String buildId, Integer imageId)
}
```

### **VoteService**
```java
@Service
public class VoteService {
    private final VoteDAO voteDAO;
    private final ImageService imageService;
    
    // Methods:
    public List<VoteVM> findAll(int page, int pageSize)
    public Optional<VoteVM> findById(String voteId)
        // Hydrates options, user votes, images
    public void create(Vote vote)
    public void update(Vote vote)
    public void delete(String voteId)
    public void addOption(VoteOption option, Optional<MultipartFile> image)
    public void removeOption(Integer optionId)
    public void castVote(String userId, String voteId, Integer optionId)
    public void updateVote(String userId, String voteId, Integer newOptionId)
}
```

### **ImageService**
```java
@Service
public class ImageService {
    private final ImageDAO imageDAO;
    private final String uploadDir;
    
    // Methods:
    public Image saveImage(MultipartFile file)
        // SHA-256 hash for deduplication, disk storage
    public Optional<Image> getImage(Integer imageId)
    public void deleteImage(Integer imageId)
    public String getImageUrl(String filePath)
}
```

### **UserService, WorldService, BuildTypeService, RoleService**
Similar patterns with CRUD and business logic specific to each domain.

---

## Controllers & Endpoints

### **Controller Layer Pattern**

Controllers (`@Controller`) map HTTP requests to handler methods:
- Use `@RequestMapping` at class level
- Use `@GetMapping`, `@PostMapping`, etc. for endpoints
- Return view names (Thymeleaf templates)
- Use `Model` to pass data to views
- Use `RedirectAttributes` for flash messages
- Use Spring Security annotations for authorization

### **BuildController**
```java
@Controller
@RequestMapping("/builds")
public class BuildController {
    
    // Endpoints:
    
    @GetMapping
    public String list(@RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "12") int size,
                       @RequestParam(required = false) String worldId,
                       @RequestParam(required = false) String buildTypeId,
                       @RequestParam(required = false) String displayName,
                       Model model)
    // Returns: build/list.html
    
    @GetMapping("/{buildId}")
    public String detail(@PathVariable String buildId, Model model)
    // Returns: build/detail.html
    
    @GetMapping("/new")
    public String newForm(Model model)
    // Returns: build/form.html
    
    @PostMapping
    public String create(Build build, 
                        @RequestParam(required = false) MultipartFile[] images,
                        RedirectAttributes attrs)
    // Returns: redirect:/builds/{buildId}
    
    @PostMapping("/{buildId}/edit")
    public String update(@PathVariable String buildId, Build build, RedirectAttributes attrs)
    // Returns: redirect:/builds/{buildId}
    
    @PostMapping("/{buildId}/delete")
    public String delete(@PathVariable String buildId, RedirectAttributes attrs)
    // Returns: redirect:/builds
}
```

### **VoteController**
```java
@Controller
@RequestMapping("/votes")
public class VoteController {
    
    @GetMapping
    public String list(@RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "12") int size,
                       Model model)
    // Returns: vote/list.html
    
    @GetMapping("/{voteId}")
    public String detail(@PathVariable String voteId,
                        @AuthenticationPrincipal UserDetails userDetails,
                        Model model)
    // Returns: vote/detail.html
    
    @GetMapping("/new")
    public String newForm(Model model)
    // Returns: vote/form.html
    
    @PostMapping
    public String create(Vote vote, RedirectAttributes attrs)
    
    @PostMapping("/{voteId}/vote")
    public String castVote(@PathVariable String voteId,
                          @RequestParam Integer optionId,
                          @AuthenticationPrincipal UserDetails userDetails,
                          RedirectAttributes attrs)
}
```

### **Other Controllers**
- **AuthController**: Login/registration (`/auth/login`, `/auth/register`)
- **UserController**: User management (`/users`, `/users/{userId}`)
- **WorldController**: World CRUD (`/worlds`)
- **RoleController**: Role management (`/roles`)
- **HomeController**: Home page (`/`)
- **GenericErrorController**: Error handling (`/error`)

---

## Thymeleaf Layouts & Fragments

### **Master Layout: `layouts/main.html`**

Base template using layout dialect decorator pattern:

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org"
      xmlns:layout="http://www.ultraq.net.nz/thymeleaf/layout"
      xmlns:sec="http://www.thymeleaf.org/extras/spring-security">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title layout:title-pattern="$CONTENT_TITLE - SMP Portal">SMP Portal</title>
    
    <!-- Bootstrap 5.3.3 + Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    
    <!-- Custom styles -->
    <link rel="stylesheet" th:href="@{/css/main.css}"/>
    
    <!-- Per-page head additions (scripts, extra styles) -->
    <th:block layout:fragment="head"/>
</head>
<body class="d-flex flex-column min-vh-100">
    
    <!-- Navbar fragment -->
    <th:block th:replace="~{fragments/navbar :: navbar}"/>

    <!-- Flash messages container -->
    <div class="container mt-3">
        <th:block th:replace="~{fragments/alerts :: alerts}"/>
    </div>

    <!-- Main content (child page overrides) -->
    <main layout:fragment="content" class="container my-4 flex-grow-1">
    </main>

    <!-- Footer fragment -->
    <th:block th:replace="~{fragments/footer :: footer}"/>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Per-page scripts -->
    <th:block layout:fragment="scripts"/>
</body>
</html>
```

**Key Features:**
- `layout:decorate` (in child templates) specifies this layout
- `layout:fragment="content"` - main content area (overridden by child pages)
- `layout:title-pattern` - automatic page title concatenation
- `layout:fragment="head"` - per-page styles
- `layout:fragment="scripts"` - per-page scripts
- Fragments included via `th:replace`

### **Fragment: `fragments/navbar.html`**

Navigation bar with conditional Admin section:

```html
<nav th:fragment="navbar" class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand fw-bold" th:href="@{/}">
            <i class="bi bi-pick me-1"></i> SMP Portal
        </a>
        
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
            <span class="navbar-toggler-icon"></span>
        </button>
        
        <div class="collapse navbar-collapse" id="navbarMain">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link" th:href="@{/builds}">
                        <i class="bi bi-buildings"></i> Builds
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" th:href="@{/votes}">
                        <i class="bi bi-check2-square"></i> Votes
                    </a>
                </li>
                <!-- Admin dropdown (only visible to Admins) -->
                <li class="nav-item dropdown" sec:authorize="hasRole('Admin')">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        <i class="bi bi-shield-lock"></i> Admin
                    </a>
                    <ul class="dropdown-menu dropdown-menu-dark">
                        <li><a class="dropdown-item" th:href="@{/users}">
                            <i class="bi bi-people"></i> Users</a></li>
                        <li><a class="dropdown-item" th:href="@{/roles}">
                            <i class="bi bi-key"></i> Roles</a></li>
                        <li><hr class="dropdown-divider"/></li>
                        <li><a class="dropdown-item" th:href="@{/worlds}">
                            <i class="bi bi-globe"></i> Worlds</a></li>
                        <li><a class="dropdown-item" th:href="@{/buildtypes}">
                            <i class="bi bi-tags"></i> Build Types</a></li>
                    </ul>
                </li>
            </ul>
            
            <!-- Right side: User menu -->
            <ul class="navbar-nav ms-auto">
                <li class="nav-item dropdown" sec:authorize="isAuthenticated()">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        <i class="bi bi-person-circle"></i>
                        <span sec:authentication="name"></span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end">
                        <li><a class="dropdown-item" th:href="@{/profile}">Profile</a></li>
                        <li><hr class="dropdown-divider"/></li>
                        <li>
                            <form th:action="@{/logout}" method="post" class="d-inline">
                                <button type="submit" class="dropdown-item text-danger">Logout</button>
                            </form>
                        </li>
                    </ul>
                </li>
                <li class="nav-item" sec:authorize="!isAuthenticated()">
                    <a class="nav-link" th:href="@{/auth/login}">
                        <i class="bi bi-box-arrow-in-right"></i> Login
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>
```

**Features:**
- `sec:authorize="hasRole('Admin')"` - conditionally show admin menu
- `sec:authorize="isAuthenticated()"` - show user menu when logged in
- `sec:authentication="name"` - display current username

### **Fragment: `fragments/alerts.html`**

Flash message display (success, error, warning):

```html
<div th:fragment="alerts">
    <div th:if="${success}" class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i>
        <span th:text="${success}"></span>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <div th:if="${error}" class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-triangle me-2"></i>
        <span th:text="${error}"></span>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <div th:if="${warning}" class="alert alert-warning alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-circle me-2"></i>
        <span th:text="${warning}"></span>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</div>
```

**Usage in Controller:**
```java
RedirectAttributes attrs = ...;
attrs.addFlashAttribute("success", "Build created successfully!");
return "redirect:/builds";
```

### **Fragment: `fragments/buildCard.html`**

Reusable build card component:

```html
<div th:fragment="buildCard(build)" class="card h-100 shadow-sm">
    <!-- Primary image or placeholder -->
    <a th:href="@{/builds/{id}(id=${build.buildId})}">
        <img th:if="${build.hasPrimaryImage()}"
             th:src="@{/uploads/{path}(path=${build.filePath})}"
             th:alt="${build.buildId}"
             class="card-img-top build-card-img object-fit-cover"/>
        <div th:unless="${build.hasPrimaryImage()}"
             class="card-img-top build-card-img bg-secondary d-flex align-items-center justify-content-center">
            <i class="bi bi-image text-white" style="font-size:3rem;"></i>
        </div>
    </a>

    <div class="card-body d-flex flex-column">
        <h5 class="card-title">
            <a th:href="@{/builds/{id}(id=${build.buildId})}"
               th:text="${build.buildId}"
               class="text-decoration-none text-dark stretched-link">
            </a>
        </h5>
        <p class="card-text text-muted small mb-1">
            <i class="bi bi-person"></i> <span th:text="${build.userDisplayName}">Builder</span>
            &nbsp;·&nbsp;
            <i class="bi bi-globe"></i> <span th:text="${build.worldId ?: 'Unknown'}">World</span>
        </p>
        <p class="card-text text-muted small mb-1">
            <i class="bi bi-tags"></i> <span th:text="${build.buildTypeId ?: 'Uncategorized'}">Type</span>
        </p>
        <p class="card-text small text-truncate mt-auto" th:text="${build.buildDescription}">
            Description
        </p>
    </div>

    <div class="card-footer text-muted small">
        <i class="bi bi-geo-alt"></i>
        <span th:text="${build.coordString()}">Coords</span>
    </div>
</div>
```

**Usage:**
```html
<th:block th:each="b : ${builds}">
    <div class="col">
        <th:block th:replace="~{fragments/buildCard :: buildCard(build=${b})}"/>
    </div>
</th:block>
```

### **Vote Fragments: `fragments/vote/`**

#### **Fragment: `vote-card.html`**
Vote summary card (similar to buildCard).

#### **Fragment: `vote-forms.html`**
Vote option forms (for vote creation/editing).

#### **Fragment: `vote-pagination.html`**
Pagination controls for vote listings.

#### **Fragment: `vote-tabs.html`**
Tabbed interface for vote states (Active, Pending, Concluded, Draft).

### **Fragment: `fragments/footer.html`**

Simple footer with branding and links.

```html
<footer th:fragment="footer" class="bg-dark text-light text-center py-3 mt-auto border-top">
    <div class="container">
        <small>&copy; 2024 SMP Portal. All rights reserved.</small>
    </div>
</footer>
```

### **Child Template Example: `build/list.html`**

```html
<!DOCTYPE html>
<html lang="en"
      xmlns:th="http://www.thymeleaf.org"
      xmlns:layout="http://www.ultraq.net.nz/thymeleaf/layout"
      layout:decorate="~{layouts/main}">

<head>
    <title>Builds</title>
</head>

<main layout:fragment="content">
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-hammer me-2"></i>Builds</h2>
        <a th:href="@{/builds/new}" class="btn btn-primary">
            <i class="bi bi-plus-lg me-1"></i>New Build
        </a>
    </div>

    <!-- Filters Form -->
    <form method="get" th:action="@{/builds}" class="row g-2 mb-4">
        <div class="col-12 col-sm-6 col-md-3">
            <select name="worldId" class="form-select form-select-sm">
                <option value="">All Worlds</option>
                <option th:each="w : ${worlds}"
                        th:value="${w.worldId}"
                        th:text="${w.worldId}"
                        th:selected="${w.worldId == worldId}"></option>
            </select>
        </div>
        <!-- More filters... -->
        <div class="col-12">
            <button type="submit" class="btn btn-sm btn-outline-primary">Filter</button>
        </div>
    </form>

    <!-- Builds Grid -->
    <div class="row g-3">
        <th:block th:each="b : ${builds}">
            <div class="col-md-6 col-lg-4">
                <th:block th:replace="~{fragments/buildCard :: buildCard(build=${b})}"/>
            </div>
        </th:block>
    </div>

    <!-- Pagination -->
    <nav class="mt-4">
        <ul class="pagination">
            <li class="page-item" th:classappend="${page == 0 ? 'disabled' : ''}">
                <a class="page-link" th:href="@{/builds(page=${page - 1})}">Previous</a>
            </li>
            <li class="page-item active">
                <span class="page-link" th:text="${page + 1}"></span>
            </li>
            <li class="page-item">
                <a class="page-link" th:href="@{/builds(page=${page + 1})}">Next</a>
            </li>
        </ul>
    </nav>
</main>
```

**Decorator Pattern:**
- `layout:decorate="~{layouts/main}"` - applies main.html as parent
- `layout:fragment="content"` - replaces the `<main layout:fragment="content">` in main.html
- `<title>` becomes `Builds - SMP Portal` via `layout:title-pattern`

---

## Authentication & Security

### **Spring Security Configuration**

File: `config/SecurityConfig.java`

- **Authentication:** UserDetailsService implementation (validates credentials)
- **Password Encoding:** BCrypt (hashed in database)
- **Authorization:**
  - Role-based: `hasRole('Admin')`
  - Granular: Custom permission checks via Role entity
  - Per-endpoint security rules in `SecurityConfig`
- **Session Management:** Default Spring Security session handling
- **CSRF Protection:** Enabled by default
- **Thymeleaf Integration:** `thymeleaf-extras-springsecurity6` for `sec:*` attributes

### **Key Security Annotations**

In templates:
```html
<!-- Show only to authenticated users -->
<div sec:authorize="isAuthenticated()">...</div>

<!-- Show only to Admins -->
<div sec:authorize="hasRole('Admin')">...</div>

<!-- Get current username -->
<span sec:authentication="name"></span>
```

In controllers:
```java
// Inject current authenticated user
@PostMapping
public String create(@AuthenticationPrincipal UserDetails userDetails) {
    String currentUser = userDetails.getUsername();
    // ...
}
```

---

## Configuration

### **Application Properties: `application.properties`**

```properties
# ─── Server ────────────────────────────────────────────────────────────────────
server.port=8080

# ─── DataSource (MariaDB) ───────────────────────────────────────────────────────
spring.datasource.url=jdbc:mariadb://localhost:3306/smpdb
spring.datasource.username=appuser
spring.datasource.password=KylaMaya2558
spring.datasource.driver-class-name=org.mariadb.jdbc.Driver

# Connection pool tuning (HikariCP)
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=2
spring.datasource.hikari.connection-timeout=30000

# ─── Thymeleaf ──────────────────────────────────────────────────────────────────
spring.thymeleaf.cache=false
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html

# ─── File Upload ────────────────────────────────────────────────────────────────
spring.servlet.multipart.enabled=true
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB

# Directory where uploaded images are saved on disk
app.upload.dir=./uploads

# ─── Logging ────────────────────────────────────────────────────────────────────
logging.level.com.jayrodharv=DEBUG
logging.level.org.springframework.security=INFO

# Error handling
spring.web.error.path=/error
spring.web.error.whitelabel.enabled=false
```

### **MVC Configuration: `config/MvcConfig.java`**

- View resolver setup (Thymeleaf already auto-configured)
- Static resource mappings (CSS, JS, images)
- Message source for i18n (if implemented)

### **File Upload Configuration**

- **Directory:** `./uploads/` (relative to application working directory)
- **Max File Size:** 10MB
- **File Strategy:** SHA-256 hash naming for deduplication
- **MIME Type:** Stored for validation

---

## Key Design Patterns

### **1. Decorator/Layout Pattern**
- Master layout in `layouts/main.html`
- Child templates use `layout:decorate` to inherit structure
- `layout:fragment` overrides specific sections

### **2. Fragment Reuse**
- Common UI components as fragments (navbar, alerts, cards)
- `th:replace` for fragment inclusion
- Fragment parameters for dynamic content

### **3. View Model Pattern**
- Entity models for database persistence
- Separate VM classes for presentation (denormalized data)
- Service layer hydrates related objects (e.g., images list)

### **4. DAO Layer Abstraction**
- DAOs encapsulate SQL queries
- Services orchestrate DAO calls
- Controllers never access DAOs directly

### **5. Role-Based Access Control**
- Granular permission model at database level
- Role entity with 24 permission flags
- Authorization checks in controllers and templates

### **6. Flash Messages**
- RedirectAttributes for post-request feedback
- Alerts fragment for consistent display
- Success, error, warning message types

---

## Future Enhancements (from schema comments)

The database schema includes commented-out tables for future features:

1. **2FA (Two-Factor Authentication)**
   - 2fa_code table (email/SMS/phone methods)

2. **Password Reset**
   - PasswordReset table (token-based resets)

3. **Discussion Forum**
   - DiscussionForm and Message tables
   - Comments/messaging per build or vote

4. **Build Type Colors**
   - TODO: Add color field to BuildType
   - Use HTML5 `<input type="color">` picker

---

## Summary

This is a well-structured Spring Boot MVC application with:

- **Clear separation of concerns** (controllers → services → DAOs)
- **Reusable Thymeleaf components** (fragments, layouts)
- **Flexible data access** (raw SQL, stored procedures, no ORM)
- **Comprehensive permissions model** (granular role-based access)
- **Community-focused features** (builds, votes, worlds)
- **Modern frontend** (Bootstrap 5, responsive design)
- **Secure authentication** (Spring Security, BCrypt passwords)

The architecture is maintainable, testable, and easily extensible for future features.

