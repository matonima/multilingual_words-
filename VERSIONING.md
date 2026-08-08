# Versioning and pushing updates

The project uses semantic versions stored in `VERSION` and
`application/config/version` in `project.godot`. VS Code/Cursor tasks are in
`.vscode/tasks.json`.

## One-time setup

1. Open the project folder in VS Code or Cursor.
2. Configure your Git author if needed:

   ```powershell
   git config user.name "Your Name"
   git config user.email "you@example.com"
   ```

3. Run **Tasks: Run Task → Git: Configure origin**, and paste the HTTPS or SSH
   URL of the empty repository you created on GitHub, GitLab, or another host.
4. Create and push the initial snapshot:

   ```powershell
   git add -A
   git commit -m "Initial Words app"
   git push -u origin main
   ```

## Every update

Run one of these tasks:

- **Release: Patch** for fixes (`1.0.0` → `1.0.1`).
- **Release: Minor** for new compatible features (`1.0.0` → `1.1.0`).
- **Release: Major** for incompatible changes (`1.0.0` → `2.0.0`).

The release task checks Git configuration, runs the Godot smoke test, updates
both version files and the changelog, commits, creates an annotated `vX.Y.Z`
tag, and pushes the branch and tag to `origin`.

Use **Git: Status** to review changes and **Git: Push current branch** when you
only need to push an existing commit without creating a release.
