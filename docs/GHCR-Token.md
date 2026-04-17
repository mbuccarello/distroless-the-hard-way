# GitHub Container Registry (GHCR) Authentication

To run "Distroless The Hard Way" in your own repository fork, you must grant GitHub Actions the permission to publish OCI images to `ghcr.io`.

## Configure GITHUB_TOKEN Permissions
The simplest and most secure way to publish is to elevate the default repository token permissions.

1. Navigate to your Repository's **Settings**.
2. Click on **Actions** -> **General**.
3. Scroll down to the **Workflow permissions** section.
4. Select **Read and write permissions**.
5. Save the configuration.

In our repository pipelines, we authenticate via:
```yaml
- name: Authenticate to GitHub Container Registry
  run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
```

This ensures the pipeline can securely authenticate and push `artifacts`, `bootstrap`, and `base` images to your packages registry without requiring you to manually generate and manage a Personal Access Token (PAT).
