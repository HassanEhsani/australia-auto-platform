-- Enforce consistency between role scope and branch_id.
ALTER TABLE "user_role_assignments"
ADD CONSTRAINT "user_role_assignments_scope_branch_check"
CHECK (
  (
    "scope" = 'GLOBAL'::"RoleScope"
    AND "branch_id" IS NULL
  )
  OR
  (
    "scope" = 'BRANCH'::"RoleScope"
    AND "branch_id" IS NOT NULL
  )
);

-- Prevent duplicate active GLOBAL role assignments.
CREATE UNIQUE INDEX "user_role_assignments_active_global_unique"
ON "user_role_assignments" ("user_id", "role_id")
WHERE
  "revoked_at" IS NULL
  AND "scope" = 'GLOBAL'::"RoleScope";

-- Prevent duplicate active BRANCH role assignments.
CREATE UNIQUE INDEX "user_role_assignments_active_branch_unique"
ON "user_role_assignments" ("user_id", "role_id", "branch_id")
WHERE
  "revoked_at" IS NULL
  AND "scope" = 'BRANCH'::"RoleScope";
