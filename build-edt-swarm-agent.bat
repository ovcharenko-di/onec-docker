@echo off

docker login -u %DOCKER_LOGIN% -p %DOCKER_PASSWORD% %DOCKER_REGISTRY_URL%

if %ERRORLEVEL% neq 0 goto end

if %DOCKER_SYSTEM_PRUNE%=="true" docker system prune -af

if %ERRORLEVEL% neq 0 goto end

if %NO_CACHE%=="true" (SET last_arg="--no-cache .") else (SET last_arg=".")

set edt_version=%EDT_VERSION%
set edt_escaped=%edt_version: =_%

.\build-edt.bat

docker build ^
    --build-arg DOCKER_REGISTRY_URL=%DOCKER_REGISTRY_URL% ^
    --build-arg BASE_IMAGE=edt ^
    --build-arg BASE_TAG=%edt_escaped% ^
    -t %DOCKER_REGISTRY_URL%/base-jenkins-agent:%edt_escaped% ^
    -f swarm-jenkins-agent/Dockerfile ^
    %last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_REGISTRY_URL%/base-jenkins-agent:%edt_escaped%

if %ERRORLEVEL% neq 0 goto end

:end
echo End of program.
