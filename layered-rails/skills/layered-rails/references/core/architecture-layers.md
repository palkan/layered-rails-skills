# Architecture Layers

## Contents

- The Four Layers (Presentation, Application, Domain, Infrastructure)
- The Four Layering Rules
- Mapping Rails Components to Layers
- Applying Layered Architecture in Practice
- Common Layering Mistakes

## The Four Layers (Presentation, Application, Domain, Infrastructure)

Rails applications are organized into four architecture layers with unidirectional data flow:

| Layer | Responsibility | Rails Examples |
|-------|----------------|----------------|
| **Presentation** | Handle user interactions, present information; all inbound entry points | Controllers, Views, Channels, Jobs (internal inbound), Form objects, Presenters |
| **Application** | Organize domain objects for use cases | Service objects, Policy objects, Mailers, Deliveries |
| **Domain** | Entities, rules, invariants, application state | Models, Value objects, Query objects, Domain events |
| **Infrastructure** | Supporting technologies | Active Record, API clients, File storage |

```
Presentation → Application → Domain → Infrastructure
```

## The Four Layering Rules

### Rule 1: Unidirectional Data Flow

Data flows from top to bottom only. Arrows in the architecture always point downward.

### Rule 2: No Reverse Dependencies

Lower layers must not depend on higher layers. A domain object should never depend on a controller or request object.

**Violations:**

```ruby
# BAD: Service (Application) depends on request (Presentation)
class HandleEventService
  param :request  # Reverse dependency!
end

# BAD: Model (Domain) depends on Current (Presentation context)
class Post < ApplicationRecord
  def destroy
    self.deleted_by = Current.user  # Hidden dependency!
    super
  end
end
```

**Correct:**

```ruby
# GOOD: Service accepts domain objects only
class HandleEventService
  param :event  # Value object, not request

  def call
    user = User.find_by(gh_id: event.user_id)
    # ...
  end
end

# GOOD: Model method accepts explicit parameters
class Post < ApplicationRecord
  def destroy_by(user:)
    self.deleted_by = user
    destroy
  end
end
```

### Rule 3: Abstraction Boundaries

Every abstraction layer must belong to a single architecture layer. An abstraction cannot span multiple architecture layers.

**Evaluating abstractions:**
- Does this object depend on objects from a higher layer? → Extract or refactor
- Does this object's responsibility match its architecture layer? → Move if not

### Rule 4: Minimize Inter-Layer Connections

Fewer connections = looser coupling = better testability and reusability.

**Good layering:**
```ruby
# Controller (Presentation) → Service (Application) → Model (Domain)
class PostsController
  def publish
    PublishPostService.call(post_id: params[:id], user: current_user)
    redirect_to posts_path
  end
end

class PublishPostService
  def call
    post = Post.find(post_id)
    post.publish!(by: user)  # Domain logic stays in model
  end
end
```

**Caveat — Architecture Sinkhole:** If you reduce connections to minimum (each layer only talks to adjacent layer), you may create objects that just proxy data through layers with no modification.

```ruby
# BAD: Service does nothing but proxy
class FindPostService
  def call(id)
    Post.find(id)  # No value added, just pass-through
  end
end
```

## Mapping Rails Components to Layers

### Presentation Layer

**Purpose:** Handle user interactions, present information

**Includes:**
- Controllers (HTTP request/response)
- Views (HTML rendering)
- Channels (WebSocket connections)
- Mailboxes (inbound email)
- Jobs (**internal inbound** entry points — same design rules as controllers, minus authentication and user-input handling)
- API serializers
- Form objects (user input handling)
- Filter objects (request parameter transformation)
- Presenters (view-specific logic)

**Primary concerns:**
- Request parsing and validation
- Authentication
- Response formatting
- User interface logic
- Building execution contexts for units of work (web requests and background jobs alike)

### Application Layer

**Purpose:** Organize domain objects for specific use cases

**Includes:**
- Service objects (business operations)
- Policy objects (authorization rules; enforcement stays in presentation)
- Interactors/Commands
- Mailers, deliveries, notifiers (notification orchestration; the delivery adapters they use — SMTP, push drivers — are infrastructure)

**Primary concerns:**
- Orchestrating domain objects
- Transaction boundaries
- Use-case specific logic

**Sub-layers:** The application layer is sometimes split into **Business** (framework-agnostic rules — e.g., policies) and **Services** (implementation-aware orchestration — e.g., mailers, deliveries). Either way, the invariant holds: mailers always belong to a layer above the domain layer — they are neither presentation (no user interaction) nor infrastructure (no transport details).

**Warning:** This layer is often overused. Don't strip all logic from models into services (anemic models anti-pattern).

### Domain Layer

**Purpose:** Entities, rules, invariants, application state

**Includes:**
- Models (business entities)
- Value objects (immutable concepts)
- Domain events
- Query objects and repositories (data retrieval logic — the **domain services** sub-layer sitting above domain models)
- Concerns (shared behaviors)
- Configuration classes (schema objects; their data sources — ENV, YAML, credentials — are infrastructure)

**Primary concerns:**
- Business rules and invariants
- Entity relationships
- Data transformations
- Domain-specific calculations

### Infrastructure Layer

**Purpose:** Supporting technologies

**Includes:**
- Active Record (database access)
- API clients (external services)
- File storage adapters
- Message queue adapters
- Mail/notification delivery adapters (SMTP, push drivers)
- Configuration sources (ENV, YAML, credentials)
- Cache implementations

**Primary concerns:**
- Persistence
- External communication
- Technical implementations

## Applying Layered Architecture in Practice

When designing or refactoring code:

1. **Identify the architecture layer** the code belongs to
2. **Check dependencies** — does it depend on higher layers?
3. **Apply specification test** — do tests verify appropriate responsibilities?
4. **Extract if needed** — move code to the correct layer

## Common Layering Mistakes

| Mistake | Problem | Solution |
|---------|---------|----------|
| Current in models | Hidden dependency on presentation context | Pass as explicit parameter |
| Request in services | Service depends on HTTP layer | Extract value object from request |
| Mailer in callbacks | Domain calls upward into the application layer | Move the notification to the service/delivery layer |
| SQL in controllers | Presentation doing infrastructure work | Use model scopes or query objects |
| Business logic in views | Presentation doing domain work | Use presenters or model methods |
