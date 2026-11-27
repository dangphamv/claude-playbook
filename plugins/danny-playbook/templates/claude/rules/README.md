# Path rules

Rules load only when Claude touches files matching `paths`. /danny-playbook:init and /pb-ux create real rules
(e.g. `api.md`, `frontend.md`, `db.md`) for this project's stack. Example:

```markdown
---
paths: ["apps/api/**"]
---
- Validate every request body; errors use one documented format.
- New queries on large tables need an index; check with EXPLAIN.
```
