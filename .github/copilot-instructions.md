# GitHub Copilot Instructions for onec-docker

## Project Overview

This repository contains Docker configurations for building Docker images with 1C:Enterprise (1С:Предприятие) 8.3 platform - a popular Russian ERP and business automation platform. The project provides containerized solutions for various 1C components including servers, clients, development tools, and CI/CD agents.

## Key Technologies and Patterns

### Core Technologies
- **Docker & Docker Compose**: Primary containerization technology
- **1C:Enterprise Platform**: Russian ERP platform (versions 8.3.x)
- **OneScript (oscript)**: Scripting language for 1C automation
- **EDT (Enterprise Development Tools)**: 1C development environment
- **Vanessa Runner**: Testing framework for 1C
- **Jenkins**: CI/CD integration with Docker agents

### Languages and Scripts
- **Dockerfile**: Container definitions
- **Bash scripts**: Build automation and utilities
- **Batch files (.bat)**: Windows build scripts
- **Makefile**: Build orchestration
- **Russian language**: Documentation and comments are primarily in Russian

## Repository Structure Guidelines

### Docker Images Organization
Each directory represents a specific Docker image:
- `server/`: 1C:Enterprise server
- `client/`: 1C:Enterprise thick client
- `thin-client/`: 1C:Enterprise thin client
- `edt/`: Enterprise Development Tools
- `oscript/`: OneScript runtime
- `vanessa-runner/`: Testing framework
- `jenkins-agent/`: CI/CD agents
- `coverage41C/`: Code coverage tools

### Build Scripts Pattern
- `build-*.sh`: Linux build scripts
- `build-*.bat`: Windows build scripts
- Scripts follow naming pattern: `build-<component>-<environment>-<type>.{sh|bat}`

## Coding Standards and Best Practices

### Dockerfile Guidelines
1. **Multi-stage builds**: Use when downloading/building dependencies
2. **ARG variables**: Follow existing pattern for build arguments:
   ```dockerfile
   ARG ONEC_USERNAME
   ARG ONEC_PASSWORD
   ARG ONEC_VERSION
   ARG DOCKER_REGISTRY_URL
   ```
3. **Base image pattern**: Use registry URL pattern:
   ```dockerfile
   FROM ${DOCKER_REGISTRY_URL}${DOCKER_REGISTRY_URL:+/}base-image:tag
   ```
4. **Labels**: Include maintainer information
5. **Layer optimization**: Combine RUN commands to minimize layers

### Environment Variables
Standard environment variables used across the project:
- `ONEC_USERNAME`: 1C releases portal username
- `ONEC_PASSWORD`: 1C releases portal password
- `ONEC_VERSION`: 1C platform version (format: 8.3.x.xxxx)
- `EDT_VERSION`: EDT version
- `DOCKER_REGISTRY_URL`: Docker registry URL
- `COVERAGE41C_VERSION`: Coverage tool version

### Build Scripts
1. **Error handling**: Include proper error checking and exit codes
2. **Variable validation**: Check required environment variables
3. **Logging**: Provide informative output messages
4. **Cross-platform**: Maintain both .sh and .bat versions when applicable

### Makefile Targets
Follow existing pattern for Make targets:
- Use environment variables for configuration
- Include docker build with proper arguments
- Tag images with both version and 'latest' tags
- Use `.PHONY` declarations

## 1C:Enterprise Specific Guidelines

### Version Management
- 1C versions follow pattern: `8.3.x.xxxx` (e.g., 8.3.18.1520)
- Different components may require different version compatibility
- Check version compatibility when updating dependencies

### Localization Support
- Support both Russian and international localizations
- Use `nls_enabled=true` build argument for multi-language support
- Preserve Russian language in comments and documentation

### Platform Components
- **Server**: Database server component
- **Client**: Full desktop client
- **Thin Client**: Web-based client
- **CRS**: Configuration Repository Server
- **RAC**: Remote Administration Console

## Security and Credentials

### Sensitive Information
- Never hardcode credentials in Dockerfiles or scripts
- Use build arguments for credentials (ONEC_USERNAME, ONEC_PASSWORD)
- Provide example files (.example suffix) for configuration
- Use environment variables for runtime configuration

### Download Authentication
- 1C platform requires authentication to download from releases.1c.ru
- Use oneget tool for secure downloads when possible
- Handle download failures gracefully

## Testing and Validation

### Build Validation
- Test builds with different 1C versions
- Validate multi-architecture support where applicable
- Check both Linux and Windows build scripts

### Integration Testing
- Test with docker-compose configurations
- Validate Jenkins agent functionality
- Check VNC connectivity for GUI clients

## Documentation Standards

### Code Comments
- Use Russian for 1C-specific terminology
- Include English translations for complex concepts
- Document version compatibility and requirements

### README Updates
- Update version information when adding new components
- Include build examples for new Docker images
- Maintain table of contents structure

## Common Patterns to Follow

### Container Naming
- Use pattern: `${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}onec-<component>:${VERSION}`
- Tag both specific version and 'latest'
- Use descriptive suffixes (-nls, -vnc, etc.)

### Volume Mounts
- Follow 1C standard paths: `/opt/1cv8/`, `/var/1cv8/`
- Use consistent mount points across related containers
- Document required volumes in README

### Network Configuration
- Use standard 1C ports (1540-1541 for server, 1545 for ras)
- Document port requirements for each service
- Consider cluster configurations

## Maintenance Guidelines

### Version Updates
- Update .env.example files when changing default versions
- Test compatibility across the entire stack
- Update documentation with version-specific changes

### Dependencies
- Monitor 1C platform releases for security updates
- Keep OneScript and related tools updated
- Validate third-party tool compatibility

## Error Handling

### Common Issues
- Authentication failures to 1C releases portal
- Version compatibility problems
- Network connectivity issues during builds
- Missing dependencies or tools

### Debug Information
- Include version information in build outputs
- Log download URLs and file checksums
- Preserve error messages in Russian when from 1C tools

## AI Assistant Guidelines

When working with this repository:

1. **Respect the bilingual nature**: Maintain Russian language in documentation and comments for 1C-specific terminology while providing English explanations for international contributors
2. **Follow 1C conventions**: Understand that 1C:Enterprise has specific naming conventions, file structures, and deployment patterns
3. **Consider enterprise context**: This is enterprise software with licensing, authentication, and complex deployment requirements
4. **Maintain security**: Always use build arguments for credentials, never hardcode sensitive information
5. **Test comprehensively**: Changes should be tested across multiple 1C versions and deployment scenarios
6. **Document thoroughly**: Include both Russian and English documentation for new features

Remember: This project serves the Russian 1C community, so maintain Russian language support and cultural context while ensuring international accessibility through clear documentation and examples.