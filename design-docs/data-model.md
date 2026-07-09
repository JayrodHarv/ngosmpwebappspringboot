# smpdb data model

Reflects the schema after generalizing `post_type` and adding custom
fields via typed-column `post_field_value` (the chosen design — an earlier
JSON-column alternative was considered and dropped).

## Files & media

### `file`
Base row for any uploaded file (TPH pattern). `file_type` discriminates
into a detail table below.
- `file_id` PK, `file_type` (`IMAGE`|`VIDEO`), `hash` (unique, dedupe),
  `path`, `extension`, `mime_type`, `size_bytes`, `created_by` → `user`.

### `image` (detail)
1:1 extension of `file` for `file_type = IMAGE`.
- `file_id` PK/FK → `file`, `width_px`, `height_px`.

### `video` (detail)
1:1 extension of `file` for `file_type = VIDEO`.
- `file_id` PK/FK → `file`, `width_px`, `height_px`, `duration_seconds`,
  `thumbnail_file_id` → `file` (nullable).

### `post_file` (join)
Attaches uploaded media to a post. Joins to the base `file` table (not
`image`/`video` directly) so a single gallery can mix both types under one
shared `sort_order`.
- PK `(post_id, file_id)`, `role` (`COVER`|`GALLERY`), `caption`,
  `sort_order`, `created_by` → `user`. `ON DELETE RESTRICT` on `file_id` —
  deleting a post shouldn't cascade into deleting a file that might be
  referenced elsewhere (dedup via `file.hash`).

## Users, roles & permissions (RBAC)

### `user`
- `user_id` PK, `email` (unique), `display_name` (unique), `password_hash`,
  `status` (`ACTIVE`|`INACTIVE`|`LOCKED`), `pfp_image_id` → `image`.

### `system_user`
Marks a `user` row as a system/bot account (1:1 extension, no extra columns).

### `system_config`
Singleton row (`CHECK (system_config_id = 1)`) pointing at the system user,
used for seeding/bootstrap actions attributed to no real person.

### `role`
Named permission bundle. `role_id` PK, `name` (unique), `color_hex`.

### `permission`
Lookup table of individual permissions. `permission_id` PK, `name` (unique).

### `user_role` (join)
Many-to-many `user` ↔ `role`. PK `(user_id, role_id)`.

### `role_permission` (join)
Many-to-many `role` ↔ `permission`. PK `(role_id, permission_id)`.

### `user_permission` (join)
Per-user overrides on top of role-derived permissions. PK
`(user_id, permission_id)`, `effect` (`GRANT`|`DENY`) — lets a specific
user be granted or explicitly denied a permission regardless of their roles.

## Tags

### `tag_type`
Category/color grouping for tags. `tag_type_id` PK, `name` (unique),
`color_hex` (unique).

### `tag`
- `tag_id` PK, `tag_type_id` → `tag_type`, `name` (unique per type).

## Post types & custom fields

### `post_type`
Replaces the old fixed `post_type` ENUM. Rows are either system-defined
(`is_system = 1`, seeded at bootstrap: `BUILD`, `NEWS`, `VIDEO`,
`DISCUSSION`, `VOTE`) or created at runtime by users/moderators.
- `post_type_id` PK, `name` (unique), `slug` (unique), `is_system`.

### `post_type_field`
Defines the custom fields available on a given `post_type`. Built-in
types keep using dedicated detail tables (`build`, `vote`); this is for
fields on dynamically-created types.
- `field_id` PK, `post_type_id` → `post_type`, `field_key` (unique per
  type), `label`, `data_type` (`TEXT`|`NUMBER`|`BOOLEAN`|`DATE`|
  `DATETIME`|`URL`|`SELECT`|`FILE`), `is_required`, `sort_order`,
  `options` (JSON — e.g. select choices, min/max).

### `post_field_value`
Actual custom field values for posts of a dynamically-defined type. One
typed column per `data_type`; only the matching column is populated per
row (app-enforced).
- PK `(post_id, field_id)`, `value_text`, `value_number`, `value_boolean`,
  `value_date`, `value_datetime`. Indexed per-column, scoped by `field_id`,
  for fast filtering (`WHERE field_id = ? AND value_number > ?`).

## Posts

### `post`
Core content row for every post regardless of type (TPH pattern).
- `post_id` PK, `post_type_id` → `post_type`, `title` (unique), `slug`
  (unique), `body`, `status` (`DRAFT`|`PUBLISHED`|`ARCHIVED`), `pinned`,
  `view_count`, `like_count` (denormalized, trigger-maintained),
  `published_at`, `created_by`/`updated_by` → `user`.

### `post_tag` (join)
Many-to-many `post` ↔ `tag`, with `sort_order`. PK `(post_id, tag_id)`.

### `build` (detail)
1:1 extension of `post` for the system `BUILD` type.
- `build_id` PK/FK → `post`, `date_built`, `x_coord`/`y_coord`/`z_coord`.

### `post_reference` (join)
Self-referencing many-to-many: lets a post creator link other posts as
references, rendered as a clickable list rather than parsed from
wiki-style `[[links]]` embedded in the body. Directional — `post_id`
references `referenced_post_id` — so a "referenced by" / backlinks view is
just this table queried by `referenced_post_id` instead.
- PK `(post_id, referenced_post_id)`, `note` (optional), `sort_order`,
  `created_by` → `user`. `CHECK (post_id <> referenced_post_id)` prevents
  self-reference. Both FKs `ON DELETE CASCADE` — a reference is meaningless
  once either post is gone.

## Voting

Voting is *not* a scalar custom field — it has real relational structure
(multiple options, per-user selections) and stays as dedicated tables. See
the wizard/architecture discussion for whether it should be locked to the
`VOTE` post type or attachable to any post; the tables below support either.

### `vote` (detail)
1:1 extension of `post`. `vote_id` PK/FK → `post`, `start_at`, `end_at`,
`max_selections`.

### `vote_option`
- `option_id` PK, `vote_id` → `vote`, `title` (unique per vote),
  `description`, `sort_order`, `vote_count` (denormalized,
  trigger-maintained via `trg_user_vote_after_insert`/`_delete`).

### `vote_option_image` (join)
Attaches one or more images to a vote option. PK `(option_id, image_id)`,
`sort_order`.

### `user_vote`
Records who voted for what. PK `(user_id, vote_id, option_id)` — allows
multiple selections per user up to `vote.max_selections` (enforced at the
app layer).

## Likes

### `content_like`
- PK `(post_id, user_id)`. Triggers keep `post.like_count` in sync on
  insert/delete; `content_like` remains the source of truth for *who*
  liked what.

## Messaging

### `conversation`
- `conversation_id` PK, `is_group`, `title` (nullable, for group chats),
  `created_by` → `user`.

### `conversation_participant` (join)
- PK `(conversation_id, user_id)`, `role` (`OWNER`|`MEMBER`),
  `last_read_at` (for unread tracking).

### `message`
Unified table for both post comments and direct messages.
- `message_id` PK, `message_type` (`COMMENT`|`DIRECT`),
  `parent_message_id` → `message` (self-referencing, for reply threads),
  `body`, `created_by`/`updated_by` → `user`.

### `post_comment` (join)
Links a `COMMENT`-type message to the post it's on. PK
`(message_id, post_id)`.

### `conversation_message` (join)
Links a `DIRECT`-type message to its conversation. PK
`(message_id, conversation_id)`.

### `message_file` (join)
Attaches uploaded media to a message (comment or DM). Same rationale as
`post_file` — joins to base `file`, one shared `sort_order` for mixed
image/video galleries.
- PK `(message_id, file_id)`, `sort_order`.

## Audit

### `audit_log`
Generic change log across tables.
- `audit_id` PK, `table_name`, `action_type` (`INSERT`|`UPDATE`|`DELETE`),
  `record_id`, `changed_by` → `user`, `old_values`/`new_values` (JSON).

---

## Entity relationship summary

```
user ──< user_role >── role ──< role_permission >── permission
user ──< user_permission >── permission
user ──< file (created_by)
file ──1:1── image | video

post_type ──< post_type_field
post_type ──< post (post_type_id)
post ──1:1── build                      (system type)
post ──1:1── vote ──< vote_option ──< user_vote
                    vote_option ──< vote_option_image >── image
post ──< post_field_value >── post_type_field
post ──< post_tag >── tag ──< tag_type
post ──< post_file >── file ──1:1── image | video
post ──< post_reference >── post (self-referencing)
post ──< content_like >── user
post ──< post_comment >── message ──< message (parent_message_id, self-ref)
message ──< message_file >── file
conversation ──< conversation_participant >── user
conversation ──< conversation_message >── message
```
