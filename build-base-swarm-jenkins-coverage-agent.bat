@echo off

docker login -u %DOCKER_LOGIN% -p %DOCKER_PASSWORD% %DOCKER_REGISTRY_URL%

if %ERRORLEVEL% neq 0 goto end

if %DOCKER_SYSTEM_PRUNE%=="true" docker system prune -af

if %ERRORLEVEL% neq 0 goto end

if %NO_CACHE%=="true" (SET last_arg="--no-cache .") else (SET last_arg=".")

.\build-edt-swarm-agent.bat

set PUSH_AGENT='false'
.\build-base-swarm-jenkins-agent.bat

docker build ^
    --build-arg DOCKER_REGISTRY_URL=%DOCKER_REGISTRY_URL% ^
    --build-arg BASE_IMAGE=base-jenkins-agent ^
    --build-arg BASE_TAG=%ONEC_VERSION% ^
    --build-arg EDT_VERSION=%EDT_VERSION% ^
    --build-arg COVERAGE41C_VERSION=%COVERAGE41C_VERSION% ^
    -t %DOCKER_REGISTRY_URL%/base-jenkins-coverage-agent:%ONEC_VERSION% ^
    -f coverage41C/Dockerfile ^
    %last_arg%

docker push %DOCKER_REGISTRY_URL%/base-jenkins-coverage-agent:%ONEC_VERSION%

