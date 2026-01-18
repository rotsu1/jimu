# Database Schema Documentation: Fitness & Social Tracker

## 1. System Overview
* **Platform:** PostgreSQL (Supabase)
* **Authentication:** Managed via Supabase Auth (Google/Apple OAuth).
* **Identity Management:** The `auth.users` table (managed by Supabase) is the source of truth for Identity. The `public.profiles` table extends this identity with application-specific data.

---

## 2. Core Data Models (Entities)

### A. User Management Module

#### `profiles`
**Purpose:** Stores public-facing user data.
**Relationship:** 1:1 with `auth.users`.

* **`id`** *(PK, UUID)*: References `auth.users`.
* **`username`** *(Unique)*: Public handle.
* **`subscription_plan`**: Enum (`free`, `monthly`, `yearly`, `lifetime`). Logic gates feature access.
* **`is_private_account`**: Boolean flag affecting visibility of `workouts` and `follows`.
* **Metrics (Denormalized):** `total_workouts`, `current_streak`, `total_calories_burned`.
    > **Note:** These are cached counters updated via triggers or application logic to avoid expensive aggregation queries.

#### `user_settings`
**Purpose:** Stores private user preferences and device configurations.
**Relationship:** 1:1 with `profiles`.
**Security:** Strictly Private (Row Level Security allows only the owner to read/write).

* **`face_id_enabled`**: Local app security flag.
* **Notifications:** Toggles for `daily_reminder`, `new_follower`, `likes`, `comments`.
* **Training Prefs:**
    * `sound_enabled`
    * `default_timer` settings
    * `auto_fill_previous_values`: Determines if the UI should pre-fill weights/reps from the last session.
* **Units:** Enums for `unit_weight` (kg/lbs), `unit_distance` (km/miles), `unit_length` (cm/inch).

#### `follows`
**Purpose:** Manages the social graph.
**Relationship:** Many-to-Many (Self-referencing `profiles`).

* **`follower_id`**: The user who is following.
* **`following_id`**: The user being followed.
* **`status`**: Enum `pending` or `accepted`.
    > **Note:** If `profiles.is_private_account` is true, logic should enforce `pending` status upon creation.

---

### B. Exercise Library Module

#### `exercises`
**Purpose:** A library of performable movements.
**Ownership Model:** Hybrid.

1.  **System Exercises:** `created_by` is `NULL`. Visible to everyone.
2.  **Custom Exercises:** `created_by` references a `profile.id`. Visible only to the creator.

* **Attributes:** `name`, `image_url`, `target_muscles` (Array), `equipment_used` (Array).
* **`suggested_rest_seconds`**: A default value for timers.

---

### C. Workout Logging Module (The Core Loop)

The logging system is hierarchical:
**Workouts** (Session) → **Workout_Exercises** (Movement) → **Workout_Sets** (Effort).

#### `workouts`
**Purpose:** Represents a single training session.

* **`visibility`**: Enum determining who can view this:
    * `public`: Visible to all.
    * `followers_only`: Visible to approved followers.
    * `private`: Visible only to owner.
* **Time Tracking:** `started_at`, `ended_at`, and `duration_seconds` (allows for manual override if the app crashes or user forgets to end workout).
* **Context:** `name`, `comment`, `image_url`.

#### `workout_exercises`
**Purpose:** The instance of an `exercise` performed within a specific `workout`.

* **`order_index`**: Maintains the sequence of exercises in the UI.
* **`rest_timer_seconds`**: Specific rest timer used for this instance (overrides the generic default).
* **`memo`**: Exercise-specific notes for this session.

#### `workout_sets`
**Purpose:** The atomic data of the workout (Weight x Reps).

* **`weight`**: Numeric (supports decimals).
    > **Note:** The unit (kg/lbs) is not stored here; it is inferred from `user_settings` at display time, or normalized to kg on save.
* **`reps`**: Integer.
* **`is_completed`**: Boolean checkbox state from the UI.
* **`order_index`**: Maintains set order (Set 1, Set 2, etc.).

---

## 3. Enumerations & Data Types
Strong typing is used to enforce business logic at the database level.

| Enum Name | Allowed Values |
| :--- | :--- |
| `subscription_tier` | `free`, `monthly`, `yearly`, `lifetime` |
| `visibility_type` | `public`, `private`, `followers_only` |
| `weight_unit` | `kg`, `lbs` |
| `distance_unit` | `km`, `miles` |
| `length_unit` | `cm`, `inch` |
| `theme_option` | `system`, `light`, `dark` |

---

## 4. Security & Access Control (RLS)
The database uses Row Level Security (RLS) to strictly enforce privacy.

### Public Access
* `profiles`: Read-only.
* `follows`: Read-only.
* `workouts`: Read-only **WHERE** `visibility = 'public'`.
* `exercises`: Read-only **WHERE** `created_by` is `NULL`.

### Authenticated User Access (Owner)
* **Full CRUD:** Own `profiles`, `user_settings`, `workouts`, `workout_exercises`, `workout_sets`.
* **Custom Exercises:** Can create/read own exercises.
* **Social:** Can create a follow request (as follower) or delete a connection (as follower or following).

### Follower Access
* Logic exists to allow followers to view workouts where `visibility = 'followers_only'`, though the implementation provided relies on a simplified join.

---

## 5. Automation & Triggers
* **New User Handling:** A trigger `on_auth_user_created` automatically inserts a row into `public.profiles` and `public.user_settings` immediately after signup. This ensures `user_id` FK constraints are satisfied before the app attempts to load the home screen.

---

## 6. Client-Side Mapping (Swift)
The database schema maps to Swift structs using `Codable`.

* **Naming Convention:** Database uses `snake_case` (e.g., `display_name`), Swift uses `camelCase` (e.g., `displayName`).
* **UUID Handling:** Handled natively as `UUID` type in Swift.
* **Dates:** PostgreSQL `timestamp with time zone` maps to Swift `Date`.

### Key Integration Logic
1.  **Fetching Workouts:** When fetching `workouts`, the client likely performs a deep fetch (joining `workout_exercises` and `workout_sets`) to rebuild the session view.
2.  **Units:** The database stores raw numbers. The UI must check `user_settings.unit_weight` to determine if `workout_sets.weight` should be displayed as "kg" or converted to "lbs".