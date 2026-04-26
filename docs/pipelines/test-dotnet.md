# Pipeline Specification: E2E Verification - dotnet

This pipeline performs automated functional assertions on the [dotnet Distroless image](assemble-dotnet.md).

---

## 1. Verification Objectives
- **Runtime Integrity**: Confirm the dotnet engine initializes within the shell-less environment.
- **Linkage Validation**: Ensure binary compatibility with the project-native Glibc and OpenSSL libraries.
- **Functional Check**: Execute `app/test-dotnet.cs` (published as binary) to verify CoreCLR and SSL connectivity.

