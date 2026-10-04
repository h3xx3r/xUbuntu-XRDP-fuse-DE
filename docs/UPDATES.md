# Updates

The recommended image tag for production is:

```text
ghcr.io/h3xx3r/xubuntu-xrdp-fuse-de:stable
```

`latest` tracks the main branch. Version tags such as `v1.0.0` are immutable release references.

On Unraid, normal Docker image updates should be used. Persistent user data and printer golden profiles are stored under the `/home` mapping and survive image replacement.

Before a major upgrade, back up the mapped Unraid appdata directory.

The GitHub Actions workflow publishes:

- `latest` on pushes to `main`
- `stable` when a version tag is pushed
- the exact version tag, e.g. `v1.0.0`
